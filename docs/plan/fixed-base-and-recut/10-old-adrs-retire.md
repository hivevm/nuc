# Ticket: ADR-0001 to ADR-0006 retire, and the old identifier form leaves the readers

## What to build

The old ADRs leave the tree once the clause tables of tickets 03 to 09 cover every clause. The remap
script learns the new form and moves every reference in the tree, `AGENTS.md` and the skills
included, to the `NUC-` ADR that carries the cited clause. A reference that the map cannot decide,
because its old ADR now lies in two new ones, is listed and rewritten by hand. The library, the
checks, and the sensors drop the form `ADR-NNNN`.

The remap script runs idempotently, has a `--check` mode, and takes its map as a reviewed data file.
The map stands in the hand-off and the commit body, not in a document.

Some references need a rewrite, not a remap. The setup path for a project without a Dev Container
superseded ADR-0004. Under clause 1 of `NUC-container-hides-host-daemon`, such a project deletes
`.devcontainer/` and supersedes nothing, and no project ADR may supersede a `NUC-` ADR. The setup
file, the `setup-project` skill, and case 3 of `scripts/test-template-setup.sh` change with it.

The sweep also moves citations of [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) for a rule
that a `NUC-` ADR now carries, outside `AGENTS.md` itself: the `work-tickets` skill and its claim
script, the pull request template, `SECURITY.md`, the workflows, the Dev Container definition, the
catalogue entries, and the step 2 of the *Workflow* in `CONTRIBUTING.md`.

## Acceptance criteria

- [ ] Given the clause tables of tickets 03 to 09, when they are joined, then each clause of
      ADR-0001 to ADR-0006 has exactly one home, and the hand-off carries the joined table.
- [ ] Given the tree after this ticket, when it is searched for `ADR-` followed by four digits, then
      the only matches are in commit history, not in files.
- [ ] Given the remap script with `--check` on the tree after the map, when it runs, then it reports
      nothing left to move; run twice, it changes nothing the second time.
- [ ] Given `scripts/test-normalize-remap.sh`, when it cycles the real tree, then it passes.
- [ ] Given the tree, when `scripts/check-all.sh` runs, then it is green.

## Read first

- Touches: `docs/adr/`, `scripts/lib/adr.sh`, `scripts/`, `.agents/skills/normalize/remap.sh`,
  `scripts/test-normalize-remap.sh`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`
- The clause tables in the hand-offs of tickets 03 to 09.
- The *References* step of the normalize skill.

## Blocked by

- docs/plan/fixed-base-and-recut/02-the-base-is-held-by-blob-list.md
- docs/plan/fixed-base-and-recut/04-documents-are-fixed.md
- docs/plan/fixed-base-and-recut/05-decisions-cite-tests-checks-are-bash.md
- docs/plan/fixed-base-and-recut/06-procedures-are-skills.md
- docs/plan/fixed-base-and-recut/07-container-hides-host-daemon.md
- docs/plan/fixed-base-and-recut/08-main-only-via-pr.md
- docs/plan/fixed-base-and-recut/09-large-work-is-planned-design-is-revised.md

## Mode

with the human: the human checks the joined clause table before the old ADRs are deleted.
