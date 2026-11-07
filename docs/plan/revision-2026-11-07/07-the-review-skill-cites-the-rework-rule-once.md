# Ticket: The review skill cites the rework rule once

## What to build

[`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) states that a rework
replaces the commits a review saw, so the review that binds after one is of the whole branch at
its head. The `review` skill restates it three times: in its list of inputs, in the paragraph on
a second review, and in the hand-back. A skill cites a rule and states none of its own
([ADR-0003](../../adr/0003-procedures-as-skills.md)), and each restatement is one more place a
change to the rule must find (the convention "A rule changes everywhere it is stated" in
`docs/CONVENTIONS.md`).

The skill keeps the steps a reviewer takes and cites the rule once, where the step that depends on
it stands. The lines of the skill fall.

## Acceptance criteria

- [ ] Given `.agents/skills/review/SKILL.md` after the change, when it is searched for "whole
      branch", then one sentence holds it, and it links the rule.
- [ ] Given the skill before and after, when the human reads both, then no step a reviewer takes
      is lost.
- [ ] Given `scripts/check-all.sh`, when it runs, then it is green.

## Read first

- Touches: `.agents/skills/review/SKILL.md`
- [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done), the review bullet;
  ADR-0003, *Decision*.

## Blocked by

- None (can start immediately)

## Mode

with the human: no test decides whether a step was lost, so the human judges the wording.
