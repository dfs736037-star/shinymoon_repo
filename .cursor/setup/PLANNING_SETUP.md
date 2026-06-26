# Planning stack setup — shinymoon_alpha

This project includes a **manual OpenSpec scaffold** (works without Node.js).

Optional components need **Node.js 18+** on PATH.

## Already active

| Component | Location |
|-----------|----------|
| OpenSpec specs | `openspec/specs/` |
| OpenSpec config | `openspec/config.yaml` |
| OpenSpec CLI | `@fission-ai/openspec@1.4.1` (global npm) |
| Slash commands | `.cursor/commands/opsx-*.md` |
| Plan skill | `.cursor/skills/shinymoon-plan/` |
| Plan-first rule | `.cursor/rules/plan-first.mdc` |
| Agent instructions | `AGENTS.md` |
| MCP: NL tools | `shinymoon-alpha-tools` |
| MCP: UI prototypes | `open-design` |
| MCP: step reasoning | `sequential-thinking` |

**Restart Cursor** after this setup so slash commands appear.

## Quick start

```
/opsx-explore how should we add X
/opsx-propose add-x-feature
# review openspec/changes/add-x-feature/
/opsx-apply add-x-feature
/opsx-archive add-x-feature
```

Or: `@shinymoon-plan` in chat.

## Install optional Node stack

Run from project root in PowerShell:

```powershell
.\.cursor\setup\install-planning.ps1
```

This will:

1. Install Node.js via winget (if missing)
2. Install OpenSpec CLI globally and run `openspec update` to sync official templates
3. Merge optional MCPs into `.cursor/mcp.json`:
   - `@modelcontextprotocol/server-sequential-thinking` — step-by-step reasoning
   - `@henkey/postgres-mcp-server` — **not** installed (not applicable)

## Optional MCP template

See `.cursor/mcp.planning.json` — merged by install script.

## External skills (manual, when Node available)

```powershell
npx skills add github/awesome-copilot --skill breakdown-feature-implementation
npx skills add hieutrtr/ai1-skills --skill project-planner
```

Prefer project skill `shinymoon-plan` for Neverlose context over generic skills.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Slash commands missing | Restart Cursor; check `.cursor/commands/` exists |
| open-design tools fail | Start `%LOCALAPPDATA%\open-design\Open Design.exe` |
| Agent implements before approve | Reinforce plan-first rule; use Plan Mode |
| openspec CLI conflicts | Run `openspec update` — keeps CLI templates in sync with manual scaffold |
