#!/usr/bin/env bash
#
# Template bootstrap (ADR-0003): run once, at the first interaction in a project created from
# this template. Keeps the policy modules chosen for this project, removes every file and every
# marked text block belonging to the modules that were not chosen, marks the chosen seed ADRs
# accepted (the human's selection is the acceptance), sets the project identity — license and
# copyright holder in LICENSE, the chosen GitHub Actions badges in the README repointed to this
# project's repository (or removed when none is known) — renumbers the surviving ADRs to a
# gapless 0001..N, deletes itself, and verifies the result with the remaining check scripts.
#
# Usage: scripts/init-template.sh --help   (usage() below is the single source).
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
  [supply-chain]="Actions on floating major version tags, secrets rules, Dependabot major updates (CI-checked)"
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
  [supply-chain]="scripts/check-action-refs.sh .github/dependabot.yml"
  [release]="CHANGELOG.md"
  [conformance]="docs/CONFORMANCE.md"
)
INIT_FILES=(scripts/test-init-template.sh)   # bootstrap tooling, always removed (self is last);
                                   # the license texts under scripts/licenses/ go in step 4,
                                   # after apply_license has read the chosen one
INIT_ADR=0003                      # the ADR describing this mechanism — removed with the mechanism
MARKED_FILES=(
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md CHANGELOG.md
  docs/adr/README.md
  .github/workflows/checks.yml
  .github/workflows/ci.yml
  .github/dependabot.yml
)
ADR_INDEX="docs/adr/README.md"

# Repository identity (ADR-0003): the placeholder appears only in the README badge lines and the
# instruction comment above them — that restriction is what makes the rewrite below total.
REPO_PLACEHOLDER='hivevm/nuc'
REPO_SLUG_RE='^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$'
REPO_SLUG=''                       # resolved chain: --repo, else origin remote, else empty
BADGE_COMMENT_RE='^<!-- The bootstrap script'
badge_result=''

# GitHub Actions badges (ADR-0003): one per workflow, selectable like the modules. A badge line
# in the README survives only when its workflow is selected AND a repository slug is known.
BADGE_KEYS=(checks ci)
declare -A BADGE_DESC=(
  [checks]="Checks workflow (repository consistency checks; runs from the first commit)"
  [ci]="CI workflow (build/test/lint; inert until you activate it — badge shows 'no status' until then)"
)
declare -A BADGE_DEFAULT=([checks]=y [ci]=n)
SELECTED_BADGES=(checks)           # default when --badges is not given and no terminal asks

# Project identity (ADR-0003): copyright holder and license. The LICENSE copyright line with the
# holder 'Maintainer' is the sanctioned license placeholder; it appears nowhere else.
LICENSE_HOLDER_RE='^Copyright \(c\) [0-9]{4} Maintainer$'
LICENSES=(mit apache-2.0 none)
APACHE_TEXT='scripts/licenses/Apache-2.0.txt'
MAINTAINER=''                      # resolved chain: --maintainer, else asked, else left as-is
LICENSE_CHOICE=mit
license_result=''
BADGES_GIVEN=0                     # 1 when --badges was passed (skips the interactive question)
LICENSE_GIVEN=0                    # 1 when --license was passed (skips the interactive question)
INTERACTIVE=0                      # 1 only when no --modules was given on a terminal: a flag-driven
                                   # run never prompts — missing values fall back to the defaults

# scripts/test-init-template.sh re-states this regex — deliberately, as an independent oracle
# against leftover markers. When changing it, update both.
MARKER_RE='^[[:space:]>]*(<!--|#)[[:space:]]*module:([a-z][a-z,-]*)[[:space:]]+(begin|end)([[:space:]]*-->)?[[:space:]]*$'

SELECTED=()
removed=()
dropped_adrs=()                    # "NNNN-slug" of every deleted seed/bootstrap ADR
kept=()
renumbered=()
declare -A NEW_NR=()               # old ADR number -> number after renumbering

