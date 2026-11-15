# Ticket: A long sentence added to a skill is reported

## What to build

An author who adds a sentence over 25 words to a skill sees it in the plain rules sensor's report,
under a key of its own, as a hint. First, the Enforcement of NUC-documents-are-fixed is corrected
in place, so that it says the sensor also reads the skills for long sentences and fails nothing
on them. The human reviews that commit of ADRs in the session. Then the sensor reads the skills,
for long sentences on added lines only. `--require` does not fail on it, in the template or in a
derived project. What the sensor reads and reports for the rules stays as it is. Tickets 04
and 05 wait for it, so that it reports the long sentences they add.

## Acceptance criteria

- [ ] Given NUC-documents-are-fixed, when the first commit lands, then it is a commit of ADRs only,
  with `docs/adr/NUC.blobs` rewritten in it. Its Enforcement names the skills, the hint's key, and
  that the hint fails nothing.
- [ ] Given a change that adds a sentence of 26 words to a skill, when the sensor runs, then it
  reports the sentence with its file and line under the new key.
- [ ] Given a skill with a long sentence the change does not touch, when the sensor runs, then it
  reports nothing for it.
- [ ] Given a change that adds a long sentence to a skill, when the sensor runs with `--require`,
  then it exits 0 for that sentence.
- [ ] Given a soft modal verb or an avoided word added to a skill, when the sensor runs, then it
  reports nothing for it.
- [ ] Given the existing cases of the sensor's fixture table, when its self-test runs, then each
  passes unchanged.
- [ ] Given the sensor's header, when it is read, then it names the skills and the hint's key.
- [ ] Given the hand-off, when the human reads it, then it names the commit of ADRs reviewed, the
  deviation from NUC-large-work-is-planned §4, and under *A derived project acts on* that the
  sensor newly reads the project's own skills, as a hint only.

## Read first

- Touches: `docs/adr/NUC-documents-are-fixed.md`, `docs/adr/NUC.blobs`,
  `scripts/sensor-plain-rules.sh`, `scripts/lib/rules.sh`, `scripts/test-sensor-plain-rules.sh`,
  `scripts/fixtures/plain-rules.txt`
- NUC-documents-are-fixed §5 and its Enforcement; NUC-checks-are-bash §4 (a sensor reports; it
  fails only where a decision makes it a check);
  NUC-decisions-are-proposed-then-accepted §4 and §6.
- The conventions' entries "A self-test asserts what it builds" and "A check's cases are a table".
- The golden path: how the sensor reads the rule file through `scripts/lib/rules.sh`. Its file
  filter admits only the rule file and ADRs and counts every streamed line for soft modal verbs,
  so a skill needs a pass of its own or a tagged stream.

## Blocked by

- None (can start immediately)

## Mode

with the human. It corrects an accepted `NUC-` ADR, which the human reviews, and the plan lives
off `main` (see the spec), so no ticket is dispatched.
