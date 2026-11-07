# Ticket: An ADR is identified by its category and a slug, picked when the file is created

## What to build

The tracer bullet. An agent creates `docs/adr/NUC-adrs-record-decisions.md` with its identifier in
the heading and file name, and every check of the record accepts it. The ADR is proposed in a commit
of ADRs only before anything is implemented. It restates
[`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) and the mechanics of the ADR index, and decides the
identifiers, the fixed base, and the roles. This ticket implements its clauses on identifiers;
ticket 02 implements the fixed base and the roles.

The ADR library reads both forms, `ADR-NNNN` and `CAT-slug`, until ticket 10 retires the old one.
Check-docs holds the new form: the pattern, a category in the list of the index, and an identifier
unique over the tree and over the deleted ADRs in the history. The draft state goes: check 16 and
`scripts/number-adrs.sh` with its self-test leave the tree, and checks 1, 2, 5, 6, and 8 read the
new form. The index gains the category list.

Each changed check gets its fixture table first, and the bash self-test reads it.

## Acceptance criteria

- [ ] Given the ADR `NUC-adrs-record-decisions`, when the human reads its commit, then that commit
      changes ADRs only and comes before every commit that implements it.
- [ ] Given a file `docs/adr/SEC-host-socket-closed.md` whose heading names that identifier, when
      check-docs runs, then it passes; given `SEC-Host_socket` or a category not in the list, then
      it fails and names the file.
- [ ] Given an identifier that a deleted ADR in the history carried, when a new file takes it, then
      check-docs fails and names the commit that deleted it.
- [ ] Given a reference `SEC-x §3` to an existing ADR, when checks
      5 and 6 run, then they pass; given a reference to a missing identifier, then they fail.
- [ ] Given the tree after this ticket, when `scripts/check-all.sh` runs, then it is green with the
      old ADRs still in place, and neither check 16 nor the numbering script exists.
- [ ] Given each changed check, when its self-test runs, then it reads the cases from a fixture
      table in the tree.

## Read first

- Touches: `docs/adr/`, `docs/adr/README.md`, `docs/adr/template.md`, `scripts/lib/adr.sh`,
  `scripts/check-docs.sh`, `scripts/test-check-docs.sh`, `scripts/number-adrs.sh`,
  `scripts/test-number-adrs.sh`, `scripts/check-all.sh`, `.github/workflows/checks.yml`,
  `.agents/skills/propose-adr/`
- [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) and the *Mechanics* of `docs/adr/README.md`: what
  the new ADR restates.
- The spec's *Implementation decisions*, items *Identifiers* and *Form*.
- Golden path: the readers in `scripts/lib/adr.sh`, and the fixture style of
  `scripts/test-check-docs.sh`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the ADR is a new decision that the human reviews before the implementation.
