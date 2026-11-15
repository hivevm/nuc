# Ticket: The skills cite their rules instead of stating them

## What to build

An agent following a skill reads, at every rule-like sentence, the clause that carries it. The
skills change as the inventory of ticket 04 decided. A sentence with a clause cites it. A
sentence the human restated as a step reads as a step. A sentence whose rule moved into a new
clause cites that clause.

## Acceptance criteria

- [ ] Given each entry of the inventory, when the skills are read, then the sentence cites its
  clause, or reads as a step, as the human decided.
- [ ] Given the skills before and after, when they are compared, then no step, condition, or
  order changes beyond what the inventory decided.
- [ ] Given the change, when it is inspected, then it changes no ADR. The ADR text landed in
  ticket 04.
- [ ] Given the change, when `scripts/check-all.sh` runs, then it passes.

## Read first

- Touches: `.agents/skills/*/SKILL.md`
- The inventory in ticket 04's hand-off, and the clauses it names.
- NUC-procedures-are-skills §3.

## Blocked by

- docs/plan/skills-carry-only-steps/04-each-rule-of-a-skill-has-its-clause.md

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
