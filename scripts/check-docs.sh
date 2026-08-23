#!/usr/bin/env bash
#
# Documentation consistency checks for this template.
#
# Enforces — as CI, not just convention — the documentation rules from AGENTS.md and
# docs/adr/README.md:
#
#   1. ADR index integrity: every docs/adr/NNNN-*.md file is listed in the index table in
#      docs/adr/README.md, every index row points to an existing file, and the status shown
#      in the index matches the **Status:** line inside each ADR.
#   2. ADR numbering integrity: the ADR files run 0001..N without gaps, and every file's
#      '# ADR-NNNN' heading matches its filename (docs/adr/README.md, process rule 6).
#   3. Relative-link integrity: every relative Markdown link in every tracked .md file resolves
#      to a file or directory that exists. Links inside fenced code blocks are illustrations,
#      not claims about files on disk, and are skipped (here and in check 6); an optional link
#      title ('[text](file "title")') is not part of the path. Reference-style links
#      ('[text][label]') are not resolved — this repository uses inline links only.
#   4. Section-reference integrity: in Markdown, YAML and shell files, every section reference
#      (the section sign followed by a number, e.g. in "AGENTS.md, section 6") matches a numbered
#      '## N.' heading in AGENTS.md — the only numbered document in this repository; extend the
#      check if another one appears.
#   5. ADR-reference integrity: every 'ADR-NNNN' reference (with actual digits) names an ADR
#      file that exists in docs/adr/ — anticipated follow-ups are described by topic, never by
#      a number that does not exist yet (docs/adr/README.md, process rule 7).
#   6. ADR link agreement: a Markdown link whose text cites 'ADR-NNNN' points at that ADR's own
#      file — the number and the file it links to must name the same decision
#      (docs/adr/README.md, process rule 7).
#
# Checks 5 and 6 read every text file of the repository, not a list of documentation extensions:
# process rule 6 states that code may reference an ADR number, so a verifier restricted to
# documentation file types would leave the references most likely to go stale — those in source
# comments, which no reviewer reads alongside the ADR index — unchecked. Check 4 stays on
# documentation file types on purpose: 'ADR-NNNN' means one thing wherever it appears, but '§' in
# source code is an ordinary character (see is_doc_file), and flagging it there would make a
# project's own string literals fail this template's CI.
#
# Pure bash + coreutils/grep/sed, plus git to enumerate the repository's files — all present in
# the Dev Container base image, so running it adds no toolchain and no dependency that would
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
# this script having to guess the directory names of a toolchain the template does not yet know.
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

# is_superseded_adr <file> — true for an ADR whose status is ⚪. Superseded ADRs are immutable
# historical record (see AGENTS.md and docs/adr/README.md): they intentionally reference a past
# state that may since have been removed, so their references are frozen with the decision.
is_superseded_adr() {
  [[ "$1" == "$ADR_DIR"/* ]] && grep -m1 -F '**Status:**' "$1" | grep -q '⚪'
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

  # Parse the index into parallel arrays: filename + status emoji per row.
  local indexed_files=() indexed_status=()
  local line number target filename status
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*\[([0-9]{4})\]\(([^\)]+)\) ]] || continue
    number="${BASH_REMATCH[1]}"
    target="${BASH_REMATCH[2]}"
    filename="${target%%#*}"
    status="$(printf '%s' "$line" | first_status_emoji)"
    indexed_files+=("$filename")
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

  # Every listed file must exist, and its status must match the file.
  local i file_status
  for i in "${!indexed_files[@]}"; do
    f="${indexed_files[$i]}"
    status="${indexed_status[$i]}"
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

# Print the GitHub-style slug of every ATX heading in a Markdown file.
extract_heading_slugs() {
  local line text
  while IFS= read -r line; do
    [[ "$line" =~ ^#{1,6}[[:space:]]+(.*)$ ]] || continue
    text="${BASH_REMATCH[1]}"
    # Drop a trailing run of '#' (closed ATX headings), then slugify the way GitHub does:
    # lowercase, remove everything but [a-z0-9 _-], collapse whitespace runs to single hyphens.
    printf '%s\n' "$text" \
      | sed -E 's/[[:space:]]+#*[[:space:]]*$//' \
      | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/[^a-z0-9 _-]+//g; s/[[:space:]]+/-/g'
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
    is_superseded_adr "$md" && continue
    dir="$(dirname "$md")"
    while IFS= read -r linkexpr; do
      target="$(link_target "$linkexpr")"
      case "$target" in
        http://*|https://*|mailto:*) continue ;;
      esac
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

# Section references point into AGENTS.md, whose sections are numbered '## N.' headings.
# Inserting or removing a section renumbers the ones after it and silently invalidates such
# references — so verify that every referenced number still names an existing section. A matching
# number can still mean the wrong section; renumbering AGENTS.md requires re-checking references
# by hand.
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

  local f rel lineno match
  for f in "${TEXT_FILES[@]}"; do
    is_doc_file "$f" || continue
    rel="${f#"$ROOT"/}"
    is_superseded_adr "$f" && continue
    while IFS=: read -r lineno match; do
      n="${match#§}"
      if ! _contains "$n" "${valid_sections[@]}"; then
        add_error "$rel:$lineno: reference '$match' matches no numbered section in AGENTS.md"
      fi
    done < <(grep -noE '§[0-9]+' "$f")
  done
}

# Every 'ADR-NNNN' reference (with digits — the literal 'ADR-NNNN' placeholder never matches)
# must name an ADR file that already exists. Anticipated follow-up decisions are described by
# topic, not by a reserved number (docs/adr/README.md, process rule 7).
check_adr_refs() {
  local f rel lineno match number
  for f in "${TEXT_FILES[@]}"; do
    rel="${f#"$ROOT"/}"
    [[ "$f" == "$ADR_DIR/template.md" ]] && continue
    is_superseded_adr "$f" && continue
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
    is_superseded_adr "$f" && continue
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

collect_text_files
check_adr_index
check_adr_numbering
check_relative_links
check_section_refs
check_adr_refs
check_adr_link_targets

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
