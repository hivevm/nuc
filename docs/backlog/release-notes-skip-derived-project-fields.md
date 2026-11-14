# Nothing tells whoever cuts a release to gather what a derived project acts on

## Observed

Since the revision of 2026-11-13, every hand-off says under Doubts what a derived project acts on,
for the notes of the next release. No document tells whoever cuts the release to collect those
fields from the pull requests merged since the last tag. `CONTRIBUTING.md` has no release
procedure, and NUC-releases-are-semver-tags says what a release is, not how its notes are written.
A project that takes the release up then reads the diff to learn what it must change.

A step or a sensor could list the fields of the pull requests merged since the last tag.

## Where

- `CONTRIBUTING.md`; `docs/adr/NUC-releases-are-semver-tags.md`; the pull request template.
- Found by the review of the whole branch feat/after-revision-2026-11-13, 2026-11-13.
