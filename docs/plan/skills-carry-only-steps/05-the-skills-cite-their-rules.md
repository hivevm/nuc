# Ticket: The skills cite their rules instead of stating them

## What to build

An agent following a skill reads, at every rule-like sentence, the clause that carries it. The
skills and their reference files change as the inventory below decided. A sentence with a clause
cites it. A sentence the human restated as a step reads as a step. A sentence whose rule moved
into a new clause cites that clause.

Ticket 04 writes the inventory below this paragraph, as a list: each sentence with its file and
step, its clause or "none", and the human's verdict on each "none".

## Acceptance criteria

- [ ] Given each entry of the inventory in What to build, when the skills are read, then the
  sentence cites its clause, or reads as a step, as the human decided.
- [ ] Given the skills before and after, when they are compared, then no step, condition, or
  order changes beyond what the inventory decided.
- [ ] Given the change, when it is inspected, then it changes no ADR. The ADR text landed in
  ticket 04.
- [ ] Given the change, when `scripts/check-all.sh` runs, then it passes. The plain rules sensor
  reports no long sentence on the lines the change adds to the skills.
- [ ] Given the hand-off, when the human reads it, then it names the deviation from
  NUC-large-work-is-planned §4, and under *A derived project acts on* the skills that changed.

## Read first

- Touches: `.agents/skills/`
- The inventory in What to build, and the clauses it names.
- NUC-procedures-are-skills §3.

## Blocked by

- docs/plan/skills-carry-only-steps/03-a-long-sentence-in-a-skill-is-reported.md
- docs/plan/skills-carry-only-steps/04-each-rule-of-a-skill-has-its-clause.md

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
