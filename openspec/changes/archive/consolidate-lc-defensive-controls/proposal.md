# Proposal: Consolidate Break LC and Defensive Gating overlap

## Why

After porting LuaSense **Defensive Gating**, Setup now has two panels that partially do the same job:

| Control | Break LC | Defensive Gating |
|---------|----------|------------------|
| Weapon switch condition | `setup.break_lc_conditions` | `setup.def_game_events` |
| Weapon reload condition | same list | same list |
| Hide Shots → Break LC | always when Break LC on | `def_force_hideshot` only during defensive window |
| DT Lag → Always on | — | `def_game_events` when per-state `defensive_tickbase` on |

Both paths duplicate swap/reload detection (`misc_on_break_lc` vs `def_update_game_event_boost`) and both write `refs.hideshot_config`. Users must configure the same events twice; order is `misc_run` → `aa_engine_run`, so the second writer can silently override the first.

**Intent:** one shared LC-event condition model, one writer authority per ref, Defensive Gating keeps only what Break LC cannot express (state filter, disablers, improve fakelag).

## What

1. **Shared helper** `lc_event_conditions_active(me)` — weapon switch, reload, always (+ quickpeek guard for Always).
2. **Expand Break LC panel** (rename label optional: **LC Control**):
   - Keep existing conditions listable.
   - Add targets listable: **Hide Shots Break LC**, **DT Lag Always on** (DT target requires per-state `defensive_tickbase` + gating not blocked).
3. **Remove from Defensive Gating:** `def_game_events`, `def_force_hideshot` (UI + runtime).
4. **Keep in Defensive Gating:** Active States, Disablers, Improve Fakelag on Defensive.
5. **Single reload helper** — merge `misc_weapon_reloading` / `def_weapon_reloading`.

## Affected domains

- **ui** — Setup controls reshuffle
- **antiaim** — `apply_defensive_runtime_overrides`, remove `def_update_game_event_boost` weapon logic from AA-only path
- **misc** — `misc_on_break_lc` becomes orchestrator for HS + optional DT lag override
- **core** — shared condition helper (ponytail: one function, two call sites)

## Scope out

- Per-state defensive builder changes
- DTC send-tick algorithm (`dtc-reliability`)
- Hidden AA
- Custom choke sliders

## Rollback

Revert shared helper + Break LC targets; restore `def_game_events` / `def_force_hideshot` controls and previous dual-path runtime.

## In-game test

1. Break LC ON, HS target ON, Weapon switch — HS Options = Break LC on swap tick.
2. Same + DT Lag target ON, Standing builder `defensive_tickbase` ON — DT Lag Options = Always on on swap (DTC still send-tick gated).
3. Defensive Gating ON, Air only in Active States, Standing — DTC skip_reason `state_gate`; Break LC still works independently.
4. Both HS + DT targets OFF — no overrides; NL defaults restored.
