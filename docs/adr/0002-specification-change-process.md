# ADR-0002: The specification changes only by human decision, naming the ADRs it moves

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer
- **Applies to:** `docs/SPECIFICATION.md` and every accepted ADR derived from it

## Context

Authority in this repository runs **specification → accepted ADRs → task**
([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). The lower half of that chain is governed in detail:
an ADR is developed in dialogue, ships `proposed` in a pull request of its own, is accepted only by
a human, and is then immutable — a decision changes only through a new ADR that supersedes it,
numbers are permanent, and [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies what is
mechanically checkable about all of it ([process rules 3 to 6](README.md#process)).

The document at the top of that chain has none of it. Nothing states who may change
[`docs/SPECIFICATION.md`](../SPECIFICATION.md), in what kind of change, or what happens to the
decisions that derive from a clause once it is rewritten. The only rule that touches the question is
the conflict rule — the specification wins, and the conflict is raised rather than resolved silently
([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)) — and it points the wrong way: because the
specification outranks every ADR and is not protected, editing a goal is the cheapest available
route around an accepted, immutable decision. An agent can take that route inside an ordinary
documentation commit, and nothing in the repository would notice; the ADRs built on the old clause
keep their `accepted` status and their binding force while the ground under them has moved.

Two forces pull against a heavy answer. The specification must stay genuinely editable: filling in
its scaffold text is the *first* work in a new project
([`AGENTS.md` §2](../../AGENTS.md#2-start-here)), and a project's goals legitimately develop as it
learns. And this repository's checks run on bash and the text tools the container already
provides, which limits what any rule here can lean on mechanically.

## Decision

We will treat a change to [`docs/SPECIFICATION.md`](../SPECIFICATION.md) as a decision rather than
an edit: it is made by a human, and it names every accepted ADR whose basis it moves — so that those
decisions are reconsidered in the same review, and each one the change invalidates is superseded by
a new ADR instead of being left standing on a clause that no longer says what it said.

The obligation scales with what actually rests on the words. While nothing derives from a passage
yet — the ordinary case in a young project, where filling in scaffold text is the first work
([`AGENTS.md` §2](../../AGENTS.md#2-start-here)) — there is nothing to name and the rule costs
nothing. It engages exactly when it should: once accepted decisions depend on the text being
rewritten.

An agent drafts and proposes specification text as before; what it may not do is land the change or
judge alone that no ADR is affected.

This template ships no selectable policy: the decision is content of the project from its first
commit, like every other ADR here.

**Out of scope:** what the specification *contains* — its sections are scaffold a project shapes
freely, and this decision governs how they change, not which of them exist. Also out of scope: how
a specification change is *packaged* — whether it travels on its own or alongside the work it
motivates is left to ordinary review judgment (see the alternatives below); and whether the
specification carries a version, a date, or per-clause identifiers.

## Alternatives considered

- **Leave it as it is — review only, no stated lifecycle.** The status quo, and the reason this ADR
  exists: it leaves the constitution cheaper to change than the decisions it governs. The failure
  mode is silent, which is what makes it worse than a missing rule that someone would notice.
- **Give the specification the full ADR lifecycle — immutable clauses, superseded by new ones.**
  Symmetrical, and wrong for the document's nature: the specification is a living statement of
  intent, not a record of past decisions. Freezing clauses would demand a supersession for a wording
  fix and collide head-on with [`AGENTS.md` §2](../../AGENTS.md#2-start-here), which makes
  elaborating scaffold text the first work in a project.
- **Version the specification, or give it a changelog of its own.** Records *that* something changed
  without saying what it invalidates — the ADRs would lose their basis just as quietly, only with a
  version number next to it. It also duplicates what git history already holds.
- **A CI check that fails when the specification changes without an `ADR-NNNN` in the description.**
  Mechanical, but it cannot tell a typo fix from a rewritten goal, so it would either block ordinary
  edits or be satisfied by a meaningless reference. That is false confidence rather than
  enforcement: a gate a token reference satisfies is worse than no gate at all.
- **Additionally requiring the change in a pull request of its own, carrying no implementation.**
  Drafted into this decision and dropped as disproportionate
  ([`AGENTS.md` §1](../../AGENTS.md#1-principles)): it would split every change that touches both a
  goal and the work that goal motivates, costing a round trip each time, while adding nothing to the
  protection that matters. A reviewer who sees the specification diff sees it just as well next to
  the code that prompted it. What guards the decisions below is that the consequences are *named*,
  not that the change travels alone.

## Sources / Prior art

- [ADR community site](https://adr.github.io/) — the lifecycle this repository already mirrors for
  decisions, and its consistent separation of *decisions* from the *requirements* they derive from.
  That separation is what makes an unprotected requirements document a hole rather than a detail.
- [arc42](https://arc42.org/) — keeps goals, constraints and quality requirements in sections
  distinct from the solution, on the same reasoning: the two change at different rates and under
  different authority.
- Requirements-engineering practice more broadly (ISO/IEC/IEEE 29148 and its predecessors) treats
  change control and downstream traceability as properties a requirements document must have, not as
  process overhead added later. Cited for the principle; this ADR deliberately does not adopt a
  formal traceability apparatus.

## Consequences

- Positive: the constitution stops being the cheapest way around an immutable ADR. A goal that
  moves surfaces the decisions it undermines while a reviewer is already looking at it, instead of
  months later when an ADR is found to rest on text that no longer exists. Agents get an explicit
  rule for a document they are otherwise only told to fill in. And because the obligation scales
  with what derives from the text, the rule stays out of the way for exactly as long as there is
  nothing to protect.
- Negative / trade-offs: naming the affected ADRs is a judgment call no check can make, so a
  careless or deliberately narrow reading still passes — the rule raises the question reliably, it
  does not answer it. It also puts a decision step in front of edits that used to be routine, which
  will feel like friction on a wording fix even though such a fix owes nothing.
- Follow-ups: whether the specification should carry per-clause identifiers so an ADR can cite the
  exact clause it derives from, which would turn "names the affected ADRs" from judgment into
  lookup — worth a follow-up ADR on specification traceability once a project has enough clauses for
  it to pay. Nothing else: accepting this decision triggers no edit elsewhere in the record.

## Enforcement

**No check.** Whether a rewritten clause moves an ADR's basis is exactly the judgment a script
cannot make, and the rejected alternative above explains why a check that pretended to would be
worse than none: it would be satisfied by a meaningless reference and would block ordinary edits.
That gap is stated rather than papered over.

**Two gates that make no judgment, and therefore do not fall under that rejection.** They do not
decide whether a change is right; they route it to the human this decision names.
[`.claude/settings.json`](../../.claude/settings.json) prompts before any edit to
[`docs/SPECIFICATION.md`](../SPECIFICATION.md), so Claude Code cannot rewrite the constitution
without being told to in that moment; and [`.github/CODEOWNERS`](../../.github/CODEOWNERS), once
the repository requires a review from Code Owners
([**Repository settings**](../../README.md#repository-settings)), stops the same person from
writing and merging the change. Their limits are stated in
[`SECURITY.md`](../../SECURITY.md): the prompt is Claude Code's own format and reaches no other
agent, it does not survive a "don't ask again" answer for the rest of a session, and a code owner
the repository does not name enforces nothing.

The rule itself lands in [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), where the authority chain it
protects is already stated, and in the pull request template's checklist, where a reviewer meets it.
