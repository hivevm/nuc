# Ticket: ADR-0002 is split into `NUC-decisions-cite-tests` and `NUC-checks-are-bash`

## What to build

ADR-0002 carries two decisions. `NUC-decisions-cite-tests` restates that every accepted decision and
every criterion is verified by a test that cites it. `NUC-checks-are-bash` restates that the checks
and sensors are bash scripts under `scripts/`, with the latitude "a `nuc` binary instead of bash".
Its draft clause has gone with ticket 01.

This ticket also works
docs/plan/revision-2026-11-07/05-a-check-holds-each-sensor-self-test-to-its-citation.md against the
new form: the traceability check fails on a sensor without a self-test, or on a self-test that does
not cite `NUC-checks-are-bash`, read as the other checks read identifiers. The branch deletes that
ticket file.

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
- [ ] Given a sensor without a self-test, or a self-test that cites another ADR only, when the
      traceability check runs, then it fails and names the sensor and the ADR it expects.
- [ ] Given `scripts/test-normalize-remap.sh`, when it cycles the real tree, then the traceability
      self-test passes, so the check holds no literal identifier.
- [ ] Given `NUC-checks-are-bash`, when its *Latitude* is read, then it names the binary as a choice
      and leaves whether the template switches open.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/0002-decisions-verified-by-tests.md`, `docs/adr/`,
  `scripts/check-traceability.sh`, `scripts/test-check-traceability.sh`, `scripts/test-sensor-*.sh`,
  `.githooks/`, `docs/plan/revision-2026-11-07/`
- ADR-0002 in full, and the revision ticket named above.
- The convention "A self-test asserts what it builds" in `docs/CONVENTIONS.md`.
- The pilot `docs/adr/NUC-releases-are-semver-tags.md` and the spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/03-pilot-releases-are-semver-tags.md

## Mode

with the human: each ADR is reviewed by the human before its implementation.
