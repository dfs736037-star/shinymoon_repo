# Anti-Aim — shinymoon_alpha

## Purpose

HVH anti-aim: per-state setup, builder overrides, defensive tickbase, protections, and event-driven angle logic.

## State model

States (from `AA.state_labels`):

| State | Override | Builder |
|-------|----------|---------|
| Global | no | yes |
| Standing, Moving, Crouching, Crouch Moving, Air, Air + Crouch, Slow Walk | yes | yes |

## Requirements

### Builder visibility

- **Requirement:** Builder UI panels MUST respect `NAV.install` visibility: builder tab selected, state override active, controls shown only when `show_controls` is true.
- **Scenario:** State switch — When user changes builder state, only that state's override switch and controls are visible.

### Builder schema

- **Requirement:** New builder keys MUST extend `AA.builder_schema` (base_keys, slider_groups) and follow existing key naming in setup tables.
- **Scenario:** New slider — When adding a builder slider, it MUST appear in schema, setup loop, and runtime read path for the target state.

### Defensive

- **Requirement:** Defensive features MUST guard on enable toggles and valid local player / tickbase preconditions before mutating angles or tickbase.
- **Scenario:** Defensive off — When defensive toggle is disabled, no defensive mutation runs on createmove.

### DTC send-tick gate

- **Requirement:** Defensive Ticks Correction MUST set `cmd.force_defensive` only when `globals.choked_commands == 0` (send tick).
- **Scenario:** Mid-choke tick — When choked_commands > 0, DTC MUST NOT set force_defensive even if defensive window is active.

### DTC choke boundary

- **Requirement:** DTC fire decisions MUST align with the computed choke boundary (`prev_choke >= fire_choke` on send tick), except the latched one-shot window_start fire after a new shift is detected.
- **Scenario:** Defensive window opens — First fire occurs on a send tick at or after the choke boundary, not while building choke.

### DTC toggle off

- **Requirement:** When `defensive_tickbase` is disabled, DTC MUST clear force_defensive and call allow_defensive(false).
- **Scenario:** Toggle off — No defensive mutation on createmove.

### Defensive gating

- **Requirement:** When Setup **Defensive Gating** is enabled, DTC MUST respect **Active States** filter and **Disablers** only; LC-event overrides MUST NOT live in this panel.
- **Scenario:** State gate — Standing not in Active States list → skip_reason `state_gate`.
- **Requirement:** **Improve Fakelag on Defensive** MUST override Fake Lag limit to 1 while the defensive window is open (`defensive_ticks >= 1`); MUST clear override when the window closes.
- **Scenario:** Defensive window ends — fakelag override cleared.

### Break LC

- **Requirement:** Break LC MUST use shared condition evaluation via `lc_event_conditions_active` (weapon switch, reload, Always + quickpeek guard on Always).
- **Scenario:** Weapon switch selected — When `m_flNextAttack > curtime`, conditions active.
- **Requirement:** Break LC **Targets** MUST support **Hide Shots Break LC** and **DT Lag Always on**; HS applies `hideshot_config` Break LC when conditions match; DT applies `refs.def` Always on only when per-state `defensive_tickbase` is on and defensive gating (state filter + disablers) would not block DTC.
- **Scenario:** DT target + swap with `defensive_tickbase` off — `refs.def` not forced Always on.
- **Requirement:** LC-event ref overrides MUST be applied once per tick via `lc_apply_break_lc_overrides` at the end of `aa_engine_run` (after builder clears `refs.def`).
- **Scenario:** Weapon swap with HS + DT targets — both refs set in one path; no duplicate override from Defensive Gating.

### Yaw random methods

- **Requirement:** Builder `yaw_random_methods` MUST support Default, Sinusoidal, and Chaotic; Sinusoidal/Chaotic use per-state frequency/amplitude or r_min/r_max/scale sliders.
- **Scenario:** Chaotic selected — yaw offset varies with curtime-based chaotic function.

### Amnesia body speed

- **Requirement:** When `speed_options` is Amnesia and fake option is Jitter, body yaw MUST periodically disable/enable on `amnesia_tick_speed` sent ticks.
- **Scenario:** Amnesia tick 16 — body yaw toggles every 16 send ticks.

### Antibrute shot geometry

- **Requirement:** `bullet_impact` antibrute MUST use geometry + trace validation (`ab_shot_fired_at_local`) before triggering anti-bruteforce.
- **Scenario:** Impact far from head line — antibrute not triggered.

### Protections

- **Requirement:** Protection modules MUST not fight each other; order of application MUST match existing EVENTS order unless design explicitly changes priority.
- **Requirement:** Break LC and Defensive Gating MUST NOT both write `hideshot_config` or `refs.def` for the same LC event; Defensive Gating owns DTC guards and improve fakelag only.

## Constraints

- Neverlose anti-aim API: follow docs at https://docs-csgo.neverlose.cc/
- Mode strings and control names MUST stay consistent between UI labels and runtime comparisons.
