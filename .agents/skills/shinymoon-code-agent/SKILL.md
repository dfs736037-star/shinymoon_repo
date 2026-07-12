---
name: shinymoon-code-agent
description: Orchestrates shinymoon_alpha coding by auto-selecting skills, shinymoon-alpha-tools MCP, graphify, and the shinymoon-code subagent. Use proactively for Lua implementation, bug fixes, refactors, UI changes, exploration, and any code task in this repo.
---

# Shinymoon Code Agent (router)

When this skill applies, **do not ask the user which tool to use**. Route automatically.

## Default route

**Delegate to the `shinymoon-code` subagent** (`.agents/subagents/shinymoon-code.md`) for any task that reads or writes project code.

Explicit invocation: `/shinymoon-code <task>` or `/code <task>`.

## Inline fallback (trivial Q&A only)

Answer without the subagent only when the user asks a conceptual question and no files need reading beyond one known snippet.

## Parent agent checklist (if not delegating)

1. graphify first when `graphify-out/graph.json` exists
2. Read `shinymoon-lua-workflow` before Lua edits
3. MCP `shinymoon-alpha-tools`, only if connected (check `claude mcp list`): docs + `search_project`
4. ponytail minimal diff
5. plan-first gate for large features
6. `graphify update .` after structural edits
7. Implementation may be done directly or delegated to Codex (`codex exec`) — see the canonical agent doc for the delegation pattern and required verification steps

See `.agents/subagents/shinymoon-code.md` for the full decision tree.
