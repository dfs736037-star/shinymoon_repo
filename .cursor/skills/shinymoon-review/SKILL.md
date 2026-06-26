---
name: shinymoon-review
description: Reviews shinymoon_alpha Lua changes for regressions, API mistakes, UI consistency, risky state handling, and missing runtime checks. Use before finalizing substantial Lua edits, after refactors, when the user asks for review, or when behavior touches callbacks, anti-aim, defensive, visuals, presets, or menu state.
---

# Shinymoon Review

## Review Focus

Prioritize issues that can break the script at runtime:

- Invalid or outdated Neverlose API usage.
- Nil access from missing UI references or entity state.
- Callback logic that keeps stale state after feature disable.
- Mode strings that do not match UI options.
- Heavy per-tick work that should be cached or guarded.
- UI controls that exist but are not used, or logic without controls.
- Preset/config changes that break existing user expectations.

## Review Steps

1. Compare the changed area against nearby project patterns.
2. Check whether feature toggles fully guard runtime behavior.
3. Verify callbacks register/unregister or no-op safely.
4. Search for duplicate names, old mode strings, and stale references.
5. Review labels and grouping against the Apple-style UI direction.
6. Identify what still needs in-game Neverlose testing.

## Response Style

If reviewing, lead with findings by severity:

- Critical: likely runtime error or broken feature.
- High: wrong behavior in common use.
- Medium: confusing UI, fragile state, or likely edge case.
- Low: polish, maintainability, or optional cleanup.

If no issues are found, say that clearly and list remaining runtime test gaps.

## Runtime Test Notes

When a change cannot be fully validated statically, recommend a concrete scenario:

- Map/state to load.
- Feature toggle or preset to enable.
- Enemy/local player condition to reproduce.
- Expected visual/menu/behavior result.
