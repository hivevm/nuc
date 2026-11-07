# NUC-adrs-record-decisions: Decisions are recorded as ADRs named by category and slug, on a fixed base of the template's `NUC-` ADRs

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** every ADR under `docs/adr/`, the ADR index `docs/adr/README.md`, the ADR template `docs/adr/template.md`, the blob list `docs/adr/NUC.blobs`, the record checks of `scripts/check-docs.sh`, the ADR readers of `scripts/lib/adr.sh`, `scripts/sensor-binding-adrs.sh`, and the skills `propose-adr` and `normalize`

## Context

The record has three weaknesses that this template and every derived project share.

- **Identifiers say nothing.** An ADR is cited by a number. A number names no topic, so a reader
  of a commit, an issue, or a code comment opens the file to learn what was meant. A draft takes
  its number only on the way to `main`, through a numbering script, a check against drafts on
  `main`, and a rule for two branches that took the same number. A normalization renumbers the
  whole record, and every citation outside the tree goes stale.
- **The inherited ADRs are edited.** A derived project accepts an inherited ADR by adding its
  decider to it, and some projects add clauses as well. After that edit the project owns the
  text. A take-up of a release cannot replace the files; it merges them through a normalization.
  A check on the template's text fails on the project's edits, which is why the check on avoided
  terms stayed a sensor.
- **The rules of the record stand in no ADR.** [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules) and the
  mechanics of the index state them. The binding sensor routes a change only to ADRs, so a change to
  the record reaches these rules only through the rule file, and a project cannot narrow them in its
  record.

Several forces bound the answer. Every agent reads the same files, so the identifier has to work
in plain text, file names, and Markdown links. The checks are bash and must keep working on
macOS, Linux, and Windows under Git Bash. A derived project needs room for its own categories.
Each choice the template leaves open must stay visible as a choice.

## Decision

We will record each architecture decision as one ADR named by a category key and a slug. The
template's `NUC-` ADRs are a fixed base that a project extends or narrows but never edits.

1. **When.** An agent must create an ADR before an architecture-relevant decision. Such a
   decision picks a dependency or framework, a public interface, a persistence or synchronization
   strategy, or a protocol or data format. It is anything that constrains future technology
   choices. One ADR records one decision. A cross-cutting ADR may record an integration, where the
   decision is the interplay. The catalogue of `propose-adr` may have an entry for the decision
   that no ADR in force decides. Then the agent must propose the entry's fitting concepts first.
2. **Calibration.** An ADR records a decision of one of these kinds:
   - it is costly to reverse;
   - it constrains future choices;
   - a reader without the conversation would take it for a mistake.

   The last kind needs an ADR however cheap it is to reverse. These need no ADR:
   - implementing within an ADR in force;
   - a bug fix, an interface-preserving refactoring, a test, documentation, or formatting;
   - tooling used only in development.

   An agent that is unsure must write a short proposed ADR instead of deciding silently.
3. **Proposal.** An agent submits an ADR with the status proposed, in commits that change ADRs
   only. It must hand those commits to the human before anything is implemented against them.
   - The commits go on the branch of the work they belong to, or on a branch of their own.
   - Several ADRs that the same human decides may travel together. Each stays one decision.
   - An ADR that the human sends back must leave the work's branch for a branch of its own.
     Nothing may be implemented against it until it is settled.
4. **Implementation.** After the human's review, the agent may implement while the ADR is still
   proposed. The implementation follows the ADR's commits, on the same branch or a stacked one. A
   commit that changes the text of an ADR must change nothing else. Findings return as revisions,
   each a commit of ADRs only. The hand-off must name the commit of ADRs that the human reviewed.
5. **Status.** Only a human may change the status of an ADR. The flip to accepted changes the
   header line only and may land with the implementation. An accepted ADR binds every human and
   agent. Nobody may violate or work around it.
6. **Immutability.** Outside a normalization, nobody may rewrite or delete an accepted project
   ADR. A project changes one only by superseding it. The template repository corrects its own
   `NUC-` ADRs in place, and a release ships the correction.
7. **Authority.** Authority runs from the specification to the accepted ADRs to the task. When
   the specification and an ADR conflict, the specification wins. An agent must raise the
   conflict and must not choose silently.
