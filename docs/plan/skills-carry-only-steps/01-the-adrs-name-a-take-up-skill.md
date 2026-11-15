# Ticket: The ADRs name a skill of its own for the take-up of a release

## What to build

The correction of the template's ADRs that lets the take-up of a release leave the normalize
skill. NUC-procedures-are-skills §1 names a take-up skill among the skills and no longer says
normalize carries the take-up. NUC-releases-are-semver-tags names that skill where it names the
take-up's order of work. The correction is proposed in a commit of ADRs only and handed to the
human, who reviews it before ticket 02 moves the skill.

## Acceptance criteria

- [ ] Given the two ADRs on `feat/v0.12.0`, when the correction lands, then
  NUC-procedures-are-skills §1 lists the take-up skill by its name and says normalize carries
  normalization and adoption.
- [ ] Given NUC-releases-are-semver-tags, when the correction lands, then every sentence that
  names normalize as the take-up's place names the take-up skill instead, and no clause changes
  its meaning.
- [ ] Given the commit, when it is inspected, then it changes nothing outside `docs/adr/` but the
  blob list `docs/adr/NUC.blobs`, rewritten in the same commit.
- [ ] Given the commit, when `scripts/check-all.sh` runs, then it passes. The plain rules sensor
  reports no soft modal verb or avoided word on the added lines.
- [ ] Given the hand-off, when the human reads it, then it names the commit of ADRs to review
  and the deviation from NUC-large-work-is-planned §4 the spec records.

## Read first

- Touches: `docs/adr/NUC-procedures-are-skills.md`, `docs/adr/NUC-releases-are-semver-tags.md`,
  `docs/adr/NUC.blobs`
- The `propose-adr` skill, steps 3 and 4; NUC-decisions-are-proposed-then-accepted §3, §4, and §6
  (the template corrects its own `NUC-` ADRs in place).
- The spec's Implementation decisions, "Take-up skill" and "Way of working".
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), "Write a rule plainly".

## Blocked by

- None (can start immediately)

## Mode

with the human. It changes accepted `NUC-` ADRs, which only the human accepts.
