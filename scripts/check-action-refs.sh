#!/usr/bin/env bash
#
# GitHub Actions reference checks for this template.
#
# Enforces — as CI, not just convention — the action version policy from AGENTS.md §7 and
# ADR-0005: every action used in .github/workflows/ is referenced by its major version tag
# (e.g. 'actions/checkout@v7'), so workflows always run the newest release of that major.
# Commit SHAs and branches are rejected: a SHA never receives updates, and a branch is not a
# release at all.
#
# For every non-comment 'uses:' line in .github/workflows/*.yml|*.yaml:
#   - './…' (local actions): exempt — they ship with the repository itself.
#   - 'docker://IMAGE': must carry an explicit ':<tag>'.
#   - anything else: the ref must be a major version tag, e.g.  uses: actions/checkout@v7
#
# Pure bash + coreutils/grep/sed only — present in the Dev Container base image.
#
# Usage:
#     scripts/check-action-refs.sh        (or: bash scripts/check-action-refs.sh)
# Exit code 0 when all checks pass, 1 otherwise.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW_DIR="$ROOT/.github/workflows"

errors=()
add_error() { errors+=("$1"); }

check_action_refs() {
  local f rel lineno line uses ref img
  while IFS= read -r f; do
    rel="${f#"$ROOT"/}"
    while IFS=: read -r lineno line; do
      # Skip commented lines (first non-blank character is '#') — e.g. the inert ci.yml skeleton.
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      # Extract the value after 'uses:', stripping quotes and any trailing comment.
      uses="$(printf '%s' "$line" | sed -E "s/^[[:space:]-]*uses:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^[\"']//; s/[\"'][[:space:]]*$//")"
      case "$uses" in
        ./*)
          continue ;;
        docker://*)
          img="${uses#docker://}"
          if [[ "${img##*/}" != *:* ]]; then
            add_error "$rel:$lineno: docker image carries no explicit ':<tag>': $uses"
          fi ;;
        *)
          ref="${uses##*@}"
          if [[ "$uses" != *@* ]]; then
            add_error "$rel:$lineno: action carries no ref — use its major version tag (e.g. '@v7'): $uses"
          elif [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
            add_error "$rel:$lineno: action is pinned to a commit SHA — use its major version tag (e.g. '@v7') so the newest release is picked up automatically: $uses"
          elif [[ ! "$ref" =~ ^v[0-9]+$ ]]; then
            add_error "$rel:$lineno: action ref is not a major version tag (expected '@v<major>', e.g. '@v7'): $uses"
          fi ;;
      esac
    done < <(grep -nE '^[[:space:]#-]*uses:' "$f")
  done < <(find "$WORKFLOW_DIR" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
}

check_action_refs

if ((${#errors[@]} > 0)); then
  echo "Action reference checks FAILED:"
  echo
  for e in "${errors[@]}"; do echo "  - $e"; done
  echo
  echo "${#errors[@]} problem(s) found."
  exit 1
fi

echo "Action reference checks passed."
exit 0
