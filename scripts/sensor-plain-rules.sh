#!/usr/bin/env bash
#
# Sensor: rules written plainly (AGENTS.md section 4, ADR-0002).
#
# Reads the lines a change adds to the rules: AGENTS.md, and the Decision and Enforcement sections
# of an ADR (ADR_RULE_SECTIONS in scripts/lib/adr.sh). It lists each sentence over 25 words that
# holds an added line, by the line it starts on, and each soft modal verb on an added line:
# should, could, might, ideally. Code spans, words in italics, which a rule uses to name a word,
# link targets, block quotes, fenced code, tables, and headings do not count. A paragraph or a list item ends a sentence; so do '.', '!', and '?' before a
# space or the end. It reports for the reviewer and never fails on what it counts.
#
# Pure bash + git + awk. Usage:
#     scripts/sensor-plain-rules.sh [--root <dir>] [base [head]]
# Without a base, the merge base of head with origin/main (else main) is used; CI passes the pull
# request's base, and a base of zeros counts as none. Without a head, the change is the working
# tree, untracked files included. Exit code 0, except 2 on a base or head that does not resolve.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/adr.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/adr.sh"
# shellcheck source-path=SCRIPTDIR source=lib/git.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/git.sh"

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

# added <path> — the numbers of the lines the change adds to the file, one per line; every line of
# an untracked file.
added() {
  if ((worktree)) && ! git ls-files --error-unmatch -- "$1" >/dev/null 2>&1; then
    awk '{ print NR }' "$1"
    return
  fi
  if ((worktree)); then git diff -U0 --no-renames "$base" -- "$1"; else git diff -U0 --no-renames "$base" "$head" -- "$1"; fi \
    | awk '/^@@ / { split($3, a, ","); s = substr(a[1], 2); n = (2 in a) ? a[2] : 1; for (i = 0; i < n; i++) print s + i }'
}

# show <path> — the file as the change has it.
show() { if ((worktree)); then cat -- "$1"; else git show "$head:$1"; fi; }

files=()
while IFS= read -r p; do
  [[ "$p" == AGENTS.md || ( "$p" == docs/adr/* && "$p" != docs/adr/*/* ) ]] || continue
  [[ "$p" == AGENTS.md ]] || adr_is_file "$p" || continue
  if ((worktree)); then [[ -f "$p" ]] || continue; else git cat-file -e "$head:$p" 2>/dev/null || continue; fi
  files+=("$p")
done < <(
  if ((worktree)); then
    git -c core.quotePath=false diff --name-only --no-renames "$base"
    git -c core.quotePath=false ls-files --others --exclude-standard
  else
    git -c core.quotePath=false diff --name-only --no-renames "$base" "$head"
  fi | LC_ALL=C sort -u)

findings=()
for f in "${files[@]}"; do
  lines="$(added "$f" | tr '\n' ',')"
  [[ -n "$lines" ]] || continue
  mode=rules
  [[ "$f" == AGENTS.md ]] || mode=adr
  while IFS= read -r finding; do findings+=("$finding"); done < <(show "$f" | awk \
    -v file="$f" -v added=",$lines" -v mode="$mode" -v sections="^## ($ADR_RULE_SECTIONS)\$" -v max="$MAX_WORDS" '
    function flush(  i, any) {
      if (count > max) {
        any = 0
        for (i in seen) if (index(added, "," i ",")) any = 1
        if (any) print file ":" start ": a sentence of " count " words"
      }
      count = 0; start = 0; split("", seen)
    }
    /^[[:space:]]*(```|~~~)/ { flush(); fence = !fence; next }
    fence { next }
    /^## / { flush(); if (mode == "adr") inside = ($0 ~ sections); next }
    mode == "adr" && !inside { next }
    /^#/ || /^[[:space:]]*[>|]/ || /^[[:space:]]*$/ { flush(); next }
    /^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]/ { flush() }
    {
      text = $0
      gsub(/`[^`]*`/, "", text)
      gsub(/\*\*/, "\001", text); gsub(/\*[^*]+\*/, "", text); gsub(/\001/, "**", text)
      gsub(/\]\([^)]*\)/, "]", text)
      if (index(added, "," NR ",")) {
        low = tolower(text)
        n = split("should could might ideally", soft, " ")
        for (i = 1; i <= n; i++)
          if (low ~ ("(^|[^a-z])" soft[i] "([^a-z]|$)")) print file ":" NR ": the soft modal verb \"" soft[i] "\""
      }
      w = split(text, words, /[[:space:]]+/)
      for (i = 1; i <= w; i++) {
        if (words[i] !~ /[A-Za-z0-9]/) continue
        if (!count) start = NR
        count++; seen[NR] = 1
        if (words[i] ~ /[.!?][)*_"]*$/) flush()
      }
    }
    END { flush() }')
done

if ((${#findings[@]} == 0)); then
  echo "Plain rules sensor ($range): no long sentence and no soft modal verb on the lines the change adds to the rules."
  exit 0
fi
echo "Plain rules sensor ($range): ${#findings[@]} to read on the lines the change adds to the rules (AGENTS.md section 4):"
printf '  - %s\n' "${findings[@]}"
exit 0
