# AGENTS.md — shinymoon_alpha

Instructions for AI coding assistants working in this repository.

## Project

- **Script:** `shinymoon_alpha.lua` — CS:GO Neverlose Lua HVH ambient
- **Docs:** https://docs-csgo.neverlose.cc/
- **Specs:** `openspec/specs/` (source of truth for behavior)
- **Changes:** `openspec/changes/<name>/` (active work)

## Plan-first workflow (mandatory)

For any task touching **3+ sections** of `shinymoon_alpha.lua` or changing anti-aim/defensive/visual architecture:

1. **Do not write code** until the user approves a plan.
2. Use `/opsx-propose <change-name>` or `@shinymoon-plan` to produce artifacts.
3. Include a **Mermaid diagram** in `design.md` for multi-callback features.
4. Use **open-design** MCP for menu mockups when UI layout is non-trivial.
5. Run **graphify** (`graphify query` or open `graphify-out/graph.html`) before large refactors.
6. Implement with `/opsx-apply` — **one task group per session**, then stop for review.
7. Run **shinymoon-review** before calling work done.

Small fixes (single guard, label tweak, one callback) may skip OpenSpec — use ponytail.

## OpenSpec commands (Cursor)

| Command | Action |
|---------|--------|
| `/opsx-explore` | Investigate; no artifacts |
| `/opsx-propose` | Create change folder + proposal, specs, design, tasks |
| `/opsx-apply` | Implement from `tasks.md` (one group at a time) |
| `/opsx-archive` | Merge specs and archive change |

## Skills to load

| Skill | When |
|-------|------|
| `shinymoon-plan` | Planning, proposals, visual plan review |
| `shinymoon-lua-workflow` | Lua implementation / debug |
| `shinymoon-apple-ui` | Menu design |
| `shinymoon-review` | Pre-merge review |
| `graphify` | Codebase exploration |
| `open-design` | UI prototypes / DESIGN.md |
| `ponytail` | Minimal diffs (default) |

## MCP servers

| Server | Use |
|--------|-----|
| `shinymoon-alpha-tools` | NL docs, Lua search, memory, test logs, UI helpers |
| `open-design` | Visual prototypes (daemon required) |
| `sequential-thinking` | Step-by-step decomposition for complex plans (Node/npx) |

## Validation

- In-game: state transitions, menu toggles, preset reload, defensive on/off
- Log failures via shinymoon-alpha-tools test log tools when debugging
- After substantive Lua edits: `graphify update .`

## File rules

- Edit `shinymoon_alpha.lua` only unless user names another file.
- Legacy reference `.lua` files are examples — do not modify by default.

<!-- openspec:begin -->
OpenSpec is configured. Use `/opsx-propose` to start changes. Config: `openspec/config.yaml`.
<!-- openspec:end -->
