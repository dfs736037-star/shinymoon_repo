# Desync Smear Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a standalone defensive anti-aim exploit that varies the local player's hidden-yaw offset per choked command, decorrelating the fake-lag backtrack trail so a resolver that fits one record is wrong on the next.

**Architecture:** One new stateless helper (`shiny_smear_offset`) computes a per-command signed yaw offset from `globals.choked_commands`. The existing single `rage.antiaim:override_hidden_yaw_offset` call site in `apply_yaw_and_desync` gains a guarded branch so exactly one of {Smear, Massive Fake} writes per tick, Smear winning. A global UI toggle + amount slider + pattern dropdown drive it. No `send_packet` interaction, so the Double-Tap / `defensive_tickbase` engine is untouched.

**Tech Stack:** Lua (Neverlose CS:GO scripting API), single file `shinymoon_alpha.lua`.

## Global Constraints

- Single file only: `shinymoon_alpha.lua`. No new files, no new dependencies.
- Never write `cmd.send_packet` / `cmd.no_choke` / `cmd.force_defensive`. Yaw only.
- Single write authority: the one `override_hidden_yaw_offset` call site stays the only writer; the guard is `if config["smear"] then ... elseif config["massive_fake"] then ...`.
- `shiny_smear_offset` must NEVER return 0 (0 flashes the real angle), and must clamp to `[-180, 180]`.
- Stateless: no `aa_engine` fields, no round-reset entries.
- Gated behind `body_yaw` enabled + the default-OFF `smear` toggle. Stock defaults unchanged.
- No `pcall` around `rage.antiaim` calls (matches file convention).
- **No Lua interpreter exists in the build environment.** The runnable check is the in-game load-time `assert` block (fires when the script loads in CS:GO). Where a step says "verify," it means load the script in-game and confirm the described behavior; the load-time assert is what fails loudly if the math is wrong.

---

### Task 1: `shiny_smear_offset` helper + load-time assert

**Files:**
- Modify: `shinymoon_alpha.lua` — insert immediately BEFORE line 5237 (`local function apply_yaw_and_desync(config, tick)`).

**Interfaces:**
- Produces: `shiny_smear_offset(base: number, choked: number, window: number, side: number, pattern: string): number` — a top-level file local. `side` is `-1` or `1` (current desync side). `pattern` is one of `"Alternate"`, `"Ramp"`, `"Walk"`. Returns a signed offset in `[-180, 180]`, never 0.

- [ ] **Step 1: Insert the helper + assert**

Insert this block immediately before line 5237 (the `local function apply_yaw_and_desync` line):

```lua
-- Desync Smear: vary the hidden-yaw offset per choked command so the fake-lag
-- backtrack trail carries a different fake angle on every record instead of one
-- repeated angle a resolver can solve once. Stateless — indexed by choked count.
-- ponytail: the server-side animation layer may not reproduce the fastest sweep
-- faithfully per-tick; the pattern dropdown + amount are the tuning knobs
-- (Ramp = safe, Alternate = aggressive). Calibrate in-game if it over/undershoots.
local function shiny_smear_offset(base, choked, window, side, pattern)
	base = math.max(1, math.min(180, math.abs(base or 120)))
	if pattern == "Ramp" then
		local denom = math.max(1, window - 1)
		local p = choked / denom
		if p < 0 then p = 0 elseif p > 1 then p = 1 end
		local mag = base * (0.6 + 0.4 * p)
		return math.max(-180, math.min(180, side * mag))
	elseif pattern == "Walk" then
		local mag = base * (0.6 + 0.4 * math.random())
		local sgn = (math.random(1, 2) == 1) and 1 or -1
		return math.max(-180, math.min(180, sgn * mag))
	else -- "Alternate" (default)
		local sgn = (choked % 2 == 0) and 1 or -1
		return math.max(-180, math.min(180, sgn * base))
	end
end

-- ponytail: no Lua interpreter in the build env; this runs at script load in-game.
assert(shiny_smear_offset(120, 0, 5, 1, "Alternate") == 120, "smear: alternate even tick")
assert(shiny_smear_offset(120, 1, 5, 1, "Alternate") == -120, "smear: alternate odd tick")
assert(shiny_smear_offset(120, 0, 5, -1, "Ramp") < 0, "smear: ramp honors side")
for _smear_c = 0, 14 do
	for _, _smear_pat in ipairs({ "Alternate", "Ramp", "Walk" }) do
		local _smear_v = shiny_smear_offset(120, _smear_c, 5, 1, _smear_pat)
		assert(_smear_v ~= 0, "smear: returned 0")
		assert(_smear_v >= -180 and _smear_v <= 180, "smear: out of range")
	end
end
```

