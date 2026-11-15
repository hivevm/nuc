# Ticket: A long sentence added to a skill is reported

## What to build

An author who adds a sentence over 25 words to a skill sees it in the plain rules sensor's report,
under a key of its own, as a hint. The sensor reads the skills for long sentences on added lines
only. `--require` does not fail on it, in the template or in a derived project.

## Acceptance criteria

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

## Read first

- Touches: `scripts/sensor-plain-rules.sh`, `scripts/lib/rules.sh`,
  `scripts/test-sensor-plain-rules.sh`, `scripts/fixtures/plain-rules.txt`
- NUC-checks-are-bash §4 (a sensor reports; it fails only where a decision makes it a check);
  NUC-documents-are-fixed §5.
- The conventions' entries "A self-test asserts what it builds" and "A check's cases are a table".
- The golden path: how the sensor reads AGENTS.md through `scripts/lib/rules.sh`.

## Blocked by

- None (can start immediately)

## Mode

with the human. The plan lives off `main` (see the spec), so no ticket is dispatched.
