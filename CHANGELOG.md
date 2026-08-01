# Changelog

All notable changes to this project are documented in this file. The format follows
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), versioning follows
[SemVer 2.0.0](https://semver.org/spec/v2.0.0.html) — see [ADR-0006](docs/adr/0006-versioning-and-releases.md).
Update the **Unreleased** section in the same change as any user-visible modification.

## [Unreleased]

### Added

- Initial template: agent governance (`AGENTS.md`, specification, ADRs), Dev Container without
  host Docker access, documentation CI checks, and this changelog.
- Shell lint: every shell script passes ShellCheck, enforced in CI (the check scripts are the
  template's enforcement layer, so they are linted themselves).
<!-- module:git-conventions begin -->
- Git conventions: branch naming, Conventional Commit subjects, and squash merge, enforced in CI.
<!-- module:git-conventions end -->
<!-- module:supply-chain begin -->
- Supply-chain pinning: GitHub Actions pinned to full commit SHAs, secrets handling rules, and
  Dependabot pin updates, enforced in CI.
<!-- module:supply-chain end -->
<!-- module:conformance begin -->
- Conformance tracking: projects that derive from an external specification or project anchor
  themselves in `docs/CONFORMANCE.md` — pinned upstream revision, per-unit conformance inventory,
  and deliberate deviations — so external progress can be diffed instead of guessed.
<!-- module:conformance end -->
<!-- module:init begin -->
- Selectable policy modules: at the first interaction, the project chooses which policy modules
  (git conventions, supply chain, release policy, conformance) to adopt; a first-run bootstrap
  removes everything not chosen and marks the chosen seed ADRs accepted. It also drops the ADR describing
  the bootstrap itself and renumbers the surviving ADRs to a gapless `0001..N`, rewriting every
  reference — so an initialized project starts without holes in its decision history. The
  bootstrap also repoints the README CI badge to the project's repository (`--repo`, or derived
  from the `origin` remote), or removes it when no repository is known.
<!-- module:init end -->
