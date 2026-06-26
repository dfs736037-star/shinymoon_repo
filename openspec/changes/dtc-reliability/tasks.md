# Tasks: DTC Reliability Overhaul

## Group A — Timing + sample

- [x] Unify send-tick gate in `def_should_fire`; remove `window_start` bypass and `window_sustain`
- [x] Add `window_fire_armed` latch for one window_start fire per defensive window
- [x] Pass `config` (not `commit_config`) to `def_apply_force_defensive`
- [x] Sample tickbase every createmove (remove tickcount dedupe)

## Group B — Scheduler

- [x] Keep simplified `def_calc_choke_target` formula
- [x] Improve Air + Crouch early bias (crouched air apex)

## Group C — Telemetry + spec

- [x] Restore DTC debug logs gated by `setup.aa_debug`
- [x] Update `openspec/specs/antiaim/spec.md` with DTC send-tick requirements
