# Tasks: Unify LC & Defensive UI

## 1. UI — master control

- [x] 1.1 Add `setup.lc_defense` switch + `lc_def_grp` under `antiaim.setup_r` (~560)
- [x] 1.2 Move `break_lc_conditions`, `break_lc_targets`, `break_lc_no_quickpeek` under unified group (keep `setup.*` key names for ponytail)
- [x] 1.3 Move `def_conditions`, `def_disablers`, `def_improve_fakelag` under same group
- [x] 1.4 Remove `setup.break_lc` and `setup.def_gating` master switches
- [x] 1.5 Implement `update_lc_defense_visibility`; wire callbacks; replace `update_break_lc_visibility` / `update_def_gating_visibility`
- [x] 1.6 Update `cfg_refresh_ui` to call unified visibility

## 2. Runtime — single guard

- [ ] 2.1 Add `lc_defense_enabled()`; delete or alias `lc_break_lc_enabled` / `def_gating_enabled`
- [ ] 2.2 Update `lc_event_conditions_active`, `lc_apply_break_lc_overrides`, `def_state_allowed`, `def_disabler_blocks`, `apply_defensive_runtime_overrides`
- [ ] 2.3 Fix `lc_hs_target_enabled` / `lc_dt_target_enabled`: empty targets → false (no overrides)

## 3. CFG / presets

- [ ] 3.1 Document preset re-save after upgrade; add post-load note in log if master default OFF
- [ ] 3.2 Optional ponytail shim: after `pui.load`, set master ON if legacy behavior detectable without fragile hacks

## 4. Spec merge (post-validate)

- [ ] 4.1 Update `openspec/specs/ui/spec.md` — single LC & Defensive section
- [ ] 4.2 Update `openspec/specs/antiaim/spec.md` — master guard + empty targets

## 5. Validation (in-game)

- [ ] 5.1 Master ON + HS target + weapon switch — Break LC on swap only
- [ ] 5.2 Master ON + DT target + defensive_tickbase — DT Lag Always on on swap; DTC send-tick unchanged
- [ ] 5.3 Master ON + Air-only Active States — Standing gets `state_gate`; LC still works on swap
- [ ] 5.4 Master ON + Peek disabler + peek active — DTC blocked
- [ ] 5.5 Master ON + improve fakelag — FL=1 in defensive window
- [ ] 5.6 Master OFF — no LC overrides, no gates, no improve FL
- [ ] 5.7 Load old preset — children restore; user confirms master state
