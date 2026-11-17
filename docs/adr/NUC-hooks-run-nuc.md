# NUC-hooks-run-nuc: The git hooks are the reference shims of `nuc`, pinned by their blobs, and refuse without the `nuc` that `nuc.toml` names

- **Status:** 🟡 proposed
- **Date:** 2026-11-17
- **Deciders:** NUC maintainer
- **Applies to:** the git hooks under `.githooks/` and the blob list beside them, `nuc.toml`, the installation of `nuc` in `.devcontainer/` and in the jobs of `.github/workflows/` that run a hook, and `scripts/test-git-hooks.sh`

## Context

The template ships its git hooks as bash scripts under `.githooks/`, and every derived project
carries a copy. A fix to a hook reaches a project only when it takes up a template release and
merges the copy by hand. A hook runs before any check can say which bash it found, so
[NUC-checks-are-bash](NUC-checks-are-bash.md) held each hook to bash 3.2, the one macOS ships, and
the hooks still need bash and its tools, which a contributor outside the Dev Container may lack.

`nuc`, the binary of `hivevm/nuc-tools`, ports every hook of the template from v0.5.0 to v0.11.0:
`nuc hook <name>` decides as the bash hook of the release a tree carries. `nuc-tools` releases
reference shims in POSIX sh that hand each hook to it, and from v0.2.1 on every refusal of a shim
ends in a key `[<rule>:<reason>]`. `nuc` reads `nuc.toml`, which names the minimum `nuc` a tree
requires and the rules it turns on; a `nuc` older than the minimum refuses. The Feature
`ghcr.io/hivevm/features/nuc` installs `nuc` in a Dev Container, and the Action of `nuc-tools`
installs it in CI. Both verify the binary against the checksums of its release.

A derived project cannot switch alone. `nuc-tools` tried, under
[NUC-checks-are-bash §8](NUC-checks-are-bash.md): the template's self-test of the hooks holds their
wording, the self-test of the normalize skill expects the hooks' citations to follow a map, which
the compiled messages of `nuc` cannot, and the check of the Dev Container asks for `.githooks` as
the hooks path. These files change with the hooks, so the switch happens in the template.

Three more forces bound the answer. A hook that passes when it cannot decide is a gate nobody has.
A shim edited by hand, or left behind a `nuc` release, decides something no release of `nuc`
tested. A test that holds a message's wording breaks on every rewording and on every map of a
normalization, while a key stays.

## Decision

We will make the template's git hooks the reference shims of `nuc`, pinned by their blobs, and have
each hook refuse where `nuc` is missing or older than `nuc.toml` names.

1. **Shims.** Each hook under `.githooks/`, `pre-commit`, `pre-merge-commit`, `pre-push`,
   `reference-transaction`, and `merge-adr-index`, is the file of the same name under `shims/` of a
   release of `hivevm/nuc-tools`, unchanged. A hook must need no more than a POSIX sh and `nuc` on
   the `PATH`. It hands its work to `nuc hook <name>`, which refuses and passes as the table of the
   git hooks in `CONTRIBUTING.md` says, and runs the checks as
   [NUC-checks-are-bash §6](NUC-checks-are-bash.md) decides.
2. **Pin.** A blob list beside the hooks names each hook's blob and the release of `nuc-tools` it
   comes from. A check fails where a hook's blob differs from the list. A newer release of the
   shims replaces the hooks and the list in one change.
3. **`nuc.toml`.** The template ships a `nuc.toml` at the root of the tree. Its `minimum` is at
   least the release the shims come from. Its `rules` name every `hook/` rule of that `nuc`, since
   with a `nuc.toml` its list governs which rules run. A project must not remove a `hook/` rule.
4. **Installation.** The Dev Container installs `nuc` by the Feature `ghcr.io/hivevm/features/nuc`,
   referenced and locked as
   [NUC-container-hides-host-daemon §3](NUC-container-hides-host-daemon.md) says. Each job of CI
   that runs a hook installs `nuc` by the Action of `hivevm/nuc-tools` before it.
5. **Refusal.** A hook without `nuc`, with a `nuc` older than the minimum, or with an answer of
   `nuc` it does not know, must refuse and end its message in its key. No hook falls back to bash.
