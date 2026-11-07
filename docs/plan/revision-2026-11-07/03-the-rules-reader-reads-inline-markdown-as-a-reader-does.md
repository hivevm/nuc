# Ticket: The rules reader reads inline Markdown as a reader does

## What to build

`rule_stream` in `scripts/lib/rules.sh` feeds the plain-rules sensor and check 17 of
`scripts/check-docs.sh`. It drops code spans and single-star italics, since a rule names a word
there, but the reviews of tickets 02 and 03 of the plan `plain-rules-and-backlog` left these
cases unread:

- an italic written `_word_` is read as prose, so check 17 fails on an avoided word a rule only
  names, and the sensor counts it;
- a code span that opens on one line and closes on the next is read as prose on both;
- a bare star in prose, such as `a * b`, opens an italic that hides the rest of the paragraph
  from check 17;
- a fence closes on any line that starts with its marker, an opening line with an info string
  included;
- a `## ` line inside a fence ends an ADR's section here but not in `adr_section` of
  `scripts/lib/adr.sh`, so the binding sensor and this reader disagree on what a *Decision*
  holds.

Check 17 fails a change, so its false finding blocks work; the others are misses. The reader
handles each case as Markdown does, and reads an ADR's sections with the same boundary as
`adr_section`.

## Acceptance criteria

- [ ] Given an added line of a *Decision* with an avoided word in `_italics_`, when check 17
      runs, then it passes; the same word in plain prose still fails.
- [ ] Given a code span wrapped over two added lines of `AGENTS.md`, when the sensor and
      check 17 run, then neither reads its text.
- [ ] Given a bare star between spaces, when check 17 runs on an avoided word later in the same
      paragraph, then it fails on that word.
- [ ] Given a fence that holds a line starting with its marker and an info string, and a `## `
      line, when the reader runs, then the fence ends at its closing line only and the section
      continues, as `adr_section` reads it.
- [ ] Given the cases of `scripts/test-sensor-plain-rules.sh` and of check 17 in
      `scripts/test-check-docs.sh`, when they run, then the existing ones pass unchanged and one
      new case per bullet above fails before the fix.

## Read first

- Touches: `scripts/lib/rules.sh`, `scripts/lib/adr.sh`, `scripts/test-sensor-plain-rules.sh`,
  `scripts/test-check-docs.sh`
- The merges of tickets 02 and 03 of `plain-rules-and-backlog` (`9f337e2`, `9fd9507`), their
  *Doubts*.
- The case table of `scripts/test-sensor-plain-rules.sh`: the golden path for a new case.

## Blocked by

- docs/plan/revision-2026-11-07/02-the-sensors-that-read-a-change-resolve-it-one-way.md

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
