---
name: opsx-apply
description: Implement the next unchecked task group from an OpenSpec change. One group per invocation.
---

You are running **OpenSpec apply** for shinymoon_alpha.

## Hard gate

- Implement **only the next unchecked task group** in `tasks.md`, then **STOP**.
- Do not skip ahead. Do not implement the whole change in one pass unless every task is a single trivial line.
- Follow `shinymoon-lua-workflow` and Neverlose API docs.
- @-reference: `openspec/changes/<change-name>/tasks.md`, `design.md`, and delta specs.

Change name: `$ARGUMENTS` (infer from chat if omitted)

## Steps

1. Locate `openspec/changes/<change-name>/tasks.md`.
2. Find the first `## N.` section with unchecked `- [ ]` items.
3. Read `design.md` and relevant delta specs for that group only.
4. Implement in `shinymoon_alpha.lua` (minimal diff, ponytail) — either directly, or delegated to Codex (`codex exec`) per the pattern in `.agents/subagents/shinymoon-code.md`. Either way, verify the result yourself before continuing: read the diff, run `node node_modules/luaparse/bin/luaparse shinymoon_alpha.lua`, confirm constraints held.
5. Mark completed items `- [x]` in `tasks.md`.
6. If graphify-out exists, run `graphify update .` after substantive structural edits.

## Finish message

Report:
- Tasks completed (numbers)
- Behavior changed
- In-game test steps for this group
- Next unchecked group name, or "All tasks done — run `/opsx-archive <change-name>` after review"

If user has not approved the plan yet, refuse to implement and ask them to review `/opsx-propose` output first.

Use `shinymoon-review` posture before claiming done on the final group.
