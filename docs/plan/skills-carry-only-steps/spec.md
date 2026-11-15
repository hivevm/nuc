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

- A maintainer of a derived project takes up a release through a skill named for it. Normalize
  carries normalization and adoption only.
- The design revision asks the backlog sensor which entries are stale and proposes those. It
  computes no dates by hand.
- Every sentence of a skill that reads as a rule either cites the clause that carries it, or
  is restated as a step. A rule that stood nowhere else gains its clause in an ADR or AGENTS.md
  first.
- A change that adds a sentence over 25 words to a skill sees it in the plain rules sensor's
  report, as a hint that never fails.

## Existing behaviour

- **Normalize** carries the take-up in its section 7 and in the entry points of its section 1.
  NUC-procedures-are-skills §1 names the skills and says normalize carries the take-up.
  NUC-releases-are-semver-tags names the take-up's order of work as a procedure of normalize.
  The setup walk and the setup file point an existing project at normalize for its adoption,
  and that pointer stays. The pointer tests of the documentation check pin that every skill has
  its pointer and front matter.
- **The backlog sensor** lists the entries on main and those a local branch adds. Its self-test
  and fixture table pin that behaviour, which must stay. A stale entry is defined by
  NUC-design-is-revised §6. The sensor does not report it today.
- **The design revision's step 7** computes staleness from the history of the backlog files and
  of the `Last design revision` line. Its self-tests pin the revision-due count, not the
  staleness.
- **The plain rules sensor** reads AGENTS.md and the Decision and Enforcement of an ADR. Its
  self-test and fixture table pin what it reports on those, which must stay. With `--require`
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
5. As an agent following a skill, I want every rule-like sentence to cite its clause, so that I
   know whether it binds me or only orders my steps.
6. As a reviewer, I want a rule that stood only in a skill moved into an ADR or AGENTS.md, so
   that the rule file stays the one place rules live.
7. As an author of a skill, I want the plain rules sensor to show me a sentence over 25 words I
   add, so that the skills stay as readable as v0.11.1 left them.
8. As a maintainer of a derived project, I want that hint never to fail a check, so that a long
   sentence in my own skill does not block my merge.

## Implementation decisions

- **Take-up skill.** The take-up moves out of normalize into a skill of its own, with its pointer.
  Normalize keeps normalization and adoption. Its entry point for a release names the new skill.
  The correction of NUC-procedures-are-skills §1 and of the take-up's place in
  NUC-releases-are-semver-tags is proposed in a commit of ADRs only and reviewed by the human
  before the skill moves. The template corrects its own `NUC-` ADRs in place
  (NUC-decisions-are-proposed-then-accepted §6). A derived project takes up the new skill with
  the release.
- **Stale entries.** The backlog sensor gains a mode that names the stale entries by the
  definition of NUC-design-is-revised §6. It reads the dates of the `Last design revision` line
  from the history of the architecture overview. A date with an ordinal counts on its own. The
  design revision's step 7 runs it instead of its git commands. The sensor still reports and
  never fails.
- **Rules out of the skills.** First an inventory of every sentence in the skills that reads as
  a duty or a prohibition, each with the clause that carries it or "none". Each with a clause
  gets the citation. Each with none is decided with the human: a clause of an ADR or a line of
  AGENTS.md, proposed in a commit of ADRs only, or restated as a step. AGENTS.md and the `NUC-`
  files change only with their blob list, in the same commit.
- **Sentence hint.** The plain rules sensor also reads the skills, for sentences over 25 words on
  added lines only, reported under a key of its own. `--require` does not fail on it. Soft modal
  verbs and avoided words in skills are out of this hint.
- **Way of working (the human's decision).** The plan lives on `feat/v0.12.0` and never reaches
  `main`, because plan files would otherwise ship with the template to derived projects. That
  deviates from NUC-large-work-is-planned §4, whose frontier is read on `main`. The tickets are
  therefore worked one after another, each in a session the human sits in, each on a branch cut
  from `feat/v0.12.0`, without `claim.sh` and without parallel agents. A reviewed branch is
  rebased onto `feat/v0.12.0` as the Integration branches of CONTRIBUTING.md say. Every hand-off
  names this deviation. Before the pull request into `main`, every ticket file and this spec are
  gone: each ticket's branch deletes its file, and the design revision deletes this spec.

## Testing decisions

- Take-up skill: the documentation check's pointer and front-matter cases, and its link and
  section-reference checks, which find a dangling pointer to the old section. No new test: a
  skill is prose.
- Stale entries: the backlog sensor's fixture table and self-test gain the cases of
  NUC-design-is-revised §6. These cover an entry older than two dates, one older than one, a date
  with an ordinal, fewer than two dates, and an entry a ticket was made from. The fixtures are
  built in the self-test's own repositories, as the conventions ask.
- Rules out of the skills: a clause that a check can decide gets its test with a `Verifies:`
  marker. Otherwise its Enforcement says it is not mechanically decidable.
- Sentence hint: the plain rules sensor's fixture table gains cases for a long sentence added to
  a skill, a long one left unchanged, and `--require` passing on a skill with a long sentence.

## Out of scope

- Splitting or merging any other skill.
- Moving the template-finding form out of design-revision step 6, which its setup self-test reads
  there.
- Merging the three paragraphs on planning in issues that plan-feature, work-tickets, and
  design-revision each carry.
- Soft modal verbs and avoided words in skills.
- A check that holds script comments to 100 columns.
- The merge of NUC-base-is-fixed and NUC-releases-are-semver-tags, discussed but not decided.

## ADR impact

The ADRs in force that bind this work:

- NUC-procedures-are-skills §1, corrected in place: it names the take-up skill.
- NUC-releases-are-semver-tags, corrected in place where it names normalize as the take-up's
  place.
- NUC-design-is-revised §6, which defines a stale entry. It is unchanged, and the sensor
  implements it.
- NUC-checks-are-bash, for the sensor changes.
- NUC-documents-are-fixed §3 and §5, for the rule file and the plain rules sensor.
- NUC-large-work-is-planned §4, from which this plan deviates as the human decided (see
  Implementation decisions).
- NUC-decisions-are-proposed-then-accepted §3 and §4: each correction is proposed in a commit of
  ADRs only and reviewed before its implementation.

Proposed ADR changes before implementation: the correction for the take-up skill (ticket 01), and
any clause the inventory of rules finds missing (ticket 04).
