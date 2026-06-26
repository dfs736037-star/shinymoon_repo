# Shinymoon AI Workflow

This project includes local Cursor guidance for better AI behavior while working on `shinymoon_alpha`.

## Plan-first (OpenSpec)

Specs and changes live under `openspec/`. Agent instructions: `AGENTS.md`.

| Step | Command / skill |
|------|-----------------|
| Explore | `/opsx-explore` |
| Plan (no code) | `/opsx-propose <change-name>` or `@shinymoon-plan` |
| Implement one step | `/opsx-apply <change-name>` |
| Archive | `/opsx-archive <change-name>` |

Rule: `.cursor/rules/plan-first.mdc` — large changes need approved artifacts before coding.

Setup details: `.cursor/setup/PLANNING_SETUP.md`

## Code agent (default)

Custom subagent **`shinymoon-code`** (`.cursor/agents/shinymoon-code.md`) orchestrates skills and MCPs automatically for fast coding.

| Trigger | Action |
|---------|--------|
| Any code task | Agent delegates to `shinymoon-code` (or skill `shinymoon-code-agent` routes it) |
| Quick start | `/code <task>` or `/shinymoon-code <task>` |
| Large feature | Agent stops and asks for `/opsx-propose` first |

## Skills

Project skills live in `.cursor/skills/`.

- `shinymoon-plan`: plan-first workflow, OpenSpec artifacts, Mermaid diagrams, visual review hooks.
- `shinymoon-lua-workflow`: use for Lua/Neverlose implementation, debugging, refactoring, callbacks, anti-aim, defensive, visuals, presets, and `shinymoon_alpha.lua`.
- `shinymoon-apple-ui`: use for Apple-inspired menu design, labels, layout hierarchy, palettes, visual polish, and UI review.
- `shinymoon-review`: use before finalizing substantial Lua changes or when reviewing regressions, API usage, UI consistency, and test gaps.
- `shinymoon-code-agent`: auto-routes coding tasks to the `shinymoon-code` subagent; loads skills/MCP/graphify without manual picks.

## Persistent Rule

`.cursor/rules/shinymoon-ai-workflow.mdc` applies automatically and tells the agent when to use these skills, MCP tools, and Cursor subagents.

## Subagents

Cursor controls the available subagent types. This project adds a routing playbook at:

- `.cursor/subagents/shinymoon-subagent-playbook.md`

Use subagents mainly for:

- broad exploration of the codebase;
- isolated implementation attempts;
- larger refactor planning;
- explicit Bugbot or security reviews.

## MCP Support

The local MCP server `shinymoon-alpha-tools` complements these skills with:

- Neverlose docs lookup;
- Lua/reference search;
- project memory notes;
- local test logs;
- Apple-style UI helpers.
