# An ADR may name a rule key that check-docs.sh does not have, and nothing says so

## Observed

The binding ADRs sensor binds an ADR that names 'the rule `<key>` of `<file>`' to the function
of the check that carries that key. A key the header of `scripts/check-docs.sh` does not list,
misspelt or renamed, binds nothing inside the checks: the ADR then binds only lines outside
them, and no check fails. The rename of `docs/adr-numbering` to `docs/adr-identifiers` showed
it: at the ADR-only commit the ADR and the function tag disagreed, and the sensor dropped the
ADR silently. A derived project whose own ADR copies a key from old notes meets the same.

A check could hold every key named in an *Applies to* against the header items.

## Where

- `scripts/sensor-binding-adrs.sh`, `checked()`; the rule `docs/adr-refs` of
  `scripts/check-docs.sh` as a possible home.
- Found by the review of the rule key rename, 2026-11-13.
