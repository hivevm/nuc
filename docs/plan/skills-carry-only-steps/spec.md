# Spec: The skills carry only steps, and a release's take-up is a skill of its own

## Problem

The readability pass of v0.11.1 left four things in the skills that a patch could not change:

- The take-up of a template release is the most frequent of three procedures inside the
  normalize skill. That skill's description says it runs only on a human's instruction to
  normalize, and its own text says a take-up is no normalization. A maintainer of a derived
  project who wants to take up a release has to find the procedure in section 7 of a skill named
  for something else.
- The design revision describes in prose, with git commands, when a backlog entry is stale. An
  agent works the dates out by hand on every revision, and nothing checks that it does so alike
  each time.
- A few sentences of the skills read as rules that stand nowhere else: what a reviewer declines,
  that a ticket "with the human" is never dispatched, and why a claim pushes an empty commit. A
  skill must state no rule of its own, so such a sentence is either a rule in the wrong place or
  a step that only reads like one.
- Nothing stops the nested, long sentences from coming back into the skills. The plain rules
  sensor reads the rules only, not the skills.

## Solution

Once this is done:

- A maintainer of a derived project takes up a release through the skill `take-up-release`.
  Normalize carries normalization and adoption only.
- The design revision of a project whose backlog is files asks the backlog sensor which entries
  are stale, and proposes those. A project whose backlog is the host's issues keeps the steps it
  has today.
- Every sentence of a skill or of its reference files that reads as a rule either cites the
  clause that carries it, or is restated as a step. A rule that stood nowhere else gains its
  clause in an ADR or the rule file first.
- A change that adds a sentence over 25 words to a skill sees it in the plain rules sensor's
  report, as a hint that never fails.

## Existing behaviour

- **Normalize** carries the take-up in its section 7, in its description, and in its section 1:
  the entry point for a release and the part on hooks and repository settings, which adoption
  uses too. NUC-procedures-are-skills §1 names the skills and says normalize carries the take-up.
  NUC-releases-are-semver-tags names the take-up's order of work as a procedure of normalize.
  The setup walk and the setup file point an existing project at normalize for its adoption,
  and that pointer stays. The documentation check pins that every skill has its pointer and its
  front matter.
- **The backlog sensor** lists the entries on main and those a local branch adds, and reports
  nothing for a project whose backlog is the host's issues. Its self-test pins that behaviour,
  which must stay. It has no fixture table. A stale entry is defined by NUC-design-is-revised §6,
  and the sensor does not report it today.
- **The design revision's step 7** computes staleness from the history of the backlog files and
  of the `Last design revision` line, or from the date the host shows for an issue. The date of
  the line is the date written in it, not the date of a commit that edits it. Its self-tests pin
  the revision-due count, not the staleness.
- **The plain rules sensor** reads the lines a change adds to the rule file and to the Decision
  and Enforcement of an ADR, as the Enforcement of NUC-documents-are-fixed says. Its reader of the
  rules admits only those files and counts every line it streams for soft modal verbs and avoided
  words. Its self-test and fixture table pin what it reports, which must stay. With `--require`
  it fails on a soft modal verb or an avoided word in a project ADR. A hint on a skill must not
  change what `--require` fails on.

## Goals served

The template's own specification is a scaffold with no goals filled in, so this work serves no
`G-n` or `Q-n` by identifier. It serves the template's rules:

- NUC-procedures-are-skills §3: a skill carries the steps of one procedure and states no rule;
- [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done):
  a mistake that a check would have caught becomes a check; a rule in prose is the fallback for
  what no check can decide.

## User stories

1. As a maintainer of a derived project, I want a skill named for taking up a release, so that I
   find the procedure without reading the normalize skill.
2. As a maintainer, I want normalize to carry normalization and adoption only, so that its
   description says when it runs and nothing else hides in it.
3. As an agent running a design revision, I want the backlog sensor to name the stale entries,
   so that I propose the same entries a second revision would.
4. As a human deciding which backlog entries to delete, I want each stale entry listed with the
   date it was added and the two revision dates it predates, so that I can check the proposal.
5. As a maintainer whose backlog is the host's issues, I want the design revision to keep its
   steps for issues, so that the sensor's mode for files takes nothing from me.
6. As an agent following a skill, I want every rule-like sentence to cite its clause, so that I
   know whether it binds me or only orders my steps.
7. As a reviewer, I want a rule that stood only in a skill moved into an ADR or the rule file, so
   that the rule file stays the one place rules live.
8. As an author of a skill, I want the plain rules sensor to show me a sentence over 25 words I
   add, so that the skills stay as readable as v0.11.1 left them.
9. As a maintainer of a derived project, I want that hint never to fail a check, so that a long
   sentence in my own skill does not block my merge.

## Implementation decisions

- **Take-up skill.** The take-up moves out of normalize into the skill `take-up-release`, with its
  pointer. Normalize keeps normalization and adoption, and its entry point for a release names the
  new skill. The part of normalize's section 1 on hooks and repository settings serves both: the
  take-up skill carries what a take-up needs, and normalize keeps what adoption needs. The rule
  file gains no line for the new skill: it names no step of a take-up, so
  NUC-procedures-are-skills §4 asks for none. A derived project takes up the new skill and its
  pointer with the release.
