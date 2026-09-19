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

- **File.** Copy [`template.md`](template.md) to `NNNN-short-title.md` with the next free number.
  The `# ADR-NNNN` heading matches the filename, and the numbers run `0001..N` without gaps.
- **Index.** The table below changes in the same pull request as the ADR it describes, for
  additions, supersessions, and status flips alike. The status is shown via the legend's bullet
  and the ADR's `Applies to` header is mirrored verbatim in its own column. The index routes a
  reader from a change to the decisions that bind it, so a row says what its ADR governs without
  the file being opened.
- **Numbers are permanent.** Never renumber, delete, or merge ADRs: other ADRs, commits
  (`Implements ADR-NNNN`), and code may reference a number. A superseded ADR keeps its file and
  its body. Its `Status` line flips to `⚪ superseded by ADR-NNNN` in the pull request that lands
  the superseding ADR, whose `Supersedes` field names it back.
- **Sprawl is curbed by supersession, never by editing.** One ADR may supersede several whose
  decisions have grown into one. Its `Supersedes` field names each, and each flips its status in
  the same pull request, so the set an agent reads for a change shrinks while every number and
  every body stays.
- **Cite only what exists.** Every `ADR-NNNN` reference names a file already in this directory.
  An anticipated follow-up is described by topic ("a follow-up ADR on session storage"), never by
  a number. In Markdown, cite an ADR as a link to its own file.

## Index

An ADR whose `Deciders` line names the **NUC maintainer** is inherited from the template. It
binds a derived project once its own maintainer adds their name to `Deciders` and flips the
`Status` line to `🟢 accepted` ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). Change an
inherited decision by superseding it, never by editing. Once the template setup is done, check
12 of [`scripts/check-docs.sh`](../../scripts/check-docs.sh) fails on an inherited ADR still
proposed.

**Status legend:** 🟢 accepted · 🟡 proposed · 🔴 rejected · ⚪ superseded

| ADR | Title | Applies to | Status |
|-----|-------|------------|--------|
| [0001](0001-agent-governance-model.md) | The document set: one specification, one ADR record, one `AGENTS.md`, one overview, one glossary, one conventions file | every document that carries rules for humans or agents, the architecture overview, the glossary, and the conventions | 🟡 proposed |
| [0002](0002-dev-container-runtime.md) | The Dev Container keeps the host daemon out of reach and its Features locked | `.devcontainer/`, `.vscode/settings.json`, and everything the container pulls in | 🟡 proposed |
| [0003](0003-decisions-verified-by-tests.md) | Every accepted decision and every success criterion is verified by a test that cites it | every accepted ADR, the Goals and Quality Goals of `docs/SPECIFICATION.md`, and the tests that verify them | 🟡 proposed |
| [0004](0004-feature-layer.md) | Work larger than one session is planned on the issue tracker: a feature spec cut into tracer-bullet tickets | every change larger than one agent session, the issue templates, and the pull request template | 🟡 proposed |
| [0005](0005-procedures-as-skills.md) | The procedures of the rule file are Agent Skills under `.agents/skills/`, each carrying a how and no rule of its own | `.agents/skills/`, the pointers under `.claude/skills/`, and every document that describes how a procedure of `AGENTS.md` is carried out | 🟡 proposed |
| [0006](0006-architecture-style.md) | Application code is structured as ports and adapters, with every dependency pointing at the core | every module of the system's code, the golden path, and the structural test that decides the dependency direction | 🟡 proposed |
