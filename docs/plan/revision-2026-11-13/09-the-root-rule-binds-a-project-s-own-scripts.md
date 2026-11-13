# Ticket: NUC-checks-are-bash decides that the root rule binds a project's own scripts

## What to build

`scripts/test-check-all.sh` holds every `scripts/*.sh` but the self-tests and `check-all.sh` to
`scripts/lib/root.sh`. The script takes its root only as `--root <dir>` through `enter_root`, and
refuses an argument it does not read. That holds in a derived project too. Since f57e923, step 6 of
`TEMPLATE-SETUP.md` asks it of the project's own `check-build.sh`. Yet
[NUC-checks-are-bash §1](../../adr/NUC-checks-are-bash.md) covers "the checks and sensors the
template ships", and no clause decides that a template rule binds a project's own scripts.

The human decided on 2026-11-13 that it does (decision D1 of the revision of 2026-11-13). The
check keeps its scope. NUC-checks-are-bash gains a clause for it, as the template's correction in
place of its own `NUC-` ADR
([NUC-decisions-are-proposed-then-accepted §6](../../adr/NUC-decisions-are-proposed-then-accepted.md)).

The work comes in two steps:

1. **A commit of ADRs only**
   ([NUC-decisions-are-proposed-then-accepted §4](../../adr/NUC-decisions-are-proposed-then-accepted.md)).
   It holds the new clause of `docs/adr/NUC-checks-are-bash.md`, its *Applies to* and *Enforcement*,
   and the line of `docs/adr/NUC.blobs`. The clause states what every script under `scripts/` of a
   repository must do for its root and its arguments, and which scripts are exempt. The *Applies
   to* names `scripts/lib/root.sh`. The human reviews this commit before the next.
2. **The implementation.** The check of the root and the bash floor cites the clause in its
   comment and in its failure message. Its self-test cites the ADR. The layout of
   `CONTRIBUTING.md` and step 6 of `TEMPLATE-SETUP.md` cite the clause where they state the rule.
   Ticket 02 gives the check its rule key and its home; this ticket leaves it where it stands.
3. **The take-up.** A derived project must act on the new binding: each script of its own under
   `scripts/` must take its root through `scripts/lib/root.sh`. The hand-off of this ticket names
   it in its field for what a derived project acts on. The notes and the take-up steps of the next
   release then carry it
   ([NUC-releases-are-semver-tags §2](../../adr/NUC-releases-are-semver-tags.md)).

## Acceptance criteria

- [ ] Given the commit of ADRs only, when `git show --stat` lists it, then it changes nothing
      outside `docs/adr/`. `scripts/check-docs.sh` passes on it, the rule `docs/base-blobs`
      included.
- [ ] Given the hand-off of this ticket, when the review reads it, then it names the new binding
      as a step a derived project acts on at the next take-up; the review decides this criterion.
- [ ] Given a project script without its call of `enter_root`, when the check runs, then its
      message cites the new clause by its anchor.
- [ ] Given `CONTRIBUTING.md` and `TEMPLATE-SETUP.md`, when `scripts/check-docs.sh` runs, then each
      cites the clause as a link, and the rule `docs/section-refs` passes.
- [ ] Given the commit of ADRs only, when `scripts/sensor-plain-rules.sh` runs on it, then it
      reports no long sentence, no soft modal verb, and no avoided term on the new clause.

## Read first

- Touches: `docs/adr/NUC-checks-are-bash.md`, `docs/adr/NUC.blobs`, `scripts/test-check-all.sh`,
  `CONTRIBUTING.md`, `TEMPLATE-SETUP.md`
- `docs/adr/NUC-checks-are-bash.md`, in full, since the change revises it.
- The clauses on implementation and on immutability:
  [NUC-decisions-are-proposed-then-accepted §4](../../adr/NUC-decisions-are-proposed-then-accepted.md)
  and
  [NUC-decisions-are-proposed-then-accepted §6](../../adr/NUC-decisions-are-proposed-then-accepted.md).
- The commit message of f57e923, and the description of PR #43, *Review*.
- The skill `propose-adr`, for the form of a clause.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR to answer a cap on open agent work, and the human
reviews the commit of ADRs only before its implementation. Past that, a test decides each
criterion of the implementation, and a wrong result costs one revert. Stop and hand off when the
clause would change the meaning of a clause in force, which a release must then map
([NUC-releases-are-semver-tags §7](../../adr/NUC-releases-are-semver-tags.md)).
