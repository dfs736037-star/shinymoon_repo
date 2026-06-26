# UI / Menu — shinymoon_alpha

## Purpose

Neverlose PUI menu: Home, Anti-Aim (subtabs), Misc; Apple-inspired hierarchy via `shinymoon-apple-ui` patterns.

## Structure

- **Home:** about, profile, stats, local presets, cloud library
- **Anti-Aim tab:** setup vs builder subtabs; builder uses COL1/COL2 layout buckets
- **Misc:** auxiliary HVH features

## Requirements

### Navigation

- **Requirement:** Subtab visibility MUST flow through `NAV.install` + `NAV.subtab_labels`; no orphan controls outside visibility callbacks.
- **Scenario:** Tab change — When user switches main tab, only the active tab's groups are visible.

### Labels and icons

- **Requirement:** User-facing labels SHOULD use `icon_label`, `sub_label`, or `sub_label_active` for consistency with accent/link colors.

### Apple-style polish

- **Requirement:** New menu sections SHOULD follow palettes and spacing from `shinymoon-apple-ui`; complex mockups MAY use open-design MCP before Lua implementation.

## Constraints

- Do not mix runtime angle logic into UI creation blocks.
- UI values read every tick MUST use control `:get()` in callback path, not cached once at load unless intentional.
