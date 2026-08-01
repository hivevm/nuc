# Architecture Decision Records

This directory contains all Architecture Decision Records (ADRs) for this project.
Accepted ADRs are **binding** for humans and coding agents alike (see [`AGENTS.md`](../../AGENTS.md)
in the repository root). ADRs derive from the specification in [`docs/SPECIFICATION.md`](../SPECIFICATION.md).

## Process

1. Copy [`template.md`](template.md) to `NNNN-short-title.md` (next free number).
2. Fill in context, decision, alternatives, and consequences. Set status `proposed`.
3. A human reviewer accepts or rejects the ADR. **Only humans change the status.**
4. Add the ADR to the index below, with its status shown via the colored bullet from the legend.
5. A decision is changed by a *new* ADR that supersedes the old one — never by editing an
   accepted ADR.
6. **Once this template is in use, ADRs are immutable and their numbers are permanent.** Never
   renumber, delete, or merge ADRs — other ADRs, commits (`Implements ADR-NNNN`), and code may
   reference a number. Superseded ADRs stay as historical record (status `superseded by ADR-NNNN`);
   filter active ones via the Status column. To curb sprawl, supersede — do not consolidate.
   The numbers therefore run `0001..N` without gaps, which
   [`scripts/check-docs.sh`](../../scripts/check-docs.sh) verifies.
   <!-- module:init begin -->
   Before that point the template may still consolidate or renumber its own seed ADRs, since
   nothing external references those numbers yet — see rule 8.
   <!-- module:init end -->
7. **Never reference an ADR number that does not exist yet.** Every `ADR-NNNN` reference must point
   to a file that is already present in this directory. Anticipated follow-up decisions are
   described by topic (e.g., "a follow-up ADR on session storage") in the Consequences section —
   the concrete number is cited only once that ADR file exists.
<!-- module:init begin -->
8. **Seed ADRs are selected at bootstrap.** Projects created from this template choose their
   policy modules at first interaction (see [0003](0003-template-bootstrap-and-module-selection.md)):
   the chosen seed ADRs are switched to accepted — the human's selection *is* the acceptance,
   executed by the bootstrap script — and deselected seed ADRs are deleted before anything
   references them, together with the ADR describing the bootstrap itself. The bootstrap then
   renumbers the survivors to a gapless `0001..N`, rewriting every reference in the same pass, so
   the initialized project starts with a numbering that has no holes and no history it never had.
   That renumbering is the single exception to rule 6, and it is possible exactly once: from the
   first commit that cites an ADR number onwards, the numbers are permanent.
<!-- module:init end -->

## Index

**Status legend:** 🟢 accepted · 🟡 proposed · 🔴 rejected · ⚪ superseded

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-agent-governance-model.md) | Specification + ADRs governed through a single `AGENTS.md` | 🟢 accepted |
| [0002](0002-dev-container-runtime.md) | Debian Dev Container without host Docker access | 🟢 accepted |
| [0003](0003-template-bootstrap-and-module-selection.md) | Template bootstrap with selectable policy modules and repository identity | 🟡 proposed |
| [0004](0004-git-conventions.md) | Git conventions: branches, Conventional Commits, squash merge | 🟡 proposed |
| [0005](0005-secrets-and-supply-chain.md) | Secrets handling and supply-chain pinning | 🟡 proposed |
| [0006](0006-versioning-and-releases.md) | Versioning and release process | 🟡 proposed |
| [0007](0007-external-conformance-tracking.md) | Conformance to an external source is tracked in `docs/CONFORMANCE.md` | 🟡 proposed |

