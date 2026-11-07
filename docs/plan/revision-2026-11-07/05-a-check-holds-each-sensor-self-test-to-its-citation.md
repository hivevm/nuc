# Ticket: A check holds each sensor's self-test to its citation of ADR-0002

## What to build

ADR-0002 decides that each self-test of a sensor the template ships cites it. Its *Enforcement*
leaves this to review. In the plan `plain-rules-and-backlog` it slipped twice: ticket 04 shipped
`scripts/test-sensor-backlog.sh` citing ADR-0006 only, and ticket 02 added the citation in passing;
the first round of ticket 02's review found its own self-test citing ADR-0001 instead. A mistake a
check could have caught becomes a check
([`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done)).

`scripts/check-traceability.sh` fails when a `scripts/sensor-<name>.sh` has no
`scripts/test-sensor-<name>.sh`, or when that self-test carries no `Verifies:` marker citing the
ADR that decides the checks. The check does not write that identifier as a literal: it reads it
the way the other checks read identifiers, so a normalization that moves ADR-0002 moves the check
with it. ADR-0002's *Enforcement* moves the clause from review to the check, corrected in place in
a commit of ADRs only that the human reviews first
([ADR-0005](../../adr/0005-template-releases.md)).

The next release changes the form of ADR identifiers and re-cuts the template's ADRs. Where this
ticket is not worked before that, it is worked against the new form, and the correction of the
*Enforcement* rides with the re-cut.

## Acceptance criteria

- [ ] Given a fixture with a `scripts/sensor-x.sh` and no `scripts/test-sensor-x.sh`, when the
      traceability check runs, then it fails and names the sensor.
- [ ] Given a self-test of a sensor that cites another ADR only, when the check runs, then it
      fails and names the ADR it expects; a self-test that cites both passes.
- [ ] Given `scripts/test-normalize-remap.sh`, when it cycles the real tree, then the
      traceability self-test passes, so the check holds no literal identifier.
- [ ] Given ADR-0002 after its correction, when its *Enforcement* is read, then it names the
      check, and the clause is no longer review.

## Read first

- Touches: `scripts/check-traceability.sh`, `scripts/test-check-traceability.sh`,
  `docs/adr/0002-decisions-verified-by-tests.md`
- ADR-0002, *Decision* (the sensors the template ships) and *Enforcement*.
- The convention "A self-test asserts what it builds" in `docs/CONVENTIONS.md`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the correction of ADR-0002 is a commit of ADRs only that the human reviews before
the implementation, and the template has no harness ADR to answer a cap on open agent work.