8. **Identifier.** An ADR's identifier is its category key, a hyphen, and its slug, such as
   `SEC-host-socket-closed`.
   - The category key is two to five capital letters. The slug is two to five lower-case words
     or numbers joined by hyphens, and it states the decision.
   - The file is `docs/adr/<identifier>.md`. Its heading starts with `# <identifier>:` and the
     title.
   - The author picks the identifier when the file is created. No ADR has a draft state, and no
     step numbers ADRs.
   - The identifier must not change once the ADR is on `main`, even when its title changes.
   - No identifier may be used twice, including the identifiers of deleted ADRs in the history.
     A successor takes a new slug.
   - The date in the header gives the order of ADRs.
9. **Categories.** The fixed categories are these:
   - `NUC`: the template's own ADRs, reserved to the template repository;
   - `SEC`: security;
   - `OPS`: build, release, deployment, and operation;
   - `API`: interfaces the system offers and consumes, adapters among them.

   A project must define every further category in the category list of the ADR index, each
   with one line on what it holds. The checks read that list.
10. **Clauses.** The *Decision* of an ADR states its rules as numbered clauses. A citation of a
    clause is the identifier, a section sign, and the number, such as `SEC-host-socket-closed §3`.
    A clause keeps its number. A removed clause leaves its number unused.
11. **Fixed base.** The `NUC-` ADRs lie in `docs/adr/` next to the project's ADRs.
    - A derived project must not edit a `NUC-` file, and no project ADR may supersede one.
    - A project ADR may extend or narrow a `NUC-` clause. It names the clause in the header field
      `Extends:` or `Narrows:`.
    - A project that must contradict a `NUC-` clause forks the template. A fork removes the blob
      list and names the release it forked in the **Template** section of its README.
    - A project takes up a release by replacing the `NUC-` files and the blob list.
    - A project accepts the base by naming the release it carries.
12. **Blob list.** The blob list `docs/adr/NUC.blobs` names each `NUC-` file with its git blob
    identifier. A change to a `NUC-` file rewrites the list in the same commit. In every
    repository, each `NUC-` file must match its line in the list.
13. **Roles.** Some choices are required project ADRs. Such an ADR carries the header field
    `Role:` with the role it fills. The required roles are `harness` and `toolchain`. Once the
    template setup is done, each required role must have exactly one accepted ADR. The template
    refers to a role, never to a project's identifier.
14. **Supersession.** A project ADR that replaces others names each in its `Supersedes:` field
    from its proposal on. When a human accepts it, the status of each old ADR flips to superseded
    by the new identifier, in the same change. Until a normalization, a superseded ADR keeps its
    file and its body. One ADR may supersede several whose decisions have grown into one.
15. **Index.** The ADR index lists the project's ADRs, grouped by category, and the category
    list.
    - It links the `NUC-` base in one line and lists no `NUC-` ADR.
    - Each row shows the status by the legend's emoji and mirrors the ADR's `Applies to` field
      verbatim.
    - Accepted and proposed ADRs stand under **Binding**. Superseded and rejected ADRs stand
      under **Superseded and rejected**.
    - A row changes in the same commit as its ADR.
16. **Citations.** Every citation of an ADR must name a file that exists in `docs/adr/`. An
    anticipated follow-up is described by its topic. In Markdown, a citation of an ADR is a link
    to its own file.
    - An identifier in a Markdown code span is an example or a planned identifier. It is not a
      citation.
    - A citation is a link, or an identifier outside a code span.
17. **Normalization.** A normalization restates the record, only on a human's instruction.
    - It restates the specification first. It supersedes the ADRs the restatement invalidates
      next. Then it rewrites the project ADRs in force as a new set.
    - It changes no decision. It deletes superseded and rejected ADRs.
    - A merged or split ADR takes a new identifier. The others keep theirs.
    - A map moves the references from the old identifiers to the new ones. The map stands in
      the hand-off and the commit body, in no document.
    - A normalization leaves the `NUC-` files as they are.

**Out of scope:**

