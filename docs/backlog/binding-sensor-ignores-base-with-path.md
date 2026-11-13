# The binding ADRs sensor ignores a positional base given with --path

## Observed

`scripts/sensor-binding-adrs.sh --path <path>` names the paths itself and reads no range, yet
it accepts up to two positional arguments, a base and a head, and ignores them. A stray argument
passes without a word. The review of the small fixes for v0.10.0 found that this let a slip with
`--root` pass on the wrong tree, until `enter_root` refused it.

## Where

- `scripts/sensor-binding-adrs.sh`, its argument handling with `--path`.
- Found by the review of the small fixes for v0.10.0, 2026-11-13.
