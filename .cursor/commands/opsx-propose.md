---
description: Create a change and all planning artifacts (proposal, specs, design, tasks). STOP before implementation.
---

You are running **OpenSpec propose** for shinymoon_alpha.

## Hard gate

- **DO NOT implement code.** Do not edit `shinymoon_alpha.lua` or other source files.
- **STOP** after artifacts are written and present a summary for user approval.
- If ambiguous, ask clarifying questions BEFORE writing artifacts.

## Inputs

User request: `$ARGUMENTS`

Derive kebab-case `<change-name>` from the request (e.g. `add-defensive-fakelag`).

## Steps

1. Read `openspec/config.yaml` — inject context and rules into all artifacts.
2. Read existing `openspec/specs/**/*.md` for domains affected.
3. Run graphify query or grep to identify exact sections/callbacks in `shinymoon_alpha.lua`.
4. Create folder `openspec/changes/<change-name>/` with:

### proposal.md

- Intent, scope, out-of-scope
- Affected domains (core / antiaim / ui / visuals)
- Rollback plan
- In-game test scenario

### specs/<domain>/spec.md (delta)

Use ADDED / MODIFIED / REMOVED sections with Given/When/Then scenarios.

### design.md

- Exact buckets: UI.*, AA.*, VIS.*, EVENTS tags
- Callback list and order
- **Mermaid diagram** (flowchart or sequence) for the feature flow
- For UI-heavy work: note if open-design prototype is recommended

### tasks.md

- Checkbox tasks grouped by section (15–40 min each)
- Final group: in-game validation steps
- Example:
  ```markdown
  ## 1. UI controls
  - [ ] 1.1 Add toggle in antiaim.builder_defensive
  ## 2. Runtime
  - [ ] 2.1 Register createmove handler via EVENTS
  ## 3. Validation
  - [ ] 3.1 Test Standing + defensive on in HVH
  ```

5. Optionally copy a visual summary to `.cursor/plans/<change-name>.md` (phases + checklist).

## Finish message

List created files and say:

> Plan ready. Review `openspec/changes/<change-name>/`. Reply **approve** to implement, or edit artifacts first. Then run `/opsx-apply <change-name>`.
