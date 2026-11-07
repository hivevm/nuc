# NUC-main-only-via-pr: Work is committed on branches, a human decides what leaves the machine, and `main` changes only through a merged pull request

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** the git hooks under `.githooks/`, the git settings the Dev Container sets for them, every commit, merge, and push, the integration steps on `feat/` branches, the repository settings of the remote, the sections *Git hooks*, *Integration branches*, and *Repository settings* of `CONTRIBUTING.md`, `scripts/ready-for-main.sh`, `scripts/drop-merged-branch.sh`, and `scripts/sensor-repo-settings.sh`

## Context

Agents commit, merge, and push as fast as they type. Without rules on integration, four things go
wrong.

- **Work leaves the machine unseen.** An agent that pushes, opens a pull request, or rewrites
  history on its own acts where a human can no longer take it back quietly. A push is public, and
  a reset or a clean loses work nobody reviewed. An instruction for one push read as leave for the
  next one makes every later push unasked.
- **`main` moves without a review.** A commit on the local `main`, a fast-forward to a local
  branch, or a push to the remote's `main` skips the pull request, the required checks, and the
  Code Owners review. The local `main` then differs from the remote's, and every later branch
  starts from a state nobody else has.
- **The history loses what was reviewed.** A squash merge folds a branch into one commit. A
  rebase merge rewrites its commits with new identifiers. Both discard the merges an integration
  branch carries, and with them each branch's hand-off. A rewrite of `main` breaks every clone and
  every citation of a commit.
- **A gate binds one agent only.** A permission prompt or a deny list in one agent's configuration
  stops that agent. The next agent, or a human, passes it. A rule that rests on such a gate looks
  enforced and is not.

Several forces bound the answer. Git does not version hooks, and `--no-verify` skips most of them,
so a hook holds only for those who keep it on. The remote's settings hold for everyone who pushes,
but they see only what reaches the remote. An administrator may bypass a ruleset. Several branches
reviewed apart collide only when they meet, so some work has to meet before it reaches `main`.

