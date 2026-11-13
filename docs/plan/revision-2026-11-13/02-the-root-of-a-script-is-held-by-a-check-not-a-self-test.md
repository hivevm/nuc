# Ticket: The root of a script is held by a check with rule keys, not by a self-test

## What to build

`scripts/test-check-all.sh` is the self-test of `scripts/check-all.sh`, yet two of its loops are
checks of the real tree: `guard_problem` holds every `scripts/*.sh` and skill script that sources
the bash floor, and `root_problem` holds every `scripts/*.sh` but the self-tests and
`check-all.sh` to `scripts/lib/root.sh`. The human decided on 2026-11-13 that the root rule binds
a derived project's own scripts (ticket 09). Three things follow from the rule's present home:

- **The rule stood only in the self-test.** A derived project's own script, such as the
  `check-build.sh` of step 6 of `TEMPLATE-SETUP.md`, failed it without a word why. The review of
  release v0.10.0 found it as a break the notes had missed; f57e923 then wrote the rule into
  `TEMPLATE-SETUP.md` and the layout of `CONTRIBUTING.md`.
- **The local gate skips it when an existing script loses its root.** The `# Inputs:` line of
  `test-check-all.sh` names `scripts/check-all.sh` and `scripts/lib/`. With `--changed`, as the
  pre-commit and pre-push hooks run it, an edit of an existing `scripts/<name>.sh` that drops its
  call of `enter_root` leaves the self-test "skipped — neither it nor its inputs changed", and only
  CI fails. A new script is held: the rule `docs/check-lists:orphan` makes its change edit
  `check-all.sh`, and that edit runs the self-test.
- **Its findings carry no key.** The convention "A check's cases are a table" of
  `docs/CONVENTIONS.md` asks for cases in a table under `scripts/fixtures/` and findings that end
  in a key, so that a port is held to the same cases. These loops have neither.

The two rules move into `scripts/check-shell.sh`, which reads every script on every run, with a
rule key each, cases in a table, and a message that a project understands: it names the rule, the
call that satisfies it, and where the rule is stated. As the human decided on 2026-11-13 for
ticket 01, the check also takes over the case the dropped cd guard held: it holds each script to
`rest_args`, which refuses a positional argument the script does not read.

## Acceptance criteria

- [ ] Given a branch that edits an existing `scripts/<name>.sh` to remove its call of
      `enter_root`, when `scripts/check-all.sh --changed` runs, then it fails and names the script
      and the rule key. Before the ticket's work, the run skips the check-all self-test for that
      edit: "skipped — neither it nor its inputs changed".
- [ ] Given a script that sources the bash floor and does not stop below bash 4.4 with its name,
      when the check runs, then it fails with a key of its own.
- [ ] Given `scripts/fixtures/check-shell.txt`, when the self-test of the check runs, then each
      row is a case, each expected finding is a key and its data, and the self-test reads the table.
- [ ] Given a finding of the root rule, when it is printed, then it names the call of
      `scripts/lib/root.sh` and the document a project reads for the rule, the layout of
      `CONTRIBUTING.md`.
- [ ] Given `scripts/test-check-all.sh`, when it is read, then it holds `check-all.sh` alone and
      no loop over the tree's scripts.

## Read first

- Touches: `scripts/test-check-all.sh`, `scripts/check-shell.sh`, `scripts/test-check-shell.sh`,
  `scripts/fixtures/check-shell.txt`, `scripts/lib/root.sh`, `CONTRIBUTING.md`,
  `TEMPLATE-SETUP.md`
- `CONTRIBUTING.md`, *Project Layout*; `TEMPLATE-SETUP.md`, step 6.
- `docs/CONVENTIONS.md`, the entry on tables.
- `scripts/fixtures/check-devcontainer.txt` and its reader in `scripts/lib/selftest.sh`, the golden
  path of a table.
- The description of PR #43, *Review*, third round.

## Blocked by

- docs/plan/revision-2026-11-13/01-the-cd-guard-of-the-root-check-is-dropped.md
- docs/plan/revision-2026-11-13/09-the-root-rule-binds-a-project-s-own-scripts.md

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. Past that, a
test decides each criterion, and a wrong result costs one revert. Stop and hand off when the rules
do not fit `scripts/check-shell.sh` and would need a new script in the three lists of
[NUC-checks-are-bash §5](../../adr/NUC-checks-are-bash.md).
