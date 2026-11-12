# Ticket: The Project Layout of CONTRIBUTING.md names the commit gate and the bash floor

## What to build

The *Project Layout* block of `CONTRIBUTING.md` is the tour of the template's own tree. Since
the design revision of 2026-11-07 (2), two of its lines no longer say what the tree does:

- `.githooks/` reads "checks before a merge and a push". Since ece4fa2, `pre-commit` runs
  `scripts/check-docs.sh` on every commit on a branch.
  [NUC-checks-are-bash §6](../../adr/NUC-checks-are-bash.md) and
  [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) say "before a
  commit, a merge, and a push", and the *Git hooks* table of the same file was corrected in that
  change. The convention "A rule changes everywhere it is stated" of `docs/CONVENTIONS.md` asked
  for this line too.
- `scripts/lib/` lists "the ADR header, git, the ticket path, the self-tests". Since e7d1d93 every
  script a person runs sources `scripts/lib/bash.sh`, the bash floor of
  [NUC-checks-are-bash §1](../../adr/NUC-checks-are-bash.md). The library also holds the reader of
  plain rules (`rules.sh`) and the shared findings (`check.sh`), which the line does not name.

Check 10 of `scripts/check-docs.sh` holds that each listed path exists, not what its comment says.
The two comments are corrected; no other line changes.

## Acceptance criteria

- [ ] Given the *Project Layout* block, when the comment of `.githooks/` is read, then it names
      the checks before a commit, a merge, and a push, as the *Git hooks* table does.
- [ ] Given the *Project Layout* block, when the comment of `scripts/lib/` is read, then it names
      each file under `scripts/lib/` by what it holds: the bash floor (`bash.sh`), the ADR header
      (`adr.sh`), the findings of a check (`check.sh`), git (`git.sh`), the plain rules
      (`rules.sh`), the self-tests (`selftest.sh`), and the ticket path (`ticket.sh`).
- [ ] Given the diff, when it is read, then it changes no line of `CONTRIBUTING.md` but these two
      comments and their continuation lines.

## Read first

- Touches: `CONTRIBUTING.md`
- `CONTRIBUTING.md`, sections *Project Layout* and *Git hooks*.
- The header of `scripts/lib/bash.sh` and of each file under `scripts/lib/`.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work. The change is
two comments of one block, and check 10 and check 15 of `scripts/check-docs.sh` notice a broken
block. Stop and hand off when the block needs more than these two lines.
