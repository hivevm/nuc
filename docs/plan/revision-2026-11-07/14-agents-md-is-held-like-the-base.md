# Ticket: AGENTS.md is held against the release like the NUC- files

## What to build

The preamble of `AGENTS.md` says the file belongs to the template and a derived project must not
edit it. The plain-rules check spares it, because a take-up replaces it as the release has it
([NUC-documents-are-fixed §5](../../adr/NUC-documents-are-fixed.md), Enforcement). Nothing holds
it: `docs/adr/NUC.blobs` lists only the `NUC-` files
([NUC-adrs-record-decisions §12](../../adr/NUC-adrs-record-decisions.md)), and
[NUC-releases-are-semver-tags §6](../../adr/NUC-releases-are-semver-tags.md) counts the rule file
among "the other files the release notes name". A project that edits it loses the edit at the
next take-up without a check telling it, and its own rules there are never checked.

With the human, before `v0.9.0` makes every derived project migrate: either the blob list names
`AGENTS.md` too, check 12 holds it, and clauses 11 and 12 of NUC-adrs-record-decisions say so in a
commit of ADRs only; or the preamble's "must not edit" goes and the plain-rules check reads a
project's `AGENTS.md` like its ADRs.

## Acceptance criteria

- [ ] Given a derived project that edits `AGENTS.md`, when check-docs runs, then check 12 fails
      naming it, or the plain-rules check holds the edited lines.
- [ ] Given `scripts/fixtures/check-docs-record.txt`, when its self-test runs, then a case pins the
      chosen behaviour.

## Read first

- Touches: `docs/adr/NUC-adrs-record-decisions.md`, `docs/adr/NUC.blobs`, `scripts/lib/adr.sh`,
  `scripts/check-docs.sh`, `scripts/fixtures/check-docs-record.txt`, `AGENTS.md`
- The step *Take up a template release* of the `normalize` skill.

## Blocked by

- None (can start immediately)

## Mode

with the human: it changes what a derived project owns.
