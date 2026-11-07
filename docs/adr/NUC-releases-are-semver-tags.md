# NUC-releases-are-semver-tags: The template is released as SemVer tags, and every repository names the release it carries

- **Status:** 🟡 proposed
- **Date:** 2026-11-07
- **Deciders:** NUC maintainer
- **Applies to:** the tags of the template repository, the **Template** section of `README.md`, check 14 of `scripts/check-docs.sh`, the pull request that lands a release, and the take-up of a release in a derived project

## Context

GitHub's template mechanism copies the default branch when a repository is created. It copies no
history and no tags, and it offers no choice of a version. Without releases, nobody can say which
state of the template a derived project inherited. The difference between what a project has and
what the template now says cannot be computed. A project that wants a change has no unit to take
it up in: a commit is too small, and `main` moves.

Three forces bound the answer. The template ships no toolchain, so release tooling is out. Its
maintainers are few and its releases rare, so a chore on every pull request costs more than it
returns. Tags do not travel with the copy, so a tracked file must name the release.

The template's ADRs are a fixed base that a project never edits
([NUC-adrs-record-decisions §11](NUC-adrs-record-decisions.md)). So a release can carry its ADRs
as files, and a take-up can replace them.

## Decision

We will release the template as annotated SemVer tags on `main`, and every repository names the
release it carries in its README.

1. **Tags.** A release is an annotated tag `vX.Y.Z` on `main`, versioned by
   [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html). A tag carries no pre-release suffix and no
   build metadata. Work that is not ready is not tagged.
2. **Cut.** Only a human cuts a release. A pull request moves the release line to the new
   version. The human tags the merge commit. The tag's annotation and the GitHub release built
   from it must say what changed and what a derived project does to take it up.
3. **Version.** The maintainer picks the part of the version by the change:
   - a major is a change a derived project must act on. Examples are a check that fails on its
     tree, a `NUC-` clause changed in meaning or removed, and a re-cut base;
   - a minor adds a check, an ADR, a skill, a catalogue entry, or a document;
   - a patch changes wording, or fixes a script without changing what it decides.

   Before `v1.0.0` a minor may break, per SemVer item 4.
4. **Release line.** The **Template** section of `README.md` carries a `Template release` line.
   - In the template, it names the last release cut.
   - In a derived project, it names the release the project carries.
   - Before the first release, it reads `unreleased`.
5. **Moving the line.** A derived project moves the line when it takes up a later release, and
   only then. A line never moved still names what the project carries.
6. **Take-up.** A derived project takes up a release in these steps:
   - It replaces the `NUC-` files and the blob list with those of the release.
   - It takes up the other files the release notes name.
   - It moves the release line.
   - It runs the checks and fixes its own files until they pass.

   The project's own ADRs stay as they are. A take-up needs no normalization.
7. **Re-cut.** A release that merges, splits, or removes a `NUC-` ADR is a major. Its notes must
   carry the map from each old identifier and clause to its new home.

**Out of scope:**

- a changelog file and release automation;
- how a derived project merges the files of a release other than the `NUC-` files;
- which releases receive fixes, which `SECURITY.md` states;
- the correction of `NUC-` ADRs in place, which
  [NUC-adrs-record-decisions §6](NUC-adrs-record-decisions.md) decides.

## Latitude

A project may choose:

- which releases it takes up, and when; it may skip releases;
- how it merges the other files of a release: by hand, by patch, or by subtree;
- a templating tool on top of the tags, such as one that pins a tag at creation.

The catalogue has no entry for these choices, and none of them needs an ADR.

## Alternatives considered

- **No versions; the default branch is the template.** Every derived project carries an unnamed
  state, and no change can be taken up as a unit.
- **CalVer.** A date carries no signal of what a derived project must do. The major is that
  signal.
- **A changelog file kept per pull request.** It is a chore on every change of a template
  released rarely. The tag annotation and the pull requests between two tags say the same, once.
- **A templating tool with versioned updates, such as copier or cruft.** It gives version
  selection at creation and an update path. It costs a Python toolchain on every host that
  creates a project, and a template file to maintain. A project that wants the update path adds
  the tool on top of the tag.
- **Release branches per major.** A template with few releases has nothing to maintain on them. A
  tag marks the same state.
- **A version file.** Nobody reads it, and it is one more entry of the project layout. The README
  section a reader opens first answers the same question.
- **A take-up by normalization, as before.** The project merged the template's ADRs into its own
  record by hand at every release. With a fixed base, replacing the files does the same without a
  merge.

## Sources / Prior art

- Semantic Versioning 2.0.0 — <https://semver.org/spec/v2.0.0.html>, item 4 on `0.y.z`.
- GitHub, *Creating a repository from a template* —
  <https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template>:
  the default branch or all branches are copied, and no version is offered.
- GitHub, *About releases* —
  <https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases>: a
  release is built on a tag and carries notes.
- Copier — <https://copier.readthedocs.io/>: `--vcs-ref` at creation and `copier update`
  afterwards, the tool the alternative names.

## Consequences

- Positive: a derived project can say what it inherited, and diff the template between the tag
  it carries and a later one.
- Positive: the version says whether a take-up is work.
- Positive: a take-up replaces files and runs the checks; it needs no normalization.
- Negative: the line moves by hand. A release nobody cuts leaves `main` ahead of the last tag.
- Negative: a project that never moves the line carries a state that grows old.
- Follow-ups: the order of work of a take-up is a procedure of the `normalize` skill.

## Enforcement

- Check 14 of `scripts/check-docs.sh` holds the release line (clause 4). It fails when
  `README.md` has no `Template release` line. It also fails when the line names neither a
  `vX.Y.Z` tag nor `unreleased`. Its self-test cites this ADR.
- The check on the blob list holds the replaced `NUC-` files of a take-up (clause 6).

**Not mechanically decidable:** two clauses rest on judgement. The review of the release pull
request holds them:

- whether the version part fits the change (clause 3);
- whether the tag exists and the line moved with the release (clauses 2 and 5), since tags do not
  travel with the copy.
