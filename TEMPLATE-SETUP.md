# Template setup

This repository is a scaffold. Work through this file to turn it into your own project. Then
close the setup with `scripts/test-template-setup.sh --close`, and run
[`scripts/check-all.sh`](scripts/check-all.sh). The close removes this file and what exists only
for it: the notes of [`README.md`](README.md), the layout row of
[`CONTRIBUTING.md`](CONTRIBUTING.md), the
[`setup-project`](.agents/skills/setup-project/SKILL.md) skill, and the setup's own self-test.
Documents that mention the setup in passing, such as the ADRs, keep their sentence.
Its function `close_setup` in [`scripts/test-template-setup.sh`](scripts/test-template-setup.sh)
lists them. The close also removes the template's own open work, so the project starts with an
empty plan and an empty backlog. That work is the files under `docs/plan/` and `docs/backlog/`
that the committed copy of the template brought. A file the project wrote there itself stays. The
close lists each file it removed there and each it kept. On a copy not yet committed, the close
refuses and asks to commit it first.

Choose the **profile** first, because it decides how much of each step you take. A small
project takes the path of [A small project](#a-small-project) at each step; a complex one takes
every step in full and grows its harness to tickets worked in parallel, as
[A complex project](#a-complex-project) says. An agent walks you through the steps one question
at a time with the `setup-project` skill, and writes the specification of step 3 with you,
section by section.

An **existing project** takes up the template by an adoption, with the
[`normalize`](.agents/skills/normalize/SKILL.md) skill. Its files are copied into the tree, and
step 1 gives the project its identity. Then the specification and the record are restated in
place of steps 2 and 3: the project's own decisions become its record, and the `NUC-` base stays
as the release brings it
([NUC-decisions-are-proposed-then-accepted §8](docs/adr/NUC-decisions-are-proposed-then-accepted.md)).
The steps still open follow.

## What only you can do

1. Give the project its identity. An agent asks the human for four values and applies them:
   - **Project name.** Replace **NUC** in the title of [`README.md`](README.md) and in `"name"`
     of `.devcontainer/devcontainer.json`, rewrite the README's intro sentence, which explains
     the template's name, and delete its **Why NUC** section, which presents the template. Keep
     `NUC maintainer` in the `Deciders` lines of the ADRs: it names who decided. Leave the `NUC-`
     files of [`docs/adr/`](docs/adr/) and [`AGENTS.md`](AGENTS.md) as they are: the rule
     `docs/base-blobs` of [`scripts/check-docs.sh`](scripts/check-docs.sh) holds them against
     their blob list.
   - **Repository.** The badges of checks, release, and license in [`README.md`](README.md)
     point at the template's repository, `hivevm/nuc`. Repoint them to this project's
     `owner/name` (`git remote get-url origin` says it where a remote exists), or delete a badge
     line. The release badge shows a release once the project cuts its first.
   - **Maintainer.** The copyright holder in [`LICENSE`](LICENSE), the code owner in
     [`.github/CODEOWNERS`](.github/CODEOWNERS) (a GitHub handle or team with write access; then
     uncomment its two rules and remove the TODO above them), the security contact in
     [`SECURITY.md`](SECURITY.md), and the reporting contact in
     [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
   - **License.** MIT ships in [`LICENSE`](LICENSE) and in the **License** section of the README.
     For another license, replace the text of both.
   The rule `docs/template-identity` of [`scripts/check-docs.sh`](scripts/check-docs.sh) fails
   on any of these placeholders still present once this file is gone.

   Then work through [**Repository settings**](CONTRIBUTING.md#repository-settings), before the
   setup's pull request is opened. They are the rules only the GitHub repository can enforce. Until
   they are set, nothing on GitHub keeps a change from reaching `main` without a pull request and
   its checks. The jobs they name as required checks exist from the start. Without a second
   maintainer, the Code Owners review stays off until one joins, as
   [A small project](#a-small-project) says. Then run
   [`scripts/sensor-repo-settings.sh`](scripts/sensor-repo-settings.sh): it reports what still
   differs from the list.
2. Read the `NUC-` ADRs in [`docs/adr/`](docs/adr/), the base this project inherits: the
   document set, the record, how decisions are verified, the checks, and the skills first,
   because every later one rests on them; the container, integration, planning, the design
   revision, and the releases follow. The project accepts the base by the release its README
   names, never edits a `NUC-` file, and extends or narrows a clause in an ADR of its own
   ([NUC-base-is-fixed §1](docs/adr/NUC-base-is-fixed.md)). The template ships
   each with its test or its exemption, so the checks stay green. The Dev Container waits for
   step 4, where it is decided beside the
   environment: whether the project needs one rests on where its work runs, which the
   specification of step 3 says. The shape of the code is not an inherited ADR: it is a
   founding decision of step 4.
3. Write down the **project idea** in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md), and
   give it and the other three documents of [`docs/`](docs/) the project's name in their title.
   Each section of the scaffold says in a line what belongs in it. Write the **Problem** first;
   everything else rests on it. The goals, the quality goals, and the threats are what the
   founding decisions of step 4 are weighed against, so they come before them. The `<Part>`,
   `<Term>`, and `<Convention>` entries of the other three show the form of an entry: replace
   each with a real one, or delete it while there is nothing to say. The rule
   `docs/template-identity` fails on a `<Project Name>` title, a placeholder criterion, or a
   scaffold entry still present once this file is gone.
4. Take the **founding decisions**: the few that every later session works inside and that are
   expensive to discover by accident. Each brings its **guides**, which steer an agent before it
   acts, and its **sensors**, which check what it did. Committing to them early narrows what an
   agent can produce to what the sensors can hold
   ([harness engineering](https://martinfowler.com/articles/harness-engineering.html)).

   **Deciding.** For each, the agent proposes the fitting concepts of the catalogue in
   [`.agents/skills/propose-adr/concepts/`](.agents/skills/propose-adr/concepts/README.md), the
   simplest among them, with what each one's *Does not fit* says about this project; you choose,
   and the choice becomes an ADR of your own
   ([NUC-decisions-are-proposed-then-accepted §1](docs/adr/NUC-decisions-are-proposed-then-accepted.md)).
   One decision per ADR, all of them in commits of ADRs only, status `proposed`
   ([NUC-decisions-are-proposed-then-accepted §3](docs/adr/NUC-decisions-are-proposed-then-accepted.md)).
   Keeping what the template ships is a choice too, and gets the mini-ADR of
   [`docs/adr/template.md`](docs/adr/template.md): this file goes once the setup is done, and
   without the record the next session proposes the question again. Decide these and no more;
   everything else is decided when the work first needs it.
   - **The harness** ([catalogue](.agents/skills/propose-adr/concepts/harness.md)): which agents
     and models work here, who reviews what, and what may run unattended.
   - **The toolchain** ([catalogue](.agents/skills/propose-adr/concepts/toolchain.md)): the
     language, its build, test, and lint commands, and its sensors in three kinds.

     These two carry the header field `Role:`, `harness` or `toolchain`. Once this file is gone,
     the rule `docs/template-identity` fails unless each role has exactly one accepted ADR.
   - **The shape of the code,** from the catalogue's group of that name, with the rule a
     structural test decides, or no prescribed shape, as the template ships. A decision about
     the shape is the one entropy erodes first.
   - **The environment:** the base of the Dev Container (an image, a `Dockerfile`, or Compose)
     and how the work reaches the containers it needs, or none, as `.devcontainer/` ships it;
     or no Dev Container at all, where
     [NUC-container-hides-host-daemon §1](docs/adr/NUC-container-hides-host-daemon.md) binds
     nothing.
   - **The supply chain:** how the workflows reference actions, by major version tag as the
     template ships them, and, where the specification names credentials as an asset, where
     secrets live and how a leak is caught.

   **When they bind.** These ADRs are a start, not a cage. While they are `proposed`, a finding
   revises one in a commit of ADRs only
   ([NUC-decisions-are-proposed-then-accepted §4](docs/adr/NUC-decisions-are-proposed-then-accepted.md)).
   The ones the golden path of step 7 proves wrong are rewritten before they bind. Each flips to
   accepted with what decides it:
   - **The shape and the toolchain** flip with the golden path of step 7 and its tests.
   - **The environment** flips with `scripts/check-devcontainer.sh` and what its ADR adds. A
     project without a Dev Container removes it in a commit after the reviewed ADRs, as
     [A small project](#a-small-project) says, and supersedes nothing.
   - **The supply chain** flips with
     [`scripts/sensor-action-refs.sh`](scripts/sensor-action-refs.sh) run as its check, wired as
     its [catalogue entry](.agents/skills/propose-adr/concepts/action-references.md) says.
   - **The harness and a kept default** usually flip with a `**Not mechanically decidable:**`
     paragraph.

   After that, following the technology means superseding the one ADR that chose it.
5. Fill in the **Overview**, **Build, Test & Run**, and **Usage** sections of
   [`README.md`](README.md). The rule `docs/template-identity` fails on the scaffold's Overview
   sentence, the Usage `TODO`, and a Build, Test, Lint, or Run command still `TODO` once this
   file is gone; write "none" where there is nothing to run.
6. Add the toolchain of step 4 to the environment (the base image ships none). The build, test,
   and lint commands of the README run through **one script under [`scripts/`](scripts/)**, say
   `check-build.sh`. [`scripts/check-all.sh`](scripts/check-all.sh) invokes it with a `run` line,
   beside the other checks at once, so it must write nowhere they read, and a job of
   [`checks.yml`](.github/workflows/checks.yml) runs it after setting up the toolchain, the job
   named among the required checks of `CONTRIBUTING.md` and added to those of the ruleset on `main`.
   That is what makes the pre-push hook and CI refuse a red change
   ([`AGENTS.md` §5](AGENTS.md#5-quality-bar--definition-of-done)). The rule `docs/check-lists` of
   [`scripts/check-docs.sh`](scripts/check-docs.sh) fails on a job whose commands are written
   inline instead, and while the three lists disagree. What is too slow to gate a push, such as
   a nightly suite or a long benchmark, is a workflow of its own on a schedule, not a job here.
   The sensors the toolchain ADR names run the same way; their output is what the reviewer of
   [`AGENTS.md` §5](AGENTS.md#5-quality-bar--definition-of-done) is handed, and a sensor that
   runs only in someone's head is a rule in prose.
7. Lay down one golden path and one test pattern: a small, complete, idiomatic piece of the real
   system and the test that verifies it, built on the founding decisions. Name both in an entry
   of the Building blocks of [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), with the words
   "golden path", which `--open` looks for. The specification says *what*; this is where
   an agent learns *how* this project does it, and what it copies from is what you get more of.
   Where the project chose a shape, its rule lands here as a **structural test**, cited with a
   `Verifies:` marker ([NUC-decisions-cite-tests §2](docs/adr/NUC-decisions-cite-tests.md)), and
   the shape ADR flips to accepted with it; the toolchain ADR flips with the golden path's tests.
   What the golden path shows that no check decides and a reader could not guess, the why behind
   a shape, is the first entry in [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md).

Project-specific conventions belong in [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md), in checks, and
in ADRs; on what may and may not be edited, see
[NUC-decisions-are-proposed-then-accepted §6](docs/adr/NUC-decisions-are-proposed-then-accepted.md)
and [NUC-base-is-fixed §1](docs/adr/NUC-base-is-fixed.md). Leave the **Dev Container**, **Coding
Agents**, and **Repository settings** sections of `CONTRIBUTING.md` and the **Template** section of
the README as-is; they describe the scaffold. A project without a Dev Container changes the first
two as [A small project](#a-small-project) says. The Template section names the release this project
carries and is the one link to the template that stays. The **Project Layout** block of
`CONTRIBUTING.md` inventories the top level, so a part you remove goes out of it, this file
included, and a part you add goes in, such as the source tree and the toolchain's files of step 6;
the rule `docs/project-layout` of [`scripts/check-docs.sh`](scripts/check-docs.sh) fails on one it
does not name.

## A small project

A tool, a library, or a one-person project pays for the steps above only where they buy
something. The base stands whole, and costs little:
[NUC-documents-are-fixed](docs/adr/NUC-documents-are-fixed.md) holds the documents the checks
read, [NUC-decisions-cite-tests](docs/adr/NUC-decisions-cite-tests.md) asks one `Verifies:`
marker per accepted decision, [NUC-procedures-are-skills](docs/adr/NUC-procedures-are-skills.md)
ships skills that cost nothing until invoked, and
[NUC-releases-are-semver-tags](docs/adr/NUC-releases-are-semver-tags.md) is one line of the
README. What can go, and how:

- **No Dev Container?** Record where the work runs in the environment ADR of step 4, delete
  `.devcontainer/`, and supersede nothing: without it no clause of the Dev Container ADR binds
  ([NUC-container-hides-host-daemon §1](docs/adr/NUC-container-hides-host-daemon.md)).
  `scripts/check-devcontainer.sh`, its self-test, and the `devcontainer` job stay: the check
  passes and says that nothing binds, and its self-test is the test that cites the ADR. Remove
  the rest of what the container brings in the change that implements the decision:
  - the `remote.extensionKind` entry of [`.vscode/settings.json`](.vscode/settings.json) and the
    lock comment of [`.gitignore`](.gitignore);
  - in `CONTRIBUTING.md`, the Dev Container section and the `.devcontainer/` row of the Project
    Layout, with the first paragraph of Git hooks, the first paragraph of Coding Agents, and the
    Dev Container in the workflow rewritten for the host; in the README, Prerequisites and
    Getting Started; and the first bullet of Agent execution in [`SECURITY.md`](SECURITY.md).

  The link and layout checks fail on a file or a link left behind;
  the prose is the reviewer's to read. This file names what the path removes without linking it,
  so its own links hold while the path is walked.
- **No shape worth a decision?** A script or a thin CLI keeps what the template ships, no
  prescribed shape, in a mini-ADR that says so.
- **Work never exceeds a session?** Planning costs nothing: it binds only above that threshold
  ([NUC-large-work-is-planned §1](docs/adr/NUC-large-work-is-planned.md)), and the threshold is a
  judgement under proportionality ([`AGENTS.md` §1](AGENTS.md#1-principles)).
- **The harness and the toolchain** take the smallest form of their catalogue entries: one agent
  and the human reviewing every change, the linter's own rules as the first sensors. Each grows
  when the work does.
- **A single maintainer** cannot approve their own pull request, so the Code Owners review in
  the repository settings cannot be met; keep the required checks and the force-push block, and
  let [`.github/CODEOWNERS`](.github/CODEOWNERS) name the owner without the requirement. The
  status flip and the specification are then guarded by the rule alone; say so where
  [`SECURITY.md`](SECURITY.md) describes the gate.

[`AGENTS.md`](AGENTS.md), the glossary, the conventions, and the overview stay, empty where
there is nothing to say; a scaffold section costs a reader a glance, a missing document costs a
check.

## A complex project

Several people or agents, work that spans sessions, or assets worth protecting: every step is
taken in full, and the founding decisions of step 4 take the larger forms of their catalogue
entries.

- **The harness** takes the form *Parallel tickets under a cap* of its
  [catalogue entry](.agents/skills/propose-adr/concepts/harness.md): the ADR names the agent and
  model that implement and the one that reviews, the command that starts each without a human,
  the cap on open agent work, the parts never worked unattended, and, where several people
  dispatch from clones of their own, the remote claims are made on. Tickets are worked through
  the [`work-tickets`](.agents/skills/work-tickets/SKILL.md) skill: a dispatching session reads
  the frontier from [`scripts/sensor-plan-frontier.sh`](scripts/sensor-plan-frontier.sh), claims
  each ticket by its branch in a worktree of its own, and starts a fresh session in each.
- **The environment** says how parallel sessions are kept apart: worktrees in the one Dev
  Container, or a container each. The worktrees lie under the ignored `.scratch/`, so a tool of
  the toolchain that walks directories without reading `.gitignore`, such as a test runner or a
  file watcher, is configured to leave `.scratch/` out.
- **The work** is planned under `docs/plan/` from the start, through the
  [`plan-feature`](.agents/skills/plan-feature/SKILL.md) skill; the golden path of step 7 is the
  tracer bullet of the first spec. A ticket is claimed on `main`
  ([NUC-large-work-is-planned §4](docs/adr/NUC-large-work-is-planned.md)), so the setup's pull
  request lands steps 1 to 6 first, and the founding ADRs reach `main` as `proposed`; step 7 follows
  as that spec.
- **A second maintainer** makes the Code Owners review of the repository settings possible; keep
  it required. With several, a team is the code owner in
  [`.github/CODEOWNERS`](.github/CODEOWNERS), and the harness ADR says which of them decides the
  ADRs of which part, so that the proposed ADRs do not all wait on one person.
