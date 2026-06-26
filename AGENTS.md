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

## Cursor Cloud specific instructions

This repo is a **spec-driven planning repository**, not a runnable app. There is no
`shinymoon_alpha.lua` yet, no `package.json`, and no test/lint/build system. The actual
product is a Neverlose CS:GO Lua script that only runs inside the proprietary Neverlose
client on Windows — it **cannot run in this Linux cloud VM**. In-game validation
(`openspec/config.yaml` validation steps) must be done by a human on a Windows CS:GO setup.

The only runnable dev tool here is the **OpenSpec CLI** (`@fission-ai/openspec`), installed
globally by the update script to `~/.npm-global/bin` (added to PATH via `~/.bashrc`). It drives
the plan-first workflow (`/opsx-*` commands map to `openspec` subcommands).

Common commands (run from repo root):
- `openspec list` / `openspec list --specs` — list active changes / specs
- `openspec show <name>` — render a change or spec
- `openspec validate <change> --strict` — validate a change proposal (this is the closest
  thing to a "test/lint" here)

Non-obvious gotchas:
- `openspec validate --specs --all --strict` **fails on the existing specs** in
  `openspec/specs/`. This is expected: those specs use the repo's custom manual scaffold
  (`**Requirement:**` / `**Scenario:**` bullets), not OpenSpec's official format
  (`#### Requirement:` / `#### Scenario:` with `**WHEN**`/`**THEN**`). Do not "fix" them
  unless asked. New **change** proposals authored in official format validate cleanly.
- The CLI is installed with `npm install -g ... --prefix ~/.npm-global` (no global npm
  `prefix` in `~/.npmrc`), so there is no nvm conflict. Active node is `/exec-daemon/node`.
- The `shinymoon-alpha-tools` (PowerShell) and `open-design` (Windows GUI) MCP servers in
  `.cursor/mcp.json` are Windows-only and will not run here. Only `sequential-thinking`
  (npx-based) is cross-platform.
