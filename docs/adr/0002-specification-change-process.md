# ADR-0002: The specification changes only by human decision, naming the ADRs it moves

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer
- **Applies to:** `docs/SPECIFICATION.md` and every accepted ADR derived from it

## Context

Authority runs **specification → accepted ADRs → task** ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)).
ADRs have a full lifecycle — proposed in their own pull request, accepted only by a human, then
immutable ([process rules 3 to 6](README.md#process)). The specification at the top of the chain has
none: nothing says who changes it or what happens to the decisions resting on a rewritten clause.
Because it outranks every ADR and is unprotected, editing a goal is the cheapest route around an
accepted, immutable decision — and the ADRs built on the old clause keep their binding force.

Against a heavy answer: filling in the specification is the *first* work in a new project
([`AGENTS.md` §2](../../AGENTS.md#2-start-here)), and goals legitimately develop.

## Decision

We will treat a change to [`docs/SPECIFICATION.md`](../SPECIFICATION.md) as a decision rather than
an edit: it is made by a human, and it names every accepted ADR whose basis it moves, so that each
is reconsidered in the same review and superseded where the change invalidates it.

The obligation scales with what rests on the text: while nothing derives from a passage, there is
nothing to name. An agent drafts and proposes specification text; it never lands the change, and
never judges alone that no ADR is affected.

**Out of scope:** what the specification contains; whether a change travels alone or with the work
it motivates; and whether the specification carries a version or a date.

## Alternatives considered

- **Review only, no stated lifecycle** — leaves the constitution cheaper to change than the
  decisions it governs, and fails silently.
- **The full ADR lifecycle for the specification** — immutable clauses would demand a supersession
  for a wording fix; the specification is living intent, not a record.
- **A version number or changelog** — records *that* something changed, not what it invalidates.
- **A CI check requiring an ADR reference on every specification change** — cannot tell a typo fix
  from a rewritten goal, so it blocks ordinary edits or is satisfied by a token reference.
- **A pull request of its own for every specification change** — a round trip per change for no
  added protection; what guards the ADRs is that the consequences are named.

## Sources / Prior art

- [ADR community site](https://adr.github.io/) — decisions kept separate from the requirements they
  derive from.
- ISO/IEC/IEEE 29148 — change control and traceability as properties of a requirements document.

## Consequences

- Positive: the specification stops being a way around an immutable ADR; a moved goal surfaces the
  decisions it undermines while a reviewer is looking; the rule costs nothing while nothing derives
  from the text.
- Negative / trade-offs: naming the affected ADRs is a judgment no check makes, so a narrow reading
  still passes; routine wording fixes meet a decision step.
- Follow-ups: none.

## Enforcement

No check decides whether a rewritten clause moves an ADR's basis; that is review. Two gates route the
change to a human without judging it: [`.claude/settings.json`](../../.claude/settings.json) prompts
before any edit to the specification, and [`.github/CODEOWNERS`](../../.github/CODEOWNERS) requires
the owner's review once the repository enables it
([**Repository settings**](../../README.md#repository-settings)). Their limits are stated in
[`SECURITY.md`](../../SECURITY.md).
