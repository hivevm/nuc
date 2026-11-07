# NUC-documents-are-fixed: Six documents with one role each carry what a repository knows, and one rule file carries its working rules

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** `docs/SPECIFICATION.md`, `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, `docs/CONVENTIONS.md`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.github/CODEOWNERS`, `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md`, every per-agent pointer file and configuration, checks 3 and 4 of `scripts/check-docs.sh`, `scripts/sensor-plain-rules.sh`, and `scripts/lib/rules.sh`

## Context

Several coding agents may work in the same repository, and each looks for its instructions in a
different place. Without one written governance their behaviour drifts, rule sets are duplicated
and diverge, and structural decisions are made silently.

Three document roles follow from that: what the project is *for*, what has been *decided*, and
what the working *rules* are. Three more are easy to overlook.

- The record is a log. Nothing in it says what the system looks like **now**. Reconstructing that
  from the log costs more as it grows, and an agent starting without memory pays it every session.
- The vocabulary changes more often than any other part of the specification. A term is sharpened
  in almost every design conversation, which sits badly in the document meant to change least.
- An older project has conventions on how it writes code and tests where no check decides it. The
  rule file is the template's, the specification must not churn, and an ADR is for decisions. So a
  convention became an ADR it did not deserve, or stayed in someone's head, and a reviewer held
  the diff against nothing.

Two forces bound the answer. Every further document is a candidate second source of truth that
can go stale. And the specification outranks every ADR while nothing protects it: editing a goal
would be the cheapest route around an accepted decision, and the ADRs resting on the old clause
would keep their force.

A rule restated in a second document drifts unseen. A link to the rule's section breaks visibly
when the section moves, and a check catches the broken link.

## Decision

We will keep what a repository knows in six documents with one role each, and its working rules
in one rule file.

1. **The set.** These six documents carry what a repository knows, each in one role:
   - [`docs/SPECIFICATION.md`](../SPECIFICATION.md), the specification: what the project is for;
   - [`docs/adr/`](.), the record: the decisions derived from the specification;
   - [`AGENTS.md`](../../AGENTS.md), the rule file: the working rules;
   - [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md), the overview: the system as it stands;
   - [`docs/GLOSSARY.md`](../GLOSSARY.md), the glossary: the vocabulary;
   - [`docs/CONVENTIONS.md`](../CONVENTIONS.md), the conventions: the judgement calls on code and
     tests.

   No other document may carry a rule.
2. **Specification.** A change to the specification is a decision, not an edit.
   - Only a human may land the change.
   - The change must name every accepted ADR whose basis it moves.
   - The human reconsiders each named ADR in the same review and supersedes each one it
     invalidates.
   - An agent may draft specification text. It must not land the change. It must not judge alone
     that no ADR is affected.
   - A change to a passage that no ADR derives from names no ADR.
3. **Record.** [NUC-adrs-record-decisions](NUC-adrs-record-decisions.md) decides how the record is
   kept.
4. **Rule file.** The rule file is vendor-neutral and the one source of working rules for humans
   and agents alike.
   - A repository must have exactly one rule file.
   - Another document must cite a working rule by a link to its section anchor. It must not
     restate the rule.
   - A working rule that the rule file neither states nor links is not a rule of the project.
5. **Overview.** The overview names the system's parts, their responsibilities, and how they fit
   together.
   - It must hold no rule and no decision.
   - It must cite the ADR behind each structural choice.
   - A change to the structure must update the overview in the same change.
   - Where the overview and an accepted ADR disagree, the ADR is right.
6. **Glossary.** The glossary defines the terms specific to the domain and decides nothing.
   - An entry names one term in bold and says in one or two sentences what it is.
   - An entry lists under _Avoid:_ the synonyms the term displaces, where there are any.
   - Whoever resolves a term, an agent included, must add it in the same change that settles it.
   - Code, comments, and documents must use the glossary's terms. A missing entry is a gap to
     close in the glossary, not a word to invent.
   - The specification must use the glossary's terms and must define none of its own.
7. **Conventions.** The conventions say how the project writes code and tests where no check
   decides it.
   - An entry says in a sentence or two what is done and why.
   - Whoever settles a convention, an agent included, must update the file in the same change as
     the review or code that settled it.
   - A convention that a check is able to decide must become the check, not an entry.
   - A convention that constrains future choices must become an ADR, not an entry.
   - The reviewer must receive the conventions. The implementer reads them when the work needs
     them.
