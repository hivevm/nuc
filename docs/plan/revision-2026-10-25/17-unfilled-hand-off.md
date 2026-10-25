# Ticket: Decide whether an unfilled hand-off or a missing review fails a pull request

## What to build

Pull request #8 merged with its hand-off unfilled. Its description has a two-line summary
followed by the pull request template with every section empty, including `Reviewed at:`. No
fresh-context review ran. `scripts/sensor-review-binding.sh` reported the missing line in the
sensors job of `checks.yml`, and reports fail nothing (ADR-0002: "a sensor fails on nothing it
counts until a project's decision turns it into a check").

So a check did see the mistake, and nothing stopped it. Draft, through `propose-adr`, whether the
template turns part of the sensor into a check:

- **Hand-off left unfilled.** The description still carries a section of the template whose
  bullets are all empty (`- Tests:` with nothing after it). That is cheap to decide and leaves
  the content to review.
- **No review named.** No `Reviewed at:` commit, with an exemption the description states (a
  release line moved by a human, as in #5, #7, #10).

Weigh the cost. A failing check on the description needs the `edited` trigger of
`review-binding.yml` as a required check, and that workflow is required by none today.

## Acceptance criteria

- [ ] Given the draft, when the maintainer reviews it, then the decision names what fails, what
      is exempt, and where it runs.
- [ ] Given a decision to check, when a fixture description with an empty *Proof* section is fed
      to the sensor's self-test, then the check fails and names the section.

## Read first

- `docs/adr/0002-decisions-verified-by-tests.md` (sensors and checks)
- [`AGENTS.md` §5](../../../AGENTS.md#5-quality-bar--definition-of-done) (review in a fresh
  context; the hand-off names the commit)
- `scripts/sensor-review-binding.sh`, `.github/workflows/review-binding.yml`,
  `.github/PULL_REQUEST_TEMPLATE.md`; the description of pull request #8

## Blocked by

- None (can start immediately)

## Mode

with the human: turning a sensor into a check is a decision ADR-0002 reserves.
