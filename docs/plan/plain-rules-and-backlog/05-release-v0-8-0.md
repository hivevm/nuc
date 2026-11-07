# Ticket: Release v0.8.0

## What to build

The minor release `v0.8.0` of the template, as ADR-0005 decides. The release notes say what a
derived project takes up and what it may leave:

- the writing rule and its sensor, which fails nothing;
- check 17, silent until the project fills _Avoid:_ in its glossary;
- the backlog, a choice the project records in an ADR of its own, and its sensor;
- the corrections of ADR-0001 and ADR-0006 in place, by clause.

The spec of this plan closes by a design revision before the release
([`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done)). The revision sensor
reports a revision due as well. This one revision covers both: the modules the tickets touched,
and the changes the sensor counts since the last revision. No revision runs before ticket 01.

## Acceptance criteria

- [ ] Given tickets 01 to 04 merged into the `feat/` branch, when the design revision runs, then it
      covers the tickets' modules and the changes the revision sensor counts, deletes the spec,
      moves the `Last design revision` line, and files what it finds.
- [ ] Given the release notes, when a maintainer of a derived project reads them, then each change
      says whether it must act, may act, or need not.
- [ ] Given the release, when `scripts/check-all.sh` runs on the tagged tree, then it is green.

## Read first

- Touches: `README.md` (the `Template release` line), the release notes
- `docs/adr/0005-template-releases.md`, *Decision*: what a minor is and what the notes say.
- The last release, `v0.7.0`, as the golden path of a release change.

## Blocked by

- docs/plan/plain-rules-and-backlog/01-every-script-reads-adr-identifiers-through-the-library.md
- docs/plan/plain-rules-and-backlog/02-rules-are-written-plainly.md
- docs/plan/plain-rules-and-backlog/03-a-check-refuses-a-displaced-synonym-in-a-new-rule.md
- docs/plan/plain-rules-and-backlog/04-a-finding-outside-the-plan-goes-to-the-backlog.md

## Mode

with the human: a release is the human's to cut and push.
