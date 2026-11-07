# A list of clauses after one identifier is read as sections of the rule file

Observed in the review of ticket 08 of the plan fixed-base-and-recut: check 4 of
`scripts/check-docs.sh` strips only the first clause of a citation such as
`NUC-main-only-via-pr §4, §5`. The second section sign stays and is read as a section of
`AGENTS.md`. In Markdown such a citation fails although it is right. In scripts and hooks it is
held against the sections 1 to 7 of the rule file, so a second clause up to 7 passes unchecked
and one above 7 fails. Until it is fixed, a document cites one clause per link.

Where: `clauses_out` in `scripts/check-docs.sh`, the fixture table of check 4.
