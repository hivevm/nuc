# Ticket: ADR-0001 is restated as `NUC-documents-are-fixed`

## What to build

`NUC-documents-are-fixed` restates ADR-0001: one specification, one record, one rule file, one
overview, one glossary, one conventions file, and where each kind of text lives. What ADR-0001 says
about the record itself moves to `NUC-adrs-record-decisions` as a revision of ADRs only, where
ticket 01 did not already carry it.

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
- [ ] Given the checks and sensors that cite ADR-0001 for a clause, when they are read, then each
      cites the `NUC-` ADR that now carries that clause.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/0001-agent-governance-model.md`, `docs/adr/`, `scripts/check-docs.sh`,
  `scripts/sensor-binding-adrs.sh`, `scripts/sensor-plain-rules.sh`, `scripts/lib/rules.sh`,
  `.agents/skills/normalize/remap.sh`
- ADR-0001 in full, and `NUC-adrs-record-decisions` for what is already restated there.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation.
