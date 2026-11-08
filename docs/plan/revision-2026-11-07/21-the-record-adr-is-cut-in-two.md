# Ticket: The ADR on the record is cut into the process and the identifiers with the base

## What to build

The spec `fixed-base-and-recut` cut the base one decision each. One `NUC-` ADR still holds
several: `NUC-adrs-record-decisions` decides when an ADR
is due, how it is proposed and accepted, and that it is immutable (clauses 1 to 7), how it is
named (8 to 10), the fixed base, the blob list, and the roles (11 to 13), and supersession, the
index, citations, and normalization (14 to 17). Its *Decision* and *Enforcement* are 1,531 words,
a quarter of the base's 6,055, and the binding sensor prints them for every change to
`docs/adr/`, `scripts/lib/adr.sh`, `scripts/check-docs.sh`, and the `normalize` skill.

Draft with the human a re-cut into two or three `NUC-` ADRs, such as the process of a decision,
and the identifiers with the fixed base, each proposed in a commit of ADRs only. A re-cut is a
major ([NUC-releases-are-semver-tags §7](../../adr/NUC-releases-are-semver-tags.md)), and its
notes carry the map of each old clause, so it waits for a release that breaks anyway or lands
before `v0.9.0` ships the base.

## Acceptance criteria

- [ ] Given the drafts, when the human reviews them, then each clause of the old ADR has one new
      home, listed in the hand-off.
- [ ] Given a change to a project ADR, when the binding sensor runs with `--sections`, then it
      prints fewer words than the 1,896 it prints at the revision of 2026-11-07 (2).

## Read first

- Touches: `docs/adr/`, `.agents/skills/normalize/map-v0.9.0.txt`
- The `propose-adr` skill and step 7 of the `normalize` skill.

## Blocked by

- None (can start immediately)

## Mode

with the human: it re-cuts the base.
