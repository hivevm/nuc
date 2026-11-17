# Spec: The template's git hooks are the reference shims of `nuc`

## Problem

The template ships its git hooks as bash scripts under `.githooks/`, and every derived project
carries a copy of them. A fix to a hook reaches a project only when it takes up a template release
and merges the copy by hand. The hooks need bash and its tools, which a contributor outside the Dev
Container may lack.

`nuc`, the binary of `hivevm/nuc-tools`, ports every hook of the template from v0.5.0 to v0.11.0:
`nuc hook <name>` decides as the bash hook of the release a tree carries, and a POSIX sh shim hands
each hook to it. Its hook scenarios agree with the bash hooks on every template tree its corpus
pins. Its release v0.2.1 is published, and the Feature `ghcr.io/hivevm/features/nuc` installs it.

A derived project cannot switch alone. `nuc-tools` tried: the template's own self-test of the hooks
holds their wording, the normalize skill's self-test expects the hooks' citations to follow a map,
which the compiled messages of `nuc` cannot, and `check-devcontainer.sh` asks for `.githooks` as the
hooks path. The switch has to happen in the template, where those files change with the hooks.

## Solution

The template's hooks under `.githooks/` are the reference shims of `nuc`, copied from a release of
`nuc-tools` and pinned by their blobs. The Dev Container installs `nuc` by its Feature, CI by the
Action of `nuc-tools`, and the template ships a `nuc.toml` that names the minimum `nuc` and turns
the hook rules on. The self-test of the hooks asserts exit codes and keys, not wording. A derived
project that takes up the release installs `nuc` first and gets every later fix to a hook with a
`nuc` update.

## Existing behaviour

- The hooks refuse and pass as the table in the Git hooks section of `CONTRIBUTING.md` says. That
  stays: the shims with `nuc` refuse and pass alike, on every release a tree carries.
- `scripts/test-git-hooks.sh` exercises every row of that table on fixture repositories and holds
  the wording of each refusal. Its cases stay; what it asserts changes from wording to key.
- `scripts/test-normalize-remap.sh` runs `test-git-hooks.sh` after a cycle of the real tree. That
  stays, and passes once the hooks' assertions name keys, which carry no ADR identifier.
- `scripts/check-devcontainer.sh` holds the hooks path `.githooks` and the lock of the Features;
  `scripts/test-ready-for-main.sh` uses `.githooks/merge-adr-index` as its merge driver. Both stay.
- The checks the hooks run, `scripts/check-all.sh --changed` and `scripts/check-docs.sh`, stay bash.

## Goals served

- The template's goal that its gates hold for every agent and every human, now without bash in the
  hooks themselves.
- Fixes to a hook reach a project by a `nuc` update, not by merging a copy.

## User stories

1. As a maintainer of the template, I want the hooks to be the shims of `nuc`, so that a fix to a
   hook ships once, in `nuc`.
2. As a maintainer of a derived project, I want the take-up of this release to say that `nuc` comes
   first, so that no hook refuses for want of it.
3. As a contributor, I want a hook without `nuc` to refuse and name how to install it, so that no
   commit passes ungated.
4. As a contributor with too old a `nuc`, I want the hook to refuse and name the update, so that an
   old binary never decides a newer template's hooks.
5. As the maintainer, I want the shims pinned by their blobs, so that a shim edited by hand, or left
   behind a `nuc` release, is caught.
6. As the maintainer, I want the self-test of the hooks to assert keys, so that rewording a message
   of `nuc` breaks no test, and a normalization's map can run over the tree.

## Implementation decisions

- **The hooks.** `.githooks/{pre-commit,pre-merge-commit,pre-push,reference-transaction,
  merge-adr-index}` are the files of `shims/` of a release of `nuc-tools` that ends every refusal of
  a shim in a key, v0.2.1 or later.
- **The pin.** A blob list beside the hooks names each shim's blob and the `nuc` release it comes
  from. A check fails where a hook's blob differs, as the check of the copied fixture tables does in
  `nuc-tools`.
- **`nuc.toml`.** The template ships one: `minimum` the release of the shims, and `rules` every
  `hook/` rule, since with a `nuc.toml` its list governs them. The `docs/` and `traceability/`
  rules stay off; the checks are bash.
- **The binary.** The Dev Container installs `nuc` by the Feature `ghcr.io/hivevm/features/nuc`,
  pinned by the lock; CI installs it by the Action `hivevm/nuc-tools@v0` in each job that runs a
  hook.
- **The self-test.** `scripts/test-git-hooks.sh` keeps its cases and asserts each refusal by its key
  `[hook/<rule>:<reason>]` and its exit code.
- **The record.** A `NUC-` ADR decides the hooks' switch, superseding what of
  NUC-checks-are-bash and NUC-main-only-via-pr names the bash hooks. It changes a clause, so the
  release is a minor.

## Testing decisions

- **The seam** is `scripts/test-git-hooks.sh`, run on fixture repositories with the hooks under
  `.githooks/` and the released `nuc` on the `PATH`.
- **The pin's check** has its own self-test, a fixture whose hook differs from its blob.
- `scripts/test-normalize-remap.sh` passes unchanged once the hooks' test asserts keys.

## Out of scope

- The checks behind `nuc check`: a later spec, with the `docs/` and `traceability/` rules in
  `nuc.toml`, and the deletion of `check-docs.sh` and `check-traceability.sh`.
- `nuc upgrade`.
- A fallback to the bash hooks where `nuc` is missing.

## ADR impact

- Bind this work: NUC-checks-are-bash (clauses 1, 2, 3, 6, 8), NUC-main-only-via-pr (clause 6, the
  hooks' refusals), NUC-container-hides-host-daemon (clause 3, the lock; clause 6, the hooks path),
  NUC-releases-are-semver-tags (clause 3, the minor), NUC-procedures-are-skills.
- New, proposed in ticket 01: the `NUC-` ADR of the switch.
- Depended on `hivevm/nuc-tools`, both landed: the change there that ends every refusal of a shim
  in a key (hivevm/nuc-tools#102), and the release v0.2.1 that carries it.
