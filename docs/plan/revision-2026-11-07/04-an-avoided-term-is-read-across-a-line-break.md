# Ticket: An avoided term is read across a line break, and an Avoid list ends at a sub-list

## What to build

The plain-rules sensor reports a word the glossary lists under _Avoid:_, one line at a time. A
term of two words that a rule wraps after the first is not found. And the parser of the glossary,
`avoid_terms` in `scripts/lib/rules.sh`, keeps an open _Avoid:_ list going over an indented
sub-list line of the same entry, so the sub-list's words become avoided terms. The review of
ticket 03 of the plan `plain-rules-and-backlog` left both as nits.

The sensor matches a term across the line break of a paragraph, and the _Avoid:_ list ends at a
sub-list line.

## Acceptance criteria

- [ ] Given an avoided term of two words wrapped over two added lines of a *Decision*, when the
      sensor runs, then it reports the line the term starts on.
- [ ] Given the same term across a paragraph break, when the sensor runs, then it reports nothing.
- [ ] Given a glossary entry whose _Avoid:_ list is followed by an indented `- ` sub-list line,
      when `avoid_terms` reads the glossary, then no word of the sub-list is an avoided term.
- [ ] Given the avoided-term cases of `scripts/test-sensor-plain-rules.sh`, when they run, then
      the existing ones pass unchanged and the new ones fail before the fix.

## Read first

- Touches: `scripts/lib/rules.sh`, `scripts/sensor-plain-rules.sh`,
  `scripts/test-sensor-plain-rules.sh`
- The merge of ticket 03 of `plain-rules-and-backlog` (`9fd9507`), its *Doubts*.

## Blocked by

- docs/plan/revision-2026-11-07/03-the-rules-reader-reads-inline-markdown-as-a-reader-does.md

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
