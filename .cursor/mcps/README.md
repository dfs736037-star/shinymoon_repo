# Shinymoon MCP

This workspace enables local MCP servers:

- `shinymoon-alpha-tools`
- `open-design` (UI prototypes; daemon must be running — see below)

### Open Design daemon

Before using `open-design` MCP tools:

1. Start the daemon once per session:
   ```powershell
   & "$env:LOCALAPPDATA\open-design\Open Design.exe" "$env:LOCALAPPDATA\open-design\resources\app\prebundled\daemon\daemon-cli.mjs" --no-open
   ```
   Or open `%LOCALAPPDATA%\open-design\Open Design.exe` (GUI also starts the daemon).

2. Reload MCP in Cursor after install changes (`Settings → MCP` or restart Cursor).

Installed globally via `od mcp install cursor` into `%USERPROFILE%\.cursor\mcp.json`. Project copy: `.cursor/mcp.json`.

Optional (after Node.js install — run `.cursor/setup/install-planning.ps1`):

- `sequential-thinking` — step-by-step decomposition for complex plans

Local LLM offload (Ollama installed — run `.cursor/setup/install-ollama.ps1`):

- `ollama` — local chat/generate/embed via `ollama-mcp` (zero Cursor tokens for delegated tasks)
- Guide: `.cursor/setup/OLLAMA_INTEGRATION.md`

It exposes tools for:

- Fetching official Neverlose CS:GO documentation pages.
- Listing and searching local Lua/reference files.
- Reading local project files safely within this workspace.
- Saving persistent project notes in `.cursor/mcp-data/memory_notes.jsonl`.
- Saving/reading structured local test logs in `.cursor/mcp-data/test_logs.jsonl`.
- Generating Apple-style UI principles, palettes, component specs, and review checklists for script menus.

Restart Cursor or reload the MCP servers after editing `.cursor/mcp.json`.

The GitHub MCP is not enabled by default because it needs credentials. See `github_mcp_setup.md`.
