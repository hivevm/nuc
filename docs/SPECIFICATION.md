# Specification — <Project Name>

> The **specification** of this project: the problem it solves, where it is going, and the
> vocabulary everyone (humans and agents) must use. This document is the **constitution** —
> every Architecture Decision Record in [`adr/`](adr/) derives from it and must not contradict it.

## Problem

What concrete problem does this project solve? For whom? What is painful or missing today?

## Mission

What is the core purpose of this project? One clear sentence.

## Vision

Where is this project going? Describe the desired future state in one or two paragraphs.

## Strategy

How do we get there? High-level approach (e.g., "Build modular components, open source, community-driven").

## Core Concepts & Vocabulary

Define the key terms of the domain. Use these exact words consistently in code, comments,
documentation, and ADRs.

- **<Term>** — definition.
- **<Term>** — definition.

## Goals / Success Criteria

What must be true for this project to be considered successful? Write criteria that can be
used as acceptance criteria.

1. …
2. …

## Quality Goals

The properties the result must have, as opposed to the functions it must perform — and the yardstick
every ADR's *Consequences* section is weighed against. Name only the few that actually drive
decisions, in priority order, each with a measure concrete enough to settle a disagreement.

- **<Quality, e.g. Performance>** — why it matters for this project, and how it is measured
  (e.g. "p95 response under 200 ms at 100 requests per second").
- **<Quality, e.g. Security, Availability, Portability, Accessibility>** — …

## Non-Goals

What this project explicitly does not try to do — to keep scope clear.

- …

## Constraints

What the solution has to live with regardless of what would otherwise be the better choice:
platforms and runtimes it must support, standards or regulation it must satisfy, systems it must
interoperate with, and the limits of time, budget, and team. A constraint that is not written here
gets rediscovered as a rejected alternative in an ADR.

- …

## Assumptions

What is believed true today and would invalidate the decisions above if it turned out false —
expected scale, the shape of the data, who operates the result, which dependency stays maintained.
Recording them is what lets a later ADR name the assumption it rests on and be revisited when that
assumption breaks.

- …
