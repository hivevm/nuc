# ADR-0004: Secrets never enter the repository; a leak is remediated by rotation

- **Status:** 🟡 proposed
- **Date:** 2026-09-15
- **Deciders:** Maintainer
- **Applies to:** anything that could hold a secret — tracked files, commit messages, ADRs, logs, CI output

## Context

Coding agents read, write, and execute far more than a careful human would, so a secret that lands in
a tracked file, a commit message, or CI output spreads fast and irreversibly: once pushed, it exists
on every clone and fork.

The repository has two mechanisms and no rule: [`.gitignore`](../../.gitignore) leaves `.env*`
untracked, and [`.claude/settings.json`](../../.claude/settings.json) denies one agent read access to
the same pattern. Neither says where secrets live or what happens after a leak. A scanning toolchain
would be a new dependency ([`AGENTS.md` §1](../../AGENTS.md#1-principles)) in a repository that
ships no code yet.

## Decision

We will keep secrets out of the repository entirely — never in tracked files, commit messages, ADRs,
logs, or CI output — by holding them in environment variables, gitignored `.env*` files, or GitHub
Actions secrets; by treating every secret that reaches git as compromised and rotating it first; and
by relying on GitHub's secret scanning with push protection as the one mechanical backstop.

**Out of scope:** which secret manager a project uses, how secrets reach a deployed environment, and
how external dependencies are pinned.

## Alternatives considered

- **Description in [`SECURITY.md`](../../SECURITY.md) only** — binds nobody, and the mechanisms it
  describes cover one agent and one filename pattern.
- **gitleaks or similar in CI** — a dependency with rule tuning, for a repository without code; a
  project can add it through its own ADR.
- **A bash-regex scan in [`scripts/`](../../scripts/)** — false confidence that misses most real
  leaks.
- **Rewriting history instead of rotating** — cannot reach clones, forks, or caches.

## Sources / Prior art

- [GitHub: secret scanning and push protection](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning).
- [GitHub: removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-secure/removing-sensitive-data-from-a-repository)
  — rotation first, history rewriting only as cleanup.

## Consequences

- Positive: a secrets baseline from the first commit; a rule agents can follow mechanically; the
  remediation order is stated before it is needed.
- Negative / trade-offs: the backstop is a repository setting that does nothing until a maintainer
  enables it, and GitHub's patterns do not know a project's own credential shapes.
- Follow-ups: project-specific scanning, once a project has credentials the built-in patterns miss.

## Enforcement

Review only, plus a repository setting: secret scanning with push protection, listed under
[**Repository settings**](../../README.md#repository-settings). No file can enable it, and no check
in this repository looks for a secret. The `.gitignore` and deny rules close one path for one agent
and are not claimed as enforcement.
