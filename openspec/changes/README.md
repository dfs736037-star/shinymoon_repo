# OpenSpec Changes

Each feature or fix gets a folder here: `openspec/changes/<change-name>/`

## Artifacts (spec-driven schema)

| File | Purpose |
|------|---------|
| `proposal.md` | Why and what — intent, scope, rollback |
| `design.md` | How — sections in shinymoon_alpha.lua, callbacks, Mermaid diagram |
| `tasks.md` | Checkbox implementation list (execute one group at a time) |
| `specs/<domain>/spec.md` | Delta spec (ADDED / MODIFIED / REMOVED) |

## Workflow in Cursor

1. `/opsx-explore` — investigate before committing
2. `/opsx-propose add-my-feature` — generate all planning artifacts (**no code yet**)
3. Review artifacts; edit if needed; approve explicitly
4. `/opsx-apply add-my-feature` — implement **one unchecked task group**, then stop
5. Repeat apply until tasks complete; test in Neverlose
6. `/opsx-archive add-my-feature` — merge deltas into `openspec/specs/` and archive

Optional: save Plan Mode output to `.cursor/plans/` for the same change name.
