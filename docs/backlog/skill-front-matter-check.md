# A check holds a skill's front matter

Observed in ticket 10 of fixed-base-and-recut: a rewrap of the `setup-project` skill wrapped its
`description:` onto unindented lines and left the closing `---` at the end of a line, so no agent
read the skill, and no check caught it. A review found it.

A check needs an ADR correction first: NUC-procedures-are-skills names a check on the front matter
of a skill as out of scope and defers it as a follow-up, so the correction moves it into a clause.
The check must accept the Agent Skills format, nested keys such as `metadata:` and block scalars
such as `description: >`, or detect only a missing opening or closing `---`. A first guard in
check 11 refused valid skills and was reverted.

Where: check 11 of scripts/check-docs.sh, docs/adr/NUC-procedures-are-skills.md (Out of scope,
Consequences).