6. **Self-test.** `scripts/test-git-hooks.sh` must assert each refusal by its exit code and its key,
   never by its wording, with the released `nuc` on the `PATH`.

**Out of scope:**

- the checks and sensors, which stay bash scripts under
  [NUC-checks-are-bash](NUC-checks-are-bash.md), and the rules of `nuc check` that would replace
  them;
- an update of `nuc` by `nuc` itself;
- how `nuc-tools` builds, tests, and releases `nuc` and its shims;
- hooks a project adds of its own.

## Latitude

A project may choose:

- further rules in `nuc.toml`. A rule that replaces a script of the template needs an ADR that
  narrows [NUC-checks-are-bash §1](NUC-checks-are-bash.md), under its clause 8;
- how a contributor outside the Dev Container installs `nuc`, which needs no ADR;
- how its workflows reference the Action of `nuc-tools`, from the entry
  [Action references](../../.agents/skills/propose-adr/concepts/action-references.md) of the
  catalogue.

## Alternatives considered

- **Keep the bash hooks.** A fix to a hook keeps reaching a project only by a merged copy, and a
  hook keeps needing bash and its tools.
- **Each project switches alone, under NUC-checks-are-bash §8.** `nuc-tools` tried it. The
  template's own self-tests and the check of the Dev Container hold the bash hooks, so a project
  would carry changed template files that every take-up merges again.
- **Move every check to `nuc` at once.** It removes more bash, but the checks behind `nuc check`
  are a larger change with its own parity to prove. The hooks go first, and the checks follow in
  a change of their own.
- **Fall back to the bash hooks where `nuc` is missing.** Two implementations decide one gate, and
  the fallback keeps every cost the switch removes. A contributor without `nuc` never learns that
  the hooks run on an old copy.
- **A hook that downloads `nuc` on its first run.** It puts the network into every hook and
  refuses work whenever the network fails. The Feature and the Action already install a verified
  binary.
- **Copy the shims without a pin.** A shim edited by hand would decide unseen, and a shim left
  behind a release would stay so until someone diffed it.

## Sources / Prior art

- Git, *githooks* — <https://git-scm.com/docs/githooks>: hooks are found through `core.hooksPath`
  and run as executables, in any language.
- `hivevm/nuc-tools`, the README of `shims/` and the release v0.2.1 —
  <https://github.com/hivevm/nuc-tools/releases/tag/v0.2.1>: the shims, their answers, and their
  keys.
- Dev Container Features — <https://containers.dev/features>: a Feature installs a tool at build
  time, locked by its digest.

## Consequences

- Positive: a fix to a hook ships once, in `nuc`, and reaches every project with its next `nuc`.
- Positive: a hook needs a POSIX sh, not bash, so clause 3 of NUC-checks-are-bash no longer binds a
  hook to bash 3.2.
- Positive: the self-test of the hooks asserts keys, so rewording a message breaks no test, and a
  normalization's map runs over the tree.
- Negative: a contributor installs `nuc` before the first commit; outside the Dev Container, by
  hand.
- Negative: every project's local gate depends on a release of `nuc-tools`. The checksums of the
  release and the lock of the Feature bound what reaches it.
- Negative: a change to the shims themselves still reaches a project only by a template release.
- Follow-ups: the checks behind `nuc check`; an update of `nuc` by itself.

## Enforcement

- `scripts/test-git-hooks.sh` runs every row of the table of the git hooks on fixture repositories
  with the hooks under `.githooks/`. It asserts each refusal by its exit code and its key, among
  them a hook without `nuc` and one with a `nuc` older than the minimum (clauses 1, 5, and 6). It
  cites this ADR.
- A check of the hooks' blobs against the blob list, with a self-test whose fixture holds a hook
  that differs, fails where a hook is not the shim it names (clause 2). Its self-test cites this
  ADR.
- `scripts/check-devcontainer.sh` holds the Feature's tag and lock (clause 4), as
  NUC-container-hides-host-daemon decides.

**Not mechanically decidable:** the review holds these judgements:

- whether `nuc.toml` names every `hook/` rule of the `nuc` its minimum names (clause 3);
- whether each job of CI that runs a hook installs `nuc` before it (clause 4).
