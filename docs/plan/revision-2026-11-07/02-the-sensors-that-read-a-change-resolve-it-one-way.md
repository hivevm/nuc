# Ticket: The sensors that read a change resolve its base and head one way

## What to build

Four sensors resolve the change they read with the same lines: a base of zeros counts as none, no
base takes the merge base with `origin/main` or `main`, each of base and head must resolve to a
commit or the sensor exits 2, and no head means the working tree. They are
`scripts/sensor-binding-adrs.sh`, `scripts/sensor-review-binding.sh`,
`scripts/sensor-tests-kept.sh`, and `scripts/sensor-plain-rules.sh`. Reading a file as the change
has it, the working tree or `git show <head>:<path>`, is `show()` in the binding sensor and the
same test inline in `rule_stream` of `scripts/lib/rules.sh`. The review of ticket 02 of the plan
`plain-rules-and-backlog` named this as a `lib/git.sh` candidate. Each copy is logic written a
second time, and a fix to one, such as the base of zeros, has to find the others.

`scripts/lib/git.sh` takes the resolution and the reading of a file, and the four sensors and
`rule_stream` call them. Check 17 of `scripts/check-docs.sh` keeps its own fallback, since a
check falls back where a sensor exits 2; it may call the same function if one parameter says so,
and not otherwise. Nothing a sensor decides or prints changes.

While in `scripts/sensor-binding-adrs.sh`: its banner for `--sections` names "the Decision, and
the Enforcement" literally, while the sections it prints are `ADR_RULE_SECTIONS` of
`scripts/lib/adr.sh`. The banner names them from that list.

## Acceptance criteria

- [ ] Given the self-tests of the four sensors, of check 17, and of the plain-rules sensor, when
      they run unchanged after the refactor, then they pass; a self-test that must change means
      the refactor changed behaviour.
- [ ] Given `scripts/lib/git.sh`, when it is read, then it holds the one resolution of base and
      head and the one reading of a file as the change has it, each with its comment, and no
      sensor repeats either.
- [ ] Given `ADR_RULE_SECTIONS` changed in a fixture, when the binding sensor runs with
      `--sections`, then its banner names the sections it prints.
- [ ] Given `scripts/check-all.sh`, when it runs, then it is green.

## Read first

- Touches: `scripts/lib/git.sh`, `scripts/lib/rules.sh`, `scripts/sensor-binding-adrs.sh`,
  `scripts/sensor-review-binding.sh`, `scripts/sensor-tests-kept.sh`,
  `scripts/sensor-plain-rules.sh`, `scripts/test-sensor-binding-adrs.sh`
- `main_merge_base` and `enter_root` in `scripts/lib/git.sh`: the golden path of a shared
  function.
- The merge of ticket 01 of `plain-rules-and-backlog` (`d4fda62`): the same kind of refactor,
  proven by unchanged self-tests.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
