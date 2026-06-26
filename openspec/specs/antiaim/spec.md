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

### Protections

- **Requirement:** Protection modules MUST not fight each other; order of application MUST match existing EVENTS order unless design explicitly changes priority.

## Constraints

- Neverlose anti-aim API: follow docs at https://docs-csgo.neverlose.cc/
- Mode strings and control names MUST stay consistent between UI labels and runtime comparisons.
