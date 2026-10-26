# shellcheck shell=bash
# The header of an ADR, read one way by every script that reads it: a header field is the list
# item '- **<Name>:** …' that docs/adr/template.md writes (ADR-0001). check-docs.sh fails on a
# field written in any other form, so every other reader may take the list item for granted.
# Sourced by scripts/check-docs.sh, scripts/check-traceability.sh, and
# scripts/sensor-binding-adrs.sh.

# shellcheck disable=SC2034 # ADR_ID_RE is the sourcing script's
# An identifier a 'Verifies:' marker cites: an ADR, a goal, or a quality goal (ADR-0002).
ADR_ID_RE='ADR-[0-9]{4}|[GQ]-[0-9]+'

# The header fields of docs/adr/template.md.
ADR_FIELDS='Status|Date|Deciders|Applies to|Supersedes'

# adr_field_line <file, or - for stdin> <name> — the first line of the header field, or nothing.
adr_field_line() { grep -m1 -E "^- \*\*$2:\*\*" "$1"; }

# adr_stray_fields <file> — each header field written in another form than the list item, as
# '<line number>:<line>'. The header ends at the first '## ' heading; the body may quote a field.
adr_stray_fields() {
  awk -v fields="$ADR_FIELDS" '
    /^## / { exit }
    $0 ~ "\\*\\*(" fields "):\\*\\*" && $0 !~ /^- \*\*/ { print NR ":" $0 }
  ' "$1"
}
