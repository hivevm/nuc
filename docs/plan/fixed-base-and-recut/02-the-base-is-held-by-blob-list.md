# Ticket: The `NUC-` files are a fixed base, held by a blob list and extended only by name

## What to build

The clauses of `NUC-adrs-record-decisions` on the fixed base and the roles, as a revision of ADRs
only where ticket 01's text needs one.

- The release workflow writes `docs/adr/NUC.blobs`: each `NUC-` file with its git blob identifier.
  In the template repository a check holds the list against the files. In a derived project the same
  check compares the files with the list. It replaces check 12.
- A project ADR may carry `Extends:` or `Narrows:` with a `NUC-` clause. A check fails on
  `Supersedes: NUC-*`.
- A project ADR may carry `Role:`. Once `TEMPLATE-SETUP.md` is gone, a check requires exactly one
  accepted ADR per role that the base lists. While the setup file exists, the check is silent.
- The index lists the project's ADRs only, grouped by category, and the `NUC-` base in one line. The
  binding sensor reads *Applies to* from every ADR file and no longer from the index.
- A fork removes the list and names the release it forked in its README; the check then passes.

## Acceptance criteria

- [ ] Given a derived fixture whose `NUC-` file differs from its blob in the list, when check-docs
      runs, then it fails and names the file; given an unchanged base, then it passes.
- [ ] Given a fixture without a blob list whose README names a fork of a release, when the check
      runs, then it passes.
- [ ] Given a project ADR with `Supersedes: NUC-x`, when check-docs runs, then it fails; with
      `Narrows: NUC-x §2`, then it passes, and the clause must
      exist.
- [ ] Given a fixture after the setup with no accepted `Role: harness` ADR, or with two, when the
      check runs, then it fails and names the role.
- [ ] Given a change to a path that only a `NUC-` ADR names, when the binding sensor runs, then it
      prints that ADR, read from its file.
- [ ] Given the release workflow on a tag, when it runs, then it writes the list, and the template's
      own check passes on it.
- [ ] Given check-docs after this ticket, when its checks are counted, then the count is as before.

## Read first

- Touches: `scripts/check-docs.sh`, `scripts/test-check-docs.sh`, `scripts/lib/adr.sh`,
  `scripts/sensor-binding-adrs.sh`, `scripts/test-sensor-binding-adrs.sh`, `docs/adr/README.md`,
  `docs/adr/template.md`, `.github/workflows/`, `CONTRIBUTING.md`
- The spec's items *Fixed base*, *Blob list*, *Roles*, and *Index*.
- Check 12 and its self-test: the behaviour the blob check takes over.

## Blocked by

- docs/plan/fixed-base-and-recut/01-identifiers-name-their-category.md

## Mode

with the human: it implements a proposed ADR, and a revision of its text goes to the human first.
