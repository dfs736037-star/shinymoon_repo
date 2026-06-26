---
description: Fast coding on shinymoon_alpha — auto skills, MCP, graphify via the shinymoon-code agent.
---

You are starting a **Shinymoon code session**.

## Route

Delegate to the **`shinymoon-code`** custom subagent (`.cursor/agents/shinymoon-code.md`) unless the user only wants a short answer with no file changes.

If executing inline instead of delegating, follow the same workflow as that agent.

## User task

$ARGUMENTS

If no arguments, ask what to implement, fix, or explore — then proceed.

## Quick paths

| User intent | Action |
|-------------|--------|
| Small bug / one callback | `/shinymoon-code` inline, ponytail fix |
| New feature / 3+ sections | Refuse code → `/opsx-propose <name>` |
| Explore only | graphify query + summary, no edits |
| UI polish | shinymoon-apple-ui + apple_ui MCP tools |
| Done / review | shinymoon-review posture |

Do not ask which skill or MCP to use — pick from the agent checklist automatically.
