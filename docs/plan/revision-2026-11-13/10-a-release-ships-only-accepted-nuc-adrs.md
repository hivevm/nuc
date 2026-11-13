# Ticket: A release ships only accepted `NUC-` ADRs

## What to build

The review of the integration branch for v0.10.0 (PR #42, first round at 85ae347) found a
`proposed` `NUC-` ADR, `NUC-template-learns-from-projects`, on its way into the release. A derived
project could neither accept nor reject it, since it must not edit a `NUC-` file
([NUC-base-is-fixed §1](../../adr/NUC-base-is-fixed.md)). The human held it back for that release.
No clause says so, and no check would have caught it.

The human decided on 2026-11-13 (decision D2 of the revision of 2026-11-13): a release ships only
accepted `NUC-` ADRs. [NUC-releases-are-semver-tags](../../adr/NUC-releases-are-semver-tags.md)
gains a clause for it, as the template's correction in place of its own `NUC-` ADR
([NUC-decisions-are-proposed-then-accepted §6](../../adr/NUC-decisions-are-proposed-then-accepted.md)).
The rule `docs/template-release` of `scripts/check-docs.sh` refuses a 🟡 `NUC-` ADR when a release
is cut.

**A decidable form.** `check_template_release` reads only the `Template release` line of
`README.md` in the tree. The tree alone cannot tell a release from any other change. A form that
fails on every 🟡 `NUC-` ADR whenever the line names a version would refuse every branch that
proposes a `NUC-` ADR, since the template's line always names one. **Decided by the human on
2026-11-13:** the check fires only when a change moves the version on the release line against
the merge base with `origin/main`. The form reads the change:

- the rule finds the merge base with `origin/main`, else `main`, as `main_merge_base` of
  `scripts/lib/git.sh` does;
- where the version on the release line differs from the one at that base, a release is cut, or
  a derived project takes one up;
- then each `NUC-` ADR whose `Status` is 🟡 fails with the key `docs/template-release:proposed` and
  the ADR's identifier;
- without a merge base, the rule reads only the line, as it does today.

A take-up passes, since a release now carries no 🟡 `NUC-` ADR. In CI the job that runs
`scripts/check-docs.sh` checks out the whole history (`fetch-depth: 0` in
`.github/workflows/checks.yml`), so the merge base is there.

The work comes in two steps:

1. **A commit of ADRs only**
   ([NUC-decisions-are-proposed-then-accepted §4](../../adr/NUC-decisions-are-proposed-then-accepted.md)).
   It holds the new clause of `docs/adr/NUC-releases-are-semver-tags.md`, its *Enforcement*, which
   names the rule `docs/template-release`, and the line of `docs/adr/NUC.blobs`. The human reviews
   this commit before the next.
2. **The implementation.** `check_template_release` and the header item of `docs/template-release`
   take the form above, with cases in the table.

## Acceptance criteria

- [ ] Given the commit of ADRs only, when `git show --stat` lists it, then it changes nothing
      outside `docs/adr/`, and `scripts/check-docs.sh` passes on it.
- [ ] Given a fixture repository whose change moves the release line from `v0.1.0` to `v0.2.0`
      while a `NUC-` ADR is 🟡, when `scripts/check-docs.sh` runs, then it fails with
      `docs/template-release:proposed` and the ADR's identifier.
- [ ] Given the same 🟡 ADR in a change that leaves the release line as it was, when the check
      runs, then it passes.
- [ ] Given a change that moves the line while every `NUC-` ADR is 🟢, when the check runs, then
      it passes.
- [ ] Given a repository without `origin/main` and `main`, when the check runs, then it reads the
      line alone and passes on a well-formed one.
- [ ] Given `scripts/fixtures/check-docs-record.txt`, when `scripts/test-check-docs.sh` runs, then
      each case above is a row of the table.

## Read first

- Touches: `docs/adr/NUC-releases-are-semver-tags.md`, `docs/adr/NUC.blobs`,
  `scripts/check-docs.sh`, `scripts/fixtures/check-docs-record.txt`, `scripts/test-check-docs.sh`
- `docs/adr/NUC-releases-are-semver-tags.md`, in full, since the change revises it.
- `scripts/check-docs.sh`, `check_template_release` and its header item; `check_adr_identifiers`
  for a rule that already reads git.
- `scripts/lib/git.sh`, `main_merge_base`.
- The description of PR #42, *Doubts* and *Review*.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the human
reviews the commit of ADRs only before its implementation. Past that, the self-test decides each
criterion, and a wrong result costs one revert. Stop and hand off when the rule cannot read the
base the way the hooks and CI both have it.
