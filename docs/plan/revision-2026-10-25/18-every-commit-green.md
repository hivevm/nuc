# Ticket: Check that every commit of a regrouped branch passes on its own

## What to build

Pull requests #6 and #9 were regrouped before they merged. In #6, two reviews of the grouping
found commits that relied on what later ones added, and messages that left out part of their
diff. In both, "each commit passes `check-all.sh`" was proven by hand. The first half is
mechanical: run the checks on every commit of a range and name the first that fails.

A sensor, `scripts/sensor-each-commit.sh <base> <head>`, checks out each commit of the range in a
temporary worktree under `.scratch/` and runs `scripts/check-all.sh` there. It lists the commits
that fail and runs on a human's instruction, since it costs one full run per commit. It ships
with its self-test. Whether a message covers its diff stays with review.

Weigh first whether the cost earns its place against the hand run it replaces. The regroups are
the maintainer's practice; the sensor serves it, not a rule.

## Acceptance criteria

- [ ] Given a fixture branch whose second commit breaks a check that the third repairs, when the
      sensor runs over it, then it names the second commit and exits zero (it reports).
- [ ] Given a branch whose every commit passes, when it runs, then it says so.
- [ ] Given the sensor, when check 9 runs, then its self-test is in the three lists and the
      sensor itself in none, like the settings sensor.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (sensors; on instruction)
- `scripts/sensor-repo-settings.sh` and its self-test, the golden path of a sensor run by hand
- The *Review* sections of pull requests #6 and #9

## Blocked by

- None (can start immediately)

## Mode

with the human: whether the sensor earns its run time is the maintainer's call, and the template
has no harness ADR for an unattended run.
