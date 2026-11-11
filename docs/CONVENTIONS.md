# Conventions — <Project Name>

> How this project writes code and tests **where no check decides it**: the judgement calls. What
> a module may know, what a test asserts and never does, the shape of an error, how a thing is
> named when the glossary has no word for it. Whoever settles a convention updates this file
> inline, an agent included, in the same change as the review or code that settled it. The
> reviewer always has it ([NUC-documents-are-fixed §6](adr/NUC-documents-are-fixed.md)).

An entry says in a sentence or two what is done and why; the why tells a convention from a habit.
A convention a check can decide is the check, not an entry. One that constrains future choices is
an ADR. What the golden path already shows needs none. Few entries that hold beat many that are
skimmed. The design revision drops what prevented nothing
([`AGENTS.md` §5](../AGENTS.md#5-quality-bar--definition-of-done)).

- **A rule changes everywhere it is stated** — a change to a rule, a step, or a name searches
  the tree for its old wording and for every citation of its anchor, and corrects them in the
  same change. A link check sees the anchor, never a sentence that restates it.
- **A self-test asserts what it builds** — it takes its fixtures from the tree it copies or writes
  them itself, never from the template's own ADRs, scripts, or numbers, so it holds in a derived
  project and after a normalization.
- **A check's cases are a table** — a new or changed check writes its cases into a table under
  `scripts/fixtures/` before its code, and its self-test reads the table, so a port of the
  checks is held to the same cases. A case expects a key, a rule identifier and a reason word that
  the message ends in, such as `[docs/adr-index:twice]`, and the data of the finding, never its
  wording, so that rewording a message breaks no port.
- **<Convention>** — what is done, and why.
