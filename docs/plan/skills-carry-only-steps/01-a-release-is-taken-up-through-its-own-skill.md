# Ticket: A release is taken up through a skill of its own

## What to build

A maintainer of a derived project takes up a template release through the skill
`take-up-release`. First, the ADRs that name normalize as the take-up's place are corrected in
place. NUC-procedures-are-skills §1 lists `take-up-release` and says normalize carries
normalization and adoption. NUC-releases-are-semver-tags names `take-up-release` where it names
the take-up's order of work. The human reviews that commit of ADRs in the session. Then the
take-up's steps leave normalize: its section 7, its description's mention of a release, its entry
point for a release, and what a take-up needs of the part on hooks and repository settings.
Normalize keeps normalization and adoption, and its entry point for a release names the new
skill. The new skill has its pointer.

## Acceptance criteria

- [ ] Given the two ADRs, when the first commit lands, then it is a commit of ADRs only, with
  `docs/adr/NUC.blobs` rewritten in it. NUC-procedures-are-skills §1 lists `take-up-release` and
  says normalize carries normalization and adoption. No clause of NUC-releases-are-semver-tags
  changes its meaning. The plain rules sensor reports nothing on its added lines.
- [ ] Given the template, when the skills are listed, then `take-up-release` exists with front
  matter whose description says it runs when a derived project takes up a later release. It has
  its pointer.
- [ ] Given the normalize skill, when it is read, then it holds no step of a take-up. Its
  description no longer names a template release, and its entry point for a release names
  `take-up-release`.
- [ ] Given the steps of the take-up before and after, when they are compared, then no step,
  condition, order, or duty is added, dropped, or changed. The one exception is a pointer to the
  normalize skill where a take-up step names "this skill".
- [ ] Given normalize's normalization and adoption steps before and after, when they are compared,
  then they are unchanged, the hooks and repository settings an adoption needs included.
- [ ] Given the change, when `scripts/check-all.sh` runs, then it passes, the documentation
  check's pointer and front-matter cases included.
- [ ] Given the hand-off, when the human reads it, then it names the commit of ADRs reviewed, the
  deviation from NUC-large-work-is-planned §4, and under *A derived project acts on* the new skill
  and its pointer, which a take-up must bring.

## Read first

- Touches: `docs/adr/NUC-procedures-are-skills.md`, `docs/adr/NUC-releases-are-semver-tags.md`,
  `docs/adr/NUC.blobs`, `.agents/skills/normalize/SKILL.md`,
  `.agents/skills/take-up-release/SKILL.md`, `.claude/skills/take-up-release`
- NUC-decisions-are-proposed-then-accepted §3, §4, and §6;
  NUC-procedures-are-skills §1, §3, §4, §6, and §7;
  NUC-releases-are-semver-tags §5, §6, and §7.
- The spec's Implementation decisions, "Take-up skill", "ADR corrections", and "Way of working".
- The `propose-adr` skill, steps 3 and 4; the conventions' entry "A rule changes everywhere it is
  stated".
- The golden path: an existing skill and its pointer, such as `review`.

## Blocked by

- None (can start immediately)

## Mode

with the human. It corrects accepted `NUC-` ADRs, which the human reviews, and the plan lives off
`main` (see the spec), so no ticket is dispatched.
