# Ticket: A pipeline whose status is read ends in no reader that exits early

## What to build

Under `set -o pipefail`, `producer | grep -q PATTERN` fails when `grep` finds its match and exits
before the producer has written its last line: the producer dies of SIGPIPE, the pipeline's
status is 141, and the test reads "no match". It happens only when the scheduler runs `grep`
between two writes, so it shows under load. That is the one-off failure of
`scripts/test-normalize-remap.sh` in its cycle of the real tree, which runs every self-test side
by side: `scripts/sensor-repo-settings.sh` tests each required check by
`printf '%s\n' "${actual[@]}" | grep -qxF -- "$name"`, and with `docs` the first of three lines,
its self-test reported "the required checks lack 'docs'". The same loop, run 240 000 times in 12
parallel shells, failed once. A flaky test is a defect
([`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done)), and here the defect is
in the scripts the test runs, not in the test.

The same shape stands where a check decides, so a finding can go missing, not only a test fail:

- `scripts/sensor-repo-settings.sh`, the two loops over the required checks;
- `scripts/check-devcontainer.sh`, the socket mount (step 1) and the host-side pin (step 4): a
  mounted socket could pass unreported;
- `scripts/sensor-binding-adrs.sh`, `finish()`: an *Applies to* in prose could go unlisted;
- `scripts/test-template-setup.sh`, `open_toolchain_job` and `open_golden_path`.

Each site reads its input whole before it matches (a here-string, a variable, or `grep -c`), and
`scripts/check-shell.sh` gains a rule beside the one on `sed -i` that refuses a pipe into
`grep` with `-q` on a line that is no comment, so the shape does not come back.

## Acceptance criteria

- [ ] Given a producer that writes a second line after a delay and a `grep -q` that matches the
      first, when each fixed site's form runs under `pipefail`, then it reports the match every
      time; a regression case in the self-test of the script it lives in, or in
      `scripts/test-check-shell.sh` for the form, fails before the fix.
- [ ] Given a script with `| grep -q` on a line that is not a comment, when
      `scripts/check-shell.sh` runs, then it fails and names the file and line; a here-string, a
      comment, and `grep -c` pass.
- [ ] Given the repository after the fix, when `grep -nE '\|[[:space:]]*grep -[a-zA-Z]*q'` runs
      over the shell scripts, then it lists no line outside comments and the self-test fixtures.
- [ ] Given `scripts/check-all.sh`, when it runs, then it is green.

## Read first

- Touches: `scripts/check-shell.sh`, `scripts/test-check-shell.sh`,
  `scripts/sensor-repo-settings.sh`, `scripts/test-sensor-repo-settings.sh`,
  `scripts/check-devcontainer.sh`, `scripts/test-check-devcontainer.sh`,
  `scripts/sensor-binding-adrs.sh`, `scripts/test-template-setup.sh`
- The rule on `sed -i` in `scripts/check-shell.sh` and its cases in `scripts/test-check-shell.sh`:
  the golden path for the new rule, its text spelled so the self-test passes its own lint.
- Other early readers, such as `head` or `awk` with `exit`, matter only where the pipeline's
  status is read; the session lists any it finds in the hand-off.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
