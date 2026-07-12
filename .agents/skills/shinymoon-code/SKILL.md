---
name: shinymoon-code
description: Primary coding agent for shinymoon_alpha Lua/Neverlose work. Use proactively for implementation, bug fixes, refactors, UI/menu changes, and feature tasks.
model: inherit
---

# Shinymoon Code Agent

Canonical definition lives at `.agents/subagents/shinymoon-code.md` — read that file for the full hard rules, startup checklist, MCP usage (optional, check connection first), execution-by-task-type guidance, delegation rules (including delegating implementation to Codex via `codex exec`), and finish checklist.

This file exists only so harnesses that auto-discover `.agents/skills/*/SKILL.md` (e.g. Codex) can find this agent by name; keep it a thin pointer rather than a second copy, so the two can't drift out of sync again.
