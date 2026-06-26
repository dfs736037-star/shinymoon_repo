---
name: open-design
description: >
  Local-first design engine for prototypes, live HTML artifacts, slide decks,
  images, and design-system work. Use when the user asks for UI design,
  mockups, landing pages, dashboards, decks, DESIGN.md systems, or says
  "open design", "use open-design", or wants Claude Design-style artifacts.
---

# Open Design

Open Design runs locally via the MCP server `open-design` and the daemon at `http://127.0.0.1:7456`.

## Before you start

1. Ensure `%LOCALAPPDATA%\open-design\Open Design.exe` is running (starts the daemon).
2. Prefer MCP tools from the `open-design` server over inventing export flows.
3. For Neverlose/shinymoon menu work, also read `shinymoon-apple-ui`.

## Resource paths (Windows)

- Skills: `%LOCALAPPDATA%\open-design\resources\open-design\skills\`
- Design systems: `%LOCALAPPDATA%\open-design\resources\open-design\design-systems\`
- Plugins: `%LOCALAPPDATA%\open-design\resources\open-design\plugins\`

Browse a skill folder's `SKILL.md` when the task matches (e.g. `design-md`, `apple-hig`, `web-prototype` plugins under `plugins/_official/`).

## Typical prompts

- "Use open-design to generate a landing page with the Linear design system"
- "Create a DESIGN.md for shinymoon's Apple-style menu palette"
- "Build a sandboxed HTML prototype for a new AA settings panel"

## Handoff to code

When the artifact direction is locked, implement the smallest correct diff in `shinymoon_alpha.lua` using existing menu patterns. Do not rewrite unrelated Lua.
