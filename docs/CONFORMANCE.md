# Conformance — <Project Name> against <External Source>

> This document anchors the implementation to the **external source** it derives from: another
> project, a published specification, or a reference implementation. It answers three questions —
> *which* revision of that source this project is measured against, *how far* it has come, and
> *where it deliberately differs*. [`SPECIFICATION.md`](SPECIFICATION.md) remains the constitution:
> it says what this project is *for*; this file says what it *owes an outside authority*. Where the
> two collide, the specification wins and the deviation is recorded below.

## Source

- **Name:** <external project or specification>
- **Origin:** <URL, repository, or document identifier>
- **Pinned revision:** <version, tag, commit SHA, or document revision>
- **Last reconciled:** <YYYY-MM-DD> by <name>
- **In scope:** <which parts of the source this project intends to derive at all>
- **Out of scope:** <parts deliberately not derived — so their absence is not read as a gap>

**Reconciling** means: fetch the current upstream revision, diff it against the pinned one, add or
update the rows below, then move the pin. Moving the pin is therefore a reviewable change, and its
diff is exactly the answer to "what did the outside world do while we were not looking?". Reconcile
on a rhythm the source's pace warrants, and always before planning a milestone.

## Conformance inventory

One row per unit of the external source — a specification section, a feature, a test-suite entry, a
public API surface — at whatever granularity the source itself is organized in. Use the source's own
identifiers verbatim, so a diff against a newer upstream revision maps onto this table mechanically
instead of by interpretation.

**Status legend:** 🟢 conformant · 🟡 partial · 🔵 planned · ⚪ out of scope · 🔴 deviates

| Unit | Source ref | Status | Notes |
|------|------------|--------|-------|
| <name> | <section / file / test id> | 🔵 planned | <what is still missing> |
| <name> | <section / file / test id> | 🟡 partial | <which part, and what remains> |
| <name> | <section / file / test id> | 🔴 deviates | <points to the deviation entry below> |

Completeness of this table is itself a claim: a unit that exists upstream and is missing here is an
unreconciled gap, not an implicit "out of scope".

## Deviations

Deliberate departures from the source. Each entry states what the source requires, what this project
does instead, and why. A deviation that is architecture-relevant additionally needs an ADR (see
[`adr/`](adr/)) and cites it here — this list records *that* we deviate, the ADR records *why it was
allowed*. **A difference not listed here is a defect, not a decision.**

- **<Unit>** — the source requires <…>; this project does <…>, because <…>. Decided in ADR-NNNN.

## Open questions

Where the source is ambiguous, contradictory, or silent, and what this project assumed in the
meantime. Resolve upstream where possible — an answer from the source removes an assumption from
this list.

- <question> — assumed <…> until clarified.
