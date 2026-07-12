# Shinymoon Subagent Playbook

## Custom project agent (default for code)

**`shinymoon-code`** — `.agents/subagents/shinymoon-code.md`

Use proactively for all Lua implementation, debugging, refactors, and UI work. It auto-loads skills, `shinymoon-alpha-tools` MCP, graphify, and ponytail.

Invocation:

```text
/shinymoon-code fix defensive flicker on land
/code add watermark opacity slider
```

Slash command `/code` routes to the same agent (see `.agents/commands/code.md`).

Skill router: `shinymoon-code-agent` (auto-invokes on coding tasks in this repo).

---

Built-in Cursor subagent types are still available. Use this playbook to route when not using `shinymoon-code`.

## Explore Subagent

Use for:

- Understanding unfamiliar sections of `shinymoon_alpha.lua`.
- Comparing behavior across legacy reference scripts.
- Finding all call sites for callbacks, UI controls, mode strings, presets, or Neverlose API usage.

Prompt template:

```text
Explore the shinymoon_alpha workspace for [topic]. Focus on shinymoon_alpha.lua first, then reference Lua files only as examples. Return the key files/sections, relevant symbols, current behavior, and risks. Do not modify files.
```

## General Purpose Subagent

Use for:

- Researching alternate implementation approaches.
- Drafting a refactor plan.
- Summarizing larger Lua subsystems.

Prompt template:

```text
Research an implementation plan for [feature/fix] in shinymoon_alpha. Respect Neverlose API constraints and existing project style. Return a concise plan, likely files/sections, and validation steps.
```

## Best-of-N Runner

Use for:

- Trying alternate implementations without polluting the main workspace.
- Comparing UI organization variants.
- Testing a risky refactor idea in isolation.

Prompt template:

```text
Implement an isolated attempt for [change]. Keep edits scoped, follow Neverlose Lua patterns, and report the exact behavior changed plus test gaps.
```

## Bugbot Review

Use only when the user explicitly asks for Bugbot-style review.

Focus:

- Runtime errors.
- Regressions.
- Nil access.
- Broken mode strings.
- Missing guards around callbacks or UI state.

## Security Review

Use only when the user explicitly asks for security review.

Focus:

- Unsafe file/network access.
- Credential leakage.
- Overly broad local automation.
- MCP or script behavior that escapes the project boundary.
