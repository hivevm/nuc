# NUC-design-is-revised: The design is revised when a feature spec closes, and after a number of changes without one

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** the closing of a feature spec, the `Last design revision` line of `docs/ARCHITECTURE.md`, `scripts/sensor-revision-due.sh`, and the `design-revision` skill

## Context

Every feature adds structure faster than anyone revisits it. A concept lands in one more file, a
piece of logic is written a second time, an interface widens by one parameter. None of it is
wrong in the change that brought it. All of it is entropy that no check sees. The record protects
decisions; nothing in the process protects the shape.

The moment to look is while the work that added the structure is still known. A feature spec
that closes is such a moment. A project that writes no specs never reaches it: one in
maintenance, with tickets and fixes only, revisits its design when somebody remembers to ask.

A count of the work done marks the second moment better than a date. A calendar chore is skipped
when the team is busy and pointless when it is idle. A count stays tied to the changes that caused
the drift.

The line that carries the count sits in the architecture overview. The revision corrects that
document anyway, and the overview is the one document that says how the system stands.

## Decision

We will revise the design of what recent work touched when a feature spec closes, and after a
number of changes without a spec.

1. **Closing a spec.** A feature spec closes only after a design revision. The revision runs once
   the spec's last ticket has merged.
2. **What a revision covers.** A fresh session runs the revision. It revisits these parts of what
   the work touched:
   - the modules;
   - the accepted ADRs that bind them;
   - the criteria of the specification they serve.
3. **What a revision files.** The revision files what it finds before it ends. It lists the
   backlog entries that touch the modules it revisits. The revision that closes a spec deletes the
   spec's `spec.md`.
4. **Due without a spec.** The revision also comes due on a count of changes, without a spec.
   `docs/ARCHITECTURE.md` carries the line that holds the count:
   `**Last design revision:** <YYYY-MM-DD [(<n>)] or none yet>, due after <N> changes.`
5. **Ordinal.** A second revision on one day writes its ordinal after the date, such as `(2)`. So
   its commit sets a line of its own to count from.
6. **Change.** A change is a commit that touches a path outside `docs/`. Merge commits do not
   count. The count starts at the commit that set the date of the line.
7. **Number.** The number of changes ships as 20. The project may set it on the line. The sensor
   must not hold the number.
8. **Reported, not enforced.** The count is reported. A due revision must not block a merge. Once
   the number is reached, a revision runs over the modules those changes touched. That revision
   moves the date of the line.

**Out of scope:**

- the order of work of a revision, which the `design-revision` skill carries;
- the form of a ticket a revision files, which
  [NUC-large-work-is-planned](NUC-large-work-is-planned.md) decides;
- a revision that the human asks for outside both triggers, which needs no rule.

## Latitude

A project may choose:

- the number of changes after which the revision is due, on the line of the overview (clause 7);
- revisions beyond the two triggers, whenever the human asks for one.

The catalogue has no entry for these choices, and none of them needs an ADR.

## Alternatives considered

- **A standing "improve the architecture" chore on a calendar.** Nothing ties it to the work that
  caused the entropy. A closing spec and a count of changes are both moments the touched modules
  are still known.
- **A failing check once the revision is due.** It blocks every merge until a session that ships
  no behaviour has run. This decision makes entropy visible, not impossible.
- **The number of changes inside the sensor.** The sensor belongs to the template and travels with
  it. How much drift a project tolerates belongs in the project's own document.
- **Counting lines changed rather than commits.** It is nearer to entropy and far noisier: a
  formatter run is thousands of lines and no structure at all.
- **A revision only when a spec closes.** A project in maintenance writes no specs and never
  revises.

## Sources / Prior art

- Matt Pocock, *improve-codebase-architecture* —
  <https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md>:
  the design revision at the close of a spec.
- Kent Beck, *Extreme Programming Explained*, quoted in the README of
  <https://github.com/mattpocock/skills>: "Invest in the design of the system every day."

## Consequences

- Positive: the design of what a feature touched is revisited while it is still known.
- Positive: the overview is checked against the tree at the same moment.
- Positive: a project that writes no specs revisits its design at a rhythm its own changes set.
- Positive: the tree answers when the design was last looked at.
- Negative: a feature spec stays open one session longer.
- Negative: the revision costs a session that ships no behaviour.
- Negative: the revision files tickets, and nothing obliges anyone to work them.
- Negative: a commit is a coarse measure of drift. A project that squashes reaches the number more
  slowly.
- Negative: the date moves by hand, in the revision's own change.

## Enforcement

`scripts/sensor-revision-due.sh`, in the job `sensors`, reads the `Last design revision` line of
the overview (clause 4). It counts the changes since the commit that set its date (clauses 5 and
6) and reports the count. Once the number is reached, it lists the top-level directories and files
the changes touched, with the changes each. It fails when the line is missing or unreadable,
because then it measures nothing. It never fails on the count (clause 8). Its self-test cites this
ADR.

**Not mechanically decidable:** the review holds these judgements:

- whether a spec was deleted without its design revision (clauses 1 and 3);
- whether a due revision ran at all, and moved the date (clause 8).