# ------------------------------------------------------------------------------------ helpers --
usage() {
  cat <<'EOF'
Usage:
    scripts/init-template.sh --modules <name>[,<name>...] | all | none
                             [--repo <owner/name>] [--maintainer <holder>]
                             [--license mit|apache-2.0|none] [--badges <name>[,<name>...] | all | none]
    scripts/init-template.sh --list | --help
Without --modules on a terminal, everything is asked interactively: modules, repository slug,
badges, copyright holder, license. With --modules the run is fully scripted and never prompts —
values not passed as flags fall back to the defaults: --license mit, --badges checks, the badge
slug derived from a github.com 'origin' remote (all badges removed without one), and the
copyright holder left as 'Maintainer'.

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

list_badges() {
  local b
  for b in "${BADGE_KEYS[@]}"; do
    printf '  %-16s %s\n' "$b" "${BADGE_DESC[$b]}"
  done
}

is_badge() {
  local b
  for b in "${BADGE_KEYS[@]}"; do [[ "$b" == "$1" ]] && return 0; done
  return 1
}

badge_selected() {
  local b
  for b in "${SELECTED_BADGES[@]:-}"; do [[ "$b" == "$1" ]] && return 0; done
  return 1
}

is_license() {
  local l
  for l in "${LICENSES[@]}"; do [[ "$l" == "$1" ]] && return 0; done
  return 1
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
  # Write through the existing inode (mktemp files are 0600 — a mv would lose the file's mode).
  cat "$tmp" >"$file" && rm -f "$tmp"
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

# apply_badges — keep each README badge line only when its workflow badge was selected and a
# repository slug is known, repointed to REPO_SLUG; remove the rest. The instruction comment
# above the badges goes in every case; when no badge survives, the blank line that followed the
# badge block goes too, so no double blank is left behind.
apply_badges() {
  local readme="$ROOT/README.md" tmp keep="," b kept_badges=()
  if [[ -n "$REPO_SLUG" ]]; then
    for b in "${SELECTED_BADGES[@]:-}"; do [[ -n "$b" ]] && { keep="$keep$b,"; kept_badges+=("$b"); }; done
  fi
  tmp="$(mktemp)"
  # A badge line carries 'workflows/<name>.yml/badge.svg'; <name> decides its fate. A line with
  # 'badge.svg' but not that pattern is not a badge line and passes through unchanged.
  awk -v comment_re="$BADGE_COMMENT_RE" -v keep="$keep" '
    $0 ~ comment_re { next }
    /badge\.svg/ {
      if (match($0, /workflows\/[A-Za-z0-9_-]+\.yml\/badge\.svg/)) {
        wf = substr($0, RSTART, RLENGTH)
        sub(/^workflows\//, "", wf)
        sub(/\.yml\/badge\.svg$/, "", wf)
        if (index(keep, "," wf ",")) { anykept = 1; skipblank = 0; print; next }
        skipblank = 1; next
      }
    }
    skipblank && !anykept && /^[[:space:]]*$/ { skipblank = 0; next }
    { skipblank = 0; print }
  ' "$readme" >"$tmp"
  # Write through the existing inode (mktemp files are 0600 — a mv would lose the file's mode).
  cat "$tmp" >"$readme" && rm -f "$tmp"
  if ((${#kept_badges[@]} > 0)); then
    sed -i "s|$REPO_PLACEHOLDER|$REPO_SLUG|g" "$readme"
    badge_result="$(IFS=,; echo "${kept_badges[*]}") -> $REPO_SLUG"
  elif [[ -n "$REPO_SLUG" ]]; then
    badge_result="removed (none selected)"
  else
    badge_result="removed (no --repo and no github.com origin remote)"
  fi
}

# apply_license — set the chosen license and copyright holder. 'mit' keeps the shipped LICENSE
# and fills the copyright line; 'apache-2.0' replaces it with the Apache text and fills the
# appendix fields; 'none' removes LICENSE and rewrites the README section to all-rights-reserved.
# With no holder known, the placeholder fields stay for the human to edit — reported in the summary.
apply_license() {
  local license="$ROOT/LICENSE" readme="$ROOT/README.md" line content year holder_note=''
  year="$(date +%Y)"
  [[ -n "$MAINTAINER" ]] || holder_note=" (no copyright holder given — edit LICENSE)"
  case "$LICENSE_CHOICE" in
    mit)
      if [[ -n "$MAINTAINER" ]]; then
        # Bash replacement, not sed: the holder is free text and must not be a pattern.
        line="$(grep -E -m1 "$LICENSE_HOLDER_RE" "$license")"
        content="$(<"$license")"
        printf '%s\n' "${content/"$line"/Copyright (c) $year $MAINTAINER}" >"$license"
      fi
      license_result="MIT$holder_note"
      ;;
    apache-2.0)
      content="$(<"$ROOT/$APACHE_TEXT")"
      content="${content//"[yyyy]"/$year}"
      [[ -n "$MAINTAINER" ]] && content="${content//"[name of copyright owner]"/$MAINTAINER}"
      printf '%s\n' "$content" >"$license"
      sed -i 's/Released under the MIT License/Released under the Apache License 2.0/' "$readme"
      license_result="Apache-2.0$holder_note"
      ;;
    none)
      rm -f "$license"
      sed -i '/^Released under the MIT License/c\All rights reserved — this project is not offered under an open-source license.' "$readme"
      license_result="none (LICENSE removed, all rights reserved)"
      ;;
  esac
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

# drop_adr <number> — delete the seed ADR file and its index row, recording what was deleted
# (check_dropped_refs verifies no surviving file still references it).
drop_adr() {
  local nr="$1" f
  for f in "$ROOT/docs/adr/$nr"-*.md; do
    [[ -e "$f" ]] || continue
    dropped_adrs+=("$(basename "$f" .md)")
    rm -f "$f"
  done
  sed -i "/^| \\[$nr\\]/d" "$ROOT/$ADR_INDEX"
}

# check_dropped_refs — refuse to renumber while any surviving file still references a deleted
# ADR: after renumbering the dangling number would name a different decision and pass every
# check (the number resolves). Runs after filtering, so marker blocks that legitimately cited a
# deselected ADR are already gone — a hit is a genuine violation of the writing constraint.
check_dropped_refs() {
  local entry nr slug hits
  for entry in "${dropped_adrs[@]:-}"; do
    [[ -n "$entry" ]] || continue
    nr="${entry%%-*}"; slug="${entry#*-}"
    # --exclude=$SELF: this script cites its own ADR and is deleted only in a later step.
    if hits="$(grep -rInF --exclude-dir=.git --exclude="$SELF" \
                 -e "ADR-$nr" -e "$nr-$slug.md" "$ROOT" 2>/dev/null)"; then
      echo "ERROR: the tree references a deleted ADR ($entry):" >&2
      printf '%s\n' "$hits" >&2
      echo "A file surviving this selection must not cite a removable ADR (writing constraint)." >&2
      echo "Recover with 'git reset --hard', fix the reference, and rerun." >&2
      exit 1
    fi
  done
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
  local m b answer modules_arg="" modules_given=0 badges_arg=""
  while (($# > 0)); do
    case "$1" in
      --list)
        echo "Available policy modules:"; list_modules
        echo "Available GitHub Actions badges:"; list_badges
        echo "Available licenses: ${LICENSES[*]}"
        exit 0 ;;
      -h|--help)
        usage
        exit 0 ;;
      --modules)
        modules_arg="${2:-}"
        [[ -n "$modules_arg" ]] || { echo "ERROR: --modules needs a value." >&2; usage >&2; exit 2; }
        modules_given=1; shift 2 ;;
      --repo)
        REPO_SLUG="${2:-}"
        [[ "$REPO_SLUG" =~ $REPO_SLUG_RE ]] \
          || { echo "ERROR: --repo needs a value of the form 'owner/name'." >&2; usage >&2; exit 2; }
        shift 2 ;;
      --maintainer)
        MAINTAINER="${2:-}"
        [[ -n "$MAINTAINER" ]] || { echo "ERROR: --maintainer needs a value." >&2; usage >&2; exit 2; }
        shift 2 ;;
      --license)
        LICENSE_CHOICE="${2:-}"
        is_license "$LICENSE_CHOICE" \
          || { echo "ERROR: --license must be one of: ${LICENSES[*]}." >&2; usage >&2; exit 2; }
        LICENSE_GIVEN=1; shift 2 ;;
      --badges)
        badges_arg="${2:-}"
        [[ -n "$badges_arg" ]] || { echo "ERROR: --badges needs a value." >&2; usage >&2; exit 2; }
        BADGES_GIVEN=1; shift 2 ;;
      *) echo "ERROR: unknown argument '${1}'." >&2; usage >&2; exit 2 ;;
    esac
  done

  if ((BADGES_GIVEN)); then
    case "$badges_arg" in
      all)  SELECTED_BADGES=("${BADGE_KEYS[@]}") ;;
      none) SELECTED_BADGES=() ;;
      *)
        SELECTED_BADGES=()
        local IFS=,
        for b in $badges_arg; do
          is_badge "$b" || { echo "ERROR: unknown badge '$b'. Valid:" >&2; list_badges >&2; exit 2; }
          badge_selected "$b" || SELECTED_BADGES+=("$b")
        done ;;
    esac
  fi

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
    INTERACTIVE=1
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
# REPO_SLUG), else a github.com origin remote, else — on interactive runs — ask, mirroring the
# module prompts. Still empty afterwards means: remove all badges.
resolve_repo_slug() {
  local answer
  [[ -n "$REPO_SLUG" ]] && return 0
  derive_repo_slug
  if [[ -z "$REPO_SLUG" ]] && ((INTERACTIVE)); then
    read -rp "Repository 'owner/name' for the GitHub Actions badges (empty removes them): " answer
    if [[ -n "$answer" ]]; then
      [[ "$answer" =~ $REPO_SLUG_RE ]] \
        || { echo "ERROR: '$answer' is not of the form 'owner/name'." >&2; exit 2; }
      REPO_SLUG="$answer"
    fi
  fi
  return 0
}

