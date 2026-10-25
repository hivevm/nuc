# Ticket: Decide the bash version the checks and hooks need

## What to build

A `proposed` correction of ADR-0002, drafted through `propose-adr` and handed to the maintainer,
that names the bash the checks and the git hooks need. Today the decision says only "bash".
`README.md` (Prerequisites) says bash 4.4 or later, and no ADR decides it. The scripts follow two
policies:

- They need bash 4.4: `mapfile -d ''` in `scripts/check-all.sh`, on every hook's `--changed`
  path; `declare -A` in `scripts/check-docs.sh` and `.agents/skills/normalize/remap.sh`; `${x,,}`
  in `scripts/sensor-review-binding.sh` and `scripts/sensor-tests-kept.sh`.
- They are written for 3.2: `.githooks/reference-transaction` and the `${a[@]+…}` idiom of
  `scripts/sensor-plan-frontier.sh`.

The hooks call `bash` from `PATH`, which is 3.2 on macOS. Pull request #4 left the question to
the maintainer under *Doubts*, and pull request #6 put 4.4 into the README without an ADR.

Draft of the clause for ADR-0002 → **The checks**:

> … needs nothing beyond bash 4.4 or later, git, and the standard tools of the base image …; a
> git hook needs no more than bash 3.2, because it runs before any check can say which bash it
> found.

Weigh the alternative too: everything on 3.2. The cost is rewriting `mapfile`, the associative
arrays, and the case conversions.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then ADR-0002 names one bash floor for the
      checks (and one for the hooks, if they differ), with the alternative weighed under
      *Alternatives considered*.
- [ ] Given the decision, when `README.md` → Prerequisites is read, then it names the same floor
      and cites ADR-0002.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (Decision → The checks; Enforcement)
- [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 to 5 (the template corrects its own
  ADRs in place, ADR-0005)
- The *Doubts* of pull request #4

## Blocked by

- None (can start immediately)

## Mode

with the human: this is a decision on an accepted ADR, which only the maintainer takes. The
template has no harness ADR either, so the conditions of
[`AGENTS.md` §4](../../../AGENTS.md#4-working-style) for an unattended run cannot be
answered.
