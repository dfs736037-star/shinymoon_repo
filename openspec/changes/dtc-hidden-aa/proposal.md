# Proposal: DTC Hidden AA Mirror

**Status: REVERTED** — Hidden defensive AA removed; DTC timing (`dtc-reliability`) kept.

## Why

During defensive tickbase windows, visible yaw offset is less useful than hidden angles (LuaSense pattern). Users already configure per-state AA in the builder; duplicating a defensive builder is bloat.

## What

When `defensive_tickbase` is on and `defensive_ticks >= 1`, mirror builder yaw (L/R, delay, modifier, body) to `rage.antiaim:override_hidden_*` with pitch Down (89°). Visible offset neutralized. DTC timing unchanged.

## Scope out

- Separate defensive builder UI
- Pitch combo in builder
- DTC algorithm changes

## Rollback

Revert hidden AA helpers + `aa_engine_run` branch; keep `dtc-reliability` intact.
