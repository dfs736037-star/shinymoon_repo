---
name: shinymoon-apple-ui
description: Designs and reviews Apple-inspired UI for shinymoon_alpha menus, controls, palettes, labels, layout hierarchy, presets, and visual polish. Use when the user mentions UI, menu, design, layout, Apple style, glass, palette, components, or visual elements.
---

# Shinymoon Apple UI

## Design Direction

Aim for an Apple-inspired interface translated into a Neverlose Lua menu:

- Clarity over decoration.
- Calm dark surfaces.
- Sparse accent color.
- Short labels.
- Progressive disclosure for advanced or risky controls.
- Consistent spacing and control order.

## Menu Structure

Recommended top-level sections:

- Main
- Anti-Aim
- Defensive
- Visuals
- Misc
- Presets
- Debug / Advanced

Inside each section, order controls like this:

1. Enable toggle.
2. Main mode selector.
3. Important behavior controls.
4. Fine tuning sliders.
5. Color/style controls.
6. Advanced/dependency controls.

## Apple-Like Label Rules

- Prefer 1-3 word labels.
- Use sentence case for descriptions.
- Avoid hype words and unclear names.
- Name sliders by user-visible effect, not internal math.
- Keep mode names stable so presets remain understandable.

## Palette Defaults

Dark UI:

- Background: `#0B0B0F`
- Elevated panel: `#15151C`
- Secondary panel: `#1C1C24`
- Separator: `#2C2C35`
- Primary text: `#F5F5F7`
- Secondary text: `#A1A1AA`
- Disabled text: `#5F5F6B`

Accent options:

- Blue: `#0A84FF`
- Purple: `#BF5AF2`
- Green: `#30D158`
- Orange: `#FF9F0A`
- Red: `#FF453A`

## Review Checklist

Before finalizing UI changes:

- The first action in each section is obvious.
- Controls are grouped by user intent.
- Experimental controls are not mixed into the main path.
- One accent color carries selection/active state.
- Warnings and destructive states use semantic color only.
- Labels are consistent across related features.
- Dependencies between controls are explained or hidden.
