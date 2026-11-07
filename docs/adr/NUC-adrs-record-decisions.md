# NUC-adrs-record-decisions: Decisions are recorded as ADRs named by category and slug, on a fixed base of the template's `NUC-` ADRs

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** every ADR under `docs/adr/`, the ADR index `docs/adr/README.md`, the ADR template `docs/adr/template.md`, the blob list `docs/adr/NUC.blobs`, the record checks of `scripts/check-docs.sh`, the ADR readers of `scripts/lib/adr.sh`, `scripts/sensor-binding-adrs.sh`, `scripts/test-normalize-remap.sh`, the map script `.agents/skills/normalize/remap.sh`, and the skills `propose-adr` and `normalize`

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

1. **When.** An agent must create an ADR before an architecture-relevant decision.
   - Such a decision picks a dependency or framework, a public interface, a persistence or
     synchronization strategy, or a protocol or data format. It is anything that constrains
     future technology choices.
   - One ADR records one decision, or an integration whose decision is the interplay.
   - When the catalogue of `propose-adr` has an entry for a decision no ADR in force decides, the
     agent must propose the entry's fitting concepts first. The proposal must include the
     simplest of them.
2. **Calibration.** An ADR records a decision that is costly to reverse or constrains future
   choices. It also records one a reader without the conversation takes for a mistake, however
   cheap to reverse.
   - Implementing within an ADR in force needs no ADR. Nor do a bug fix, an interface-preserving
     refactoring, a test, documentation, formatting, or development-only tooling.
   - An agent that is unsure must write a short proposed ADR instead of deciding silently.
3. **Proposal.** An agent must submit an ADR as proposed, in commits of ADRs only, and hand them
   to the human before anything is implemented against them.
   - The commits go on the work's branch or on a branch of their own.
   - ADRs that one human decides may travel together.
   - An ADR the human sends back must move to a branch of its own. Nothing may be implemented
     against it until it is settled.
4. **Implementation.** After the human's review, the agent may implement while the ADR is
   proposed, after its commits, on the same branch or a stacked one.
   - A commit that changes the text of an ADR must change nothing else.
   - A normalization may carry the restated ADRs together with the text that cites them.
   - The template repository's correction of its own `NUC-` ADRs may carry the corrected ADRs
     together with the text that cites them.
   - Findings return as revisions, each a commit of ADRs only.
   - The hand-off must name the commit of ADRs that the human reviewed.
5. **Status.** Only a human may change the status of an ADR. The flip to accepted changes the
   header line only and may land with the implementation. An accepted ADR binds everyone, and
   nobody may violate or work around it.
6. **Immutability.** Outside a normalization, nobody may rewrite or delete an accepted project
   ADR. A project changes one only by superseding it. The template repository corrects its own
   `NUC-` ADRs in place, and a release ships the correction.
   - A take-up of a release may move each citation of a `NUC-` clause in an accepted project ADR,
     as the map of the release says.
   - When the cited clause changes its meaning, the project must supersede its ADR instead.
7. **Authority.** Authority runs from the specification to the accepted ADRs to the task. When the
   specification and an ADR conflict, the specification wins. An agent must raise the conflict
   instead of choosing silently.
8. **Identifier.** An identifier is a category key, a hyphen, and a slug, such as
   `SEC-host-socket-closed`.
   - The key is two to five capital letters. The slug is two to five lower-case words or numbers
     joined by hyphens, and it states the decision.
   - The file is `docs/adr/<identifier>.md`, headed `# <identifier>:` and the title.
   - The author picks the identifier when creating the file. No ADR has a draft state, and no step
     numbers ADRs.
   - The identifier must not change once the ADR is on `main`, even when its title changes.
   - No identifier may be used twice, deleted ADRs included. A successor takes a new slug.
   - The date in the header orders the ADRs.
9. **Categories.** The fixed categories are these:
   - `NUC`: the template's own ADRs, reserved to the template repository;
   - `SEC`: security;
   - `OPS`: build, release, deployment, and operation;
   - `API`: interfaces the system offers and consumes, adapters among them.

   A project must define every further category, with one line on what it holds, in the category
   list of the ADR index.
10. **Clauses.** The *Decision* of an ADR states its rules as numbered clauses. A citation of a
    clause adds a section sign and the number, such as `SEC-host-socket-closed §3`. A clause keeps
    its number, and a removed clause leaves its number unused.
