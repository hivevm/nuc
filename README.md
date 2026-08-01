# NUC — an Agentic, Specification-Oriented Starter Template

<!-- The bootstrap script repoints this badge to your repository (--repo or the origin remote), or removes it. -->
[![Checks](https://github.com/hivevm/nuc/actions/workflows/checks.yml/badge.svg)](https://github.com/hivevm/nuc/actions/workflows/checks.yml)

**NUC** — in beekeeping, the small *nucleus colony* a full hive grows from — is a starting point for
building software **with coding agents** inside a ready-to-use
Dev Container. The work is driven by a written **specification** ([`docs/SPECIFICATION.md`](docs/SPECIFICATION.md))
and **Architecture Decision Records** ([`docs/adr/`](docs/adr/)), so intent and the reasoning
behind every structural choice stay explicit and reviewable.

> For agent instructions, see [`AGENTS.md`](AGENTS.md) — the single source of truth for all coding agents.

> [!NOTE]
> **Using this template.** This repository is a scaffold — turn it into your own project:
> <!-- module:init begin -->
>
> **First — initialize.** While [`scripts/init-template.sh`](scripts/init-template.sh) exists, this
> template is uninitialized: ask your coding agent to bootstrap, or run
> `bash scripts/init-template.sh --modules <choices|all|none>` yourself (`--list` shows the
> optional policy modules). The script prunes everything you did not choose, repoints the CI badge
> above to your repository (`--repo <owner/name>`, derived from the `origin` remote when omitted;
> without either, the badge is removed), and deletes itself — the full mechanism is decided in
> [ADR-0003](docs/adr/0003-template-bootstrap-and-module-selection.md). Then:
> <!-- module:init end -->
>
> 1. Replace the project name **NUC** everywhere it appears — the title and the intro sentence above,
>    and `"name"` in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).
> 2. Write your specification in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) and record
>    structural decisions as ADRs in [`docs/adr/`](docs/adr/).
>    <!-- module:conformance begin -->
>    Pin the external source you derive from in [`docs/CONFORMANCE.md`](docs/CONFORMANCE.md).
>    <!-- module:conformance end -->
> 3. Fill in the **Overview**, **Build, Test & Run**, and **Usage** sections below, and set the
>    security contact address in [`SECURITY.md`](SECURITY.md).
> 4. Add your language toolchain (the base image ships none).
> 5. Configure the GitHub repository settings that repository files cannot enforce:
>    - a **ruleset on `main`** that requires pull requests, requires the `docs` and `shell` jobs
>      of the **Checks** workflow as required status checks (rulesets list checks by their
>      job name), and blocks force pushes and branch deletion;
>    <!-- module:supply-chain begin -->
>    - add the `pins` job to that ruleset's required checks;
>    <!-- module:supply-chain end -->
>    <!-- module:git-conventions begin -->
>    - add the `git-conventions` job to that ruleset's required checks;
>    <!-- module:git-conventions end -->
>    <!-- module:supply-chain begin -->
>    - enable **secret scanning with push protection**;
>    <!-- module:supply-chain end -->
>    - enable **private vulnerability reporting** (see [`SECURITY.md`](SECURITY.md)).
>
> Project-specific conventions belong in the specification and ADRs — [`AGENTS.md`](AGENTS.md)
> stays constant and is not edited per project. Leave the **Dev Container**, **Coding Agents**, and
> **Project Layout** sections as-is; they describe the scaffold. Delete this note once you're done.

## Overview

Describe what this project does, who it is for, and its main goals. The full problem statement,
goals, and vocabulary live in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md).

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the
  [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  extension — or any DevContainer-compatible IDE
- Docker / Podman (rootless) available on the host

## Getting Started

> Setting the project up for the first time? See **Using this template** above for the one-time
> steps. This section covers the everyday workflow.

1. Open the repository in VS Code and choose **Reopen in Container** — the Dev Container and
   preconfigured agent extensions build automatically.
2. Authenticate your coding agent inside the container (for Claude Code: `claude login`).
3. Start working with the agent — drive the work from the specification and the ADRs.

## Build, Test & Run

<!-- Fill in once the toolchain is chosen. This section is the single source for build/test/run
     commands — both humans and agents rely on it (AGENTS.md links here). -->

- **Build:** TODO <!-- e.g. `make build` -->
- **Test:** TODO <!-- e.g. `make test` -->
- **Run:** TODO <!-- e.g. `make run` -->

## Usage

<!-- Once there is something to use, show how to use the built software: the primary commands or
     API, a minimal example, and the expected output. Keep build/test/run mechanics in the section
     above — this section is about using the result, not producing it. -->

TODO — show a minimal example of using the project.

## Project Layout

```
README.md             # overview & setup for humans
AGENTS.md             # single source of truth for coding agents
docs/SPECIFICATION.md # the specification: problem, goals, vocabulary
docs/adr/             # Architecture Decision Records (+ template)
scripts/              # repository consistency checks, enforced in CI
.github/              # CI workflows, issue & pull request templates
.devcontainer/        # Dev Container definition (base image + Features)
.vscode/              # shared editor settings
.claude/CLAUDE.md     # pointer for Claude Code to read AGENTS.md
.claude/settings.json # Claude Code permissions: prompt before git/gh writes
```

## Dev Container

The environment is defined entirely in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json):
it starts from a prebuilt base image and layers Dev Container Features and VS Code extensions on top —
no Dockerfile or Compose file required. Customise the environment by adding Features, switching the
base image, or adding extensions.

### Host container management

The Dev Container deliberately has **no access to the host Docker daemon** — the socket is not mounted
([ADR-0002](docs/adr/0002-dev-container-runtime.md)). To manage the host's containers from VS
Code, run the **Container Tools** extension (`ms-azuretools.vscode-containers`) on the **host** side:
install it in your host VS Code. [`.vscode/settings.json`](.vscode/settings.json) already pins it to
run locally via `remote.extensionKind`, so it keeps talking to the host engine even when this folder
is reopened in the container.

## Coding Agents

This Dev Container preinstalls the **Claude Code** and **Mistral Vibe** VS Code extensions (see
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json)); other agents (OpenAI Codex,
Cursor, OpenCode, GitHub Copilot) work too once you add them. Authenticate your agent inside the
container (for Claude Code: `claude login`).

The rules every agent follows live in [`AGENTS.md`](AGENTS.md); how each agent is wired to read them
is recorded in [ADR-0001](docs/adr/0001-agent-governance-model.md).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow (specification- and ADR-driven, small
reviewable changes) and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) for the community standards we
expect of everyone taking part. Security issues: please follow [`SECURITY.md`](SECURITY.md) instead
of opening a public issue.

## License

Released under the MIT License — see [`LICENSE`](LICENSE).
