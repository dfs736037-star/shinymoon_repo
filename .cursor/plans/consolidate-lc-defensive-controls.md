# Plan: Consolidate Break LC + Defensive Gating

**Change:** `consolidate-lc-defensive-controls`  
**Question:** Defensive gating e Break LC não têm meio que a mesma função?  
**Answer:** Sim, parcialmente — condições swap/reload e HS Break LC estão duplicadas; DT Lag Always on é o único comportamento único do gating hoje.

## Overlap map

| Behavior | Break LC | Def Gating | After merge |
|----------|----------|------------|-------------|
| Swap/reload detect | yes | yes | shared helper |
| HS Break LC | on conditions | on def window | Break LC targets |
| DT Always on | no | on game events | Break LC targets |
| State filter | no | yes | stays in gating |
| Disablers | no | yes | stays in gating |
| Improve FL | no | yes | stays in gating |

## Phases

1. Shared `lc_event_conditions_active` + merge reload helper  
2. UI: add Break LC targets; remove def game events / force HS  
3. Runtime: one writer in `misc_on_break_lc`; slim AA gating  
4. Spec update + in-game validation  

## Checklist

- [ ] Helpers merged
- [ ] UI consolidated
- [ ] No double `hideshot_config` write per tick
- [ ] DTC reliability unchanged
- [ ] In-game swap/reload tests pass

Full artifacts: `openspec/changes/consolidate-lc-defensive-controls/`
