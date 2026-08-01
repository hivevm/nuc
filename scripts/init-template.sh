#!/usr/bin/env bash
#
# Template bootstrap (ADR-0003): run once, at the first interaction in a project created from
# this template. Keeps the policy modules chosen for this project, removes every file and every
# marked text block belonging to the modules that were not chosen, marks the chosen seed ADRs
# accepted (the human's selection is the acceptance), repoints the README CI badge to this
# project's repository (or removes it when none is known), renumbers the surviving ADRs to a
# gapless 0001..N, deletes itself, and verifies the result with the remaining check scripts.
#
# Usage:
#     scripts/init-template.sh --modules <name>[,<name>...] | all | none  [--repo <owner/name>]
#     scripts/init-template.sh --list
# Without --modules on a terminal, each module is asked interactively. Without --repo, the badge
# slug is derived from a github.com 'origin' remote; without either, the badge is removed.
#
# Recovery from a partial run: `git reset --hard` (the template state is committed).
# Exit code 0 on success, 1 on failure, 2 on usage errors.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="$(basename "${BASH_SOURCE[0]}")"

# ---------------------------------------------------------------------------- module manifest --
# scripts/test-init-template.sh re-states this mapping as its own expectations — deliberately, as
# an independent oracle. When adding or changing a module, update both.
MODULES=(git-conventions supply-chain release conformance)
declare -A MODULE_DESC=(
  [git-conventions]="Branch naming, Conventional Commit subjects, squash merge (CI-checked)"
  [supply-chain]="SHA-pinned GitHub Actions, secrets rules, Dependabot pin updates (CI-checked)"
  [release]="SemVer + keep-a-changelog CHANGELOG.md, human-only release process"
  [conformance]="docs/CONFORMANCE.md anchoring the project to an external spec or project it derives from — choose only if such a source exists"
)
declare -A MODULE_ADR=(
  [git-conventions]=0004
  [supply-chain]=0005
  [release]=0006
  [conformance]=0007
)
declare -A MODULE_FILES=(          # deleted when the module is deselected
  [git-conventions]="scripts/check-git-conventions.sh"
  [supply-chain]="scripts/check-workflow-pins.sh .github/dependabot.yml"
  [release]="CHANGELOG.md"
  [conformance]="docs/CONFORMANCE.md"
)
INIT_FILES=(scripts/test-init-template.sh)   # bootstrap tooling, always removed (self is last)
INIT_ADR=0003                      # the ADR describing this mechanism — removed with the mechanism
MARKED_FILES=(
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md CHANGELOG.md
  docs/adr/README.md
  .github/workflows/checks.yml
  .github/workflows/ci.yml
  .github/dependabot.yml
)
ADR_INDEX="docs/adr/README.md"

# Repository identity (ADR-0003): the placeholder appears only in the README badge line and the
# instruction comment above it — that restriction is what makes the rewrite below total.
REPO_PLACEHOLDER='hivevm/nuc'
REPO_SLUG_RE='^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$'
REPO_SLUG=''                       # resolved chain: --repo, else origin remote, else empty
BADGE_COMMENT_RE='^<!-- The bootstrap script'
badge_result=''

MARKER_RE='^[[:space:]>]*(<!--|#)[[:space:]]*module:([a-z][a-z,-]*)[[:space:]]+(begin|end)([[:space:]]*-->)?[[:space:]]*$'

SELECTED=()
errors=()
add_error() { errors+=("$1"); }
removed=()
kept=()
renumbered=()
declare -A NEW_NR=()               # old ADR number -> number after renumbering

# ------------------------------------------------------------------------------------ helpers --
usage() {
  cat <<'EOF'
Usage:
    scripts/init-template.sh --modules <name>[,<name>...] | all | none  [--repo <owner/name>]
    scripts/init-template.sh --list
Without --modules on a terminal, each module is asked interactively. Without --repo, the badge
slug is derived from a github.com 'origin' remote; without either, the badge is removed.

Recovery from a partial run: `git reset --hard` (the template state is committed).
Exit code 0 on success, 1 on failure, 2 on usage errors.
EOF
}

list_modules() {
  local m
  for m in "${MODULES[@]}"; do
    printf '  %-16s %s\n' "$m" "${MODULE_DESC[$m]}"
  done
}

is_selected() {
  local m
  for m in "${SELECTED[@]:-}"; do [[ "$m" == "$1" ]] && return 0; done
  return 1
}

