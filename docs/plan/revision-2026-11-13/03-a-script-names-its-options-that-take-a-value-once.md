# Ticket: A script names its options that take a value once

## What to build

A script under `scripts/` that sources `scripts/lib/root.sh` states its option grammar in three
places:

- the usage string it hands to `enter_root` and `rest_args`;
- `VALUE_OPTIONS`, the options whose value `enter_root` must not read as `--root`;
- its own `case` loop, which shifts such an option and its value.

`VALUE_OPTIONS` is written by hand, today in `sensor-binding-adrs.sh` (`--path`),
`sensor-review-binding.sh` (`--hand-off`), and `sensor-action-refs.sh` (`--require`). A new script
with an option that takes a value and no `VALUE_OPTIONS` falls back to the reading before
0074c2f. The `--root` after the option is taken as the root, and the option is left without its
value. The script then exits 2 or refuses the call itself. No check finds the missing line. The
silent pass on the wrong tree was another thing: 7bfc378, an earlier form of the fix that its
review caught, passed the argument after the option on as its value.

The concept "which options take a value" is spread over a library global and the script's own
parser. The backlog entry `value-options-unchecked.md` recorded it. The human's triage of
2026-11-13, to implement everything open in the tickets and the backlog, makes it this ticket.

The ticket makes one place decide it. The implementer proposes the simplest of these, or another:

- a check that holds each option a script's `case` loop shifts with its value to the script's
  `VALUE_OPTIONS`;
- `enter_root` reading the options that take a value from the usage string it already gets, as
  `[--path <path>]`, so that `VALUE_OPTIONS` goes;
- `enter_root` parsing `--root` only before the script's own options.

## Acceptance criteria

- [ ] Given a script with an option that takes a value, when the option is not named in the one
      place that decides it, then `scripts/check-all.sh` fails and names the script and the option.
- [ ] Given each of the three scripts above, when it runs as `<script> <option> --root <dir>`,
      then it exits 2 with "'<option>' needs a value, not '--root'", as the case of
      `scripts/test-check-all.sh` holds today.
- [ ] Given the header of `scripts/lib/root.sh`, when it is read, then it states the one place
      and no other.

## Read first

- Touches: `scripts/lib/root.sh`, `scripts/sensor-binding-adrs.sh`,
  `scripts/sensor-review-binding.sh`, `scripts/sensor-action-refs.sh`, `scripts/check-shell.sh`,
  `scripts/fixtures/check-shell.txt`, `scripts/test-check-all.sh`
- The human's decision of 2026-11-13 to implement everything open in the tickets and the backlog,
  which takes up the backlog entry `value-options-unchecked.md` as this ticket.
- The merge message of bc1e3a2, *Doubts* and *Review*.
- `scripts/lib/root.sh`, `enter_root` and `rest_args`, which hold the refusals of an argument.

## Blocked by

- docs/plan/revision-2026-11-13/02-the-root-of-a-script-is-held-by-a-check-not-a-self-test.md

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the choice
among the three ways changes the interface every script of a derived project copies. Past that, a
test decides each criterion, and a wrong result costs one revert. Stop and hand off when the chosen
way needs a script to give up an option it reads today.
