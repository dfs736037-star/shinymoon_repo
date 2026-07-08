# Tasks: DTC Hidden AA Mirror

**REVERTED** — see proposal.md. Code aligned in shinymoon_alpha.lua (helpers + aa_engine_run branch removed).

## Group A — Helpers

- [x] ~~`def_aa_is_active`, `def_clear_hidden_aa`, `def_resolve_hidden_yaw`, `def_apply_hidden_aa`~~ removed
- [x] ~~`aa_engine.def.hidden_active`, `hidden_yaw`~~ removed

## Group B — Wire

- [x] Branch `aa_engine_run` hidden vs normal — reverted to visible-only path
- [x] ~~`def_clear_hidden_aa` in priority modes~~ removed

## Group C — Debug + spec

- [x] Debug panel hidden fields removed
- [x] Main spec has no hidden-AA requirements (dtc-reliability only)