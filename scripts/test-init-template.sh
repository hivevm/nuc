#!/usr/bin/env bash
#
# Tests the template bootstrap (ADR-0003) across every module combination.
#
# For each combination the working tree is copied to a temp directory (without .git), the
# bootstrap runs non-interactively, and the result is verified: consistency checks pass, the
# right files and ADRs exist (accepted) or are gone (with their index rows), the surviving ADRs
# are renumbered to a gapless 0001..N in the expected order, no module markers or references to
# removed artifacts remain, spacing stays clean, and a second bootstrap run is refused. The
# repository-identity paths (badges repointed via --repo, derived from a GitHub origin remote,
# removed when neither exists, badge selection via --badges, malformed values refused) and the
# project-identity paths (--maintainer fills the LICENSE copyright line; --license switches
# between MIT, Apache-2.0, and no license) are checked separately.
# Template-repo tooling only — the bootstrap removes this script in real projects.
#
# Pure bash + coreutils — present in the Dev Container base image.
#
# Usage:
#     scripts/test-init-template.sh        (or: bash scripts/test-init-template.sh)
# Exit code 0 when all combinations pass, 1 otherwise.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Modules in manifest order — the order in which their seed ADRs are numbered, and therefore the
# order the renumbered ADRs must appear in after the bootstrap. The module→file/ADR expectations
# in this script deliberately duplicate the manifest in scripts/init-template.sh: an independent
# oracle that catches manifest drift. When adding or changing a module, update both.
MODULES=(git-conventions supply-chain release conformance)

# ADRs are identified by their slug, not by a number: the bootstrap renumbers them, so which
# number a seed ADR ends up with depends on the combination.
CORE_ADRS=(agent-governance-model dev-container-runtime)   # always kept, always 0001 and 0002
INIT_ADR_SLUG=template-bootstrap-and-module-selection      # always removed with the mechanism
declare -A MODULE_ADR_SLUG=(
  [git-conventions]=git-conventions
  [supply-chain]=secrets-and-supply-chain
  [release]=versioning-and-releases
  [conformance]=external-conformance-tracking
)

