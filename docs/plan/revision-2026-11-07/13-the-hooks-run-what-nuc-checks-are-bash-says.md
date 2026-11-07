# Ticket: The hooks run the checks where NUC-checks-are-bash §6 says they do

## What to build

[NUC-checks-are-bash §6](../../adr/NUC-checks-are-bash.md) says the git hooks run the checks
before a commit, a merge, and a push. `.githooks/pre-commit` runs them only on the commit that
concludes a conflicted merge, and `.githooks/pre-merge-commit` runs only `scripts/check-docs.sh`.
An ordinary commit runs nothing. Two commits of `fixed-base-and-recut` were red on their own,
both on check-docs: `40e6f3f` (a line over 100 columns, ticket 10) and `48ce2d9` (a broken link
and a bare section sign, ticket 11). Check-docs takes under a second.

Decide with the human which side moves:

- `.githooks/pre-commit` runs `scripts/check-docs.sh` on every commit off `main`, as
  pre-merge-commit does on a merge. Check-docs reads the working tree, so a partial commit is
  judged on more than it holds; the hook says so in its refusal. The ADR text stays.
- Or the ADR's clause 6 is corrected to what the hooks do, in a commit of ADRs only with
  `docs/adr/NUC.blobs`, before `v0.9.0` ships the base.

## Acceptance criteria

- [ ] Given a commit whose tree fails check-docs, when it is made on a branch, then the hook
      refuses it, or the corrected clause 6 no longer promises a check before such a commit.
- [ ] Given `scripts/test-git-hooks.sh`, when it runs, then a case pins the chosen behaviour.

## Read first

- Touches: `.githooks/pre-commit`, `scripts/test-git-hooks.sh`, `docs/adr/NUC-checks-are-bash.md`,
  `docs/adr/NUC.blobs`
- The section *Git hooks* of `CONTRIBUTING.md`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the choice moves either a hook every commit runs or a `NUC-` clause.
