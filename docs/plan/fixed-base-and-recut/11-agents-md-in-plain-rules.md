# Ticket: `AGENTS.md` links the rules of the record and of integration and keeps the rest in plain rules

## What to build

`AGENTS.md` keeps its principles, the start, the working style, the quality bar, and secrets, in
plain rules. [§3](../../../AGENTS.md#3-adr-rules) and [§6](../../../AGENTS.md#6-project-rules) link
the `NUC-` ADRs that carry their rules and restate nothing. [§2](../../../AGENTS.md#2-start-here)
says that the binding sensor prints the `NUC-` ADRs like any other. Section numbers stay, so that
citations by anchor stay valid.

## Acceptance criteria

- [ ] Given `AGENTS.md`, when the plain-rules sensor reads it, then it reports no sentence over the
      limit and no modal verb besides *must*, *must not*, *may*.
- [ ] Given [§3](../../../AGENTS.md#3-adr-rules) and [§6](../../../AGENTS.md#6-project-rules), when
      they are read, then each rule they held is a link to its `NUC-` clause.
- [ ] Given the section references in the tree, when check 4 runs, then it passes.
- [ ] Given the word count of `AGENTS.md`, when the hand-off reports it, then it gives the count
      before and after.

## Read first

- Touches: `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), the writing rule.
- `NUC-adrs-record-decisions` and `NUC-main-only-via-pr`.

## Blocked by

- docs/plan/fixed-base-and-recut/10-old-adrs-retire.md

## Mode

with the human: the rule file binds every session, and the human reviews its wording.
