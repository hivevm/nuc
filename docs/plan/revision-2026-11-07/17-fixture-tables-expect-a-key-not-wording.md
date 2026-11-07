# Ticket: A fixture table expects a stable key, not the wording of a message

## What to build

[NUC-checks-are-bash §8](../../adr/NUC-checks-are-bash.md) holds a binary that replaces the
scripts to the fixture tables under `scripts/fixtures/`. The tables expect a substring of the bash
message ("text the output contains"), and their base tree is built in bash only. nuc-tools'
parity tests therefore follow the bash wording, and every rewording of a message breaks the port
(hand-offs of tickets 01 and 13 of `fixed-base-and-recut`).

Each failure a table expects carries a short stable key, such as the check's number and a reason
word, that the message prints and the table matches. The base tree of each table is described in
the table's header precisely enough to build it without the bash.

## Acceptance criteria

- [ ] Given a message reworded without changing its key, when the self-tests run, then they pass.
- [ ] Given each table, when it is read, then each failing case names a key and no wording.
- [ ] Given the line count of the spec's measure, when it is taken after the change, then the
      hand-off reports it.

## Read first

- Touches: `scripts/fixtures/`, `scripts/lib/selftest.sh`, the self-tests that read a table, and
  the checks whose messages gain a key
- The convention *A self-test asserts what it builds* in `docs/CONVENTIONS.md`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the key's form is the contract nuc-tools implements against.
