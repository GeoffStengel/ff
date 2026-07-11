# Fig Farmer - Architecture

## Philosophy

Fig Farmer is built around one core idea:

**main.gd should coordinate the game, not contain the game.**

Each gameplay feature belongs to one focused system.

---

## High-Level Structure

```
main.gd
|
|-- Systems
|   |-- CropSystem
|   |-- InventorySystem
|   |-- OrderSystem
|   |-- WeatherSystem
|   |-- FestivalSystem
|   |-- EconomySystem
|   |-- RelationshipSystem
|   |-- SaveSystem
|   `-- ...
|
|-- UI
|   |-- DrawerUI
|   |-- VillageRequestsUI
|   |-- FarmControlsUI
|   |-- PantryUI
|   |-- GuideUI
|   |-- HelpUI
|   |-- HUDUI
|   |-- BottomBarUI
|   |-- ToolPanelUI
|   `-- Theme / Layout / Constants
|
`-- Renderers
    |-- FarmRenderer
    |-- EffectsRenderer
    `-- ...
```

---

## Responsibilities

### main.gd

Responsible for:

- scene lifecycle
- player input
- sounds
- UI refresh
- connecting systems together

Not responsible for:

- crop math
- order math
- save parsing
- inventory calculations
- UI layout

---

## Systems

Systems should be pure whenever possible.

They should:

- receive data
- process data
- return data

They should avoid:

- scene nodes
- Control nodes
- audio
- messages

---

## UI

UI files own layout.

They know:

- spacing
- padding
- fonts
- colors
- rectangles

They do not know gameplay.

---

## Future Goal

Eventually main.gd should be under 1500 lines.
