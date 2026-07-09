# Fig Farmer UI Framework

## Philosophy

The UI framework is designed to work like a tiny CSS framework.

Instead of every screen inventing its own spacing and drawing code,
all screens share the same building blocks.

---

## Layers

Feature UI

↓

UITheme

↓

UILayout

↓

UIConstants

---

## Responsibilities

### UIConstants

Owns:

- spacing
- typography
- standard heights
- padding

Never draws anything.

---

### UILayout

Owns:

- geometry
- grids
- stacks
- alignment
- rectangles

Never draws anything.

---

### UITheme

Owns:

- colors
- borders
- backgrounds
- cards
- badges
- buttons
- typography drawing

Never knows gameplay.

---

### Feature UI

Examples:

VillageRequestsUI

HUDUI

InventoryUI

ToolPanelUI

Each feature combines:

UIConstants

UILayout

UITheme

to build its own interface.

---

## Goal

Every UI screen should be understandable by opening ONE file.

Every visual change should require changing ONE place.