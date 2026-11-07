# Ticket: A finding outside the plan goes to the backlog

## What to build

A project records where findings outside the plan go, in one of two forms:

- **Files:** one file per entry in a backlog directory beside the plan, not inside it, because the
  frontier sensor reads every file under the plan as a ticket. An entry holds a title, what was
  observed, and where. It holds no history. It is created in a commit of its own.
- **Issues:** the issue tracker of the host, for a project whose reports arrive from outside.

A catalogue entry of the `propose-adr` skill describes both forms, when each fits, and its sensor.
A project records its form in an ADR of its own.

A new sensor lists the backlog entries on `main` and the entries that exist only on local branches
not yet merged, from the history of the backlog directory. It fails nothing. It runs in the
sensors job and in `scripts/check-all.sh`, with its self-test first.

The rule file gains one rule: a finding outside the scope of the current ticket becomes a backlog
entry, not a larger change. The human moves an entry into the plan. The design revision lists the
entries that touch the modules it revisits. The commit that creates a ticket from an entry deletes
the entry.

First, a commit of ADRs only corrects ADR-0006 in place: the receiving of findings moves from *Out
of scope* into the decision, with the two forms as the project's choice; triage stays out of
scope. The human reviews that commit before anything is built
([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 and 4).

## Acceptance criteria

- [ ] Given an entry on `main` and an entry on an unmerged local branch, when the sensor runs, then
      it lists both, the second with its branch, and exits 0.
- [ ] Given an entry deleted on `main` by the commit that created its ticket, when the sensor runs,
      then it does not list it.
- [ ] Given no backlog directory, when the sensor runs, then it says so and exits 0.
- [ ] Given a backlog entry, when the frontier sensor runs, then it does not read the entry as a
      ticket.
- [ ] Given the self-test, when it runs, then it decides each case above from fixture repositories
      and cites ADR-0006.
- [ ] Given the check-list agreement and the Project Layout check (checks 9 and 10), when they run,
      then the new sensor and the backlog directory are listed where they require.
- [ ] Given the commit that corrects ADR-0006, when it is inspected, then it changes no file but
      the ADR.

## Read first

- Touches: `docs/adr/0006-feature-layer.md`,
  [`AGENTS.md` §4](../../../AGENTS.md#4-working-style), `.agents/skills/propose-adr/concepts/`
  (a new entry and the README's table), `.agents/skills/design-revision/SKILL.md`, a new
  `scripts/sensor-*.sh` with its self-test, `.github/workflows/checks.yml` (job `sensors`),
  `scripts/check-all.sh`, `CONTRIBUTING.md`
- `docs/adr/0006-feature-layer.md`, *Decision*, *Out of scope*, *Alternatives considered*: why the
  plan is not in the issue tracker, and why the backlog may be.
- `.agents/skills/propose-adr/concepts/README.md`: the sections every entry has.
- The golden path: `scripts/sensor-plan-frontier.sh` and its self-test.

## Blocked by

- None (can start immediately)

## Mode

with the human: the ticket corrects an accepted ADR and adds a rule to the rule file.
