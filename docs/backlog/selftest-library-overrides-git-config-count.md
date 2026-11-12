# The self-test library overrides a GIT_CONFIG_COUNT that the environment already sets

## Observed

`scripts/lib/selftest.sh` exports `GIT_CONFIG_COUNT=1`, `GIT_CONFIG_KEY_0=core.autocrlf`, and
`GIT_CONFIG_VALUE_0=false`, so that fixtures are checked out with LF under Git for Windows
(2aef757, PR #32). Where the environment of a self-test already sets `GIT_CONFIG_COUNT` and its
keys, such as a project's own self-test or a CI runner, the library replaces the count and the
first key. The settings the environment gave are lost without a word. No project has reported it.
The review of PR #33 named it and left it.

An entry that appends instead would read the count the environment set and add the setting at the
next index. The library leaves the template with the bash checks if the proposal
`NUC-checks-run-by-nuc` is implemented. The human weighs a fix against that.

## Where

- `scripts/lib/selftest.sh`, line 31.
- Found by the design revision of 2026-11-12.
