# Design: DTC Hidden AA Mirror

## Flow

```mermaid
flowchart TD
    CM[aa_engine_run] --> DUS[def_update_state]
    CM --> PRI[priority modes clear hidden]
    CM --> BUILDER[builder path]
    BUILDER --> FS{freestanding?}
    FS -->|yes| FSAA[normal yaw clear hidden]
    FS -->|no| GATE{def_aa_active and yaw on?}
    GATE -->|yes| HIDDEN[def_apply_hidden_aa]
    GATE -->|no| NORMAL[visible offset path]
    CM --> DTC[def_apply_force_defensive unchanged]
```

## Mirror mapping

Reuse `apply_yaw_and_desync` + `apply_modifier` → hidden yaw. Pitch fixed 89. Body limits unchanged.

## Files

- [`shinymoon_alpha.lua`](shinymoon_alpha.lua): helpers ~L5260, wire ~L5811, debug ~L6124
