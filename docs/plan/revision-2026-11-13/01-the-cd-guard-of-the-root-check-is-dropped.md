# Ticket: The cd guard of the root check is dropped

## What to build

`root_problem` of `scripts/test-check-all.sh` holds every `scripts/*.sh` but the self-tests and
`check-all.sh` to the root of `scripts/lib/root.sh` in three ways:

- by text, that it calls `enter_root`;
- by text, that no line passes `$1` to `cd` or `pushd` (the cd guard);
- by running it, that `--verbose` and a `--root` on a missing directory stop it with exit 2.

The cd guard came with ticket 01 of the revision of 2026-11-12, as its criterion "None passes its
first positional argument to `cd`" (19078a9), and was widened by d9cee30 for the unbraced forms.
Dropping it reverses that criterion. It prevented nothing during the work it was written for: no
script it ran on ever had such a line, and every case of it is a mutation of
`check-devcontainer.sh`. It reads text, not shell, and its own comment lists what it misses
(`dir=$1; cd "$dir"`, `cd "$(realpath "$1")"`, a `#` before the `cd`). It was a lesser finding of
the review of #41, then a fix commit and a second review round of the small fixes for v0.10.0.

The running cases do not stand in for it. `enter_root` refuses a missing `--root`, and
`rest_args` refuses `--verbose`, both before any line of the script that could change to `$1`.
What is lost: a script that calls `enter_root`, lets `rest_args` keep a positional argument, and
then changes to it, so that it reads a root given the old way.

**Decided by the human on 2026-11-13:** the guard goes, and the lost case is accepted. The check
of ticket 02 does not take it over: `rest_args` refuses only a positional argument a script does
not declare, so a script that declares one and changes to it still passes; the case is lost.
[`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) asks a design
revision to drop what prevented nothing. The guard goes with its cases and the part of the
comment that describes it.

## Acceptance criteria

- [ ] Given `scripts/test-check-all.sh`, when it is read, then `root_problem` has no test on the
      text of a `cd` or `pushd`, and no case builds a copy with such a line beside `enter_root`.
- [ ] Given a copy of `check-devcontainer.sh` without its call of `enter_root`, when the self-test
      runs on it, then it is still caught.
- [ ] Given `scripts/check-all.sh`, when it runs, then it ends "All checks passed." and the
      self-test of check-all counts fewer cases by the guard's cases alone.
- [ ] Given the hand-off, when the review reads it, then it names each removed case and the loss
      above; the review decides this criterion, no test.

## Read first

- Touches: `scripts/test-check-all.sh`
- `scripts/test-check-all.sh`, the block of `root_problem` and the cases after it.
- The merge message of bc1e3a2, *Proof* and *Review*, for what the guard was meant to catch.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. Past that, the
self-test decides each criterion, and a wrong result costs one revert. Stop and hand off when a
script in the tree fails the guard before the change: the guard then catches a real script, and
the ground for dropping it is gone.
