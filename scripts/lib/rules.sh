# shellcheck shell=bash
# The rules a change adds to, read one way by scripts/sensor-plain-rules.sh and by check 17 of
# scripts/check-docs.sh: AGENTS.md, and the sections ADR_RULE_SECTIONS of each ADR (AGENTS.md
# section 4). Sourced after scripts/lib/adr.sh, run inside the repository of the change.

# rule_stream <base> [head] — every line of the rules in the files the change touches, as the
# change has them: without a head, the working tree with its untracked files. For each file
# 'F<TAB><path>'; for each line of its rules 'L<TAB><number><TAB><1 if the change adds it, else
# 0><TAB><text>', the text without code spans, link targets, and words in italics, '*word*' or
# '_word_', which a rule uses to name a word, each italic a space; 'P' where a paragraph, a list item, a
# heading, a block quote, a table, or fenced code ends a run of prose. An italic may wrap.
rule_stream() {
  local base="$1" head="${2:-}" p lines
  local -a refs=("$base")
  [[ -n "$head" ]] && refs+=("$head")
  while IFS= read -r p; do
    [[ "$p" == AGENTS.md ]] || { [[ "$p" == docs/adr/* && "$p" != docs/adr/*/* ]] && adr_is_file "$p"; } || continue
    if [[ -z "$head" ]]; then [[ -f "$p" ]] || continue; else git cat-file -e "$head:$p" 2>/dev/null || continue; fi
    if [[ -z "$head" ]] && ! git ls-files --error-unmatch -- "$p" >/dev/null 2>&1; then
      lines="$(awk '{ printf ",%d", NR }' "$p")"
    else
      lines="$(git diff -U0 --no-renames "${refs[@]}" -- "$p" \
        | awk '/^@@ / { split($3, a, ","); s = substr(a[1], 2); n = (2 in a) ? a[2] : 1; for (i = 0; i < n; i++) printf ",%d", s + i }')"
    fi
    [[ -n "$lines" ]] || continue
    printf 'F\t%s\n' "$p"
    { if [[ -z "$head" ]]; then cat -- "$p"; else git show "$head:$p"; fi; } | awk \
      -v added="$lines," -v adr="$([[ "$p" == AGENTS.md ]] || echo 1)" -v sections="^## ($ADR_RULE_SECTIONS)\$" '
      function para() { if (!gap) print "P"; gap = 1; ital = "" }
      # plain <text> — a star or an underscore opens an italic before a non-space and closes it
      # after one; an underscore inside a word, as in snake_case, does neither. Bold is no italic,
      # and the italic carries to the next line of the paragraph.
      function plain(s,  out, i, c, prev, nx) {
        gsub(/\*\*/, "\001", s); gsub(/__/, "\002", s); out = ""; prev = " "
        for (i = 1; i <= length(s); i++) {
          c = substr(s, i, 1); nx = substr(s, i + 1, 1)
          if (ital == "" && (c == "*" || (c == "_" && prev !~ /[[:alnum:]]/)) && nx ~ /[^[:space:]]/) {
            ital = c; out = out " "
          } else if (ital != "" && c == ital && prev ~ /[^[:space:]]/ && (c == "*" || nx !~ /[[:alnum:]]/)) {
            ital = ""; out = out " "
          } else if (ital == "") out = out c
          prev = c
        }
        gsub(/\001/, "**", out); gsub(/\002/, "__", out)
        return out
      }
      !fence && match($0, /^[[:space:]]*(```|~~~)/) { para(); fence = substr($0, RLENGTH - 2, 3); next }
      fence && index($0, fence) && $0 ~ /^[[:space:]]*(```|~~~)/ { fence = ""; next }
      fence != "" { next }
      /^## / { para(); if (adr) inside = ($0 ~ sections); next }
      adr && !inside { next }
      /^#/ || /^[[:space:]]*[>|]/ || /^[[:space:]]*$/ { para(); next }
      /^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]/ { para() }
      {
        text = $0
        gsub(/`[^`]*`/, "", text)
        gsub(/\]\([^)]*\)/, "]", text)
        text = plain(text)
        print "L\t" NR "\t" (index("," added, "," NR ",") ? 1 : 0) "\t" text; gap = 0
      }'
  done < <(
    if [[ -z "$head" ]]; then
      git -c core.quotePath=false diff --name-only --no-renames "$base"
      git -c core.quotePath=false ls-files --others --exclude-standard
    else
      git -c core.quotePath=false diff --name-only --no-renames "$base" "$head"
    fi | LC_ALL=C sort -u)
}
