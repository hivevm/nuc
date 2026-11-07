# Ticket: The migration from numbered ADRs leaves the template after its window

## What to build

The migration of a derived project to category identifiers runs once per project, at its take-up
of `v0.9.0`. Every later release still ships it: step 8 *Migrate a numbered record* of the
`normalize` skill, the map `.agents/skills/normalize/map-v0.9.0.txt` (261 lines), and in
`.agents/skills/normalize/remap.sh` the numbered forms (`num_re`, the `ADR-` and `NNNN-*.md`
tokens) and `--record`. The skill gained 121 lines in the work, and the remap script's new map
forms cost about 180 lines of the scripts' budget (hand-off of ticket 10).

At the first minor after `v0.9.0` that the human names as the end of the window, these go. The
release notes of `v0.9.0` say that a project migrates from `v0.9.0`'s copy of the skill. The
last clause of [NUC-adrs-record-decisions §17](../../adr/NUC-adrs-record-decisions.md) goes with
them, in a commit of ADRs only.

## Acceptance criteria

- [ ] Given the tree after the change, when it is searched, then no script reads a numbered ADR
      form and the `normalize` skill has no migration step.
- [ ] Given `scripts/test-normalize-remap.sh`, when it runs, then it passes without the cases of
      the numbered forms and `--record`.
- [ ] Given the line count of the spec's measure, when it is taken, then the hand-off reports what
      it fell by.

## Read first

- Touches: `.agents/skills/normalize/`, `scripts/test-normalize-remap.sh`,
  `docs/adr/NUC-adrs-record-decisions.md`, `docs/adr/NUC.blobs`

## Blocked by

- None (can start immediately)

## Mode

with the human: the human names the release that ends the window.
