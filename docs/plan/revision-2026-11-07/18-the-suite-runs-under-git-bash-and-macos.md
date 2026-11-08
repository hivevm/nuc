# Ticket: The suite runs under Git Bash and on macOS before the base ships

## What to build

The Context of [NUC-checks-are-bash](../../adr/NUC-checks-are-bash.md) says the checks run on
macOS, Linux, and Windows under Git Bash. Every job of `.github/workflows/checks.yml` runs on
`ubuntu-latest`, and no ticket of `fixed-base-and-recut` ran the suite elsewhere. The hand-offs
name what is unproven: `git hash-object` with `core.autocrlf` for the blob list (ticket 02), the
`LC_ALL=C` glob and the old-git shim (ticket 01), the map script's byte-wise `§` in awk
(ticket 10), and 14 cases of the plain-rules self-test that fail under BWK awk, the awk macOS ships
(ticket 12).

First a run by hand of `scripts/check-all.sh` under Git Bash on Windows and on macOS, before the
human tags `v0.9.0`; each failure becomes a fix with its regression test. Then, with the human,
whether `checks.yml` gains a job on `windows-latest` and `macos-latest` that runs the self-tests.

## Acceptance criteria

- [ ] Given a Windows machine with Git Bash and a Mac, when `scripts/check-all.sh` runs on a clone
      of the release branch, then it is green, or each failure is fixed with a test.
- [x] Given the plain-rules self-test under BWK awk, when it runs, then it passes.
- [ ] Given the decision on CI, when it is taken, then `checks.yml`, `scripts/check-all.sh`, and
      the required checks of `CONTRIBUTING.md` agree (check 9).

## Read first

- Touches: `.github/workflows/checks.yml`, `scripts/lib/rules.sh`, `scripts/sensor-plain-rules.sh`,
  `scripts/lib/adr.sh`, `.agents/skills/normalize/remap.sh`

## Blocked by

- None (can start immediately)

## Mode

with the human: it needs a Windows machine and a Mac, and a CI job adds required checks.

## Where it stands

Every self-test passes with BWK awk first on `PATH`, run on Linux with two builds of Debian's
`original-awk`: 20220912, which reads bytes as the awk of macOS does, and 20250116, which reads
UTF-8. The plain-rules self-test passed under both before this branch changed it. The one
failure, in `scripts/test-check-docs.sh` and through it the tree cycle of
`scripts/test-normalize-remap.sh`, was a fixture helper that passed a newline in a `-v` value; it
now passes its paths through the environment.

What remains needs the machines: a run of `scripts/check-all.sh` on a Mac, whose awk is 20200816,
and under Git Bash on Windows, for `git hash-object` with `core.autocrlf`, the `LC_ALL=C` glob,
and the old-git shim; and the decision on a CI job on `windows-latest` and `macos-latest`.
