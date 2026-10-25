# Ticket: Write the base resolution, the file listing, and the error helpers once, in scripts/lib/

## What to build

Logic that is written several times moves into `scripts/lib/`, as the self-test setup already
did in `scripts/lib/selftest.sh`. This is an interface-preserving refactoring under the suites
that exist: expand, migrate the scripts in batches, contract, every step green.

- **The base of a comparison.** `origin/main`, else `main`, as merge base is written four times:
  `scripts/check-all.sh`, `scripts/sensor-binding-adrs.sh`, `scripts/sensor-tests-kept.sh`, and
  `scripts/sensor-review-binding.sh`.
  - The three sensors act on the repository of the current directory. Every other check finds it
    from its own path, as `.githooks/pre-push` says the checks do.
  - Path quoting is solved two ways: `-z` in one script, `core.quotePath=false` in another.
- **The files of the repository.** `git ls-files --cached --others --exclude-standard` filtered by
  `grep -I` appears in `scripts/check-docs.sh`, `scripts/check-traceability.sh`, and
  `scripts/check-shell.sh`. `.agents/skills/normalize/remap.sh` says it copies it.
- **The fixture copy.** Copying the tree into a fixture is written twice, with `tar` in
  `scripts/test-template-setup.sh` and with a `cp` loop in `scripts/test-check-traceability.sh`.
- **The check scaffolding.** `add_error` and `_contains` are copied in `check-docs.sh`,
  `check-traceability.sh`, and `check-devcontainer.sh`.
- **The self-test recording.** `expect()`, with the same pass/fail tail, is in 13 self-tests.
- **The skip and focus markers.** The `MARKERS` list of `scripts/sensor-tests-kept.sh` repeats the
  table of `.agents/skills/propose-adr/concepts/toolchain.md`. The sensor also hard-codes that
  document's path.

## Acceptance criteria

- [ ] Given each helper in `scripts/lib/`, when `git grep` searches `scripts/` and the skills'
      scripts for its former copies, then none is left.
- [ ] Given every step of the migration, when `scripts/check-all.sh` runs, then it passes, and
      no existing self-test case changed its expectation.
- [ ] Given a sensor run from a subdirectory of another repository, when it is called by its
      path, then it reads the repository it lives in, as the checks do (a new self-test case).

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (checks are bash scripts on the standard tools,
  each after its self-test)
- `scripts/lib/selftest.sh`, the golden path of a shared helper
- `scripts/check-all.sh` (`# Inputs:` lines: a self-test reruns when a library it sources changes)

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered. The refactoring is wide, so its batches are agreed first.
