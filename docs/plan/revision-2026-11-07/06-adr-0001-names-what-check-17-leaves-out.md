# Ticket: ADR-0001's Enforcement names what check 17 leaves out

## What to build

Check 17 of `scripts/check-docs.sh` does not read a word in a code span or in italics, because a
rule names a word there; its header says so. ADR-0001's *Enforcement* says the check fails on a
listed word on an added line, and does not name the exemption. A reader of the ADR expects a
failure the check never gives. The review of ticket 03 of the plan `plain-rules-and-backlog` left
this as a nit.

The *Enforcement* of ADR-0001 names the exemption, corrected in place in a commit of ADRs only
that the human reviews ([ADR-0005](../../adr/0005-template-releases.md)). Ticket
`03-the-rules-reader-reads-inline-markdown-as-a-reader-does.md` decides which italics count, so
the wording follows it.

The next release re-cuts the template's ADRs. Where this ticket is not worked before that, the
sentence rides with the re-cut and this file is deleted there.

## Acceptance criteria

- [ ] Given ADR-0001 after the correction, when its *Enforcement* is read beside the header of
      check 17, then both name the same words the check does not read.
- [ ] Given the commit of the correction, when it is read, then it changes ADR text only, and
      `scripts/check-all.sh` is green.

## Read first

- Touches: `docs/adr/0001-agent-governance-model.md`
- The header of `scripts/check-docs.sh`, check 17.
- ADR-0005, *Decision*: the template corrects its own ADRs in place.

## Blocked by

- docs/plan/revision-2026-11-07/03-the-rules-reader-reads-inline-markdown-as-a-reader-does.md

## Mode

with the human: a correction of an ADR is the human's to review before it lands.
