# Ticket: Decide whether check-docs.sh is split along the decisions it holds

## What to build

`scripts/check-docs.sh` is 1028 lines and carries 15 checks that serve five owners:

| Checks | Owner |
|---|---|
| 1–8, 10 | ADR-0001 |
| 9 | ADR-0002 |
| 11 | ADR-0003 |
| 12, 13 | the setup lifecycle (they switch on `TEMPLATE-SETUP.md`) |
| 14 | ADR-0005 |
| 15 (prose width) | no ADR |

Its self-test cites ADR-0001, ADR-0003, and ADR-0005 but not ADR-0002, although it tests check 9.
No ADR asks for a split. The check numbers have meanwhile become an interface that a split would
renumber: ADR-0002 cites "check 9", ADR-0005 "check 14", and `TEMPLATE-SETUP.md` and
`scripts/test-template-setup.sh` cite checks 12 and 13. `.githooks/pre-merge-commit` hard-codes
the script as the record check.

Decide with the maintainer:

1. **Keep it whole.** Add only the missing `Verifies: ADR-0002` and an owner for check 15.
2. **Split by decision.** For example, the setup checks go with ticket 06's skill script, with
   every citation of a check number moved in the same change.

## Acceptance criteria

- [ ] Given the decision, when a check of `check-docs.sh` is read, then its header names the ADR
      or the setup step that owns it, check 15 included.
- [ ] Given the self-test, when the traceability check runs, then `test-check-docs.sh` cites every
      ADR whose check it tests.

## Read first

- `docs/adr/0001-agent-governance-model.md`, `docs/adr/0002-decisions-verified-by-tests.md`
  (Enforcement)
- the header of `scripts/check-docs.sh`

## Blocked by

- None (can start immediately)

## Mode

with the human: a split renumbers checks that accepted ADRs cite, and the template has no harness
ADR for an unattended run.
