# Architecture Decision Records

This directory contains all Architecture Decision Records (ADRs) for this project. Accepted ADRs are
**binding** for humans and coding agents alike (see [`AGENTS.md`](../../AGENTS.md) in the repository
root). ADRs derive from the specification in [`docs/SPECIFICATION.md`](../SPECIFICATION.md).

## Mechanics

The rules live in [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules): when an ADR is written, how it
is developed, who flips its status, that an accepted one is immutable and changed only by
supersession. This section carries only the mechanics of the record;
[`scripts/check-docs.sh`](../../scripts/check-docs.sh) names in its header which of them it
verifies.

- **File.** Copy [`template.md`](template.md) to `<CAT>-<slug>.md` and head it
  `# <CAT>-<slug>: <title>`, the category from the [list](#categories). The author picks the
  identifier when creating the file, and it never changes or returns
  ([NUC-adrs-record-decisions §8](NUC-adrs-record-decisions.md)). An older ADR,
  `NNNN-short-title.md` headed `# ADR-NNNN`, keeps its number until it retires.
- **Wording.** The *Decision* and the *Enforcement* follow the writing rule of
  [`AGENTS.md` §4](../../AGENTS.md#4-working-style).
- **Index.** The tables below change in the same commit as the ADR they describe, for
  additions, supersessions, and status flips alike. The status is shown via the legend's bullet
  and the ADR's `Applies to` header is mirrored verbatim in its own column. The index routes a
  reader from a change to the decisions that bind it, so a row says what its ADR governs without
  the file being opened. Two tables keep what a session reads apart from what it looks up: an
  accepted or proposed ADR sits under **Binding**, a superseded or rejected one under
  **Superseded and rejected**, and a status flip moves the row.
- **Identifiers are permanent once on `main`.** A normalization keeps them, and only a merged or
  split ADR takes a new one ([NUC-adrs-record-decisions §17](NUC-adrs-record-decisions.md)).
  Between two normalizations, never rename, delete, or merge an ADR there: other ADRs, commits
  (`Implements <CAT>-<slug>`), and code cite it. A superseded ADR keeps its file and its body.
  The superseding ADR's `Supersedes` field names it from the proposal on; its `Status` line
  flips to `⚪ superseded by <CAT>-<slug>` in the change where a human accepts the successor
  ([NUC-adrs-record-decisions §14](NUC-adrs-record-decisions.md)), its index row moving with it.
- **Between normalizations, sprawl is curbed by supersession, never by editing.** One ADR may
  supersede several whose decisions have grown into one. Its `Supersedes` field names each, and
  each flips its status when the superseding ADR is accepted, so the set an agent reads shrinks
  while every identifier and every body stays.
- **A normalization restates the record** ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules), rule
  5).
  - **Start.** The tree has no proposed ADR, no feature spec or ticket under `docs/plan/`, and
    green checks.
  - **Steps.** Three, in this order on one branch, each handed to the human and confirmed
    before the next begins: the restated specification, whose `G-n` and `Q-n` run from 1; the
    supersessions it calls for; and the restated record. The record begins once the human has
    decided each supersession. One pull request lands them, merged by a human.
  - **Order.** The record numbers the ADRs in force `0001..N` by what they govern. The document
    set and the ADR process come first, then the founding decisions in the order of the setup,
    then the rest in groups. An inherited ADR takes its place like any other, and may be merged
    with the project's own.
  - **Clauses.** Every clause of an old ADR lives on in one new ADR. The hand-off of the
    record lists each clause with the new ADR that carries it.
  - **Header.** A new ADR keeps the status of the ADRs it restates. Its `Deciders` name all of
    theirs, its `Date` is the latest of theirs, and it has no `Supersedes` field. In an
    adoption, an ADR the project had accepted stays accepted. A decision found outside any
    record enters as proposed.
  - **Dead ADRs.** Superseded and rejected ADRs are deleted. What one of them chose, and why it
    did not stand, becomes an entry under *Alternatives considered* in the new ADR that governs
    its topic.
  - **References.** Each step moves its references with a map, old to new, applied by the map
    script of the `normalize` skill. The map stands in the hand-off and the
    commit body, and in no document. A commit older than the normalization cites the numbers it
    had then.
- **Cite only what exists.** Every citation, `<CAT>-<slug>`, a clause `<CAT>-<slug> §n`, or
  `ADR-NNNN`, names a file already in this directory. An anticipated follow-up is described by
  topic ("a follow-up ADR on session storage"). What counts as a citation, and its form in
  Markdown, is [NUC-adrs-record-decisions §16](NUC-adrs-record-decisions.md).

## Index

