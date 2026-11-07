# The shell lint's rule on a pipe into grep -q holds a POSIX sh script without pipefail

Observed: the trial migration of nectar to v0.9.0 failed the shell lint on
`release/install-nectar.sh`, a `#!/bin/sh` script that sets no pipefail, at a
`printf … | grep -Eqx …` line. Without pipefail the pipe's status is grep's, so the hazard the rule
names does not arise there, and the fix it proposes, a here-string, is not POSIX sh. The trial
rewrote the line to count with `grep -c`, the rule's other proposal.

Where: the loop over `$QUIET_PIPE` in scripts/check-shell.sh, which reads every script whatever its
shell.
