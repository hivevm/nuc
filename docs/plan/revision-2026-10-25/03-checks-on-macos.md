# Ticket: Run the checks on macOS so a GNU-only spelling fails before it lands

## What to build

Pull request #4 found GNU-only `sed` and `grep` in the checks only because a derived project ran
them on macOS. `scripts/check-shell.sh` has refused `sed -i` since then, and nothing else.
`scripts/check-docs.sh` still uses `\b` in a `grep -E` expression (check 12, the LICENSE
placeholder), which POSIX ERE does not define. No list of spellings a check refuses catches the
whole class. A run on the platform does.

Add a CI job, or a matrix entry of the existing jobs, that runs `scripts/check-all.sh` on a macOS
runner with the bash floor of ticket 01. Then fix what it finds, each with a regression case.

Weigh this with the maintainer first. The job is inherited by every derived project. macOS
minutes cost more on private repositories, and the job would join the required checks of
`README.md` → Repository settings, which check 9 holds against `checks.yml`.

## Acceptance criteria

- [ ] Given the macOS job, when a script uses a GNU-only spelling such as `\b` in ERE or `sed -i`,
      then the job fails.
- [ ] Given the current tree after the fixes, when the job runs, then it passes.
- [ ] Given check 9, when the job is added, then the README's required checks and `check-all.sh`
      agree with it.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (the checks; three lists)
- `.github/workflows/checks.yml`, `scripts/check-shell.sh`, the *Proof* and *Doubts* of pull
  request #4

## Blocked by

- docs/plan/revision-2026-10-25/01-bash-floor-decision.md

## Mode

with the human: the job is inherited by every derived project and costs them CI minutes. That is
the maintainer's call, and the template has no harness ADR for an unattended run.
