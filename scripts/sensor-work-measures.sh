#!/usr/bin/env bash
#
# Sensor: what the merged work cost in time and in rounds of review.
#
# For each of the ten newest merges of a pull request on main, it reports the branch, the whole
# hours from the branch's first commit to its merge, and the rounds of review. A claim made by a
# local branch has no commit, so the first commit of the branch, by its author date, stands for
# the claim. The rounds come from the description of the pull request, which the merge commit
# does not carry: the 'review rounds <n>' of its Measures line (.github/PULL_REQUEST_TEMPLATE.md).
# Its 'Reviewed at:' line counts none, since the review moves that one line after each round.
# More than one round means a review ran again after the fixes of its findings.
#
# With --red it also names the commits of each branch that were red alone: it runs the
# scripts/check-all.sh of every commit the merge brought in, merges aside, in a temporary
# worktree of that commit, and lists each on which it exited 1, a failed check. A commit on which
# it exited otherwise is named as not decided; one without scripts/check-all.sh, or whose
# worktree could not be made, is counted as not run. That costs a full run of the checks per
# commit, so it runs only when asked.
#
# It runs on a human's instruction, not in scripts/check-all.sh or checks.yml, since it reads
# GitHub (NUC-checks-are-bash §7). It reports and never fails. scripts/test-sensor-work-measures.sh
# runs it on fixture repositories: GH names the command that stands in for gh.
#
# Bash + coreutils + git + grep + sed, plus the GitHub CLI, authenticated through its web flow
# (NUC-main-only-via-pr §3). Usage:
#     scripts/sensor-work-measures.sh [--root <dir>] [--red]
# The root defaults to this repository. main is origin/main where it exists, else main. Exit
# code 0 always, except 2 on an unknown argument, a root that is no git repository, a missing gh,
# or no temporary directory for --red, and 130 or 143 when INT or TERM stops it.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/bash.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bash.sh"

# shellcheck source-path=SCRIPTDIR source=lib/root.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/root.sh"

NAME="Work measures sensor"
usage="scripts/sensor-work-measures.sh [--root <dir>] [--red]"
enter_root "${BASH_SOURCE[0]}" "$usage" "$@"
red=0
set -- "${ARGS[@]}"
if [[ "${1:-}" == --red ]]; then red=1; shift; fi
rest_args "${BASH_SOURCE[0]}" "$usage" 0 "$@"
last=10  # the merges read, the newest first
git -C "$ROOT" rev-parse --git-dir > /dev/null 2>&1 \
  || { echo "work measures sensor: '$ROOT' is no git repository." >&2; exit 2; }
GH="${GH:-gh}"
command -v "$GH" > /dev/null 2>&1 \
  || { echo "work measures sensor: the GitHub CLI ($GH) is not installed." >&2; exit 2; }

main=origin/main
git -C "$ROOT" rev-parse -q --verify "$main^{commit}" > /dev/null || main=main

# Every merge of a pull request on main, the newest first: '<merge> <pull request> <branch>'.
mapfile -t merges < <(git -C "$ROOT" log --first-parent --merges --format='%H %s' "$main" -- 2>/dev/null \
  | sed -nE 's/^([0-9a-f]+) Merge pull request #([0-9]+) from [^/]+\/(.+)$/\1 \2 \3/p')
if ((${#merges[@]} == 0)); then
  echo "$NAME: no merge of a pull request on main — nothing to report."
  exit 0
fi
read_n=$((last < ${#merges[@]} ? last : ${#merges[@]}))
echo "$NAME: ${#merges[@]} merge$( ((${#merges[@]} == 1)) || echo s) of a pull request on main, the newest $read_n read."

# red_alone <merge> — the commits the merge brought in, merges aside, oldest first, each run with
# its own scripts/check-all.sh in a temporary worktree. Prints a line for each on which it exited
# 1, a failed check; one for each on which it exited otherwise, which decides nothing, such as an
# old script refusing its bash; and how many it could not run, without a check-all.sh or a
# worktree. Names each commit on stderr as it starts, since a run takes minutes.
red_alone() {
  local merge="$1" c rc unchecked=0
  for c in $(git -C "$ROOT" rev-list --reverse --no-merges "$merge^1..$merge^2"); do
    if ! git -C "$ROOT" cat-file -e "$c:scripts/check-all.sh" 2>/dev/null; then
      unchecked=$((unchecked + 1))
      continue
    fi
    wt="$tmp/$c"
    if ! git -C "$ROOT" worktree add -q --detach "$wt" "$c" > /dev/null 2>&1; then
      wt=""
      unchecked=$((unchecked + 1))
      continue
    fi
    echo "work measures sensor: checking $(git -C "$ROOT" log -1 --format=%h "$c") …" >&2
    (cd "$wt" && exec bash scripts/check-all.sh > /dev/null 2>&1) &
    child=$!
    wait "$child"; rc=$?
    child=""
    if ((rc == 1)); then
      echo "    - red alone: $(git -C "$ROOT" log -1 --format='%h %s' "$c")"
    elif ((rc != 0)); then
      echo "    - not decided, its checks exited $rc: $(git -C "$ROOT" log -1 --format='%h %s' "$c")"
    fi
    git -C "$ROOT" worktree remove --force "$wt" > /dev/null 2>&1
    wt=""
  done
  ((unchecked == 0)) \
    || echo "    - not run, without scripts/check-all.sh or a worktree: $unchecked commit$( ((unchecked == 1)) || echo s)"
}
# On exit the checks still running stop, and only the worktree this run made is removed, with
# its entry: an interrupted run leaves none behind, and the worktrees of others stay as they are.
# The checks run in the background, so that a signal stops the wait for them at once.
# shellcheck disable=SC2317,SC2329 # run by the trap
drop_worktree() {
  [[ -z "${child:-}" ]] || { kill "$child" 2>/dev/null; wait "$child" 2>/dev/null; }
  [[ -z "${wt:-}" ]] || git -C "$ROOT" worktree remove --force "$wt" > /dev/null 2>&1
  rm -rf "$tmp"
}
wt="" child=""
if ((red)); then
  tmp="$(mktemp -d)" || { echo "work measures sensor: no temporary directory." >&2; exit 2; }
  trap drop_worktree EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
fi

for entry in "${merges[@]:0:read_n}"; do
  read -r merge pr branch <<< "$entry"
  merged_at="$(git -C "$ROOT" log -1 --format=%ct "$merge")"
  first_at="$(git -C "$ROOT" log --reverse --format=%at "$merge^1..$merge^2" | head -n 1)"
  hours=$(( (merged_at - ${first_at:-$merged_at}) / 3600 ))
  if body="$(cd "$ROOT" && "$GH" pr view "$pr" --json body --jq .body 2>/dev/null)"; then
    rounds="$(grep -oE 'review rounds [0-9]+' <<< "$body" | head -n 1 | grep -oE '[0-9]+$')"
    if [[ -n "$rounds" ]] && ((rounds > 0)); then reviews="$rounds round$( ((rounds == 1)) || echo s) of review"
    else reviews="rounds of review unknown"; fi
  else
    reviews="rounds of review not read"
  fi
  echo "  - #$pr $branch: $hours h from its first commit to its merge, $reviews"
  ((red == 0)) || red_alone "$merge"
done
exit 0