# any_selected <comma-list> — true if at least one listed module is selected.
any_selected() {
  local IFS=, n
  for n in $1; do is_selected "$n" && return 0; done
  return 1
}

is_module() {
  local m
  for m in "${MODULES[@]}"; do [[ "$m" == "$1" ]] && return 0; done
  return 1
}

# filter_file <file> — strip ALL marker lines; strip the content of blocks none of whose
# owner modules is selected. Line-based, no nesting (a begin inside a skipped block is a bug
# in the markers, not supported).
filter_file() {
  local file="$1" tmp skip=0 line
  tmp="$(mktemp)"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ $MARKER_RE ]]; then
      case "${BASH_REMATCH[3]}" in
        begin) if any_selected "${BASH_REMATCH[2]}"; then skip=0; else skip=1; fi ;;
        end)   skip=0 ;;
      esac
      continue
    fi
    ((skip)) && continue
    printf '%s\n' "$line" >>"$tmp"
  done <"$file"
  mv "$tmp" "$file"
}

# derive_repo_slug — fill REPO_SLUG from a github.com 'origin' remote, if one exists. Only
# GitHub remotes qualify: the badge is a GitHub Actions badge and means nothing elsewhere.
derive_repo_slug() {
  local url slug
  url="$(git -C "$ROOT" remote get-url origin 2>/dev/null)" || return 0
  [[ "$url" == *github.com[:/]* ]] || return 0
  slug="${url#*github.com}"; slug="${slug#[:/]}"
  slug="${slug%/}"; slug="${slug%.git}"
  [[ "$slug" =~ $REPO_SLUG_RE ]] && REPO_SLUG="$slug"
  return 0
}

# apply_repo_slug — repoint the README CI badge to REPO_SLUG, or remove it when no slug is
# known. The instruction comment above the badge goes in both cases; when the badge itself is
# removed, the blank line that followed it goes too, so no double blank is left behind.
apply_repo_slug() {
  local readme="$ROOT/README.md" tmp
  if [[ -n "$REPO_SLUG" ]]; then
    sed -i -e "s|$REPO_PLACEHOLDER|$REPO_SLUG|g" -e "/$BADGE_COMMENT_RE/d" "$readme"
    badge_result="repointed to $REPO_SLUG"
  else
    tmp="$(mktemp)"
    awk -v comment_re="$BADGE_COMMENT_RE" '
      $0 ~ comment_re                { next }
      /badge\.svg/                   { skipblank = 1; next }
      skipblank && /^[[:space:]]*$/  { skipblank = 0; next }
      { skipblank = 0; print }
    ' "$readme" >"$tmp"
    mv "$tmp" "$readme"
    badge_result="removed (no --repo and no github.com origin remote)"
  fi
}

# accept_adr <number> — flip the seed ADR and its index row from proposed to accepted.
accept_adr() {
  local nr="$1" file
  file="$(find "$ROOT/docs/adr" -maxdepth 1 -name "$nr-*.md" | head -n1)"
  [[ -n "$file" ]] || { echo "ERROR: seed ADR $nr not found." >&2; exit 1; }
  grep -q '^- \*\*Status:\*\* 🟡 proposed$' "$file" \
    || { echo "ERROR: $file does not carry status '🟡 proposed' — template drift." >&2; exit 1; }
  sed -i 's/^- \*\*Status:\*\* 🟡 proposed$/- **Status:** 🟢 accepted/' "$file"
  sed -i "/^| \\[$nr\\]/s/🟡 proposed/🟢 accepted/" "$ROOT/$ADR_INDEX"
  grep -q "^| \\[$nr\\].*🟢 accepted" "$ROOT/$ADR_INDEX" \
    || { echo "ERROR: could not mark ADR $nr accepted in the index." >&2; exit 1; }
}

# drop_adr <number> — delete the seed ADR file and its index row.
drop_adr() {
  local nr="$1"
  rm -f "$ROOT/docs/adr/$nr"-*.md
  sed -i "/^| \\[$nr\\]/d" "$ROOT/$ADR_INDEX"
}

