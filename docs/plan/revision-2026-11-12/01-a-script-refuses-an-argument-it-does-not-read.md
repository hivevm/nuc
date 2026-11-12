# Ticket: Every script takes its root as `--root <dir>` and refuses an argument it does not read

## What to build

Fifteen scripts under `scripts/` can run on a repository other than their own. They name that
root in two shapes, and each script resolves it with lines of its own:

- **Positional, unguarded.** Five take the root as their first argument and pass it to `cd`
  unchecked: `check-docs.sh`, `check-devcontainer.sh`, `check-traceability.sh`,
  `sensor-plan-frontier.sh`, and `sensor-revision-due.sh`.
- **Positional, guarded.** Four take it the same way and stop with exit 2, each with its own
  message: `check-shell.sh`, `sensor-action-refs.sh`, and `sensor-repo-settings.sh` stop on a path
  that is no directory, and `sensor-backlog.sh` stops on a path that is no git repository.
- **`--root <dir>`.** Six take a `--root` option and stop with exit 2 on a missing directory:
  `sensor-binding-adrs.sh`, `sensor-plain-rules.sh`, `sensor-review-binding.sh`,
  `sensor-tests-kept.sh`, `ready-for-main.sh`, and `drop-merged-branch.sh`. The four sensors also
  stop on `--verbose`, but only because they read it as a base commit that does not resolve, not
  as an option they refuse.

So the concept is written fifteen times, in two interfaces. That is the smell of an interface that
widened where one shape was due. The unguarded five fail open. Observed on 2026-11-12:

- `scripts/check-devcontainer.sh /nonexistent` passes with exit 0: no `.devcontainer/`, so
  nothing binds. A check passes on a tree it never read.
- `scripts/sensor-plan-frontier.sh --verbose` reports "no open tickets", while two are open.
- `scripts/sensor-revision-due.sh --verbose` says `docs/ARCHITECTURE.md` is not found, and
  `scripts/check-traceability.sh --verbose` runs `find` on `/docs/adr`.

**The decided shape.** Every one of the fifteen takes the root as `--root <dir>`. The root
defaults to the repository the script lives in. One function of `scripts/lib/` parses `--root` alone
and resolves the directory; a script's other options, such as `--sections`, `--require`, or
`--hand-off`, stay its own. A script stops with exit 2 and its own name on an argument that starts
with `-` and that it does not read. It also stops with exit 2 on a `--root` that is no directory.
A script that needs a git repository keeps that test of its own after the function. The self-tests,
`scripts/check-all.sh`, the hooks, the workflows, and the usage lines in headers and documents
pass `--root` where they passed a positional root. A self-test runs each of the fifteen with
`--verbose` and with `--root` on a missing directory, the way `scripts/test-check-all.sh` runs each
script below bash 4.4.

**Weighed against `NUC-checks-run-by-nuc`.** The proposal, on the branch
`docs/nuc-checks-run-by-nuc`, would move these scripts into the `nuc` binary. Until that change is
implemented and the scripts leave, a check that passes on a misread argument is a false green for
whoever runs it by hand. The gate never passes such an argument. Drop the ticket if the proposal
is implemented before the ticket is claimed. The change also alters the command line that the
parity harness of `hivevm/nuc-tools` may call the scripts with. The human confirms that the
harness does not depend on the positional root, or that it is changed with this ticket.

## Acceptance criteria

- [ ] Given each of the fifteen scripts, when it runs with `--verbose`, then it exits 2, and its
      message names the script and the argument.
- [ ] Given each of the fifteen scripts, when it runs with `--root` on a path that does not exist,
      then it exits 2. `scripts/check-devcontainer.sh` reports no pass.
- [ ] Given each of the fifteen scripts, when it runs with `--root <fixture>`, then it reads the
      fixture, as the self-tests show.
- [ ] Given the scripts after the change, when they are searched, then each of the fifteen calls
      the one function of `scripts/lib/` for its root. None passes its first positional argument
      to `cd`.
- [ ] Given the new self-test case, when the call of the function is removed from one script, then
      the case fails.

## Read first

- Touches: `scripts/lib/`, `scripts/check-docs.sh`, `scripts/check-devcontainer.sh`,
  `scripts/check-traceability.sh`, `scripts/check-shell.sh`, `scripts/sensor-plan-frontier.sh`,
  `scripts/sensor-revision-due.sh`, `scripts/sensor-action-refs.sh`,
  `scripts/sensor-repo-settings.sh`, `scripts/sensor-backlog.sh`, `scripts/sensor-binding-adrs.sh`,
  `scripts/sensor-plain-rules.sh`, `scripts/sensor-review-binding.sh`,
  `scripts/sensor-tests-kept.sh`, `scripts/ready-for-main.sh`, `scripts/drop-merged-branch.sh`,
  their self-tests `scripts/test-*.sh`, `scripts/check-all.sh`, `.githooks/`,
  `.github/workflows/`, and the documents that show a usage line of one of them
- The `--root` parsing of `scripts/ready-for-main.sh`, the shape to keep.
- The bash guard and its case per script in `scripts/test-check-all.sh`, the pattern to copy.
- `docs/CONVENTIONS.md`: "A self-test asserts what it builds".

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. The human
decides first whether the proposal `NUC-checks-run-by-nuc` makes the ticket moot, and confirms the
parity harness's command line. Past that, a test decides each criterion, and a wrong result costs
one revert. Stop and hand off when a script's root cannot be read by the one function, `--root`
alone, beside the options the script keeps. Also stop when the change does not fit one session:
then land the nine positional scripts first and leave the six that take `--root` already to a
ticket of their own.
