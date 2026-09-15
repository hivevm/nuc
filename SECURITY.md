# Security Policy

## Reporting a vulnerability

Please report security vulnerabilities **privately** — do not open a public issue or pull request.

- Use GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
  (**Security → Report a vulnerability**) if enabled, or
- email the maintainer: <!-- TODO: add a security contact address -->.

Please include enough detail to reproduce the issue (affected version/commit, steps, and impact).
We aim to acknowledge reports within a reasonable time frame and will coordinate a fix and
disclosure with you.

## Dev Container & agent execution

This template runs coding agents inside the Dev Container defined in
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json). Two properties shape its
security posture:

- **The Dev Container has no access to the host container engine.** The host Docker/Podman socket is
  **not** mounted into the container (see [ADR-0003](docs/adr/0003-dev-container-runtime.md)), so
  code or agents running inside cannot control the host engine. Host containers are managed from a
  host-side VS Code extension (see the README), keeping that capability outside the container's
  reach. The container is still not a strong security boundary, so run only agents and code you
  trust in it.
- **Git and GitHub writes require explicit human approval.** The agent must get a go-ahead before
  each commit, push, or `gh` action ([`AGENTS.md` §6](AGENTS.md#6-project-rules)). For Claude Code
  this is enforced, not just documented: [`.claude/settings.json`](.claude/settings.json) prompts on
  every command that writes history (`add`, `commit`, `push`, `merge`, `rebase`, `cherry-pick`,
  `revert`, `tag`), on the ones that can discard uncommitted work (`reset`, `restore`, `checkout`,
  `switch`, `branch`, `clean`, `stash`, `submodule`), and on `gh`. Authentication uses `gh`'s web
  flow with no stored tokens. That file is Claude Code's own format; for an agent without an
  equivalent mechanism the rule is documentation only.
- **The specification and the decision record change only by human decision.** A change to
  [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) is a decision rather than an edit, and only a
  human changes an ADR's status ([`AGENTS.md` §3](AGENTS.md#3-adr-rules)). For Claude Code this is
  enforced: [`.claude/settings.json`](.claude/settings.json) prompts before any edit to the
  specification or to anything under [`docs/adr/`](docs/adr/), a new ADR file included. The review
  half is [`.github/CODEOWNERS`](.github/CODEOWNERS) together with the Code-Owner review requirement
  listed under [**Repository settings**](README.md#repository-settings). Four limits are worth
  knowing. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) is deliberately not gated, because
  [§5](AGENTS.md#5-quality-bar--definition-of-done) requires it to change in the same commit as the
  structure it describes. The prompt covers the agent's editing tools and the file commands it
  recognizes in a shell — a redirect, `sed` — but not a subprocess that opens a file itself.
  Answering an edit prompt with "don't ask again" lifts the gate until the session ends, so drafting
  an ADR, which prompts on every edit, can switch off the prompt that was meant to catch the status
  flip. And a code owner GitHub does not know matches nobody, so the file enforces nothing until it
  carries a real handle. For an agent without an equivalent mechanism the rule is documentation
  only, as with the git rules above.

## Secrets

The rule is in [`AGENTS.md` §7](AGENTS.md#7-secrets) and that wording governs: a secret never enters
a tracked file, a commit message, an ADR, a log, or CI output, and one that reaches git is rotated
rather than deleted from the tip of a branch ([ADR-0004](docs/adr/0004-secrets-handling.md)). What
this section records is what the repository's own configuration does about it, which is less than
the rule asks.

Two mechanisms keep environment files out of the way: [`.gitignore`](.gitignore) leaves `.env*`
untracked in every directory, with a secrets-free `.env.example` as the one tracked exception, and
[`.claude/settings.json`](.claude/settings.json) denies Claude Code read access to the same pattern,
so their contents cannot reach the agent's context and from there a file, a commit message, or a
log.

Three limits are worth knowing, and this section states them rather than leaving them to be found.
The deny pattern also covers a tracked `.env.example`, whose shape an agent is told rather than
shown. It is a permission rule on one agent's file-reading tool, not a sandbox, and it reaches no
other agent — for an agent without an equivalent mechanism the rule is documentation only, as with
the git rules above. And the two together are not enforcement of the rule: they close one path for
one agent, while a secret that arrives by any other — typed into a commit message, echoed by a
workflow step, pasted into an ADR — is caught by review or by GitHub's secret scanning with push
protection, which is a repository setting (see [**Repository settings**](README.md#repository-settings))
and does nothing until a maintainer enables it. No check in this repository looks for a secret;
ADR-0004 explains why a regex scan in [`scripts/`](scripts/) would be false confidence rather than
enforcement.

## Supported versions

Security fixes are delivered on the current state of the default branch only — older states are not
patched.
