# Core — shinymoon_alpha

## Purpose

Shared infrastructure: Neverlose API wrapper, logging, event registry, navigation, and config/preset plumbing.

## Requirements

### NL wrapper

- **Requirement:** All Neverlose API access MUST go through the `NL` table.
- **Scenario:** UI creation — When a menu control is added, it MUST use `NL.ui.create` and existing icon/label helpers.

### EVENTS registry

- **Requirement:** Callbacks MUST register via `EVENTS.add` / `EVENTS.set_handler` and activate through `EVENTS.register_all`.
- **Scenario:** Handler replacement — When updating a callback, `EVENTS.set_handler` MUST replace the existing entry for the same event+tag without duplicating handlers.

### Logging

- **Requirement:** User-visible debug output SHOULD use `shinymoon_log` / `shinymoon_log_print`; action tracing MAY use `log_action` / `log_fail`.

### Presets / CFG

- **Requirement:** Preset load/save/export/import MUST preserve builder state and UI control references without stale nil access after reload.

## Constraints

- Single primary script file: `shinymoon_alpha.lua`.
- Legacy `.lua` references are read-only unless user explicitly requests edits.
