# Ticket: Release v0.9.0

## What to build

The design revision runs over what the tickets touched and deletes the spec; what has to last moves
into an ADR, the architecture overview, the glossary, or the conventions first. The baseline of the
spec is measured again. The release notes carry the map for derived projects and the take-up steps.
The README names `v0.9.0`, and the branch deletes this ticket.

## Acceptance criteria

- [ ] Given the measures of the spec's baseline, when they are taken on the release commit, then the
      hand-off reports each before and after, and the number of checks and the lines in `scripts/`
      and the skill scripts have not risen.
- [ ] Given each `NUC-` ADR, when the release is cut, then the human has accepted it.
- [ ] Given the release commit, when check-docs runs, then check 12 passes on the blob list.
- [ ] Given `docs/plan/fixed-base-and-recut/`, when the release commit lands, then the directory is
      gone.

## Read first

- Touches: `README.md`, `docs/ARCHITECTURE.md`, `docs/plan/`
- The `design-revision` skill.
- The release notes of `v0.8.0` and `v0.8.1` as the golden path.

## Blocked by

- docs/plan/fixed-base-and-recut/13-derived-projects-migrate.md

## Mode

with the human: tag and release are the human's.
