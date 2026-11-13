# A script's options that take a value are named by hand, and nothing holds the list

## Observed

`enter_root` of `scripts/lib/root.sh` refuses a `--root` that stands as the value of a script's
own option. It knows those options from `VALUE_OPTIONS`, which each script sets by hand: today
`sensor-binding-adrs.sh`, `sensor-review-binding.sh`, and `sensor-action-refs.sh`. A new script
with an option that takes a value and no `VALUE_OPTIONS` falls back to the old reading, where
`--root` is taken as the root. No check finds the missing line.

## Where

- `scripts/lib/root.sh`, `enter_root`; the scripts that source it.
- Found by the implementer of the small fixes for v0.10.0, 2026-11-13.
