# Delta: Anti-Aim — Defensive Gating

## ADDED Requirements

### Defensive state gate

- **Requirement:** When Defensive Gating is enabled and Active States has selections, DTC MUST NOT fire unless the detected movement state is in the selection.
- **Scenario:** Air only selected — DTC disabled while Standing even if per-state toggle is on.

### Defensive disablers

- **Requirement:** When Defensive Gating disablers match an active condition (Freestanding, Manual AA, Peek Assist), DTC MUST NOT set `force_defensive`.
- **Scenario:** Manual AA active with Manual disabler — skip_reason `disabler`.

### Defensive game events

- **Requirement:** When Game Events include weapon switch or reload and the event occurs, DT Lag Options MUST override to "Always on" for that tick while per-state defensive is enabled.
- **Scenario:** Swap AWP → rifle with event enabled — `refs.def` Always on.

### Improve fakelag on defensive

- **Requirement:** When enabled and defensive window is open (`defensive_ticks >= 1`), Fake Lag limit MUST override to 1; MUST clear override when window closes.
- **Scenario:** Defensive window ends — fakelag override cleared.

### Force hide shots break LC

- **Requirement:** When enabled and defensive window open, Hide Shots Options MUST override to "Break LC".
- **Scenario:** Defensive ticks active — HS Break LC applied.