# renumber_adrs — compact the surviving ADRs to a gapless 0001..N, preserving their order, and
# rewrite every reference to them. This is the one sanctioned renumbering (docs/adr/README.md):
# nothing outside the tree references these numbers yet. A single ascending pass suffices, because
#   - numbers only ever shrink, so each target number is already free (no temporary-name dance),
#   - a later source number always exceeds every earlier target, so no rewrite chains into another.
# Only the two canonical reference forms are rewritten — 'ADR-NNNN' and 'NNNN-<slug>.md', plus the
# '| [NNNN](' label of the index row. Bare numbers in prose are never touched, which is why no
# document may cite an ADR number in bare form (ADR-0003, writing constraints). Slugs are
# [a-z0-9-]+ and therefore safe inside the patterns below.
renumber_adrs() {
  local files=() base old new slug target n=0
  while IFS= read -r base; do files+=("$base"); done \
    < <(find "$ROOT/docs/adr" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' -printf '%f\n' | sort)

  for base in "${files[@]}"; do
    n=$((n + 1))
    new="$(printf '%04d' "$n")"
    old="${base%%-*}"
    slug="${base#*-}"; slug="${slug%.md}"
    NEW_NR["$old"]="$new"
    [[ "$old" == "$new" ]] && continue

    # --exclude=$SELF: never rewrite the script bash is currently reading.
    while IFS= read -r target; do
      sed -i -e "s/ADR-$old/ADR-$new/g" -e "s/$old-$slug\\.md/$new-$slug\\.md/g" "$target"
    done < <(grep -rlI --exclude-dir=.git --exclude="$SELF" \
               -e "ADR-$old" -e "$old-$slug\\.md" "$ROOT")
    sed -i "s/^| \\[$old\\](/| [$new](/" "$ROOT/$ADR_INDEX"

    mv "$ROOT/docs/adr/$base" "$ROOT/docs/adr/$new-$slug.md"
    renumbered+=("$base -> $new-$slug.md")
  done
}

# ---------------------------------------------------------------------------------- selection --
parse_selection() {
  local m answer modules_arg="" modules_given=0
  while (($# > 0)); do
    case "$1" in
      --list) echo "Available policy modules:"; list_modules; exit 0 ;;
      --modules)
        modules_arg="${2:-}"
        [[ -n "$modules_arg" ]] || { echo "ERROR: --modules needs a value." >&2; usage >&2; exit 2; }
        modules_given=1; shift 2 ;;
      --repo)
        REPO_SLUG="${2:-}"
        [[ "$REPO_SLUG" =~ $REPO_SLUG_RE ]] \
          || { echo "ERROR: --repo needs a value of the form 'owner/name'." >&2; usage >&2; exit 2; }
        shift 2 ;;
      *) echo "ERROR: unknown argument '${1}'." >&2; usage >&2; exit 2 ;;
    esac
  done

  if ((modules_given)); then
    case "$modules_arg" in
      all)  SELECTED=("${MODULES[@]}") ;;
      none) SELECTED=() ;;
      *)
        local IFS=,
        for m in $modules_arg; do
          is_module "$m" || { echo "ERROR: unknown module '$m'. Valid:" >&2; list_modules >&2; exit 2; }
          is_selected "$m" || SELECTED+=("$m")
        done ;;
    esac
    return 0
  fi

  if [[ -t 0 ]]; then
    echo "Choose the policy modules for this project:"
    for m in "${MODULES[@]}"; do
      read -rp "  adopt '$m' — ${MODULE_DESC[$m]}? [y/N] " answer
      [[ "$answer" =~ ^[Yy] ]] && SELECTED+=("$m")
    done
    return 0
  fi
  echo "ERROR: no terminal — pass --modules explicitly." >&2; usage >&2; exit 2
}

# resolve_repo_slug — settle the badge slug before anything is mutated: --repo wins (already in
# REPO_SLUG), else a github.com origin remote, else — interactively — ask, mirroring the module
# prompts. Still empty afterwards means: remove the badge.
resolve_repo_slug() {
  local answer
  [[ -n "$REPO_SLUG" ]] && return 0
  derive_repo_slug
  if [[ -z "$REPO_SLUG" && -t 0 ]]; then
    read -rp "Repository 'owner/name' for the CI badge (empty removes the badge): " answer
    if [[ -n "$answer" ]]; then
      [[ "$answer" =~ $REPO_SLUG_RE ]] \
        || { echo "ERROR: '$answer' is not of the form 'owner/name'." >&2; exit 2; }
      REPO_SLUG="$answer"
    fi
  fi
  return 0
}

