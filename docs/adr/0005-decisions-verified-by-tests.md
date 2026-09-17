# ADR-0005: Every accepted decision and every success criterion is verified by a test that cites it

- **Status:** 🟡 proposed
- **Date:** 2026-09-16
- **Deciders:** Maintainer
- **Applies to:** every accepted ADR, the Goals and Quality Goals of `docs/SPECIFICATION.md`, and the tests that verify them

## Context

This template drives development from a specification: authority runs **specification → accepted
ADRs → task** ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). Neither end of that chain is
connected to anything executable. The Definition of Done requires tests for new behaviour
([`AGENTS.md` §5](../../AGENTS.md#5-quality-bar--definition-of-done)), but nothing says which
decision or goal a test protects, and nothing notices a decision that no test protects.

The record shows the result: the ADR template calls "None — review only" a legitimate
*Enforcement*, and every ADR before this one relies on it in whole or in part — including
[ADR-0003](0003-dev-container-runtime.md), whose load-bearing clause is a property of one JSON file
a script can read. The specification has the mirror-image gap: its success criteria carry no
identifier, so no test can name the criterion it accepts. [ADR-0002](0002-specification-change-process.md)
left per-clause identifiers open; this decision takes them up.

Two forces limit the answer. Some decisions cannot be decided by a program — that only a human
flips an ADR's status, that a leaked secret is rotated — and demanding tests for them produces tests
that assert nothing. And this template ships no language toolchain, so the rule can prescribe only
something every language's tests can carry.

## Decision

We will fail CI on any accepted ADR, and any criterion under **Goals / Success Criteria** or
**Quality Goals** in the specification, that no test cites with a `Verifies: <id>` marker.

- **Identifiers.** Every list item in those two sections starts with a bold `G-n` (Goals) or `Q-n`
  (Quality Goals), as in `- **G-1** — …`; an item without one fails. Identifiers are never
  renumbered or reused.
- **Marker.** `Verifies:` followed by one or more identifiers (`ADR-0003`, `G-1`), in any tracked
  file that is not Markdown. It is plain text so that every language can carry it.
- **Pending.** A criterion whose work has not landed yet ends with `*(pending)*`; the pull request
  that adds its test removes the marker. A pending criterion that a test already cites fails.
- **Exception.** An ADR whose decision a program cannot decide says so in its *Enforcement* section,
  in a paragraph starting `**Not mechanically decidable:**` with the reason. Criteria have no
  exception: a criterion no test can decide is not an acceptance criterion, and is rewritten until
  one can.
- **Invalid citation.** A marker citing an identifier that does not exist, or an ADR that is
  superseded or rejected, fails.

`proposed` ADRs are out of the check's scope: their implementation and tests land while they are
still proposed, and the acceptance lands with them ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)).

**Out of scope:** whether a citing test is adequate, which stays with review; whether the tests
pass, which is the project's own build-test job; and which test framework, layout, or kind of test a
project uses.

## Alternatives considered

- **Keep review-only enforcement as a legitimate default.** The state this ADR ends: the cheapest
  *Enforcement* entry is the one that protects nothing, and the record shows it is the one chosen. A
  coverage report that fails nothing is the same thing in a new format.
- **Tests without any exception.** Does not remove the undecidable decisions, it hides them behind
  tests that assert a constant. A written, reasoned exception is more honest.
- **Count a marker only in test files.** Stronger, but "test file" has no language-neutral
  definition. A project that has one narrows the check through its own ADR.
- **A language-specific mechanism** (annotations, tags, ArchUnit-style rule classes). Stronger where
  it exists, but a template without a toolchain cannot prescribe one; a project can add one on top
  of the marker.

## Sources / Prior art

- Ford, Parsons, Kua, Sadalage: *Building Evolutionary Architectures*, ch. 2 "Fitness Functions"
  (O'Reilly, 2nd ed.) — architectural characteristics protected by executable checks:
  <https://www.oreilly.com/library/view/building-evolutionary-architectures/9781492097532/ch02.html>.
- Adzic: *Specification by Example* (Manning, 2011) — acceptance criteria automated into executable
  specifications that stay traceable to their goals: <https://gojko.net/books/specification-by-example/>.

## Consequences

- Positive: "which test protects this decision?" and "is this goal met?" become lookups; a decision
  nobody verifies fails CI when it is accepted, not when it is found broken later; *Enforcement*
  stops being free text that can say "none".
- Negative / trade-offs: accepting an ADR requires its tests in the same pull request. A marker
  proves a claim, not adequacy — a test that cites and asserts nothing passes, and so does a marker
  in a file that is no test. A mistyped marker cites nothing and surfaces only as an uncited
  criterion. Removing `*(pending)*` is a specification change, so every pull request that meets a
  goal touches the specification. Quality goals must be phrased so a test can decide them.
- Follow-ups: each of the existing ADRs needs a citing test or a declared exception before it can
  be accepted.

## Enforcement

A new check, `scripts/check-traceability.sh`, run by `scripts/check-all.sh` and as its own job in
[`checks.yml`](../../.github/workflows/checks.yml), fails on every violation listed in the decision
above. It ships with tests of its own that cite this ADR.
