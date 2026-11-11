# shellcheck shell=bash
# Shared by the self-tests under scripts/ (scripts/test-*.sh), sourced as their first act: the
# repository root, a temporary directory for the fixtures, the counters, the guard on a fixture's
# path, one counted assertion, and the summary.
#
# The checks a self-test exercises build fixture repositories under $work. Git hands a hook, a
# linked worktree, and 'git -c' variables that bind every git command to one repository;
# inherited, a fixture's commands would act on this one and could push from it. They are unset
# here, so a self-test run from anywhere is as safe as one run by hand (see .githooks/pre-push).
#
# Usage, from scripts/test-<name>.sh:
#     # shellcheck source-path=SCRIPTDIR source=lib/selftest.sh
#     source "$(dirname "${BASH_SOURCE[0]}")/lib/selftest.sh"
#     ...
#     summary "<Name> self-test"

# shellcheck source=scripts/lib/bash.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash.sh"

# shellcheck disable=SC2034 # ROOT is the sourcing self-test's
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC2046 # one variable name per word
unset $(git rev-parse --local-env-vars)

# A fixture repository has no .gitattributes of its own. Git for Windows sets core.autocrlf=true,
# which checks a fixture's files out with CRLF and prints a warning naming each file; a check
# then reads a status word with a carriage return, and a needle meets a file name in a warning.
# The fixtures are written with LF and read as they are written. MSYS copies on 'ln -s' unless
# told to make a native link, and a fixture's pointer under .claude/skills/ must be a symlink.
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.autocrlf GIT_CONFIG_VALUE_0=false
[[ " ${MSYS-} " == *" winsymlinks:nativestrict "* ]] || export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failed=0
passed=0

# fixture <dir> — refuse a path that is no fixture repository under $work: 'git -C ""' acts on
# this repository, and a path outside $work may be this repository or another one.
fixture() {
  [[ -n "${1:-}" && "$1" == "$work"/* && -d "$1/.git" ]] \
    || { echo "fixture: '${1:-}' is no fixture repository under $work" >&2; exit 1; }
}

# table_hyphens <text> — the notation of the fixture tables under scripts/fixtures/ read: a colon
# after two to five capital letters, not preceded by a letter, a digit, or '_', and before a letter
# or a digit is a hyphen.
table_hyphens() { sed -E 's/(^|[^A-Za-z0-9_])([A-Z]{2,5}):([A-Za-z0-9])/\1\2-\3/g' <<< "$1"; }

# check <name> <condition...> — count one assertion.
check() {
  local name="$1"; shift
  if "$@"; then passed=$((passed + 1)); else failed=$((failed + 1)); echo "FAIL: $name" >&2; fi
}

# summary <name> — the result line, and the exit code: 0 when every case passed, 1 otherwise.
summary() {
  if ((failed)); then
    echo "$1 FAILED ($failed of $((passed + failed)) cases)." >&2
    exit 1
  fi
  echo "$1 passed ($passed cases)."
  exit 0
}
