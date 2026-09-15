# ADR-0001: The document set: one specification, one ADR record, one `AGENTS.md`, one overview

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer of the originating starter template
- **Applies to:** every document that carries rules for humans or agents, and the architecture overview
- **Note:** Documented retroactively, so the record follows its own method: the decision was
  already embodied in the repository it describes. Accepted 2026-06-20 by the maintainer of the
  starter template this record originates in — which is why the decider is not this project's own.
  A repository created from that template never gets to decline it: it is the governance under
  which every other ADR here is recorded.
  Returned to `proposed` on 2026-09-05 by the maintainer, together with the rest of the set, so
  that it is reviewed and decided as a whole; consolidated on the same day with a separately
  proposed decision on the architecture overview, which named the fourth document role this record
  had left out. Both moves are possible because this record is still `proposed` — the immutability
  set out in [`README.md`](README.md) in this directory binds an *accepted* ADR
  ([process rule 5](README.md#process)).

## Context

Several coding agents may work in the same repository — which ones this project uses is listed in
[`README.md`](../../README.md). Without explicit, written governance their behaviour drifts, intent
stays implicit, and structural decisions are made silently and become hard to review. Each agent
also looks for its instructions in a different place, which invites duplicated and diverging rule
sets.

Three document roles follow directly from that: what the project is *for*, what has been *decided*,
and what the working *rules* are. A fourth is easy to overlook and turns out to matter most to the
reader this template exists for. The ADR record is a log — it says what was decided, when and why,
and keeps rejected and superseded entries as the memory of roads not taken. Nothing in it says what
the system looks like **now**. The index routes a reader from a change to the decisions that bind
it, which is the right service for "may I do this?" and the wrong shape for "what am I looking
at?"; reconstructing the present structure from the log means reading every accepted ADR and
replaying the supersessions between them, at a cost that grows with the log while the answer it
yields stays the same size. The specification does not fill the gap either: it states the problem,
the goals and the vocabulary — deliberately not how the project is currently built, which is
precisely why it can outrank the ADRs derived from it.

That cost falls hardest on a coding agent. It starts every session without memory of the project,
is told to read the specification and the ADR index before non-trivial work, and neither will tell
it which components exist or how they fit together. A human contributor pays the cost once and then
carries the picture in their head; the agent pays it every session — or does not pay it and infers
the structure from whichever files it happened to open.

Against a fourth document pulls the reason none existed: a second descriptive document is a
candidate second source of truth, which is exactly what this decision exists to prevent, and
documentation that must be kept current is documentation that can go stale and be trusted anyway.

## Decision

We will govern this repository through **four documents with four distinct roles**, and no others
that carry a rule:

- [`docs/SPECIFICATION.md`](../SPECIFICATION.md) — the **constitution**: what the project is for.
- [`docs/adr/`](.) — the **decision record**: every architecture-relevant decision, derived from
  the specification.
- [`AGENTS.md`](../../AGENTS.md) — one vendor-neutral **rule file**, the single source of working
  rules for humans and agents alike.
- [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — the **current state**: the system's parts, what
  each is responsible for, and how they fit together. It holds no rule and no decision of its own;
  it cites the ADR behind each structural choice, and it is updated in the same change as any
  modification to the structure it describes. It is a description, not an authority — where it and
  an accepted ADR disagree, the ADR is right and the overview is stale. That keeps a fourth document
  outside the second-source-of-truth problem: it restates no rule, so it cannot contradict one.

Every other document — [`README.md`](../../README.md), [`CONTRIBUTING.md`](../../CONTRIBUTING.md),
[`SECURITY.md`](../../SECURITY.md), the issue and pull request templates, a per-agent pointer, and
whatever else a project keeps — points at the rule file and holds no working rule of its own. The
standing exception is a document that holds the mechanics of a record the rule file delegates to it:
[`docs/adr/README.md`](README.md) and the [`template.md`](template.md) it prescribes, delegated by
[`AGENTS.md` §3](../../AGENTS.md#3-adr-rules); any further such record a project keeps is treated
the same way.

**The load-bearing clause is that there is exactly one rule file.** An ADR that supersedes any other
part of this record restates that one, or the drift this decision exists to prevent returns by the
back door.

**How each document changes is governed at the level of its own authority**, which is why the three
answers below look different and are not. The specification outranks every ADR, so rewriting it is
itself a decision and gets an ADR of its own
([ADR-0002](0002-specification-change-process.md)). The ADR record outranks nothing: its lifecycle —
numbering, template, status, index — is mechanics, and mechanics are delegated to a document
([`README.md`](README.md) in this directory). The overview outranks nothing and decides nothing, so
there is no authority to protect; the only obligation it carries is to stay current, and that
belongs beside the role it serves, above. Three treatments, one principle — and a reader who finds
a fourth document later applies the same test to it.

**The second of those three is the one that has to be argued rather than asserted**, because the
objection is good. [ADR-0002](0002-specification-change-process.md) exists precisely because the
specification was cheaper to change than the decisions resting on it, and that sentence appears to
fit the ADR record just as well: "accepted ADRs are immutable" and "numbers are permanent" can be
rewritten by editing a document, which is cheaper than the supersession they demand of everyone
else. Three things separate the cases. The binding rules are not in that document — they are in
[`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), the rule file whose singularity this record decides,
and what is delegated to [`README.md`](README.md) is their elaboration: how to number, what the
template holds, how the index is written. The damage differs in direction: a rewritten goal moves
the ground under ADRs that are already accepted, silently and in retrospect, which is the failure
ADR-0002 is built around, while a changed lifecycle rule invalidates nothing that stands and governs
only how the record is kept from then on. And the invariants a silent edit would most want to relax
are checked rather than trusted — [`check-docs.sh`](../../scripts/check-docs.sh) verifies that the
numbers run without gaps, that every heading matches its file, and that the index agrees with each
ADR's own status line.

What is left over is stated rather than resolved. **[§3](../../AGENTS.md#3-adr-rules) is the only
block of working rules in this repository with no ADR behind it**, and an edit to the ADR process is
caught by review, by [`.github/CODEOWNERS`](../../.github/CODEOWNERS), and by the prompt guarding
[`docs/adr/`](.) — never by a decision record. Deciding the ADR method by ADR is not free either:
this record manages it only because it was written retroactively, whereas a prospective lifecycle
ADR would have to be proposed and accepted under the very rules it was proposing. The trade is
accepted here, and a project that judges it wrong reverses it with an ADR on the ADR process —
against this paragraph, which is what it is for.

**Out of scope:** what `AGENTS.md` says, and how another document cites it when it summarizes a rule
for its own readers. Rule text and citation discipline are both maintained in the rule file
([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)) — an ADR that carried them would itself be the
second source this decision exists to prevent. Equally out of scope: which agents a project uses and
which of them need a pointer file or a tool-specific configuration; how the ADR record is kept —
numbering, template, lifecycle, index — which [`docs/adr/README.md`](README.md) governs; how the
specification itself changes, decided in [ADR-0002](0002-specification-change-process.md); the
notation the overview uses — plain prose, a C4 level, an arc42 section set, one diagram or none —
and how deep it goes, which follows the system's own size; and what a repository created from this
template may drop when it is initialized.

## Alternatives considered

- **Per-tool instruction files (one rule set each)** — guarantees drift between agents and
  multiplies maintenance.
- **Rules embedded in `README.md`** — mixes human onboarding with agent governance and bloats both.
- **No written governance** — maximal agent drift and unreviewable, implicit decisions.
- **No overview; the ADR log is the record of the current state.** The arrangement this decision
  ends. It holds while the log is short and degrades silently as it grows, because nobody notices a
  reconstruction cost that each reader pays privately, every time.
- **Fold the current state into `docs/SPECIFICATION.md`.** Puts churn into the one document that
  must not churn — the specification would move with every refactoring that changes no goal, and its
  authority over the ADRs derived from it rests on its being about intent rather than
  implementation.
- **Generate the overview from the ADR log.** Produces a restatement of decisions rather than a
  description of structure, is blind to everything that was never worth an ADR, and needs tooling
  this template does not have and would have to justify
  ([`AGENTS.md` §1](../../AGENTS.md#1-principles)).
- **Ship arc42 or a full C4 set as a template for the overview.** A section inventory a small
  project leaves mostly empty, and empty sections train readers to skip the document. The value is
  one current picture; a project that wants either framework adopts it inside this document.
- **Make the overview optional, for projects that judge they do not need one.** Tempting, and
  rejected twice over: every system has a structure, so there is no factual precondition to hang
  the choice on, and the orientation an agent most needs would be the first thing dropped — by
  someone deciding before the project has any structure to describe. This template ships no
  optional policy at all, which settles it.

## Sources / Prior art

- The `AGENTS.md` convention adopted by multiple agent vendors — <https://agents.md/>.
- Architecture Decision Records as introduced by Michael Nygard and collected at
  <https://adr.github.io/> — which treats ADRs as a decision *log* explicitly, not as architecture
  documentation; the fourth role above is one the practice itself names as missing.
- [arc42](https://arc42.org/) — separates the current solution structure (building blocks, runtime,
  deployment) from goals and constraints, and from the decision log, on the grounds that they change
  at different rates.
- [The C4 model](https://c4model.com/) — the case that a small number of current-state views at
  different zoom levels beats an exhaustive one, and the argument for keeping them close to the
  code.
- Spec-driven development as practised outside this template: a constitution above per-feature
  specifications, technical plans and task lists — [Wąsowski, *Designing a spec that survives code
  generation*](https://medium.com/@wasowski.jarek/sdd-designing-a-spec-that-survives-code-generation-spec-first-spec-driven-development-b61fdc234493).
  Read for the *layers*, not for the tooling: it argues for artifacts this record deliberately does
  not create, which is why the follow-up above is a question rather than a plan.
- Procedure as a tool-level skill, including the adversarial interview before implementation —
  [Pocock, AI Hero workshops](https://www.aihero.dev/workshops). The claim taken from it is narrow:
  that a written, repeatable procedure beats a remembered one, which is the same reason this record
  gives for a single rule file.

## Consequences

- Positive: one place to change a rule; consistent agent behaviour; decisions are explicit and
  reviewable; onboarding humans and agents read the same documents. One place also answers what the
  system currently looks like, at a cost that does not grow with the decision log, so the ADR record
  stays a log instead of drifting toward being a manual.
- Negative / trade-offs: nothing mechanical keeps a second document from stating a rule of its own —
  that stays a review question, and the documents have to stay small enough for it. The ADR index is
  written by hand too, but the documentation check verifies it against the ADR files. The discipline
  only pays off if contributors actually write ADRs. The overview adds an obligation that can be
  forgotten, and a stale overview is worse than none because it is believed; nothing mechanical can
  distinguish the two. The ADR process itself stays the one block of working rules with no record
  behind it — an asymmetry with [ADR-0002](0002-specification-change-process.md) that is argued for
  in the decision above and accepted, not overlooked. And this record now fixes four roles at once,
  which is why the single rule file is marked as the clause a superseding ADR must carry forward.
- Follow-ups: whether the overview's update obligation is strong enough to stay in the Definition of
  Done ([`AGENTS.md` §5](../../AGENTS.md#5-quality-bar--definition-of-done)) next to the changelog
  rule, or should fall back to a review expectation — better decided once a project has used the
  document for a while than in advance. How the rule file is worded, which agents a project uses,
  and how much of this template a project keeps stay maintained outside this decision.
- Two further follow-ups are **noted rather than decided**, and both concern the same empty space:
  the four roles above are all *durable* — intent, decisions, current structure, rules — and none of
  them describes the path from one intent to the code that serves it.
  - **An artifact between the constitution and the code.** Spec-driven practice fills that space
    with per-feature documents: a feature specification, a technical plan, a task list, written
    before generation and verified after it (see *Sources* below). This template has none of them,
    and not by omission: the calibration rule in
    [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules) sends work that locks nothing in straight into
    implementation, and work that does lock something in into an ADR. What is unclear is the middle
    — a change too small for an ADR and too large for a conversation — and whether an artifact for
    it would earn its place or become the second source of truth this record exists to prevent.
  - **A procedure layer.** The same practice turns the step *before* implementing into a tool-level
    procedure: an adversarial interview that keeps asking until author and agent share an
    understanding. This repository states that as a principle
    ([`AGENTS.md` §1](../../AGENTS.md#1-principles)) and as an ADR rule
    ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)) and then trusts the agent to follow it. A
    tool-specific configuration may enforce mechanically what the rule file already says, which is
    what the per-agent configuration here does for two paths; whether a *procedure* belongs in that
    category, or is exactly the drift into per-tool instructions this record rejects, is open.
  Neither is recorded as an ADR of its own: both are questions about whether a fifth artifact and a
  procedure belong in this set at all, and that is the decision a later record would have to make.

## Enforcement

[`scripts/check-docs.sh`](../../scripts/check-docs.sh) (job `docs` in
[`checks.yml`](../../.github/workflows/checks.yml)) verifies what is mechanically checkable about
this structure: that the ADR record and its index agree, that the links between these documents
resolve, and that a section reference in Markdown links to the anchor of the section it names, so
that renumbering or retitling one cannot pass unnoticed. The checks it runs
are listed in its own header; this ADR does not restate them. That no other document holds a rule of
its own is review-only, and so is whether the overview still matches the system — exactly the
judgment a check cannot make, where a check that only asked whether the file changed would be
satisfied by a whitespace edit.

The same check is what carries the decision into a repository created from this template: every
document this record **links** has to be one that project keeps, or the link check fails there.
Nothing verifies that in advance — a project that drops a linked document learns it from its own
CI, not from this repository. A document named here in prose rather than by link — the issue and
pull request templates, a per-agent pointer — is deliberately outside that guarantee: a project may
drop a pointer file it has no agent for.