- the vocabulary of the glossary, which belongs to the document set;
- the rule that a change to the specification is a decision, which belongs to the document set;
- which test cites a decision and how, which belongs to the ADR on tests;
- the order of work of a proposal or a normalization, which the skills `propose-adr` and
  `normalize` carry;
- what a project picks for each role, which its role ADR decides.

## Latitude

A project may choose:

- further categories, defined in the category list of its index;
- extensions and narrowings of any `NUC-` clause, each in an ADR of its own;
- the concepts of each required role, from the entries `harness` and `toolchain` of the
  [catalogue](../../.agents/skills/propose-adr/concepts/README.md);
- a fork of the template, when it must contradict a `NUC-` clause.

## Alternatives considered

- **Sequential numbers, as before.** They are short and sort by age. They name no topic, need a
  draft state and a numbering step, collide between parallel branches, and change at every
  normalization.
- **A category with a number, such as `SEC-0003`.** It names the area. Parallel branches still
  collide on the counter, and the number still says nothing within the category.
- **A date or a random identifier.** It never collides. Nobody can read or remember it, and a
  citation in prose means nothing without the file.
- **The slug alone, without a category.** It reads well. The index loses its grouping, and
  nothing marks the template's ADRs apart from the project's.
- **Inherited ADRs that the project edits, as before.** A project sees the template's text as its
  own and may adapt it freely. Every take-up merges by hand, and no check can tell the template's
  text from the project's.
- **The `NUC-` ADRs in a directory of their own.** The base would be visibly apart. The readers
  would need two paths, and the prefix already marks the base.
- **A SHA-256 list instead of git blob identifiers.** SHA-256 is the common checksum. It needs a
  tool that differs between macOS, Linux, and Windows, and it changes with the line endings. Git
  computes the blob identifier on every platform, from the content git stores.

## Sources / Prior art

- Michael Nygard, "Documenting Architecture Decisions" (2011): the short ADR with context,
  decision, status, and consequences, numbered in sequence.
- MADR, the Markdown Architectural Decision Records template: file names of a number and a title,
  and the status field.
- adr-tools by Nat Pryce: a numbering script and supersession links between numbered records.
- The Git object model (Pro Git, chapter "Git Internals – Git Objects"): a blob's identifier is
  the hash of its stored content, the same on every platform.
- The template's own record before this ADR: [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), the
  mechanics of the ADR index, the draft clause of the ADR on tests, and the release take-up through
  a normalization.

## Consequences

- Positive: a citation names its topic, in a commit, an issue, or a code comment.
- Positive: no numbering step, no draft check, and no collision between parallel branches.
- Positive: a take-up of a release replaces files and runs the checks.
- Positive: a check can spare the template's files, because no project edits them.
- Positive: the binding sensor routes a change to the rules of the record like to any other ADR.
- Negative: every derived project migrates its record once, with a map the human reviews.
- Negative: a project can no longer adapt the template's text; it narrows by an ADR or forks.
- Negative: an author has to name the decision in five words when creating the file.
- Follow-ups: the restatement of the other template ADRs as `NUC-` ADRs; the checks on modal
  verbs and avoided terms that spare the base; the migration steps in the `normalize` skill.

## Enforcement

`scripts/check-docs.sh` holds these clauses, and its self-test cites this ADR:

- the file name, the heading, and the form of each identifier (clause 8);
- a category in the fixed set or in the category list (clause 9);
- an identifier unique in the tree and in the history of deleted ADRs (clause 8);
- every citation names an existing ADR and links its own file (clause 16);
- the index lists every project ADR once, in the right table, with its status and `Applies to`
  (clause 15);
- the `Supersedes:` field and the status lines agree (clause 14);
- no project ADR supersedes a `NUC-` ADR, and each `Extends:` or `Narrows:` names an existing
  clause (clause 11);
- each `NUC-` file matches the blob list (clause 12);
- after the setup, each required role has exactly one accepted ADR (clause 13).

`scripts/sensor-review-binding.sh` lists each commit that changes the text of an ADR and another
path (clause 4).

**Not mechanically decidable:** clauses 1 to 4 and 11 hold four judgements. The review holds
them:

- whether a decision needs an ADR;
- whether an ADR holds one decision;
- whether a narrowing contradicts its clause;
- whether the human reviewed the proposal before the implementation.
