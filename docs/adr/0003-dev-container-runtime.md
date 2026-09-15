# ADR-0003: The Dev Container: mandatory, base free, no host daemon, Features pinned

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer
- **Applies to:** `.devcontainer/`, `.vscode/settings.json`, and everything the container pulls in
- **Note:** Originally accepted 2026-06-22 as *Debian Dev Container without host Docker access*.
  Reverted to proposed and reworked on 2026-08-23 by the maintainer to unbind the container base
  from Debian; accepted again in its reworked form on 2026-09-01. Returned to `proposed` on
  2026-09-05 together with the rest of the set, and consolidated on the same day with a separately
  proposed decision on pinning the container's Features — one artifact, one record. Both moves are
  possible because this record is still `proposed` — the immutability set out in
  [`README.md`](README.md) in this directory binds an *accepted* ADR
  ([process rule 5](README.md#process)).

## Context

The template must provide a reproducible, ready-to-use environment without committing to any
language toolchain (it has to stay language-agnostic). An earlier version of this decision fixed
the base to `mcr.microsoft.com/devcontainers/base:debian` — simple, but it makes every project
start from a generic Debian image regardless of its stack: a Rust or Node project wants its
language image, a project with system-level dependencies wants its own `Dockerfile`, and a project
that needs auxiliary services (database, broker) wants Docker Compose. A fixed base forces those
projects to either fight the checked-in container or abandon it.

The security requirement is unchanged: coding agents frequently want Docker access, and the obvious
way to grant it — the `docker-outside-of-docker` Feature — bind-mounts the **host** Docker socket
into the container, which hands host-level control to anything running inside (recorded in
[`SECURITY.md`](../../SECURITY.md)). Managing the host's containers from VS Code is a host-side
capability and does not require exposing the socket.

Beyond its base, the container pulls in two further kinds of third-party code, and neither had a
rule. **Features** are declared in [`devcontainer.json`](../../.devcontainer/devcontainer.json) —
today one entry, `ghcr.io/devcontainers/features/github-cli:1` — and execute at container build
time. **Editor extensions** are declared in the same file and run inside the container once it is
up; two of the three shipped are coding-agent extensions. Both were settled without anyone settling
them: the Feature reference is a major version tag by habit rather than by rule, and
`.devcontainer/devcontainer-lock.json`, which resolves that tag to a version and an immutable
digest, sits in [`.gitignore`](../../.gitignore) under a bare `# Dev Container` heading with no
reason recorded — an unrecorded exception to a rule this repository states elsewhere, that a
lockfile is committed.

What raises the stakes for both is the mount: the container bind-mounts the host's agent
configuration directory, so the credentials a coding agent authenticates with are reachable from
inside it. Code that runs at container build, and code that runs in the editor afterwards, runs
next to those credentials.

The two cases are not symmetric, and the asymmetry decides them. A Feature tag is **mutable** —
`:1` can be repointed by whoever controls the Feature's repository. A published extension version
is **immutable**: `anthropic.claude-code` without a version is a moving target, but no concrete
version is ever replaced by different content. Pinning a Feature therefore buys integrity; pinning
an extension buys reproducibility only.

## Decision

We will **require a Dev Container** for every project created from this template, leave its base to
the project, keep the host daemon out of reach, and pin what the container fetches to the degree
each kind of artifact actually warrants. [`AGENTS.md` §6](../../AGENTS.md#6-project-rules) states
the four clauses below as the working rule and its wording governs where the two differ
([§3](../../AGENTS.md#3-adr-rules)); this record supplies the reasoning.

**Base — free.** The project sets its own container source in
[`devcontainer.json`](../../.devcontainer/devcontainer.json), using whichever of the three sources
the Dev Container specification offers fits it:

- **image** — a published container image (`"image"`), e.g. a language-specific Dev Container image;
- **dockerfile** — a project-owned `Dockerfile` (`"build"`), when a toolchain or system packages
  must be baked in;
- **compose** — a `docker-compose.yml` (`"dockerComposeFile"` + `"service"`), when the environment
  needs auxiliary services alongside the workspace container.

Until a project chooses, the template ships `mcr.microsoft.com/devcontainers/base:debian` as a
neutral placeholder — a default, not a rule. Nothing automates the switch: it is one field in a
short file the project owns, and a mechanism that asks for it once would add more moving parts
than the edit it saves ([`AGENTS.md` §1](../../AGENTS.md#1-principles)).

**Host daemon — out of reach, in every variant.** **No host Docker socket is mounted** and no
Docker Feature that would mount it is added, so the container has no access to the host daemon.
Host containers are managed from a VS Code extension pinned to the **host (UI) side** via
`remote.extensionKind` in [`.vscode/settings.json`](../../.vscode/settings.json). This invariant
holds across all base variants and is the load-bearing clause of this record: an ADR that
supersedes any other part of it restates this one or it is lost.

**Features — pinned.** Each Feature is named by its major version tag, and
`.devcontainer/devcontainer-lock.json` — the resolved version and digest behind those tags — is
committed rather than ignored, so the same commit yields the same environment until the lock is
deliberately refreshed. The mutable tag stays readable in the file a human edits; the immutable
digest is recorded next to it.

**Extensions — deliberately not pinned.** They are listed by identifier only. Three reasons, and
they are recorded here so that the absence reads as a decision rather than an oversight: a
published version is immutable, so there is no repointing vector for a lock to close; there is no
extension lock file and no update automation, so a pin would freeze actively developed agent
extensions with nothing to remind anyone to bump them; and the `publisher.name@version` syntax is a
VS Code implementation detail, absent from the Dev Container specification, so it would silently do
nothing in another compatible IDE — which [`README.md`](../../README.md) explicitly invites. What
protects this surface is the same thing that protects the container generally: it is not a security
boundary, and only agents and code you trust belong in it ([`SECURITY.md`](../../SECURITY.md)).

**Out of scope:** which base a given project actually picks and which Features and extensions it
declares (per-project choices, not rules of this template); the language toolchain that goes into
the container; hardening the container itself — it is not a security boundary, only a boundary
against the host daemon; how often the lock is refreshed and by what mechanism; and how external
code is referenced *outside* the container, which this decision does not reach.

## Alternatives considered

- **Fixed Debian base for every project** (an earlier form of this decision) — simplest and
  uniform, but contradicts the template's language-agnostic goal in practice: real projects
  immediately need their own base, and a template that must be fought is a template that gets
  abandoned.
- **Always require a project `Dockerfile`** — uniform and explicit, but heavier than needed; for
  most projects a published image reference is sufficient and easier to keep current.
- **Leave the environment entirely to each project (no Dev Container requirement)** — loses the
  reproducible first-run the template promises and invites ad-hoc setups that mount the host
  socket for convenience.
- **Wire the base into the first-run bootstrap** — ask for image, Dockerfile, or Compose at
  initialization and rewrite the environment definition. Rejected: it buys one edited field at the
  price of a question, generator logic, and self-test surface, in a script whose purpose is to
  remove *policy* text that cannot be pruned reliably by hand — which a container base can.
- **`docker-outside-of-docker`, docker-in-docker, rootless engine in the container** — all rejected
  for the same reasons as in the original decision: host-socket exposure, privileged nesting, or an
  isolated engine that cannot manage host containers anyway.
- **Keep ignoring the Feature lock file** — the arrangement this decision ends. Every rebuild
  resolves the tag afresh, so two developers on the same commit can end up with different Feature
  versions, and a repointed tag reaches the machine where the agent's credentials are mounted
  before anyone reviews a diff.
- **Pin the Feature digest directly in `devcontainer.json` and keep ignoring the lock** —
  reproducible, but it buries an immutable hash in the one file a human edits by hand and loses the
  readable major tag. The split between a legible tag and a generated lock is what the lock is for.
- **Pin the extensions too, for symmetry** — rejected above on its merits, not for tidiness: it
  would buy reproducibility at the price of staleness in exactly the components a coding-agent
  template most needs current, and it would not work outside VS Code.
- **Deciding the pinning rules in a separate ADR on how external dependencies are referenced** —
  the natural home by subject, and wrong by unit of change: what the container fetches is part of
  deciding *the container*, not a special case of how workflows reference actions. The two run in
  different places, under different threat models — a Feature executes at build time on the machine
  where the agent's credentials are mounted, an action executes in CI — and they are revised for
  different reasons, so a later change to either should not have to carry the other. Splitting them
  would also leave the reader of `.devcontainer/` with an incomplete record: three of the four
  things the container pulls in would be decided here and one somewhere else. Keeping the
  container's own pinning next to the container it applies to is what this consolidation is for.

## Sources / Prior art

- Dev Container specification — the three container sources (`image`, `build`, `dockerComposeFile`):
  <https://containers.dev/implementors/json_reference/>.
- Dev Container Features — <https://containers.dev/features>; the supporting-tools reference
  documents the extension array as "an array of extension IDs" and says nothing about versions:
  <https://containers.dev/supporting>.
- Extension version pinning as a VS Code implementation detail, tracked upstream:
  <https://github.com/microsoft/vscode-remote-release/issues/3253> and
  <https://github.com/orgs/devcontainers/discussions/200>.
- VS Code Dev Containers — forcing an extension to run locally/remotely via `remote.extensionKind`:
  <https://code.visualstudio.com/docs/devcontainers/containers>.
- Docker daemon attack surface (why mounting the socket grants host-level control):
  <https://docs.docker.com/engine/security/#docker-daemon-attack-surface>.
- [GitHub: security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
  — the reasoning about mutable references that applies to any fetched-and-executed third-party
  code, not only to actions.

## Consequences

- Positive: the environment fits the project from day one — language image, baked toolchain, or
  services via Compose — instead of forcing Debian on every stack; the security posture is
  identical in all variants; the same commit produces the same Feature set, which is what makes a
  *mandatory* container worth mandating; a changed Feature digest shows up in a diff where a
  reviewer meets it; and one record answers everything about `.devcontainer/` instead of three.
- Negative / trade-offs: switching the base stays a manual edit that nobody is prompted for, so a
  project can run on the placeholder longer than it meant to; Feature updates stop arriving on
  their own, and a stale lock is invisible; the lock file is written by tooling, so it will appear
  in diffs whose author did not intend to change it; extensions stay unpinned, so two developers
  can run different versions of the same agent extension; and this record now carries several
  clauses, which is why the host-daemon invariant is marked as the one a superseding ADR must
  carry forward.
- Follow-ups: whether an automated update path for Dev Container Features exists and should be
  wired up the way Dependabot covers actions — worth establishing before relying on manual
  refreshes, and a follow-up ADR if adopting one adds a dependency.

## Enforcement

None mechanical — review only, for every clause. Nothing checks that
[`devcontainer.json`](../../.devcontainer/devcontainer.json) mounts no host Docker socket and adds
no Feature that would; a reviewer has to see it in the diff. The file is short and the socket mount
is a visible line, which is why no check was written — not because the risk is small. Nothing in CI
builds the container either, so no job can notice that the lock and `devcontainer.json` have
drifted apart or that the lock is months stale; the tooling reconciles them on a developer's
machine, where no check of this repository runs. What the repository does carry is the absence of
the ignore line, which makes the lock a tracked file whose changes appear in review like any other.