- [ ] **Step 2: Verify it loads (assert passes)**

There is no host interpreter. Load the script in CS:GO via Neverlose. Expected: the script loads with no `[error]` in the console. If any assert fails, the console prints the assert message (e.g. `smear: returned 0`) and the script does not load — fix the math and reload.

- [ ] **Step 3: Commit**

```bash
git add shinymoon_alpha.lua
git commit -m "feat(aa): add shiny_smear_offset helper for Desync Smear"
```

---

### Task 2: Smear UI controls + persistence

**Files:**
- Modify: `shinymoon_alpha.lua` — UI block after the Massive Fake group (after line 1332), callback near line 1377, `base_keys` at line 908.

**Interfaces:**
- Produces: `builder.smear` (switch), `builder.smear_amount` (slider), `builder.smear_pattern` (combo). After `save_state`, these surface as `config["smear"]` (bool), `config["smear_amount"]` (number), `config["smear_pattern"]` (string) — consumed in Task 3.

- [ ] **Step 1: Add the controls after the Massive Fake group**

After line 1332 (the closing `)` of `builder.massive_fake_amount = massive_fake_grp:slider(...)`), insert:

```lua

-- Desync Smear: standalone from Massive Fake (which is broken). Varies the
-- hidden-yaw offset per choked command to decorrelate the fake-lag trail.
-- Own amount + pattern; single write authority shared with Massive Fake in
-- apply_yaw_and_desync (Smear wins when both are on). Off by default.
builder.smear = antiaim.builder_defensive:switch(
	icon_label("waveform", "Desync Smear", 1, 5),
	false
)
local smear_grp = builder.smear:create()
builder.smear_amount = smear_grp:slider(
	sub_label("Amount"),
	60, 180, 120, 1, function(v) return v .. "°" end
)
builder.smear_pattern = smear_grp:combo(
	sub_label("Pattern"),
	{ "Alternate", "Ramp", "Walk" }
)
```

- [ ] **Step 2: Add the visibility callback**

After line 1377 (the closing `end, true)` of the `builder.massive_fake:set_callback(...)` block), insert:

```lua

builder.smear:set_callback(function()
	smear_grp:visibility(builder.smear:get())
end, true)
```

- [ ] **Step 3: Register keys for per-state save/load**

At line 908, replace:

```lua
		"event_handler", "defensive_tickbase", "head_behind_chest", "break_lc", "massive_fake", "massive_fake_amount",
```

with:

```lua
		"event_handler", "defensive_tickbase", "head_behind_chest", "break_lc", "massive_fake", "massive_fake_amount",
		"smear", "smear_amount", "smear_pattern",
```

(Global controls, like `massive_fake` — do NOT add to `per_state_keys`. `save_state`/`load_state` handle them via the base_keys path automatically.)

- [ ] **Step 4: Verify in-game**

Load the script. Expected: under Anti-Aim → the defensive builder column, a new "Desync Smear" switch appears. Toggling it on reveals an "Amount" slider (60–180°, default 120) and a "Pattern" dropdown (Alternate / Ramp / Walk). Toggling off hides them. No console errors. `combo:get()` returns the selected string — confirm by selecting each pattern (used in Task 3).

- [ ] **Step 5: Commit**

```bash
git add shinymoon_alpha.lua
git commit -m "feat(aa): add Desync Smear UI toggle, amount, and pattern"
```

---

### Task 3: Wire Smear into the desync write site

**Files:**
- Modify: `shinymoon_alpha.lua` — write-site branch at line 5406, anti-brute skips at lines 5262 and 5335.

**Interfaces:**
- Consumes: `shiny_smear_offset(...)` (Task 1); `config["smear"]`, `config["smear_amount"]`, `config["smear_pattern"]` (Task 2); existing `get_fakelag_limit()`, `globals.choked_commands`, `aa_engine.allow_inverter`, `setup.aa_debug`.

