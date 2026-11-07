# Ticket: The setup's close clears the template's own open work

## What to build

The template plans its own work in its tree, under `docs/plan/` and `docs/backlog/`, as ADR-0006
asks of every project. A project created from the template copies that tree and takes the
template's open tickets and backlog entries as its own; `close_setup` in
`scripts/test-template-setup.sh` removes neither. For v0.8.0 the open work was kept off `main`
instead, which is no rule a later release keeps.

`close_setup` removes the files under `docs/plan/` and `docs/backlog/` that the template's tree
holds, so the project starts with an empty plan and an empty backlog. The setup file says so where
it lists what the close removes. A project that already planned under either directory before it
closed the setup keeps what it wrote: the close removes only paths the template's release carried.

## Acceptance criteria

- [ ] Given a copy of the template with a ticket under `docs/plan/` and an entry under
      `docs/backlog/`, when `scripts/test-template-setup.sh --close` runs on it, then both are gone
      and `scripts/check-all.sh` is green on the copy.
- [ ] Given a copy whose project added a ticket of its own before the close, when the close runs,
      then that ticket stays.
- [ ] Given `TEMPLATE-SETUP.md`, when its opening paragraph is read, then it names the template's
      plan and backlog among what the close removes.

## Read first

- Touches: `scripts/test-template-setup.sh` (`close_setup`, case 4), `TEMPLATE-SETUP.md`
- `docs/adr/0006-feature-layer.md`, *Decision*: the plan and the backlog in the tree.
- How the close tells the template's files from the project's: the template's title in the README
  is what `--close` refuses on; the release a project carries is its `Template release` line.

## Blocked by

- None (can start immediately)

## Mode

with the human: the template has no harness ADR, so no cap on open agent work can be answered.
