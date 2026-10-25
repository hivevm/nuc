# Ticket: Draft where the git hooks and the review sensors are decided

## What to build

A draft for the maintainer, written through `propose-adr`. It is not landed here. The structure
has grown past the record in three places:

- **The git hooks.** The hooks under `.githooks/` are the local gate of
  [`AGENTS.md` §6](../../../AGENTS.md#6-project-rules) and
  [§5](../../../AGENTS.md#5-quality-bar--definition-of-done). No ADR names them in *Applies to* or
  *Enforcement*. Their logic is also repeated: the refusal on `main` in `pre-commit` and
  `pre-merge-commit`, and `unset $(git rev-parse --local-env-vars)` in three hooks and
  `scripts/lib/selftest.sh`.
- **The hook settings check.** Check 5 of `scripts/check-devcontainer.sh` holds that the
  container enables the hooks and the merge settings (`core.hooksPath`, `merge.ff`, `pull.ff`).
  Its header says itself that it "is no part of ADR-0004". ADR-0004's *Enforcement* does not list
  it, although ADR-0004's *Applies to* names the script.
- **Four sensors.** No ADR names `sensor-review-binding.sh`, `sensor-tests-kept.sh`,
  `sensor-action-refs.sh`, or `sensor-repo-settings.sh`. ADR-0002 covers them only as "the checks
  and sensors under `scripts/`". Three of their self-tests carry no `Verifies:` marker, so the
  traceability check holds them to nothing.

Under step 5 of the `design-revision` skill a check that no ADR cites, and that prevented nothing,
is dropped. This revision drops none of them: review binding reported the unreviewed pull request #8
in scope, and the others serve a catalogue decision of a derived project. Whether they stand belongs
to this draft.

Options the draft weighs:

1. Correct ADR-0002 in place (ADR-0005) to name the hooks as the local runner of the checks, and
   the four sensors with what each reports, each self-test citing ADR-0002.
2. Correct ADR-0004 to take check 5 in, or move check 5 to the hooks' self-test.
3. A new ADR on the local gate (hooks plus `check-all.sh --changed` with its `# Inputs:` lines,
   today defined only in a comment of `check-all.sh`).

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then each hook, check 5, and each of the
      four sensors is named by one ADR in force, or listed for removal.
- [ ] Given the decision, when the traceability check runs, then every self-test of a script that
      ADR names cites it with `Verifies:`.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md`, `docs/adr/0004-dev-container-runtime.md`
  (in full: this weighs their forces)
- [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) and
  [§6](../../../AGENTS.md#6-project-rules); `README.md` → Git hooks
- `.agents/skills/propose-adr/SKILL.md`

## Blocked by

- None (can start immediately)

## Mode

with the human: a decision on accepted ADRs, which only the maintainer takes.
