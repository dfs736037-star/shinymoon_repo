# GitHub MCP setup

The local `shinymoon-alpha-tools` MCP is enabled in `.cursor/mcp.json`.

Add a GitHub MCP only after you have a token available. A typical Cursor config looks like this:

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

Do not commit real tokens. Prefer a user-level MCP config or environment variable for credentials.
