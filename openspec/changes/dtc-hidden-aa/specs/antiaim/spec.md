# Anti-Aim Delta — Hidden Defensive AA

## ADDED Requirements

### Defensive hidden AA mirror

- **Requirement:** When `defensive_tickbase` is enabled and `defensive_ticks >= 1`, builder yaw MUST route through hidden angles (`refs.hidden` + `override_hidden_pitch/yaw`) using the active state config (yaw, delay, modifier, body).
- **Scenario:** Defensive window open — visible offset ~0, hidden yaw reflects builder L/R and modifier.

### Defensive hidden AA clear

- **Requirement:** When the defensive window closes or priority AA modes take over, hidden overrides MUST clear on the same tick.
- **Scenario:** Window ends — `hidden_active` false, normal visible AA resumes.

### Defensive hidden pitch

- **Requirement:** Hidden pitch during defensive mirror MUST be Down (89°).
- **Scenario:** Hidden active — `override_hidden_pitch(89)`.
