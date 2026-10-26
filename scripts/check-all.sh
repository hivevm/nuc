#!/usr/bin/env bash
#
# Runs every consistency check this repository enforces, in one command.
#
# AGENTS.md §5 requires these checks to pass before pushing. This script is the local equivalent
# of .github/workflows/checks.yml, in the same order; check 9 of check-docs.sh holds the two lists
# and the required status checks named in README.md together.
#
# Every check runs even after an earlier one fails, so a single run reports everything that is
# wrong instead of the first thing. The exit code is what a pre-push decision is made on.
#
# With --changed, a self-test (scripts/test-*.sh) runs only where the branch changed what it
# tests: the self-test itself or a path its '# Inputs:' header line names, changed in the working
# tree against the merge base with origin/main, else main, untracked files included. A path in
# that line is a file, or with a trailing '/' a directory. A self-test without the line or naming
# a path that does not exist runs, and so does everything on main or without such a merge base.
# The checks, the sensors, and a project's build, test, and lint always run. The hooks run this
# mode before a push and on the conclusion of a conflicted merge; CI runs every self-test, so what
# is skipped here is still decided before anything reaches main.
#
# Pure bash + coreutils/git. The individual checks state their own dependencies — the shell lint
# needs ShellCheck and skips itself with a notice where it is missing.
#
# Usage:
#     scripts/check-all.sh [--changed]        (or: bash scripts/check-all.sh [--changed])
# Exit code 0 when every check passes, 1 when any of them fails, 2 on an unknown argument.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/git.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/git.sh"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

changed_mode=0
case "${1:-}" in
  "") ;;
  --changed) changed_mode=1 ;;
  *) echo "check-all: unknown argument '$1' — usage: scripts/check-all.sh [--changed]" >&2; exit 2 ;;
esac

# The paths changed against the merge base with origin/main, else main, read once: the local
# main may lag the remote's, or a clone without the hooks may have moved it. On main, or without
# a merge base, changed mode is off and everything runs.
changed=()
if ((changed_mode)); then
  branch="$(git -C "$ROOT" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  base="$(cd "$ROOT" && main_merge_base HEAD)"
  if [[ "$branch" == "main" || -z "$base" ]]; then
    changed_mode=0
  else
    # NUL-separated: on lines, git quotes a path with a special character, which then matches no
    # input.
    mapfile -d '' -t changed < <(
      git -C "$ROOT" diff -z --name-only --no-renames "$base" --
      git -C "$ROOT" ls-files -z --others --exclude-standard
    )
  fi
fi

# needs_run <script> — whether a script runs in changed mode: it is no self-test, it names no
# inputs or one that does not exist, or a changed path is the self-test or one of its inputs.
needs_run() {
  local script="$1" line path c
  local -a inputs
  [[ "$script" == scripts/test-*.sh ]] || return 0
  line="$(grep -m1 '^# Inputs:' "$ROOT/$script")" || return 0
  read -r -a inputs <<< "${line#"# Inputs:"}"
  ((${#inputs[@]})) || return 0
  for path in "${inputs[@]}"; do
    [[ -e "$ROOT/$path" ]] || return 0
  done
  for c in "${changed[@]}"; do
    [[ "$c" == "$script" ]] && return 0
    for path in "${inputs[@]}"; do
      if [[ "$path" == */ ]]; then
        [[ "$c" == "$path"* ]] && return 0
      else
        [[ "$c" == "$path" ]] && return 0
      fi
    done
  done
  return 1
}

failed=()

# announce <label> — print the heading a check's output follows.
announce() { printf '\n==> %s\n' "$1"; }

# run <label> <script> [args...] — run one check, recording a failure without aborting the run.
run() {
  local label="$1" script="$2"
  shift 2
  announce "$label"
  if ((changed_mode)) && ! needs_run "$script"; then
    echo "skipped — neither it nor its inputs changed against main; CI runs it"
    return
  fi
  bash "$ROOT/$script" "$@" || failed+=("$label")
}

run "Documentation self-test" scripts/test-check-docs.sh
run "Documentation consistency" scripts/check-docs.sh
run "Template setup self-test" scripts/test-template-setup.sh
run "Normalize map self-test" scripts/test-normalize-remap.sh
run "Traceability self-test" scripts/test-check-traceability.sh
run "Traceability" scripts/check-traceability.sh
run "Dev Container self-test" scripts/test-check-devcontainer.sh
run "Dev Container" scripts/check-devcontainer.sh
run "Tests-kept sensor self-test" scripts/test-sensor-tests-kept.sh
run "Tests-kept sensor" scripts/sensor-tests-kept.sh
run "Binding ADRs sensor self-test" scripts/test-sensor-binding-adrs.sh
run "Binding ADRs sensor" scripts/sensor-binding-adrs.sh
run "Revision-due sensor self-test" scripts/test-sensor-revision-due.sh
run "Revision-due sensor" scripts/sensor-revision-due.sh
run "Plan frontier sensor self-test" scripts/test-sensor-plan-frontier.sh
run "Plan frontier sensor" scripts/sensor-plan-frontier.sh
run "Action references sensor self-test" scripts/test-sensor-action-refs.sh
run "Action references sensor" scripts/sensor-action-refs.sh
run "Review binding sensor self-test" scripts/test-sensor-review-binding.sh
run "Review binding sensor" scripts/sensor-review-binding.sh
# The repository settings sensor reads GitHub and runs on a human's instruction (ADR-0002); its
# self-test runs here.
run "Repository settings sensor self-test" scripts/test-sensor-repo-settings.sh
run "Check runner self-test" scripts/test-check-all.sh
run "Git hooks self-test" scripts/test-git-hooks.sh
run "Shell lint self-test" scripts/test-check-shell.sh
run "Shell lint" scripts/check-shell.sh

printf '\n'
if ((${#failed[@]})); then
  echo "FAILED:" >&2
  printf '  - %s\n' "${failed[@]}" >&2
  exit 1
fi
echo "All checks passed."
