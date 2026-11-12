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

**Landed for v0.10.0** (the human chose parts 1 to 3 for that minor on 2026-11-12):
`scripts/check-all.sh` names the time of each check, the slowest, and its own; the pull request
template carries `Measures: tokens <n> | checks <n> s | review rounds <n>`; and
`scripts/sensor-work-measures.sh`, run on a human's instruction, reports per merged pull request
the hours from the branch's first commit to its merge and the rounds of review, read through gh
from the Measures line or the `Reviewed at:` lines. A GitHub merge commit carries no description,
so git alone holds no round.

**Still open in the template:**

3. **Commits that were red alone.** The sensor does not report a commit of a branch on which the
   checks failed; finding one runs the checks on each commit, which costs a full run per commit.
4. **The design revision reads them.** The `design-revision` skill gains a section on what the
   work cost and what slowed it, from the measures and the sensor; it yields tickets of the project
   and findings about the template, kept apart.
5. **Findings go back to the template.** A finding about the template is written in the form of
   an issue template of hivevm/nuc. The human decides whether to send it: sending publishes it.
   Nothing reports back on its own. The template's own design revision reads the issues sent and
   cuts tickets for the next release. This is a process decision and needs an ADR of the base, such
   as `NUC-template-learns-from-projects`, proposed before the work and accepted by the human.

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

- [ ] Given a branch with a commit on which the checks fail and a later one on which they pass,
      when the work measures sensor runs, then it names the red commit; its self-test decides it.
- [ ] Given the `design-revision` skill, when it is read, then it has the section on cost and
      time and writes findings about the template apart from the project's tickets.
- [ ] Given the ADR on findings for the template, when the human has accepted it, then hivevm/nuc
      has the issue template it names, and no file of the template sends anything on its own.
- [ ] Given nuc-tools, when this ticket lands, then its ticket for the reader exists and names the
      `Measures:` form.
- [ ] Given the telemetry turned on, when a session runs, then the collector shows its tokens per
      call, and `CONTRIBUTING.md` says how to turn it on.

## Read first

- Touches: `scripts/sensor-work-measures.sh`, `scripts/test-sensor-work-measures.sh`,
  `.github/PULL_REQUEST_TEMPLATE.md`,
  `.agents/skills/design-revision/`, an issue template under `.github/ISSUE_TEMPLATE/`, a new
  `NUC-` ADR and `docs/adr/NUC.blobs`, `CONTRIBUTING.md`; outside the template, nuc-tools and
  the human's harness settings
- The measures of the v0.9.0 release notes, and ticket 18 for the times per platform

## Blocked by

- None (can start immediately); the parts 4 and 5 wait for the ADR's acceptance

## Mode

with the human: the ADR is the human's to accept, the telemetry runs on the human's machine, and
the reader's place is nuc-tools.
