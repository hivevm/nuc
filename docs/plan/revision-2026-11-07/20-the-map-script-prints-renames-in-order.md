# Ticket: The map script prints its renames in a stable order

## What to build

`remap.sh --record` renames each numbered ADR by a loop over the keys of an associative array
(`for new in "${!target[@]}"` in `.agents/skills/normalize/remap.sh`), so it prints the renames,
with `--check` and without, in bash's hash order. A maintainer reviews that output at the
migration, and two runs of one map on two machines print it differently. The loop runs over the
keys sorted.

## Acceptance criteria

- [ ] Given a map that renames three numbered ADRs, when `remap.sh --record --check` runs, then it
      prints the renames sorted by the old file name.
- [ ] Given `scripts/test-normalize-remap.sh`, when it runs, then a case pins the order.
- [ ] Given the line count of the spec's measure, when it is taken after the change, then it has
      not risen above 10,015.

## Read first

- Touches: `.agents/skills/normalize/remap.sh`, `scripts/test-normalize-remap.sh`

## Blocked by

- None (can start immediately)

## Mode

unattended: the criteria decide it; stop after two failed attempts and hand off with the state
written here.
