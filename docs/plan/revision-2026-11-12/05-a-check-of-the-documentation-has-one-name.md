# Ticket: A check of the documentation has one name, not a number and a rule key

## What to build

Each check of `scripts/check-docs.sh` has two names:

- **Its number**, 1 to 15, in the header of the script and in the comment `# check N` on its
  function. The *Applies to* of five `NUC-` ADRs names checks by number, such as "checks 1, 2, 5,
  6, 7, and 8 of `scripts/check-docs.sh`". `scripts/sensor-binding-adrs.sh` routes a change by it:
  it maps each changed line to the number of the check whose function holds it, since f59cc3d. The
  first field of `scripts/fixtures/check-docs-record.txt`, `TEMPLATE-SETUP.md`, the workflow
  `checks.yml`, the self-tests, and other files of the tree cite numbers too.
- **Its rule keys**, since PR #36: every finding ends in `[docs/<rule>:<reason>]`, such as
  `docs/adr-index` or `docs/links`. The `nuc` binary of `hivevm/nuc-tools` names its rules this
  way.

Today each check reports one rule area, one to one: check 1 reports `docs/adr-index`, check 3
`docs/links`, and so on to check 15, `docs/prose-width`. Nothing in the tree states the map. A
reader who meets a key in a finding cannot find the ADR whose *Applies to* binds it without
reading the script. A renumbering of the checks moves the *Applies to* of `NUC-` ADRs, which only
the template corrects in place
([NUC-decisions-are-proposed-then-accepted §6](../../adr/NUC-decisions-are-proposed-then-accepted.md)).

This holds whatever becomes of the proposal `NUC-checks-run-by-nuc` on the branch
`docs/nuc-checks-run-by-nuc`. Under the proposal the numbers of a bash script go away, and the
*Applies to* fields and the binding sensor need the rule keys anyway. The proposal does not say so
yet. This ticket may fold into the proposal's follow-ups if the human prefers that.

The first step is the human's choice of one name:

- **Rule keys.** The *Applies to* fields name the rule areas, such as "the rules `docs/adr-index`
  and `docs/links` of `scripts/check-docs.sh`". The sensor routes by the key a check's function
  reports. The numbers stay only as the order of the header, or go.
- **Numbers.** The header maps each number to the rule keys its check reports, and a check of the
  tree holds that map against the keys the script prints.

Naming checks in a `NUC-` ADR binds every derived project and a port. If the human judges it a
decision, it is proposed through `propose-adr` before this ticket is worked. The correction of the
`NUC-` ADRs is a commit of ADRs only that the human reviews.

## Acceptance criteria

- [ ] Given the human's choice, when the *Applies to* of a `NUC-` ADR names checks of
      `scripts/check-docs.sh`, then it names them by the chosen name only.
- [ ] Given a change to the function of one check, when `scripts/sensor-binding-adrs.sh` runs on
      it, then it lists the ADRs whose *Applies to* names that check by the chosen name. Its
      self-test shows it.
- [ ] Given a finding of `scripts/check-docs.sh`, when its key is looked up, then one place of
      the tree names the check, and a check fails when a key the script prints is missing there.

## Read first

- Touches: `scripts/check-docs.sh`, `scripts/sensor-binding-adrs.sh`,
  `scripts/test-sensor-binding-adrs.sh`, `scripts/fixtures/check-docs-record.txt`,
  `scripts/test-check-docs.sh`, the `NUC-` ADRs whose *Applies to* names checks of
  `scripts/check-docs.sh`, `docs/adr/NUC.blobs`, `TEMPLATE-SETUP.md`
- The template's correction of its `NUC-` ADRs:
  [NUC-decisions-are-proposed-then-accepted §6](../../adr/NUC-decisions-are-proposed-then-accepted.md).
- The proposal on the branch `docs/nuc-checks-run-by-nuc`, its *Consequences*.

## Blocked by

- None (can start immediately)

## Mode

with the human: the human chooses the one name, decides whether it needs a proposed ADR, and
reviews the correction of the `NUC-` ADRs. The template has no harness ADR to answer a cap on
open agent work. Stop and hand off after the choice and the commit of ADRs, before the scripts
change.
