# Design — Anticipation Rework: Adversarial Convergence-Evasion

Date: 2026-07-09
File: `shinymoon_alpha.lua`
Status: approved (brainstorming)

## Scope

Two independent changes in one pass:

1. **Remove** the Massive Fake and Desync Smear features entirely (dead/broken
   defensive UI + their shared `override_hidden_yaw_offset` bypass).
2. **Rework** the Anticipation feature into an "Adversarial Convergence-Evasion"
   predictor: fully automatic lead (no slider), 2nd-order + aim-angle prediction,
   a hazard-integral scorer, an adversarial predict-the-predictor term, and a
   confidence gate.

Both preserve the existing single-writer contract into `compute_automatic_yaw`
and the "can only go inert, never crash" guarantee.

---

## Part 1 — Removal of Massive Fake + Desync Smear

Mechanical deletion. Every reference (line numbers approximate, resolve by
symbol):

| Location | What | Action |
|---|---|---|
| ~908–909 | config-key list `"massive_fake","massive_fake_amount","smear","smear_amount","smear_pattern"` | delete those keys |
| ~1325–1351 | `builder.massive_fake` switch + group + amount slider; `builder.smear` switch + group + amount slider + pattern combo | delete both blocks + their explanatory comments |
| ~1394–1400 | `massive_fake:set_callback` and `smear:set_callback` visibility callbacks | delete |
| ~3200 | `massive_fake_mag = 0` in `aa_engine` init | delete |
| ~3323 | `"massive_fake_mag"` in the teleport/reset field list | delete |
| ~5260–5294 | `shiny_smear_offset` function + its load-time asserts/loop | delete |
| ~5459–5505 | the whole hidden-yaw bypass block (`if config["smear"] … elseif config["massive_fake"] … end`) + its comment | delete |

Two guards go **vacuous** once both keys are gone and must collapse, not linger:

- ~5321 and ~5394: `if table_selection_has(config["antibrute_method"], "Fake limit") and not (config["massive_fake"] or config["smear"]) then`
  → `if table_selection_has(config["antibrute_method"], "Fake limit") then`
- ~5432: `if not config["massive_fake"] then` (wrapping the fake-left/right random
  reduction) → remove the `if`, keep its body unconditional.

**Net behavioral effect:** the script no longer calls
`rage.antiaim:override_hidden_yaw_offset()` at all; the fake yaw is driven solely
by the native Left/Right Limit sliders (`refs.body_yaw[3/4]`) as it was before
Massive Fake existed. Anti-Brute "Fake limit" now always applies its shrink
(previously suppressed while either feature was on).

**Verification for Part 1:** grep the file for `massive_fake`, `smear`,
`override_hidden_yaw_offset`, `massive_fake_mag` → zero hits. Script still loads
(load-time asserts pass).

---

## Part 2 — Anticipation: Adversarial Convergence-Evasion

### Concept

Ordinary auto-freestanding hides the real head from where the strongest threat's
eye is *now*. A late-resolving peeker punishes that staleness. The old
Anticipation projected the threat's *position* forward and faced away from it.

The rework optimizes the thing that actually kills you: **the threat's crosshair
landing on your exposed head at the tick their shot resolves.** It models the
threat's aim as a *moving, sweeping ray*, integrates the hazard to your exposed
head across the whole lead window, and steps off the side the threat's aim is
converging onto (predict-the-predictor).

### Contract (unchanged)

- Global `shiny_anticipation_offset(me)` returns a yaw **offset** (a value from the
  candidate set) or `nil`. `nil` = feature off / no threat / low confidence /
  ambiguous → caller falls back to normal freestanding.
- Sole consumer is `compute_automatic_yaw`; it remains the single yaw writer.
- Entire computation wrapped in `pcall`; any error → returns `nil` (inert).
- Requires Anti-Aim Yaw Mode = Automatic (unchanged).
- Reset committed side on `round_start` / `level_init` (unchanged).

### UI change

- **Remove** the "Max Lead" slider (`rage_setup.anticipation_lead`) at ~1798 and
  every read of it.
