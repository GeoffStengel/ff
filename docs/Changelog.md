# Changelog

## 2026-07-08

### Refactoring

- Extracted SaveSystem.
- Extracted CropSystem.
- Added VillageRequestsUI.
- Added UITheme.
- Added UIConstants.

### UI

- Started redesigning Village Requests.
- Introduced shared card styling.

### Architecture

- Added documentation folder.
- Added coding standards.

## 2026-07-09

### Architecture

- Completed VillageRequestsUI v2
- Removed remaining ORDERBOOK_* constants
- Village Requests now owns:
  - layout
  - sizing
  - card geometry
  - button sizing
  - scroll sizing
  - decorative drawing
- main.gd now coordinates Village Requests instead of laying it out.

### Rendering

- Completed the FarmRenderer extraction for farm-scene drawing.
- Moved plot plants, variety tags, ripe markers, peak sparkles, farm props, side-scene details, and farmer drawing into FarmRenderer.
- Removed callback bridges from farm plot drawing.
- main.gd now keeps the draw order and gameplay state while FarmRenderer owns pure farm visuals.
- Fixed the missing FarmRenderer bee icon integration so pollinator visuals stay renderer-owned.

### UI

- Completed the HUDUI extraction for the top HUD.
- Moved top HUD geometry, label widths, text formatting, and decorative bar drawing into HUDUI.
- Removed the old HUD-only helpers from LayoutSystem.
- Completed the BottomBarUI extraction for the bottom action/status area.
- Moved bottom-bar geometry, action/plot card rectangles, message toast geometry, label placement, and decorative drawing into BottomBarUI.
- Removed the old bottom-bar-only helpers from LayoutSystem.
- Completed the ToolPanelUI extraction for the left dock/tool/menu panel.
- Moved left dock geometry, pocket rectangles, row/label placement, button sizing, row spacing, and decorative dock drawing into ToolPanelUI.
- Removed the old left-dock-only helpers from LayoutSystem.
- Completed the DrawerUI extraction for the shared right-side drawer shell.
- Moved drawer geometry, content/hint rectangles, shared panel sizing, active-panel visibility helper, and decorative drawer shell drawing into DrawerUI.
- Removed the old drawer-only helpers from LayoutSystem.

## 2026-07-10

### UI

- Completed Phase 3 feature UI modularization for FarmControlsUI, PantryUI, GuideUI, and HelpUI.
- Added feature UI modules for Farm Controls, Pantry, Guide, and Help drawer tabs.
- Moved feature tab sizing, panel spacing, control minimum sizes, card backplate geometry, and pure display text helpers into the new modules.
- Kept callbacks, gameplay state, inventory mutations, crop mutations, save/load, audio, and UI refresh orchestration in main.gd.
- Added docs/ArchitectureMap.md to keep module ownership visible.

### Systems

- Completed WeatherSystem extraction into scripts/systems/weather_system.gd.
- Moved weather definitions, lookups, seasonal rolling, temperature generation, weather formatting, rain/heat helpers, pollinator chance, and max-water calculation into WeatherSystem.
- Kept current_weather and temperature_f state, day-transition timing, save/load coordination, sounds, messages, and UI refresh in main.gd.
- Kept GameData.weather_table() as a compatibility delegate to WeatherSystem.weather_definitions().
- Completed FestivalSystem, EconomySystem, and RelationshipSystem extraction.
- Moved weekly table goal/resolution math into FestivalSystem.
- Moved pricing, affordability, sale values, order payout math, and barrel water capacity math into EconomySystem.
- Moved relationship score changes, customer bonuses, short names, summaries, and milestone reward deltas into RelationshipSystem.
- Kept save keys, UI text, reward numbers, customer names, and current balance unchanged.
