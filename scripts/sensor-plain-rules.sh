#!/usr/bin/env bash
#
# Sensor: rules written plainly (AGENTS.md section 4, ADR-0002).
#
# Reads the rules a change touches as scripts/lib/rules.sh streams them: AGENTS.md, and the
# Decision and Enforcement of an ADR, without code spans, italics, link targets, block quotes,
# tables, fenced code, and headings. It lists each sentence over 25 words that holds an added line,
# by the line it starts on, each soft modal verb on an added line: should, could, might, ideally,
# and each word on an added line that an entry of docs/GLOSSARY.md lists under _Avoid:_, with the
# term to write instead (ADR-0001). A verb or a word counts whole, case insensitive, and not inside
# an identifier, where a letter, a digit, or an underscore adjoins it. A paragraph or a list item
# ends a sentence; so do '.', '!', and '?' before a space or the end. It reports for the reviewer
# and never fails on what it counts.
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
resolve_change "Plain rules sensor" "${1:-}" "${2:-}" || exit 0
base="$CHANGE_BASE" head="$CHANGE_HEAD"
# at — the head a file is read at, empty for the working tree, as rule_stream and change_file take it.
at="$( ((CHANGE_WORKTREE)) || echo "$head")"
range="$(git rev-parse --short "$base")..$(git rev-parse --short "$head")"
[[ -n "$at" ]] || range="${range%..*}..working tree"

if ! stream="$(rule_stream "$base" "$at")"; then
  awk -F '\t' -v range="$range" '
    $1 == "E" && $2 == "" { print "Plain rules sensor (" range "): could not list the rules the change touches." }
    $1 == "E" && $2 != "" { print "Plain rules sensor (" range "): could not read the rules of " $2 "." }' <<< "$stream" >&2
  exit 2
fi
# The glossary as the change has it: the working tree's, or the head's.
glossary="$(mktemp)"
change_file "$at" docs/GLOSSARY.md > "$glossary" 2>/dev/null
avoid="$(avoid_terms "$glossary")"
rm -f "$glossary"
findings=()
while IFS= read -r finding; do findings+=("$finding"); done < <(
  awk -F '\t' -v max="$MAX_WORDS" -v avoid="$avoid" '
    BEGIN { na = split(avoid, rows, "\n"); for (i = 1; i <= na; i++) { split(rows[i], kv, "\t"); word[i] = kv[1]; term[i] = kv[2] } }
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
          if (low ~ ("(^|[^a-z0-9_])" soft[i] "([^a-z0-9_]|$)")) print file ":" nr ": the soft modal verb \"" soft[i] "\""
        low = " " low " "
        for (i = 1; i <= na; i++) {
          rest = low; off = 0
          while ((at = index(rest, word[i])) > 0) {
            before = substr(low, off + at - 1, 1); after = substr(low, off + at + length(word[i]), 1)
            if (before !~ /[a-z0-9_]/ && after !~ /[a-z0-9_]/) {
              print file ":" nr ": \"" word[i] "\" is listed under _Avoid:_ in docs/GLOSSARY.md — write \"" term[i] "\""
              break
            }
            off += at; rest = substr(low, off + 1)
          }
        }
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
  echo "Plain rules sensor ($range): no long sentence, no soft modal verb, and no avoided term on the lines the change adds to the rules."
  exit 0
fi
echo "Plain rules sensor ($range): ${#findings[@]} to read on the lines the change adds to the rules (AGENTS.md section 4):"
printf '  - %s\n' "${findings[@]}"
exit 0
