# Agent Guide

> **The single rule file of this project** ([ADR-0001](docs/adr/0001-agent-governance-model.md)).
> Every working rule lives here; where another document repeats one, this wording governs. The
> file belongs to the template and is not edited per project: project conventions go into
> [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md), into checks, and into ADRs. A procedure is a skill
> under [`.agents/skills/`](.agents/skills/) that cites a rule here and states none of its own
> ([ADR-0005](docs/adr/0005-procedures-as-skills.md)). Setup for humans is in
> [`README.md`](README.md).

## 1. Principles

The human decides *why* and *what*; the agent works out *how*. A how that binds future choices is
the human's too, recorded with its why in an ADR ([§3](#3-adr-rules)). Four principles win over
speed and cleverness:

- **Simplicity.** Build the simplest thing that satisfies the specification. Add a dependency or
  an abstraction only for a present need. Removing code is progress. Justify warranted complexity
  in an ADR.
- **Proportionality.** Ceremony scales with how hard a change is to reverse. Skipping ceremony a
  reader would expect is said out loud.
- **Reflection.** Weigh alternatives and consequences, and write the reasoning down.
- **Critical stance.** Take nothing at face value: not the human's framing, not your own earlier
  output, not the existing code. Verify against the specification, the ADRs, the code, and
  authoritative sources. State disagreement with its evidence, and flag what you could not
  confirm. Both go into the pull request, where "none" is a claim the reviewer checks.

## 2. Start here

Before any non-trivial work, read:

1. [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md): problem, goals, success criteria, written in
   the vocabulary of [`docs/GLOSSARY.md`](docs/GLOSSARY.md).
2. [`docs/adr/README.md`](docs/adr/README.md): the ADR index. **Accepted ADRs are binding.** Read
   every one whose *Applies to* names what your change touches. A `proposed` ADR binds the work
   that implements it. Rejected and superseded ADRs explain *why*; they are not rules.
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): the system as it stands today. Where it and an
   accepted ADR disagree, the ADR is right.

Scaffold text in those documents, such as a placeholder title, an empty section, or a `TODO`, is
the first work: say so and elaborate it with the human before implementing.

## 3. ADR rules

Authority runs **specification → accepted ADRs → task**. The mechanics of the record are in
[`docs/adr/README.md`](docs/adr/README.md): numbering, template, lifecycle, index. Working
rules originate here and nowhere else. Another document cites a section here by its anchor
(`[AGENTS.md §3](AGENTS.md#3-adr-rules)`) and restates nothing. A rule this file does not state
is not a rule of this project.

1. **Create an ADR before any architecture-relevant decision:** a dependency or framework, a
   public interface, a persistence or synchronization strategy, a protocol or data format,
   anything that constrains future technology choices. One decision per ADR. A cross-cutting ADR
   only for an integration, where the decision *is* the interplay.
2. **Calibrate.** An ADR is for a decision that is *costly to reverse*, that *constrains future
   choices*, or that **a reader without this conversation would take for a mistake**; record the
   last however cheap it is to reverse. No ADR for implementing within an accepted ADR, bug
   fixes, interface-preserving refactorings, tests, docs, formatting, and dev-only tooling. When
   genuinely unsure, prefer a short `proposed` ADR over a silent decision.
3. **Develop the ADR with the human, critically.** Submit it with status `proposed` **in its own
   pull request**, never mixed with implementation. Skill: `propose-adr`.
4. **After human review, implement while the ADR is still `proposed`.** Findings return as
   revisions, each in its own ADR-only pull request. **Only a human changes the status;** the
   flip to `accepted` may land with the implementation. The gate that routes such an edit to a
   human is [`.github/CODEOWNERS`](.github/CODEOWNERS), with the review requirement listed under
   **Repository settings** in the README.
5. **Accepted ADRs are binding and immutable.** Never violate, edit, or silently work around one.
   Change the decision with a superseding ADR. The only permitted edit is the `Status` line,
   flipped by a human. ADR numbers are permanent. If the specification and an ADR conflict, the
   specification wins: raise the conflict, never choose silently.
6. **Use the vocabulary of [`docs/GLOSSARY.md`](docs/GLOSSARY.md)** in code, comments, and
   documentation. Add a term in the same change that settles it. A missing entry is a gap to close
   there, not a word to invent.
7. **A change to the specification is a decision, not an edit.** Only a human lands one, and it
   names every accepted ADR whose basis it moves. An agent drafts specification text; it never
   lands the change and never judges alone that no ADR is affected.

## 4. Working style

- **Reply to the human in their own language.** Everything else is English: code, comments,
  commits, docs, ADRs, pull requests.
- **Prefer small, reviewable changes.** Plan and explore before a larger one. Commits and pull
  requests name the ADR they implement (`Implements ADR-NNNN`).
- **Cut work into vertical slices:** each a thin, tested path through every layer it touches. The
  first through new ground is the tracer bullet. The one exception is a wide mechanical
  refactor: expand, migrate in batches, contract, every step green.
