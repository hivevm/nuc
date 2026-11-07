# Ticket: Release v0.8.1

## What to build

The patch release `v0.8.1` of the template, as ADR-0005 decides: tickets 02, 03, 04, 07, and 10 of
this directory, each a fix, a refactor, or a wording change. The release notes say what a derived
project takes up and that it need not act on any of it. Ticket 05 adds a check and waits for the
next minor.

## Acceptance criteria

- [ ] Given tickets 02, 03, 04, 07, and 10 merged into the `feat/` branch, when the release
      change is made, then the README's `Template release` line names v0.8.1.
- [ ] Given the release notes, when a maintainer of a derived project reads them, then each change
      says whether it must act, may act, or need not.
- [ ] Given the release, when `scripts/check-all.sh` runs on the tree, then it is green.

## Read first

- Touches: `README.md` (the `Template release` line), the release notes
- `docs/adr/0005-template-releases.md`, *Decision*: what a patch is.
- The release of v0.8.0 as the golden path.

## Blocked by

- docs/plan/revision-2026-11-07/02-the-sensors-that-read-a-change-resolve-it-one-way.md
- docs/plan/revision-2026-11-07/03-the-rules-reader-reads-inline-markdown-as-a-reader-does.md
- docs/plan/revision-2026-11-07/04-an-avoided-term-is-read-across-a-line-break.md
- docs/plan/revision-2026-11-07/07-the-review-skill-cites-the-rework-rule-once.md
- docs/plan/revision-2026-11-07/10-the-setup-clears-the-templates-own-work.md

## Mode

with the human: a release is the human's to cut and push.
