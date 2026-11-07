# Ticket: Avoided terms become a check that spares the template's own text

## What to build

The plain-rules sensor reports a word the glossary lists under _Avoid:_ on an added line of the
rules, and fails nothing (ADR-0001). It was a failing check until the review of the whole branch
of v0.8.0 found that derived projects already fill _Avoid:_, as the glossary scaffold asked, with
the terms of their own domain. A failing check then broke their take-up on inherited template
text: in comb, words such as *shape*, *socket*, and *pin* in the ADRs the template wrote, and a
take-up by normalization counts every line of a restated ADR as added.

With the next release the template's ADRs become a fixed base that a project never edits. Then a
check can hold the glossary against the project's own rules only, and spare the template's files.
The same release may make the soft modal verbs a check, which a minor before v1.0.0 may do
(ADR-0005). The parser also meets prose in an _Avoid:_ list, as comb writes it: "self-edge in
prose", "shape alone", "frustum culling, outside the wording of the constraint". It either reads
bare words only, as the glossary scaffold then says, or reports what it cannot parse.

ADR-0001's *Enforcement* changes with it, in a commit of ADRs only that the human reviews.

## Acceptance criteria

- [ ] Given a derived project with _Avoid:_ lists whose words stand in the template's own files,
      when the check runs on a take-up of the release, then it passes.
- [ ] Given an avoided word added to one of the project's own rules, when the check runs, then it
      fails and names the term to use.
- [ ] Given an _Avoid:_ item with a qualifier, when the glossary is read, then the item is read
      as the scaffold says, or reported as not parsed.

## Read first

- Touches: `scripts/check-docs.sh`, `scripts/lib/rules.sh`, `scripts/sensor-plain-rules.sh`,
  `docs/adr/0001-agent-governance-model.md`, `docs/GLOSSARY.md`
- The merge of the avoided terms as a sensor on `feat/0.8.0`, its *Doubts*.

## Blocked by

- None (can start immediately)

## Mode

with the human: the ticket changes an ADR and turns a report into a gate.
