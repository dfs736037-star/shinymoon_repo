# Delta: UI — Consolidate LC controls

## REMOVED Requirements

### Defensive gating LC duplicates

- **Requirement:** Setup MUST NOT expose separate `def_game_events` or `def_force_hideshot` controls.
- **Scenario:** Defensive Gating panel shows only Active States, Disablers, Improve Fakelag.

## ADDED Requirements

### Break LC targets control

- **Requirement:** Break LC group MUST include a listable **Targets** with options Hide Shots Break LC and DT Lag Always on; visible when Break LC master switch is on.
- **Scenario:** User enables Break LC — Conditions and Targets both visible.

### Visibility parity

- **Requirement:** Break LC quickpeek guard switch MUST remain visible only when Always condition is selected (existing behavior preserved).
- **Scenario:** Always deselected — quickpeek switch hidden.

## MODIFIED Requirements

### Setup section layout

- **Requirement:** Anti-Aim Setup column order SHOULD keep Break LC above Defensive Gating so users configure LC events before DTC filters.
- **Scenario:** User opens Setup — Break LC expanded targets appear before Defensive Gating slim panel.
