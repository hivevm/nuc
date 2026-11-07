# Spec: The template's ADRs become a fixed base, cut one decision each, under stable identifiers

## Problem

A derived project inherits six ADRs that each carry several decisions: ADR-0001 alone decides the
document set, the rule file, the glossary, and how the record is read, and ADR-0006 decides
planning, the backlog, and the design revision at once. A session that touches one of these topics
reads all of its ADR. The binding sensor prints about 3,000 words for a change to the docs check and
about 1,600 for a plan file.

A derived project edits the inherited ADRs in place: it adds its decider and sometimes a clause. So
a take-up of a release cannot replace the files. It merges them by hand through a normalization, and
a check on the template's text fails on the project's edits. The backlog entry "avoided terms become
a check" shows this: a check on avoided words cannot spare the template's files, because the project
owns them after the edit.

ADR identifiers are numbers. A number says nothing about its topic, a draft takes its number only on
the way to `main`, and a normalization renumbers everything that is cited outside the tree. The
template and every derived project carry a numbering script, a check against drafts on `main`, and a
remap step for each normalization.

The rules of the record and of integration stand in [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules)
and [§6](../../../AGENTS.md#6-project-rules) and in no ADR. So no sensor routes a change to them,
and a derived project cannot narrow them in a record.

## Solution

The template ships ten ADRs with the prefix `NUC-`, one decision each, as a fixed base. A derived
project never edits or supersedes them. It extends or narrows one in an ADR of its own, which names
the clause. A project that must contradict one forks the template. A take-up of a release replaces
the `NUC-` files and runs the checks; a list of blob identifiers holds the files against the
release.

Every ADR is identified by a category key and a slug, such as `SEC-host-socket-closed`. The
identifier is fixed once the ADR reaches `main`. No ADR has a draft state, nothing numbers ADRs, and
a normalization maps only the ADRs that have merged.

Each `NUC-` ADR states its decision as invariants in plain rules, conditional where the part is
optional, and names in a *Latitude* section what a project may choose, pointing to the catalogue of
`propose-adr`. A project records some choices as required ADRs, such as its harness and its
toolchain, marked by a `Role:` header line.

`AGENTS.md` keeps the principles, the start, and the working style in plain rules. It links the
rules of the record and of integration in their `NUC-` ADRs instead of stating them.

## Existing behaviour

- The record: `docs/adr/NNNN-*.md`, drafts as `draft-<slug>.md`, numbered by
  `scripts/number-adrs.sh` on the branch that brings them to `main`. Check-docs holds the index (1),
  the numbering (2), the references (5, 6), the headers (7), supersessions (8), inherited ADRs
  decided (12), the release line (14), and no draft on `main` (16). Their self-tests in
  `scripts/test-check-docs.sh` and `scripts/test-number-adrs.sh` pin this behaviour.
- The shared readers in the ADR library parse identifiers and header fields. Thirty-seven scripts
  and skill scripts match the form `ADR-NNNN`, most of them through the library.
- The normalize skill restates the record and moves references with a map through its remap script.
  `scripts/test-normalize-remap.sh` cycles the real tree through a map and back.
- The binding sensor reads the *Applies to* column of the index. Its self-test pins the output.
- Must stay: every check and sensor keeps its behaviour for project ADRs, except where this spec
  names a change. The traceability check, the plain-rules sensor, the backlog, and the hooks keep
  working on the new identifiers.
- Migration: a derived project runs the remap script with a reviewed map. The map sends its numbered
  ADRs to category identifiers, and each reference to an inherited ADR to the `NUC-` ADR that
  carries the cited clause. A clause the project added to an inherited ADR becomes a project ADR
  that extends or narrows the `NUC-` clause. The normalize skill carries the steps.

## Goals served

None by identifier. The specification of the template repository is the scaffold that a derived
project fills. This work maintains the template. It breaks every derived project's record, so it
ships as the minor release `v0.9.0` under ADR-0005, which lets a minor break before `v1.0.0`.

## User stories

1. As a session in a derived project, I want the sensor to print only the decision my change
touches, so that I read less before I start. 2. As a maintainer of a derived project, I want to take
up a release by replacing the `NUC-` files and running the checks, so that a take-up needs no
normalization. 3. As a maintainer of a derived project, I want to narrow a template rule in an ADR
of my own, so that the template's text stays untouched and my narrowing stays visible. 4. As a
maintainer, I want an ADR identifier that names its topic and never changes, so that a citation in a
commit, an issue, or a code comment stays readable. 5. As an agent writing an ADR, I want to pick
its identifier when I create the file, so that no step renumbers it and no draft form exists. 6. As
a reviewer, I want a check to fail when a project ADR supersedes a `NUC-` ADR, so that a
contradiction becomes a fork and not a silent edit. 7. As a maintainer of a derived project, I want
a check to tell me which required role has no accepted ADR, so that my harness and toolchain are
always recorded. 8. As a session, I want the rules of the record and of integration in ADRs, so that
the binding sensor routes me to them like to any other decision. 9. As a maintainer, I want a check
for modal verbs and avoided terms in my own rules that spares the template's files, so that my
take-up does not fail on the template's text. 10. As the template's maintainer, I want the number of
checks and the lines in `scripts/` not to rise, so that the base stays lean.

## Implementation decisions

- **Identifiers.** An identifier is a category key and a slug joined by a hyphen. The fixed
  categories are only those the template needs: `NUC` (reserved for the template), `SEC`, `OPS`, and
  `API` (interfaces offered and consumed, adapters among them). A project defines its other
  categories in a list in the ADR index, and the checks read that list. A slug is kebab case of at
  most five words and states the decision. It stays when the title changes. A successor takes a new
  slug, and no slug is used twice, including the slugs of deleted ADRs in the history. A clause is
  cited as `SEC-x §3`. The date in the header gives the order.
- **Fixed base.** The `NUC-` ADRs lie flat in the ADR directory. A project ADR carries `Extends:` or
  `Narrows:` with a `NUC-` clause. A check forbids `Supersedes: NUC-*`. Whether a narrowing
  contradicts the base is the reviewer's call. Clause numbers are stable: a removed clause leaves a
  gap.
- **Blob list.** A change to a `NUC-` file rewrites the list of the `NUC-` files with their git blob
  identifiers, and a check in the template repository holds the list against the files. In a derived
  project a check compares the files with the list. It replaces check 12 (inherited ADRs decided): a
  project accepts the base by naming the release it carries. A fork removes the list and names the
  release it forked in its README. Blob identifiers need no new tool on any platform and ignore line
  endings.
- **Roles.** A required project ADR carries a `Role:` header line. A `NUC-` clause lists the
  required roles, at first `harness` and `toolchain`. Once the setup file is gone, a check requires
  exactly one accepted ADR per role. The template refers to a role, never to a project's identifier.
- **Index.** The index lists the project's ADRs only, grouped by category, and links the `NUC-` base
  as one line. The binding sensor reads *Applies to* from every ADR file, the `NUC-` ones included,
  and no longer from the index.
- **The cut.** Ten `NUC-` ADRs replace ADR-0001 to ADR-0006 and absorb
  [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules) and [§6](../../../AGENTS.md#6-project-rules):
  - Structure: `NUC-documents-are-fixed` (0001), `NUC-decisions-cite-tests` and
    `NUC-checks-are-bash` (0002 split, the second with the latitude "a `nuc` binary instead of
    bash"), `NUC-procedures-are-skills` (0003), and `NUC-container-hides-host-daemon` (0004,
    conditional on a Dev Container).
  - Process: `NUC-adrs-record-decisions` ([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules),
    identifiers, fixed base, roles), `NUC-main-only-via-pr`
    ([`AGENTS.md` §6](../../../AGENTS.md#6-project-rules)), `NUC-large-work-is-planned` (0006
    planning and backlog, with the latitude "plan in issues": the issue assignment replaces the
    branch claim, the issue list replaces the frontier sensor), `NUC-design-is-revised` (0006
    revision), and `NUC-releases-are-semver-tags` (0005).
  - The claim mechanics leave ADR-0006 for the `work-tickets` skill. The draft clause leaves
    ADR-0002 with the draft state.
  - Every clause of an old ADR and every rule of [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules)
    and [§6](../../../AGENTS.md#6-project-rules) lives on in one `NUC-` ADR, a skill, or the rule
    file. The hand-off lists each clause with its new home.
- **Form.** Each `NUC-` ADR writes its *Decision* and *Enforcement* in plain rules
  ([`AGENTS.md` §4](../../../AGENTS.md#4-working-style)): one statement per sentence, active with a
  subject, glossary terms, modal verbs only *must*, *must not*, *may*. It has a *Latitude* section
  that names the choices a project may make and links the catalogue, without tool names or project
  values. The ADR template gains the `Extends`, `Narrows`, and `Role` fields and the *Latitude*
  section.
- **Transition.** Until the old ADRs retire, the library reads both forms, so each ticket leaves the
  checks green and the new ADRs can be cut in parallel. The retiring ticket removes the old form,
  and no reader of it survives the release.
- **Migration tooling.** The remap script runs idempotently, has a `--check` mode, and takes its map
  as a reviewed data file. It runs dry over the parity corpus of nuc-tools before the release. The
  normalize skill's take-up becomes: replace the `NUC-` files and the blob list, map the project's
  ADRs and references, run the checks. A trial migration runs on nectar.
- **Plain-rules checks.** Modal verbs and avoided terms become checks on the project's own rules,
  and they spare the `NUC-` files. The glossary reader parses qualifiers in an *Avoid* item or
  reports what it cannot parse. Sentence length stays a sensor.
- **Status.** Each `NUC-` ADR enters as proposed in a commit of ADRs only, which the human reviews
  before anything is implemented against it. The human accepts each one after reviewing its
  implementation and tests.

## Testing decisions

- Each new or changed check gets a fixture table first: a tree described in a few lines and the
  output it must give. The bash self-test reads the table, and nuc-tools implements against the same
  table.
- The existing self-tests are the seam: `test-check-docs.sh` for the record checks,
  `test-sensor-binding-adrs.sh` for routing, `test-normalize-remap.sh` for the map, and
  `test-check-traceability.sh` for citations. `test-number-adrs.sh` goes with its script.
- `test-normalize-remap.sh` cycles the real tree through the new map, so no check holds a literal
  identifier.
- Baseline on `v0.8.1`, measured again before the release:
  - words: the six ADRs 10,064, `AGENTS.md` 2,987, the ADR index 1,355;
  - binding sensor output with `--sections`: 2,958 words for a change to `scripts/check-docs.sh`,
    1,621 for a file under `docs/plan/`;
  - checks: check-docs runs 16; `scripts/` and the skill scripts hold 10,015 lines.
  - Acceptance: the number of checks does not rise (check 12 becomes the blob check; check 16 and
    the numbering script go), and the lines do not rise.

## Out of scope

- A change-locality sensor in the template: the pilot runs in comb first and lands as a later patch,
  if it proves useful.
- A project-scale profile in the catalogue: removed from the plan.
- Whether the template's own checks move to the `nuc` binary: a separate decision.
- Migrating any derived project other than the trial on nectar: each takes the release up itself.
- New decisions in the content of the old ADRs: the cut restates them, and only the identifiers, the
  fixed base, the roles, and the claim mechanics change.

## ADR impact

Binding: ADR-0001 to ADR-0006, all of them restated by this work.

Ten new ADRs, each proposed in a commit of ADRs only before its implementation
([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rules 3 and 4). Three of them take new decisions:
`NUC-adrs-record-decisions` (identifiers, fixed base, roles), `NUC-large-work-is-planned` (plan in
issues as a latitude), and `NUC-checks-are-bash` (the `nuc` binary as a latitude). The other seven
restate their old ADRs in the new form. The old ADRs are deleted when every clause has a new home.
This is not a normalization: a normalization changes no decision.
