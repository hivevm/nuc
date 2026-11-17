# Ticket: Propose the NUC- ADR that makes the hooks the shims of nuc

## What to build

The hooks are bash by NUC-checks-are-bash (clause 1 the scripts, clause 3 a hook needs no more than
bash 3.2, clause 6 the local gate) and NUC-main-only-via-pr clause 6 (the hooks' refusals). Propose,
through `propose-adr`, the `NUC-` ADR that decides the switch as the spec says: the hooks are the
shims of `nuc` pinned by their blobs, `nuc` comes by the Feature and the Action, the template ships
a `nuc.toml` with `minimum` and the `hook/` rules, and a hook without `nuc`, or with one older than
the minimum, refuses. It supersedes the clauses of the two ADRs that name the bash hooks, as the
template's mechanics decide for a change of a `NUC-` clause; the human decides each.

## Acceptance criteria

- [ ] Given the ADR, when `scripts/check-docs.sh` runs, then it passes with the ADR proposed and its
  index row in place.
- [ ] Given the human's decision, when it is recorded, then the ADR is accepted, with what it
  supersedes, or the ticket hands back why not.

## Read first

- Touches: `docs/adr/`, `docs/adr/README.md`, `docs/adr/NUC.blobs`
- NUC-checks-are-bash, NUC-main-only-via-pr, NUC-decisions-are-proposed-then-accepted,
  NUC-base-is-fixed; the `propose-adr` skill

## Blocked by

- None (can start immediately)

## Mode

with the human: a `NUC-` ADR is the human's to decide.
