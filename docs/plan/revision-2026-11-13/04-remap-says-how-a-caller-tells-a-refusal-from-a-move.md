# Ticket: remap.sh says how a caller tells a refused call from a reference that would move

## What to build

`.agents/skills/normalize/remap.sh` exits 0 when every reference moved, 2 when references are left
for the hand, and 1 on anything else. Under `--check` its exit codes run together in two ways:

- **A refusal reads as work to do.** It exits 1 when a reference would move, and also when the
  call is refused: an unknown option, a second map, a missing or invalid map, no git repository.
- **A move hides what would be left.** The end of `remap.sh` tests a move before a reference left,
  so a run that would move one reference and leave another exits 1, never 2. Only stderr lists
  what would be left.

No script or workflow reads the exit code of `remap.sh`. Its one caller is the `normalize` skill,
whose session reads the output: the moves on stdout, a refusal and the references left on stderr.
A change of the codes would break a caller that a derived project wrote itself.

**Decided by the human on 2026-11-13:** the exit codes stay. The header of `remap.sh` and the
`normalize` skill say how a caller tells the cases apart, by what the script prints:

- a reference that would move prints a line `file:line: OLD -> NEW` on stdout;
- a refused call prints only lines starting `remap: ` on stderr, one per error of an invalid map,
  and nothing on stdout;
- references that would be left follow `remap: references left to rewrite by hand:` on stderr,
  also when exit 1 reports a move.

The cases of `scripts/test-normalize-remap.sh` pin what the header says, so that the text stays
true.

## Acceptance criteria

- [ ] Given each refusal (an unknown option, a second map, no map file, an invalid map, no git
      repository), when `remap.sh --check` runs, then it exits 1, stdout is empty, every line of
      stderr starts `remap: `, and the tree is unchanged.
- [ ] Given a tree where one reference would move and one would be left, when
      `remap.sh --check <map>` runs, then it exits 1, stdout names the move, and stderr lists the
      reference left after the line `remap: references left to rewrite by hand:`.
- [ ] Given the header of `remap.sh` and steps 3 and 4 of the `normalize` skill, when they are
      read, then they name the two overlaps of exit 1 and the output that tells each case apart.
- [ ] Given the diff, when it is read, then no exit code of `remap.sh` changes.

## Read first

- Touches: `.agents/skills/normalize/remap.sh`, `.agents/skills/normalize/SKILL.md`,
  `scripts/test-normalize-remap.sh`
- The header of `remap.sh`, and the cases of `--check` in `scripts/test-normalize-remap.sh`.
- The commit message of 548427c.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. Past that, the
self-test decides each criterion but the third, which the review decides, and a wrong result costs
one revert. Stop and hand off when the output cannot tell a case apart without a change of the
script's behaviour.
