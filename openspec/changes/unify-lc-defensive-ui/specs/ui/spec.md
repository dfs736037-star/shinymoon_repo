# Delta: UI — Unify LC & Defensive

## REMOVED

### Dual master switches

- **Requirement:** ~~Break LC and Defensive Gating MUST be separate master switches in Setup.~~
- **Scenario:** ~~User enables Break LC — Conditions and Targets visible under Break LC only.~~

- **Requirement:** ~~Break LC SHOULD appear above Defensive Gating in the Setup column.~~

## ADDED

### LC & Defensive master control

- **Requirement:** Anti-Aim Setup MUST expose a single master switch **LC & Defensive** (`setup.lc_defense`) replacing separate Break LC and Defensive Gating masters.
- **Scenario:** Given user opens Setup, When master is OFF, Then all LC & Defensive child controls are hidden.

### Unified child group

- **Requirement:** When master is ON, the group MUST show in order:
  1. LC Events (weapon switch, reload, always)
  2. LC Targets (Hide Shots Break LC, DT Lag Always on)
  3. Quickpeek guard (visible only when Always is selected in LC Events)
  4. DTC Active States
  5. DTC Disablers
  6. Improve Fakelag on Defensive
- **Scenario:** Given master ON and Always not selected, When user views the group, Then quickpeek guard is hidden.

### Labels and icons

- **Requirement:** Master switch SHOULD use `icon_label` consistent with Setup column (e.g. shield-halved + accent).
- **Scenario:** Master visible on Anti-Aim Setup right column between Avoid Backstab and Hide Head (same slot as former Break LC).

## MODIFIED

### Visibility callback

- **Requirement:** One visibility callback (`update_lc_defense_visibility`) MUST drive master group visibility; `cfg_refresh_ui` MUST invoke it after preset load.
- **Scenario:** Preset load — child visibility matches master state without tab switch.
