#!/usr/bin/env bash
#
# Sensor: rules written plainly (AGENTS.md section 4, ADR-0002).
#
# Reads the rules a change touches as scripts/lib/rules.sh streams them: AGENTS.md, and the
# Decision and Enforcement of an ADR, without code spans, italics, link targets, block quotes,
# tables, fenced code, and headings. It lists each sentence over 25 words that holds an added line,
# by the line it starts on, and each soft modal verb on an added line: should, could, might,
# ideally. A paragraph or a list item ends a sentence; so do '.', '!', and '?' before a space or
# the end. It reports for the reviewer and never fails on what it counts.
#
# Pure bash + git + awk. Usage:
#     scripts/sensor-plain-rules.sh [--root <dir>] [base [head]]
# Without a base, the merge base of head with origin/main (else main) is used; CI passes the pull
# request's base, and a base of zeros counts as none. Without a head, the change is the working
# tree, untracked files included. Exit code 0, except 2 on a base or head that does not resolve
# and on a reader of the rules that fails.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/adr.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/adr.sh"
# shellcheck source-path=SCRIPTDIR source=lib/git.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/git.sh"
# shellcheck source-path=SCRIPTDIR source=lib/rules.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/rules.sh"

enter_root "Plain rules sensor" "${BASH_SOURCE[0]}" "$@"
shift "$ROOT_TAKEN"

MAX_WORDS=25
base="${1:-}" head="${2:-}" worktree=0
[[ -n "$head" ]] || { head=HEAD; worktree=1; }
[[ "$base" =~ ^0+$ ]] && base=""
[[ -n "$base" ]] || base="$(main_merge_base "$head")"
if [[ -z "$base" ]]; then
  echo "Plain rules sensor: nothing to compare — no base given and no main to compare with."
  exit 0
fi
for ref in "$base" "$head"; do
  git rev-parse --verify -q "$ref^{commit}" >/dev/null \
    || { echo "Plain rules sensor: '$ref' does not resolve to a commit." >&2; exit 2; }
done
range="$(git rev-parse --short "$base")..$(git rev-parse --short "$head")"
((worktree)) && range="${range%..*}..working tree"

if ! stream="$(rule_stream "$base" "$( ((worktree)) || echo "$head")")"; then
  unread="$(awk -F '\t' '$1 == "E" { printf "%s%s", sep, $2; sep = ", " }' <<< "$stream")"
  echo "Plain rules sensor ($range): could not read the rules${unread:+ of $unread}." >&2
  exit 2
fi
findings=()
while IFS= read -r finding; do findings+=("$finding"); done < <(
  awk -F '\t' -v max="$MAX_WORDS" '
    function flush(  i, any) {
      if (count > max) {
        any = 0
        for (i in seen) if (seen[i] == 1) any = 1
        if (any) print file ":" start ": a sentence of " count " words"
      }
      count = 0; start = 0; split("", seen)
    }
    $1 == "F" { flush(); file = $2; next }
    $1 == "P" { flush(); next }
    {
      nr = $2; text = $4
      if ($3 == 1) {
        low = tolower(text)
        n = split("should could might ideally", soft, " ")
        for (i = 1; i <= n; i++)
          if (low ~ ("(^|[^a-z])" soft[i] "([^a-z]|$)")) print file ":" nr ": the soft modal verb \"" soft[i] "\""
      }
      w = split(text, words, /[[:space:]]+/)
      for (i = 1; i <= w; i++) {
        if (words[i] !~ /[A-Za-z0-9]/) { if (count && words[i] ~ /^[.!?]/) flush(); continue }
        if (!count) start = nr
        count++; if (!(nr in seen) || $3 == 1) seen[nr] = $3
        if (words[i] ~ /[.!?][)*_"]*$/) flush()
      }
    }
    END { flush() }' <<< "$stream")

if ((${#findings[@]} == 0)); then
  echo "Plain rules sensor ($range): no long sentence and no soft modal verb on the lines the change adds to the rules."
  exit 0
fi
echo "Plain rules sensor ($range): ${#findings[@]} to read on the lines the change adds to the rules (AGENTS.md section 4):"
printf '  - %s\n' "${findings[@]}"
exit 0
