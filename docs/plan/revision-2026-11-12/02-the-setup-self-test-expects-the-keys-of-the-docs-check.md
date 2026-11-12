# Ticket: The setup's self-test expects the keys of the documentation check's findings, not their wording

## What to build

`scripts/test-template-setup.sh` matches findings of `scripts/check-docs.sh` by their wording, in
these places:

- its table `PLACEHOLDERS`, one row per placeholder of the scaffold, each with the message the
  check prints for it. Most rows are findings of check 13, `[docs/template-identity:<reason>]`.
  Three rows are findings of other checks: two broken links to `TEMPLATE-SETUP.md`, of check 3
  (`[docs/links:broken]`), and the Project Layout row of `TEMPLATE-SETUP.md`, of check 10
  (`[docs/project-layout:missing]`);
- its needles `link_re` and `layout` in case 1, which tell those findings of checks 3 and 10 apart
  from the rest;
- its test that every file with a token of the scaffold is named, which looks for `"$file: "`.

Since PR #36, every finding of `check-docs.sh` ends in a key, and its file is a subject.

The convention "A check's cases are a table" of `docs/CONVENTIONS.md` says a case expects a key
and the data of a finding, never its wording. These cases expect wording. A reworded message
breaks them. A port of the checks, such as the `nuc` binary of `hivevm/nuc-tools`, is not held to
them, though
[NUC-checks-are-bash §8](../../adr/NUC-checks-are-bash.md) holds a binary to the cases of the
fixture tables. PR #36 left this open under its *Doubts*.

The cases stay in the self-test: they run on the real scaffold, which no fixture table builds.
Each expects a key and its subjects instead of the message, read by `output_holds` or
`table_holds` of `scripts/lib/selftest.sh`. The self-test's `--open` lists the lines of
`check-docs.sh` that start with `  - `. The ticket names that dependency on the output's form in
the self-test's header, so a port knows it must keep it.

The proposal `NUC-checks-run-by-nuc`, on the branch `docs/nuc-checks-run-by-nuc`, does not say
whether this self-test stays: it tests the setup, but its `--open` and `--close` are run by hand,
which clause 1 of the proposal makes commands of `nuc`. Either way, the keys are what the bash
check and `nuc` share, and the setup's cases are the ones a port needs. The human decides whether
the ticket waits for the proposal.

## Acceptance criteria

- [ ] Given `scripts/test-template-setup.sh`, when it is searched, then no case matches the
      wording of a finding of `scripts/check-docs.sh`, of check 13 or of checks 3 and 10. Each
      matches a key and its subjects.
- [ ] Given a copy of `scripts/check-docs.sh` with every message of checks 3, 10, and 13 reworded
      and their keys kept, when the self-test runs against it, then every case passes.
- [ ] Given a copy with one reason word of check 13 changed, when the self-test runs against it,
      then the case of that placeholder fails. The same holds for `docs/links:broken` and for
      `docs/project-layout:missing`.
- [ ] Given the self-test's header, when it is read, then it says that `--open` reads the lines of
      the documentation check that start with `  - `.

## Read first

- Touches: `scripts/test-template-setup.sh`
- `scripts/check-docs.sh`: checks 3, 10, and 13 (`check_template_identity`), for the keys.
- `scripts/lib/selftest.sh`: `table_holds` and `output_holds`.
- `docs/CONVENTIONS.md`: "A check's cases are a table" and "A self-test asserts what it builds".

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. A test
decides each criterion, and a wrong result costs one revert. Stop and hand off when a finding
carries no subject that tells two placeholders of one file apart.
