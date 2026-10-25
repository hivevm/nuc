# Ticket: Let the frontier list only tickets the claim script accepts

## What to build

The way from a ticket's path to its branch is written twice, and the two disagree.

- `.agents/skills/work-tickets/claim.sh` accepts only `docs/plan/<spec>/<NN>-<slug>.md` whose
  names are made of `[A-Za-z0-9._-]`.
- `scripts/sensor-plan-frontier.sh` lists any `[0-9][0-9]-*.md`.

So the frontier can offer a ticket whose name has a space or a character outside that set, and
the claim then refuses it. Write the pattern and the mapping once and use them in both. Then the
sensor fails on a ticket name it cannot claim, as it already fails on a ticket it cannot place.

## Acceptance criteria

- [ ] Given a ticket file `docs/plan/x/01-a b.md`, when the frontier sensor runs, then it fails
      and names the file (a regression case).
- [ ] Given a valid ticket, when the sensor lists it and `claim.sh` claims it, then both derive
      the same branch from one definition.

## Read first

- `docs/adr/0006-feature-layer.md` (the claim; the sensor fails on a ticket it cannot place)
- `scripts/test-sensor-plan-frontier.sh`

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
