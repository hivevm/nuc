# ADR-NNNN: <short title of the decision>

- **Status:** 🟡 proposed
- **Date:** YYYY-MM-DD
- **Deciders:** <names / roles of the humans who decide>
- **Applies to:** <the paths, components, or kinds of change this decision constrains>
- **Supersedes:** [ADR-NNNN](NNNN-short-title.md)
- **Note:** <optional>

*Complete the header and delete what does not apply. `Status` ships as `🟡 proposed`; a human flips
it — to `🟢 accepted`, `🔴 rejected`, or `⚪ superseded by ADR-NNNN` — and keeps **exactly one** emoji,
with the word that belongs to it. `Date` is the date of the last status change — the date the ADR
was proposed until the first flip; revising a `proposed` ADR does not move it. `Deciders` names the
human(s) who accept or reject; an agent is never a decider. `Applies to` names what the decision
constrains — concrete paths where it has them, otherwise the kind of change (every commit, every
public interface) — in one line without a pipe character: it is mirrored verbatim in the index,
which is how a reader finds the ADRs that bind a change ([process rule 3](README.md#process)).
`Supersedes` only when this ADR replaces an existing one — the superseded ADR's own status line is
flipped in the same pull request ([process rule 5](README.md#process)). `Note` records earlier
status changes, retroactive documentation, and anything else about this ADR's own history that the
status line cannot carry. Then delete this paragraph.*

## Context

What is the issue we are facing? What forces are at play (requirements from
[`docs/SPECIFICATION.md`](../SPECIFICATION.md), constraints from other ADRs, technical forces)?

## Decision

What did we decide? One clear, active sentence ("We will …"). Needing a second "We will …"
sentence is a sign that this should be two ADRs ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)).

**Out of scope:** what this decision deliberately leaves open, so a later ADR can take it up
without contradicting this one. Write "nothing beyond the sentence above" when the decision is
already narrow.

## Alternatives considered

- **<Alternative A>** — why it was not chosen.
- **<Alternative B>** — why it was not chosen.

## Sources / Prior art

State of the art and established solutions consulted before deciding — links, docs, papers, or
comparable systems. [`AGENTS.md` §4](../../AGENTS.md#4-working-style) requires capturing and citing
what informed the decision; write "None — trivial/reversible" only when that is genuinely true.

## Consequences

- Positive: what becomes easier or possible.
- Negative / trade-offs: what becomes harder, what we accept.
- Follow-ups: new questions or follow-up ADRs this decision triggers. Describe them by topic —
  never cite an ADR number that does not exist yet.

## Enforcement

What keeps this decision true — the check, test, CI job, or review step that fails when it is
violated, and where it lives. "None — review only" is a legitimate answer; naming it keeps the gap
visible instead of implying an enforcement that does not exist.
