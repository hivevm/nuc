# Ticket: Read an ADR's header one way in every script

## What to build

The scripts read an ADR's `Status` and `Applies to` in two dialects that disagree:

- `scripts/check-docs.sh` and `scripts/check-traceability.sh` find `**Status:**` anywhere on a
  line.
- `scripts/sensor-binding-adrs.sh` takes only `^- **Status:**` and `^- **Applies to:**`.

A Status line that is no list item therefore passes the documentation check, and the
binding-ADRs sensor silently passes its ADR over.

Three scripts decide in force or not from the bullet, each in its own way. The identifier
expressions of `check-traceability.sh` (`ID_RE`) and of `.agents/skills/normalize/remap.sh` are
two copies.

Decide one reading: the list item, as `docs/adr/template.md` writes it. Put it in one helper of
`scripts/lib/` and make the documentation check fail on a header line in any other form. The
other readers can then trust it.

## Acceptance criteria

- [ ] Given an ADR whose Status line is no list item, when `check-docs.sh` runs, then it fails
      and names the line (a regression case, red before the fix).
- [ ] Given an accepted ADR whose *Applies to* names a touched path, when
      `sensor-binding-adrs.sh` runs, then it lists the ADR. The self-test asserts this through
      the shared reader.
- [ ] Given the shared reader, when `git grep` searches for the old Status and identifier
      expressions, then each lives in one place.

## Read first

- `docs/adr/README.md` → Mechanics; `docs/adr/template.md`
- `docs/adr/0001-agent-governance-model.md` (Enforcement: the record and its index agree)
- ticket 04 of this directory, which adds `scripts/lib/` helpers alongside

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
