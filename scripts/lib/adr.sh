# shellcheck shell=bash disable=SC2034 # the variables are the sourcing script's
# The header of an ADR, read one way by every script that reads it: a header field is the list
# item '- **<Name>:** …' that docs/adr/template.md writes (ADR-0001). check-docs.sh fails on a
# field written in any other form, so every other reader may take the list item for granted.
# The identifier of an ADR is read one way too: its number, or the draft identifier of an ADR that
# has not reached main, 'ADR-draft-<slug>' in the file 'draft-<slug>.md' (ADR-0002).
# Sourced by every script that reads an ADR's file name, identifier, or header.

# The slug of a draft identifier: lower case letters and digits, joined by single hyphens.
ADR_SLUG_RE='[a-z0-9]+(-[a-z0-9]+)*'
# An ADR as it is cited: 'ADR-' and the key of its file, its number or 'draft-<slug>'.
ADR_NUMBER_RE='[0-9]{4}'
ADR_REF_RE="ADR-($ADR_NUMBER_RE|draft-$ADR_SLUG_RE)"
# An identifier a 'Verifies:' marker cites: an ADR, a goal, or a quality goal (ADR-0002).
ADR_ID_RE="$ADR_REF_RE|[GQ]-[0-9]+"

# The fields of docs/adr/template.md, an item's start, a field's item, a field anywhere (awk-safe).
ADR_FIELDS='Status|Date|Deciders|Applies to|Supersedes'
ADR_ITEM_RE='^- [*][*]'
ADR_FIELD_ITEM_RE="${ADR_ITEM_RE}[A-Za-z ]+:[*][*]"
ADR_FIELD_MARK_RE="[*][*]($ADR_FIELDS):[*][*]"

# adr_field_line <file, or - for stdin> <name> — the first line of the header field, or nothing.
adr_field_line() { grep -m1 -E "$ADR_ITEM_RE$2:[*][*]" "$1"; }
# adr_field_value <line> <name> — sets ADR_VALUE to what follows the field's name on the line.
adr_field_value() { ADR_VALUE="${1##*\*\*"$2":\*\*}"; }

# The names of ADR files: a numbered ADR, then a draft. ADR_FILE_RE matches the same names.
ADR_GLOBS=('[0-9][0-9][0-9][0-9]-*.md' 'draft-*.md')
ADR_FILE_RE="($ADR_NUMBER_RE-[^/]*|draft-[^/]*)\\.md"

# adr_files <dir> [draft] — every ADR file in the directory, the numbered ones in order, then the
# drafts; with 'draft', the drafts only.
adr_files() {
  local names=(-name "${ADR_GLOBS[1]}")
  [[ "${2:-}" == draft ]] || names=(\( -name "${ADR_GLOBS[0]}" -o "${names[@]}" \))
  find "$1" -maxdepth 1 -type f "${names[@]}" | LC_ALL=C sort
}

# adr_is_file <name>, adr_is_draft <file or key> — true when it names an ADR file, or a draft.
adr_is_file() { [[ "${1##*/}" =~ ^$ADR_FILE_RE$ ]]; }
adr_is_draft() { [[ "${1##*/}" == draft-* ]]; }

# adr_key_of <file> — sets ADR_KEY to what follows 'ADR-' in the identifier of the ADR file: its
# number, or 'draft-<slug>' for a draft. adr_key prints it.
adr_key_of() { if adr_is_draft "$1"; then ADR_KEY="${1##*/}" ADR_KEY="${ADR_KEY%.md}"; else ADR_KEY="${1##*/}" ADR_KEY="${ADR_KEY%%-*}"; fi; }
adr_key() { adr_key_of "$1"; printf '%s\n' "$ADR_KEY"; }

# adr_stray_fields <file> — each header field written in another form than the list item, as
# '<line number>:<line>'. The header ends at the first '## ' heading; the body may quote a field.
adr_stray_fields() {
  awk -v mark="$ADR_FIELD_MARK_RE" -v item="$ADR_ITEM_RE" '
    /^## / { exit }
    $0 ~ mark && $0 !~ item { print NR ":" $0 }
  ' "$1"
}
