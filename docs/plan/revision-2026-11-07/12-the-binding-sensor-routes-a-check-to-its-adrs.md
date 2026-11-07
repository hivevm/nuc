# Ticket: The binding sensor routes a change to one check of check-docs to the ADRs of that check

## What to build

User story 1 of the spec `fixed-base-and-recut` asked that a session read only the decision its
change touches. For a file under `docs/plan/` the binding sensor's `--sections` output fell from
1,621 words at `v0.8.1` to 1,080. For a change to `scripts/check-docs.sh` it rose from 2,958 to
4,325: five `NUC-` ADRs name that file in their *Applies to*, each for its own checks ("check 14 of
`scripts/check-docs.sh`", "checks 3, 4, and 11 of …"). The sensor matches paths only, so the
narrowing to a check is prose that every session reads in full and matches by hand.

Pick one of two shapes with the human, then build it:

- the sensor reads the numbered header of `scripts/check-docs.sh` and the lines a change touches,
  and routes a change inside one check to the ADRs whose *Applies to* names that check, the file's
  header and shared helpers to all of them; or
- `scripts/check-docs.sh` splits its checks by the ADR that decides them into files the
  *Applies to* lines name by path, which adds no check and costs lines against the budget the
  spec set.

## Acceptance criteria

- [ ] Given a change inside check 14 only, when the sensor runs with `--sections`, then it prints
      `NUC-releases-are-semver-tags` and no ADR that names only other checks of the file.
- [ ] Given a change to the header or a shared helper of the file, when the sensor runs, then it
      prints every ADR that names the file.
- [ ] Given `scripts/test-sensor-binding-adrs.sh`, when it runs, then a case pins each of the two.
- [ ] Given `cat scripts/*.sh scripts/lib/*.sh .agents/skills/*/*.sh | wc -l`, when it is taken
      after the change, then the hand-off reports it against 10,009.

## Read first

- Touches: `scripts/sensor-binding-adrs.sh`, `scripts/test-sensor-binding-adrs.sh`,
  `scripts/check-docs.sh`
- The *Applies to* lines of the ten `NUC-` ADRs.

## Blocked by

- None (can start immediately)

## Mode

with the human: the choice between the two shapes moves either the sensor's interface or the
layout of the checks.