# --------------------------------------------------------------------------------------- main --
main() {
  parse_selection "$@"

  # Guard: refuse to run twice (markers gone = already initialized).
  grep -q 'module:init begin' "$ROOT/AGENTS.md" 2>/dev/null \
    || { echo "ERROR: already initialized (no init markers in AGENTS.md)." >&2; exit 1; }

  # Guard against template drift: every manifest file must exist before we mutate anything,
  # and the badge placeholder must still be where the rewrite expects it.
  local m f
  for m in "${MODULES[@]}"; do
    for f in ${MODULE_FILES[$m]}; do
      [[ -f "$ROOT/$f" ]] || { echo "ERROR: manifest file missing: $f" >&2; exit 1; }
    done
  done
  grep -qF "$REPO_PLACEHOLDER" "$ROOT/README.md" \
    || { echo "ERROR: README.md does not carry the badge placeholder '$REPO_PLACEHOLDER' — template drift." >&2; exit 1; }

  resolve_repo_slug

  # 1. Delete files owned by deselected modules, and their seed ADRs.
  for m in "${MODULES[@]}"; do
    if is_selected "$m"; then
      kept+=("$m")
    else
      for f in ${MODULE_FILES[$m]}; do rm -f "$ROOT/$f"; removed+=("$f"); done
      drop_adr "${MODULE_ADR[$m]}"
      removed+=("docs/adr/${MODULE_ADR[$m]}-*.md")
    fi
  done

  # 2. Bootstrap tooling is always removed — including the ADR that decides the mechanism, which
  #    documents nothing that survives in an initialized project (ADR-0003).
  for f in "${INIT_FILES[@]}"; do rm -f "$ROOT/$f"; removed+=("$f"); done
  drop_adr "$INIT_ADR"
  removed+=("docs/adr/$INIT_ADR-*.md")

  # 3. Filter every surviving marked file (strips all markers; drops deselected blocks —
  #    including every 'init' block, since 'init' is never a selectable module).
  for f in "${MARKED_FILES[@]}"; do
    [[ -f "$ROOT/$f" ]] && filter_file "$ROOT/$f"
  done

  # 4. Repoint the CI badge to the resolved slug, or remove it when none is known (ADR-0003).
  apply_repo_slug

  # 5. Accept the chosen seed ADRs — the human's selection is the acceptance (ADR-0003).
  for m in "${SELECTED[@]:-}"; do
    [[ -n "$m" ]] && accept_adr "${MODULE_ADR[$m]}"
  done

  # 6. Close the gaps the deletions left: the surviving ADRs become a gapless 0001..N. From here
  #    on their numbers are permanent — this is the last moment at which nothing references them.
  renumber_adrs

  # 7. Remove this script itself (its absence signals "initialized").
  rm -- "$ROOT/scripts/init-template.sh"
  removed+=("scripts/init-template.sh")

  # 8. Verify the initialized tree.
  echo "Verifying the initialized tree..."
  bash "$ROOT/scripts/check-docs.sh" || exit 1
  if is_selected supply-chain; then bash "$ROOT/scripts/check-workflow-pins.sh" || exit 1; fi
  if is_selected git-conventions && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    bash "$ROOT/scripts/check-git-conventions.sh" || exit 1
  fi
  if grep -rInE "$MARKER_RE" "$ROOT" --exclude-dir=.git >/dev/null 2>&1; then
    echo "ERROR: leftover module markers found:" >&2
    grep -rInE "$MARKER_RE" "$ROOT" --exclude-dir=.git >&2
    exit 1
  fi
  if grep -rInF "$REPO_PLACEHOLDER" "$ROOT" --exclude-dir=.git >/dev/null 2>&1; then
    echo "ERROR: leftover badge placeholder '$REPO_PLACEHOLDER' found:" >&2
    grep -rInF "$REPO_PLACEHOLDER" "$ROOT" --exclude-dir=.git >&2
    exit 1
  fi

  # 9. Summary.
  echo
  echo "Template initialized."
  if ((${#kept[@]} > 0)); then
    local nr
    for m in "${kept[@]}"; do
      nr="${MODULE_ADR[$m]}"
      echo "  kept:    $m (seed ADR ${NEW_NR[$nr]:-$nr}, accepted)"
    done
  else
    echo "  kept:    no optional modules"
  fi
  echo "  badge:   $badge_result"
  for f in "${removed[@]}"; do echo "  removed: $f"; done
  for f in "${renumbered[@]}"; do echo "  renumbered: docs/adr/$f"; done
  echo
  echo "Review with 'git status' / 'git diff', then commit the initialization."
}

main "$@"
