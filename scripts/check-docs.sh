#!/usr/bin/env bash
#
# Documentation consistency checks for this repository.
#
# Enforces — as CI, not just convention — the documentation rules from AGENTS.md and
# docs/adr/README.md:
#
#   1. ADR index integrity: every docs/adr/NNNN-*.md file is listed in the index table in
#      docs/adr/README.md, every index row points to an existing file, and the status and the
#      'Applies to' cell shown in the index match the **Status:** and **Applies to:** lines
#      inside each ADR — the index routes a reader from a change to the ADRs that bind it
#      (AGENTS.md, section 2), so a row that misstates what its ADR governs misroutes them.
#   2. ADR numbering integrity: the ADR files run 0001..N without gaps, and every file's
#      '# ADR-NNNN' heading matches its filename (docs/adr/README.md, process rule 5).
#   3. Relative-link integrity: every relative Markdown link in every tracked .md file resolves
#      to a file or directory that exists. Links inside fenced code blocks are illustrations,
#      not claims about files on disk, and are skipped (here and in check 6); so is a target that
#      still carries the 'NNNN' placeholder of docs/adr/template.md; an optional link title
#      ('[text](file "title")') is not part of the path. Reference-style links
#      ('[text][label]') are not resolved — this repository uses inline links only.
#
#      Checks 3 to 6 and 11 skip ⚪ superseded and 🔴 rejected ADRs (see is_inactive_adr): both
#      describe a repository state that does not exist, so holding their references against the
#      current tree would demand that it still contain what the project decided against.
#   4. Section-reference integrity: in Markdown, YAML and shell files, every section reference
#      (the section sign followed by a number, e.g. in "AGENTS.md, section 6") matches a numbered
#      '## N.' heading in AGENTS.md — the only numbered document in this repository; extend the
#      check if another one appears. The headings there must themselves run 1..N in order: a
#      gap or a repeat is a botched renumbering, and it is the only half of the renumbering
#      hazard a check can see (AGENTS.md, section 3).
#   5. ADR-reference integrity: every 'ADR-NNNN' reference (with actual digits) names an ADR
#      file that exists in docs/adr/ — anticipated follow-ups are described by topic, never by
#      a number that does not exist yet (docs/adr/README.md, process rule 6).
#   6. ADR link agreement: a Markdown link whose text cites 'ADR-NNNN' points at that ADR's own
#      file — the number and the file it links to must name the same decision
#      (docs/adr/README.md, process rule 6).
#   7. ADR header hygiene: every ADR's '**Status:**' line carries exactly one legend emoji and the
#      word that belongs to it, and no ADR still contains the instruction paragraph from
#      docs/adr/template.md — recognized by a needle read off that template, so rewording it
#      cannot silently disable the check. Check 1 compares index and file emoji-to-emoji, so a
#      leftover list of alternatives and a word contradicting its emoji both survive it — and the
#      word is what a reader believes (docs/adr/README.md, process rule 3).
#   8. Supersession agreement: the '**Supersedes:**' field of the new ADR and the '⚪ superseded by
#      ADR-NNNN' status line of the old one name each other. Both are written in the same pull
#      request but in two files (docs/adr/README.md, process rule 5), and check 1 cannot see a
#      missing half — it only mirrors the index against whatever status the file carries.
#   9. Check-list agreement: the jobs in .github/workflows/checks.yml, the invocations in
#      scripts/check-all.sh, and the required status checks named between the 'required-checks'
#      markers in README.md list the same checks. A check that runs in only one of the three is a
#      gate somebody believes in and does not have, and both files already say in their header
#      that a check added to one is added to the other in the same change (AGENTS.md, section 5).
#  10. Project Layout integrity: every path listed in the 'Project Layout' block of README.md
#      exists, a trailing '/' meaning a directory. The block is written by hand and nothing else
#      tells a reader that one of its lines has gone stale. The reverse direction is deliberately
#      not checked — the block is a tour of the parts a newcomer needs, not a file listing.
#  11. Process-rule reference integrity: every 'process rule N' reference — including each number
#      in a 'process rules N and M' or 'N to M' list — names a rule the numbered '## Process' list
#      in docs/adr/README.md actually carries, and that list runs 1..N without a gap. That
#      document states the hazard itself: its rules are cited by number elsewhere, so renumbering
#      the list means rewriting those citations in the same change, and nothing else in this
#      script would notice a citation left behind. Only the explicit 'process rule(s) N' form is
#      checked; a bare '(rule 4)' is ambiguous, because AGENTS.md section 3 numbers its own rules
#      too, and that half is carried by review.
#
# Checks 5 and 6 read every text file of the repository, not a list of documentation extensions:
# process rule 5 states that code may reference an ADR number, so a verifier restricted to
# documentation file types would leave the references most likely to go stale — those in source
# comments, which no reviewer reads alongside the ADR index — unchecked. Check 4 stays on
# documentation file types on purpose: 'ADR-NNNN' means one thing wherever it appears, but '§' in
# source code is an ordinary character (see is_doc_file), and flagging it there would make a
# project's own string literals fail this repository's CI.
#
# Pure bash + coreutils/grep/sed/awk/find, plus git to enumerate the repository's files — all present
# in the Dev Container base image, so running it adds no toolchain and no dependency that would
# require an ADR.
#
# Usage:
#     scripts/check-docs.sh        (or: bash scripts/check-docs.sh)
# Exit code 0 when all checks pass, 1 otherwise.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADR_DIR="$ROOT/docs/adr"
ADR_INDEX="$ADR_DIR/README.md"

