# Ticket: The backlog sensor names the stale entries

## What to build

An agent running a design revision of a project whose backlog is files asks the backlog sensor
which entries are stale, by the definition of NUC-design-is-revised §6. The sensor gains a mode
that lists each stale entry with the date it was added and the two dates of the
`Last design revision` line it predates. It reads those dates from the history of the
architecture overview on main. The design revision's step 7 runs that mode for a backlog of
files, and keeps its steps for a backlog in the host's issues.

## Acceptance criteria

- [ ] Given an entry added before two dates of the `Last design revision` line, when the sensor
  runs in the new mode, then it lists the entry with its date and the two dates.
- [ ] Given an entry added before only one date, when the sensor runs, then it does not list it.
- [ ] Given a line whose two newest dates are one day with an ordinal, such as `(2)`, when the
  sensor runs, then each counts as a date of its own.
- [ ] Given a commit that edits the line but keeps its date, such as one that changes only the
  number of changes, when the sensor runs, then that commit adds no date.
- [ ] Given a line that has read fewer than two dates, or reads `none yet`, when the sensor runs,
  then it lists no entry as stale and says why.
- [ ] Given an entry added before two dates and deleted in a later commit, when the sensor runs,
  then it does not list it.
- [ ] Given the new mode's cases, when the self-test runs, then it reads them from a fixture
  table. The existing cases pass unchanged, and the sensor still exits 0.
- [ ] Given the design revision's step 7, when it is read, then a backlog of files is proposed
  from the sensor's mode and no longer from git commands. A backlog in the host's issues keeps its
  steps, and no other step changes.
- [ ] Given the hand-off, when the human reads it, then it names the deviation from
  NUC-large-work-is-planned §4, and under *A derived project acts on* the sensor's new mode.

## Read first

- Touches: `scripts/sensor-backlog.sh`, `scripts/test-sensor-backlog.sh`,
  `scripts/fixtures/backlog.txt`, `.agents/skills/design-revision/SKILL.md`
- NUC-design-is-revised §4 and §6; NUC-checks-are-bash.
- The conventions' entries "A self-test asserts what it builds" and "A check's cases are a table".
- The golden path: `scripts/sensor-revision-due.sh`, which reads the same line, and
  `scripts/fixtures/plain-rules.txt` with its self-test, for a table.

## Blocked by

- None (can start immediately)

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
