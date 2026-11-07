# Ticket: The pilot restates the release ADR as `NUC-releases-are-semver-tags`

## What to build

The first restatement, which sets the form the other `NUC-` ADRs copy.
`NUC-releases-are-semver-tags` restates ADR-0005 in plain rules, with a *Latitude* section,
proposed in a commit of ADRs only. Its take-up clause becomes: replace the `NUC-` files and the
blob list, map the project's ADRs, run the checks. The normalize skill's take-up section follows
it. ADR-0005 stays until ticket 10.

This ticket runs beside ticket 02. The blob list is decided in
[NUC-adrs-record-decisions §12](../../adr/NUC-adrs-record-decisions.md),
and ticket 02 builds it. This ticket only cites the clause. The ADR template gains the *Latitude*
section here, and ticket 02 adds its header fields.

The hand-off lists each clause of ADR-0005 with its home in the new ADR, a skill, or nowhere and
why. It reports the word count before and after.

## Acceptance criteria

- [ ] Given the new ADR, when the plain-rules sensor reads its *Decision* and *Enforcement*, then it
      reports no sentence over the limit and no modal verb besides *must*, *must not*, *may*.
- [ ] Given its *Latitude* section, when a reader looks for a tool name or a project value, then
      there is none, and each choice links the catalogue.
- [ ] Given the normalize skill, when its take-up section is read, then it names the steps of the
      new clause and no merge of inherited ADRs.
- [ ] Given every clause of ADR-0005, when the hand-off's clause table is walked, then each has a
      home.
- [ ] Given check 14, when it runs, then it cites the new ADR.

## Read first

- Touches: `docs/adr/0005-template-releases.md`, `docs/adr/`, `docs/adr/README.md`,
  `.agents/skills/normalize/SKILL.md`, `scripts/check-docs.sh` (check 14), `README.md`
- [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), the writing rule.
- The spec's item *Form*.

## Blocked by

- docs/plan/fixed-base-and-recut/01-identifiers-name-their-category.md

## Mode

with the human: the human reviews the form here before six more ADRs copy it.
