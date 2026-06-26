# Anti-Aim Delta — DTC Reliability

## ADDED Requirements

### DTC send-tick gate

- **Requirement:** Defensive Ticks Correction MUST set `cmd.force_defensive` only when `globals.choked_commands == 0` (send tick).
- **Scenario:** Mid-choke tick — When choked_commands > 0, DTC MUST NOT set force_defensive even if defensive window is active.

### DTC choke boundary

- **Requirement:** DTC fire decisions MUST align with the computed choke boundary (`prev_choke >= fire_choke` on send tick), except the latched one-shot window_start fire after a new shift is detected.
- **Scenario:** Defensive window opens — First fire occurs on a send tick at or after the choke boundary, not while building choke.

### DTC toggle off

- **Requirement:** When `defensive_tickbase` is disabled, DTC MUST clear force_defensive and call allow_defensive(false).
- **Scenario:** Toggle off — No defensive mutation on createmove.
