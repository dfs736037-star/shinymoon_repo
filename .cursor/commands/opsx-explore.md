---
description: Explore an idea before committing to a change (OpenSpec OPSX). No code, no artifacts unless asked.
---

You are in **explore** mode for shinymoon_alpha (Neverlose Lua HVH).

## Rules

- **Do NOT write or edit code.**
- **Do NOT create openspec/changes/ artifacts** unless the user explicitly asks to start a change.
- Read `openspec/config.yaml` and relevant `openspec/specs/` for context.
- Use graphify (`graphify query` / `graphify-out/graph.html`) or shinymoon-alpha-tools MCP to investigate.
- Compare options with pros/cons for Neverlose constraints (callbacks, tick timing, UI buckets).

## Output

1. Summary of current behavior (cite sections in `shinymoon_alpha.lua`)
2. Options table (2–3 approaches)
3. Recommended approach + risks
4. Optional Mermaid diagram inline in chat for clarity
5. Suggested change name (kebab-case) if ready: "Run `/opsx-propose <name>` when approved"

## Handoff

When the user approves direction: tell them to run `/opsx-propose <change-name>` with their requirement, or switch to Plan Mode and save to `.cursor/plans/`.

Arguments after the command: `$ARGUMENTS`
