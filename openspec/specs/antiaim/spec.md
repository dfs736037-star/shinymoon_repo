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

### Protections

- **Requirement:** Protection modules MUST not fight each other; order of application MUST match existing EVENTS order unless design explicitly changes priority.

### Pitch

- **Requirement:** Pitch MUST be fixed to **Down** (-89°) on AA runtime paths: builder, freestanding, manual, mouse, hide head.
- **Requirement:** Troll AA MUST use pitch **Disabled** (0°) — not Down.
- **Requirement:** Builder MUST NOT expose a per-state pitch control.

### Post-defensive clean

- **Requirement:** When a defensive window closes (`defensive_ticks` transitions from >0 to 0), the AA engine MUST run a short post-defensive clean (2 sent ticks: neutral offset + inverter flip).
- **Scenario:** Window ends — Offset is 0 and side flips once before resuming builder yaw.

### DTC telemetry

- **Requirement:** When AA debug is enabled, DTC fire/armed counters and success rate MUST be visible on the debug panel.

## Constraints

- Neverlose anti-aim API: follow docs at https://docs-csgo.neverlose.cc/
- Mode strings and control names MUST stay consistent between UI labels and runtime comparisons.
