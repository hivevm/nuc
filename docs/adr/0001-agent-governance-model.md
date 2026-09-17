# ADR-0001: The document set: one specification, one ADR record, one `AGENTS.md`, one overview

- **Status:** 🟡 proposed
- **Date:** 2026-09-05
- **Deciders:** Maintainer
- **Applies to:** every document that carries rules for humans or agents, and the architecture overview
- **Note:** Documented retroactively: the decision was already embodied in the repository it
  describes. It is the governance under which every other ADR here is recorded.

## Context

Several coding agents may work in the same repository, and each looks for its instructions in a
different place. Without one written governance their behaviour drifts, rule sets are duplicated
and diverge, and structural decisions are made silently.

Three document roles follow from that: what the project is *for*, what has been *decided*, and what
the working *rules* are. A fourth is easy to overlook: the ADR record is a log, and nothing in it
says what the system looks like **now**. Reconstructing the present structure means reading every
accepted ADR and replaying the supersessions — a cost that grows with the log and that a coding
agent, starting every session without memory, pays every time. Against a fourth document stands the
risk it creates: a second descriptive document is a candidate second source of truth, and one that
can go stale.

## Decision

We will govern this repository through **four documents with four distinct roles**, and no others
that carry a rule:

- [`docs/SPECIFICATION.md`](../SPECIFICATION.md) — the **constitution**: what the project is for.
- [`docs/adr/`](.) — the **decision record**: every architecture-relevant decision, derived from
  the specification.
- [`AGENTS.md`](../../AGENTS.md) — one vendor-neutral **rule file**, the single source of working
  rules for humans and agents alike.
- [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — the **current state**: the system's parts, their
  responsibilities, and how they fit together. It holds no rule and no decision, cites the ADR
  behind each structural choice, and is updated in the same change as the structure. Where it and
  an accepted ADR disagree, the ADR is right — so it cannot become a second source of truth.

Every other document — [`README.md`](../../README.md), [`CONTRIBUTING.md`](../../CONTRIBUTING.md),
[`SECURITY.md`](../../SECURITY.md), issue and pull request templates, per-agent pointers — points at
the rule file and holds no rule of its own. The exception is a document holding the mechanics of a
record the rule file delegates to it: [`docs/adr/README.md`](README.md) and its
[`template.md`](template.md), delegated by [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules).

**The load-bearing clause is that there is exactly one rule file.** An ADR that supersedes any other
part of this record restates it.

**Each document changes at the level of its own authority.** The specification outranks every ADR,
so changing it is a decision of its own ([ADR-0002](0002-specification-change-process.md)). The ADR
lifecycle is mechanics, delegated to [`README.md`](README.md); its binding rules stay in
[`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), and a changed lifecycle rule invalidates no standing
decision. That leaves those rules as the one block with no ADR behind it — accepted here, and
reversible by an ADR on the ADR process. The overview decides nothing, so its only obligation is to
stay current.

**Out of scope:** what `AGENTS.md` says and how other documents cite it; which agents a project uses
and which need a pointer file; how the ADR record is kept; the notation and depth of the overview;
and which documents a project created from this template drops.

## Alternatives considered

- **Per-tool instruction files** — guarantees drift between agents and multiplies maintenance.
- **Rules embedded in `README.md`** — mixes human onboarding with agent governance.
- **No written governance** — agent drift and implicit, unreviewable decisions.
- **No overview; the ADR log is the current state** — holds while the log is short and degrades
  silently as it grows.
- **Current state inside the specification** — puts churn into the one document that must not
  churn.
- **Generate the overview from the ADR log** — restates decisions instead of describing structure,
  and needs tooling this template does not have.
- **Make the overview optional** — the orientation an agent most needs would be the first thing
  dropped.

## Sources / Prior art

- The `AGENTS.md` convention — <https://agents.md/>.
- Architecture Decision Records — <https://adr.github.io/>, which treats ADRs as a log, not as
  architecture documentation.
- [arc42](https://arc42.org/) and [the C4 model](https://c4model.com/) — current structure kept
  apart from goals and from the decision log, in a few views rather than an exhaustive set.

## Consequences

- Positive: one place to change a rule; consistent agent behaviour; explicit, reviewable decisions;
  one place that answers what the system looks like, at a cost that does not grow with the log.
- Negative / trade-offs: nothing mechanical keeps another document from stating a rule of its own,
  so the documents have to stay small enough for review to see it. A stale overview is worse than
  none because it is believed, and no check can tell the two apart.
- Follow-ups: whether a per-feature artifact between specification and code, or a tool-level
  procedure before implementation, belongs in this set is open and would need an ADR of its own.

## Enforcement

[`scripts/check-docs.sh`](../../scripts/check-docs.sh) (job `docs` in
[`checks.yml`](../../.github/workflows/checks.yml)) verifies what is mechanically checkable: that the
ADR record and its index agree, that links between the documents resolve, and that section
references point at the section they name. That no other document holds a rule, and that the
overview matches the system, is review only.