- **Keep** the Anticipation on/off switch and the "Debug logs" switch.

### Components

All live in the existing `do … end` block that defines `shiny_anticipation_offset`
(~12728–12887). Helpers `ac_norm`, `ac_angdist`, `ac_ti`, `ac_debug_log`,
`ac_ping_ticks` are kept/reused.

#### C1. Kinematic sampler

Ring buffer `ac_hist`, capacity 12, appended once per `shiny_anticipation_offset`
call while active + threat alive. Each sample:

```
{ t     = realtime,
  px,py,pz = threat eye position,
  vx,vy = threat.m_vecVelocity (x,y),
  aim   = threat aim yaw deg or nil }     -- from threat.m_angEyeAngles.y, pcall'd
```

- `m_angEyeAngles` access is `pcall`-guarded. **If it yields nil/errors, `aim`
  is nil** and the aim-angle path degrades (see C4). This is the in-game
  calibration point: the property name/shape must be confirmed live.
- Buffer cleared on reset. Samples older than a small horizon are irrelevant;
  the buffer size bounds it.

#### C2. Kinematics from the buffer

- **velocity** `v = (vx,vy)` — newest sample's `m_vecVelocity` (instantaneous).
- **acceleration** `a = (v_now − v_prev)/dt`, `v_prev` from ~2–3 ticks back,
  averaged over available diffs to suppress jitter. If <2 usable samples, `a=0`.
- **aim angular velocity** `ω` — shortest-arc delta of consecutive `aim` values
  / dt, smoothed. If any `aim` is nil, `ω=0`.

#### C3. Auto-lead (ticks) — no slider

```
lead = round( 1
             + ping_ticks                              -- server resolve latency
             + min(closing_rate / CLOSE_SCALE, C1)     -- fast peek ⇒ lead more
             + min(abs(ω)      / SWEEP_SCALE, C2) )     -- fast flick ⇒ lead more
lead = clamp(lead, 1, LEAD_HARD_CAP=16)                 -- sanity ceiling only
```

- `ping_ticks = ac_ping_ticks()` (existing).
- `closing_rate = max(0, -d(dist_to_me)/dt)` from position samples (units/s).
- `CLOSE_SCALE`, `SWEEP_SCALE`, `C1`, `C2` are heuristic tuning constants →
  `ponytail:` calibration comment naming them as the retune knobs.

#### C4. Hazard integral (novel core)

For `K` steps `s = 1..K` (K = 5), `t_s = s * (lead*ti / K)`:

- project threat eye **2nd-order**: `P(s) = p0 + v·t_s + 0.5·a·t_s²`
- project threat **aim** 1st-order angular: `A(s) = aim0 + ω·t_s`
  (if aim unavailable: `A(s) = bearing from P(s) to my eye` → reduces to a pure
  2nd-order *position* predictor)

For each candidate offset `cand` in `AC_CANDIDATES = {-90,90,-120,120,180,-60,60}`:

- exposed head world pos: `head = my_eye + unit(target_yaw+cand) · HEAD_LATERAL`
  (`target_yaw` from `aa:get_target(false)`; `HEAD_LATERAL` ≈ shoulder/head
  lateral offset, a small constant, calibration knob).
- `bearing = atan2(head.y − P(s).y, head.x − P(s).x)`
- `raw = max(0, HEAD_TOL − ac_angdist(A(s), bearing))`  — crosshair proximity
- **cover scale:** `utils.trace_line(P(s), head, me)`; if it hits geometry
  (`fraction < 1`), scale `raw` by `fraction` (a walled head is safer). One trace
  per candidate at the *resolve* step only (≈ `ping_ticks` into the window), not
  every K, to bound trace count.
- **resolve weight:** `w(s)` = gaussian centered at the step nearest `ping_ticks`
  (that's when the enemy's shot actually lands against your record).
- `hazard(cand) = Σ_s raw(cand,s) · w(s)`

**Pick the candidate with MINIMUM `hazard`.**

#### C5. Adversarial term (predict-the-predictor)

