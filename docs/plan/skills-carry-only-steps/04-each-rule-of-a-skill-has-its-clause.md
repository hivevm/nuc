# Ticket: Each rule-like sentence of a skill has its clause

## What to build

An inventory of every sentence in the eight skills and their reference files that reads as a
rule. It covers a duty, a prohibition, or an imperative that binds beyond the procedure's own
order. Each sentence is paired with the clause of an ADR or the section of the rule file that
carries it, or "none". The human decides each "none": a new clause, or a restatement as a step.
A new clause is proposed in a commit of ADRs only, with the rule file and the blob list where a
line of the rule file is due. The inventory is written into ticket 05's What to build, which
applies it.

## Acceptance criteria

- [ ] Given the eight skills and their reference files, when the inventory is done, then every
  sentence that reads as a rule is listed with its file and step, and names its clause or "none".
  This covers at least each sentence with must, must not, never, only, or no, and each imperative
  aimed at another actor.
- [ ] Given the three sentences the v0.11.1 review named, when they are inventoried, then each has
  a verdict. These are the reviewer declining the implementer's reasoning (review), a ticket "with
  the human" never dispatched (work-tickets), and the reason for the claim's empty commit
  (work-tickets).
- [ ] Given each "none" the human decides as a rule, when the proposal lands, then it is a commit
  of ADRs only, plus the rule file and `docs/adr/NUC.blobs` where the rule file changes. The plain
  rules sensor reports nothing on its added lines.
- [ ] Given ticket 05's file, when it is read, then its What to build holds the
  inventory with the human's verdict on each "none".
- [ ] Given the hand-off, when the human reads it, then it names the commit of ADRs to review, the
  deviation from NUC-large-work-is-planned §4, and under *A derived project acts on* each clause
  added to a `NUC-` ADR or the rule file.

## Read first

- Touches: `.agents/skills/` (read only), `docs/adr/NUC-*.md`, `AGENTS.md`, `docs/adr/NUC.blobs`,
  `docs/plan/skills-carry-only-steps/05-the-skills-cite-their-rules.md`
- NUC-procedures-are-skills §3 and §5; NUC-documents-are-fixed §3;
  NUC-decisions-are-proposed-then-accepted §3, §4, and §6.
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), "Write a rule plainly".

## Blocked by

- docs/plan/skills-carry-only-steps/01-a-release-is-taken-up-through-its-own-skill.md
- docs/plan/skills-carry-only-steps/02-the-backlog-sensor-names-the-stale-entries.md
- docs/plan/skills-carry-only-steps/03-a-long-sentence-in-a-skill-is-reported.md

## Mode

with the human. Each "none" is the human's decision, and the ADRs are the human's to review.
