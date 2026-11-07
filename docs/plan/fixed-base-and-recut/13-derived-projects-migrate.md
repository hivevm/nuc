# Ticket: A derived project migrates by a map, proven on nectar and on the parity corpus

## What to build

The map that a derived project applies at take-up. It ships with the release: every clause of
ADR-0001 to ADR-0006 to the `NUC-` ADR that carries it. The normalize skill's take-up steps become:
replace the `NUC-` files and the blob list; write a map of the project's numbered ADRs to category
identifiers, which the human reviews; turn each clause the project added to an inherited ADR into a
project ADR that extends or narrows the `NUC-` clause; run the remap script and the checks.

The remap script runs dry over the parity corpus of nuc-tools. A trial migration runs on a local
branch of nectar and is not pushed. Both results stand in the hand-off.

## Acceptance criteria

- [ ] Given the parity corpus of nuc-tools, when the remap script runs on it with `--check`, then it
      reports each reference it cannot decide, and nothing else fails.
- [ ] Given nectar on a local branch, when the take-up steps run, then `scripts/check-all.sh` is
      green there, and the hand-off lists every step that needed a hand edit.
- [ ] Given the normalize skill, when its take-up section is read, then it carries the steps above
      and states no rule of its own.

## Read first

- Touches: `.agents/skills/normalize/`, `scripts/test-normalize-remap.sh`
- The clause table of ticket 10.
- The parity corpus in the nuc-tools repository; nectar's record and its inherited ADRs.

## Blocked by

- docs/plan/fixed-base-and-recut/11-agents-md-in-plain-rules.md
- docs/plan/fixed-base-and-recut/12-plain-rules-become-checks.md

## Mode

with the human: the trial works in another repository, and its findings may change the steps.
