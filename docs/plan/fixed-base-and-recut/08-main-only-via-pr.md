# Ticket: The rules of integration become `NUC-main-only-via-pr`

## What to build

`NUC-main-only-via-pr` decides what [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) states
today and no ADR records: commits only on a branch, a human decides what leaves the machine, `main`
only through a pull request merged as a merge commit, integration on a `feat/` branch on the human's
instruction, no hook bypassed, and a rule enforced only by what every agent hits. Its *Applies to*
names the hooks, the integration steps, and the repository settings, so the binding sensor routes a
change there. `AGENTS.md` keeps [§6](../../../AGENTS.md#6-project-rules) until ticket 11 rewrites
it.

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
- [ ] Given a change to `.githooks/`, when the binding sensor runs, then it prints the new ADR.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/`, `.githooks/`, `CONTRIBUTING.md`, `scripts/ready-for-main.sh`,
  `scripts/drop-merged-branch.sh`, `scripts/sensor-repo-settings.sh`
- [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) and the sections *Git hooks*, *Integration
  branches*, and *Repository settings* of `CONTRIBUTING.md`.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation: the ADR records rules
that no ADR held before.
