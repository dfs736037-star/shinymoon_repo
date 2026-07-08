# Proposal: Defensive Gating (LuaSense parity)

**Superseded by `consolidate-lc-defensive-controls`** — Game Events and Force Hide Shots moved to Break LC targets; this change retains Active States, Disablers, and Improve Fakelag only. Merged into `openspec/specs/antiaim/spec.md`.

## Why

LuaSense exposes global defensive controls (state filter, game events, hide shots LC mode, disablers, fakelag on def) without duplicating the per-state builder. shinymoon had only per-state `defensive_tickbase`.

## What

Setup tab **Defensive Gating** panel:

- Active States filter (optional; empty = all states)
- Game Events: weapon switch / reload → DT Lag Options "Always on"
- Force Hide Shots Break LC during defensive window
- Disablers: Freestanding, Manual AA, Peek Assist block DTC
- Improve Fakelag on Defensive (FL limit = 1 while defensive window open)

Integrates with existing DTC send-tick gate (`dtc-reliability`); no hidden AA.

## Scope out

- Custom/random choke sliders
- Second defensive builder
- Post-defensive clean records

## Rollback

Remove Setup gating UI + `def_*` helpers in `def_apply_force_defensive` / `aa_engine_run`.
