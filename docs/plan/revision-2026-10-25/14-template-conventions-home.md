# Ticket: Draft where the template keeps the conventions of its own work

## What to build

A draft for the maintainer, written through `propose-adr`. In the template, `docs/CONVENTIONS.md`
is the derived project's scaffold. The setup deletes its placeholder, and check 12 fails while it
stays. An entry written there would ship to every derived project as that project's convention.
So this design revision found mistakes that a convention could have prevented, and no place for
it.

The mistakes, from the reviews of the merges since 2026-10-04, and the entries they call for:

- **Old wording left after a rule changed.**
  - Pull request #9: "stale wording from the branch per step"; two setup sentences still cited
    the old rule 3 until a later commit.
  - Pull request #6: commit messages omitted part of their diff after a regroup.
  - Entry: *A change to a rule searches the tree for its old wording and for every citation of
    its anchor, and corrects them in the same commit; an anchor check sees only the link, never
    the restated words.*
- **Self-tests that hold the template's own state.**
  - Pull request #3: the traceability self-test accepted every ADR, and the setup self-test
    removed only the template's scripts, so both turned red in a derived project.
  - Entry: *A self-test builds what it asserts from the tree it copies, never from the template's
    own ADRs, scripts, or numbers.* The normalize self-test already runs the other self-tests on a
    moved copy, which catches part of this.
- **A rule stated in a skill.**
  - Pull request #9: the `normalize` skill stated when the record begins, and the setup skill ran
    a `gh` sensor without an instruction.
  - ADR-0003 already leaves this to review. No entry, unless the maintainer wants one.

Options: a section of `CONTRIBUTING.md`, which stays the template's and which the setup keeps or
replaces; or template-only entries in `docs/CONVENTIONS.md`, marked like the README's NOTE blocks
and removed by the setup's close.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then the template's conventions have one
      home that a derived project does not inherit by accident.
- [ ] Given the decision, when the first two entries above land there, then each says what is
      done and why, in a sentence or two.

## Read first

- `docs/adr/0001-agent-governance-model.md` (the conventions' role), `docs/CONVENTIONS.md`
- `TEMPLATE-SETUP.md` (what the setup deletes), check 12 of `scripts/check-docs.sh`
- The *Review* sections of pull requests #3, #6, and #9

## Blocked by

- None (can start immediately)

## Mode

with the human: where the template's own conventions live is a decision on the document set
(ADR-0001).
