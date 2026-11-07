# Spec: Plain rules and a backlog

## Problem

A session reads the rules of a project before it works. It meets long sentences, the passive
voice, and several words for one thing. It must guess who acts, and whether two words name two
things. The glossary lists the synonyms to avoid, but only a reviewer notices one in use.

A session finds things outside its ticket: a defect, a doubt, an idea. It has no place to put
them. The finding stays in the conversation or in the agent's memory, and it is lost with them.
The feature layer leaves reports out of its scope, so no rule says where they go.

The scripts read ADR identifiers and ADR headers through a shared library, but some still match
file names and header lines on their own. A change to the form of an identifier must find each
of these places.

## Solution

- The rule file says how a rule is written: one statement per sentence, active, with a subject,
  in the terms of the glossary, as a list where there are several items. A sensor reports long
  sentences and soft modal verbs in the rules. The review asks for one statement per sentence.
- A check refuses a word the glossary lists under _Avoid:_ on the lines a change adds to the
  rules. A project turns the check on by filling _Avoid:_.
- A project records where findings outside the plan go: one file per finding in the tree, or the
  issue tracker of its host. A catalogue entry describes both forms. A sensor lists the file
  entries on `main` and on the local branches that are not merged yet. A finding outside the
  scope of a ticket becomes a backlog entry, not a larger ticket.
- Every script reads ADR identifiers and ADR headers through the shared library only.

## Existing behaviour

- The shared ADR library holds the identifier pattern, the header fields, the list of ADR files,
  and the key of a file. The documentation check, the traceability check, the binding sensor, and
  the numbering script use it. The documentation check, the binding sensor, and the review-binding
  sensor still match ADR file names and header lines on their own, in about a dozen places. Their
  self-tests pin what they decide. These self-tests pass unchanged after the refactor.
- ADR-0001 has each glossary entry list the synonyms it displaces under _Avoid:_. Whether the
  terms in use are the glossary's is review only.
- ADR-0006 leaves the receiving and triage of reports out of its scope, and names it a follow-up.
- A derived project that takes up the release sees no new failure: the synonym check reads only
  added lines and finds nothing while _Avoid:_ is empty, the sensors fail nothing, and the backlog
  is a choice the project records.

## Goals served

None by identifier. The specification of the template repository is the scaffold that a derived
project fills. This work maintains the template, and it ships as the minor release `v0.8.0`
under ADR-0005: it adds a check, two sensors, and a catalogue entry.

## User stories

1. As a session that reads a rule, I want one statement per sentence with a named actor, so that
   I know who acts and can bind each statement to a test.
2. As a maintainer, I want a check to refuse a displaced synonym in a new rule, so that the
   glossary governs the words without a reviewer having to notice each one.
3. As a maintainer of a derived project, I want the synonym check to stay silent until I fill
   _Avoid:_, so that taking up the release breaks nothing.
4. As a reviewer, I want a sensor to list long sentences and soft modal verbs in the rules a change
   touches, so that I judge them without counting words.
5. As a session that finds something outside its ticket, I want one place to record it, so that
   the finding outlives the session and the ticket keeps its scope.
6. As a session in a parallel worktree, I want to see the backlog entries of branches not yet
   merged, so that I do not record a finding twice.
7. As a maintainer, I want the backlog to cause no merge conflicts between parallel branches, so
   that recording a finding costs nothing at merge.
8. As a maintainer whose reports arrive from outside, I want the backlog to be the issue tracker of
   my host, so that there is one place, not two.
9. As the maintainer of the template, I want every script to read an ADR identifier through one
   function, so that the next change to the form of an identifier touches one place.

## Implementation decisions

- **Shared parsing.** The remaining matches of ADR file names, identifiers, and header lines move
  into the shared ADR library. Nothing that a script decides changes. The lines of the scripts
  fall in total.
- **Where the writing rule lives.** In the rule file, as a working-style rule, because ADR-0001
  allows a rule nowhere else. The ADR README and the review skill point at it and restate nothing.
- **What the writing rule covers.** The rules of the rule file, and the *Decision* and
  *Enforcement* sections of an ADR. Context, alternatives, and sources stay free prose.
- **Sensor for sentences.** It reports a sentence over 25 words and the modal verbs *should*,
  *could*, *might*, and *ideally* in the sections the writing rule covers, on the lines a change
  adds. It reads the sections the way the binding sensor extracts them. It fails nothing.
  Code spans, links, and block quotes do not count.
- **Synonym check.** It reads the _Avoid:_ list of each glossary entry and refuses a listed word on
  a line that a change adds to the sections the writing rule covers. It compares whole words, case
  insensitive. It cites ADR-0001, whose *Enforcement* section moves this one part from review to
  the check.
- **Modal verbs stay a sensor in this release.** As a check they would fail a derived project on
  its next rule written with *should*. That would be a breaking change, and the release is a minor.
- **Backlog forms.** A file per entry under a backlog directory beside the plan, not inside it: the
  frontier sensor reads every file under the plan as a ticket. Or the issue tracker of the host. A
  project records its form in an ADR of its own. An entry holds a title, what was observed, and
  where. It holds no history.
- **Backlog entry in its own commit.** A branch that is discarded can then hand its entries to
  another by cherry-pick.
- **Backlog sensor.** It lists the entries on `main` and those that exist only on unmerged local
  branches, from the history of the backlog directory. It fails nothing.
- **From backlog to plan.** The human decides. The design revision lists entries that touch the
  modules it revisits. The commit that creates a ticket from an entry deletes the entry.
- **Out-of-scope findings.** The rule file gains one rule: a finding outside the scope of the
  current ticket becomes a backlog entry, not a larger change.

## Testing decisions

- Each script keeps its self-test under the selftest library, as the existing sensors do. The new
  check and the new sensors get one each, with fixture repositories built in the test.
- The new check and the sensor for sentences take a table of cases: an input tree and the expected
  output. The table is the contract a later port of the checks implements against.
- The refactor is tested by the existing self-tests, unchanged. A self-test that must change to
  pass means the refactor changed behaviour.

## Out of scope

- The identifier scheme of category and slug, the fixed NUC base, and the re-cut of the NUC ADRs.
  They are the next release.
- Rewriting existing rules in the new style. Only new and changed lines follow it now.
- Modal verbs as a check.
- A check that a finding was recorded. No script can decide it.
- A project-size profile.
- Triage of reports beyond recording them.

## ADR impact

Binding: ADR-0001 (documents, glossary, the binding sensor), ADR-0002 (every check cites its
decision), ADR-0003 (the review skill points and states no rule), ADR-0005 (a minor release),
ADR-0006 (the plan and its sensors).

No new ADR. Two ADRs are corrected in place, as the template repository corrects its own
(ADR-0005), each in a commit of ADRs only that the human reviews before the implementation
([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 and 4):

- ADR-0001: its *Enforcement* section names the synonym check and drops the glossary terms from
  what is review only.
- ADR-0006: the receiving of findings moves from *Out of scope* into the decision, with the two
  forms of the backlog as the project's choice; triage stays out of scope.
