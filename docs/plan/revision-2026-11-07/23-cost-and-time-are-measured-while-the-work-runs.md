# Ticket: Where the work spends tokens and time is measured, and projects report back to the template

## What to build

Nothing measures during the work where a session spends its tokens. The v0.9.0 work, read
afterwards from its transcripts, spent about 700 million tokens read from the prompt cache over
4,400 calls of the model, 60 % of them in subagents. The cost grew with the length of the context
times the number of calls, not with single tool outputs: the main session averaged 370,000 tokens
of context a call before its compaction, and one subagent of 198 calls read 63 million. What a
derived project learns about the template reaches it only by hand, through a take-up.

The template decides what is measured and where it goes; nuc-tools reads the harness; the human
sends what reaches the template. The template ships no toolchain and binds no harness, and only
the harness knows the tokens, so their reader lives outside it.

**Landed for v0.10.0** (the human chose parts 1 to 3 for that minor on 2026-11-12, the commits
red alone on 2026-11-13, and parts 4 and 5 once the human accepted
[NUC-template-learns-from-projects](../../adr/NUC-template-learns-from-projects.md) on 2026-11-14):
`scripts/check-all.sh` names the time of each check, the slowest, and its own; the pull request
template carries `Measures: tokens <n> | checks <n> s | review rounds <n>`; and
`scripts/sensor-work-measures.sh`, run on a human's instruction, reports per merged pull request
the hours from the branch's first commit to its merge and the rounds of review, read through gh
from the Measures line; more than one round is a review again after the fixes of its findings.
The `Reviewed at:` line counts none, since the review moves that one line after each round. A
GitHub merge commit carries no description, so git alone holds no round.
`scripts/sensor-red-commits.sh`, run on a human's instruction and without `gh`, names each
commit of the ten newest merges on which that commit's own `scripts/check-all.sh` failed, run in
a temporary worktree: a full run of the checks per commit, so only when asked.
Step 6 of the `design-revision` skill reads what the work cost and what slowed it, from the
Measures lines, the two sensors, and the times of `scripts/check-all.sh`. It keeps findings about
the template apart from the project's tickets, as drafts under `.scratch/`. A draft has the fields
of the issue template `.github/ISSUE_TEMPLATE/template-finding.md`. The skill lists the drafts for
the human, who alone sends one. In the template's own repository it lists the open findings as
candidates. The close of the setup deletes the issue template, and `docs/template-identity` fails
a project that still carries it. Case 5 of `scripts/test-template-setup.sh` holds the skill to
the fields of the form. The rule `docs/opens-no-issue` of
`scripts/check-docs.sh` holds that no file of the template opens an issue.

**In nuc-tools, filed there as a ticket of its own:**

6. **A reader of the harness**, such as `nuc measure`: it reads the transcripts or the
   OpenTelemetry of one harness through an adapter, Claude Code first, and lists per session, per
   subagent, and per tool call the context read, the context written, and the output, the costliest
   subagents, and the largest tool outputs. It prints the template's `Measures:` form, and on
   request a summary across the projects on one machine and a cleaned draft of a finding for the
   template.

**In the human's environment, in neither repository:**

7. **Live telemetry.** Claude Code exports tokens and cost per session, model, and call through
   OpenTelemetry to a collector the human runs; `CONTRIBUTING.md` says how a contributor turns it
   on, as one harness's example.

## Acceptance criteria

- [x] Given the `design-revision` skill, when it is read, then it has the section on cost and
      time and writes findings about the template apart from the project's tickets.
- [x] Given the ADR on findings for the template, when the human has accepted it, then hivevm/nuc
      has the issue template it names, the `design-revision` skill carries its fields, the setup
      deletes it from a derived project and `docs/template-identity` checks that, and no file of
      the template sends anything on its own.
- [ ] Given nuc-tools, when this ticket lands, then its ticket for the reader exists and names the
      `Measures:` form.
- [ ] Given the telemetry turned on, when a session runs, then the collector shows its tokens per
      call, and `CONTRIBUTING.md` says how to turn it on.

## Read first

- Touches: `CONTRIBUTING.md`; outside the template, nuc-tools and the human's harness settings
- The measures of the v0.9.0 release notes, and ticket 18 for the times per platform

## Blocked by

- None (can start immediately)

## Mode

with the human: the telemetry runs on the human's machine, and the reader's place is nuc-tools.
