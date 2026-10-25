# Ticket: Draft where the take-up of a template release lives

## What to build

A draft for the maintainer, written through `propose-adr`, on two gaps that met in the
`normalize` skill.

- **ADR-0003 does not name `normalize`.** Its Decision lists the procedures it keeps as skills:
  developing an ADR, planning, working tickets, reviewing, revising the design, and the setup walk.
  `normalize` carries the procedure of [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) rule 5, and
  the list does not name it.
- **The take-up of a release sits in `normalize`, but is not a normalization.** ADR-0005 lists a
  procedure for taking up the files of a release under *Follow-ups*. That procedure now lives
  under the skill's "A template release" entry, and its steps for hooks, settings, and scripts
  have nothing to do with restating the record. `README.md` → Template points at it.

Options:

1. Correct ADR-0003 in place to name `normalize` and the take-up.
2. Split the take-up into a skill of its own, which ADR-0005's follow-up asks for, with
   `normalize` keeping only the record's part.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then ADR-0003's list names every skill
      under `.agents/skills/`, and the take-up of a release has one home.
- [ ] Given the decision, when ADR-0005's *Follow-ups* is read, then it no longer lists what is
      done.

## Read first

- `docs/adr/0003-procedures-as-skills.md`, `docs/adr/0005-template-releases.md` (in full)
- `.agents/skills/normalize/SKILL.md`; the take-up section of the release notes of v0.4.0 (pull
  request #10)

## Blocked by

- None (can start immediately)

## Mode

with the human: a decision on accepted ADRs, which only the maintainer takes.
