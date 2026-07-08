# Proposal: Unify Break LC and Defensive Gating UI

## Why

Users ask whether **Break LC** and **Defensive Gating** are "the same thing" — and they overlap in purpose: both tune **when defensive / lag-compensation behavior is allowed** during HVH.

| Concern | Break LC (today) | Defensive Gating (today) |
|---------|------------------|---------------------------|
| When (events) | Weapon switch, reload, Always | — (removed from gating in consolidate) |
| What refs change | HS Break LC, DT Lag Always on | — |
| When (movement state) | — | Active States filter for DTC |
| When (context) | — | Disablers (FS, manual, peek) |
| Runtime side effect | `hideshot_config`, `refs.def` overrides | `force_defensive` gates, improve fakelag |

Runtime was already consolidated (`consolidate-lc-defensive-controls`): one writer for LC-event refs, gating owns DTC guards only. **UI still shows two master switches**, so users enable one, disable the other, and get half the behavior they expect — or think the feature is broken.

**LuaSense parity:** one `defensive_settings` group (conditions, game events, force HS, disablers) — not two top-level toggles.

**Intent:** one master **LC & Defensive** control in Setup; child settings unchanged; single `lc_defense_enabled()` guard in runtime.

## What

1. **Replace** `setup.break_lc` + `setup.def_gating` master switches with **`setup.lc_defense`** (one switch + one child group).
2. **Re-parent** existing child controls under the unified group (no behavior rename):
   - LC Events (conditions listable)
   - LC Targets (HS Break LC, DT Lag Always on)
   - Quickpeek guard (Always only)
   - DTC Active States
   - DTC Disablers
   - Improve Fakelag on Defensive
3. **Runtime:** `lc_defense_enabled()` replaces `lc_break_lc_enabled()` and `def_gating_enabled()`; remove dual-master guards.
4. **Fix empty LC Targets:** when master ON and no target selected, apply **no** LC ref overrides (remove legacy "empty = HS on" default).
5. **Preset shim:** on `CFG.import_snapshot` / `pui.load`, if legacy keys exist, master ON when `break_lc OR def_gating` was true; map child values as today.

## Affected domains

- **ui** — Anti-Aim Setup column (`antiaim.setup_r`), visibility callbacks, `cfg_refresh_ui`
- **antiaim** — `lc_event_conditions_active`, `lc_apply_break_lc_overrides`, `def_state_allowed`, `def_disabler_blocks`, `apply_defensive_runtime_overrides`
- **cfg** — optional import compatibility for old preset control names

## Scope out

- DTC send-tick algorithm (`dtc-reliability`)
- Per-state `defensive_tickbase` builder changes
- Hidden AA / DTC hidden yaw routing
- Re-adding force HS only during defensive window (LuaSense had this; consolidate moved it to LC targets)
- open-design mockup unless layout review requested (listables + one switch — low risk)

## Rollback

Restore two master switches and `lc_break_lc_enabled` / `def_gating_enabled` split; revert empty-target behavior if needed. No builder schema changes — rollback is UI + guard helpers only.

## In-game test

1. Master ON, HS target + Weapon switch — HS Options = Break LC on swap only.
2. Master ON, DT target + `defensive_tickbase` ON — DT Lag Always on on swap; DTC still send-tick gated.
3. Master ON, Active States = Air only, Standing — DTC `skip_reason` = `state_gate`; LC overrides still work on swap if configured.
4. Master ON, Disabler Peek Assist + peek active — DTC blocked; LC overrides independent.
5. Master ON, Improve Fakelag — FL limit 1 during defensive window.
6. Master OFF — no LC overrides, no state/disabler DTC gates, no improve fakelag.
7. Preset saved with old dual switches — loads with correct master + children.

## Callbacks touched

- `createmove` → `aa_cm_handler` → `aa_engine_run` (order unchanged: LC overrides → improve FL → `def_apply_force_defensive`)
- `render` — none
- Setup visibility callbacks — merged into `update_lc_defense_visibility`
