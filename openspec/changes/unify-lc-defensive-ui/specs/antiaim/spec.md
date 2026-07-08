# Delta: Anti-Aim — Unify LC & Defensive guards

## ADDED

### Single master guard

- **Requirement:** Runtime MUST use `lc_defense_enabled()` (reads `setup.lc_defense`) as the sole master guard for LC-event overrides, DTC state/disabler gates, and improve fakelag on defensive.
- **Scenario:** Given master OFF, When createmove runs, Then no LC ref overrides, DTC state gate passes all states, disablers inactive, improve fakelag inactive.

### Empty LC targets

- **Requirement:** When master ON and LC Targets has **no** selection, `lc_apply_break_lc_overrides` MUST NOT apply HS or DT ref overrides.
- **Scenario:** Given master ON, targets empty, weapon switch condition active, When swap occurs, Then `hideshot_config` and `refs.def` are not forced by LC path.

## MODIFIED

### Defensive gating guard

- **Requirement:** When Setup **LC & Defensive** master is enabled, DTC MUST respect **Active States** and **Disablers** (same semantics as former Defensive Gating panel).
- **Scenario:** Given master ON, Active States = Air only, player Standing, When DTC would fire, Then `skip_reason` = `state_gate`.

### Break LC guard

- **Requirement:** LC-event condition evaluation and ref overrides MUST require `lc_defense_enabled()` (not a separate Break LC master).
- **Scenario:** Given master ON, HS target selected, weapon switch condition active, When swap detected, Then `hideshot_config` = Break LC at end of `aa_engine_run`.

### Improve fakelag

- **Requirement:** Improve Fakelag on Defensive MUST run only when master ON and sub-switch enabled; behavior unchanged (FL = 1 while `defensive_ticks >= 1`).
- **Scenario:** Master OFF — fakelag override never applied by this path.

### Writer authority

- **Requirement:** Unchanged — LC path MUST NOT set `force_defensive`; gating path MUST NOT duplicate LC-event writes to `hideshot_config` / `refs.def` for swap/reload.
- **Scenario:** Weapon swap with HS + DT targets — single write path in `lc_apply_break_lc_overrides`.

## REMOVED

### Dual master runtime guards

- **Requirement:** ~~Separate `lc_break_lc_enabled()` and `def_gating_enabled()` masters.~~
- **Scenario:** Replaced by `lc_defense_enabled()`.
