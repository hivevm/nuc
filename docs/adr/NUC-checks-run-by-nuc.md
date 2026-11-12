# NUC-checks-run-by-nuc: The checks, sensors, hooks, and scripts the template ships are commands of one pinned `nuc` binary, which `nuc.toml` couples to the template release

- **Status:** 🟡 proposed
- **Date:** 2026-11-12
- **Deciders:** NUC maintainer
- **Applies to:** the checks, sensors, hooks, merge driver, and scripts run by hand that the template ships, `nuc.toml`, `scripts/check-all.sh`, the git hooks under `.githooks/`, the workflows under `.github/workflows/`, and the required checks of `CONTRIBUTING.md`
- **Supersedes:** [NUC-checks-are-bash](NUC-checks-are-bash.md)

## Context

[NUC-checks-are-bash](NUC-checks-are-bash.md) ships every check as a bash script under
`scripts/`. It left open whether the template's own checks move to a binary. That ADR names the
cost of the copy. Each derived project carries about 8,000 lines of bash and their self-tests.
A fix reaches another project only by hand, through a take-up. The checks need bash 4.4 and
GNU tools, which macOS and Windows lack outside the container. The self-tests are the larger
part of every run, in every project, although they test the template and not the project.

The probe of 2026-11-08 ran the scripts on macOS and under Git Bash. Under Git Bash the suite
took about 57 minutes, and each platform needed fixes of its own. The maintainer decided on that
day that CI gains no job on either platform, because a binary is to replace the bash checks.

`hivevm/nuc-tools` builds that binary, `nuc`, in Rust. Release v0.1.0 came out on 2026-11-07.
Its own record decides how it works:

- its command line and `nuc.toml`, its ADR-0020:
  <https://github.com/hivevm/nuc-tools/blob/main/docs/adr/0020-command-line-contract-with-hook-signal.md>
- the hand-over of each hook, its ADR-0021:
  <https://github.com/hivevm/nuc-tools/blob/main/docs/adr/0021-hook-contract.md>
- how it follows the template release, its ADR-0023:
  <https://github.com/hivevm/nuc-tools/blob/main/docs/adr/0023-version-coupling-with-hook-defaults.md>
- how it ships, its ADR-0025:
  <https://github.com/hivevm/nuc-tools/blob/main/docs/adr/0025-feature-in-hivevm-features.md>
- a parity harness that compares it with the bash on pinned trees of the template and of derived
  projects, its ADR-0015:
  <https://github.com/hivevm/nuc-tools/blob/main/docs/adr/0015-parity-harness.md>

This ADR decides the template's side of that contract. It is proposed before the parity run
shows no difference. The maintainer accepts it once it does, with the change that removes the
scripts.

## Decision

We will ship the template's checks, sensors, hooks, and scripts as commands of one `nuc` binary,
which each project pins in `nuc.toml`.

1. **Commands.** Every check, sensor, and script run by hand that the template ships is a command
   of `nuc`. So are the decisions of its git hooks and the merge driver of the ADR index. The
   template carries no bash implementation of them and no copy of the source of `nuc`.
2. **Install.** The Dev Container installs `nuc` by its Feature from `hivevm/features`. CI runs it
   by the Action of `hivevm/nuc-tools`. Each is referenced by its major version tag alone.
3. **`nuc.toml`.** The file at the repository root names the oldest `nuc` the repository needs
   and the rules it turns on. It carries the `Verifies:` markers of the `NUC-` ADRs whose rules
   it turns on.
4. **Fail closed.** A missing `nuc` fails every hook and every CI job that needs it. So do a
   `nuc` below the minimum and a missing or unreadable `nuc.toml`. No check passes without
   `nuc`.
5. **Hooks.** Each file under `.githooks/` is a POSIX `sh` shim that hands its hook to
   `nuc hook <name>`. On the answer that the checks run now, the shim runs
   `scripts/check-all.sh`. `nuc init` sets `core.hooksPath`, the merge settings the hooks rely on,
   and the merge driver.
6. **Runner.** `scripts/check-all.sh` runs `nuc check` and then the project's own checks. The
   hooks and CI run it alike. With `--changed`, it runs a check of the project only where the
   branch changed what the check reads. CI must run every check.
7. **Three lists.** `scripts/check-all.sh`, the `checks.yml` workflow, and the required checks of
   `CONTRIBUTING.md` must list the same checks. A job with a matrix is listed by the check runs it
   reports. A workflow that publishes rather than checks is no gate, and `scripts/check-all.sh`
   names it so.
8. **Sensors.** A sensor is a command `nuc sensor <name>`, and `nuc explain` says what it counts.
   It must not fail on what it counts until a decision turns it into a check.
9. **Sensors of the GitHub repository.** A sensor that reads what only the GitHub repository
   holds may need the GitHub CLI, signed in as
   [NUC-main-only-via-pr §3](NUC-main-only-via-pr.md) says. It runs only on a human's
   instruction, never in `scripts/check-all.sh` or `checks.yml`.
10. **Releases.** A release of `nuc` turns no rule on. A template release raises the minimum in
    `nuc.toml` to a `nuc` that decides as its checks do, and turns on the rules it takes up. Its
    annotation names both.

**Out of scope:**

- how `hivevm/nuc-tools` builds, tests, and releases `nuc`, which its own record decides;
- how `hivevm/features` publishes the Feature, which its own record decides;
- the language and build of a project's own code and checks, which its `toolchain` role ADR
  decides ([NUC-base-is-fixed §3](NUC-base-is-fixed.md));
- which test cites a decision ([NUC-decisions-cite-tests](NUC-decisions-cite-tests.md)).

## Latitude

A project may choose:

