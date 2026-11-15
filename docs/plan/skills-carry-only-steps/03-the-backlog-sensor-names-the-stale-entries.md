# Ticket: The backlog sensor names the stale entries

## What to build

An agent running a design revision asks the backlog sensor which entries are stale, by the
definition of NUC-design-is-revised §6. The sensor gains a mode that lists each stale entry with
the date it was added and the two dates of the `Last design revision` line it predates. The design
revision's step 7 runs that mode instead of its git commands and proposes the entries it lists.

## Acceptance criteria

- [ ] Given a backlog entry added before two dates of the `Last design revision` line and no
  ticket made from it, when the sensor runs in the new mode, then it lists the entry with its
  date and the two dates.
- [ ] Given an entry added before only one date, when the sensor runs, then it does not list it.
- [ ] Given a line whose two newest dates are one day with an ordinal, such as `(2)`, when the
  sensor runs, then each counts as a date of its own.
- [ ] Given a line that has read fewer than two dates, or reads `none yet`, when the sensor runs,
  then it lists no entry as stale and says why.
- [ ] Given a stale entry whose ticket was made from it, when the sensor runs, then it does not list
  it. The ticket's commit deleted the entry (NUC-large-work-is-planned §8), so the case is an
  entry that no longer exists.
- [ ] Given the existing cases of the sensor's fixture table, when its self-test runs, then each
  passes unchanged, and the sensor still exits 0.
- [ ] Given the design revision's step 7, when it is read, then it runs the sensor's mode and no
  longer spells out the git commands. No other step changes.

## Read first

- Touches: `scripts/sensor-backlog.sh`, `scripts/test-sensor-backlog.sh`,
  `scripts/fixtures/` (the backlog sensor's table, if it has one),
  `.agents/skills/design-revision/SKILL.md`
- NUC-design-is-revised §4 and §6; NUC-checks-are-bash.
- The conventions' entries "A self-test asserts what it builds" and "A check's cases are a table".
- The golden path: `scripts/sensor-revision-due.sh`, which reads the same line.

## Blocked by

- None (can start immediately)

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
