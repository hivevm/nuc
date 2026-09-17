# ADR-0003: The Dev Container: mandatory, base free, no host daemon, Features pinned

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer
- **Applies to:** `.devcontainer/`, `.vscode/settings.json`, and everything the container pulls in

## Context

The template must provide a reproducible environment without committing to a language toolchain. A
fixed base image makes every project start from generic Debian, while real projects want a language
image, their own `Dockerfile`, or Compose with auxiliary services.

Agents often want Docker access, and the obvious way — the `docker-outside-of-docker` Feature —
bind-mounts the **host** Docker socket, handing host-level control to anything inside. Managing host
containers from VS Code does not need the socket.

The container also pulls in third-party code that runs next to the agent credentials it mounts:
**Features**, executed at build time, and **editor extensions**, run afterwards. A Feature tag is
mutable and can be repointed; a published extension version is immutable. Pinning a Feature buys
integrity, pinning an extension only reproducibility.

## Decision

We will **require a Dev Container** for every project, leave its base to the project, keep the host
daemon out of reach, and pin Features but not extensions.
[`AGENTS.md` §6](../../AGENTS.md#6-project-rules) states these clauses as the working rule.

- **Base — free.** The project sets `image`, `build` (a `Dockerfile`), or `dockerComposeFile` in
  [`devcontainer.json`](../../.devcontainer/devcontainer.json). The shipped
  `mcr.microsoft.com/devcontainers/base:debian` is a placeholder.
- **Host daemon — out of reach.** No host Docker socket is mounted and no Feature that would mount
  one is added, in every variant. Host containers are managed from an extension pinned to the host
  side via `remote.extensionKind` in [`.vscode/settings.json`](../../.vscode/settings.json). **This
  is the load-bearing clause**; an ADR that supersedes another part restates it.
- **Features — pinned.** Named by major version tag, with `.devcontainer/devcontainer-lock.json`
  committed, so the same commit yields the same Features.
- **Extensions — not pinned.** Listed by identifier only: a published version cannot be repointed,
  nothing would remind anyone to bump a pin, and `publisher.name@version` is VS Code-specific and
  ignored by other compatible IDEs.

**Out of scope:** which base, Features, and extensions a project picks; its toolchain; hardening the
container, which is not a security boundary; and how the lock is refreshed.

## Alternatives considered

- **Fixed Debian base** — contradicts the language-agnostic goal; a template that must be fought is
  abandoned.
- **Always a project `Dockerfile`** — heavier than a published image for most projects.
- **No Dev Container requirement** — loses the reproducible first run and invites socket mounts.
- **`docker-outside-of-docker`, docker-in-docker, rootless engine inside** — host-socket exposure,
  privileged nesting, and an engine that cannot manage host containers anyway.
- **Ignore the Feature lock** — a repointed tag reaches the credentials before anyone sees a diff.
- **Digests directly in `devcontainer.json`** — buries hashes in the hand-edited file and loses the
  readable tag.
- **Pin extensions too** — staleness in the components an agent template most needs current, and no
  effect outside VS Code.

## Sources / Prior art

- Dev Container specification — <https://containers.dev/implementors/json_reference/> and
  <https://containers.dev/features>.
- Extension version pinning as a VS Code detail —
  <https://github.com/microsoft/vscode-remote-release/issues/3253>.
- `remote.extensionKind` — <https://code.visualstudio.com/docs/devcontainers/containers>.
- Docker daemon attack surface —
  <https://docs.docker.com/engine/security/#docker-daemon-attack-surface>.

## Consequences

- Positive: the environment fits each stack; the security posture is the same in every variant; the
  same commit gives the same Features, and a changed digest shows up in review.
- Negative / trade-offs: switching the base is a manual edit nobody is prompted for; Feature updates
  stop arriving on their own and a stale lock is invisible; two developers can run different
  extension versions.
- Follow-ups: whether an automated update path for Features should be wired up.

## Enforcement

None mechanical — review only. Nothing checks that
[`devcontainer.json`](../../.devcontainer/devcontainer.json) mounts no host socket, and no CI job
builds the container, so drift between the file and its lock goes unnoticed. The lock is tracked,
so its changes appear in review.
