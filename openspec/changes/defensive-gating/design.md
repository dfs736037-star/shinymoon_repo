# Design: Defensive Gating

## Flow

```mermaid
flowchart TD
    CM[createmove aa_engine_run] --> GATE{def_gating enabled?}
    GATE -->|no| DTC[def_apply_force_defensive unchanged gates]
    GATE -->|yes| ST[state in def_conditions?]
    ST -->|no| SKIP[skip_reason state_gate]
    ST -->|yes| DIS{disabler active?}
    DIS -->|yes| SKIP2[skip_reason disabler]
    DIS -->|no| EVT[game_event_boost weapon swap/reload]
    EVT --> RT[apply_defensive_runtime_overrides]
    RT --> DTC
    DTC --> FD[cmd.force_defensive send-tick only]
```

## Integration points

| Hook | File region | Behavior |
|------|-------------|----------|
| `def_state_allowed` | before `def_should_fire` | Blocks DTC when state not in filter |
| `def_disabler_blocks` | `aa_engine.def.gating_blocked` | Blocks DTC when FS/manual/peek active |
| `def_update_game_event_boost` | end of `aa_engine_run` | Sets `refs.def` Always on on swap/reload |
| `apply_defensive_runtime_overrides` | end of `aa_engine_run` | FL=1, HS Break LC during def window |

Per-state `defensive_tickbase` remains required; gating adds global filters only.
