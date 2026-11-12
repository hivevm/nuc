# The self-test of the binding sensor spends a minute on one case

## Observed

`scripts/test-sensor-binding-adrs.sh` takes 66 s alone and 117 s of the 161 s of a full
`scripts/check-all.sh` (2026-11-12). One case of its 58 takes 68 s: the ADR whose *Applies to*
puts prose before a list longer than a pipe holds. Its fixture writes two paths of 200,000
characters each. The sensor reads that line with bash pattern removals that anchor a `*` on the
left, and these are quadratic in the length of the string:

- `adr_field_value` in `scripts/lib/adr.sh` (`${1##*…}`): 40 s; the shortest match, `${1#*…}`,
  takes 5 ms on the same line.
- `module_dir` in `scripts/sensor-binding-adrs.sh` (`${1##*/}`), once per path: 10 s each.

No real ADR has such a line. The cost falls on every full run of the checks, in CI as well. The
case needs only a list longer than a pipe holds (64 KiB): pads of 40,000 characters each still
overflow it, and the field read then takes under 2 s. The scripts
leave the template if the proposal `NUC-checks-run-by-nuc` is implemented. The human weighs a
fix against that.

## Where

- `scripts/test-sensor-binding-adrs.sh`, the case `sections-long`, line 286.
- `scripts/lib/adr.sh`, line 53; `scripts/sensor-binding-adrs.sh`, line 74.
- Found by the assessment of v0.6.0 against main, after the design revision of 2026-11-12.
