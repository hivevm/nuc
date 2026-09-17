# Architecture Decision Records

This directory contains all Architecture Decision Records (ADRs) for this project. Accepted ADRs are
**binding** for humans and coding agents alike (see [`AGENTS.md`](../../AGENTS.md) in the repository
root). ADRs derive from the specification in [`docs/SPECIFICATION.md`](../SPECIFICATION.md).

## Process

The rules below are cited by number elsewhere — the header and comments of
[`scripts/check-docs.sh`](../../scripts/check-docs.sh) name the rule each check enforces.
Renumbering this list means rewriting those citations in the same change.

1. Copy [`template.md`](template.md) to `NNNN-short-title.md` (next free number), **scoped to one
   specific decision** as required by [`AGENTS.md` §3](../../AGENTS.md#3-adr-rules) — the rule that
   governs when an ADR is written and how narrowly it is cut.
2. Fill in context, decision, alternatives, consequences, and how the decision is enforced. Develop
   the proposal interactively and critically in dialogue with the human
   ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)), instead of delivering a finished document.
3. **Submit the `proposed` ADR in its own pull request**
   ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). The index below changes in the same PR as the
   ADR it describes — for additions, supersessions, and status flips alike — with the status shown
   via the colored bullet from the legend and the ADR's `Applies to` header mirrored verbatim in its
   own column. The index is what routes a reader from a change to the decisions that bind it
   ([`AGENTS.md` §2](../../AGENTS.md#2-start-here)), so a row has to say what its ADR governs
   without the file being opened; [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies
   that both columns agree with the file.
4. A human reviewer accepts or rejects the ADR — **only humans change the status**. Implementation
   proceeds while the ADR is still `proposed` and its findings flow back as revisions, each in its
   own ADR-only PR (rule 3); only the acceptance itself may land together with implementation
   ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)).
5. **A decision is changed by a *new* ADR that supersedes the old one**, never by editing an
   accepted one ([`AGENTS.md` §3](../../AGENTS.md#3-adr-rules)). ADR numbers are permanent: never
   renumber, delete, or merge ADRs — other ADRs, commits (`Implements ADR-NNNN`), and code may
   reference a number. Superseded ADRs stay as historical record (status `superseded by ADR-NNNN`);
   filter active ones via the Status column. **That status flip is the one edit an accepted ADR ever
   receives** — made by a human (rule 4), in the pull request that lands the superseding ADR,
   together with both index rows; the body of the superseded ADR stays untouched. To curb sprawl,
   supersede — do not consolidate. The numbers therefore run `0001..N` without gaps, which
   [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies.
6. **Never reference an ADR number that does not exist yet.** Every `ADR-NNNN` reference must point
   to a file that is already present in this directory. Anticipated follow-up decisions are
   described by topic (e.g., "a follow-up ADR on session storage") in the Consequences section —
   the concrete number is cited only once that ADR file exists.
   [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies this in every text file of the
   repository, source comments included — rule 5 makes code a legitimate place to cite a number,
   and a stale reference there is the one no reviewer reads next to the index. In Markdown, cite
   an ADR as a link to its own file: the check compares the number in the link text with the file
   the link points at, so a reference whose number and target name different decisions cannot pass
   on the strength of each half existing.

## Index

**Status legend:** 🟢 accepted · 🟡 proposed · 🔴 rejected · ⚪ superseded

| ADR | Title | Applies to | Status |
|-----|-------|------------|--------|
| [0001](0001-agent-governance-model.md) | The document set: one specification, one ADR record, one `AGENTS.md`, one overview | every document that carries rules for humans or agents, and the architecture overview | 🟡 proposed |
| [0002](0002-specification-change-process.md) | The specification changes only by human decision, naming the ADRs it moves | `docs/SPECIFICATION.md` and every accepted ADR derived from it | 🟡 proposed |
| [0003](0003-dev-container-runtime.md) | The Dev Container: mandatory, base free, no host daemon, Features pinned | `.devcontainer/`, `.vscode/settings.json`, and everything the container pulls in | 🟡 proposed |
| [0004](0004-secrets-handling.md) | Secrets never enter the repository; a leak is remediated by rotation | anything that could hold a secret — tracked files, commit messages, ADRs, logs, CI output | 🟡 proposed |
| [0005](0005-decisions-verified-by-tests.md) | Every accepted decision and every success criterion is verified by a test that cites it | every accepted ADR, the Goals and Quality Goals of `docs/SPECIFICATION.md`, and the tests that verify them | 🟡 proposed |
