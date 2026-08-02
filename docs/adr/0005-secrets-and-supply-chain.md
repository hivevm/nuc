# ADR-0005: Secrets handling and action version policy

- **Status:** 🟡 proposed
- **Date:** 2026-07-21
- **Deciders:** Maintainer

## Context

Coding agents read, write, and execute far more than a careful human would, so a secret that lands
in a tracked file, a commit message, or CI output spreads fast — and the way CI references its
dependencies (actions, lockfiles) decides both how current and how tamper-resistant those
dependencies are. The template so far only gitignores `.env*` and forbids storing `gh` tokens
([`AGENTS.md`](../../AGENTS.md) §6); there is no lockfile rule, no action version rule, and no
scanning. Checks must remain pure bash + coreutils — a scanning toolchain would itself be a new
dependency.

## Decision

We will forbid writing secrets into tracked files, commit messages, ADRs, logs, or CI output
(secrets live in environment variables, gitignored `.env*` files, or GitHub Actions secrets, and a
leaked secret is rotated immediately — deleting it from the tip is not remediation); rely on
GitHub's built-in secret scanning with push protection, enabled in the repository settings; require
that when the chosen toolchain has a lockfile it is committed and CI installs from it; and
reference every GitHub Action by its **major version tag** (`uses: owner/action@vN`), so workflows
always run the newest release of that major — never a commit SHA (frozen, receives no updates) and
never a branch (not a release). Enforced by
[`scripts/check-action-refs.sh`](../../scripts/check-action-refs.sh); Dependabot
([`.github/dependabot.yml`](../../.github/dependabot.yml)) raises a PR when an action publishes a
new major version.

Choosing floating tags over immutable SHAs is a deliberate trade-off: a tag can be repointed by
whoever controls (or compromises) the action's repository — the `tj-actions/changed-files`
compromise (March 2025) is the concrete case, and GitHub's own hardening guide recommends SHA
pinning for third-party actions. This template accepts that residual risk in exchange for staying
current automatically (security fixes included) and for keeping `uses:` lines readable, and it
confines the exposure by using only widely-watched first-party actions (`actions/*`). A project
whose risk profile demands pin integrity reverses this with its own ADR and a stricter check.

## Alternatives considered

- **gitleaks (or similar) as a CI scanning step** — real scanning coverage, but a new pinned
  dependency with rule maintenance and false-positive tuning, for a template that ships no code
  yet. A project can add it later via its own ADR; GitHub's built-in scanning covers the baseline.
- **A bash-regex secret scan in `scripts/`** — dependency-free but weak: a handful of token
  patterns produce false confidence while missing most real leaks. Worse than relying on GitHub's
  maintained pattern set.
- **Pinning actions to a full commit SHA with a version comment** — the previous decision here.
  Immutable and therefore the strongest supply-chain posture, but a SHA receives no updates at
  all: every fix arrives only as Dependabot PR churn, and an unmerged PR means running known-stale
  code. Rejected in favor of automatic currency; the mutability risk is accepted and documented
  above.
- **Pinning to full version tags (`@v7.0.1`)** — as mutable as a major tag (no integrity gain)
  while updating exactly as poorly as a SHA. The worst of both.
- **No update automation at all** — even with floating major tags, major-version bumps still need
  a PR (they may contain breaking changes). Dependabot is GitHub-native (no new toolchain).

## Sources / Prior art

- [GitHub: secret scanning and push protection](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning)
- [GitHub: security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
  — recommends pinning third-party actions to a full commit SHA; this decision consciously
  deviates for the reasons above.
- CISA/GitHub advisories on the `tj-actions/changed-files` compromise (CVE-2025-30066) — a
  retagged action exfiltrating CI secrets; the accepted residual risk of floating tags.
- [GitHub: Dependabot version updates for GitHub Actions](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot)

## Consequences

- Positive: workflows pick up new releases (including security fixes) of the referenced major
  automatically, with no PR churn; `uses:` lines stay readable; a baseline secrets policy that
  agents can follow mechanically; lockfile rule is language-agnostic and ready for whatever
  toolchain a project adds; major-version bumps arrive as reviewable Dependabot PRs.
- Negative / trade-offs: tags are mutable — a compromised action repository can repoint one and
  CI executes the result with repository permissions (accepted, documented above; confined by
  using only first-party actions); secret scanning and push protection are repository settings
  that must be enabled manually (README setup checklist).
- Follow-ups: a release-policy ADR (versioning, changelog, and support statement); per-project
  scanning tooling (e.g. gitleaks) or a return to SHA pinning can be proposed in its own ADR when
  a project's risk warrants it.
