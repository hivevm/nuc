# Ticket: ADR-0003 is restated as `NUC-procedures-are-skills`

## What to build

`NUC-procedures-are-skills` restates ADR-0003: the procedures of the rule file are skills under
`.agents/skills/`, each carrying a how and no rule of its own, with pointers for agents that read
another directory.

Each new ADR is proposed in a commit of ADRs only, in the form of the pilot
`NUC-releases-are-semver-tags`: plain rules, conditional where a part is optional, a *Latitude*
section. The checks, sensors, skills, and self-tests that cite the old ADR cite the new one where
they hold its clauses; the old ADR stays until ticket 10. The hand-off lists each clause of the old
text with its new home and reports the word count before and after.

## Acceptance criteria

- [ ] Given the new ADRs, when the plain-rules sensor reads their *Decision* and *Enforcement*, then
      it reports no sentence over the limit and no modal verb besides *must*, *must not*, *may*.
- [ ] Given every clause of the old text, when the hand-off's clause table is walked, then each has
      a home, and no clause has two.
- [ ] Given the *Latitude* section of each new ADR, when it is read, then it names no tool and no
      project value, and each choice links the catalogue where the catalogue has an entry; where
      none has one, the section says that no choice needs an ADR.
- [ ] Given check 11 and every skill that cites ADR-0003, when they are read, then they cite the new
      ADR.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/0003-procedures-as-skills.md`, `docs/adr/`, `.agents/skills/`,
  `.claude/skills/`, `scripts/check-docs.sh` (check 11)
- ADR-0003 in full.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation.
