# A sensor runs on instruction for its cost, and no clause says it may

## Observed

Clause 7 of NUC-checks-are-bash requires a sensor that reads what only the GitHub repository
holds to run only on a human's instruction. `scripts/sensor-red-commits.sh` needs no `gh`. It runs
on instruction because it runs the full checks once per commit, and `scripts/check-all.sh` names
it on an `# On instruction:` line. No clause decides that a sensor may run on instruction for its
cost. The rule `docs/check-lists` therefore holds a list that no ADR bounds, and a project can add
any script to it. The list holds two scripts that are no sensors as well,
`scripts/ready-for-main.sh` and `scripts/drop-merged-branch.sh`.

Clause 7 could name a second case: a sensor whose run costs a full run of the checks or more. That
case leaves the two scripts that are no sensors unbounded, so the clause may need to name them too.
The change widens an accepted NUC- ADR, so the human decides it.

## Where

- `docs/adr/NUC-checks-are-bash.md`, clause 7; `scripts/check-all.sh`, its `# On instruction:`
  lines; the rule `docs/check-lists` of `scripts/check-docs.sh`.
- Named by the design revision of 2026-11-13 and left unfiled; the human chose a backlog entry on
  2026-11-13.
