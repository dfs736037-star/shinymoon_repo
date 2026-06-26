---
name: shinymoon-lua-workflow
description: Guides implementation, debugging, and refactoring of shinymoon_alpha Lua/Neverlose features. Use when editing Lua scripts, adding HVH features, fixing Neverlose API usage, changing anti-aim/defensive/visual logic, or working with shinymoon_alpha.lua.
---

# Shinymoon Lua Workflow

## Start Here

When working on `shinymoon_alpha.lua` or related Lua references:

1. Read the nearby Lua structure before editing.
2. Check the current Neverlose API usage against project rules and docs.
3. Preserve existing naming, menu grouping, and callback style unless the user asks for a redesign.
4. Keep changes scoped to the requested feature or bug.
5. After edits, search for duplicate old patterns that now conflict.

## Project Context

- This project is focused on CS:GO Neverlose Lua scripting.
- Follow the official Neverlose CS:GO docs: `https://docs-csgo.neverlose.cc/`.
- Treat `shinymoon_alpha.lua` as the primary script.
- Treat other `.lua` files as references or legacy sources unless the user explicitly asks to edit them.
- Prefer clear feature boundaries: UI creation, state calculation, callbacks, rendering, and config/presets should not be mixed casually.

## Implementation Pattern

For new features:

1. Identify the owner section or create a small local section near similar code.
2. Add UI controls first only if the behavior needs user configuration.
3. Keep runtime logic guarded by the relevant enable toggle.
4. Avoid broad fallback logic that hides broken state.
5. Use short comments only where the game/Neverlose behavior is not obvious.

## Debugging Pattern

When fixing behavior:

1. Find the exact callback or state transition involved.
2. Verify variable lifetime and reset behavior.
3. Check whether UI values are read once or every tick.
4. Look for mismatched control names, stale references, and duplicated mode strings.
5. Prefer a minimal fix over rewriting feature architecture.

## Before Final Response

- Mention changed behavior, not every line touched.
- Say if docs or tests could not be verified.
- If runtime testing in Neverlose is required, state the specific in-game scenario to test.
