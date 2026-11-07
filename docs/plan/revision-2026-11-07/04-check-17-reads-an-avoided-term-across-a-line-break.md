# Ticket: Check 17 reads an avoided term across a line break, and an Avoid list ends at a sub-list

## What to build

Check 17 of `scripts/check-docs.sh` matches each avoided word on one line at a time. A term of
two words that a rule wraps after the first is not found. And the parser of the glossary keeps
an open _Avoid:_ list going over an indented sub-list line of the same entry, so the sub-list's
words become avoided terms. The review of ticket 03 of the plan `plain-rules-and-backlog` left
both as nits. A missed term lets the synonym through; a sub-list read as terms fails a change on
a word the glossary never listed.

The check matches a term across the line break of a paragraph, and the _Avoid:_ list ends at a
sub-list line.

## Acceptance criteria

- [ ] Given an avoided term of two words wrapped over two added lines of a *Decision*, when
      check 17 runs, then it fails on the line the term starts on.
- [ ] Given the same term across a paragraph break, when check 17 runs, then it passes.
- [ ] Given a glossary entry whose _Avoid:_ list is followed by an indented `- ` sub-list line,
      when check 17 reads the glossary, then no word of the sub-list is an avoided term.
- [ ] Given the cases of check 17 in `scripts/test-check-docs.sh`, when they run, then the
      existing ones pass unchanged and the new ones fail before the fix.

## Read first

- Touches: `scripts/check-docs.sh`, `scripts/test-check-docs.sh`
- `check_avoided_terms` in `scripts/check-docs.sh`, and the merge of ticket 03 of
  `plain-rules-and-backlog` (`9fd9507`), its *Doubts*.

## Blocked by

- docs/plan/revision-2026-11-07/03-the-rules-reader-reads-inline-markdown-as-a-reader-does.md

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
