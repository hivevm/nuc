# Ticket: Modal verbs and avoided terms become checks on the project's own rules

## What to build

The backlog entry docs/backlog/avoided-terms-become-a-check.md, together with the modal verbs. A
check fails on a modal verb other than *must*, *must not*, *may*, and on an avoided term of the
glossary, in an added rule of the project's own text. It spares the `NUC-` files. The glossary
reader parses qualifiers in an *Avoid* item, such as "shape alone", or reports what it cannot parse.
Sentence length stays a sensor. The ADR that decides the plain-rules checks names them in its
*Enforcement*, as a revision of ADRs only. The branch deletes the backlog entry.

## Acceptance criteria

- [ ] Given a project ADR whose added *Decision* sentence uses *should*, when the check runs, then
      it fails and names the line; given the same sentence in a `NUC-` file, then it passes.
- [ ] Given a glossary item "*shape* alone" under *Avoid*, when the reader parses it, then it reads
      the term with its qualifier; given an item it cannot parse, then it says so.
- [ ] Given comb's glossary and its `NUC-` files after a take-up, when the check runs on a fixture
      built from them, then it passes.
- [ ] Given check-docs after this ticket, when its checks are counted, then the count has not risen
      above the baseline of the spec.

## Read first

- Touches: `scripts/sensor-plain-rules.sh`, `scripts/lib/rules.sh`, `scripts/check-docs.sh`,
  `scripts/test-check-docs.sh`, `docs/GLOSSARY.md`, `docs/backlog/`
- The backlog entry above.
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), the writing rule.

## Blocked by

- docs/plan/fixed-base-and-recut/10-old-adrs-retire.md

## Mode

with the human: the revision of the ADR goes to the human before the implementation.