- [ ] **Step 1: Guard the write site so Smear wins over Massive Fake**

At line 5406, replace the opening of the Massive Fake block:

```lua
			if config["massive_fake"] then
				local aa = rage and rage.antiaim
				if aa then
```

with:

```lua
			if config["smear"] then
				local aa = rage and rage.antiaim
				if aa then
					local base   = math.abs(config["smear_amount"] or 120)
					local window = math.max(2, get_fakelag_limit())
					local choked = globals.choked_commands or 0
					local side   = aa_engine.allow_inverter and -1 or 1
					local signed = shiny_smear_offset(base, choked, window, side, config["smear_pattern"])
					aa:override_hidden_yaw_offset(signed)
					if setup.aa_debug and setup.aa_debug:get() then
						print(string.format("[shinymoon] smear %s c%d/w%d -> %.1f",
							tostring(config["smear_pattern"]), choked, window, signed))
					end
				end
			elseif config["massive_fake"] then
				local aa = rage and rage.antiaim
				if aa then
```

(This keeps the entire existing Massive Fake body unchanged — only its `if` becomes `elseif` and the Smear branch is prepended. The Massive Fake block's own closing `end`s are untouched.)

- [ ] **Step 2: Extend the Anti-Brute "Fake limit" skips**

At line 5262, replace:

```lua
			if table_selection_has(config["antibrute_method"], "Fake limit") and not config["massive_fake"] then
```

with:

```lua
			if table_selection_has(config["antibrute_method"], "Fake limit") and not (config["massive_fake"] or config["smear"]) then
```

At line 5335 (the second identical occurrence, in the Static/Random branch), make the same replacement:

```lua
			if table_selection_has(config["antibrute_method"], "Fake limit") and not (config["massive_fake"] or config["smear"]) then
```

(So Anti-Brute's fakelimit substitution can't clobber the Smear magnitude.)

- [ ] **Step 3: Verify in-game**

Load the script. Enable Anti-Aim with `body_yaw` (Desync) on, turn on **Desync Smear**, and turn on the **Debug** switch (Anti-Aim setup section, `setup.aa_debug`). Fake-lag yourself (stand still so the cheat chokes commands). Expected console lines like:

```
[shinymoon] smear Alternate c0/w6 -> 120.0
[shinymoon] smear Alternate c1/w6 -> -120.0
[shinymoon] smear Alternate c2/w6 -> 120.0
```

Confirm per pattern:
- **Alternate**: sign flips every choked tick, magnitude constant.
- **Ramp**: sign constant across a window, magnitude climbs `~72 → 120`.
- **Walk**: magnitude jitters in `~72 → 120`, sign random.

Also confirm: with **Massive Fake** ALSO on, the log still shows `smear` (Smear wins). With Smear off + Massive Fake on, no `smear` log (Massive Fake path runs as before). No console errors either way.

- [ ] **Step 4: Commit**

```bash
git add shinymoon_alpha.lua
git commit -m "feat(aa): wire Desync Smear into desync write site (single authority)"
```

---

## Self-Review

**Spec coverage:**
- Problem/insight (per-command variation, decorrelate trail) → Task 1 helper.
- Non-goals (no send_packet, no Massive Fake dep, yaw only) → Global Constraints + Task 3 guard.
- Mechanic / single authority (`if smear elseif massive_fake`) → Task 3 Step 1.
- Sweep function (Alternate/Ramp/Walk, invariants) → Task 1 Step 1 + assert.
- UI/config (global switch, own amount, pattern combo, base_keys) → Task 2.
- Anti-Brute interaction (both skips) → Task 3 Step 2.
- Safety/calibration/verification (body_yaw gate, aa_debug line, load-time assert) → Task 1 Step 2, Task 3 Step 3, Global Constraints.
All spec sections map to a task. No gaps.

**Placeholder scan:** No TBD/TODO/"handle edge cases"/vague steps — every code step shows exact code and exact anchors. Clear.

**Type consistency:** `shiny_smear_offset(base, choked, window, side, pattern)` signature identical in Task 1 (definition), Task 3 (call). `config["smear"]`/`["smear_amount"]`/`["smear_pattern"]` keys identical across Tasks 2 and 3. `builder.smear`/`smear_grp`/`builder.smear_amount`/`builder.smear_pattern` consistent within Task 2. Consistent.
