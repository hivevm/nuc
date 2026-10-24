---
name: setup-project
description: Set a project up from this template interactively, one question at a time — the profile (small or complex), the identity, the inherited ADRs, the specification written with the human section by section, the founding decisions, and the remaining steps of TEMPLATE-SETUP.md. Use when TEMPLATE-SETUP.md exists and the human starts or initialises a project, or asks to write its specification from the beginning. Deleted together with TEMPLATE-SETUP.md.
---

# Set the project up

The steps and what each one decides are [`TEMPLATE-SETUP.md`](../../../TEMPLATE-SETUP.md); the
rules on ADRs are [`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules). This skill is the order of
the conversation and states no rule of its own
([ADR-0003](../../../docs/adr/0003-procedures-as-skills.md)).

## How the conversation runs

- One question at a time, each with what it decides and a proposal drawn from what the human has
  said so far. Write only what the human confirmed; a proposal they did not answer is not an
  answer.
- What the human does not know yet is not invented: it goes into the specification's
  *Assumptions*, or stays an open question in the conversation until it is answered.
- Commit after each step, so the walk can stop anywhere. The branches stack in the order of
  the steps, each on the one before, since every step works inside what the earlier ones
  wrote: steps 1 to 3 on `chore/setup`; the founding decisions of step 4 on a branch of ADRs
  only ([`AGENTS.md` §3](../../../AGENTS.md#3-adr-rules), rule 3); steps 5 to 8, once the human
  has reviewed those ADRs, on branches stacked on it. They reach `main` by pull requests in
  that order, or, when the human instructs it, integrate first on `feat/setup` and reach
  `main` by its one pull request
  ([`AGENTS.md` §6](../../../AGENTS.md#6-project-rules)).
- A later session resumes from the tree. The profile is read from the team and the work in the
  specification's *Constraints* and the assets in its *Threats*, or asked again while those are
  unwritten. [`scripts/test-template-setup.sh`](../../../scripts/test-template-setup.sh)
  `--open` lists what is still open of steps 1, 3, and 5, and each inherited ADR without a
  decider of this project; ADR-0004 stays among them until step 4. Read from the tree are the
  *Problem*, *Mission*, *Vision*, and *Strategy* of the specification, whose scaffold carries no
  `…` to find, and steps 6 to 8. The founding decisions already taken are the ADRs of step 4 on
  their branch.
- In an existing project, steps 2 and 3 run as the adoption of the
  [`normalize`](../normalize/SKILL.md) skill, and this walk resumes with step 4 for what no
  record of the project decides yet.

## 1. The profile

Ask whether the project is small or complex, with the signals the first sentence of
[A small project](../../../TEMPLATE-SETUP.md#a-small-project) and of
[A complex project](../../../TEMPLATE-SETUP.md#a-complex-project) gives, and for a small one
also work that fits a session and one agent; propose one. Each later step then takes the path
that section says.

The profile is a starting point, not a record: the harness and the toolchain grow when the work
does.

## 2. Identity and inherited ADRs

Step 1: ask for the four values of the identity and apply them. Step 2: for each inherited ADR,
in the order of its number, say in two sentences what it decides and what it costs this
project, recommend accepting or superseding it in the light of the profile, and apply the
human's answer. ADR-0004, the Dev Container, waits for step 4, as the setup file says.

## 3. The specification

Step 3, written with the human into [`docs/SPECIFICATION.md`](../../../docs/SPECIFICATION.md)
section by section in the order of the scaffold, each drafted from the answers, shown, and
written once confirmed:

1. **Problem:** for whom it is painful or missing, what they do today instead, and what evidence
   says it is worth solving now. Nothing below is drafted before this is confirmed.
2. **Mission, Vision, Strategy:** two or three candidate wordings each, the human chooses or
   rewrites; in a small project one sentence each is enough.
3. **Goals:** for each, the trigger and the response, *When <trigger>, the system shall
   <response>*, and how a test would decide it; numbered from 1 as `G-n`.
4. **Quality goals:** the few properties that decide between designs, in priority order, each
   with a measure that would settle a disagreement; numbered from 1 as `Q-n`.
5. **Non-goals:** what a reader would expect the project to do that it will not.
6. **Constraints:** platforms, standards, systems to work with, limits of time, budget, and team.
7. **Threats:** the assets, who threatens them, the trust boundaries, and what the system must
   never do; each prohibition a test can decide becomes a `Q-n` as well.
8. **Assumptions:** what the answers above took for granted, collected along the way.

The terms that came up go into [`docs/GLOSSARY.md`](../../../docs/GLOSSARY.md), and the four
documents of `docs/` get the project's name in their title.

## 4. The founding decisions

Step 4, one decision at a time through [`propose-adr`](../propose-adr/SKILL.md), weighed against
the specification just written: the simplest fitting concepts proposed, the human chooses, each
choice an ADR at `proposed`, all of them on one branch. ADR-0004 is taken up beside the
environment, as the setup file says. For the harness, ask whether
agents are to work tickets in parallel; if so, the ADR takes the catalogue's form *Parallel
tickets under a cap* and names the command that starts each agent without a human.

## 5. The remaining steps

Steps 5 to 8 as the setup file says, asking only what the human has to decide: the commands of
the README, the toolchain's job, the repository settings. The golden path of step 7 is a session
of its own; in a complex project it is the tracer bullet of the first spec, planned through
[`plan-feature`](../plan-feature/SKILL.md).

## 6. Close

Delete the setup file with everything its first paragraph lists, this skill and its pointer
included, and run [`scripts/check-all.sh`](../../../scripts/check-all.sh): `check-docs.sh`
names what the walk left behind.