An ADR whose `Deciders` line names the **NUC maintainer** is inherited from the template. It
binds a derived project once its own maintainer adds their name to `Deciders` and its `Status`
line reads `🟢 accepted` ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). Change an inherited
decision by superseding it, never by editing. Once the template setup is done, check 12 of
[`scripts/check-docs.sh`](../../scripts/check-docs.sh) fails on an inherited ADR in force that
names no decider of the project, or that is still proposed. It does not read a `NUC-` ADR, which a
project never edits ([NUC-adrs-record-decisions §11](NUC-adrs-record-decisions.md)).

### Categories

The category of an identifier says what its decision is about
([NUC-adrs-record-decisions §9](NUC-adrs-record-decisions.md)). The fixed ones:

- **NUC** — the template's own ADRs, reserved to the template repository.
- **SEC** — security.
- **OPS** — build, release, deployment, and operation.
- **API** — interfaces the system offers and consumes, adapters among them.

The project's own follow here, each in the same form with one line on what it holds:

None yet.

**Status legend:** 🟢 accepted · 🟡 proposed · 🔴 rejected · ⚪ superseded

### Binding

The decisions in force: accepted, and proposed ones that bind the work implementing them. This
is the table a session reads.

| ADR | Title | Applies to | Status |
|-----|-------|------------|--------|
| [0001](0001-agent-governance-model.md) | The document set: one specification, one ADR record, one `AGENTS.md`, one overview, one glossary, one conventions file | every document that carries rules for humans or agents, `AGENTS.md` among them, the architecture overview, the glossary, the conventions, `scripts/check-docs.sh`, `scripts/sensor-binding-adrs.sh`, `scripts/sensor-plain-rules.sh`, and the map script of the `normalize` skill, `.agents/skills/normalize/remap.sh` | 🟢 accepted |
| [0002](0002-decisions-verified-by-tests.md) | Every accepted decision and every success criterion is verified by a test that cites it, and the checks that hold the decisions are bash scripts under `scripts/` | every accepted ADR, the identifiers by which ADRs are cited, the Goals and Quality Goals of `docs/SPECIFICATION.md`, the tests that verify them, the checks and sensors under `scripts/`, and the git hooks under `.githooks/` | 🟢 accepted |
| [0003](0003-procedures-as-skills.md) | The procedures of the rule file are Agent Skills under `.agents/skills/`, each carrying a how and no rule of its own | `.agents/skills/`, the pointers under `.claude/skills/`, and every document that describes how a procedure of `AGENTS.md` is carried out | 🟢 accepted |
| [0004](0004-dev-container-runtime.md) | The Dev Container keeps the host daemon out of reach, its Features locked, and each project under a path of its own | `.devcontainer/`, `.vscode/settings.json`, `scripts/check-devcontainer.sh`, and everything the container pulls in | 🟢 accepted |
| [0005](0005-template-releases.md) | The template is released as SemVer tags on `main`, and every repository names the release it carries | the tags of the template repository, its own ADRs, the **Template** section of `README.md`, check 14 of `scripts/check-docs.sh`, and the pull request that lands a release | 🟢 accepted |
| [0006](0006-feature-layer.md) | Work larger than one session is planned in the tree as a feature spec cut into tracer-bullet tickets, files deleted when their work lands, findings outside the plan go to a backlog, and the design is revised when a spec closes or after a number of changes | every change larger than one agent session, `docs/plan/`, the spec and ticket templates of the `plan-feature` skill, the pull request template, the `Last design revision` line of `docs/ARCHITECTURE.md`, `scripts/sensor-revision-due.sh`, `scripts/sensor-plan-frontier.sh`, the claim script `.agents/skills/work-tickets/claim.sh`, `docs/backlog/`, and `scripts/sensor-backlog.sh` | 🟢 accepted |
| [NUC-adrs-record-decisions](NUC-adrs-record-decisions.md) | Decisions are recorded as ADRs named by category and slug, on a fixed base of the template's `NUC-` ADRs | every ADR under `docs/adr/`, the ADR index `docs/adr/README.md`, the ADR template `docs/adr/template.md`, the blob list `docs/adr/NUC.blobs`, the record checks of `scripts/check-docs.sh`, the ADR readers of `scripts/lib/adr.sh`, `scripts/sensor-binding-adrs.sh`, and the skills `propose-adr` and `normalize` | 🟡 proposed |
| [NUC-releases-are-semver-tags](NUC-releases-are-semver-tags.md) | The template is released as SemVer tags, and every repository names the release it carries | the tags of the template repository, the **Template** section of `README.md`, check 14 of `scripts/check-docs.sh`, the pull request that lands a release, and the take-up of a release in a derived project | 🟡 proposed |

### Superseded and rejected

The record of what was decided against or replaced: read one when a change touches what it
governed, to learn why the current decision stands. A row moves here in the change that
flips its status.

None yet.
