# Ticket: ADR-0006 is split into `NUC-large-work-is-planned` and `NUC-design-is-revised`

## What to build

ADR-0006 carries two decisions. `NUC-large-work-is-planned` restates the plan in the tree and the
backlog, and adds the latitude "plan in issues": the issue assignment replaces the branch claim, and
the issue list replaces the frontier sensor. That answers a project such as Ocelli, which plans in
GitHub Issues. `NUC-design-is-revised` restates the design revision and its triggers. The claim
mechanics leave the ADR for the `work-tickets` skill.

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
- [ ] Given the `work-tickets` skill, when it is read, then it carries the claim steps, and the new
      ADRs state no step.
- [ ] Given the latitude "plan in issues", when it is read, then it names what replaces the claim
      and the frontier sensor.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/0006-feature-layer.md`, `docs/adr/`, `docs/plan/`, `docs/backlog/`,
  `.agents/skills/plan-feature/`, `.agents/skills/work-tickets/`, `.agents/skills/design-revision/`,
  `.github/PULL_REQUEST_TEMPLATE.md`, `scripts/sensor-revision-due.sh`,
  `scripts/sensor-plan-frontier.sh`, `scripts/sensor-backlog.sh`
- ADR-0006 in full.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation: the latitude "plan in
issues" is a new decision.