8. **Other documents.** Every other document must point at the rule file and must hold no rule of
   its own. Examples are `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, the setup file while it
   exists, the issue and pull request templates, the per-agent pointer files, and the catalogue of
   `propose-adr`.
9. **Mechanics.** A document may hold the mechanics that the rule file or a `NUC-` ADR delegates
   to it.
   - The mechanics of the record stand in [`docs/adr/README.md`](README.md) and its
     [`template.md`](template.md).
   - The mechanics of integration stand in the sections *Git hooks*, *Integration branches*, and
     *Repository settings* of [`CONTRIBUTING.md`](../../CONTRIBUTING.md).
   - Mechanics say how a rule is carried out. They must add no rule.
   - `README.md` serves those who use the project and must hold no mechanics.
10. **Per-agent configuration.** A per-agent configuration may close a path for its one agent as
    defence in depth. It enforces no rule, and no rule may rest on it.

**Out of scope:**

- how the record is kept, which [NUC-adrs-record-decisions](NUC-adrs-record-decisions.md)
  decides;
- what the rule file says, beyond clause 4;
- the order of work of a setup, which the setup file and its skill carry.

## Latitude

A project may choose:

- which agents work in it and which of them need a pointer file, from the entry `harness` of the
  [catalogue](../../.agents/skills/propose-adr/concepts/README.md);
- the notation and depth of the overview; the catalogue has no entry, and the choice needs no ADR;
- a context map and one vocabulary per bounded context, for a repository with more than one; the
  catalogue has no entry, and the choice needs no ADR;
- which of the other documents of clause 8 it keeps; the catalogue has no entry, and the choice
  needs no ADR.

## Alternatives considered

- **Per-tool instruction files.** They guarantee drift between agents and multiply maintenance.
- **Rules embedded in `README.md`.** They mix the onboarding of users with agent governance.
- **No overview; the record is the current state.** It holds while the log is short and degrades
  silently as it grows.
- **Vocabulary inside the specification.** The right authority for a goal is the wrong authority
  for a word. Every renamed term became a specification change only a human lands, so the
  vocabulary in the tree lagged the vocabulary in use.
- **The full ADR lifecycle for the specification.** Immutable clauses would demand a supersession
  for a wording fix. The specification is living intent, not a record.
- **A CI check requiring an ADR reference on every specification change.** It cannot tell a typo
  fix from a rewritten goal. So it blocks ordinary edits or is satisfied by a token reference.
- **Conventions in the rule file.** The file is the template's. Project conventions in it collide
  with every template release and reach every session, whether it writes code or not.
- **Conventions as ADRs.** The wrong lifecycle: a convention is refined every few weeks, an ADR is
  superseded. The record fills with decisions nobody would take for one.
- **Conventions only as checks.** That is the mechanical half. Naming, what a module may know, and
  what a test asserts are judgement calls no linter decides, and a reviewer needs them written
  down most.

## Sources / Prior art

- The `AGENTS.md` convention — <https://agents.md>: one open file for coding agents, the format
  the rule file takes.
- Michael Nygard, *Documenting Architecture Decisions* —
  <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions>: the ADR form, and
  that a record is immutable and superseded.
- GitHub Spec Kit — <https://github.com/github/spec-kit>: a "constitution" written once per
  project that every feature derives from; the specification's role here.
- Matt Pocock, *domain-modeling* skill —
  <https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md>: a
  glossary "and nothing else", devoid of implementation, next to `docs/adr/`; the model for the
  glossary. *A complete guide to AGENTS.md* on the same author's site —
  <https://www.aihero.dev/a-complete-guide-to-agents-md>: "Every token in your AGENTS.md file
  gets loaded on every single request", so "be ruthless about what goes here".
- Addy Osmani, *AGENTS.md* — <https://addyosmani.com/blog/agents-md/>: every line traceable to
  something that went wrong.
- Birgitta Böckeler, *Context engineering for coding agents* —
  <https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html>:
  build rules files up gradually; why conventions live in a document with a retro rather than in
  the rule file.
- Jarosław Wąsowski, *Designing a spec that survives code generation* —
  <https://medium.com/@wasowski.jarek/sdd-designing-a-spec-that-survives-code-generation-spec-first-spec-driven-development-b61fdc234493>:
  specification types with different lifecycles, and that maintaining everything is the wrong
  answer; read in abstract only, the article is paywalled.

## Consequences

- Positive: one place to change a rule, and consistent agent behaviour.
- Positive: one place answers what the system looks like.
- Positive: the session that changes the vocabulary maintains it.
- Positive: the specification stops being a way around an accepted ADR.
- Positive: a convention has a place that is neither an ADR nor a head, and the reviewer holds the
  diff against something written.
- Negative: nothing mechanical keeps another document from stating a rule of its own. The
  documents have to stay small enough for a review to see it.
- Negative: a stale overview is worse than none because it is believed, and no check tells the two
  apart.
- Negative: naming the ADRs a specification change moves is a judgement no check makes.
- Negative: the conventions attract entries a check could decide, and only the design revision
  moves them out.
- Follow-ups: a context map for repositories with more than one bounded context.

## Enforcement

[`scripts/check-docs.sh`](../../scripts/check-docs.sh) holds clause 4, and its self-test cites
this ADR:

- check 3 fails on a relative link between documents that does not resolve;
- check 4 fails on a section reference that names no section of the rule file.

[`scripts/sensor-plain-rules.sh`](../../scripts/sensor-plain-rules.sh) holds clause 6, and its
self-test cites this ADR. It reports each word an _Avoid:_ list names on a line a change adds to
the rule file, or to the *Decision* or *Enforcement* of an ADR. It names the term to use instead.
It skips a word in a code span or in italics. It fails nothing.

[`.github/CODEOWNERS`](../../.github/CODEOWNERS) routes a change to the specification to the
owner's review once the file names an owner and the repository requires the review (clause 2).
*Repository settings* in [`CONTRIBUTING.md`](../../CONTRIBUTING.md) names the setting.

**Not mechanically decidable:** five judgements rest with the review:

- whether another document holds a rule (clauses 1, 8, and 9);
- whether a specification change names every ADR it moves (clause 2);
- whether the overview matches the system (clause 5);
- whether the glossary's terms are the ones in use, beyond what the sensor reports (clause 6);
- whether a convention stands where a check is able to decide it (clause 7).