errors=()
add_error() { errors+=("$1"); }

# Print the first legend status emoji (🟢 🟡 🔴 ⚪) read from stdin, if any.
first_status_emoji() { grep -oE '🟢|🟡|🔴|⚪' | head -n1; }

# table_cell <n> — the n-th cell of a Markdown table row read from stdin, trimmed; cells are
# counted from 1 after the leading pipe, so '| a | b |' has cell 1 'a' and cell 2 'b'.
table_cell() {
  awk -F'|' -v n="$1" '{ c = $(n + 1); gsub(/^[[:space:]]+|[[:space:]]+$/, "", c); print c }'
}

# applies_to_of <adr file> — the content of its '**Applies to:**' header line, trimmed; empty
# when the line is missing or blank.
applies_to_of() {
  grep -m1 -F '**Applies to:**' "$1" | sed -E 's/^.*\*\*Applies to:\*\*[[:space:]]*//; s/[[:space:]]+$//'
}

# _contains <needle> <haystack...> — true if needle equals one of the arguments.
_contains() {
  local needle="$1"; shift
  local item
  for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done
  return 1
}

# TEXT_FILES — every text file the repository consists of, absolute paths, sorted. Collected once
# by collect_text_files below and then iterated by each check: building the list costs a grep per
# file, so rebuilding it inside every check would multiply that cost by the number of checks, and
# a repository of a few thousand files makes that difference visible in CI.
#
# The list comes from git: tracked files plus new, not-yet-added ones, minus everything
# .gitignore excludes. That keeps generated trees (node_modules/, target/, dist/) out without
# this script having to guess the directory names of a toolchain this repository does not yet know.
# Binary files are dropped by grep -I, which never matches inside one.
# Outside a work tree (an exported tarball) git cannot answer, so fall back to a plain walk.
TEXT_FILES=()
collect_text_files() {
  local f
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    grep -Iq . "$f" 2>/dev/null || continue
    TEXT_FILES+=("$f")
  done < <(
    if git -C "$ROOT" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      git -C "$ROOT" ls-files --cached --others --exclude-standard \
        | sed "s|^|$ROOT/|"
    else
      find "$ROOT" -type f -not -path '*/.git/*'
    fi | sort
  )
  if ((${#TEXT_FILES[@]} == 0)); then
    add_error "no text files found under $ROOT — the file list is empty, so nothing was checked"
  fi
}

# is_doc_file <file> — true for the file types in which the section sign is a reference into
# AGENTS.md by convention: Markdown, YAML, and shell scripts. In source code the section sign is
# an ordinary character with its own meanings — a statute cited in a German string literal, a
# translated message, a test fixture — none of which are claims about a section of AGENTS.md.
# The ADR checks scan every text file because 'ADR-NNNN' is unambiguous; this notation is not.
is_doc_file() {
  case "$1" in *.md | *.yml | *.yaml | *.sh) return 0 ;; *) return 1 ;; esac
}

# is_inactive_adr <file> — true for an ADR whose status is ⚪ superseded or 🔴 rejected. Both are
# historical record rather than live decisions, and both describe a repository state that does not
# exist: a superseded ADR is frozen with the past it was written against (AGENTS.md,
# docs/adr/README.md), and a rejected one describes a road not taken — the check script, the
# workflow job, the AGENTS.md section it names were never created, or were removed together with
# the rejection. Verifying either one's references would demand that the tree still contain what
# the project decided against, so the reference checks below skip them.
is_inactive_adr() {
  [[ "$1" == "$ADR_DIR"/* ]] && grep -m1 -F '**Status:**' "$1" | grep -q '⚪\|🔴'
}

check_adr_index() {
  if [[ ! -f "$ADR_INDEX" ]]; then
    add_error "ADR index not found: docs/adr/README.md"
    return
  fi

  # ADR files on disk (basenames), excluding the template.
  local disk_files=()
  local f
  while IFS= read -r f; do
    [[ "$(basename "$f")" == "template.md" ]] && continue
    disk_files+=("$(basename "$f")")
  done < <(find "$ADR_DIR" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)

  # Parse the index into parallel arrays: filename, 'Applies to' cell, and status emoji per row.
  # Columns are '| ADR | Title | Applies to | Status |'; the cell is compared verbatim.
  local indexed_files=() indexed_applies=() indexed_status=()
  local line number target filename applies status
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*\[([0-9]{4})\]\(([^\)]+)\) ]] || continue
    number="${BASH_REMATCH[1]}"
    target="${BASH_REMATCH[2]}"
    filename="${target%%#*}"
    applies="$(printf '%s' "$line" | table_cell 3)"
    status="$(printf '%s' "$line" | first_status_emoji)"
    indexed_files+=("$filename")
    indexed_applies+=("$applies")
    indexed_status+=("$status")
    if [[ "$filename" != "$number"-* ]]; then
      add_error "ADR index: row for $number links to '$filename', which does not start with '$number-'"
    fi
  done < "$ADR_INDEX"

  # Every file on disk must be listed.
  local d
  for d in "${disk_files[@]}"; do
    if ! _contains "$d" "${indexed_files[@]}"; then
      add_error "ADR index: file '$d' exists but is not listed in the index"
    fi
  done

  # Every listed file must exist, and its status and 'Applies to' must match the file.
  local i file_status file_applies
  for i in "${!indexed_files[@]}"; do
    f="${indexed_files[$i]}"
    status="${indexed_status[$i]}"
    applies="${indexed_applies[$i]}"
    if [[ ! -f "$ADR_DIR/$f" ]]; then
      add_error "ADR index: lists '$f', but no such ADR file exists"
      continue
    fi
    file_status="$(grep -m1 -F '**Status:**' "$ADR_DIR/$f" | first_status_emoji)"
    if [[ -z "$file_status" ]]; then
      add_error "$f: no '**Status:**' line with a status emoji found"
    elif [[ "$file_status" != "$status" ]]; then
      add_error "ADR index: status for '$f' is ${status:-<none>} in the index but $file_status in the file"
    fi
    file_applies="$(applies_to_of "$ADR_DIR/$f")"
    if [[ -z "$file_applies" ]]; then
      add_error "$f: no '**Applies to:**' line naming what the decision constrains"
    elif [[ "$file_applies" != "$applies" ]]; then
      add_error "ADR index: 'Applies to' for '$f' is '${applies:-<none>}' in the index but '$file_applies' in the file"
    fi
  done
}

# ADR numbers run 0001..N without gaps, and each file's heading carries its own number.
# Superseded ADRs stay on disk, so a gap can only ever mean a deleted ADR or a botched rename.
check_adr_numbering() {
  local f base number expected heading n=0
  while IFS= read -r f; do
    base="$(basename "$f")"
    number="${base%%-*}"
    n=$((n + 1))
    expected="$(printf '%04d' "$n")"
    if [[ "$number" != "$expected" ]]; then
      add_error "ADR numbering: expected '$expected-*.md' at position $n, found '$base' — numbers must run 0001..N without gaps"
      return
    fi
    heading="$(grep -m1 -oE '^# ADR-[0-9]{4}' "$f")"
    if [[ "$heading" != "# ADR-$number" ]]; then
      add_error "$base: heading says '${heading:-<none>}', but the filename says ADR-$number"
    fi
  done < <(find "$ADR_DIR" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)
}

# status_word_for_emoji <emoji> — the status word that belongs to a legend emoji, empty for
# anything else. The legend itself lives above the index in docs/adr/README.md.
status_word_for_emoji() {
  case "$1" in
    🟢) printf 'accepted' ;;
    🟡) printf 'proposed' ;;
    🔴) printf 'rejected' ;;
    ⚪) printf 'superseded' ;;
  esac
}

# instruction_needle — the opening of the instruction paragraph in docs/adr/template.md: the first
# line of its italic block, without the leading '*' and cut to a phrase. Reading the needle off the
# template instead of hard-coding a sentence is what keeps the check alive when the paragraph is
# reworded — which is what a project does with a template. Empty when the template is gone or
# carries no such block; the sub-check then does not run rather than reporting a phantom.
instruction_needle() {
  local line
  line="$(grep -m1 -E '^\*[^*]' "$ADR_DIR/template.md" 2>/dev/null)" || return 0
  printf '%s' "${line:1:40}"
}

# Every ADR's '**Status:**' line carries exactly one legend emoji plus the word that belongs to it,
# and no ADR still carries the instruction paragraph from template.md. check_adr_index reads the
# status through first_status_emoji, so on its own it would accept a line that kept a list of
# alternatives ('🟡 proposed | 🟢 accepted | …') as whatever stands first, and a line whose word
# and emoji disagree passes there on the strength of the emoji — while the word is what a reader
# believes. A missing or emoji-less status line is left to check_adr_index, which reports it.
check_adr_headers() {
  local f base line count emoji expected word needle
  needle="$(instruction_needle)"
  while IFS= read -r f; do
    base="$(basename "$f")"
    line="$(grep -m1 -F '**Status:**' "$f")"
    emoji="$(printf '%s' "$line" | first_status_emoji)"
    if [[ -n "$emoji" ]]; then
      count="$(printf '%s' "$line" | grep -oE '🟢|🟡|🔴|⚪' | wc -l | tr -d ' ')"
      expected="$(status_word_for_emoji "$emoji")"
      read -r word _ <<<"${line#*"$emoji"}"
      if ((count > 1)); then
        add_error "$base: status line carries $count status emoji — keep exactly one"
      elif [[ "$word" != "$expected" ]]; then
        add_error "$base: status line reads '$emoji ${word:-<nothing>}', but $emoji means '$expected'"
      fi
    fi
    if [[ -n "$needle" ]] && grep -qF "$needle" "$f"; then
      add_error "$base: still carries the instruction paragraph from template.md — delete it"
    fi
  done < <(find "$ADR_DIR" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)
}

# superseding_number <status line> — the four-digit number a '⚪ superseded by ADR-NNNN' status
# line names, empty when it names none. The citation may be plain or a Markdown link, so the
# bracket is optional (docs/adr/README.md, process rule 6 asks for the link form).
superseding_number() {
  grep -oE 'superseded by \[?ADR-[0-9]{4}' <<<"$1" | grep -oE '[0-9]{4}$'
}

# A supersession is written into two files in one pull request: the new ADR's '**Supersedes:**'
# field and the old ADR's status line (docs/adr/README.md, process rule 5). Nothing else compares
# them — check_adr_index only mirrors the index against whatever status a file carries, so a half
# performed flip passes it. Both directions are verified here; a cited number that names no file
# is left to check_adr_refs, which reports it repository-wide.
check_adr_supersessions() {
  local f base nr line target target_file back succ succ_file
  while IFS= read -r f; do
    base="$(basename "$f")"
    nr="${base%%-*}"
    line="$(grep -m1 -F '**Status:**' "$f")"

    # Forward: what this ADR claims to supersede must carry the matching status line.
    target="$(grep -m1 -F '**Supersedes:**' "$f" | grep -oE 'ADR-[0-9]{4}' | head -n1)"
    if [[ -n "$target" ]]; then
      target_file="$(find "$ADR_DIR" -maxdepth 1 -type f -name "${target#ADR-}-*.md" | head -n1)"
      if [[ -n "$target_file" ]]; then
        back="$(superseding_number "$(grep -m1 -F '**Status:**' "$target_file")")"
        [[ "$back" == "$nr" ]] || add_error \
          "$(basename "$target_file"): $base supersedes it, but its status line does not say 'superseded by ADR-$nr'"
      fi
    fi

    # Backward: a superseded ADR names its successor, and the successor claims it.
    succ="$(superseding_number "$line")"
    if [[ -z "$succ" ]]; then
      [[ "$(printf '%s' "$line" | first_status_emoji)" == "⚪" ]] \
        && add_error "$base: status is ⚪ but the line names no superseding ADR"
    else
      succ_file="$(find "$ADR_DIR" -maxdepth 1 -type f -name "$succ-*.md" | head -n1)"
      if [[ -n "$succ_file" ]] && ! grep -m1 -F '**Supersedes:**' "$succ_file" | grep -q "ADR-$nr"; then
        add_error "$(basename "$succ_file"): $base says it supersedes, but it carries no '**Supersedes:**' field naming ADR-$nr"
      fi
    fi
  done < <(find "$ADR_DIR" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)
}

# Print the GitHub-style slug of every ATX heading in a Markdown file.
extract_heading_slugs() {
  local line text
  while IFS= read -r line; do
    [[ "$line" =~ ^#{1,6}[[:space:]]+(.*)$ ]] || continue
    text="${BASH_REMATCH[1]}"
    # Drop a trailing run of '#' (closed ATX headings), then slugify the way GitHub does:
    # lowercase, remove everything but [a-z0-9 _-], then one hyphen per remaining space. A run of
    # spaces yields a run of hyphens: GitHub drops a character such as "&" and keeps the spaces
    # around it, so "Quality bar & Definition of Done" anchors as "quality-bar--definition-of-done".
    printf '%s\n' "$text" \
      | sed -E 's/[[:space:]]+#*[[:space:]]*$//' \
      | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/[^a-z0-9 _-]+//g; s/[[:space:]]/-/g'
  done < "$1"
}

# anchor_resolves <file> <fragment> — true if the fragment exists in the file.
# Handles GitHub line anchors (Lnn, Lnn-Lmm) for any file and heading-slug anchors for
# Markdown files; any other anchor is unverifiable from disk and is accepted.
anchor_resolves() {
  local file="$1" frag="$2" start end lines slug
  if [[ "$frag" =~ ^L([0-9]+)(-L([0-9]+))?$ ]]; then
    start="${BASH_REMATCH[1]}"; end="${BASH_REMATCH[3]:-$start}"
    lines="$(wc -l < "$file")"
    # +1 tolerates a final line with no trailing newline (uncounted by wc -l).
    (( start >= 1 && end >= start && end <= lines + 1 ))
    return
  fi
  case "$file" in
    *.md)
      while IFS= read -r slug; do
        [[ "$slug" == "$frag" ]] && return 0
      done < <(extract_heading_slugs "$file")
      return 1 ;;
    *) return 0 ;;
  esac
}

# strip_code_fences <file> — the file with fenced code blocks (``` / ~~~, also inside
# blockquotes) blanked out: links in fences are illustrations, not claims about files on disk.
# Fenced lines become empty lines, so the output keeps the original line count.
strip_code_fences() {
  awk '
    /^[[:space:]>]*(```|~~~)/ { in_fence = !in_fence; print ""; next }
    in_fence                  { print ""; next }
    { print }
  ' "$1"
}

# link_target <linkexpr> — the target of one '[text](target)' expression: trimmed, with an
# optional trailing '"title"' or "'title'" removed (a link title is not part of the path).
LINK_TITLE_RE="^([^[:space:]]+)[[:space:]]+(\"[^\"]*\"|'[^']*')\$"
link_target() {
  local target
  target="$(printf '%s' "$1" | sed -E 's/^\[[^]]*\]\(([^)]+)\)$/\1/')"
  target="$(printf '%s' "$target" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  [[ "$target" =~ $LINK_TITLE_RE ]] && target="${BASH_REMATCH[1]}"
  printf '%s' "$target"
}

check_relative_links() {
  local md rel linkexpr target path_part frag dir target_file
  for md in "${TEXT_FILES[@]}"; do
    case "$md" in *.md) ;; *) continue ;; esac
    rel="${md#"$ROOT"/}"
    is_inactive_adr "$md" && continue
    dir="$(dirname "$md")"
    while IFS= read -r linkexpr; do
      target="$(link_target "$linkexpr")"
      case "$target" in
        http://*|https://*|mailto:*) continue ;;
      esac
      # 'NNNN' is the placeholder docs/adr/template.md uses where a real ADR carries its number,
      # so such a target names no file and claims none exists — the convention checks 5 and 6
      # follow by matching only references with actual digits.
      case "$target" in *NNNN*) continue ;; esac
      # Split into a path part and an optional '#fragment'. An empty path is a same-file anchor.
      path_part="${target%%#*}"
      frag=""
      [[ "$target" == *"#"* ]] && frag="${target#*#}"
      if [[ -z "$path_part" ]]; then
        target_file="$md"
      else
        target_file="$dir/$path_part"
        if [[ ! -e "$target_file" ]]; then
          add_error "$rel: broken relative link -> '$target'"
          continue
        fi
      fi
      # Validate the anchor fragment against the resolved file, when there is one.
      if [[ -n "$frag" && -f "$target_file" ]]; then
        anchor_resolves "$target_file" "$frag" \
          || add_error "$rel: link '$target' has no matching anchor '#$frag' in ${target_file#"$ROOT"/}"
      fi
    done < <(strip_code_fences "$md" | grep -oE '\[[^]]*\]\([^)]+\)')
  done
}

# Section references point into AGENTS.md, whose sections are numbered '## N.' headings. Inserting
# or removing a section renumbers the ones after it, and a bare '§N' would keep pointing at
# whatever now carries that number — valid-looking and wrong. In Markdown a reference is therefore
# written as a link to the section's own anchor, which carries the number *and* the title
# ('AGENTS.md#3-adr-rules'): renumbering or retitling a section makes that anchor stop resolving,
# and check 3 fails on every reference to it. This check verifies the other half — that the number
# in the text and the anchor the link points at name the same section.
#
# Named gap (AGENTS.md, section 5): outside Markdown there are no links, so a '§N' in a workflow or
# a script comment is still only checked for the number existing. Those references live in files a
# maintainer edits next to AGENTS.md; the weaker guarantee is recorded here rather than hidden.
check_section_refs() {
  local agents="$ROOT/AGENTS.md"
  if [[ ! -f "$agents" ]]; then
    add_error "AGENTS.md not found in the repository root"
    return
  fi

  local valid_sections=()
  local n
  while IFS= read -r n; do
    valid_sections+=("$n")
  done < <(sed -nE 's/^## ([0-9]+)\..*/\1/p' "$agents")
  if ((${#valid_sections[@]} == 0)); then
    add_error "AGENTS.md: no numbered '## N.' section headings found"
    return
  fi

  # The numbering itself: 1..N in order, no gap and no repeat. A botched renumbering is what this
  # catches; that a reference still means the section it meant before is what the anchors do.
  local i expected
  for i in "${!valid_sections[@]}"; do
    expected=$((i + 1))
    if [[ "${valid_sections[$i]}" != "$expected" ]]; then
      add_error "AGENTS.md: numbered sections must run 1..N in order — expected '## $expected.' at position $expected, found '## ${valid_sections[$i]}.'"
      break
    fi
  done

  # The anchor each section carries, read with the same slug rule the link check uses.
  local section_slug=() slug
  while IFS= read -r slug; do
    [[ "$slug" =~ ^([0-9]+)- ]] || continue
    n="${BASH_REMATCH[1]}"
    _contains "$n" "${valid_sections[@]}" && section_slug[n]="$slug"
  done < <(extract_heading_slugs "$agents")

  local f rel lineno line clean linkexpr target frag
  for f in "${TEXT_FILES[@]}"; do
    is_doc_file "$f" || continue
    rel="${f#"$ROOT"/}"
    is_inactive_adr "$f" && continue

    case "$f" in
      *.md)
        lineno=0
        while IFS= read -r line; do
          lineno=$((lineno + 1))
          # Inline code spans hold literals, not citations: '`§1`' in a sentence about references
          # is the notation itself. Dropping them also strips the '`AGENTS.md`' inside a link text,
          # which leaves the link expression itself intact.
          line="$(sed -E 's/`[^`]*`//g' <<< "$line")"
          [[ "$line" == *§* ]] || continue
          while IFS= read -r linkexpr; do
            [[ "$linkexpr" =~ §([0-9]+) ]] || continue
            n="${BASH_REMATCH[1]}"
            if ! _contains "$n" "${valid_sections[@]}"; then
              add_error "$rel:$lineno: reference '§$n' matches no numbered section in AGENTS.md"
              continue
            fi
            target="$(link_target "$linkexpr")"
            frag=""
            [[ "$target" == *"#"* ]] && frag="${target#*#}"
            if [[ -z "$frag" ]]; then
              add_error "$rel:$lineno: '§$n' is cited without an anchor — point the link at '#${section_slug[$n]}'"
            elif [[ "$frag" != "${section_slug[$n]}" ]]; then
              add_error "$rel:$lineno: '§$n' links to anchor '#$frag', but section $n of AGENTS.md anchors as '#${section_slug[$n]}'"
            fi
          done < <(grep -oE '\[[^]]*\]\([^)]+\)' <<< "$line")
          # What is left once every link is removed is a reference nothing verifies.
          clean="$(sed -E 's/\[[^]]*\]\([^)]+\)//g' <<< "$line")"
          while IFS= read -r n; do
            if _contains "$n" "${valid_sections[@]}"; then
              add_error "$rel:$lineno: '§$n' stands outside a link — cite a section as a link to its anchor, e.g. [\`AGENTS.md\` §$n](AGENTS.md#${section_slug[$n]})"
            else
              add_error "$rel:$lineno: reference '§$n' matches no numbered section in AGENTS.md"
            fi
          done < <(grep -oE '§[0-9]+' <<< "$clean" | tr -d '§')
        done < <(strip_code_fences "$f")
        ;;
      *)
        while IFS=: read -r lineno line; do
          n="${line#§}"
          _contains "$n" "${valid_sections[@]}" \
            || add_error "$rel:$lineno: reference '§$n' matches no numbered section in AGENTS.md"
        done < <(grep -noE '§[0-9]+' "$f")
        ;;
    esac
  done
}

# Every 'ADR-NNNN' reference (with digits — the literal 'ADR-NNNN' placeholder never matches)
# must name an ADR file that already exists. Anticipated follow-up decisions are described by
# topic, not by a reserved number (docs/adr/README.md, process rule 6).
check_adr_refs() {
  local f rel lineno match number
  for f in "${TEXT_FILES[@]}"; do
    rel="${f#"$ROOT"/}"
    [[ "$f" == "$ADR_DIR/template.md" ]] && continue
    is_inactive_adr "$f" && continue
    while IFS=: read -r lineno match; do
      number="${match#ADR-}"
      if ! compgen -G "$ADR_DIR/$number-*.md" > /dev/null; then
        add_error "$rel:$lineno: reference '$match' matches no ADR file in docs/adr/"
      fi
    done < <(grep -noE 'ADR-[0-9]{4}' "$f")
  done
}

# A Markdown link that cites 'ADR-NNNN' in its text must point at that ADR's own file. Both
# halves resolve on their own — the number names a file that exists, the target is a file that
# exists — so a renumbering, a copied line, or a consolidated decision set leaves the two naming
# different ADRs without any single check noticing. Only links into docs/adr/ are compared; a
# reference that deliberately points elsewhere (an index, a section about the decision) is left
# alone.
check_adr_link_targets() {
  local f rel linkexpr text target base number
  for f in "${TEXT_FILES[@]}"; do
    case "$f" in *.md) ;; *) continue ;; esac
    rel="${f#"$ROOT"/}"
    [[ "$f" == "$ADR_DIR/template.md" ]] && continue
    is_inactive_adr "$f" && continue
    while IFS= read -r linkexpr; do
      text="$(printf '%s' "$linkexpr" | sed -E 's/^\[([^]]*)\].*$/\1/')"
      [[ "$text" =~ ADR-([0-9]{4}) ]] || continue
      number="${BASH_REMATCH[1]}"
      target="$(link_target "$linkexpr")"
      base="$(basename "${target%%#*}")"
      # Compare only against ADR filenames; anything else is not a claim about which ADR it is.
      case "$base" in [0-9][0-9][0-9][0-9]-*.md) ;; *) continue ;; esac
      if [[ "$base" != "$number"-* ]]; then
        add_error "$rel: link '$linkexpr' cites ADR-$number but points at '$base'"
      fi
    done < <(strip_code_fences "$f" | grep -oE '\[[^]]*\]\([^)]+\)')
  done
}

# The three places that list this repository's checks have to agree: the jobs in
# .github/workflows/checks.yml, the invocations in scripts/check-all.sh, and the required status
# checks named in README.md. AGENTS.md, section 5 makes check-all.sh the local equivalent of the
# workflow, and the README list is what a maintainer configures the ruleset from — a check that
# runs in only one of the three is a gate somebody believes in and does not have. Both files say
# in their own header that a check added to one is added to the other in the same change; this is
# that sentence, verified.
check_check_lists() {
  local rel_wf=".github/workflows/checks.yml" rel_all="scripts/check-all.sh"
  local wf="$ROOT/$rel_wf" all="$ROOT/$rel_all" readme="$ROOT/README.md"
  local f
  for f in "$wf" "$all" "$readme"; do
    if [[ ! -f "$f" ]]; then
      add_error "${f#"$ROOT"/}: not found — the check lists cannot be compared"
      return
    fi
  done

  # The workflow: job names at two-space indent under 'jobs:', and the check script each job runs.
  local line job in_jobs=0
  local wf_jobs=() wf_scripts=()
  while IFS= read -r line; do
    [[ "$line" == "jobs:"* ]] && { in_jobs=1; continue; }
    ((in_jobs)) || continue
    if [[ "$line" =~ ^\ \ ([a-z][a-z0-9-]*):[[:space:]]*$ ]]; then
      job="${BASH_REMATCH[1]}"
      wf_jobs+=("$job")
      continue
    fi
    [[ "$line" =~ run:[[:space:]]+bash[[:space:]]+(scripts/[A-Za-z0-9._-]+\.sh) ]] \
      && wf_scripts+=("${BASH_REMATCH[1]}")
  done < "$wf"
  if ((${#wf_jobs[@]} == 0)); then
    add_error "$rel_wf: no jobs found under 'jobs:' — the check lists cannot be compared"
    return
  fi

  # The local runner: every 'run <label> <script>' line.
  local all_scripts=()
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*run[[:space:]]+\"[^\"]*\"[[:space:]]+(scripts/[A-Za-z0-9._-]+\.sh) ]] \
      && all_scripts+=("${BASH_REMATCH[1]}")
  done < "$all"
  if ((${#all_scripts[@]} == 0)); then
    add_error "$rel_all: no 'run <label> <script>' invocations found — the check lists cannot be compared"
    return
  fi

  local s
  for s in "${wf_scripts[@]}"; do
    _contains "$s" "${all_scripts[@]}" \
      || add_error "$rel_all: does not run '$s', which $rel_wf runs — CI and the local gate disagree"
  done
  for s in "${all_scripts[@]}"; do
    _contains "$s" "${wf_scripts[@]}" \
      || add_error "$rel_wf: has no job running '$s', which $rel_all runs — CI and the local gate disagree"
  done

  # The README: the job names fenced by the 'required-checks' markers, which a maintainer copies
  # into the ruleset. Rulesets name checks by job name, so a name that is not a job is a required
  # check that never reports and blocks every pull request.
  local in_block=0 name readme_names=()
  while IFS= read -r line; do
    [[ "$line" == *"required-checks begin"* ]] && { in_block=1; continue; }
    [[ "$line" == *"required-checks end"* ]] && { in_block=0; continue; }
    ((in_block)) || continue
    while IFS= read -r name; do
      readme_names+=("$name")
    done < <(grep -oE '`[a-z][a-z0-9-]*`' <<< "$line" | tr -d '`')
  done < "$readme"
  if ((${#readme_names[@]} == 0)); then
    add_error "README.md: no job names between the 'required-checks' markers — the required status checks are unverifiable"
    return
  fi

  for name in "${readme_names[@]}"; do
    _contains "$name" "${wf_jobs[@]}" \
      || add_error "README.md: required check '$name' is not a job in $rel_wf — a ruleset would wait for a check that never reports"
  done
  for job in "${wf_jobs[@]}"; do
    _contains "$job" "${readme_names[@]}" \
      || add_error "README.md: job '$job' of $rel_wf is missing from the required checks — it would run without gating a merge"
  done
}

# The Project Layout block in README.md is a hand-written inventory, and nothing tells a reader
# that a line of it has gone stale: a renamed or deleted path leaves the block describing a
# repository that no longer exists. Every path it lists therefore has to exist, a trailing '/'
# meaning a directory.
#
# Only that direction is checked. The block is a tour of the parts a newcomer needs, not a listing
# of every file, so a path missing from it is an editorial judgment rather than a defect.
check_project_layout() {
  local readme="$ROOT/README.md"
  if [[ ! -f "$readme" ]]; then
    add_error "README.md: not found — the Project Layout block cannot be checked"
    return
  fi

  local line path in_section=0 in_fence=0 entries=0
  while IFS= read -r line; do
    if ((!in_section)); then
      [[ "$line" == "## Project Layout" ]] && in_section=1
      continue
    fi
    if ((!in_fence)); then
      [[ "$line" =~ ^(\`\`\`|~~~) ]] && { in_fence=1; continue; }
      # A new heading before the fence means the section holds no block at all.
      [[ "$line" =~ ^##[[:space:]] ]] && break
      continue
    fi
    [[ "$line" =~ ^(\`\`\`|~~~) ]] && break
    path="${line%%[[:space:]]*}"
    # Blank lines and the continuation lines of a wrapped comment carry no path.
    [[ -z "$path" || "$path" == "#"* ]] && continue
    entries=$((entries + 1))
    if [[ "$path" == */ ]]; then
      [[ -d "$ROOT/${path%/}" ]] \
        || add_error "README.md: Project Layout lists '$path', which is not a directory of this repository"
    else
      [[ -f "$ROOT/$path" ]] \
        || add_error "README.md: Project Layout lists '$path', which does not exist"
    fi
  done < "$readme"

  if ((entries == 0)); then
    add_error "README.md: no paths found under '## Project Layout' — the inventory is unverifiable"
  fi
}


# The numbered list under '## Process' in docs/adr/README.md is cited by number from ADRs, from
# this script's own header, and from template.md — and that document says so itself: renumbering
# the list means rewriting those citations in the same change. Nothing verified it, so removing a
# rule left three records citing a number the index no longer carried while every other check
# passed. This closes that half: each cited number has to exist, and the list itself has to run
# 1..N so that a range citation ('rules 3 to 6') is covered by its endpoints.
#
# Named gap (AGENTS.md, section 5): only the explicit 'process rule(s) N' form is checked. A bare
# '(rule 4)' is ambiguous — AGENTS.md section 3 numbers its own rules, and the index refers to its
# neighbours the same way — so a check on it would either miss the real citations or flag the rule
# file's own. That half is carried by review.
check_process_rule_refs() {
  local index_rel="${ADR_INDEX#"$ROOT"/}"
  if [[ ! -f "$ADR_INDEX" ]]; then
    add_error "$index_rel: not found — process rule references cannot be checked"
    return
  fi

  local valid_rules=() n
  while IFS= read -r n; do
    valid_rules+=("$n")
  done < <(awk '/^## Process/ { p = 1; next } /^## / { p = 0 } p' "$ADR_INDEX" \
             | sed -nE 's/^([0-9]+)\..*/\1/p')
  if ((${#valid_rules[@]} == 0)); then
    add_error "$index_rel: no numbered rules found under '## Process' — process rule references are unverifiable"
    return
  fi

  # The numbering itself: 1..N in order. A range citation names only its endpoints, so a gap here
  # would let a reference to a number inside the range pass on the strength of the endpoints.
  local i expected
  for i in "${!valid_rules[@]}"; do
    expected=$((i + 1))
    if [[ "${valid_rules[$i]}" != "$expected" ]]; then
      add_error "$index_rel: the process rules must run 1..N in order — expected '$expected.' at position $expected, found '${valid_rules[$i]}.'"
      break
    fi
  done

  local f rel lineno cite
  for f in "${TEXT_FILES[@]}"; do
    rel="${f#"$ROOT"/}"
    is_inactive_adr "$f" && continue
    while IFS=: read -r lineno cite; do
      while IFS= read -r n; do
        _contains "$n" "${valid_rules[@]}" \
          || add_error "$rel:$lineno: '$cite' names rule $n, which $index_rel does not carry"
      done < <(grep -oE '[0-9]+' <<< "$cite")
    done < <(grep -noE 'process rules? [0-9]+([[:space:]]+(to|and)[[:space:]]+[0-9]+)*' "$f")
  done
}

collect_text_files
check_adr_index
check_adr_numbering
check_adr_headers
check_adr_supersessions
check_relative_links
check_section_refs
check_adr_refs
check_adr_link_targets
check_check_lists
check_project_layout
check_process_rule_refs

if ((${#errors[@]} > 0)); then
  echo "Documentation checks FAILED:"
  echo
  for e in "${errors[@]}"; do echo "  - $e"; done
  echo
  echo "${#errors[@]} problem(s) found."
  exit 1
fi

echo "Documentation checks passed."
exit 0
