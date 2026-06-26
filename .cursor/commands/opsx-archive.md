---
description: Archive a completed OpenSpec change — merge delta specs into openspec/specs/ and move change to archive.
---

You are running **OpenSpec archive** for shinymoon_alpha.

Change name: `$ARGUMENTS`

## Preconditions

- All tasks in `openspec/changes/<change-name>/tasks.md` are checked `[x]`, OR user explicitly accepts partial archive.
- User confirmed in-game validation passed.

## Steps

1. Merge each delta spec under `openspec/changes/<change-name>/specs/` into `openspec/specs/<domain>/spec.md`:
   - Fold ADDED requirements into main spec
   - Apply MODIFIED / remove REMOVED
2. Move folder to `openspec/changes/archive/<change-name>/` (create `archive/` if needed).
3. Add one-line entry to `openspec/changes/archive/CHANGELOG.md` with date and summary.

## Do not

- Archive if implementation was never applied and specs would lie about current behavior.
- Delete proposal/design — keep in archive for history.

## Finish message

Confirm merged spec paths and archived location.
