# Desync Smear — design spec

Date: 2026-07-08
File: `shinymoon_alpha.lua`
Goal: a **new defensive anti-aim exploit** — make the local player harder to
resolve/backtrack by decorrelating the fake-lag backtrack trail. Standalone
feature (NOT a sub-mode of Massive Fake, which is currently broken and out of
scope for this spec).

## Problem / insight

Fake lag makes the server process every choked usercmd, so the enemy's
lag-compensation records a *trail* of N positions/angles you can be backtracked
to. Today the fake yaw is **held constant across the whole choke window**
(`apply_yaw_and_desync` redraws the Massive Fake magnitude only on `sent_tick`
and re-asserts the same value on every choked command, line ~5406–5432). Every
record in a trail therefore carries the **same** fake angle — a resolver solves
it once and is correct for the entire trail.

**Desync Smear** varies the hidden-yaw offset **per choked command**, indexed by
`globals.choked_commands`, so each record in the fake-lag trail carries a
different fake side/magnitude. A resolve that fits one record is wrong on the
next. This is a new, temporal axis *inside* the choke window that nothing else
in the file uses.

## Non-goals

- Does **not** touch `send_packet` / `no_choke` / `force_defensive`. Zero
  interaction with the Double-Tap / `defensive_tickbase` engine by construction
  (this is why the choke-window approach was chosen over a fake-lag scheduler).
- Does **not** fix or depend on Massive Fake.
- Yaw only (no pitch).

## Mechanic

Single authority preserved: `rage.antiaim:override_hidden_yaw_offset(signed)`
remains the only writer of the local hidden yaw. Smear owns its **own** write
call, and the write site is guarded so exactly one of {Smear, Massive Fake}
writes per command — **Smear wins when enabled**:

```
-- inside apply_yaw_and_desync, body_yaw-enabled branch (~line 5406)
if config["smear"] then
    local aa = rage and rage.antiaim
    if aa then
        local base   = math.max(1, math.min(180, math.abs(config["smear_amount"] or 120)))
        local window = math.max(2, get_fakelag_limit())
        local choked = globals.choked_commands or 0
        local side   = aa_engine.allow_inverter and -1 or 1
        aa:override_hidden_yaw_offset(
            shiny_smear_offset(base, choked, window, side, config["smear_pattern"])
        )
    end
elseif config["massive_fake"] then
    -- existing Massive Fake block, unchanged
end
```

Runs inside the existing `body_yaw`-enabled branch (desync requires body yaw on),
matching the Massive Fake gating. Not pcall-wrapped — matches the file's
convention for `rage.antiaim` calls.

## Sweep function

New top-level local `shiny_smear_offset(base, choked, window, side, pattern)`,
defined near `shiny_compute_shift`. Stateless (no `aa_engine` fields, no
round-reset entries). Returns the signed offset for the current command.

Patterns (dropdown, default **Alternate**):

- **Alternate** — `sign = (choked % 2 == 0) and 1 or -1; return sign * base`.
  Adjacent trail records land on opposite sides. Most aggressive.
- **Ramp** — `p = clamp(choked / (window - 1), 0, 1); return side * base * (0.6 + 0.4 * p)`.
  Sign fixed to the current desync side; magnitude ramps `0.6·base → base` across
  the window. Decorrelates magnitude only, side stable. Safest.
- **Walk** — `r = math.random()` per command; magnitude `base * (0.6 + 0.4 * r)`,
  sign from `math.random(1,2)`. Noisiest.

**Invariants** (enforced + asserted): magnitude is always `≥ 0.6 · base ≥ 0.6`,
so the function **never returns 0** (0 would flash the real angle into the
trail); result clamped to `[-180, 180]` (past 180 the fake wraps back toward
real).

## UI / config

Matches the Massive Fake structure (global control + `:create()` sub-group):

- `builder.smear` — `antiaim.builder_defensive:switch("Desync Smear", ...)`,
  default off.
- `smear_grp = builder.smear:create()`
- `builder.smear_amount` — `smear_grp:slider("Amount", 60, 180, 120)` (own
  magnitude, independent of the broken `massive_fake_amount`).
- `builder.smear_pattern` — `smear_grp:combo("Pattern", { "Alternate", "Ramp", "Walk" })`
  (the file's dropdown idiom; `:get()` returns the selected string), default `"Alternate"`.
- Visibility callback: `builder.smear:set_callback` → `smear_grp:visibility(builder.smear:get())`.

Persistence: add `"smear"`, `"smear_amount"`, `"smear_pattern"` to
`AA.builder_schema.base_keys` (~line 908). These are **global** controls (like
`massive_fake`), so they are NOT added to `per_state_keys` — save/load handles
them automatically via the existing base_keys path.

Config keys consumed: `config["smear"]`, `config["smear_amount"]`,
`config["smear_pattern"]`.

## Anti-Brute interaction

The Anti-Brute "Fake limit" substitution is currently skipped when Massive Fake
is on (`not config["massive_fake"]`, lines ~5262 and ~5335). Extend both to
`not (config["massive_fake"] or config["smear"])` so Anti-Brute's fakelimit
doesn't clobber the Smear magnitude.

## Safety / calibration / verification

- Gated behind `body_yaw` on + the default-off `smear` toggle → stock defaults
  unchanged.
- Debug line behind `setup.aa_debug` (matches AA debug convention): print
  `pattern`, `choked/window`, `signed` when the panel is on.
- **Calibration knob (hardware/engine reality):** the server-side animation
  layer may not reproduce a per-tick fake faithfully at the fastest sweep. The
  pattern dropdown + amount are the tuning levers; **Alternate** is documented
  as the aggressive/less-safe extreme, **Ramp** as the safe default-if-jittery.
- **Runnable check:** game-embedded Lua has no interpreter in this env, so a
  load-time `assert` block (next to the definition, matching other modules)
  sanity-checks `shiny_smear_offset`:
  - `Alternate`: sign at `choked=0` is opposite sign at `choked=1`.
  - never returns 0 for `base=120` across `choked = 0..window`.
  - `math.abs(result) <= 180` for all patterns.

## Files touched

- `shinymoon_alpha.lua` only:
  - UI block near line 1324 (add Smear controls after Massive Fake).
  - `base_keys` list (~908).
  - `shiny_smear_offset` definition + load-time assert (near `shiny_compute_shift`, ~4947).
  - Write-site guard in `apply_yaw_and_desync` (~5406).
  - Anti-Brute skip conditions (~5262, ~5335).

No new files, no new dependencies, no `send_packet`/`aa_engine` state.
