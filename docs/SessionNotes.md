## 2026-07-08

### Goal
Finish Village Requests architecture.

### Completed
- Added UITheme
- Added UIConstants
- Added UILayout
- Refactored orderbook layout map

### Next
- Apply layout helper
- Theme integration

## 2026-07-09

### Goal
Finish FarmRenderer extraction while preserving gameplay behavior.

### Completed
- FarmRenderer now draws the farm board, plots, soil texture, plant/tree visuals, variety tags, ripe markers, peak sparkles, side-scene props, and farmer/tool visuals.
- main.gd now delegates farm-scene visuals and keeps coordination, UI, input, save/load, sounds, messages, and gameplay logic.
- Removed stale farm drawing callbacks and obsolete helper wrappers from main.gd.

### Next
- Manually test farm visuals in Godot.
- Continue later with TreeRenderer or EffectsRenderer only if those become large enough to justify a split.

## 2026-07-09 HUDUI

### Goal
Extract the top HUD without changing gameplay behavior or visible layout.

### Completed
- Added HUDUI for top HUD layout, label widths, formatting, and decorative drawing.
- main.gd now creates the existing HUD controls and asks HUDUI to place/size/update them.
- Removed HUD-only geometry helpers from LayoutSystem.
- Recorded the FarmRenderer bee icon integration fix.

### Next
- Manually test the top HUD in Godot, especially resize behavior and day/weather/resource text.

## 2026-07-09 BottomBarUI

### Goal
Extract the bottom action/status UI without changing gameplay behavior or visible layout.

### Completed
- Added BottomBarUI for bottom-bar placement, card geometry, message toast geometry, label sizing, and decorative drawing.
- main.gd now keeps action/plot/message text decisions and delegates bottom-bar layout/drawing.
- Removed bottom-bar-only geometry helpers from LayoutSystem.

### Next
- Manually test action card, selected plot card, message toast, resize behavior, and mobile-width layout in Godot.

## 2026-07-09 ToolPanelUI

### Goal
Extract the left dock/tool/menu panel without changing gameplay behavior or visible layout.

### Completed
- Added ToolPanelUI for left dock placement, pocket geometry, row spacing, section label placement, button sizing, and decorative drawing.
- main.gd now keeps button creation, callbacks, selected tool state, and side-tab state while delegating dock layout/drawing.
- Removed left-dock-only geometry helpers from LayoutSystem.

### Next
- Manually test tool buttons, menu buttons, selected states, drawer opening, and mobile-width dock behavior in Godot.

## 2026-07-10 DrawerUI

### Goal
Extract the shared right-side drawer shell without changing gameplay behavior or visible layout.

### Completed
- Added DrawerUI for drawer placement, content/hint geometry, shared panel sizing, active-panel visibility, and decorative shell drawing.
- main.gd now keeps side_tab, panel_open, tab callbacks, feature text updates, and feature-specific drawer card drawing.
- Removed drawer-only geometry helpers from LayoutSystem.

### Next
- Manually test every drawer tab, Village Requests alignment, resize behavior, and save/load with a drawer open.

## 2026-07-10 Phase 3 Feature UI

### Goal
Complete Phase 3 UI modularization for Farm Controls, Pantry, Guide, and Help without changing gameplay behavior.

### Completed
- Added FarmControlsUI for Farm tab sizing, spacing, and card geometry.
- Added PantryUI for Pantry tab sizing, spacing, card geometry, and preserve display copy.
- Added GuideUI for Guide tab sizing, spacing, card geometry, notebook copy, and legend copy.
- Added HelpUI for Help tab sizing, spacing, card geometry, and help text.
- main.gd now keeps button creation, callbacks, gameplay state, mutations, UI refresh, sounds, and orchestration.
- Added docs/ArchitectureMap.md.

### Next
- Manually test every drawer tab, pantry actions, guide/help text, resize behavior, mobile-width layout, save/load, and audio.

## 2026-07-10 WeatherSystem

### Goal
Extract weather rules and weather formatting without changing gameplay behavior, save keys, or visible weather layout.

### Completed
- Added scripts/systems/weather_system.gd as the owner for weather definitions, lookups, rolling, temperature generation, weather text/icon formatting, rain/heat helpers, pollinator chance, and max-water calculation.
- main.gd now preloads the systems WeatherSystem and keeps only state ownership, day-transition timing, UI refresh, messages, sounds, and gameplay coordination.
- GameData.weather_table() delegates to WeatherSystem.weather_definitions() so older callers stay compatible.
- Removed the stale root weather_system.gd file and its generated UID sidecar.

### Next
- Manually test day advancement, Rain/Heat crop behavior, HUD weather text, weather visuals, and save/load with each weather type.

## 2026-07-10 Festival/Economy/Relationship Systems

### Goal
Extract one bounded gameplay architecture batch without changing gameplay behavior, save compatibility, rewards, progression, or UI text.

### Completed
- Added FestivalSystem for weekly table goals, timing checks, resolution deltas, and weekly table text.
- Added EconomySystem for prices, purchase checks, sale values, order reward math, and barrel water capacity math.
- Added RelationshipSystem for score lookup/changes, customer bonuses, short customer names, relationship summary text, and milestone reward deltas.
- main.gd now applies returned deltas and keeps state, input, sounds, messages, logs, save/load, and UI refresh.
- InventorySystem keeps inventory mutation while delegating money math to EconomySystem.
- OrderSystem keeps order state while delegating relationship bonus/name math to RelationshipSystem.

### Next
- Manually test buying, selling, order completion/expiration, relationship milestones, weekly table success/failure, and save/load around festival resolution.
