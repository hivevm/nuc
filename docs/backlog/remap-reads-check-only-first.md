# remap.sh reads --check only as its first argument and rewrites the tree when it comes later

## Observed

`.agents/skills/normalize/remap.sh` takes `--check` for a dry run only when it is the first
argument. Anything after the map is ignored, so `remap.sh <map> --check` applies the map and
rewrites the tree instead of reporting what it would change. A human who adds the option at the
end of the line gets the opposite of what they asked for. The scripts under `scripts/` refuse
an argument they do not read (`scripts/lib/root.sh`, `rest_args`); `remap.sh` reads its own.

## Where

- `.agents/skills/normalize/remap.sh`, its argument handling.
- Found by the implementer of the small fixes for v0.10.0, 2026-11-13.