# resolve_badges — on an interactive run with a slug known (and no --badges), ask per badge,
# mirroring the module prompts; each badge carries its own default. Slug-less runs skip the
# questions: every badge is removed regardless of selection.
resolve_badges() {
  local b answer suffix
  ((BADGES_GIVEN)) && return 0       # --badges given — nothing to ask
  ((INTERACTIVE)) || return 0
  [[ -n "$REPO_SLUG" ]] || return 0
  echo "Choose the GitHub Actions badges for the README:"
  SELECTED_BADGES=()
  for b in "${BADGE_KEYS[@]}"; do
    [[ "${BADGE_DEFAULT[$b]}" == y ]] && suffix="[Y/n]" || suffix="[y/N]"
    read -rp "  keep badge '$b' — ${BADGE_DESC[$b]}? $suffix " answer
    [[ -z "$answer" ]] && answer="${BADGE_DEFAULT[$b]}"
    [[ "$answer" =~ ^[Yy] ]] && SELECTED_BADGES+=("$b")
  done
  return 0
}

# resolve_project_identity — copyright holder and license: flags win (already set), else — on
# interactive runs — ask; else the defaults stand (MIT, holder left for the human to edit).
resolve_project_identity() {
  local answer
  ((INTERACTIVE)) || return 0
  if [[ -z "$MAINTAINER" ]]; then
    read -rp "Copyright holder / maintainer for the LICENSE (empty keeps the placeholder): " answer
    [[ -n "$answer" ]] && MAINTAINER="$answer"
  fi
  if ((!LICENSE_GIVEN)); then
    read -rp "License [${LICENSES[*]}] (default: mit): " answer
    if [[ -n "$answer" ]]; then
      is_license "$answer" || { echo "ERROR: license must be one of: ${LICENSES[*]}." >&2; exit 2; }
      LICENSE_CHOICE="$answer"
    fi
  fi
  return 0
}

