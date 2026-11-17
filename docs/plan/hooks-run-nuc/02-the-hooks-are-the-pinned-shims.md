# Ticket: The hooks are the pinned shims of nuc, with nuc.toml, the Feature, and CI

## What to build

The tracer. `.githooks/` holds the shims of `nuc-tools` v0.2.1 or later, a blob list pins them,
and a check with its self-test fails where a hook differs. The template ships `nuc.toml` with
`minimum` and every `hook/` rule. The Dev Container installs `nuc` by its Feature, locked; each CI
job that runs a hook installs it by `hivevm/nuc-tools@v0`. `scripts/test-git-hooks.sh` asserts each
refusal by its key and exit code. The Git hooks section of `CONTRIBUTING.md` says a hook needs `nuc`
and how to install it.

## Acceptance criteria

- [ ] Given a fixture with the hooks and the released `nuc` on the `PATH`, when
  `scripts/test-git-hooks.sh` runs, then every case passes on its key and exit code.
- [ ] Given a hook edited by hand, when the pin's check runs, then it fails naming the hook.
- [ ] Given `nuc` missing, or older than `minimum`, when a hook runs, then it refuses and names how
  to install or update `nuc`.
- [ ] Given `scripts/test-normalize-remap.sh`, when it runs a cycle of the real tree, then
  `test-git-hooks.sh` passes after it.
- [ ] Given CI, when the checks run, then every job passes with the hooks as shims.

## Read first

- Touches: `.githooks/`, the blob list beside it, a check and its self-test under `scripts/`,
  `nuc.toml`, `.devcontainer/devcontainer.json`, `.devcontainer/devcontainer-lock.json`,
  `.github/workflows/checks.yml`, `scripts/test-git-hooks.sh`, `scripts/check-all.sh`,
  `CONTRIBUTING.md`
- The ADR of ticket 01; `shims/` of `nuc-tools` v0.2.1 and its README; `nuc-tools`'
  `tests/tables.blobs` as the pattern of a pin

## Blocked by

- docs/plan/hooks-run-nuc/01-propose-the-adr-of-the-switch.md

## Mode

with the human: the hooks and CI are the gates every project inherits.
