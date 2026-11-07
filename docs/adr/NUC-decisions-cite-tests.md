# NUC-decisions-cite-tests: Every accepted decision and every criterion of the specification is verified by a test that cites it

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** every accepted ADR and its *Enforcement*, the Goals and Quality Goals of `docs/SPECIFICATION.md`, every `Verifies:` marker, `scripts/check-traceability.sh`, and `scripts/test-check-traceability.sh`

## Context

This template drives development from a specification. Authority runs from the specification to
the accepted ADRs to the task ([NUC-adrs-record-decisions §7](NUC-adrs-record-decisions.md)).
Neither end of that chain is connected to anything executable. The Definition of Done requires
tests for new behaviour ([`AGENTS.md` §5](../../AGENTS.md#5-quality-bar--definition-of-done)).
Nothing says which decision or goal a test protects, and nothing notices a decision that no test
protects. The cheapest *Enforcement* an ADR can carry is "review only", and it protects nothing.

Two forces bound the answer. Some decisions cannot be decided by a program: only a human flips an
ADR's status, and only a reviewer sees that a large effort was planned before it was built. Tests
demanded for them assert a constant. And the template ships no language toolchain, so the rule
can prescribe only what the tests of every language can carry.

## Decision

We will fail CI on an accepted ADR that no test cites, and report each criterion of the
specification that no test cites.

1. **Criterion identifiers.** Every list item under **Goals / Success Criteria** must start with
   a bold `G-n`. Every list item under **Quality Goals** must start with a bold `Q-n`. The form
   is `- **G-n** — …`. An item without an identifier fails.
2. **No reuse.** Nobody may reuse the identifier of a criterion. Only a normalization renumbers
   criteria ([NUC-adrs-record-decisions §17](NUC-adrs-record-decisions.md)). It must move every
   marker with them.
3. **Marker.** A test cites what it verifies by a marker: `Verifies:` and one or more identifiers
   of ADRs or criteria.
   - A marker may stand in any file that git does not ignore, except a Markdown file.
   - A marker is plain text, so that every language can carry it.
4. **Coverage.** The check fails on an accepted ADR that no marker cites. A proposed ADR is out
   of its scope. Its tests land while it is proposed, and its acceptance lands with them
   ([NUC-adrs-record-decisions §4](NUC-adrs-record-decisions.md),
   [NUC-adrs-record-decisions §5](NUC-adrs-record-decisions.md)).
5. **Exception.** An ADR whose decision no test can decide must say so in its *Enforcement*.
   - It carries a paragraph that starts with `**Not mechanically decidable:**` and gives the
     reason.
   - A decision qualifies when only a human can decide it.
   - A decision also qualifies when it governs how the project works, not what the system does.
   - The paragraph exempts the ADR from clause 4.
6. **Pending criteria.** A criterion that no marker cites is pending work. The check lists it and
   does not fail. The specification marks no state, so meeting a goal touches the tests only.
7. **No exception for criteria.** A criterion has no exception. A criterion that no test can
   decide is no acceptance criterion. Its author must rewrite it until a test can decide it.
8. **Invalid citation.** A marker fails when it names an identifier that does not exist. A marker
   also fails when it names a superseded or rejected ADR.

**Out of scope:**

- whether a citing test is adequate, which stays with review;
- whether the tests pass, which the project's build and test decide;
- which test framework, layout, or kind of test a project uses, which its `toolchain` role ADR
  decides ([NUC-adrs-record-decisions §13](NUC-adrs-record-decisions.md));
- the form of an ADR's identifier, which
  [NUC-adrs-record-decisions §8](NUC-adrs-record-decisions.md) decides;
- what the checks are written in, which [NUC-checks-are-bash](NUC-checks-are-bash.md) decides.

## Latitude

A project may choose:

- its test framework, layout, and kinds of test, from the entry `toolchain` of the
  [catalogue](../../.agents/skills/propose-adr/concepts/toolchain.md);
- a language-specific mechanism on top of the marker, such as annotations or tags;
- a narrower place for the marker, such as test files only. That choice narrows clause 3 in an
  ADR of its own ([NUC-adrs-record-decisions §11](NUC-adrs-record-decisions.md)).

The catalogue has no entry for the second choice, and it needs no ADR.

## Alternatives considered

- **Review-only enforcement as a legitimate default.** This is the state the ADR ends. A coverage
  report that fails nothing is the same thing in a new format.
- **Tests without any exception.** It does not remove the undecidable decisions. It hides them
  behind tests that assert a constant. A check that counts the headings of an issue template
  protects the template, not the decision.
- **A pending mark on each criterion in the specification.** The check could then fail on an
  unmarked criterion. Every pull request that meets a goal would change the specification, which
  only a human may land. The report says the same without touching the document.
- **A marker counts only in test files.** It is stronger, but "test file" has no
  language-neutral definition. A project that has one narrows clause 3 in its own ADR.
- **A language-specific mechanism,** such as annotations, tags, or ArchUnit-style rule classes.
  It is stronger where it exists, but a template without a toolchain cannot prescribe one. A
  project may add one on top of the marker.

## Sources / Prior art

- Birgitta Böckeler, *Harness engineering* —
  <https://martinfowler.com/articles/harness-engineering.html>: a harness is guides that feed
  forward and sensors that feed back, and the behaviour harness is the least mature. This ADR
  wires a decision to a sensor.
- Birgitta Böckeler, *Sensors for coding agents* —
  <https://martinfowler.com/articles/sensors-for-coding-agents.html>: coverage says a line ran,
  not that its effect was verified. That is why a marker proves a claim, not adequacy.
- Addy Osmani, *Agentic code review* — <https://addyosmani.com/blog/agentic-code-review/>: a
  green check over edited tests means nothing until the edits are confirmed. That is why every
  changed test needs a reason in review.

## Consequences

- Positive: "which test protects this decision?" and "is this goal met?" become lookups.
- Positive: a decision nobody verifies fails CI when it is accepted, not when it is found broken.
- Positive: *Enforcement* stops being free text that can say "none".
- Negative: accepting an ADR requires its tests in the same change.
- Negative: a marker proves a claim, not adequacy. A test that cites and asserts nothing passes,
  and so does a marker in a file that is no test.
- Negative: a criterion that loses its test shows only in the check's report and in the diff
  that deleted the test.
- Negative: quality goals must be phrased so that a test can decide them.

## Enforcement

`scripts/check-traceability.sh` holds these clauses. `scripts/check-all.sh` runs it, and so does
its own job in [`checks.yml`](../../.github/workflows/checks.yml). Its self-test
`scripts/test-check-traceability.sh` cites this ADR.

- It fails on a criterion without an identifier, and on an identifier that appears twice
  (clauses 1 and 2).
- It reads a marker in every file git does not ignore, except Markdown (clause 3).
- It fails on an accepted ADR that no marker cites and that carries no exception (clauses 4
  and 5).
- It lists the criteria that no marker cites, and does not fail on them (clause 6).
- It fails on a marker that names an unknown identifier or a superseded or rejected ADR
  (clause 8).

**Not mechanically decidable:** three judgements rest with the review:

- whether an identifier of a deleted criterion is used again (clause 2);
- whether the reason of an exception holds (clause 5);
- whether a test can decide a criterion (clause 7).
