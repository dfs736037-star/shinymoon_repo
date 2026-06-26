# Visuals — shinymoon_alpha

## Purpose

On-screen visuals: setup/state/refs/features via `VIS` bucket and `VIS.install_switch_feature` pattern.

## Requirements

### Feature install pattern

- **Requirement:** Toggleable visual features SHOULD use `VIS.install_switch_feature(def)` with enable ref, refresh callback, and guarded render/createmove hooks.
- **Scenario:** Toggle off — When feature switch is false, associated render handlers MUST early-return without drawing.

### State and refs

- **Requirement:** `VIS.state` fields MUST reset on map change / round start where applicable to avoid stale entity references.

## Constraints

- Render callbacks MUST be registered through EVENTS registry.
- Performance: avoid per-entity full scans every frame unless existing pattern already does so.
