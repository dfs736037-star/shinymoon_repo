# Tasks: Consolidate LC + Defensive Gating

## 1. Shared helpers (CORE / AA)

- [x] 1.1 Add `weapon_is_reloading(weapon)` — delete `misc_weapon_reloading` / `def_weapon_reloading` duplicates
- [x] 1.2 Add `lc_event_conditions_active(me)` using `setup.break_lc_conditions` + quickpeek guard
- [x] 1.3 Add `lc_break_lc_enabled()` guard on master switch

## 2. UI — Break LC expansion

- [x] 2.1 Add `setup.break_lc_targets` listable: Hide Shots Break LC, DT Lag Always on
- [x] 2.2 Wire visibility in `update_break_lc_visibility`
- [x] 2.3 Remove `setup.def_game_events` and `setup.def_force_hideshot` + callbacks from Defensive Gating group

## 3. Runtime — single LC writer

- [x] 3.1 Refactor `misc_on_break_lc` to apply HS and/or DT lag targets via shared helper
- [x] 3.2 DT Lag target: gate on `resolve_state_config` + `defensive_tickbase` + gating disablers (read-only check, no DTC fire)
- [x] 3.3 Remove `def_update_game_event_boost` and HS/DT writes from `apply_defensive_runtime_overrides`
- [x] 3.4 Slim `apply_defensive_runtime_overrides` to improve fakelag only
- [x] 3.5 Clear `aa_engine.def.game_event_boost` / `last_weapon_class` if unused after removal

## 4. Spec merge

- [x] 4.1 Update `openspec/specs/antiaim/spec.md` — remove def game events / force HS; add Break LC targets
- [x] 4.2 Update `openspec/specs/ui/spec.md` if target control documented
- [x] 4.3 Mark `openspec/changes/defensive-gating/` superseded note in its proposal (optional comment only)

## 5. Validation (in-game)

- [x] 5.1 Break LC + HS target + Weapon switch — HS Break LC on swap only
- [x] 5.2 Break LC + DT target + defensive_tickbase ON — DT Lag Always on on swap; DTC still send-tick gated
- [x] 5.3 Defensive Gating Air-only — DTC blocked Standing; Break LC still fires on swap
- [x] 5.4 Break LC OFF — no HS/DT overrides from LC path; improve fakelag still works via gating
- [x] 5.5 AA Debug Panel — no duplicate override flicker on swap tick
