# The glossary reader splits an _Avoid:_ item that wraps across two lines

Observed: the trial migration of nectar to v0.9.0 failed the plain-rules check on the word "file"
in two project ADRs. nectar's glossary lists `_Avoid:_ include file, part.` for **Chapter**, with
the line break between "include" and "file". The reader splits each line of an _Avoid:_ list at its
commas on its own, so it reads "include" and "file" as two items, and "file", a word every ADR
uses, fails as an avoided term. Joining the item onto one line made the check pass.

Where: `take()` in `avoid_terms` of scripts/lib/rules.sh, called once per line of the list.
