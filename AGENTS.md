# Agent Guide

> **Single source of truth for all coding agents.** Every working rule of this project lives in
> this file; where another document repeats one for its own readers, this file's wording governs
> ([§3](#3-adr-rules)). It is not edited to fit an individual project — project-specific
> conventions belong in the specification and in ADRs ([§3](#3-adr-rules)). That there is exactly
> one such file is decided in [ADR-0001](docs/adr/0001-agent-governance-model.md); which agents
> read it natively, and which need a pointer to it, is listed in the README.

Human-facing setup — prerequisites, how the Dev Container is opened, and the project description —
lives in [`README.md`](README.md). Do not duplicate that information here; what the environment
itself has to satisfy is a rule, and rules live here ([§6](#6-project-rules)).

## 1. Principles

Four principles govern every rule below. Where they tension with speed or cleverness, they win.

1. **Simplicity first.** Build the simplest thing that satisfies the specification. Add a
   dependency, an abstraction, or a layer of indirection only for a concrete, present need, never a
   speculative one (YAGNI); removing code is progress. Complexity that is genuinely warranted is
   architecture-relevant — justify it in an ADR ([§3](#3-adr-rules)).
2. **Proportionality.** Ceremony — an ADR, an issue, prior research, a round trip for approval —
   scales with how hard a change is to reverse; where there is no commitment it buys nothing but
   delay. Weigh every rule below that leaves the choice open that way — the calibration rule in
   [§3](#3-adr-rules) is the worked example — and say so when you skip ceremony a reader would
   have expected.
3. **Reflection.** Weigh alternatives and consequences instead of committing to the first solution,
   and make the reasoning explicit rather than silent — beforehand, whether this is the simplest
   path that serves the specification's goals; afterwards, whether it was, and at what cost.
4. **Critical stance.** Take nothing at face value — not the human's framing, not your own prior
   output, not the existing code. Verify claims against the specification, the ADRs, the code, and
   authoritative sources; surface conflicts, risks, and uncertainty instead of smoothing them over;
   disagree when the evidence warrants and say why; flag what you could not confirm.

## 2. Start here

Before any non-trivial work, read:

1. [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) — the **specification** (problem, goals, core
   concepts, vocabulary, success criteria).
2. [`docs/adr/README.md`](docs/adr/README.md) — the index of Architecture Decision Records.
   **Accepted ADRs are binding**: read every accepted ADR whose *Applies to* column names what your
   change touches, plus whatever else you need to understand them — the index routes, it does not
   ration. A `proposed` ADR binds the work that implements it ([§3](#3-adr-rules)). Rejected and
   superseded ADRs are the record of roads not taken: read them to learn *why* things are as they
   are, never as a rule to follow.
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — the system **as it stands today**: its parts,
   their responsibilities, and how they fit together. It decides nothing — it describes, and cites
   the ADR behind each structural choice; where it and an accepted ADR disagree, the ADR is right
   and the overview is stale.

**Where those documents still carry scaffold text, filling them in is the first work** — a title
naming a placeholder, an empty **Problem** or **Goals** section, a `TODO` where a command belongs.
Say so and elaborate them with the human before implementing: a specification that states nothing
makes every ADR derived from it ([§3](#3-adr-rules)) unreviewable.

## 3. ADR rules

Authority runs **specification → accepted ADRs → task**. The ADR mechanics — numbering, template,
lifecycle, and the index — are delegated to [`docs/adr/README.md`](docs/adr/README.md).

**Working rules originate here and nowhere else.** Every other document carries procedure and
audience-specific information only; where one repeats a rule for its own readers, this file's
wording governs and the repetition cites the section it came from (`§N`). A rule this file does not
state is not a rule of this project, and project-specific conventions go into the specification and
into ADRs rather than into a reworded rule here.

**Cite a section of this file as a link to its anchor**, which carries the number and the title:
`[AGENTS.md §3](AGENTS.md#3-adr-rules)`. Renumbering or retitling a section then breaks every link
into it, and [`scripts/check-docs.sh`](scripts/check-docs.sh) fails on each one until it has been
re-checked by hand — the half of the hazard a check can see. It also verifies that the numbering
here runs `1..N` without a gap. Outside Markdown, where there are no links, a reference is still
only checked for the number existing.

1. **Create an ADR before any architecture-relevant decision** — adding a dependency or framework,
   designing or changing a public interface, choosing a persistence/synchronization strategy or a
   protocol/data format, or anything that constrains future technology choices (non-exhaustive).
   **Scope it to one specific decision**, narrow enough that a later ADR can supersede it cleanly;
   cross-cutting ADRs are reserved for integrations, where the decision *is* the interplay of
   multiple components.
2. **Calibrate — not everything needs an ADR.** ADRs are for decisions that are *costly to reverse*
   or *constrain future choices*. Routine, local, reversible work needs none: implementing within
   an accepted ADR, bug fixes, refactorings that preserve public interfaces, tests, docs,
   formatting, or dev-only tooling no shipped code depends on. Rule of thumb: if a change locks in
   nothing and could be undone in a single follow-up commit, skip the ADR. When genuinely unsure,
   prefer a short `proposed` ADR over a silent decision.
3. **Develop the ADR interactively and critically** — copy
   [`docs/adr/template.md`](docs/adr/template.md) and work through context, alternatives, and
   consequences in dialogue with the human, questioning the framing and your own draft
   ([§1](#1-principles)) — then submit it, status `proposed`, **in its own pull request**, never
   mixed with implementation.
4. **After human review of the proposal, implement while the ADR is still `proposed`.**
   Implementing validates the decision: findings flow back as revisions to the proposed ADR, each
   in its own ADR-only PR (rule 3). **Only a human changes the status**; the flip to `accepted` may
   land together with implementation in one PR. Where a tool can enforce this rule and rule 7
   rather than trust them, it does: [`.claude/settings.json`](.claude/settings.json) prompts before
   any edit to [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) or to [`docs/adr/`](docs/adr/).
   [`.github/CODEOWNERS`](.github/CODEOWNERS) adds the review half, but only once it names a real
   owner and the repository requires a Code-Owner review
   ([**Repository settings**](README.md#repository-settings)) — until both hold it enforces
   nothing. An agent without an equivalent mechanism has this as documentation only.
5. **Accepted ADRs are binding and immutable.** Never violate or edit one and never silently work
   around it; change the decision with a *new* superseding ADR. The single permitted edit is the
   **`Status` line**, flipped by a human (rule 4); **ADR numbers are permanent** — never renumber,
   delete, or merge ADRs. If the specification and an ADR conflict, the specification wins — raise
   the conflict, never choose silently.
6. **Use the project vocabulary** from the specification consistently in code, comments, and
   documentation.
7. **A change to the specification is a decision, not an edit.** Only a human lands one, and the
   change names every accepted ADR whose basis it moves, so each of them is reconsidered in the same
   review and superseded by a new ADR wherever the change invalidates it (rule 5). The obligation
   scales with what rests on the text: while nothing derives from a passage — the ordinary case
   while the specification is still being filled in ([§2](#2-start-here)) — there is nothing to
   name. An agent drafts and proposes specification text; it never lands the change, and never
   judges alone that no ADR is affected. Decided in
   [ADR-0002](docs/adr/0002-specification-change-process.md).

## 4. Working style

- **Reply to the human in their own language**, whichever they write in. Everything else stays
  English: write **all artifacts** (code, comments, commits, docs, ADRs, PRs) in **English**,
  without exception.
- **Prefer small, reviewable changes**; plan and explore the codebase before editing a larger one.
  Reference the relevant ADR(s) in commit messages and pull request descriptions (e.g.,
  `Implements ADR-NNNN`).
- **Work interactively and iteratively**: proceed in small steps, surface your reasoning, and seek
  feedback early rather than delivering large changes at once.
- **Research before a decision that is costly to reverse.** Above the ADR bar ([§3](#3-adr-rules)),
  research the state of the art and established solutions first — external sources included — and
  cite the findings in the ADR. Below it, research what you are actually unsure of, not the whole
  field. Either way, never pass off recalled interfaces, versions, or defaults as verified.
- **Open an issue first when scope or intent is still open.** The trigger is disagreement about
  *what* and *why*, not size: work whose scope the human already stated needs none however large,
  while a small change that moves a goal, a public interface, or user-visible behaviour needs one.
- **When in doubt about scope or intent, ask the human before implementing.**

## 5. Quality bar & Definition of Done

This section defines *when* a change is done; the build, test, and lint commands themselves live in
the **Build, Test & Run** section of [`README.md`](README.md).

- **A change is done only when it builds, its tests pass, and linters/formatters are clean** —
  locally and in CI. Never hand off or propose merging red.
- **Run this repository's own consistency checks before pushing** —
  [`scripts/check-all.sh`](scripts/check-all.sh) runs every one of them; CI runs the same checks,
  as one job each, on every pull request.
- **New behaviour ships with tests; bug fixes ship with a regression test** that fails before the
  fix and passes after. If a change is genuinely untestable, say so and explain why.
- **Never weaken the suite to make it pass.** Do not delete, skip, or loosen assertions to go
  green; fix the code, or correct a genuinely wrong test and explain the reasoning.
- **Treat a flaky test as a defect, not noise** — no retries, no re-running until green; fix the
  root cause.
- **Keep the diff releasable.** No commented-out dead code, stray debug output, or `TODO` standing
  in for a decision; unfinished work is tracked as an issue or a `proposed` ADR, not hidden in the
  tree.
- **A change to the structure updates [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)** in the same
  change — the parts, their responsibilities, or the way they fit together; a change that leaves
  all three as they were owes nothing. Decided in
  [ADR-0001](docs/adr/0001-agent-governance-model.md).

## 6. Project rules

- **Git writes need explicit human approval** — never autonomously, whether run as git (`add`,
  `commit`, `push`) or through `gh`. One approval may cover a bounded sequence the human named
  ("commit these three, then stop"): the unit is the authorized work, not the number of git
  invocations. Anything it did not name needs a new approval, and silence is never approval.
- **GitHub interaction happens on explicit instruction only.** The agent may use `gh` to interact
  with GitHub (pull requests, issues, releases) only when a human explicitly asks; an instruction
  covers what it named and never implies the next.
- **Authenticate `gh` through its web flow.** Run `gh auth login` and choose *Login with a web
  browser*; a human then enters the displayed one-time code at <https://github.com/login/device> to
  authorize. Never request, store, or hard-code personal access tokens.
- **Work happens in the Dev Container, and it is not optional.** The environment is defined in
  [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json); the project picks its own
  base image, `Dockerfile`, or Compose file, but **no host Docker socket is mounted** and no Feature
  that would mount one is added, and `.devcontainer/devcontainer-lock.json` is committed rather than
  ignored. Editor extensions are deliberately listed without versions. Decided in
  [ADR-0003](docs/adr/0003-dev-container-runtime.md); how to open the container is in the README.
- **Changes reach `main` through a pull request.** The rules no file in the repository can enforce
  — the ruleset on `main`, its required status checks, and the repository's security settings — are
  listed under [**Repository settings**](README.md#repository-settings) in the README and
  configured on the repository itself.
- Build, test, and run commands live in the **Build, Test & Run** section of
  [`README.md`](README.md) — the single source for both humans and agents.

## 7. Secrets

Decided in [ADR-0004](docs/adr/0004-secrets-handling.md); what the repository's own configuration
does about secrets, and where it stops, is in [`SECURITY.md`](SECURITY.md).

- **Never write a secret into a tracked file, a commit message, an ADR, a log, or CI output** — no
  tokens, API keys, passwords, or `.env` contents. A placeholder in a tracked `.env.example` is not
  a secret and is the point of that file; secrets themselves live in environment variables,
  gitignored `.env*` files, or GitHub Actions secrets.
- **A secret that reaches git is compromised.** Rotate it first; removing it from the tip of a
  branch reaches no clone, fork, or cache that already has the commit, and is cleanup rather than
  remediation. Tell the human immediately — rotation is theirs to perform.
- No check enforces either rule. GitHub's secret scanning with push protection is the only
  mechanical backstop, and it is a repository setting
  ([**Repository settings**](README.md#repository-settings)) that nothing in the repository can
  switch on; the gap is named in ADR-0004 rather than closed with a scan that would look like one.
