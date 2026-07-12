# Codex Integration — Agent/Hook/Rule Cleanup

## Context

This session used a new pattern successfully: Claude reads OpenSpec `tasks.md`/`design.md`/specs, writes a self-contained prompt, and delegates the actual Lua edit to `codex exec` (sandboxed, non-interactive), then verifies the diff (luaparse, targeted greps) before reporting. The project's agent/skill docs (`.agents/`, root `AGENTS.md`, `.claude/`) predate this and don't mention Codex at all. A live bug and a live staleness problem surfaced during review:

- Codex auto-loads every `.agents/skills/*/SKILL.md` at startup and errors on `.agents/skills/shinymoon-code/SKILL.md` (duplicate `name:` YAML key).
- `.agents/agents/shinymoon-code.md` and `.agents/subagents/shinymoon-code.md` are byte-identical duplicates.
- `.agents/AGENTS.md` (262 lines) is a stale pre-migration copy that nothing reads automatically — Codex's AGENTS.md discovery only sees the current, clean root `AGENTS.md` (52 lines). The stale copy assumes MCP servers (`shinymoon-alpha-tools`, `open-design`, `sequential-thinking`, `ollama`) are live; `claude mcp list` shows none of them registered — only `claude-mem` and `figma`.
- The existing `PostToolUse` hook (graphify/in-game-validate reminder) only matches Claude's own `Edit|Write|MultiEdit` calls, so it never fires for Codex-authored edits (made via Bash).

## Decisions (user-approved)

1. Codex's role: **implementer under Claude's orchestration** — Claude plans, writes the prompt, delegates, and verifies. Not a peer/router, not left unintegrated.
2. Dead MCP references: **trim to what's actually live** — don't instruct any agent to assume `shinymoon-alpha-tools`/`open-design`/`sequential-thinking`/`ollama` are connected; keep setup docs as opt-in.
3. Duplicate `shinymoon-code` agent file: **merge into one canonical file** — `.agents/subagents/shinymoon-code.md` wins (already what `.agents/commands/code.md` and the subagent playbook point to).
4. Duplicate `AGENTS.md`: **root `AGENTS.md` is sole source of truth** — `.agents/AGENTS.md` is deleted outright after merging anything still true into root.
5. Hook coverage: **add a Bash-matcher `PostToolUse` hook** alongside the existing Edit/Write/MultiEdit one, firing the same reminder when the bash command contains `codex exec`.

## Changes

### 1. Fix Codex-blocking bug
`.agents/skills/shinymoon-code/SKILL.md` — delete the duplicate `name: shinymoon-code` line (frontmatter has it twice, lines 2-3).

### 2. Canonicalize the shinymoon-code agent
- Delete `.agents/agents/shinymoon-code.md`.
- `.agents/subagents/shinymoon-code.md` becomes canonical. Add a new `## Implementation execution` section documenting two options:
  - **Do it yourself** (existing behavior: read skills, MCP if connected, edit directly).
  - **Delegate to Codex** (new): for OpenSpec task groups or well-scoped implementation tasks, when the user asks to delegate or Codex is the better fit — write a self-contained prompt (task scope + current code shape at the touch point + constraints/out-of-scope + validation command + finish/report format + tasks.md checkbox instruction), run `codex exec --sandbox workspace-write --skip-git-repo-check -C . - < prompt` (piping the prompt via stdin), then **always** verify: read the diff, run `node node_modules/luaparse/bin/luaparse shinymoon_alpha.lua`, grep-check constraints held, confirm `tasks.md` checkboxes updated correctly — before reporting done. Note that Codex's edits bypass Claude's own Edit/Write hook, so the graphify-update + in-game-validation reminder must be followed manually (see hook change below, which also covers this at the tooling level).
  - Reframe the "MCP — use automatically" section: prefix with "these are optional and may not be connected — check `claude mcp list` (or your harness's MCP status) first; if not connected, use `Read`/`Grep`/`.agents/references/neverlose_api.md` directly instead."
- Update the three referrers to point at `.agents/subagents/shinymoon-code.md` instead of the deleted `.agents/agents/` path: `.agents/skills/code/SKILL.md`, `.agents/skills/shinymoon-code-agent/SKILL.md`, `.agents/subagents/shinymoon-subagent-playbook.md`.
- `.agents/skills/shinymoon-code-agent/SKILL.md`: same MCP-optional reframing in its "Parent agent checklist."

### 3. Add Codex delegation to opsx-apply
Both `.agents/skills/opsx-apply/SKILL.md` and `.claude/commands/opsx-apply.md` get a short "Delegation" note in their Steps: implementation (the "implement in shinymoon_alpha.lua" step) may be done directly or delegated to Codex per the pattern above; either way the same finish message and tasks.md checkbox rules apply, and the agent that ran must verify the diff itself regardless of who wrote it.

### 4. Consolidate AGENTS.md
- Root `AGENTS.md` gains: a skills table (shinymoon-plan, shinymoon-lua-workflow, shinymoon-apple-ui, shinymoon-review, ponytail, graphify, llm-council), a pointer to the subagent playbook, an "MCP servers (optional)" note, and a short "Delegating implementation to Codex" section summarizing the pattern from change 2 (with a pointer to the full version in the shinymoon-code agent doc, not a second copy of the whole procedure).
- Delete `.agents/AGENTS.md` outright (no pointer file — nothing reads that path automatically).

### 5. Hook coverage for Codex-authored edits
`.claude/settings.local.json` — add a second `PostToolUse` hook entry matched on `Bash`, whose command greps the bash tool's command text for `codex exec` and, on match, echoes the same reminder the existing Edit/Write/MultiEdit hook prints (graphify update + in-game validation), to stderr.

## Out of scope
- Rewriting shinymoon-review/shinymoon-plan/shinymoon-lua-workflow/shinymoon-apple-ui/ponytail-*/opsx-explore/opsx-propose/opsx-archive skill bodies — none reference Codex or are broken; touching them isn't needed for this change.
- Reconnecting/registering the shinymoon-alpha-tools or open-design MCP servers — out of scope per decision 2 (trim references, don't fix the servers).
- `.agents/setup/PLANNING_SETUP.md`'s stale reference to `.agents/AGENTS.md` — a historical setup doc, not a live-loaded instruction file; left alone.

## Validation
- `codex exec --skip-git-repo-check -C . -` on a trivial prompt (e.g. "reply OK") should start with no YAML-load ERROR line.
- Grep confirms no remaining references to `.agents/agents/shinymoon-code.md` or `.agents/AGENTS.md` anywhere in the repo (excluding the out-of-scope PLANNING_SETUP.md line, which is left as historical).
- `.claude/settings.local.json` still parses as valid JSON after the hook addition.
