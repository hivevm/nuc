# NUC — an Agentic, Specification-Oriented Starter Template

[![Checks](https://github.com/hivevm/nuc/actions/workflows/checks.yml/badge.svg)](https://github.com/hivevm/nuc/actions/workflows/checks.yml)

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
> `setup-project` skill to be walked through them, one question at a time. Delete that file and
> this note once you are through them.

## Overview

Describe what this project does, who it is for, and its main goals. The full problem statement and
goals live in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md), the vocabulary in
[`docs/GLOSSARY.md`](docs/GLOSSARY.md).

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the
  [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  extension, or any DevContainer-compatible IDE
- Docker / Podman (rootless) available on the host

## Getting Started

> Setting the project up for the first time? The one-time steps are in
> [`TEMPLATE-SETUP.md`](TEMPLATE-SETUP.md). Delete this paragraph together with that file.

1. Open the repository in VS Code and choose **Reopen in Container**. The Dev Container and the
   preconfigured agent extensions build automatically, and the container enables the repository's
   git hooks ([`.githooks/`](.githooks/)): the local `main` moves only to what the remote's
   has, no push goes to it, the checks run before a push, and the documentation check before any
   other merge. It also makes every merge a merge commit, and every pull a fast-forward. Working
   outside the container? Do the same yourself, once per clone:
   `git config core.hooksPath .githooks`, `git config merge.ff false`, and
   `git config pull.ff only`.
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

## Project Layout

```
TEMPLATE-SETUP.md     # one-time template setup; delete it when the project is yours
README.md             # overview & setup for humans
AGENTS.md             # single source of truth for coding agents
docs/SPECIFICATION.md # the specification: problem, goals, success criteria
docs/GLOSSARY.md      # the vocabulary everyone uses, kept current inline
docs/CONVENTIONS.md   # how this project writes what no check decides, kept current inline
docs/ARCHITECTURE.md  # the system as it currently stands
docs/adr/             # Architecture Decision Records (+ template)
scripts/              # consistency checks and sensors (check-all.sh runs them all), run in CI
.githooks/            # git hooks: nothing lands on main locally; checks before a push
.github/              # CI workflows, Dependabot, issue & pull request templates, code owners
.devcontainer/        # Dev Container definition (base image + Features)
.vscode/              # shared editor settings
.editorconfig         # editor-neutral formatting baseline
.gitattributes        # line-ending normalization (LF everywhere)
.agents/skills/       # the procedures of AGENTS.md as Agent Skills, one directory each (ADR-0003)
.claude/CLAUDE.md     # pointer for Claude Code to read AGENTS.md
.claude/skills/       # pointers (one symlink per skill) for Claude Code to read .agents/skills/
.claude/settings.json # Claude Code permissions: deny reading .env files (see SECURITY.md)
```

## Dev Container

The environment is defined entirely in
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json). It starts from a prebuilt
base image and layers Dev Container Features and VS Code extensions on top; no Dockerfile or
Compose file is required. Customise the environment by adding Features, switching the base image,
or adding extensions. Features are pinned by major tag and resolved in the committed
`devcontainer-lock.json`. Extensions are listed by identifier only, because a published extension
version cannot be repointed and a version suffix is VS Code-specific.

### Host container management

The Dev Container deliberately has **no access to the host Docker daemon**: the socket is not
mounted ([ADR-0004](docs/adr/0004-dev-container-runtime.md)). To manage the host's containers from
VS Code, run the **Container Tools** extension (`ms-azuretools.vscode-containers`) on the **host**
side: install it in your host VS Code. [`.vscode/settings.json`](.vscode/settings.json) already pins
it to run locally via `remote.extensionKind`, so it keeps talking to the host engine even when this
folder is reopened in the container.

## Coding Agents

This Dev Container preinstalls the **Claude Code** and **Mistral Vibe** VS Code extensions (see
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json)); other agents (OpenAI Codex,
Cursor, OpenCode, GitHub Copilot) work too once you add them.

