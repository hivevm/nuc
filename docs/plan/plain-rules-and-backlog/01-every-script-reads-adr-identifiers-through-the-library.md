# Ticket: Every script reads ADR identifiers and headers through the shared library

## What to build

The scripts that still match ADR file names, ADR identifiers, or ADR header lines on their own
use the shared ADR library instead. Nothing a script decides changes. After this ticket, a change
to the form of an ADR identifier touches the library and the scripts that only print it.

The known places, at the time of cutting:

- the documentation check: the draft key, the index row pattern, the heading pattern, the draft
  and numbered file globs, and the header lines it names in its messages;
- the binding sensor: the pattern of ADR file names it filters `git ls-tree` with;
- the review-binding sensor: the two path globs of ADR files.

The numbering script keeps its own globs. The next release removes it.

## Acceptance criteria

- [ ] Given the existing self-tests, when they run after the refactor, then each passes without a
      change to the self-test.
- [ ] Given the library, when a script needs the pattern of an ADR file name, an identifier, or a
      header field, then it takes it from the library, and a search of the scripts outside the
      library and the numbering script finds no pattern of its own.
- [ ] Given the scripts before and after, when their lines are counted, then the total does not
      rise.
- [ ] Given `scripts/check-all.sh`, when it runs, then it is green.

## Read first

- Touches: `scripts/lib/adr.sh`, `scripts/check-docs.sh`, `scripts/sensor-binding-adrs.sh`,
  `scripts/sensor-review-binding.sh`
- The header comment of `scripts/lib/adr.sh`: what the library already holds.
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style): a wide mechanical refactor is expand,
  migrate in batches, contract, every step green.
- The seam: the existing self-tests `scripts/test-check-docs.sh`,
  `scripts/test-sensor-binding-adrs.sh`, `scripts/test-sensor-review-binding.sh`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
