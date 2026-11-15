# Ticket: Each rule-like sentence of a skill has its clause

## What to build

An inventory of every sentence in the skills that reads as a duty or a prohibition, each paired
with the clause of an ADR or the section of AGENTS.md that carries it, or "none". The human
decides each "none": a new clause, or a restatement as a step. A new clause is proposed in a
commit of ADRs only, with AGENTS.md and the blob list where a line of the rule file is due. The
inventory is the hand-off. Ticket 05 changes the skills.

## Acceptance criteria

- [ ] Given the seven skills, plus the take-up skill if ticket 02 has landed, when the inventory
  is done, then every sentence with a duty or a prohibition is listed with its skill and step.
  These are sentences with must, must not, never, only, or no. Each names its clause or "none".
- [ ] Given at least the three sentences the v0.11.1 review named, when they are inventoried,
  then each has a verdict. These are the reviewer declining the implementer's reasoning, a ticket
  "with the human" never dispatched, and the reason for the claim's empty commit.
- [ ] Given each "none" the human decides as a rule, when the proposal lands, then it is a
  commit of ADRs only, plus AGENTS.md and `docs/adr/NUC.blobs` where the rule file changes. The
  plain rules sensor reports nothing on its added lines.
- [ ] Given the hand-off, when the human reads it, then it names the commit of ADRs to review
  and the inventory, and says for each "none" what the human decided.

## Read first

- Touches: `.agents/skills/*/SKILL.md` (read only), `docs/adr/NUC-*.md`, `AGENTS.md`,
  `docs/adr/NUC.blobs`
- NUC-procedures-are-skills §3; NUC-documents-are-fixed §3;
  NUC-decisions-are-proposed-then-accepted §3, §4, §6.
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), "Write a rule plainly".

## Blocked by

- docs/plan/skills-carry-only-steps/02-a-release-is-taken-up-through-its-own-skill.md

## Mode

with the human. Each "none" is the human's decision, and the ADRs are the human's to accept.
