# Ticket: Move closing and listing the setup out of its self-test into a script of the setup skill

## What to build

`scripts/test-template-setup.sh` has widened into three things: a self-test, a lister
(`--open`), and a mutator (`--close`).

- `close_setup` deletes files, deletes the script itself, and edits `scripts/check-all.sh` and
  `.github/workflows/checks.yml` by line pattern. A self-test writes to the gate.
- The `run "label" scripts/x.sh` line of `check-all.sh` now has three readers: check 9 of
  `check-docs.sh`, `needs_run` in `check-all.sh`, and this edit.
- The template's title pattern sits in both `check-docs.sh` and this file.

ADR-0003 lets a skill carry a script whose order of commands decides its outcome, as `claim.sh`
and `remap.sh` do. Listing and closing the setup become such a script of `setup-project`, for
example `.agents/skills/setup-project/setup.sh open|close`. It is deleted together with the
skill. `test-template-setup.sh` then only tests it.

`TEMPLATE-SETUP.md`, the skill, and the README's notes are rewired to the new path. A derived
project still in setup takes this up with the release, so it goes into the release notes.

## Acceptance criteria

- [ ] Given a copy of the template after step 1, when the new script runs `close`, then it
      leaves the same tree that `test-template-setup.sh --close` leaves today (the existing
      case 4, pointed at the new script).
- [ ] Given the template's own tree, when it runs `close`, then it refuses, as today.
- [ ] Given `test-template-setup.sh`, when it is read, then it carries no option beyond the
      self-test's own.

## Read first

- `docs/adr/0003-procedures-as-skills.md` (a script a step runs; its self-test under `scripts/`)
- `TEMPLATE-SETUP.md` steps 1, 6, 7; `.agents/skills/setup-project/SKILL.md`
- `.agents/skills/work-tickets/claim.sh` and `scripts/test-sensor-plan-frontier.sh`, the golden
  path of a skill script with its self-test

## Blocked by

- None (can start immediately)

## Mode

with the human: it changes the interface `TEMPLATE-SETUP.md` and the release notes of v0.4.0 name.
The template has no harness ADR for an unattended run.
