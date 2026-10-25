# Ticket: Draft how a derived project changes the ADR rules when AGENTS.md is not edited per project

## What to build

A draft for the maintainer, written through `propose-adr`, of a correction of ADR-0001. The
review of pull request #6 left this open, and the release notes of v0.4.0 repeat the second
sentence:

- `AGENTS.md`, its opening note: "The file belongs to the template and is not edited per
  project."
- ADR-0001, Decision: the ADR rules of [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) change "in a
  derived project, by an ADR on the ADR process".

An ADR that changes a rule leaves the old wording in a file that is not edited, and that file says
its own wording governs. The draft decides one of these:

1. A derived project edits the ADR rules in the change that lands its ADR on the ADR process, and
   the opening note says so.
2. The ADR overrides the ADR rules without editing them, and the rules say that an ADR on the
   ADR process in force governs over their text.
3. A derived project takes up the template's ADR rules only, and changes them upstream.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then AGENTS.md's opening note and
      ADR-0001's sentence agree on how a derived project changes the ADR rules.
- [ ] Given the decision, when the `normalize` skill's take-up steps are read, then they say the
      same.

## Read first

- `docs/adr/0001-agent-governance-model.md` (in full), `docs/adr/0005-template-releases.md`
- `AGENTS.md`, its opening note and the ADR rules
- The *Review* of pull request #6, its nits

## Blocked by

- None (can start immediately)

## Mode

with the human: a decision on the rule file's own boundary, which only the maintainer takes.