# Every subset of MODULES, enumerated as a bitmask: 2^n combinations, 'none' and 'all' included.
# Enumerated rather than listed by hand so adding a module cannot silently leave a hole here.
build_combos() {
  local mask i parts
  for ((mask = 0; mask < (1 << ${#MODULES[@]}); mask++)); do
    parts=()
    for i in "${!MODULES[@]}"; do
      ((mask & (1 << i))) && parts+=("${MODULES[$i]}")
    done
    if ((${#parts[@]} == 0)); then
      COMBOS+=(none)
    elif ((${#parts[@]} == ${#MODULES[@]})); then
      COMBOS+=(all)
    else
      COMBOS+=("$(IFS=,; echo "${parts[*]}")")
    fi
  done
}
COMBOS=()
build_combos
ALL="$(IFS=,; echo "${MODULES[*]}")"

MARKER_RE='^[[:space:]>]*(<!--|#)[[:space:]]*module:([a-z][a-z,-]*)[[:space:]]+(begin|end)([[:space:]]*-->)?[[:space:]]*$'

errors=()
add_error() { errors+=("$1"); }

expand() { case "$1" in all) echo "$ALL" ;; none) echo "" ;; *) echo "$1" ;; esac; }
has() { case ",$1," in *",$2,"*) return 0 ;; *) return 1 ;; esac; }

# copy_tree <dst> — copy the template into <dst>, honouring gitignore (local editor/agent
# settings must not leak into the test tree); plain copy when not run from a git repository.
copy_tree() {
  local dst="$1" f
  if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$ROOT" ls-files -co --exclude-standard -z |
      while IFS= read -r -d '' f; do
        # Tracked-but-deleted files (uncommitted deletions) are still listed — skip them.
        [[ -f "$ROOT/$f" ]] || continue
        mkdir -p "$dst/$(dirname "$f")"
        cp -a "$ROOT/$f" "$dst/$f"
      done
  else
    cp -a "$ROOT/." "$dst/"
    rm -rf "$dst/.git"
  fi
}

# grep_clean <combo> <dir> <label> <grep-args...> — the tree must contain no match.
grep_clean() {
  local combo="$1" dir="$2" label="$3"; shift 3
  local hits
  if hits="$(grep -rIn --exclude-dir=.git "$@" "$dir" 2>/dev/null)"; then
    add_error "[$combo] leftover $label:"$'\n'"$hits"
  fi
}

check_combo() {
  local combo="$1" sel tmp out m nr
  sel="$(expand "$combo")"
  tmp="$(mktemp -d)"
  copy_tree "$tmp"

  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules "$combo" </dev/null 2>&1)"; then
    add_error "[$combo] bootstrap failed:"$'\n'"$out"
    rm -rf "$tmp"
    return
  fi

  # Consistency checks pass on the initialized tree (independently of the bootstrap's own run).
  out="$(bash "$tmp/scripts/check-docs.sh" 2>&1)" || add_error "[$combo] check-docs failed:"$'\n'"$out"
  if has "$sel" supply-chain; then
    out="$(bash "$tmp/scripts/check-action-refs.sh" 2>&1)" \
      || add_error "[$combo] check-action-refs failed:"$'\n'"$out"
  fi

  # Remaining scripts at least parse.
  local f
  while IFS= read -r f; do
    bash -n "$f" || add_error "[$combo] $f does not parse"
  done < <(find "$tmp/scripts" -name '*.sh')

  # Expected ADRs after the bootstrap: the two core ADRs, then the selected seeds in manifest
  # order, renumbered to a gapless 0001..N. The ADR describing the bootstrap is always gone.
  local expected=("${CORE_ADRS[@]}") actual=() i file rows
  for m in "${MODULES[@]}"; do
    has "$sel" "$m" && expected+=("${MODULE_ADR_SLUG[$m]}")
  done
  while IFS= read -r f; do actual+=("$(basename "$f")"); done \
    < <(find "$tmp/docs/adr" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)

  if ((${#actual[@]} != ${#expected[@]})); then
    add_error "[$combo] docs/adr holds ${#actual[@]} ADRs, expected ${#expected[@]}: ${actual[*]}"
  fi
  rows="$(grep -c '^| \[[0-9][0-9][0-9][0-9]\](' "$tmp/docs/adr/README.md")"
  ((rows == ${#expected[@]})) \
    || add_error "[$combo] ADR index holds $rows rows, expected ${#expected[@]}"

  for i in "${!expected[@]}"; do
    nr="$(printf '%04d' "$((i + 1))")"
    file="$nr-${expected[$i]}.md"
    if [[ "${actual[$i]:-}" != "$file" ]]; then
      add_error "[$combo] expected docs/adr/$file at position $((i + 1)), found '${actual[$i]:-<none>}'"
      continue
    fi
    grep -q "^# ADR-$nr:" "$tmp/docs/adr/$file" \
      || add_error "[$combo] $file: heading does not carry its own number ADR-$nr"
    grep -q "^| \[$nr\]($file)" "$tmp/docs/adr/README.md" \
      || add_error "[$combo] ADR index has no row '[$nr]($file)'"
  done

  # Selected seeds are accepted; deselected ones are gone, with every reference to them.
  local slug
  for m in "${MODULES[@]}"; do
    slug="${MODULE_ADR_SLUG[$m]}"
    if has "$sel" "$m"; then
      grep -q '^- \*\*Status:\*\* 🟢 accepted$' "$tmp/docs/adr/"[0-9][0-9][0-9][0-9]-"$slug.md" \
        || add_error "[$combo] seed ADR '$slug' not marked accepted"
      grep -q "^| \[[0-9]\{4\}\]([0-9]\{4\}-$slug.md).*🟢 accepted" "$tmp/docs/adr/README.md" \
        || add_error "[$combo] index row for '$slug' not marked accepted"
    else
      compgen -G "$tmp/docs/adr/[0-9][0-9][0-9][0-9]-$slug.md" >/dev/null \
        && add_error "[$combo] seed ADR '$slug' still present although '$m' was deselected"
      grep_clean "$combo" "$tmp" "reference to ADR '$slug'" -F "$slug.md"
    fi
  done

  # The bootstrap ADR goes with the mechanism it decides.
  compgen -G "$tmp/docs/adr/[0-9][0-9][0-9][0-9]-$INIT_ADR_SLUG.md" >/dev/null \
    && add_error "[$combo] bootstrap ADR still present"
  grep_clean "$combo" "$tmp" "bootstrap ADR references" -F "$INIT_ADR_SLUG"

  # Module-owned files exist exactly when their module was selected.
  assert_file() { # <combo> <path> <wanted 0|1> — file presence must match expectation
    local want="$3"
    if [[ -f "$tmp/$2" ]]; then
      ((want)) || add_error "[$combo] $2 still present"
    else
      ((want)) && add_error "[$combo] $2 missing"
    fi
  }
  local want
  has "$sel" git-conventions && want=1 || want=0
  assert_file "$combo" scripts/check-git-conventions.sh "$want"
  has "$sel" supply-chain && want=1 || want=0
  assert_file "$combo" scripts/check-action-refs.sh "$want"
  assert_file "$combo" .github/dependabot.yml "$want"
  has "$sel" release && want=1 || want=0
  assert_file "$combo" CHANGELOG.md "$want"
  has "$sel" conformance && want=1 || want=0
  assert_file "$combo" docs/CONFORMANCE.md "$want"
  assert_file "$combo" .github/workflows/checks.yml 1
  assert_file "$combo" scripts/init-template.sh 0
  assert_file "$combo" scripts/test-init-template.sh 0
  assert_file "$combo" scripts/licenses/Apache-2.0.txt 0
  [[ -d "$tmp/scripts/licenses" ]] && add_error "[$combo] scripts/licenses/ still present"

  # Project-identity defaults: no --license/--maintainer means the shipped MIT LICENSE survives
  # with its placeholder copyright holder, and the README License section still says MIT.
  assert_file "$combo" LICENSE 1
  grep -Eq '^Copyright \(c\) [0-9]{4} Maintainer$' "$tmp/LICENSE" \
    || add_error "[$combo] LICENSE lost its placeholder copyright line although no holder was given"
  grep -q 'Released under the MIT License' "$tmp/README.md" \
    || add_error "[$combo] README License section no longer says MIT although mit is the default"

  # No leftover markers, no references to removed artifacts, no bootstrap mentions anywhere —
  # the ADR that documented the mechanism is removed with it.
  grep_clean "$combo" "$tmp" "module markers" -E "$MARKER_RE"
  has "$sel" git-conventions || grep_clean "$combo" "$tmp" "git-conventions artifacts" -F "check-git-conventions"
  if ! has "$sel" supply-chain; then
    grep_clean "$combo" "$tmp" "supply-chain artifacts" -F "check-action-refs"
    # dependabot.yml, not the bare word: branch-name exemptions for bot branches legitimately
    # mention dependabot regardless of this module.
    grep_clean "$combo" "$tmp" "supply-chain artifacts" -F "dependabot.yml"
  fi
  has "$sel" release || grep_clean "$combo" "$tmp" "release artifacts" -F "CHANGELOG"
  has "$sel" conformance || grep_clean "$combo" "$tmp" "conformance artifacts" -F "CONFORMANCE"
  grep_clean "$combo" "$tmp" "bootstrap mentions" -F "init-template"

  # Repository identity: the copied tree has neither --repo nor an origin remote, so the badge,
  # its instruction comment, and the placeholder slug must be gone entirely (ADR-0003).
  grep_clean "$combo" "$tmp" "badge placeholder" -F 'hivevm/nuc'
  grep -q 'badge\.svg' "$tmp/README.md" \
    && add_error "[$combo] README badge survived although no repository slug was known"
  grep -q '<!-- The bootstrap script' "$tmp/README.md" \
    && add_error "[$combo] badge instruction comment survived"

  # Spacing hygiene: no run of three or more blank lines in any text file.
  while IFS= read -r f; do
    out="$(awk 'FNR==1{n=0} /^[[:space:]]*$/{if(++n==3) print FILENAME": line "FNR} !/^[[:space:]]*$/{n=0}' "$f")"
    [[ -n "$out" ]] && add_error "[$combo] triple blank line: $out"
  done < <(find "$tmp" -type f \( -name '*.md' -o -name '*.yml' -o -name '*.sh' \) -not -path '*/.git/*')

  # A second bootstrap run must be refused.
  cp "$ROOT/scripts/init-template.sh" "$tmp/scripts/"
  if out="$(bash "$tmp/scripts/init-template.sh" --modules none </dev/null 2>&1)"; then
    add_error "[$combo] second bootstrap run was not refused"
  elif [[ "$out" != *"already initialized"* ]]; then
    add_error "[$combo] second run failed with unexpected message: $out"
  fi

  rm -rf "$tmp"
}

# The repository-identity paths the combination loop cannot exercise (it always runs slug-less):
# explicit --repo, derivation from a GitHub origin remote, and rejection of a malformed --repo.
check_repo_slug() {
  local tmp out rc

  # --repo repoints the badge and removes the instruction comment.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules all --repo acme/widget </dev/null 2>&1)"; then
    add_error "[repo:flag] bootstrap failed:"$'\n'"$out"
  else
    grep -q 'github\.com/acme/widget/actions/workflows/checks\.yml/badge\.svg' "$tmp/README.md" \
      || add_error "[repo:flag] badge not repointed to acme/widget"
    grep -q 'workflows/ci\.yml/badge\.svg' "$tmp/README.md" \
      && add_error "[repo:flag] ci badge survived although the default selection is checks only"
    grep_clean "repo:flag" "$tmp" "badge placeholder" -F 'hivevm/nuc'
    grep -q '<!-- The bootstrap script' "$tmp/README.md" \
      && add_error "[repo:flag] badge instruction comment survived"
  fi
  rm -rf "$tmp"

  # Without --repo, the slug is derived from a github.com origin remote.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  git -C "$tmp" init -q
  git -C "$tmp" remote add origin git@github.com:acme/derived.git
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules none </dev/null 2>&1)"; then
    add_error "[repo:derived] bootstrap failed:"$'\n'"$out"
  else
    grep -q 'github\.com/acme/derived/actions' "$tmp/README.md" \
      || add_error "[repo:derived] badge not derived from the origin remote"
    grep_clean "repo:derived" "$tmp" "badge placeholder" -F 'hivevm/nuc'
  fi
  rm -rf "$tmp"

  # A malformed --repo is a usage error (2) and mutates nothing.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  out="$(bash "$tmp/scripts/init-template.sh" --modules none --repo 'not a slug' </dev/null 2>&1)"
  rc=$?
  ((rc == 2)) || add_error "[repo:invalid] expected usage error (exit 2) for a malformed --repo, got $rc:"$'\n'"$out"
  [[ -f "$tmp/scripts/init-template.sh" ]] \
    || add_error "[repo:invalid] refused run still mutated the tree"
  rm -rf "$tmp"

  # --badges all keeps every badge line; --badges none removes them all even with a known slug.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules none --repo acme/widget --badges all </dev/null 2>&1)"; then
    add_error "[badges:all] bootstrap failed:"$'\n'"$out"
  else
    grep -q 'github\.com/acme/widget/actions/workflows/checks\.yml/badge\.svg' "$tmp/README.md" \
      || add_error "[badges:all] checks badge missing"
    grep -q 'github\.com/acme/widget/actions/workflows/ci\.yml/badge\.svg' "$tmp/README.md" \
      || add_error "[badges:all] ci badge missing"
  fi
  rm -rf "$tmp"

  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules none --repo acme/widget --badges none </dev/null 2>&1)"; then
    add_error "[badges:none] bootstrap failed:"$'\n'"$out"
  else
    grep -q 'badge\.svg' "$tmp/README.md" \
      && add_error "[badges:none] a badge survived although none was selected"
    grep_clean "badges:none" "$tmp" "badge placeholder" -F 'hivevm/nuc'
  fi
  rm -rf "$tmp"

  # An unknown badge name is a usage error (2) and mutates nothing.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  out="$(bash "$tmp/scripts/init-template.sh" --modules none --badges nightly </dev/null 2>&1)"
  rc=$?
  ((rc == 2)) || add_error "[badges:invalid] expected usage error (exit 2) for an unknown badge, got $rc:"$'\n'"$out"
  [[ -f "$tmp/scripts/init-template.sh" ]] \
    || add_error "[badges:invalid] refused run still mutated the tree"
  rm -rf "$tmp"
}

# The project-identity paths: --maintainer fills the LICENSE copyright line, --license switches
# the license text (MIT stays, Apache-2.0 replaces, none removes LICENSE and every link to it).
check_project_identity() {
  local tmp out rc

  # --maintainer fills the MIT copyright line; the placeholder holder is gone.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules none --maintainer 'Acme Corp' </dev/null 2>&1)"; then
    add_error "[license:mit] bootstrap failed:"$'\n'"$out"
  else
    grep -Eq '^Copyright \(c\) [0-9]{4} Acme Corp$' "$tmp/LICENSE" \
      || add_error "[license:mit] LICENSE copyright line not filled with the maintainer"
    grep -Eq '^Copyright \(c\) [0-9]{4} Maintainer$' "$tmp/LICENSE" \
      && add_error "[license:mit] LICENSE still carries the placeholder holder"
  fi
  rm -rf "$tmp"

  # --license apache-2.0 replaces the LICENSE text, fills the appendix fields, updates the README.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules all --license apache-2.0 --maintainer 'Acme Corp' </dev/null 2>&1)"; then
    add_error "[license:apache] bootstrap failed:"$'\n'"$out"
  else
    grep -q 'Apache License' "$tmp/LICENSE" \
      || add_error "[license:apache] LICENSE does not carry the Apache text"
    grep -Eq 'Copyright [0-9]{4} Acme Corp' "$tmp/LICENSE" \
      || add_error "[license:apache] Apache appendix fields not filled with year and maintainer"
    grep -q 'Released under the Apache License 2.0' "$tmp/README.md" \
      || add_error "[license:apache] README License section not switched to Apache"
    grep -q 'MIT' "$tmp/README.md" \
      && add_error "[license:apache] README still mentions MIT"
    out="$(bash "$tmp/scripts/check-docs.sh" 2>&1)" \
      || add_error "[license:apache] check-docs failed:"$'\n'"$out"
  fi
  rm -rf "$tmp"

  # --license none removes LICENSE; no link to it survives, and the docs checks still pass.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  if ! out="$(bash "$tmp/scripts/init-template.sh" --modules none --license none </dev/null 2>&1)"; then
    add_error "[license:none] bootstrap failed:"$'\n'"$out"
  else
    [[ -f "$tmp/LICENSE" ]] && add_error "[license:none] LICENSE still present"
    grep_clean "license:none" "$tmp" "links to the removed LICENSE" -F '](LICENSE)'
    grep -q 'All rights reserved' "$tmp/README.md" \
      || add_error "[license:none] README License section not rewritten to all-rights-reserved"
    out="$(bash "$tmp/scripts/check-docs.sh" 2>&1)" \
      || add_error "[license:none] check-docs failed:"$'\n'"$out"
  fi
  rm -rf "$tmp"

  # An unknown license is a usage error (2) and mutates nothing.
  tmp="$(mktemp -d)"; copy_tree "$tmp"
  out="$(bash "$tmp/scripts/init-template.sh" --modules none --license wtfpl </dev/null 2>&1)"
  rc=$?
  ((rc == 2)) || add_error "[license:invalid] expected usage error (exit 2) for an unknown license, got $rc:"$'\n'"$out"
  [[ -f "$tmp/scripts/init-template.sh" ]] \
    || add_error "[license:invalid] refused run still mutated the tree"
  rm -rf "$tmp"
}

for combo in "${COMBOS[@]}"; do
  check_combo "$combo"
  echo "checked: $combo"
done
check_repo_slug
echo "checked: repository-identity paths"
check_project_identity
echo "checked: project-identity paths"

if ((${#errors[@]} > 0)); then
  echo "Bootstrap combination tests FAILED:"
  echo
  for e in "${errors[@]}"; do echo "  - $e"; done
  echo
  echo "${#errors[@]} problem(s) found."
  exit 1
fi

echo "Bootstrap tests passed (${#COMBOS[@]} combinations + repository- and project-identity paths)."
exit 0
