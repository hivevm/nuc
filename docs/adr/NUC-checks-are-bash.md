# NUC-checks-are-bash: The checks and sensors the template ships are bash scripts under `scripts/`, each held by its self-test and run alike by the hooks and CI

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** the checks and sensors and their self-tests under `scripts/`, the git hooks under `.githooks/`, the workflows under `.github/workflows/`, and the required checks of `CONTRIBUTING.md`

## Context

The template ships no language toolchain. A derived project picks its own, and some hosts run
macOS, Linux, or Windows under Git Bash. The checks that hold the decisions must run on every one
of them before the project has chosen anything.

Three more forces bound the answer. A git hook runs before any check can say which bash it found,
and macOS ships bash 3.2. A check that runs in CI and not in the local gate, or the other way
round, is a gate somebody believes in and does not have. Some settings live only in the GitHub
repository, and the workflow token cannot read all of them.

## Decision

We will ship every check and sensor of the template as a bash script under `scripts/`, which the
git hooks and CI run alike.

1. **Scripts.** The template ships every check and sensor as a bash script under `scripts/`.
   - A script must need nothing beyond bash 4.4 or later, git, and the standard tools of the base
     image.
   - The standard tools are coreutils, grep, sed, awk, find, and tar.
   - The shell lint may need ShellCheck as well.
2. **Self-test.** Each script must have a self-test that runs it on fixture repositories. A script
   runs after its self-test.
3. **Hooks.** A git hook under `.githooks/` must need no more than bash 3.2. It runs before any
   check can say which bash it found.
4. **Sensors.** A sensor is a script `scripts/sensor-<name>.sh`.
   - Its header must say what it counts.
   - A sensor must not fail on what it counts.
   - Only a decision turns a sensor into a check.
5. **Sensor self-tests.** The self-test of a sensor is `scripts/test-sensor-<name>.sh`. It must
   cite this ADR with a `Verifies:` marker.
6. **Three lists.** `scripts/check-all.sh`, the `checks.yml` workflow, and the required checks of
   `CONTRIBUTING.md` must list the same checks. A job with a matrix is listed by the check runs it
   reports.
7. **No gate.** A workflow that publishes rather than checks, such as a release, is no gate.
   - `scripts/check-all.sh` must name it as no gate.
   - Its jobs may run commands of their own.
   - The scripts it runs count in the lists.
8. **Local gate.** The git hooks run the checks before a commit, a merge, and a push. They refuse
   what [`AGENTS.md` §6](../../AGENTS.md#6-project-rules) keeps from `main`.
9. **Changed paths.** With `--changed`, `scripts/check-all.sh` runs a self-test only where its
   `# Inputs:` line names a path the branch changed. CI must run every self-test.
10. **Sensors of the GitHub repository.** A sensor may read what only the GitHub repository holds,
    such as its rulesets and its security settings.
    - Such a sensor may need the GitHub CLI as well, authenticated through its web flow.
    - It runs on a human's instruction only.
    - It must not run in `scripts/check-all.sh` or `checks.yml`.
    - Its self-test must run on fixture responses in place of the API, without the GitHub CLI.
    - That self-test stays in the three lists.

**Out of scope:**

- the language and the build, test, and lint of a project's own code, which its `toolchain` role
  ADR decides ([NUC-adrs-record-decisions §13](NUC-adrs-record-decisions.md));
- which test cites a decision, which [NUC-decisions-cite-tests](NUC-decisions-cite-tests.md)
  decides;
- what the hooks keep from `main`, which [`AGENTS.md` §6](../../AGENTS.md#6-project-rules) states;
- whether the template's own checks move to a binary, which is a decision of its own.

## Latitude

A project may choose:

- to run a binary that implements the template's checks and sensors, in place of the bash
  scripts. Whether the template itself switches stays open;
- further checks and sensors of its own, in the language of its toolchain, from the entry
  `toolchain` of the [catalogue](../../.agents/skills/propose-adr/concepts/toolchain.md).

The catalogue has no entry for the binary, and choosing it needs no ADR.

## Alternatives considered

- **Every check on bash 3.2, the one macOS ships.** It spares a contributor on macOS the install
  of a current bash. It costs a rewrite of the `mapfile` calls, the associative arrays, and the
  case conversions of the checks. The Dev Container and CI carry a current bash, and a check that
  refuses an old one says so at once.
- **A compiled binary as the template's own checks.** One binary runs the same on every host and
  needs no bash. The template would then ship a release artefact to download on every host. This
  ADR leaves the switch open and lets a project take the binary.
- **Run the sensor of the repository settings in CI.** The workflow token reads the rules of a
  branch, but the security settings only with admin rights. CI would need a stored token, which
  [`AGENTS.md` §6](../../AGENTS.md#6-project-rules) forbids, or would report half of them.
- **A pre-push hook that reads the GitHub repository.** It refuses work for a reason the work
  does not have, whenever the network fails.

## Sources / Prior art

- Birgitta Böckeler, *Harness engineering* —
  <https://martinfowler.com/articles/harness-engineering.html>: a harness is guides that feed
  forward and sensors that feed back. Computational sensors are cheap and decide the same way
  each run, which is why the template's sensors are scripts.

## Consequences

- Positive: every check runs on every host with bash and git, before a project picks a toolchain.
- Positive: the hooks and CI run the same checks, so a green push predicts a green pull request.
- Positive: each script carries a self-test, so a change to a check shows what it changes.
- Negative: a contributor on macOS installs a current bash, or works in the Dev Container.
- Negative: the sensor of the repository settings runs only when a human remembers it.
- Follow-ups: whether the template's own checks move to a binary.

## Enforcement

- Check 9 of `scripts/check-docs.sh` holds the three lists (clauses 6, 7, and 10).
  - It fails on a job that runs no script under `scripts/`, except in a workflow named as no gate.
  - It fails on a job with a matrix that `CONTRIBUTING.md` names by its bare name.
  - It fails on a script that neither list runs, unless `scripts/check-all.sh` names it as run on
    instruction.
- `scripts/check-shell.sh` lints every script (clause 1).
- `scripts/check-all.sh` refuses a bash below 4.4, with a message that names the bash it found
  (clause 1).
- `scripts/test-check-all.sh` holds the `--changed` mode (clause 9).
- `scripts/test-git-hooks.sh` exercises every refusal of the hooks (clause 8).
- `scripts/check-traceability.sh` fails on a sensor without its self-test (clause 5). It also
  fails on a self-test of a sensor that does not cite this ADR. It reads this ADR's identifier as
  it reads the others, not as a literal.

The self-tests of these checks cite this ADR.

**Not mechanically decidable:** four judgements rest with the review:

- whether a script stays free of further dependencies (clause 1);
- whether a script runs after its self-test (clause 2);
- whether a hook stays within bash 3.2 (clause 3);
- whether a sensor of the GitHub repository runs on instruction only, and its self-test without
  the GitHub CLI (clause 10).
