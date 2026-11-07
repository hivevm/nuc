# Avoided terms become a check that spares the template's own files

Observed: derived projects fill _Avoid:_ with the terms of their domain, as the glossary scaffold
asks. A check that fails on an avoided word in an added rule fails their take-up on the template's
own text: in comb, words such as *shape*, *socket*, and *pin* in the ADRs the template wrote. A
take-up by normalization counts every line of a restated ADR as added. So the plain-rules sensor
only reports avoided words (ADR-0001).

Once the template's ADRs are a fixed base a project never edits, a check can hold the glossary
against the project's own rules and spare the template's files. The glossary parser also meets
prose in an _Avoid:_ item, such as "self-edge in prose" or "shape alone"; it then reads bare words
only, as the scaffold would then say, or reports what it cannot parse.

Where: scripts/sensor-plain-rules.sh, avoid_terms in scripts/lib/rules.sh,
docs/adr/0001-agent-governance-model.md (Enforcement), docs/GLOSSARY.md.
