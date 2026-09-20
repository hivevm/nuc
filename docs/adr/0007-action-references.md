# ADR-0007: GitHub Actions are referenced by their major version tag and kept current by Dependabot

- **Status:** 🟢 accepted
- **Date:** 2026-09-20
- **Deciders:** NUC maintainer
- **Applies to:** every `uses:` reference in `.github/workflows/`, and `.github/dependabot.yml`

## Context

The workflows under [`.github/workflows/`](../../.github/workflows/) run third-party code with the
repository's token: every `uses:` line pulls an action at the reference it names. How that
reference is written decides two things at once, how current the action stays and how much a
compromise of its repository can reach. GitHub's hardening guide recommends the full commit SHA:
"Pinning an action to a full-length commit SHA is currently the only way to use an action as an
immutable release", because a tag "can be moved or deleted if a bad actor gains access to the
repository storing the action". That is what happened to `tj-actions/changed-files` in March
2025 (CVE-2025-30066): version tags were retagged to a commit that printed the runner's secrets
into the workflow logs.

The workflows reference their actions by major version tag (`actions/checkout@v7`), and
[ADR-0002](0002-dev-container-runtime.md) pins Dev Container Features the same way, with a lock
behind them. Nothing records why the workflows deviate from the guide, and nothing keeps the
format: a reference to a branch, a SHA, or an untagged action passes review unseen. A reader who
knows the guide would take the major tag for a mistake and "fix" it, which is the case
[`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), rule 2, records however cheap it is to reverse.

## Decision

We will reference every GitHub Action by its **major version tag** (`uses: owner/action@vN`) and
let **Dependabot** raise the pull request when a new major is published, from
`.github/dependabot.yml` with the `github-actions` ecosystem on a monthly schedule; a commit
SHA, a branch, an untagged action, and a full version tag are not used. A `docker://` image
carries an explicit tag. Local actions (`./…`) are exempt.

Accepted with it is the residual risk the guide names: a major tag is mutable, and a
compromised action repository can repoint it. The exposure is confined to first-party actions
(`actions/*`) in the template's own workflows; a project whose risk profile demands pin
integrity supersedes this ADR with SHA pinning and a stricter check.

**Out of scope:** which actions the workflows use; whether third-party actions may be added, and
under what review; a lockfile rule for the project's toolchain; Dependabot for Dev Container
Features, the follow-up ADR-0002 names, which needs its own look at how an update meets the
lock.

## Alternatives considered

- **Full commit SHA with a version comment** — immutable, and the guide's recommendation; but a
  SHA receives no updates at all, so every fix, security fixes included, arrives as a Dependabot
  pull request, and an unmerged one means running known-stale code. Right for a project that
  runs actions it does not trust; wrong for a template whose actions are first-party and whose
  maintainers are few.
- **Full version tag (`@v7.0.1`)** — as mutable as the major tag, so no integrity gained, and as
  frozen as a SHA. The worst of both.
- **A branch (`@main`)** — not a release: every upstream commit runs in CI unreviewed.
- **No update automation** — within a major the floating tag picks up releases by itself, but a
  new major needs a pull request; without Dependabot it is noticed when the old major stops
  receiving fixes.
- **A rule in prose** — the state this ADR ends: the format held by habit, and the deviation
  from the guide unexplained.

## Sources / Prior art

- GitHub, *Security hardening for GitHub Actions* —
  <https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions>:
  recommends the full commit SHA; this decision deviates for the reasons above.
- GitHub Advisory GHSA-mrrh-fwg8-r2c3 / CVE-2025-30066 —
  <https://github.com/advisories/GHSA-mrrh-fwg8-r2c3>: the retagging of `tj-actions/changed-files`
  and the exfiltration of CI secrets through workflow logs, the concrete case of the accepted
  risk.
- GitHub, *Keeping your actions up to date with Dependabot* —
  <https://docs.github.com/en/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot>:
  the `github-actions` ecosystem, `directory: /`, and the schedule keys.

## Consequences

- Positive: workflows pick up new releases of their major, security fixes included, with no pull
  request; `uses:` lines stay readable; a new major arrives as a reviewable pull request; the
  format is held by a check instead of by habit, and matches the Feature pinning of ADR-0002.
- Negative / trade-offs: a repointed tag runs in CI with the repository's read token before
  anyone sees a diff; Dependabot's pull requests are one more thing to review, monthly at most.
- Follow-ups: Dependabot for Dev Container Features, once the lock's behaviour under an update
  is known.

## Enforcement

`scripts/check-action-refs.sh` (job `actions` in
[`checks.yml`](../../.github/workflows/checks.yml)) reads every uncommented `uses:` line of the
workflows and fails on a reference that is not a major version tag, on a `docker://` image
without a tag, and on a missing `dependabot.yml` or one without the `github-actions` ecosystem.
Its self-test cites this ADR ([ADR-0003](0003-decisions-verified-by-tests.md)). Not checked:
whether an action is first-party, which is review, and whether Dependabot is enabled for the
repository, which is a setting.
