# Ticket: Rules are written plainly, and a sensor reports long sentences and soft modal verbs

## What to build

The rule file gains a working-style rule on how a rule is written: one statement per sentence;
active, with a subject; in the terms of the glossary; a list where there are several items. It
covers the rules of the rule file and the *Decision* and *Enforcement* sections of an ADR. The
ADR README points at it. The review skill asks, in its report on the bar, whether each new
statement is one sentence.

A new sensor reads the lines a change adds to those sections. It reports each sentence over 25
words and each use of *should*, *could*, *might*, or *ideally*. Code spans, links, and block quotes
do not count. It reads the sections as the binding sensor extracts them. It fails nothing. It
runs in the sensors job and in `scripts/check-all.sh`, with its self-test first.

The rule is the tracer bullet of this spec: the check of ticket 03 enforces a part of it.

## Acceptance criteria

- [ ] Given a change that adds a 30-word sentence to the *Decision* of an ADR, when the sensor runs,
      then it lists the file, the line, and the word count, and exits 0.
- [ ] Given a change that adds *should* to a rule of the rule file, when the sensor runs, then it
      lists the line and the word, and exits 0.
- [ ] Given a long sentence in the *Context* of an ADR, or in a code span, when the sensor runs,
      then it lists nothing for it.
- [ ] Given no change to the covered sections, when the sensor runs, then it says so and exits 0.
- [ ] Given the self-test, when it runs, then it decides each case above from a table of fixture
      trees and expected output, and cites the decision it holds.
- [ ] Given the check-list agreement of the documentation check (check 9), when it runs, then the
      sensor's job step, its line in `scripts/check-all.sh`, and the lists in `CONTRIBUTING.md`
      agree.

## Read first

- Touches: [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), `docs/adr/README.md`,
  `.agents/skills/review/SKILL.md` (its section *Report on two axes*), a new `scripts/sensor-*.sh`
  with its self-test, `.github/workflows/checks.yml` (job `sensors`),
  `scripts/check-all.sh`, `CONTRIBUTING.md`
- `docs/adr/0001-agent-governance-model.md`, *Decision*: a rule lives in the rule file only.
- `docs/adr/0003-procedures-as-skills.md`: the review skill points at the rule and states none.
- The golden path: `scripts/sensor-binding-adrs.sh` (`--sections`, the base, `--root`) and its
  self-test under `scripts/lib/selftest.sh`.

## Blocked by

- docs/plan/plain-rules-and-backlog/01-every-script-reads-adr-identifiers-through-the-library.md

## Mode

with the human: the rule changes the rule file, which the human reviews word by word.
