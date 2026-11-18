# Ticket: The pin check of the hooks reads its cases from a table, and a check holds every check to one

## What to build

`scripts/check-hooks.sh` landed with ticket 02 of `hooks-run-nuc` (275a964) and its 22 cases
written into the code of `scripts/test-check-hooks.sh`. No table under `scripts/fixtures/` holds
them, against the convention "A check's cases are a table" of `docs/CONVENTIONS.md`: a new check
writes its cases into a table before its code, so that a port of the checks is held to the same
cases. The checks `check-devcontainer.sh`, `check-docs.sh`, `check-shell.sh`, and
`check-traceability.sh` each have one. No check noticed the missing table, so the mistake becomes
a check
([`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done)).

Two parts:

- The cases of `scripts/test-check-hooks.sh` move into `scripts/fixtures/check-hooks.txt`, in the
  form of the other tables and with a header that says all a port reads from it, and the self-test
  reads them through `table_holds` of `scripts/lib/selftest.sh`. Each case expects a key and the
  data of its finding, never its wording. The cases stay as they are: none is dropped, and the
  count of cases does not fall.
- A rule of a check fails on a check `scripts/check-<name>.sh`, `scripts/check-all.sh` aside,
  for which no table `scripts/fixtures/check-<name>*.txt` exists, or whose self-test does not
  read one. The rule has a key and its own cases in a table, as the convention asks. Where it
  stands, beside `docs/check-lists` in `scripts/check-docs.sh` or elsewhere, is the session's to
  argue in the hand-off.

Once the rule holds, the convention keeps only what no check decides: that the table comes before
the code, and that a case expects a key and data, not wording. The ticket trims the entry to that,
inline.

## Acceptance criteria

- [ ] Given the tree, when `scripts/test-check-hooks.sh` runs, then it reads every case from
      `scripts/fixtures/check-hooks.txt` and passes at least the 22 cases it passes today.
- [ ] Given a fixture with a check `scripts/check-x.sh` and its self-test, but no table
      `scripts/fixtures/check-x*.txt`, when the new rule runs, then it fails and ends its line in
      its key.
- [ ] Given a fixture whose table exists but whose self-test does not name it, when the rule runs,
      then it fails.
- [ ] Given this repository, when `scripts/check-all.sh` runs, then the rule passes on all five
      checks.
- [ ] Given `docs/CONVENTIONS.md`, when the entry "A check's cases are a table" is read, then it
      states nothing the rule decides.

## Read first

- Touches: `scripts/test-check-hooks.sh`, `scripts/fixtures/check-hooks.txt`,
  `scripts/lib/selftest.sh`, the check that carries the rule and its self-test and table,
  `docs/CONVENTIONS.md`, `CONTRIBUTING.md` (the rule's place in the docs check's list, where it
  goes there)
- `docs/CONVENTIONS.md`: "A check's cases are a table" and "A self-test asserts what it builds".
- `scripts/fixtures/check-devcontainer.txt` and `scripts/test-check-devcontainer.sh`, the pattern
  to copy.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and a new rule
of a shipped check binds every derived project's own checks named `scripts/check-*.sh`. A test
decides each criterion, and a wrong result costs one revert. Stop and hand off when a case of the
self-test cannot be stated in the notation of the tables.
