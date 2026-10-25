# Ticket: Hold every list of the checks together, and drop the claim of one order

## What to build

Check 9 of `scripts/check-docs.sh` holds three lists of checks together: those of `check-all.sh`
and `checks.yml`, and the required check names of the README. It does not see three more:

- **A script in neither list.** A new `scripts/*.sh` that neither list runs passes. The settings
  sensor of ADR-0002 is the one script left out on purpose.
- **`.github/workflows/review-binding.yml`.** It repeats the review-binding step of `checks.yml`,
  and its step name has already drifted from the one there.
- **The prose in the header of `checks.yml`.** It lists the scripts a fourth time.

The header of `scripts/check-all.sh` says it runs the checks "in the same order" as `checks.yml`.
They do not; `checks.yml` groups them by job. Drop the claim, or let check 9 decide it. Dropping
it is simpler.

## Acceptance criteria

- [ ] Given a fixture with a `scripts/check-new.sh` that neither list runs, when `check-docs.sh`
      runs, then check 9 fails and names it; the repository settings sensor stays exempt.
- [ ] Given `review-binding.yml` running the sensor with arguments other than those of
      `checks.yml`, when check 9 runs, then it fails.
- [ ] Given the header of `check-all.sh` and of `checks.yml`, when they are read, then neither
      claims an order or a list that no check holds.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (the three lists; Enforcement on check 9)
- `scripts/check-docs.sh` check 9, `scripts/test-check-docs.sh`, whose check 9 cases cite no ADR
  yet (add `Verifies: ADR-0002`)

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
