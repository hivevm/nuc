# Ticket: The hooks are the pinned shims of nuc, with nuc.toml, the Feature, and CI

## What to build

The tracer; `nuc-tools` v0.2.2 is published. `.githooks/` holds the shims of
`nuc-tools` v0.2.2 or later, a blob list pins them, and a check with its self-test fails where a
hook differs, or where `nuc.toml` names a lower `minimum` or lacks a `hook/` rule. The template
ships `nuc.toml` with `minimum` and every `hook/` rule. The Dev Container installs `nuc` by its
Feature, locked, and `scripts/check-devcontainer.sh` fails without it; each CI job that runs a hook
installs it by `hivevm/nuc-tools@v0`. `scripts/test-git-hooks.sh` asserts each refusal by its key
and exit code. The Git hooks section of `CONTRIBUTING.md` says a hook needs `nuc` and how to install
it. NUC-checks-are-bash is corrected in place: clause 3 points to NUC-hooks-run-nuc, and its scope
and latitude hand the hooks to it.

## Acceptance criteria

- [ ] Given a fixture with the hooks and the released `nuc` on the `PATH`, when
  `scripts/test-git-hooks.sh` runs, then every case passes on its key and exit code.
- [ ] Given a hook edited by hand, when the pin's check runs, then it fails naming the hook.
- [ ] Given `nuc` missing, or older than `minimum`, when a hook runs, then it refuses in its key
  and names how to install or update `nuc`.
- [ ] Given a Dev Container definition without the `nuc` Feature, when
  `scripts/check-devcontainer.sh` runs, then it fails.
- [ ] Given `scripts/test-normalize-remap.sh`, when it runs a cycle of the real tree, then
  `test-git-hooks.sh` passes after it.
- [ ] Given CI, when the checks run, then every job passes with the hooks as shims.

## Read first

- Touches: `.githooks/`, the blob list beside it, a check and its self-test under `scripts/`,
  `nuc.toml`, `.devcontainer/devcontainer.json`, `.devcontainer/devcontainer-lock.json`,
  `.github/workflows/checks.yml`, `scripts/test-git-hooks.sh`, `scripts/check-all.sh`,
  `scripts/check-devcontainer.sh`, `CONTRIBUTING.md`, `docs/adr/NUC-checks-are-bash.md`,
  `docs/adr/NUC.blobs`
- NUC-hooks-run-nuc; `shims/` of `nuc-tools` v0.2.2 and its README; `nuc-tools`'
  `tests/tables.blobs` as the pattern of a pin

## Blocked by

- docs/plan/hooks-run-nuc/01-propose-the-adr-of-the-switch.md

## Mode

with the human: the hooks and CI are the gates every project inherits.
