# The setup clears the template's own open work

Observed: the template plans its own work in its tree, under docs/plan/ and docs/backlog/, as
ADR-0006 asks of every project. A project created from the template copies that tree, so it would
take the template's open tickets and backlog entries as its own; the setup's close removes neither.
For v0.8.0 the open work was kept off main on a branch of its own instead.

Where: close_setup in scripts/test-template-setup.sh, TEMPLATE-SETUP.md, ADR-0006.
