# Ticket: Replace the restatements of rules and setup steps with citations

## What to build

Passages that restate what another document states, each to be cut to a citation by anchor,
because a restatement drifts and an anchor check does not see it:

- **`setup-project` restates `TEMPLATE-SETUP.md`.**
  - "In a complex project the pull request lands steps 1 to 6 … step 7 follows as the first spec"
    appears twice in the skill and once in the setup file.
  - "ADR-0004 waits for step 4" appears three times in the skill and once in the setup file.
  - Rule 3 of [§3](../../../AGENTS.md#3-adr-rules) ("commits of ADRs only, proposed") is restated
    in both.
  - The skill's paragraph on the repository settings repeats the second paragraph of step 1.
- **"The settings sensor runs on a human's instruction"** is stated five times: `README.md`,
  `TEMPLATE-SETUP.md`, `setup-project` twice, and `normalize`. ADR-0002 decides it.
- **The guarantees of the git hooks** appear in `SECURITY.md`, `CONTRIBUTING.md`, the `normalize`
  skill, and `README.md` → Getting Started, next to `README.md` → Git hooks.
- **`SECURITY.md` restates AGENTS.md:** [§6](../../../AGENTS.md#6-project-rules) on instructions,
  [§3](../../../AGENTS.md#3-adr-rules) rules 4 and 7, and [§7](../../../AGENTS.md#7-secrets) right
  after saying "that wording governs".
- **The `normalize` skill states a merge rule:** "only a human merges it"
  ([§6](../../../AGENTS.md#6-project-rules), uncited).
- **`CONTRIBUTING.md` adds an issue mechanism.**
  - "Open an issue first when scope or intent is not yet agreed
    ([§4](../../../AGENTS.md#4-working-style))": [§4](../../../AGENTS.md#4-working-style) says to
    settle it with the human.
  - "Link the issue or ADR": the pull request template has no issue field.
- **The pull request template's *Ticket* line cites ADR-0006 for "the report it resolves",**
  while ADR-0006 puts the intake of reports out of scope.
- **The `Bypassable with --no-verify` header lines** of `pre-push` and `pre-merge-commit` do not
  cite [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) as `pre-commit`'s does (a nit of pull
  request #6).

Ticket 10 may move some of these passages; take it first where they overlap.

## Acceptance criteria

- [ ] Given each passage above, when it is read after the change, then it cites the one place
      that states it and adds nothing of its own.
- [ ] Given the change, when `scripts/check-docs.sh` runs, then every new citation resolves.

## Read first

- [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) (the opening paragraph: cite by anchor, restate
  nothing)
- `docs/adr/0001-agent-governance-model.md`, `docs/adr/0003-procedures-as-skills.md`
  (Decision)

## Blocked by

- docs/plan/revision-2026-10-25/10-rules-outside-the-rule-file.md

## Mode

with the human: whether a sentence is a rule or a pointer is the judgement ADR-0001 leaves to
review, and the template has no harness ADR for an unattended run.
