# NUC-large-work-is-planned: Work larger than one session is planned as a feature spec cut into tracer-bullet tickets, and findings outside the plan go to a backlog

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** every change larger than one agent session, `docs/plan/`, the spec and ticket templates of the `plan-feature` skill, the `work-tickets` skill and its claim script `.agents/skills/work-tickets/claim.sh`, `scripts/sensor-plan-frontier.sh`, the pull request template, `docs/backlog/`, and `scripts/sensor-backlog.sh`

## Context

Authority runs from the specification to the accepted ADRs to the task
([NUC-adrs-record-decisions §7](NUC-adrs-record-decisions.md)). Nothing in that chain says what
this month's work is. A change that fits one session is planned in the conversation. A change
that does not has no place to keep its state: each session starts without memory, re-derives the
plan, and drifts. The rule to cut work into vertical slices
([`AGENTS.md` §4](../../AGENTS.md#4-working-style)) has no artifact that carries a slice, and the
conditions for unattended work have nothing to be written in.

Most work in a system that already exists is change, not addition. A plan written from the
user's side alone says nothing about what the system does today and what must stay. A session
without memory gets that part wrong first.

The artifact cannot live in the specification, which must not churn. It must be disposable,
because a plan that outlives its use is noise for every later session. Any agent must read it
with the tools it already has, without one vendor's tracker or an account on it.

Sessions that run in parallel need to know which tickets another session already works. Findings
that no ticket covers need a place too, or they stay in a conversation or widen the ticket that
found them.

A derived project may already plan in the issues of its host. There the tracker already gives
assignment, sub-issues, and an open list, and a second plan in the tree would split the record.

## Decision

We will plan each change larger than one session as a feature spec cut into tickets, and record
findings outside the plan in a backlog.

1. **Threshold.** A change larger than one agent session must be planned before its first slice.
   The plan is a feature spec cut into tracer-bullet tickets.
2. **Place.** The plan lies in the tree under `docs/plan/`, unless the project plans in issues
   (clause 11).
   - Each feature spec is a directory `docs/plan/<spec>/` with the file `spec.md`.
   - Each ticket is a file `<NN>-<slug>.md` in that directory. `NN` numbers the tickets in the
     order they are cut.
   - A ticket filed outside a spec lies in a directory of its own without `spec.md`. A design
     revision files such tickets, and so does a session that leaves work unfinished.
   - A directory without files is gone. So `docs/plan/` holds exactly the open work.
3. **Feature spec.** A feature spec states these parts:
   - the problem and the solution, from the user's side;
   - the existing behaviour it changes, and what must stay as it is;
   - the goals of the specification it serves, by identifier;
   - the user stories;
   - the implementation decisions, and the seams at which the change is tested;
   - what is out of scope;
   - whether it needs an ADR.

   A feature spec names no file path and no code.
4. **Ticket.** A ticket states these parts:
   - the end-to-end behaviour it delivers;
   - its acceptance criteria;
   - the tickets that block it;
   - what the session that works it reads first;
   - its *Mode*: worked with the human, or unattended with the stop of its session.

   A ticket is sized to one fresh session. It is demoable or verifiable on its own. It names each
   blocker by its path under `docs/plan/`, as text and not as a link. A blocker is closed once its
   file is gone.
5. **Frontier.** The frontier is the set of open tickets whose blockers are all closed and that no
   session claims. An agent must pick a ticket from the frontier. A ticket is claimable once it is
   on `main`.
6. **Claim.** An agent must claim a ticket before any work on it. The claim is the branch
   `ticket/<spec>/<NN>-<slug>`. A claim must be visible to every session that may work in
   parallel. A session releases a claim it gives up. The `work-tickets` skill carries the steps of
   a claim and of its release.
7. **Disposal.** The branch that lands a ticket's work must delete the ticket's file. The design
   revision deletes the `spec.md` of the spec it closes
   ([NUC-design-is-revised](NUC-design-is-revised.md)). Before a file goes, what must last moves
   into the specification, an ADR, the architecture overview, the glossary, or the conventions.
8. **Finding.** A finding is a defect, a doubt, or an idea that no ticket covers. A session that
   makes one must record it in the backlog. It must not widen its ticket for it.
9. **Backlog.** A project records the form of its backlog in an ADR of its own. Without that ADR,
   the backlog is files.
   - **Files:** each entry is one file under `docs/backlog/`. An entry holds a title, what was
     observed, and where. A session creates an entry in a commit of its own.
   - **Issues:** each entry is an issue of the host's tracker.
10. **Triage.** Only the human decides which backlog entry becomes a ticket. The commit that
    creates a ticket from an entry must delete the entry.
11. **Plan in issues.** A project may plan in the issues of its host instead of the tree. Its
    harness ADR records that choice. Then these rules hold:
    - Each feature spec and each ticket is an issue with the parts of clauses 3 and 4.
    - A ticket names its blockers as issues of the host.
    - Closing an issue takes the place of deleting its file.
    - The assignment of a ticket's issue is its claim, in place of the branch of clause 6.
    - The host's list of open, unblocked, unassigned ticket issues is the frontier. It replaces
      the frontier sensor.

**Out of scope:**

- how work smaller than one session is planned;
- an artifact for an effort too foggy to be written as a spec;
- how a finding is triaged beyond the decision whether it becomes a ticket;
- the design revision that closes a spec, which
  [NUC-design-is-revised](NUC-design-is-revised.md) decides;
- the order of work of planning and of working tickets, which the skills `plan-feature` and
  `work-tickets` carry;
- the push that makes a claim on a remote and its exception from the pre-push hook, which belong to
  the integration rules of `NUC-main-only-via-pr`;
- the isolation of parallel sessions, their number, and what never runs unattended, which the
  harness ADR decides ([NUC-adrs-record-decisions §13](NUC-adrs-record-decisions.md)).

## Latitude

A project may choose:

- the form of its backlog, files or the host's issues, from the
  [backlog entry](../../.agents/skills/propose-adr/concepts/backlog.md) of the catalogue;
- to plan in the issues of its host (clause 11), recorded in its harness ADR from the
  [harness entry](../../.agents/skills/propose-adr/concepts/harness.md) of the catalogue;
- how a claim is made among sessions that share neither a repository nor a remote, in the same
  harness ADR.

## Alternatives considered

- **Plan in the conversation.** The plan lives in a context window that is gone by the next
  session.
- **The host's issue tracker for every project.** It closes itself and carries assignment and
  sub-issues. An agent needs its interface and an account to read the plan. The plan is out of
  reach offline and of review with the code, and a project that moves host loses it.
- **Plan in issues forbidden.** A project that already plans in its tracker would keep two plans,
  or break the ADR. The latitude lets it keep its tracker. It gives up what the tree gives:
  offline reading, review with the code, and a frontier sensor in CI.
- **A long-lived document per feature under `docs/`.** Every later session reads it, true or not.
  Nobody deletes a document that no step of the process deletes.
- **A ticket marked done rather than deleted.** Closed work stays in front of every session that
  lists the directory. The history already keeps it.
- **A planning tool's own format, such as git-bug or Backlog.md.** One more tool in the
  environment. Plain Markdown files need none.
- **Tickets only, no spec.** Slices without the destination they serve: nothing says when the
  feature is done or which goal it meets.
- **A decision map while the way is unclear.** A map names the destination, with one decision
  ticket per question that can be stated now, resolved one per session. No project has needed one
  yet, and an artifact nobody needs is ceremony every reader pays for. It returns when one does.
- **Plan the whole effort upfront as tickets.** It slices what the first answer will change.
- **A process-owning framework or skills plugin.** It brings artifacts and a pipeline in one
  piece, in one vendor's format.
- **A change spec of its own for work on what exists.** One more artifact for the common case. The
  two questions, what changes and what stays, fit as a section of the feature spec.
- **The claim steps in this ADR, as before.** Every reader of a plan file paid for a page of push
  mechanics that only the dispatching session runs. The skill carries them; the ADR keeps the rule.
- **Findings in the conversation or an agent's memory.** Lost with the session, and read by one
  agent only.
- **The backlog as one file, or under `docs/plan/`.** One file conflicts on every merge of two
  branches that each add an entry. Under the plan, the frontier would read each entry as a ticket.

## Sources / Prior art

The shape follows Matt Pocock's skills — <https://github.com/mattpocock/skills>:

- *to-spec* — <https://www.aihero.dev/skills-to-spec>: the spec as a tracker issue, disposable
  once the work ships; here a file the work deletes, or an issue it closes.
- *to-tickets* —
  <https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md>:
  tracer-bullet vertical slices sized to one fresh context window, blocking edges, "what to
  build" from the user's side, no file paths because they go stale.
- *wayfinder* —
  <https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md>: the
  decision map under Alternatives.
- *Tracer bullets* — <https://www.aihero.dev/tracer-bullets>: why the first slice through new
  ground goes end to end.

Addy Osmani, *Agentic autonomy levels* — <https://addyosmani.com/blog/agentic-autonomy-levels/>:
the questions a ticket answers before it runs unattended, and its stopping condition. *Loop
engineering* — <https://addyosmani.com/blog/loop-engineering/>: why the stop is written on the
ticket rather than judged by the session that is stopping.

towncrier, *news fragments* — <https://towncrier.readthedocs.io/>: one file per entry, so that
parallel branches never conflict; the file form of the backlog borrows it.

## Consequences

- Positive: the slicing rule has a carrier. A session reads the plan instead of re-deriving it.
- Positive: in the tree, the plan is reviewed with the code, works offline, and moves with the
  repository. The history keeps every deleted file at no cost.
- Positive: the ticket answers whether it may run unattended and when it stops.
- Positive: what the system does today is written down before it is changed.
- Positive: a project that plans in issues keeps its tracker and still follows this ADR.
- Negative: a feature costs a spec and its tickets before the first slice. The threshold is a
  judgement under the proportionality principle ([`AGENTS.md` §1](../../AGENTS.md#1-principles)).
- Negative: an effort whose questions cannot all be asked at once has no artifact of its own.
- Negative: a plan lands on `main` like any change, so a ticket is claimable only once merged.
- Negative: a ticket file whose deletion a branch forgot stays open until review notices.
- Negative: with issues, the plan needs the host's interface and an account, and no sensor in the
  tree reads it.
- Follow-ups: the decision map, once an effort too foggy to slice has been met; triage of findings
  beyond the decision whether each becomes a ticket.

## Enforcement

- `scripts/sensor-plan-frontier.sh`, in the job `sensors`, lists the open tickets as claimed,
  blocked, or on the frontier, each with its *Mode* (clauses 4 and 5). It fails on a ticket
  without a *Blocked by* or a *Mode* section. Its self-test cites this ADR. It runs the claim
  script in one repository and across two clones of one remote, and the second claim must lose
  (clause 6).
- `scripts/sensor-backlog.sh`, in the same job, lists the backlog entries on `main` and those only
  on unmerged local branches (clause 9). It fails nothing. Its self-test cites this ADR.
- The templates of the `plan-feature` skill carry the parts of a spec and a ticket (clauses 3 and
  4).

**Not mechanically decidable:** the review holds these judgements:

- whether an effort was larger than one session, and so had to be planned (clause 1);
- whether a finding went to the backlog rather than into a ticket (clause 8);
- whether the branch that landed a ticket's work deleted its file (clause 7);
- with a plan in issues, whether the issues carry the parts and the claims (clause 11), since no
  sensor in the tree reads them.
