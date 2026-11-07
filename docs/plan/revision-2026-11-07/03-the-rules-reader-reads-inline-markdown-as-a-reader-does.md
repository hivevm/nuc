# Ticket: The rules reader reads inline Markdown as a reader does

## What to build

`rule_stream` in `scripts/lib/rules.sh` feeds the plain-rules sensor: its long sentences, soft
modal verbs, and avoided terms. It drops code spans and italics, since a rule names a word there,
but the reviews of tickets 02 and 03 of the plan `plain-rules-and-backlog` left these cases
unread:

- a code span that opens on one line and closes on the next is read as prose on both;
- a bare star in prose, such as `a * b`, or an unclosed underscore after a non-letter, such as
  `$_ENV`, opens an italic that hides the rest of the paragraph from the sensor;
- the plain-rules sensor's word boundary counts no underscore as part of a word, so it lists
  *should* inside `run_should_stop`, where it finds no avoided term;
- a fence closes on any line that starts with its marker, an opening line with an info string
  included;
- a `## ` line inside a fence ends an ADR's section here but not in `adr_section` of
  `scripts/lib/adr.sh`, so the binding sensor and this reader disagree on what a *Decision*
  holds.

A false report costs the reviewer's time; the others are misses. The reader
handles each case as Markdown does, and reads an ADR's sections with the same boundary as
`adr_section`.

## Acceptance criteria

- [ ] Given a code span wrapped over two added lines of `AGENTS.md`, when the sensor runs, then
      it reads none of its text.
- [ ] Given a bare star between spaces, when the sensor runs on an avoided word later in the same
      paragraph, then it reports that word.
- [ ] Given a fence that holds a line starting with its marker and an info string, and a `## `
      line, when the reader runs, then the fence ends at its closing line only and the section
      continues, as `adr_section` reads it.
- [ ] Given the cases of `scripts/test-sensor-plain-rules.sh`, when they run, then the existing
      ones pass unchanged and one new case per bullet above fails before the fix.

## Read first

- Touches: `scripts/lib/rules.sh`, `scripts/lib/adr.sh`, `scripts/test-sensor-plain-rules.sh`
- The merges of tickets 02 and 03 of `plain-rules-and-backlog` (`9f337e2`, `9fd9507`), their
  *Doubts*.
- The case table of `scripts/test-sensor-plain-rules.sh`: the golden path for a new case.

## Blocked by

- docs/plan/revision-2026-11-07/02-the-sensors-that-read-a-change-resolve-it-one-way.md

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
