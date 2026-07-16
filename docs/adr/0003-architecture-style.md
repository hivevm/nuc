# ADR-0003: Hexagonal architecture (Ports & Adapters) as the default style

- **Status:** 🟡 proposed
- **Date:** 2026-07-01
- **Deciders:** Maintainer

## Context

The specification and the accepted ADRs govern *what* is built and *how work is governed*, but the
template deliberately prescribes no architecture *style* — so every project built on it re-decides how
the domain relates to its infrastructure, or drifts without deciding at all. Two forces specific to
this template push for making that choice explicit and early:

- **Agent-driven work needs clear seams.** Well-defined boundaries let coding agents work in isolation
  and produce small, reviewable diffs instead of changes that reach across the whole codebase
  ([`AGENTS.md`](../../AGENTS.md), *Working style*).
- **The Definition of Done demands testability.** New behaviour must ship with tests and the domain
  must be verifiable without infrastructure ([`AGENTS.md`](../../AGENTS.md), *Quality bar & Definition
  of Done*).

This ADR is a **proposed default**, not a mandate: a project may accept it, or reject it with a
superseding ADR if its shape (a small CLI, a library, a data-oriented pipeline) makes the ceremony
unjustified. It embodies the *Simplicity first* principle — adopt the boundary only where it earns its
keep.

## Decision

We will structure application code as **Hexagonal / Ports & Adapters**: a technology-agnostic domain
core at the center, **ports** (interfaces owned by the core) expressing what the core needs and
offers, and **adapters** at the edges binding those ports to concrete technology (UI, persistence,
network, external services). Dependencies point **inward** — the core depends on nothing outside
itself; adapters depend on the core, never the reverse.

## Alternatives considered

- **No prescribed style** — maximal freedom, but re-litigated per project and prone to silent drift and
  domain logic entangled with infrastructure; loses the testability and seam benefits above.
- **Layered (n-tier) architecture** — familiar, but its top-down dependency direction lets
  infrastructure concerns leak upward into the domain and couples the core to a database/framework.
- **Clean / Onion architecture** — essentially the same dependency-inversion idea with more prescribed
  concentric layers; heavier vocabulary for the same benefit. Hexagonal's port/adapter framing is the
  leaner expression and maps directly onto testable seams.

## Sources / Prior art

- Alistair Cockburn, *Hexagonal Architecture (Ports and Adapters)* — <https://alistair.cockburn.us/hexagonal-architecture/>.
- Robert C. Martin, *The Clean Architecture* (dependency rule) —
  <https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html>.

## Consequences

- Positive: the domain is testable in isolation (supports the Definition of Done); technology choices
  (DB, framework, transport) become swappable adapter decisions rather than pervasive rewrites; ports
  give agents explicit, low-conflict boundaries to work within.
- Negative / trade-offs: indirection and interface ceremony that is overkill for small projects or thin
  CRUD; the domain/adapter split must be maintained deliberately or it erodes.
- Follow-ups: if accepted, define per-language conventions (where ports vs. adapters live, naming) —
  routine and within this ADR, so no further ADR needed unless a concrete boundary decision constrains
  future choices. A project for which this style does not fit should record a superseding ADR rather
  than quietly ignore it.
