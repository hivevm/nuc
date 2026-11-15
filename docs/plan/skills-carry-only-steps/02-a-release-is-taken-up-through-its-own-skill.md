# Ticket: A release is taken up through a skill of its own

## What to build

A maintainer of a derived project takes up a template release through a skill named for it. The
take-up's steps leave section 7 of the normalize skill, and so do its entry point for a release
and the part of section 1 on the hooks and repository settings that a take-up needs. Normalize
keeps normalization and adoption, and its entry point for a release names the new skill. The new
skill has its pointer under the pointer directory. Every text that sent a reader to normalize for
a take-up names the new skill.

## Acceptance criteria

- [ ] Given the template, when the agent skills are listed, then a take-up skill exists with front
  matter whose description says it runs when a derived project takes up a later release. It has
  a pointer of its own.
- [ ] Given the normalize skill, when it is read, then it holds no step of a take-up. Its
  description no longer names a template release, and its entry points name the take-up skill
  for a release.
- [ ] Given the steps of the take-up before and after, when they are compared, then no step,
  condition, order, or duty is added, dropped, or changed.
- [ ] Given the tree, when it is searched for a citation of normalize as the take-up's place,
  then none is left: not in the setup walk, the setup file, CONTRIBUTING.md, or another skill.
- [ ] Given the change, when `scripts/check-all.sh` runs, then it passes, the documentation
  check's pointer and front-matter cases included.

## Read first

- Touches: `.agents/skills/normalize/SKILL.md`, `.agents/skills/take-up-release/SKILL.md`,
  `.claude/skills/take-up-release`, `TEMPLATE-SETUP.md`,
  `.agents/skills/setup-project/SKILL.md`, `CONTRIBUTING.md`
- NUC-procedures-are-skills §1, §3, §6, §7 as ticket 01 corrected them;
  NUC-releases-are-semver-tags §5, §6, and §7.
- The conventions' entry "A rule changes everywhere it is stated".
- The golden path: an existing skill and its pointer, such as `review`.

## Blocked by

- docs/plan/skills-carry-only-steps/01-the-adrs-name-a-take-up-skill.md

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
