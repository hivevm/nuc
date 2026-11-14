# A feat/ branch reaches main as a linear series, and the documents still describe its merges

## Observed

On 2026-11-14 the human had `feat/v0.10.0` rebuilt on main as a linear series before its pull
request: one commit per topic, a topic's ADR-only commit before its code, no merges inside. The
record and the documents still describe a `feat/` branch that keeps one merge per integration,
with its hand-off as the merge message:

- NUC-main-only-via-pr §5 says each integration must be one merge commit, so the rebuilt branch
  breaks an accepted duty as it stands;
- the Integration branches of `CONTRIBUTING.md`, steps 2 to 4 (`git merge --no-ff -F`, a pull
  request merged with the hand-off, `--rebase-merges`), and `git config merge.ff false`;
- steps 7 and 8 and `scripts/ready-for-main.sh`, which take up `origin/main` by a merge, and
  `scripts/drop-merged-branch.sh`, which expects the pull request into main merged as a merge
  commit;
- `scripts/sensor-review-binding.sh`, which binds a review to each merge and reads a pull request
  description only through `--hand-off`. Without it, every commit of the rebuilt branch is named by
  no review;
- `scripts/sensor-release-notes.sh`, which reads "A derived project acts on" from ticket merges
  into a `feat/` branch;
- the review skill (fixups folded into the merges of a `feat/` branch), the work-tickets skill,
  and `.github/PULL_REQUEST_TEMPLATE.md`;
- the comments of `.githooks/pre-merge-commit` and `.githooks/pre-push`;
- `merge.ff false`, which `scripts/check-devcontainer.sh` and NUC-container-hides-host-daemon
  hold;
- the Alternatives and the Enforcement of NUC-main-only-via-pr, the Repository settings of
  `CONTRIBUTING.md`, which say squash and rebase discard the merges of a `feat/` branch, and
  [`AGENTS.md` §6](../../AGENTS.md#6-project-rules);
- the self-tests of the two scripts and the two sensors.

Without merges the hand-offs of the topics stand only in the pull request description into main.
If the linear series is the rule, these change with it, and NUC-main-only-via-pr §5 is corrected
in place with the human's acceptance.

## Where

- `docs/adr/NUC-main-only-via-pr.md`, clause 5; `CONTRIBUTING.md`, Integration branches;
  `scripts/ready-for-main.sh`, `scripts/drop-merged-branch.sh`,
  `scripts/sensor-review-binding.sh`, `scripts/sensor-release-notes.sh`, and their self-tests;
  `.agents/skills/review/SKILL.md`, `.agents/skills/work-tickets/SKILL.md`,
  `.github/PULL_REQUEST_TEMPLATE.md`; `.githooks/pre-merge-commit`, `.githooks/pre-push`;
  `scripts/check-devcontainer.sh`; `docs/adr/NUC-container-hides-host-daemon.md`; `AGENTS.md`.
- The rebuild of `feat/v0.10.0` on 2026-11-14, at the human's request.
