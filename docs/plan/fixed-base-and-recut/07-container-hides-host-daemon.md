# Ticket: ADR-0004 is restated as `NUC-container-hides-host-daemon`, conditional on a Dev Container

## What to build

`NUC-container-hides-host-daemon` restates ADR-0004 as invariants that hold if the project has a Dev
Container: the host daemon stays out of reach, the Features are locked, and each project lies under
a path of its own. A project without a Dev Container is not bound by it.

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
- [ ] Given a fixture without `.devcontainer/`, when the Dev Container check runs, then it passes
      and says that nothing binds.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/0004-dev-container-runtime.md`, `docs/adr/`, `.devcontainer/`,
  `scripts/check-devcontainer.sh`, `scripts/test-check-devcontainer.sh`
- ADR-0004 in full.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation.
