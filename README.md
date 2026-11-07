# NUC — an Agentic, Specification-Oriented Starter Template

[![Checks](https://github.com/hivevm/nuc/actions/workflows/checks.yml/badge.svg)](https://github.com/hivevm/nuc/actions/workflows/checks.yml)
[![Release](https://img.shields.io/github/v/release/hivevm/nuc)](https://github.com/hivevm/nuc/releases/latest)
[![License](https://img.shields.io/github/license/hivevm/nuc)](LICENSE)

**NUC** is named after the small *nucleus colony* a full hive grows from in beekeeping. It is a
starting point for building software **with coding agents** inside a ready-to-use Dev Container.
The work is driven by a written **specification**
([`docs/SPECIFICATION.md`](docs/SPECIFICATION.md)) and **Architecture Decision Records**
([`docs/adr/`](docs/adr/)), so intent and the reasoning behind every structural choice stay
explicit and reviewable.

> For agent instructions, see [`AGENTS.md`](AGENTS.md), the single source of truth for all coding
> agents.

> [!NOTE]
> **This project still carries its template setup.** The one-time steps that turn the scaffold
> into your own project are in [`TEMPLATE-SETUP.md`](TEMPLATE-SETUP.md); ask your agent to run the
> `setup-project` skill to be walked through them, one question at a time. Once you are through
> them, `scripts/test-template-setup.sh --close` removes that file and this note.

## Why NUC

NUC is a paved road for agentic coding: a repository template, not a tool to install, for how
humans and agents decide, review, and enforce. It ships no toolchain. A project starts from it
with what a codebase built by several humans and agents over years needs on day one:

- **One rule file for every agent.** [`AGENTS.md`](AGENTS.md) and the Agent Skills under
  [`.agents/skills/`](.agents/skills/) are read by Claude Code, Codex, Gemini CLI, Cursor, and
  others alike. No vendor's CLI or IDE is required.
- **Intent and decisions on record.** The specification is the constitution. Every structural
  choice is an ADR that a human accepts, and a normalization keeps the record readable as it
  grows.
- **Rules with teeth.** Git hooks and CI refuse what breaks the record: an accepted ADR no test
  cites, a broken link, a placeholder left behind, a commit or push on `main`.
- **Proportionate.** A small project takes a short path through the setup. A complex one grows
  to tickets worked by agents in parallel, each in a worktree of its own.

How it compares with other spec-driven approaches, as of October 2026:

| | NUC | [Spec Kit](https://github.com/github/spec-kit) | [Kiro](https://kiro.dev) | [OpenSpec](https://github.com/Fission-AI/OpenSpec) | [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) |
|---|---|---|---|---|---|
| Form | repository template | CLI and templates | IDE | CLI | agent personas |
| Agents | any that reads `AGENTS.md` | many, by slash commands | its own | several | several |
| Unit of work | specification, ADRs, tickets | spec, plan, tasks per feature | requirements, design, tasks per feature | change proposal with spec deltas | PRD, architecture, stories |
| Decisions kept as | ADRs with a lifecycle | constitution and plans | design documents | specs, updated by each change | architecture document |
| Enforced by | git hooks and CI checks | the agent's commands | IDE hooks | a validate command | the agent's workflow |

Where another fits better: OpenSpec is lighter for small changes to existing code. Spec Kit and
Kiro generate the spec, plan, and tasks of a feature by command. NUC asks for more setup in
exchange for checks that hold for every agent and every human, and it assumes GitHub.

## Overview

Describe what this project does, who it is for, and its main goals. The full problem statement and
goals live in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md), the vocabulary in
[`docs/GLOSSARY.md`](docs/GLOSSARY.md).

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the
  [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  extension, or any DevContainer-compatible IDE
- Docker / Podman (rootless) available on the host
- Outside the Dev Container: bash 4.4 or later for the checks, 3.2 for the git hooks
  ([ADR-0002](docs/adr/0002-decisions-verified-by-tests.md)); macOS ships 3.2

## Getting Started

> Setting the project up for the first time? Create the repository from the template, with
> **Use this template** on GitHub or with
> `gh repo create <owner>/<name> --template hivevm/nuc --public --clone`. A private repository
> needs a paid GitHub plan for the rulesets of
> [Repository settings](CONTRIBUTING.md#repository-settings).
> The one-time steps are in [`TEMPLATE-SETUP.md`](TEMPLATE-SETUP.md); the close of the setup
> removes this paragraph with that file.

1. Open the repository in VS Code and choose **Reopen in Container**. The Dev Container and the
   preconfigured agent extensions build automatically, and the container enables the repository's
   git hooks with the merge settings they rely on ([Git hooks](CONTRIBUTING.md#git-hooks)). Working
   outside the container? Run the three commands listed there yourself, once per clone.
2. Authenticate your coding agent inside the container (for Claude Code: `claude login`).
3. Start working with the agent. Drive the work from the specification and the ADRs.

## Build, Test & Run

<!-- Fill in once the toolchain is chosen. This section is the single source for
     build/test/lint/run commands; both humans and agents rely on it, and the rule file names
     it. -->

- **Build:** TODO <!-- e.g. `make build` -->
- **Test:** TODO <!-- e.g. `make test` -->
- **Lint:** TODO <!-- e.g. `make lint` -->
- **Run:** TODO <!-- e.g. `make run` -->

## Usage

<!-- Once there is something to use, show how to use the built software: the primary commands or
     API, a minimal example, and the expected output. Keep build/test/run mechanics in the section
     above; this section is about using the result, not producing it. -->

TODO — show a minimal example of using the project.

## Template

- **Template release:** v0.8.0 — the release of [NUC](https://github.com/hivevm/nuc) this
  repository carries; a project moves the line when it takes up a later one
  ([ADR-0005](docs/adr/0005-template-releases.md)).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow (specification- and ADR-driven, small
reviewable changes), the project layout, the Dev Container, the coding agents, the git hooks, the
integration branches, and the repository settings, and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
for the community standards we expect of everyone taking part. Security issues: please follow
[`SECURITY.md`](SECURITY.md) instead of opening a public issue.

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
