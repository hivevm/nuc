# Ticket: The glossary reader reads an Avoid item that wraps across two lines as one

## What to build

The trial migration of nectar to `v0.9.0` failed the plain-rules check on the word "file" in two
project ADRs. nectar's glossary lists `_Avoid:_ include file, part.` for **Chapter**, with the line
break between "include" and "file". `take()` in `avoid_terms` of `scripts/lib/rules.sh` splits
each line of an _Avoid:_ list at its commas on its own, so it reads "include" and "file" as two
items. Under `--require` every derived project's take-up meets this on its first run. The reader
joins the lines of one _Avoid:_ list before it splits at the commas.

## Acceptance criteria

- [ ] Given an _Avoid:_ item wrapped across two lines, when the plain-rules check reads a line that
      holds the second word alone, then it reports nothing for it.
- [ ] Given `scripts/fixtures/plain-rules.txt`, when its self-test runs, then a case pins it.
- [ ] Given the line count of the spec's measure, when it is taken after the change, then it has
      not risen above 10,015.

## Read first

- Touches: `scripts/lib/rules.sh`, `scripts/fixtures/plain-rules.txt`,
  `scripts/test-sensor-plain-rules.sh`

## Blocked by

- None (can start immediately)

## Mode

unattended: the criteria decide it; stop after two failed attempts at a line-neutral fix and hand
off with the state written here.
