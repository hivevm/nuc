# Ticket: The shell lint's rule on a pipe into grep -q spares a POSIX sh script without pipefail

## What to build

The trial migration of nectar to `v0.9.0` failed the shell lint on `release/install-nectar.sh`, a
`#!/bin/sh` script that sets no pipefail, at a `printf … | grep -Eqx …` line. Without pipefail the
pipe's status is grep's, so the hazard the rule names does not arise, and the here-string it
proposes is not POSIX sh. The loop over `$QUIET_PIPE` in `scripts/check-shell.sh` reads every
script whatever its shell. It skips a script whose shebang names `sh` and which sets no pipefail.

## Acceptance criteria

- [ ] Given a `#!/bin/sh` script without pipefail that pipes into `grep -q`, when the shell lint
      runs, then it passes.
- [ ] Given a bash script with pipefail that does the same, when the shell lint runs, then it
      still fails.
- [ ] Given `scripts/test-check-shell.sh`, when it runs, then a case pins each.

## Read first

- Touches: `scripts/check-shell.sh`, `scripts/test-check-shell.sh`

## Blocked by

- None (can start immediately)

## Mode

unattended: the criteria decide it; stop after two failed attempts and hand off with the state
written here.
