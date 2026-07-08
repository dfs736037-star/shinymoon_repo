# Plan: unify-lc-defensive-ui

## Question

Break LC e Defensive Gating têm função parecida? **Sim, parcialmente** — ambos controlam *quando* comportamento defensivo/LC entra. Runtime já foi unificado; UI ainda tem dois switches.

## Phase 1 — UI (tasks 1.x)

- Um switch: **LC & Defensive**
- Filhos: Events, Targets, quickpeek, Active States, Disablers, Improve FL

## Phase 2 — Runtime (tasks 2.x)

- `lc_defense_enabled()` único
- Empty targets = sem override LC

## Phase 3 — Presets + validate (tasks 3–5)

## Checklist rápido

- [ ] Master único na Setup
- [ ] Guards runtime unificados
- [ ] Test swap + DTC gate + master OFF
- [ ] Specs merged após validar in-game

Artifacts: `openspec/changes/unify-lc-defensive-ui/`
