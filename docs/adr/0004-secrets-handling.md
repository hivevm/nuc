# ADR-0004: Secrets never enter the repository; a leak is remediated by rotation

- **Status:** 🟡 proposed
- **Date:** 2026-09-15
- **Deciders:** Maintainer
- **Applies to:** anything that could hold a secret — tracked files, commit messages, ADRs, logs, CI output
- **Note:** Reinstates the baseline the template's seed decision on secrets carried. That record was
  removed together with the rest of the seed set while all of them were still `proposed`; the
  removal settled the set, it did not weigh this baseline and find it wrong. Putting it back is a
  decision rather than a repair, so it comes as an ADR and not as an edit to the rule file.

## Context

Coding agents read, write, and execute far more than a careful human would, so a secret that lands
in a tracked file, a commit message, or CI output spreads fast — and irreversibly: the moment a
commit is pushed, the secret exists on every clone and in every fork, beyond the reach of any later
edit.

What the repository does about this today is two mechanisms and no rule, and
[`SECURITY.md`](../../SECURITY.md) says so in as many words: [`.gitignore`](../../.gitignore) leaves
`.env*` untracked, and [`.claude/settings.json`](../../.claude/settings.json) denies one agent's
file-reading tool access to the same pattern. Both narrow the most likely accident — an agent
reading an environment file into its context and from there into a file it writes. Neither states
where secrets do live, what happens after one leaks, or anything at all to an agent that does not
read that settings file. A rule the rule file does not carry is not a rule of this project
([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)), so the baseline currently rests on whoever is
reviewing.

One further force shapes the answer: a scanning toolchain would be a new dependency, which
[`AGENTS.md` §1](../../AGENTS.md#1-principles) admits only for a concrete, present need and
[§3](../../AGENTS.md#3-adr-rules) gates behind an ADR of its own — in a repository that ships no
code yet, and therefore no credentials of its own shape.

## Decision

We will keep secrets out of the repository entirely — never in tracked files, commit messages,
ADRs, logs, or CI output — by holding them in environment variables, gitignored `.env*` files, or
GitHub Actions secrets; by treating every secret that reaches git as compromised and rotating it
first, since deleting it from the tip of a branch is not remediation; and by relying on GitHub's
built-in secret scanning with push protection, enabled in the repository settings, as the one
mechanical backstop.

**Out of scope:** which vault or secret manager a project uses beyond the three locations named
above, how secrets are delivered to a deployed environment, and how external dependencies are
referenced and pinned — a topic this repository currently decides nothing about.

## Alternatives considered

- **Leaving it as description in [`SECURITY.md`](../../SECURITY.md)** — the state this ADR changes.
  That section records what the two mechanisms do and states no obligation, which is correct for a
  document that carries no rule of its own ([ADR-0001](0001-agent-governance-model.md)). It is also
  the whole problem: a description binds nobody, and the two mechanisms it describes cover one
  agent and one filename pattern, not the class of accident.
- **gitleaks (or similar) as a CI scanning step** — real scanning coverage, but a new pinned
  dependency with rule maintenance and false-positive tuning, for a repository that ships no code
  yet. A project can add it later through its own ADR; GitHub's built-in scanning covers the
  baseline until then.
- **A bash-regex secret scan in [`scripts/`](../../scripts/)** — dependency-free but weak: a handful
  of token patterns produce false confidence while missing most real leaks. Worse than relying on
  GitHub's maintained pattern set, and it would buy a green check for a gap this ADR would rather
  name.
- **Purging a leaked secret by rewriting history instead of rotating it** — treats the symptom. The
  rewrite cannot reach clones, forks, or caches that already have the commit; rotation is the only
  remediation that ends the exposure.

## Sources / Prior art

- [GitHub: secret scanning and push protection](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning)
  — the maintained pattern set this decision relies on instead of shipping its own.
- [GitHub: security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
  — secrets in workflow logs, and the masking that does not cover values derived from them.
- [GitHub: removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-secure/removing-sensitive-data-from-a-repository)
  — GitHub's own guidance names rotation first and history rewriting only as cleanup.

## Consequences

- Positive: a secrets baseline every project created from this template carries from its first
  commit; agents get a rule they can follow mechanically ("never write it down") instead of a
  description of two mechanisms that happen to be in place; the remediation order is stated before
  anyone needs it, when it is too late to reason it out.
- Negative / trade-offs: enforcement is review plus a repository setting, not a check script — a
  secret committed in a repository whose scanning is switched off is caught by nobody; secret
  scanning and push protection have to be enabled by hand, so the backstop is absent until a
  maintainer acts; GitHub's pattern set covers known token formats, not a project's own credential
  shapes.
- Follow-ups: per-project scanning tooling can be proposed in its own ADR once a project ships code
  whose credentials the built-in patterns do not recognize. Whether the two mechanisms that exist
  today should be widened — the deny rules reach one agent, and no equivalent exists for any other
  — is left open here; it is a question about agent tool configuration, not about the baseline.

## Enforcement

Secret scanning with push protection is a repository setting, listed under **Repository settings**
in [`README.md`](../../README.md) — no file in the repository can enable it, and nothing in CI can
see whether it is on. The rules themselves are review-only by design: the rejected alternatives
above explain why a regex scan in [`scripts/`](../../scripts/) would be false confidence rather than
enforcement. Naming that gap here is deliberate — this is the one rule in the repository with no CI
job behind it.

The two existing mechanisms are not enforcement of this decision and are not claimed as such. They
remove one specific path — an agent reading `.env*` into its context — for one agent, and
[`SECURITY.md`](../../SECURITY.md) records what they do and where they stop.
