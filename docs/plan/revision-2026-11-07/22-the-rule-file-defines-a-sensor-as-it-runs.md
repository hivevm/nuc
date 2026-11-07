# Ticket: The rule file defines a sensor as the suite runs one

## What to build

[`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) says "A sensor is a script
that reports and fails nothing". `scripts/sensor-plain-rules.sh --require` fails, as
[NUC-documents-are-fixed §5](../../adr/NUC-documents-are-fixed.md) decides in its *Enforcement*,
and `scripts/check-all.sh` runs it that way under the label of a sensor, so its green line reads
`sensor:` and a session takes its failure for a sensor's. Clause 4 of NUC-checks-are-bash already
allows a decision to turn a sensor into a check.

The sentence in `AGENTS.md` follows clause 4: a sensor reports, and fails only where a decision
makes it a check. `scripts/check-all.sh` labels a run with `--require` as a check.

## Acceptance criteria

- [ ] Given [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done), when it is
      read against [NUC-checks-are-bash §4](../../adr/NUC-checks-are-bash.md), then the two agree.
- [ ] Given a green run of `scripts/check-all.sh`, when it prints the plain-rules run, then the
      line starts `ok:` like any check's.
- [ ] Given `scripts/test-check-all.sh`, when it runs, then a case pins the label.

## Read first

- Touches: `AGENTS.md`, `scripts/check-all.sh`, `scripts/test-check-all.sh`

## Blocked by

- None (can start immediately)

## Mode

unattended: the criteria decide it; stop after two failed attempts and hand off with the state
written here.
