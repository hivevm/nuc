# Ticket: Say one thing about how a claim is made and released

## What to build

The claim is described three ways, and they disagree:

- **[`AGENTS.md` §6](../../../AGENTS.md#6-project-rules):** "A claim reserves a ticket by creating
  its branch, with an empty commit and nothing else". The claim among sessions that share a
  repository has no commit: ADR-0006 says it "needs no commit and nothing pushed", and `claim.sh`
  uses `git branch` there.
- **ADR-0006:** "a claim given up is released by a human deleting its branch".
- **The `work-tickets` skill and the header of `claim.sh`:** a session deletes a local claim, and
  only the deletion on a remote goes to the human.

Draft, through `propose-adr`, which of the last two holds. If the session may release a local
claim, ADR-0006 is corrected in place (ADR-0005). If not, the skill and the script header are
corrected. Then correct the AGENTS.md sentence to cover both forms of the claim, for example:
"A claim reserves a ticket by creating its branch and nothing else; across clones, with an empty
commit".

## Acceptance criteria

- [ ] Given the decision, when [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules), ADR-0006, the
      skill, and `claim.sh` are read, then they say the same about both forms of the claim and about
      who releases one.
- [ ] Given the local claim, when `scripts/test-sensor-plan-frontier.sh` runs, then a case
      asserts that it creates no commit.

## Read first

- `docs/adr/0006-feature-layer.md` (Decision: the claim)
- [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules); `.agents/skills/work-tickets/SKILL.md` step
  3; `claim.sh`

## Blocked by

- None (can start immediately)

## Mode

with the human: it decides on the text of an accepted ADR and of the rule file.
