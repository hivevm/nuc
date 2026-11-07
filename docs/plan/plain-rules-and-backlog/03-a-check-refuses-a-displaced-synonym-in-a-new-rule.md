# Ticket: A check refuses a displaced synonym in a new rule

## What to build

The documentation check gains check 17. It reads the _Avoid:_ list of every glossary entry. It
refuses a listed word on a line that a change adds to the rules of the rule file or to the
*Decision* or *Enforcement* section of an ADR. It compares whole words, case insensitive. Its
finding names the file, the line, the word, and the glossary term to use instead. It finds the
change against the base as check 16 does. With an empty _Avoid:_ list it finds nothing, so a
derived project turns it on by filling the list.

First, a commit of ADRs only corrects the *Enforcement* of ADR-0001 in place: it names check 17,
and the glossary terms leave the list of what is review only. The human reviews that commit
before the check is built ([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 and 4).
The release notes of ticket 05 name the correction.

## Acceptance criteria

- [ ] Given a glossary entry that lists *hook script* under _Avoid:_, when a change adds *hook
      script* to the *Decision* of an ADR, then check 17 fails and names the file, the line, the
      word, and the term.
- [ ] Given the same entry, when the word stands in the *Context* of an ADR, or on a line the change
      did not add, then check 17 passes.
- [ ] Given a glossary with no _Avoid:_ entries, when check 17 runs on any change, then it passes.
- [ ] Given a word that contains a listed word, such as *hooks* for *hook*, when check 17 runs, then
      it does not fail on it.
- [ ] Given the self-test of the documentation check, when it runs, then it decides each case
      above from a table of fixture trees and expected findings, and cites ADR-0001.
- [ ] Given the commit that corrects ADR-0001, when it is inspected, then it changes no file but
      the ADR.

## Read first

- Touches: `docs/adr/0001-agent-governance-model.md` (*Enforcement*), `scripts/check-docs.sh`
  (header and a new check 17), `scripts/test-check-docs.sh`, `docs/GLOSSARY.md`
- `docs/adr/0001-agent-governance-model.md`, *Decision*, the glossary item: the form of an entry
  and its _Avoid:_ list.
- [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 to 5: commits of ADRs only, the
  template corrects its own ADRs in place.
- The golden path: check 16 in `scripts/check-docs.sh`, for the base of a change.
- The sections the writing rule of ticket 02 covers, and how its sensor reads them.

## Blocked by

- docs/plan/plain-rules-and-backlog/01-every-script-reads-adr-identifiers-through-the-library.md
- docs/plan/plain-rules-and-backlog/02-rules-are-written-plainly.md

## Mode

with the human: the ticket corrects an accepted ADR, which the human reviews first.
