# Ticket: A rule key that an ADR names is a key of the checks

## What to build

The binding ADRs sensor binds an ADR that names 'the rule `<key>` of `<file>`' to the function of
the check that carries that key, `check_<name>() {  # <key>`. A key that the header of
`scripts/check-docs.sh` does not list, misspelt or renamed, binds nothing inside the checks. The
ADR then binds only the lines outside them, and no check fails. A derived project whose own ADR
copies a key from old notes meets the same.

It happened twice in the work since the revision of 2026-11-12. Both times a commit of ADRs only
named a key that the script did not carry yet, and the sensor misrouted a change at that commit:

- ticket 05, between 6ed1681 and 156cb11 (merge 21252e1);
- the rename of `docs/adr-numbering` to `docs/adr-identifiers`, between 1940e15 and f20a1bf
  (merge 9621b20).

The backlog entry `applies-to-key-unchecked.md` recorded it. The human decided on 2026-11-13 that
it becomes this ticket, to be implemented. The commit of the revision that filed this ticket
deleted the entry.

A check holds every rule key named in an *Applies to* of an ADR in force against the keys of the
file it names, as the header of `scripts/check-docs.sh` lists them. The backlog entry proposes the
rule `docs/adr-refs` as its home. Today the key would sit with the file `scripts/check-docs.sh`
alone, the one file whose checks are named by keys.

**The order of a rename.** The check makes the transient above red. A commit of ADRs only that
renames a key then fails, and so does a commit of the script alone before it. The session
proposes to the human how a key moves under the check, such as both names in the header for one
commit, or the ADR and the script in one commit. The second is open to the template's correction
of its own `NUC-` ADRs
([NUC-decisions-are-proposed-then-accepted §4](../../adr/NUC-decisions-are-proposed-then-accepted.md)),
and not to a derived project's ADR.

## Acceptance criteria

- [ ] Given an accepted ADR whose *Applies to* names 'the rule `docs/no-such-key` of
      `scripts/check-docs.sh`', when `scripts/check-docs.sh` runs, then it fails with a key that
      names the rule and the data of the ADR and the missing key.
- [ ] Given each `NUC-` ADR as it stands, when the check runs, then it passes.
- [ ] Given a rejected or superseded ADR with such a key, when the check runs, then it passes.
- [ ] Given `scripts/fixtures/check-docs-record.txt`, when `scripts/test-check-docs.sh` runs, then
      the cases above are rows of the table.
- [ ] Given the header of `scripts/check-docs.sh`, when it is read, then it states how a key moves
      under the check, as the human chose.

## Read first

- Touches: `scripts/check-docs.sh`, `scripts/fixtures/check-docs-record.txt`,
  `scripts/test-check-docs.sh`, `scripts/sensor-binding-adrs.sh`
- `scripts/sensor-binding-adrs.sh`, the header and the reading of *Applies to* around `checked()`.
- The header of `scripts/check-docs.sh`, the items `docs/adr-refs` and the list of keys.
- The merge messages of 21252e1 and 9621b20, *Doubts*.
- The human's decision of 2026-11-13 to implement everything open in the tickets and the backlog.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the human
chooses how a key moves under the check. Past that, the self-test decides each criterion, and a
wrong result costs one revert. Stop and hand off when the check needs to read a file other than
`scripts/check-docs.sh` for its keys.
