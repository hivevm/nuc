# ADR-0003: Template bootstrap with selectable policy modules and repository identity

- **Status:** 🟡 proposed
- **Date:** 2026-07-21
- **Deciders:** Maintainer

## Context

The template ships optional governance policies — git conventions, secrets and supply-chain
pinning, versioning and releases, external conformance tracking — as seed ADRs with accompanying
scripts, workflows, and documentation passages. Projects legitimately differ in which of these they need, and policy text
that a project did not adopt decays and misleads agents,
violating simplicity-first ([`AGENTS.md`](../../AGENTS.md) §1). Pruning by hand or by free agent
judgment is non-deterministic and unverifiable. The mechanism must be deterministic, work for any
coding agent and for humans without one, and stay pure bash + coreutils — a templating toolchain
would itself be a new dependency.

The template also carries repository-specific identity: the README's CI badge points at the
template's own repository (`hivevm/nuc`) until it is repointed. Leaving that replacement to a
manual checklist step is exactly the by-hand pruning this decision rejects — easy to overlook,
and a wrong badge silently reports another repository's CI status.

## Decision

We will select policy modules once, at the first interaction in a project created from this
template, via `scripts/init-template.sh`:

- Each optional module owns files (listed in a bash manifest inside the script) and passages in
  shared files fenced by comment marker lines of the form `module:<name> begin` / `module:<name> end`
  (HTML comments in Markdown, `#` comments in YAML/bash). `<name>` may be a comma-separated list —
  the block is kept if *any* listed module is selected. Blocks are line-based and never nested.
- The script always strips marker lines; it strips the enclosed content only when no owning module
  is selected — so initialized files are clean in every combination.
- The human's selection **is** the acceptance decision: the script flips the chosen seed ADRs to
  `🟢 accepted` (the sanctioned exception to "only a human changes the status" — the human decides
  at selection time, the script merely executes it).
- Deselected seed ADRs are deleted, and so is this ADR: it decides a mechanism — script, markers,
  module selection — of which nothing survives in an initialized project, and a `proposed` record
  about a script that is no longer there would only mislead. The surviving ADRs are then
  renumbered to a gapless `0001..N` in a single ascending pass that rewrites every reference,
  preserving their relative order. This is the one sanctioned renumbering: at that moment nothing
  outside the tree cites these numbers yet, and afterwards the permanence rule applies unchanged.
- The presence of `scripts/init-template.sh` signals "not initialized"; marked hook instructions in
  `AGENTS.md` §2 and `README.md` tell the first agent to stop, ask, and run the script. The script
  removes the hooks and itself, then verifies the result with the remaining check scripts.
- The repository slug `hivevm/nuc` is the sanctioned **identity placeholder**; it appears only in
  the README's CI badge line and the instruction comment above it. The script resolves the real
  slug as a chain — explicit `--repo <owner/name>`, else derived from a `github.com` `origin`
  remote (only GitHub qualifies: the badge is a GitHub Actions badge) — and rewrites the badge.
  When neither source exists, badge and comment are removed entirely: no badge is better than one
  reporting another repository's CI. Interactive runs with no derivable slug ask, mirroring the
  module prompts; the instruction comment never survives initialization either way.
- Writing constraints, so post-initialization consistency greps stay clean by construction:
  files that survive a combination never cite a removable ADR — neither a seed ADR nor this one — in
  `ADR`-prefixed or link form, and show marker syntax only with the `<name>` placeholder;
  module-owned content in `AGENTS.md` is
  restricted to trailing sections or whole bullets, so removal never renumbers the `§N` headings
  that [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies. An ADR is referenced only
  as `ADR-NNNN` or as the link target `NNNN-<slug>.md` — **never as a bare number in prose**, which
  is what makes the renumbering rewrite total instead of a guess about which four digits mean an
  ADR. The identity placeholder follows the same discipline: `hivevm/nuc` appears nowhere outside
  the badge line and its instruction comment, which is what makes the repointing a total rewrite
  instead of a search through prose.

## Alternatives considered

- **One repository/branch variant per module combination** — 2⁴ variants to keep in sync; every
  template change multiplies; rejected as a maintenance explosion.
- **A templating engine (cookiecutter, copier)** — solves conditional content properly, but adds a
  Python toolchain to a deliberately toolchain-free template.
- **Ship everything and let each project prune by hand or agent judgment** — non-deterministic,
  unverifiable, and drifts; exactly the failure mode this decision removes.
- **Inverse markers ("keep this only when the module is NOT selected")** — adds a second semantic
  for one use case; a generic fallback sentence outside the block covers it.
- **Marking the badge as a strippable module block** — trivial to implement, but removes the badge
  even for projects that want it, and configures nothing: the actual slug would still need manual
  replacement, which is the failure mode being removed.

## Sources / Prior art

- [cookiecutter](https://cookiecutter.readthedocs.io/) and [copier](https://copier.readthedocs.io/)
  — conditional scaffold content via templating, the heavyweight version of this decision.
- [GitHub template repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)
  — repository-level scaffolding with no conditional-content mechanism, hence the marker approach.
- Preprocessor conditionals (`#ifdef`) — the same fence-and-strip idea, applied to documentation.

## Consequences

- Positive: projects start with only the policy they adopted, numbered `0001..N` without holes,
  and with a CI badge that is correct — or absent — from the first commit instead of pointing at
  the template; the initialized tree is verified by the existing consistency checks; the flow
  works for humans and any coding agent; adding a future module is a manifest entry, markers, and
  a test combination.
- Negative / trade-offs: markers add pre-initialization noise to shared files; shared prose must be
  authored in module-separable line units; the slug derivation understands GitHub remotes only —
  consistent with the badge being a GitHub Actions badge, but one more GitHub coupling; the
  bootstrap machinery itself must be tested (covered by `scripts/test-init-template.sh` across all
  sixteen module combinations plus the repository-slug paths in CI).
- Constraint: the bootstrap must run **before** any commit, code comment, or issue cites an ADR
  number — afterwards the renumbering would invalidate those references. Running it at the first
  interaction satisfies this; the script's refusal to run twice keeps it that way.
- Follow-ups: none — future optional modules extend this mechanism rather than changing it.
