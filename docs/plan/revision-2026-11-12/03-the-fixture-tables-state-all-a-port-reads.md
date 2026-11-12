# Ticket: The fixture tables state in their headers all that a port reads from them

## What to build

The four tables under `scripts/fixtures/` are the cases a binary in place of the scripts must
pass ([NUC-checks-are-bash §8](../../adr/NUC-checks-are-bash.md)). Their headers describe the
fields, and `table_holds` of `scripts/lib/selftest.sh` reads them. The review of PR #36 named
three places where the reader decides what no header says, under its *Doubts*:

- A line that starts with `#` is a comment, which the reader skips. Each header is such lines,
  and so is a comment between rows of `check-devcontainer.txt`. No header says so.
- A subject may match inside the key the line ends in, such as `docs` in
  `[docs/links:broken]`. No row relies on it today. The reader looks for subjects in the part of
  the line before its key instead, so a port cannot pass a row on the key alone.
- A `!` field with subjects applies their order as well. No `!` field names a subject today, and
  no header says how one reads. The decided reading is the one the reader has: a field
  `!<key> @ <a> @ <b>` holds where no line that ends in the key holds `<a>` and then `<b>`. A line
  with the key and the subjects in the other order does not break it. Every header says so.

A port such as the `nuc` binary of `hivevm/nuc-tools` reads only the headers. What the bash
reader decides beyond them, a port decides by guess.

PR #36 readied the tables for the parity run of `hivevm/nuc-tools`, which holds `nuc` to them.
The proposal `NUC-checks-run-by-nuc`, on the branch `docs/nuc-checks-run-by-nuc`, describes that
harness as a comparison with the bash on pinned trees and does not name the tables. The ticket is
worth its cost while a port reads the tables. Once the bash checks leave, the tables leave with
them or move to `hivevm/nuc-tools`, which the proposal does not say. The human decides whether the
ticket runs before the parity run.

## Acceptance criteria

- [ ] Given each table under `scripts/fixtures/`, when its header is read, then it says that a
      line starting with `#` is a comment.
- [ ] Given a row whose only subject occurs in the key and nowhere else in the line, when the
      self-test reads it, then the row fails.
- [ ] Given an output with one line that ends in `[docs/x:y]` and names `b.md`, then `a.md`, when
      the reader's own checks read the field `!docs/x:y @ a.md @ b.md`, then the field holds.
- [ ] Given an output with one line that ends in `[docs/x:y]` and names `a.md`, then `b.md`, when
      the reader's own checks read the same field, then it does not hold.
- [ ] Given each table's header, when it is read, then it states this reading of a `!` field with
      subjects.

## Read first

- Touches: `scripts/lib/selftest.sh`, `scripts/fixtures/check-devcontainer.txt`,
  `scripts/fixtures/check-docs-record.txt`, `scripts/fixtures/check-traceability.txt`,
  `scripts/fixtures/plain-rules.txt`, `scripts/test-check-devcontainer.sh`
- `docs/CONVENTIONS.md`: "A check's cases are a table".
- The reader's own checks in `scripts/test-check-devcontainer.sh`, the pattern to copy.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the human
decides first whether a port reads the tables. A test decides each criterion, and a wrong result
costs one revert. Stop and hand off when a row of a table fails under the narrowed match.
