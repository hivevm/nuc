# Ticket: The commits red alone are a sensor of their own, which needs no GitHub

## What to build

`scripts/sensor-work-measures.sh` reports two things of a different kind:

- without options, the hours and the rounds of review of the ten newest merges of a pull request,
  read through `gh` from the Measures line;
- with `--red` (afe9e6e), the commits of those merges whose own `scripts/check-all.sh` failed,
  each run in a temporary worktree.

The second needs only git and the commits. Yet the script exits 2 without `gh` before it looks at
`--red`, and it runs only on instruction because
[NUC-checks-are-bash §7](../../adr/NUC-checks-are-bash.md) says so of a sensor that reads GitHub.
`--red` is one more flag where a second sensor was due. It carries its own traps, worktrees,
background job, and exit codes 130 and 143, which the hours and rounds do not need. A third of
the cases of `scripts/test-sensor-work-measures.sh` are about it: the commits it runs, the stop
by TERM, and the worktrees left behind.

The ticket splits it into a sensor of its own, such as `scripts/sensor-red-commits.sh`, with its
own self-test, which runs without `gh`. It keeps the ten newest merges and every behaviour the
cases of `--red` pin. `sensor-work-measures.sh` loses `--red`. The new sensor runs on instruction
too, since a run costs a full run of the checks per commit, and its header says so: the
clause on sensors of the GitHub repository does not cover it.

## Acceptance criteria

- [ ] Given a fixture repository with a commit red alone and no `gh`, when the new sensor runs,
      then it names that commit and exits 0.
- [ ] Given the cases of `--red` in `scripts/test-sensor-work-measures.sh`, when they move to the
      new self-test, then each holds against the new sensor, the stop by TERM and the worktree left
      behind included.
- [ ] Given `scripts/sensor-work-measures.sh --red`, when it runs, then it exits 2 with its name
      and the argument.
- [ ] Given `scripts/check-all.sh`, `checks.yml`, and the required checks of `CONTRIBUTING.md`,
      when the rule `docs/check-lists` runs, then the new self-test stands in all three, and the
      sensor itself in none.

The split carries the doubts the hand-offs of 7fc58b1 and 8c7748e left open, and does not settle
them; the hand-off of this ticket names each as still open, or the case that now decides it:

- no timeout: an old `check-all.sh` that hangs blocks the run until a human stops it;
- no case for INT: a background job of a non-interactive shell ignores INT, so only a run by hand
  covered Ctrl-C;
- after Ctrl-C, the jobs of an old `check-all.sh` may run on for some seconds in the removed
  directory;
- the checks of a commit run with the tools of this machine and the sensor's environment.

## Read first

- Touches: `scripts/sensor-work-measures.sh`, `scripts/test-sensor-work-measures.sh`,
  `scripts/sensor-red-commits.sh`, `scripts/test-sensor-red-commits.sh`, `scripts/check-all.sh`,
  `.github/workflows/checks.yml`, `CONTRIBUTING.md`
- `CONTRIBUTING.md`, *Project Layout* and the required checks.
- The merge message of 7fc58b1, *Proof*, *Doubts*, and *Review*.
- [NUC-checks-are-bash §4, §5, and §7](../../adr/NUC-checks-are-bash.md).
- `docs/plan/revision-2026-11-07/23-cost-and-time-are-measured-while-the-work-runs.md`, for the
  measures this leaves as they are.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the
split changes an interface that release v0.10.0 shipped. Past that, the self-tests decide each
criterion, and a wrong result costs one revert. Stop and hand off when a case of `--red` cannot
hold against the new sensor unchanged.