- further checks of its own, run by `scripts/check-all.sh` after `nuc check`, in the language of
  its toolchain, from the entry `toolchain` of the
  [catalogue](../../.agents/skills/propose-adr/concepts/toolchain.md);
- how a clone outside the Dev Container installs `nuc`, from the binaries of a release. This
  choice needs no ADR.

## Alternatives considered

- **Keep the bash scripts, as [NUC-checks-are-bash](NUC-checks-are-bash.md) decides.** Readable
  by anyone with a shell, and nothing to install. Each project keeps its copy, a fix reaches the
  others only by hand, and the self-tests run in every project.
- **Keep the bash scripts as a fallback when `nuc` is missing.** Spares a clone without the
  binary. Two implementations drift apart, and a missing binary silently changes what the gate
  decides.
- **Leave the template on bash and let a project take `nuc`,** as clause 8 of
  [NUC-checks-are-bash](NUC-checks-are-bash.md) allows by an ADR that narrows it. Every project
  that wants the binary writes the same ADR, and the template's own checks keep every cost
  above.
- **Correct [NUC-checks-are-bash](NUC-checks-are-bash.md) in place.** Fewer files move, but the
  identifier would name the opposite of the decision, and an identifier never changes once it is
  on `main` ([NUC-adrs-are-named-by-category §1](NUC-adrs-are-named-by-category.md)).
- **Pin the exact version of `nuc` by the Feature and the Action alone.** One place fewer. Every
  update Dependabot proposes may turn a green project red, and a project cannot take up a new
  check later than the tool.
- **List the project's own checks in `nuc.toml`, run by `nuc check`.** No bash runner is left.
  `nuc-tools` decided a `nuc.toml` of the minimum and the rules alone, and a shim that runs the
  project's runner, in its ADRs 0021 and 0023 linked under Context.
- **Exempt the `NUC-` ADRs from the markers in a project.** No marker to carry, at the price of a
  change to [NUC-decisions-cite-tests](NUC-decisions-cite-tests.md) and a coverage the project
  no longer sees.
- **Keep the source of `nuc` in the template repository.** One repository for the rules and their
  checks, at the price of that source in every project made from the template.
- **Let `nuc init` write the hooks into `.git/hooks`.** No files in the tree, at the price that a
  reviewer no longer sees what runs on a commit.
- **Keep the scripts run by hand and the skills' scripts in bash.** A smaller first step. It
  leaves bash 4.4 a floor of every host that runs them, which this decision is to remove.

## Sources / Prior art

- The record of `hivevm/nuc-tools`, ADRs 0015, 0020, 0021, 0023, and 0025, linked under Context.
- pre-commit — <https://pre-commit.com/>: hooks delegated to tools pinned by version in a file of
  the repository, the shape the shims and `nuc.toml` take.
- Git, *githooks* — <https://git-scm.com/docs/githooks>: `core.hooksPath`; *gitattributes* —
  <https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver>: a merge driver is a
  command in the configuration.
- Development Containers, *Features* — <https://containers.dev/implementors/features/>: a
  Feature installs a tool at build time and is pinned by tag and lock file.
- GitHub, *Artifact attestations* —
  <https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations-to-establish-provenance-for-builds>:
  the provenance a released binary carries.
- Birgitta Böckeler, *Harness engineering* —
  <https://martinfowler.com/articles/harness-engineering.html>: a harness is guides that feed
  forward and sensors that feed back.

## Consequences

- Positive: a fix to a check reaches every project as a version Dependabot proposes.
- Positive: the checks run on Linux, macOS, and Windows without bash.
- Positive: a project's CI and hooks run the template's checks and its own, not the template's
  self-tests.
- Negative: a clone outside the Dev Container needs `nuc` before it can commit.
- Negative: a change to a check is a change in Rust in another repository. It is released there
  before a template release turns it on.
- Negative: the markers of the `NUC-` ADRs stand in `nuc.toml`, apart from the tests in
  `hivevm/nuc-tools` that hold them.
- Negative: one more release pipeline is part of every project's supply chain.
- Follow-ups: on acceptance, the same change corrects in place the `NUC-` ADRs that name the
  scripts. The container's ADR takes the Feature and `nuc init` for its git settings, and its
  enforcement moves to `nuc check`. The release ADR takes the minimum and the rules of
  `nuc.toml`. `AGENTS.md`, `CONTRIBUTING.md`, and the skills name the commands. The release that
  carries it is a minor before `v1.0.0`, and its notes carry the map from
  [NUC-checks-are-bash](NUC-checks-are-bash.md) to this ADR.
- Follow-ups: the plan's ticket on the migration from numbered ADRs loses its script once the
  map script leaves; when `hivevm/nuc-tools` retires its parity harness.

## Enforcement

`nuc check` holds clauses 3 to 7 and is cited by its tests in `hivevm/nuc-tools`. It fails when:

- `nuc.toml` is missing or names no minimum, or the running `nuc` is below it (clauses 3 and 4);
- a file under `.githooks/` is not a shim `nuc` ships (clause 5);
- the three lists name different checks, or a workflow job runs neither `scripts/check-all.sh`
  nor `nuc` outside a workflow named as no gate (clauses 6 and 7).

`nuc check devcontainer` fails when the Dev Container installs no `nuc` by its Feature, or does
not run `nuc init` at every start (clauses 2 and 5). The parity harness of `hivevm/nuc-tools`
holds that each command decides as the bash check of the release did (clause 1). `nuc.toml`
cites this ADR.

**Not mechanically decidable:** the review holds these judgements:

- whether the template still carries a bash implementation of a command (clause 1);
- whether a sensor never fails on what it counts (clause 8);
- whether a sensor of the GitHub repository runs on instruction only (clause 9);
- whether a template release names the `nuc` it needs and the rules it turns on (clause 10).