- **Stale entries.** The backlog sensor gains a mode that names the stale entries of a backlog of
  files, by the definition of NUC-design-is-revised §6. It reads the dates of the
  `Last design revision` line from the history of the architecture overview on main. A date
  counts when the line's text changes it, and a date with an ordinal counts on its own. An edit
  that keeps the date adds none. The design revision's step 7 runs the mode for a backlog of
  files and keeps its steps for a backlog of issues. The sensor still reports and never fails.
  The new mode's cases go into a fixture table its self-test reads.
- **Sentence hint.** The plain rules sensor also reads the skills, for sentences over 25 words on
  added lines only, reported under a key of its own. `--require` does not fail on it. Soft modal
  verbs and avoided words in skills are out of this hint. The reader of the rules keeps what it
  streams for the rules.
- **Rules out of the skills.** First an inventory of every sentence in the skills and their
  reference files that reads as a duty, a prohibition, or an imperative that binds beyond the
  procedure's own order. Each sentence gets the clause that carries it, or "none". Each with a
  clause gets the citation. Each "none" is decided with the human: a clause of an ADR or a line
  of the rule file, or a restatement as a step. The inventory is written into the ticket that
  applies it.
- **ADR corrections.** The template corrects its own `NUC-` ADRs in place
  (NUC-decisions-are-proposed-then-accepted §6). Each correction is the first commit of its
  ticket, a commit of ADRs only with the blob list. The human reviews it in the session before the
  ticket implements against it (NUC-decisions-are-proposed-then-accepted §4).
- **Way of working (the human's decision).** The plan lives on `feat/v0.12.0` and never reaches
  `main`, because plan files would otherwise ship with the template to derived projects. That
  deviates from NUC-large-work-is-planned §4, whose frontier is read on `main`. The tickets are
  therefore worked one after another, each in a session the human sits in, each on a branch cut
  from `feat/v0.12.0`, without the claim script and without parallel agents. A reviewed branch is
  rebased onto `feat/v0.12.0` as the Integration branches of CONTRIBUTING.md say. Every hand-off
  names this deviation, and fills *A derived project acts on*.
- **Closing the plan.** After the last ticket, the design revision runs on `feat/v0.12.0` and
  deletes this spec. Each ticket it files is worked on `feat/v0.12.0` before the pull request
  into `main`, or the human drops it. The rebuild by topic, step 7 of the Integration branches,
  drops the commits that only add or delete plan files, so no plan file reaches `main` or its
  history.

## Testing decisions

- Take-up skill: the documentation check's pointer and front-matter cases, and its link and
  section-reference checks, which find a dangling pointer to the old section. No new test: a
  skill is prose.
- Stale entries: a fixture table for the new mode, read by the backlog sensor's self-test. It
  holds an entry older than two dates, one older than one, a date with an ordinal, an edit of the
  line that keeps its date, fewer than two dates, `none yet`, and an entry deleted after it went
  stale. The fixtures are built in the self-test's own repositories, as the conventions ask.
- Sentence hint: the plain rules sensor's fixture table gains cases for a long sentence added to
  a skill, a long one left unchanged, a soft modal verb added to a skill, and `--require` passing
  on a skill with a long sentence.
- Rules out of the skills: a clause that a check can decide gets its test with a `Verifies:`
  marker. Otherwise its Enforcement says it is not mechanically decidable.

## Out of scope

- Splitting or merging any other skill.
- Moving the template-finding form out of design-revision step 6, which its setup self-test reads
  there.
- Merging the three paragraphs on planning in issues that plan-feature, work-tickets, and
  design-revision each carry.
- Stale entries of a backlog kept in the host's issues.
- Soft modal verbs and avoided words in skills.
- A check that holds script comments to 100 columns.
- The merge of NUC-base-is-fixed and NUC-releases-are-semver-tags, discussed but not decided.
- A correction of NUC-large-work-is-planned §4 for plans kept off `main`.

## ADR impact

The ADRs in force that bind this work:

- NUC-procedures-are-skills §1, corrected in place by ticket 01: it names `take-up-release`.
- NUC-releases-are-semver-tags, corrected in place by ticket 01 where it names normalize as the
  take-up's place.
- NUC-documents-are-fixed, its Enforcement corrected in place by ticket 03: the plain rules
  sensor also reads the skills, for long sentences only, and fails nothing on them.
- NUC-design-is-revised §6, which defines a stale entry. It is unchanged, and the sensor
  implements it.
- NUC-checks-are-bash, for the sensor changes.
- NUC-documents-are-fixed §3, for the rule file, and any clause the inventory of ticket 04 finds
  missing.
- NUC-large-work-is-planned §4, from which this plan deviates as the human decided (see
  Implementation decisions). NUC-decisions-are-proposed-then-accepted §5 lets nobody work around
  an accepted ADR; the human holds the deviation as acceptable for this plan instead of
  correcting NUC-large-work-is-planned §4.
- NUC-decisions-are-proposed-then-accepted §3, §4, and §6: each correction is proposed in a commit
  of ADRs only and reviewed before its implementation.
