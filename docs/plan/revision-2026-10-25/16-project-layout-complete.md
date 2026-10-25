# Ticket: Make the Project Layout name every top-level part, and check that it does

## What to build

`docs/ARCHITECTURE.md` is the derived project's scaffold. In the template, the map of the
template's own parts is `README.md` → Project Layout, which `TEMPLATE-SETUP.md` calls the
inventory of "the files". It is incomplete, and check 10 of `scripts/check-docs.sh` tests only
that what it lists exists, not that what exists is listed.

- **Missing top-level files and directories:** `CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, `LICENSE`, `.gitignore`, and `docs/plan/` (open work, which exists only
  while there is some; ADR-0006).
- **Missing parts:** the families of scripts are not described anywhere apart from the header of
  `checks.yml`. That covers `check-*`, `sensor-*` (with the settings sensor run by hand),
  `test-*`, and `scripts/lib/`. The same holds for the scripts and templates that the skills
  carry (`claim.sh`, `remap.sh`, `spec.md`, `ticket.md`) and for the two workflows.

Add the missing entries, one line each, and the reverse direction to check 10: a tracked
top-level entry that the block does not name fails. `docs/plan/` is named although it is absent
on a clean `main`.

## Acceptance criteria

- [ ] Given a fixture with a new tracked top-level file the block does not name, when
      `check-docs.sh` runs, then check 10 fails and names it.
- [ ] Given the template's tree, when `check-docs.sh` runs, then check 10 passes with
      `docs/plan/` named and absent.
- [ ] Given the block, when a reader looks for where the checks, sensors, and self-tests live,
      then one line each says it.

## Read first

- `docs/adr/0001-agent-governance-model.md` (the overview; links that resolve)
- `README.md` → Project Layout; `TEMPLATE-SETUP.md` (the Project Layout stays as-is in a
  derived project)
- check 10 of `scripts/check-docs.sh` and its cases in `scripts/test-check-docs.sh`

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
