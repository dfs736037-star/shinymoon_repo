# Delta: Anti-Aim — Consolidate LC controls

## REMOVED Requirements

### Defensive gating game events

- **Requirement:** ~~When Game Events include weapon switch or reload, DT Lag Options MUST override to "Always on".~~
- **Scenario:** Moved to Break LC targets (see ADDED).

### Force hide shots via defensive gating

- **Requirement:** ~~When `def_force_hideshot` enabled and defensive window open, Hide Shots Options MUST override to "Break LC".~~
- **Scenario:** Replaced by Break LC HS target + shared conditions.

## MODIFIED Requirements

### Defensive gating

- **Requirement:** When Setup **Defensive Gating** is enabled, DTC MUST respect **Active States** filter and **Disablers** only; LC-event overrides MUST NOT live in this panel.
- **Scenario:** Gating ON with Air selected — Standing skips DTC; swap/reload LC behavior unchanged if Break LC configured.

### Protections

- **Requirement:** LC-event ref overrides (`hideshot_config`, `refs.def` for Always on) MUST be applied from a single code path per createmove to avoid override fights.
- **Scenario:** Break LC HS + DT targets both on, weapon swap — both refs set once in `misc_on_break_lc`; `aa_engine_run` does not rewrite them for the same event.

## ADDED Requirements

### Shared LC event conditions

- **Requirement:** Weapon switch, reload, and Always conditions MUST be evaluated by one helper (`lc_event_conditions_active`) used by Break LC runtime.
- **Scenario:** Given Weapon switch selected, When `m_flNextAttack > curtime`, Then helper returns true.

### Break LC targets

- **Requirement:** Break LC panel MUST expose target list: **Hide Shots Break LC** and **DT Lag Always on**.
- **Scenario:** Given HS target selected and conditions active, When swap detected, Then `hideshot_config` = Break LC.

### DT lag target guard

- **Requirement:** DT Lag Always on target MUST apply only when resolved state config has `defensive_tickbase` enabled and defensive gating disablers do not block DTC.
- **Scenario:** Given DT target + swap, defensive_tickbase off for current state, Then `refs.def` not forced Always on.

### Improve fakelag on defensive

- **Requirement:** Unchanged — remains under Defensive Gating; applies FL=1 during defensive window only.