11. **Fixed base.** The `NUC-` ADRs lie in `docs/adr/` next to the project's ADRs.
    - A derived project must not edit a `NUC-` file, and no project ADR may supersede one.
    - A project ADR may extend or narrow a `NUC-` clause, named in its `Extends:` or `Narrows:`
      field.
    - A project that must contradict a `NUC-` clause forks the template. The fork removes the blob
      list and names the release it forked in the **Template** section of its README.
    - A project takes up a release by replacing the `NUC-` files and the blob list. It accepts the
      base by naming the release it carries.
12. **Blob list.** The blob list `docs/adr/NUC.blobs` names each `NUC-` file with its git blob
    identifier. A change to a `NUC-` file rewrites the list in the same commit. In every
    repository, each `NUC-` file must match its line in the list.
13. **Roles.** The required roles are `harness` and `toolchain`. A project ADR that fills one
    carries the header field `Role:` naming it. Once the template setup is done, each role must
    have exactly one accepted ADR. The template refers to a role, never to a project's identifier.
14. **Supersession.** A project ADR that replaces others names each in its `Supersedes:` field
    from its proposal on. One ADR may supersede several whose decisions have grown into one. When
    a human accepts it, each old ADR's status flips to superseded by the new identifier, in the
    same change. A superseded ADR keeps its file and body until a normalization.
15. **Index.** The ADR index lists the category list and the project's ADRs by category. It links
    the `NUC-` base in one line and lists no `NUC-` ADR.
    - Each row shows the status by the legend's emoji and mirrors the ADR's `Applies to` verbatim.
    - Accepted and proposed ADRs stand under **Binding**, superseded and rejected ones under
      **Superseded and rejected**.
    - A row changes in the same commit as its ADR.
16. **Citations.** Every citation of an ADR must name a file in `docs/adr/`, and in Markdown it
    links that file. An anticipated follow-up is described by its topic. An identifier in a
    Markdown code span is an example or a plan, not a citation.
17. **Normalization.** A normalization restates the record, only on a human's instruction.
    - It restates the specification, then supersedes the ADRs that invalidates, then rewrites the
      project ADRs in force as a new set.
    - It changes no decision, and it deletes superseded and rejected ADRs.
    - A merged or split ADR takes a new identifier. The others keep theirs.
    - A map moves the references to the new identifiers. It stands in the hand-off and the commit
      body, in no document.
    - It leaves the `NUC-` files as they are.
    - The migration from numbered identifiers to category identifiers is a normalization. It gives
      every numbered ADR its category identifier.

**Out of scope:**

- the glossary and the change of the specification
  ([NUC-documents-are-fixed §5](NUC-documents-are-fixed.md) and
  [NUC-documents-are-fixed §2](NUC-documents-are-fixed.md));
- which test cites a decision ([NUC-decisions-cite-tests](NUC-decisions-cite-tests.md));
- the order of work of a proposal or a normalization (the skills `propose-adr` and `normalize`);
- what a project picks for each role (its role ADR).

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

- each identifier's form, file, heading, category, and uniqueness across the history (clauses 8
  and 9);
- the supersessions, the index rows, and the citations against the ADRs (clauses 14 to 16);
- the fixed base: no supersession of a `NUC-` ADR, existing `Extends:` and `Narrows:` clauses,
  and the blob list (clauses 11 and 12);
- one accepted ADR per required role after the setup (clause 13).

These scripts fail nothing:

- `scripts/sensor-review-binding.sh` lists each commit that changes the text of an ADR and another
  path (clause 4).
- `scripts/sensor-binding-adrs.sh` lists the ADRs in force whose *Applies to* names a path the
  change touches or the session names (clause 5). With `--sections` it prints the parts a session
  reads. Its self-test cites this ADR.
- `scripts/test-normalize-remap.sh` cites this ADR. It holds that a map moves every reference
  exactly once (clause 17). The map script refuses a chain or a cycle among ADR identifiers, so a
  second run changes nothing (clause 8). A map of criteria may swap them in one pass.

**Not mechanically decidable:** the review judges these (clauses 1 to 4, 11, 17):

- whether a decision needs an ADR;
- whether an ADR holds one decision;
- whether a narrowing contradicts its clause;
- whether the human reviewed the proposal before the implementation;
- whether a normalization changed no decision.
