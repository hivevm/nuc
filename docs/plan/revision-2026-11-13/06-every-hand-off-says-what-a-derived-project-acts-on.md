# Ticket: Every hand-off says what a derived project acts on, in the fields the hand-offs write

## What to build

Two gaps in `.github/PULL_REQUEST_TEMPLATE.md` showed in the work since the revision of
2026-11-12. Both touch the hand-off and what the review reads of it, so one ticket takes both.

**What a derived project acts on.**
[NUC-releases-are-semver-tags §2](../../adr/NUC-releases-are-semver-tags.md) asks the notes of a
release to say what a derived project does to take it up. The template asks no hand-off for it.
Several hand-offs of v0.10.0 named such a step anyway, under *Doubts*, as "Unsure, for the human"
or "for the notes of v0.10.0". The break the review of the release found was raised by no
hand-off: a project's own `scripts/*.sh` must take its root through `scripts/lib/root.sh`, or
`scripts/test-check-all.sh` fails. Ticket 01 of the revision of 2026-11-12 made that rule, and its
hand-off named the positional root of a project's call but not the project's own script. A field
every hand-off fills, "none" included, asks the question of each change while its author still
knows the answer.

**The field the hand-offs write.** The *Doubts* section has two fields, `- Disagreed:` and
`- Could not confirm:`. Every hand-off since the revision of 2026-11-12 wrote a third,
`- Unsure:`: the merges 3696b8c, 8c7748e, 21252e1, 93b83f4, 9621b20, bc1e3a2, 7fc58b1, and
d67c151, and the descriptions of PR #41, #42, and #43. No template, skill, or rule names it
(`git grep -n 'Unsure'` outside `docs/plan/` printed nothing on 2026-11-13).

**Decided by the human on 2026-11-13:** `Unsure:` joins the template. The *Doubts* section carries
four fields, in this order:

- `- Disagreed:`
- `- Unsure:`
- `- Could not confirm:`
- `- A derived project acts on:` — what a derived project must do when it takes the change up,
  or "none".

## Acceptance criteria

- [ ] Given `.github/PULL_REQUEST_TEMPLATE.md`, when `grep -n '^- [A-Z][^:]*:'` runs on its
      *Doubts* section, then it prints the four fields above, in that order, and no other.
- [ ] Given `.github/PULL_REQUEST_TEMPLATE.md`, when the comment of the *Doubts* section is read,
      then it says what each field holds. For `A derived project acts on:` it names what counts: a
      changed interface of a script, a check that newly reaches a project's own files, a moved
      key, a removed file; or "none".
- [ ] Given `.agents/skills/review/SKILL.md`, when `grep -n 'A derived project acts on'` runs on
      it, then the step that reads the *Doubts* names the field as a claim the reviewer checks
      against the diff, and it names the same four fields as the template.
- [ ] Given the diff, when it is read, then it touches no file but the two above.

## Read first

- Touches: `.github/PULL_REQUEST_TEMPLATE.md`, `.agents/skills/review/SKILL.md`
- `.agents/skills/review/SKILL.md`, section 2, the paragraph on the *Doubts*.
- The descriptions of PR #41, #42, and #43, *Doubts* and *Review*.
- [NUC-releases-are-semver-tags §2 and §6](../../adr/NUC-releases-are-semver-tags.md).

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the shape
of every hand-off is the human's to accept. Past that, the criteria are decided by `grep` and by
reading two files, and a wrong result costs one revert. Stop and hand off when a field needs a rule
in `AGENTS.md` rather than a line of the template.