Over the last M samples, compute for each candidate whether the threat's aim has
been *approaching* that side's exposed-head bearing (angdist trending down).
The single side with the strongest downward trend is the "tracked" side; add a
flat `P_ADV` penalty to its hazard. Effect: when a resolver locks onto the side
you're showing, you step off it.

#### C6. Confidence gate

- `confidence ∈ [0,1]` from: mean cosine similarity of consecutive velocity
  vectors (direction stability) minus a penalty for large `ω` variance.
- Near-static threat (speed≈0, ω≈0) counts as **high** confidence (stable), just
  with `lead≈1`.
- Gate:
  - `confidence < CONF_MIN` → return `nil` (erratic; defer to freestanding).
  - best vs second-best hazard margin `< MARGIN_MIN` → ambiguous: if a side is
    already committed and still within margin of best, **hold** it; else return
    `nil`.

#### C7. Anti-flicker commit

Unchanged structure, now in hazard units:

- `ac_state = { side, last_switch }`.
- No committed side → commit best.
- Best ≠ committed → switch only if `(hazard[committed] − hazard[best]) ≥
  AC_SWITCH_MARGIN` **and** `realtime − last_switch ≥ AC_SWITCH_COOLDOWN`.
- Return `ac_state.side`.

### Data flow

```
compute_automatic_yaw(me)
  └─ shiny_anticipation_offset(me)          [pcall]
       ├─ sample threat kinematics  → ac_hist        (C1)
       ├─ derive v,a,ω, closing, confidence          (C2,C6)
       ├─ confidence gate → nil?                      (C6)
       ├─ lead = auto_lead(...)                       (C3)
       ├─ for cand: hazard = Σ integral + adversarial (C4,C5)
       ├─ margin gate → nil / hold?                   (C6)
       └─ commit + return side                        (C7)
```

### Error handling

- Whole function `pcall`-wrapped → any failure returns `nil`.
- Missing API (`m_angEyeAngles`, `get_target`, `trace_line`, velocity) each has a
  local fallback (aim path off, or feature returns nil) — never an unhandled nil
  index.

### Testing (load-time, pcall + assert, no framework)

Pure helpers only:

- `ac_norm`, `ac_angdist` — kept asserts.
- `ac_project2(p, v, a, t)` — known input → known point (e.g. `a=0` linear;
  `a≠0` matches `½at²`).
- angular projection wraps correctly across ±180.
- hazard monotonicity: aim pointed at head ⇒ hazard > aim 90° off.
- `ac_auto_lead` clamps to `[1,16]` and rises with closing_rate / ω.

All wrapped so a failure logs, never kills script load.

### Constants (initial values, all calibration knobs)

```
AC_CANDIDATES     = {-90,90,-120,120,180,-60,60}
K_STEPS           = 5
LEAD_HARD_CAP     = 16
HEAD_LATERAL      = 16      -- units, exposed-head lateral offset
HEAD_TOL          = 20      -- deg, crosshair "on head" tolerance
CLOSE_SCALE       = 120     -- units/s per lead-tick
SWEEP_SCALE       = 60      -- deg/s per lead-tick
C1, C2            = 5, 4    -- max lead contribution from closing / sweep
P_ADV             = 12      -- adversarial penalty (hazard units)
CONF_MIN          = 0.35
MARGIN_MIN        = 6
AC_SWITCH_MARGIN  = 10
AC_SWITCH_COOLDOWN= 0.30    -- s
```

### Performance note

Cost per frame ≈ `K_STEPS × |AC_CANDIDATES|` arithmetic ops (35) + `|AC_CANDIDATES|`
traces (7, resolve-step only). Higher than the old single-point score but bounded
and cheap. If it ever matters, `K_STEPS` and candidate count are the dials.
`ponytail:` comment records this ceiling.

## Out of scope

- No change to the desync/body-yaw writer, Anti-Brute, Extrapolation, DTC, or any
  other subsystem beyond the two guard collapses in Part 1.
- No new UI beyond removing the Max Lead slider.
