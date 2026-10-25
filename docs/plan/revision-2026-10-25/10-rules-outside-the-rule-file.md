# Ticket: Draft how the README sections that AGENTS.md delegates to are allowed to hold rules

## What to build

A draft for the maintainer, written through `propose-adr`, of a correction of ADR-0001 (and perhaps
ADR-0003). ADR-0001 permits exactly one exception to "no other document holds a rule": the mechanics
of a record that the rule file delegates to it, which is `docs/adr/README.md` and `template.md`.
[`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) nevertheless delegates to three README
sections, and they carry normative text:

- **Git hooks.** What each hook refuses.
- **Integration branches.** Six numbered steps. That is a procedure, and ADR-0003 says the rule
  file names a skill for its procedures and drops the steps.
- **Repository settings.** For example: the merge commit is the only merge method, and these
  are the required checks.

Rules stated outside AGENTS.md that AGENTS.md does not state:

- "A rule is enforced only by what every agent hits … A tool's own configuration is not used to
  enforce one." This sits in `README.md` → Coding Agents, in `SECURITY.md`, and under *Does not
  fit* of `.agents/skills/propose-adr/concepts/harness.md`.
- "The review that binds after a rework is a review of the whole branch." This sits in `README.md`
  → Integration branches, in `.agents/skills/review/SKILL.md`, and in
  `.github/PULL_REQUEST_TEMPLATE.md`.
  [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) says only that the hand-off
  names the commit the review saw.

Also in the draft: `.claude/settings.json`, a Read deny on `.env*` that only Claude Code honours.
`SECURITY.md` justifies it as closing one path for one agent, and no ADR names it. It sits next
to the rule above, which says a tool's own configuration enforces nothing. Decide whether that
rule exempts it or whether it goes. The pattern also hides the tracked `.env.example`.

Options: name the delegated README sections in ADR-0001's exception; or lift the two rules into
AGENTS.md and the integration steps into a skill (ADR-0003), with the README pointing.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then each passage above is either covered
      by an exception ADR-0001 names, or moved, with its new home stated.
- [ ] Given the decision, when the three copies of each rule are read, then one states it and the
      others cite it by anchor.

## Read first

- `docs/adr/0001-agent-governance-model.md`, `docs/adr/0003-procedures-as-skills.md` (in full)
- [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) (the opening paragraph) and
  [§6](../../../AGENTS.md#6-project-rules)
- `README.md` → Coding Agents, Git hooks, Integration branches, Repository settings;
  `SECURITY.md`

## Blocked by

- None (can start immediately)

## Mode

with the human: it moves the boundary of the rule file, which ADR-0001 calls load-bearing. Only
the maintainer decides it.