These rules stood in [`AGENTS.md` §6](../../AGENTS.md#6-project-rules) and in no ADR, so no sensor
routed a change to the hooks or the integration steps to them.

## Decision

We will commit only on branches, leave pushes and rewrites to a human's instruction, and change
`main` only by the merge commit of a pull request.

1. **Branches.** An agent may commit on a branch without an instruction. No human and no agent
   may commit on `main`.
2. **Instruction.** A human decides what leaves the machine. An agent must wait for a human's
   instruction before each of these:
   - a push;
   - a `gh` command;
   - a command that rewrites or discards history, such as `reset`, `rebase`, `merge`, `restore`,
     or `clean`.

   An instruction names one action and implies no next one. A standing instruction may cover one
   push only: the claim on a ticket across clones. It may cover that push only where the harness
   ADR grants it.
3. **Credentials.** A human authenticates `gh` through its web flow and enters the one-time code.
   An agent must not request, store, or hard-code a personal access token.
4. **Pull request.** A change must reach `main` through a pull request. The pull request must
   merge as a merge commit. The local `main` must only take up the remote's `main`, by
   `git merge --ff-only origin/main`.
5. **History of `main`.** Nobody may rewrite what has reached `main`.
6. **Integration branch.** On a human's instruction, branches may integrate first on a `feat/`
   branch.
   - A branch must pass the review of
     [`AGENTS.md` §5](../../AGENTS.md#5-quality-bar--definition-of-done) before it integrates.
   - It integrates by a local merge or by a pull request against the `feat/` branch.
   - Each integrated branch must be one merge commit.
   - The merge commit's message must be the hand-off of the change. It must fill the sections of
     the pull request template.
7. **Rework.** Until the `feat/` branch's pull request into `main` merges, the whole `feat/`
   branch is the human's. The human may rework it and push it again. This includes the merges of
   pull requests into it.
8. **Hooks.** The git hooks under `.githooks/` must enforce each rule of this ADR that a file in
   the tree decides.
   - An agent must not bypass a hook. It must not pass `--no-verify` or run git without the hooks.
   - An agent must not move `origin/main` by hand or write a record of a green tree by hand.
   - The push of a claim (clause 2) is the one exception. It skips the pre-push hook.
   - A human may bypass a hook deliberately.
9. **What enforces a rule.** Only what every agent hits enforces a rule: the git hooks, the
   checks, and the repository settings.
   - The repository settings must enforce on the remote each clause of this ADR that no file
     enforces.
   - A tool's own configuration enforces no rule, and no rule may rest on it.
   - A tool's configuration may close a path for its own agent as defence in depth.

**Out of scope:**

- how a claim on a ticket is made and released, which `NUC-large-work-is-planned` and the
  `work-tickets` skill carry;
- what the review checks and which checks run before a push, which
  [`AGENTS.md` §5](../../AGENTS.md#5-quality-bar--definition-of-done) states;
- the settings that hold other decisions: the Code Owners review of the record, which
  [NUC-adrs-record-decisions §5](NUC-adrs-record-decisions.md) needs, and secret scanning, which
  [`AGENTS.md` §7](../../AGENTS.md#7-secrets) needs;
- which agents work and what runs unattended, which the harness ADR decides;
- the commands of each step and each hook's refusals, which `CONTRIBUTING.md` carries.

## Latitude

A project may choose:

- whether its harness grants the standing instruction for the push of a claim, which the harness
  ADR records ([catalogue entry](../../.agents/skills/propose-adr/concepts/harness.md));
- whether branches integrate on a `feat/` branch first, and by local merge or by pull request;
- further hooks, checks, and repository settings that hold its own rules.

The catalogue has no entry for the last two choices, and neither needs an ADR.

## Alternatives considered

- **Push to `main` directly, trunk-based.** It is fast and needs no pull request. Every push
  skips the required checks and the Code Owners review, and a red tree reaches every clone.
- **Squash merges.** The history of `main` gets one commit per change. The merges of a `feat/`
  branch and the hand-off of each branch are lost, and so is the regrouped history.
- **Rebase merges.** The history stays linear. GitHub writes new commits with new identifiers, so
  the commits a review saw no longer exist, and the integration merges flatten.
- **Gates in each tool's configuration.** A permission prompt or a deny list is quick to write.
  It holds for one agent only, and a prompt asks about a command, not the branch it lands on.
- **Repository settings alone.** They hold for everyone on the remote. A red push still leaves the
  machine, a local `main` still drifts, and an administrator may bypass them.
- **Hooks alone.** They stop the mistake before it leaves the machine. Git does not version them,
  `--no-verify` skips most of them, and a fresh clone runs none until it enables them.
- **A standing instruction for every push.** It saves the human a step per push. It lets work
  leave the machine unseen, which is the first failure above.
- **A personal access token for `gh`.** It lets an agent act on the remote without a human. A
  stored token leaks with the file or the log that holds it.

## Sources / Prior art

- GitHub, *About merge methods on GitHub* —
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github>:
  a squash merge combines the commits into one, and a rebase merge writes new commits with new
  identifiers.
- GitHub, *Available rules for rulesets* —
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets>:
  a required pull request, allowed merge methods, required status checks, an up-to-date branch,
  blocked force pushes and deletions, the Code Owners review, and the bypass list.
- GitHub, *About protected branches* —
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches>:
  the older form of the same protection.
- Git, *githooks* — <https://git-scm.com/docs/githooks>: `--no-verify` skips `pre-commit` and
  `pre-merge-commit`, and a non-zero exit of `reference-transaction` in its prepared state aborts
  the update.
- GitHub CLI, *gh auth login* — <https://cli.github.com/manual/gh_auth_login>: the web flow is the
  default, and the token goes to the system's credential store.

## Consequences

- Positive: nothing reaches `main` or the remote without a human and the required checks.
- Positive: the history of `main` keeps each merge and its hand-off.
- Positive: the binding sensor routes a change to the hooks or the integration steps here.
- Negative: every push waits for a human, and an agent cannot finish an integration alone.
- Negative: hooks are enabled per clone, so a clone without them relies on the remote alone.
- Follow-ups: the hooks, the scripts, and their self-tests cite this ADR instead of the rule file.

## Enforcement

The hooks hold what a file decides, and `scripts/test-git-hooks.sh` exercises every row of the
table under *Git hooks* in `CONTRIBUTING.md`. That self-test cites this ADR.

- `.githooks/pre-commit` refuses a commit on `main` (clause 1).
- `.githooks/pre-merge-commit` refuses a merge on `main` (clause 1).
- `.githooks/reference-transaction` refuses a move of the local `main` to a commit that
  `origin/main` lacks (clause 4). `--no-verify` does not skip it.
- `.githooks/pre-push` refuses a push to the remote's `main`, a deletion included (clauses 4 and
  5).
- The git setting `merge.ff false` makes every local merge a merge commit (clause 6).
- `scripts/ready-for-main.sh` refuses a branch that still carries a fixup (clause 5).
- `scripts/drop-merged-branch.sh` takes up `origin/main` by a fast-forward only (clause 4).

The ruleset on `main` requires a pull request and allows the merge commit only. It blocks force
pushes and deletion (clauses 4, 5, and 9). `scripts/sensor-repo-settings.sh` reports each setting
that differs, on a human's instruction.

**Not mechanically decidable:** no file sees an instruction, a credential flow, or a gate in a
tool's configuration. The review holds these judgements:

- whether a push, a `gh` command, or a rewrite had its instruction (clause 2);
- whether a personal access token was requested or stored (clause 3);
- whether a merge commit's message is the hand-off (clause 6);
- whether an agent bypassed a hook or ran git without one (clause 8);
- whether a rule rests on a tool's own configuration (clause 9).
