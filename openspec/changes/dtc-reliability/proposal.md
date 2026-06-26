# Proposal: DTC Reliability Overhaul

## Why

Historical telemetry (`docs/shinymoon_records.md`) shows DTC fires failing when `force_defensive` is set mid-choke (`shift=0 choke=12/12`) and succeeding only on send ticks (`shift>0 choke=0`). Current code still bypasses the send-tick gate on `window_start` and allows permissive `window_sustain` fires.

## What

- Fire `force_defensive` only on send ticks (`choked_commands == 0`) at choke boundaries.
- Sample tickbase every createmove (no tickcount dedupe).
- Simplify in-window fire logic; remove sustain spam.
- Use resolved state config for DTC (not freestanding commit override).
- Restore debug-only DTC telemetry behind AA Debug Panel.

## Scope out

- Post-defensive clean records (Gingersense).
- Custom/random choke sliders (Frost/LuaSense).
- Enemy profiling refactor.

## Rollback

Revert `shinymoon_alpha.lua` DTC block (~L4788–5391) and remove `openspec/changes/dtc-reliability/`.
