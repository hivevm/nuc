# Ticket: Every reference to the bash hooks follows, and the release says how to take it up

## What to build

Each place that still describes the hooks as bash scripts follows the switch: the `harness` entry
of the `propose-adr` catalogue, `TEMPLATE-SETUP.md`, the README, and the self-tests whose fixtures
copy the hooks. The release notes of the minor say what a derived project does: install `nuc`
first (the Feature or a release), then take up `.githooks/`, its blob list, `nuc.toml`, the Dev
Container's Feature and lock, and the Action in CI.

## Acceptance criteria

- [ ] Given the tree, when it is searched for a description of the hooks as bash scripts, then none
  is left outside the history.
- [ ] Given the draft of the release notes, when the human reads it, then it names each step a
  derived project takes, `nuc` first.

## Read first

- Touches: `.agents/skills/propose-adr/concepts/harness.md`, `TEMPLATE-SETUP.md`, `README.md`, the
  self-tests that copy the hooks
- The release section of `CONTRIBUTING.md`; NUC-releases-are-semver-tags clause 6

## Blocked by

- docs/plan/hooks-run-nuc/02-the-hooks-are-the-pinned-shims.md

## Mode

with the human: what every derived project is asked to do on a take-up.
