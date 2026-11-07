# Ticket: Check 17 and the plain-rules sensor fail when their reader breaks

## What to build

`rule_stream` in `scripts/lib/rules.sh` runs an awk program per file inside a loop, and check 17
of `scripts/check-docs.sh` reads its output through a process substitution. Neither status is
read. While the underscore italics were added, a syntax error in that awk program printed its
error on stderr, and check 17 reported "Documentation checks passed" on a change it had to
fail. A check that cannot read what it decides passes nothing
([`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done)).

`rule_stream` returns non-zero when a reader it runs fails, and check 17 adds an error naming
the file when it does. The plain-rules sensor, which fails nothing on what it counts, exits 2
on a broken reader, as it does on a base that does not resolve.

## Acceptance criteria

- [ ] Given a reader that exits non-zero, when check 17 runs on a change to `AGENTS.md`, then it
      fails and says it could not read the rules.
- [ ] Given the same, when the plain-rules sensor runs, then it exits 2 with a message.
- [ ] Given a working reader, when both run, then their output is unchanged.

## Read first

- Touches: `scripts/lib/rules.sh`, `scripts/check-docs.sh` (check 17),
  `scripts/sensor-plain-rules.sh`, `scripts/test-check-docs.sh`,
  `scripts/test-sensor-plain-rules.sh`
- Ticket `01-a-pipeline-whose-status-is-read-ends-in-no-early-reader.md`: the same family of
  defect, a status no one reads.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
