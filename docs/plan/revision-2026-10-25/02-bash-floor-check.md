# Ticket: Refuse a bash below the floor with a message that names it

## What to build

On macOS, `scripts/check-all.sh` and the hooks that call it fail on bash 3.2 deep inside a
script, with a syntax or `mapfile` error that does not say why. Once the floor is decided
(ticket 01), the checks test `BASH_VERSINFO` once, at the start of `check-all.sh` and of each
check run on its own. A bash below the floor is refused with one line that names the floor, the
bash found, and how to get a newer one (on macOS, Homebrew's bash). This is the check that the
mistake of pull request #4 asks for.

## Acceptance criteria

- [ ] Given a bash older than the floor (simulated in the self-test by overriding the version
      the guard reads), when `check-all.sh` runs, then it exits non-zero before any check and
      prints the floor and the version found.
- [ ] Given the floor or later, when `check-all.sh` runs, then the guard prints nothing.
- [ ] Given the guard, when `scripts/test-check-all.sh` runs, then it covers both cases.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md`, as corrected by ticket 01
- `scripts/check-all.sh`, `scripts/lib/selftest.sh`, `scripts/test-check-all.sh`

## Blocked by

- docs/plan/revision-2026-10-25/01-bash-floor-decision.md

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