# confirm_plan — interactive runs only: state what will be kept and deleted and require an
# explicit yes before the tree is mutated. Flag-driven runs (the agent path) never see this —
# their caller already made the selection deliberately. Declining exits 1: nothing was changed.
confirm_plan() {
  ((INTERACTIVE)) || return 0
  local m answer
  echo
  echo "About to initialize:"
  echo "  modules: ${SELECTED[*]:-none}"
  for m in "${MODULES[@]}"; do
    is_selected "$m" || echo "  delete:  ${MODULE_FILES[$m]} + seed ADR ${MODULE_ADR[$m]}"
  done
  echo "  badges:  ${SELECTED_BADGES[*]:-none}${REPO_SLUG:+ -> $REPO_SLUG}"
  echo "  license: $LICENSE_CHOICE${MAINTAINER:+, holder: $MAINTAINER}"
  echo "Also deleted: the bootstrap tooling (this script, its tests, its ADR, scripts/licenses/);"
  echo "the surviving ADRs are renumbered to a gapless 0001..N."
  read -rp "Proceed? [y/N] " answer
  [[ "$answer" =~ ^[Yy] ]] || { echo "Aborted — nothing was changed."; exit 1; }
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
  local b
  for b in "${BADGE_KEYS[@]}"; do
    grep -qF "workflows/$b.yml/badge.svg" "$ROOT/README.md" \
      || { echo "ERROR: README.md carries no badge line for workflow '$b' — template drift." >&2; exit 1; }
  done
  grep -qE "$LICENSE_HOLDER_RE" "$ROOT/LICENSE" \
    || { echo "ERROR: LICENSE does not carry the copyright placeholder line — template drift." >&2; exit 1; }
  grep -q '^Released under the MIT License' "$ROOT/README.md" \
    || { echo "ERROR: README.md does not carry the 'Released under the MIT License' line — template drift." >&2; exit 1; }
  [[ -f "$ROOT/$APACHE_TEXT" ]] \
    || { echo "ERROR: manifest file missing: $APACHE_TEXT" >&2; exit 1; }

  resolve_repo_slug
  resolve_badges
  resolve_project_identity
  confirm_plan

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

  # 4. Project identity: keep the chosen badges repointed to the resolved slug (or remove them
  #    when none is known), and set license and copyright holder (ADR-0003). The shipped license
  #    texts are bootstrap tooling and go once the chosen one has been applied.
  apply_badges
  apply_license
  rm -rf "$ROOT/scripts/licenses"
  removed+=("$APACHE_TEXT")

  # 5. Accept the chosen seed ADRs — the human's selection is the acceptance (ADR-0003).
  for m in "${SELECTED[@]:-}"; do
    [[ -n "$m" ]] && accept_adr "${MODULE_ADR[$m]}"
  done

  # 6. No surviving file may still reference a deleted ADR — renumbering would silently repoint
  #    such a reference at a different decision.
  check_dropped_refs

  # 7. Close the gaps the deletions left: the surviving ADRs become a gapless 0001..N. From here
  #    on their numbers are permanent — this is the last moment at which nothing references them.
  renumber_adrs

  # 8. Remove this script itself (its absence signals "initialized").
  rm -- "$ROOT/scripts/init-template.sh"
  removed+=("scripts/init-template.sh")

  # 9. Verify the initialized tree.
  echo "Verifying the initialized tree..."
  bash "$ROOT/scripts/check-docs.sh" || exit 1
  bash "$ROOT/scripts/check-shell.sh" || exit 1
  if is_selected supply-chain; then bash "$ROOT/scripts/check-action-refs.sh" || exit 1; fi
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
  if [[ "$LICENSE_CHOICE" == none ]] && grep -rInF '](LICENSE)' "$ROOT" --exclude-dir=.git >/dev/null 2>&1; then
    echo "ERROR: leftover links to the removed LICENSE file:" >&2
    grep -rInF '](LICENSE)' "$ROOT" --exclude-dir=.git >&2
    exit 1
  fi

  # 10. Summary.
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
  echo "  badges:  $badge_result"
  echo "  license: $license_result"
  for f in "${removed[@]}"; do echo "  removed: $f"; done
  for f in "${renumbered[@]}"; do echo "  renumbered: docs/adr/$f"; done
  echo
  echo "Review with 'git status' / 'git diff', then commit the initialization."
}

main "$@"