- **Write to [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md).** Settle a new judgement call there in
  the same change that raised it. One a check can decide becomes the check
  ([§5](#5-quality-bar--definition-of-done)); one that constrains future choices becomes an ADR.
- **Plan work larger than one session on the issue tracker:** a feature spec cut into
  tracer-bullet tickets ([ADR-0004](docs/adr/0004-feature-layer.md)). Skill: `plan-feature`.
- **Work with the human:** small steps, reasoning surfaced, feedback sought early. A task runs
  unattended only when all of the following hold:
  1. its acceptance criteria are written and a test decides them;
  2. its scope is isolated and a wrong result costs one revert;
  3. it touches none of the parts the harness ADR keeps with the human, and the cap that ADR puts
     on open agent work leaves room;
  4. its ticket says how soon a wrong result would be noticed, how cleanly it can be undone, what
     would prove it right, and when the session stops: the point past which it leaves its state
     on the ticket and hands off instead of trying on or widening the scope.
- **Keep the context lean.** Subagents return conclusions, not file dumps. Alignment,
  implementation, and review each start in a fresh session with only what they need, never by
  compacting the old one. The implementing session loads what its ticket's *Read first* names. A
  degraded session hands off.
- **Session artifacts are not tracked.** Plans, handoff notes, and scratch files live under
  `.scratch/` (gitignored) or outside the tree. What has to outlive the session becomes an issue,
  a `proposed` ADR, or a change to one of the six documents of ADR-0001.
- **Research before a decision that is costly to reverse,** external sources included, cited in
  the ADR. Below that bar, research what you are actually unsure of. Never pass off recalled
  interfaces, versions, or defaults as verified.
- **Open an issue first when scope or intent is still open.** The trigger is disagreement about
  *why* and *what*, not size. **When in doubt, ask the human before implementing.**

## 5. Quality bar & Definition of Done

The build, test, and lint commands live in the **Build, Test & Run** section of
[`README.md`](README.md), and they run as part of
[`scripts/check-all.sh`](scripts/check-all.sh).

- **A change is done only when it builds, its tests pass, and linters and formatters are clean,**
  locally and in CI. Never hand off or propose merging red.
- **Run [`scripts/check-all.sh`](scripts/check-all.sh) before pushing.** CI runs the same checks
  on every pull request.
- **New behaviour ships with tests; a bug fix ships with a regression test** that fails before the
  fix and passes after. Genuinely untestable: say so and why.
- **The suite is the contract an implementation is held to,** so it tests through interfaces the
  implementation can change behind. Before changing what exists, pin the behaviour that must
  stay, tests first where none exist. A rewrite or migration is done when the old suite passes
  against the new implementation.
- **Every accepted ADR and every specification criterion (`G-n`, `Q-n`) is cited by a test** with
  a `Verifies: <id>` marker. An ADR no test can decide says so in its *Enforcement* section.
  [`scripts/check-traceability.sh`](scripts/check-traceability.sh) enforces it
  ([ADR-0003](docs/adr/0003-decisions-verified-by-tests.md)).
- **Never weaken the suite to make it pass. A flaky test is a defect, not noise:** no retries, no
  re-running until green.
- **Review in a fresh context before handing off.** The session that wrote a change does not
  review it. A second session gets only the diff, the task, the doubts recorded for the pull
  request, and the standards the `review` skill names, never the implementer's reasoning. It
  reports on two axes kept apart: does it do what was asked; does it meet this bar and the
  principles of [§1](#1-principles), simplicity first. Its findings are fixed before the pull
  request opens. Every existing test the diff changes or removes needs a reason the behaviour
  changed. Skill: `review`.
- **A feature spec closes only after a design revision** in a fresh session over the modules its
  tickets touched, the accepted ADRs that bind them, and the specification criteria they serve.
  It files what it finds as tickets, checks, a `proposed` ADR, or a drafted specification change
  for the human ([ADR-0004](docs/adr/0004-feature-layer.md)). Skill: `design-revision`.
- **A mistake a check could have caught becomes a check,** shipped with the fix. A rule in prose
  is the fallback for what no check can decide. The design revision drops what prevented nothing.
- **Keep the diff releasable.** No commented-out code, stray debug output, or `TODO` standing in
  for a decision. Unfinished work is an issue or a `proposed` ADR, not hidden in the tree.
- **A change to the structure updates [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)** in the same
  change.

## 6. Project rules

- **Commit freely on a branch, never on `main`. A human decides what leaves the machine.**
  Pushing, `gh`, and anything that rewrites or discards history (`reset`, `rebase`, `merge`,
  `restore`, `clean`) wait for an instruction that names it. An instruction covers what it named
  and never implies the next. The git hooks under [`.githooks/`](.githooks/) refuse a commit on
  `main` and a push while the checks of [§5](#5-quality-bar--definition-of-done) are red.
- **Authenticate `gh` through its web flow;** a human enters the one-time code. Never request,
  store, or hard-code personal access tokens.
- **The Dev Container mounts no host Docker socket** and adds no Feature that would;
  `devcontainer-lock.json` is committed ([ADR-0002](docs/adr/0002-dev-container-runtime.md)).
- **Changes reach `main` through a pull request.** What no file can enforce is listed under
  [Repository settings](README.md#repository-settings).

## 7. Secrets

- **Never write a secret into a tracked file, commit message, ADR, log, or CI output.** Secrets live
  in environment variables, gitignored `.env*` files, or GitHub Actions secrets. A placeholder in a
  tracked `.env.example` is not a secret.
- **A secret that reaches git is compromised.** Rotation comes first and is the human's to perform;
  removing it from the branch tip is cleanup, not remediation. Tell the human immediately.
- No check enforces either rule. What the repository's configuration does about secrets, and where
  it stops, is in [`SECURITY.md`](SECURITY.md).