The rules every agent follows live in [`AGENTS.md`](AGENTS.md); that there is exactly one such file
is decided in [ADR-0001](docs/adr/0001-agent-governance-model.md). An agent that cannot read it
natively gets a pointer file instead. [`.claude/CLAUDE.md`](.claude/CLAUDE.md) is the one shipped
here; it carries the pointer and no rules of its own ([`AGENTS.md` §3](AGENTS.md#3-adr-rules)). It
exists for one gap only: Claude Code loads `CLAUDE.md`, not `AGENTS.md`, tracked upstream as
[anthropics/claude-code#34235](https://github.com/anthropics/claude-code/issues/34235). Once that
lands, delete the pointer file rather than keeping a second file to maintain.

The procedures those rules name (proposing an ADR, planning a feature, working its tickets
alone or in parallel, reviewing a change, revising the design, normalizing the record) are Agent
Skills under [`.agents/skills/`](.agents/skills/), the open format and the directory Codex,
Gemini CLI, and Cursor read
([ADR-0003](docs/adr/0003-procedures-as-skills.md)). An agent invokes one by name (`/review`) or
picks it up when the task matches its description. Claude Code reads `.claude/skills/` only, so
that directory holds one symlink per skill into `.agents/skills/`; a directory-level symlink is
not followed. The symlinks are pointers of the same kind as `CLAUDE.md`, tracked upstream as
[anthropics/claude-code#31005](https://github.com/anthropics/claude-code/issues/31005). Delete them
when that lands, and add one for every skill added meanwhile; the documentation check fails on a
skill without its pointer. A rule is enforced only by what every agent hits: the git hooks under
[`.githooks/`](.githooks/), the checks, and the repository settings below. A tool's own
configuration is not used to enforce one, because a gate that one agent honours and the next does
not looks like a rule and is not one.

Agents work tickets in parallel without any one vendor's mechanism: a dispatching session claims
each ticket by its branch in a git worktree of its own and starts a fresh session there, with the
non-interactive command of whichever agent the project's harness ADR names, and the session works
the ticket through the `work-tickets` skill.

## Integration branches

A change reaches `main` through a pull request. Several branches may integrate first on a
`feat/` branch by local merges, which stays the human's to rework until its pull request merges
([`AGENTS.md` §6](AGENTS.md#6-project-rules)). Each step waits for a human's instruction.

1. Start it at the remote's `main`: `git fetch origin`, then
   `git switch -c feat/<topic> origin/main`.
2. Merge a reviewed branch into it with its hand-off as the message:
   `git merge -F .scratch/<hand-off>.md <branch>`. The documentation check gates the merge, and
   the push of step 4 runs the rest. One that stops on a conflict is concluded, once resolved and
   staged, with `git commit -F .scratch/<hand-off>.md`, and all the checks gate that commit.
3. Rework it as often as needed: rebase it, regroup its commits, or drop what did not hold. A
   rebase without `--rebase-merges` flattens the merges, and their hand-offs with them; any
   rework replaces the commits their `Reviewed at:` lines name. The review that binds after a
   rework is a review of the whole branch, named on that line in the pull request's description.
   [`scripts/sensor-review-binding.sh`](scripts/sensor-review-binding.sh) reads it there first,
   on every push to the pull request and again on every edit of the description
   ([`review-binding.yml`](.github/workflows/review-binding.yml)).
4. Test it in the pipelines: `git push -u origin feat/<topic>`, then open a draft pull request,
   `gh pr create --draft --base main`, which runs them on every push against what the merge
   into `main` would produce. A branch kept without a pull request, such as an experiment, runs
   them by hand: `gh workflow run checks.yml --ref feat/<topic>`. A rework already pushed goes out
   with `git push --force-with-lease`.
5. Take up what the remote's `main` gained meanwhile, such as a Dependabot update, since the
   ruleset merges only a branch up to date with it: `git merge origin/main` on the `feat/`
   branch, gated like any merge. A rebase onto it is a rework, as in step 3.
6. Once the pull request has merged as a merge commit, take it up and drop the branch:
   `git switch main`, `git fetch origin`, `git merge --ff-only origin/main`, then
   `git branch -d feat/<topic>` and `git push origin --delete feat/<topic>`.

## Repository settings

Some of this project's rules cannot be enforced by files in the repository
([`AGENTS.md` §6](AGENTS.md#6-project-rules)). They are settings on the GitHub repository itself,
configured once by a maintainer and worth re-checking after a repository move or transfer:

- a **ruleset on `main`** that requires pull requests and allows the merge method **merge commit**
  only, since squash and rebase discard the merges a `feat/` branch carries and the commits it
  was reworked into ([`AGENTS.md` §6](AGENTS.md#6-project-rules)); requires the
  <!-- required-checks begin — compared with the workflow's jobs by scripts/check-docs.sh -->
  `docs`, `traceability`, `devcontainer`, `sensors`, and `shell`
  <!-- required-checks end -->
  jobs of the **Checks** workflow as required status checks (rulesets list checks by their job
  name) and a branch up to date with `main` before it merges, so that the checks see what the
  merge produces, such as two ADRs proposed in parallel under one number, and blocks force
  pushes and branch deletion;
- enable **require a review from Code Owners** on that ruleset, so the two artifacts only a human
  decides, [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) and everything under
  [`docs/adr/`](docs/adr/) ([`AGENTS.md` §3](AGENTS.md#3-adr-rules)), cannot be merged without the
  owner named in [`.github/CODEOWNERS`](.github/CODEOWNERS), which has to carry a real handle or
  team for the requirement to mean anything;
- enable **secret scanning with push protection**, the only mechanical backstop behind the secrets
  rule ([`AGENTS.md` §7](AGENTS.md#7-secrets)), which is otherwise carried by review alone;
- enable **private vulnerability reporting** (see [`SECURITY.md`](SECURITY.md)).

## Template

- **Template release:** v0.2.0 — the release of [NUC](https://github.com/hivevm/nuc) this
  repository carries; a project moves the line when it takes up a later one
  ([ADR-0005](docs/adr/0005-template-releases.md)).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow (specification- and ADR-driven, small
reviewable changes) and [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) for the community standards we
expect of everyone taking part. Security issues: please follow [`SECURITY.md`](SECURITY.md) instead
of opening a public issue.

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
