# AGENTS.md — shinymoon_alpha

Instructions for AI coding assistants working in this repository.

## Project

- **Script:** `shinymoon_alpha.lua` — CS:GO Neverlose Lua HVH ambient (single-file, section buckets)
- **Neverlose lua API docs:** `.agents/references/neverlose_api.md` (source of truth)
- **Specs:** `openspec/specs/` (source of truth for behavior) + `openspec/config.yaml`
- **Changes:** `openspec/changes/<name>/` (active work)
- **Architecture graph:** `graphify-out/graph.html` if present (regenerate with `graphify update .`)

## Plan-first workflow (mandatory)

For any task touching **3+ sections** of `shinymoon_alpha.lua` or changing anti-aim/defensive/visual architecture:

1. **Do not write code** until the user approves a plan.
2. Run `/opsx-propose <change-name>` to produce artifacts (proposal, delta specs, design, tasks).
3. Include a **Mermaid diagram** in `design.md` for multi-callback features.
4. Implement with `/opsx-apply` — **one task group per session**, then stop for review.
5. Confirm in-game validation before calling work done.

Small fixes (single guard, label tweak, one callback) may skip OpenSpec — use ponytail (smallest correct diff).

## OpenSpec commands

Defined in `.claude/commands/`. Type them as slash commands:

| Command | Action |
|---------|--------|
| `/opsx-explore` | Investigate an idea; no artifacts, no code |
| `/opsx-propose` | Create change folder + proposal, specs, design, tasks — then STOP |
| `/opsx-apply` | Implement the next unchecked task group (one at a time) |
| `/opsx-archive` | Merge delta specs into `openspec/specs/` and archive the change |
| `/code` | Fast ponytail coding session on `shinymoon_alpha.lua` |

## Code agent

Default executor: **`shinymoon-code`** (`.agents/subagents/shinymoon-code.md`). Invoke with `/code <task>` or `/shinymoon-code <task>`. See `.agents/subagents/shinymoon-subagent-playbook.md` for routing to other subagents (explore, bugbot, security-review — only when the user explicitly asks for those two).

## Skills to load

| Skill | When |
|-------|------|
| `shinymoon-plan` | Planning, proposals |
| `shinymoon-lua-workflow` | Lua implementation / debug |
| `shinymoon-apple-ui` | Menu design |
| `shinymoon-review` | Pre-merge review |
| `graphify` | Codebase exploration |
| `ponytail` | Minimal diffs (default) |
| `llm-council` | Run a decision through multiple AI advisors |

## MCP servers (optional)

Not currently registered in this environment — `claude mcp list` shows only `claude-mem`/`figma` connected. Don't assume `shinymoon-alpha-tools`, `open-design`, `sequential-thinking`, or `ollama` are live; check before using, and fall back to `Read`/`Grep`/`.agents/references/neverlose_api.md` if not connected. Setup docs if you do reconnect them: `.agents/mcps/README.md`.

## Delegating implementation to Codex

`codex exec` can implement a well-scoped task (an OpenSpec task group, a bug fix) non-interactively: write a self-contained prompt (exact scope, current code shape at the touch point, constraints/out-of-scope, validation command, finish/report format), run:

```
codex exec --sandbox workspace-write --skip-git-repo-check -C . - < prompt.txt
```

then **always verify yourself** — read the diff, run `node node_modules/luaparse/bin/luaparse shinymoon_alpha.lua`, confirm constraints held and `tasks.md` checkboxes are correct — before reporting done. Full pattern and MCP-optional guidance: `.agents/subagents/shinymoon-code.md`.

## Validation

- In-game: state transitions, menu toggles, preset reload, defensive on/off
- After substantive Lua edits: `graphify update .` (only if `graphify-out/` exists)

## File rules

- Edit `shinymoon_alpha.lua` only unless the user names another file.
- Keep `def_voice_decoders.lua` at repo root (Neverlose `require`).
- Legacy reference scripts live in `reference/legacy/` — read-only unless the user asks.
- Docs / telemetry: `docs/` (`shinymoon_records.md`, netvars ref).
- Cloud API: `shinymoon-cloud/` submodule — separate repo, see its `README.md`.

<!-- openspec:begin -->
OpenSpec is configured. Use `/opsx-propose` to start changes. Config: `openspec/config.yaml`.
<!-- openspec:end -->
