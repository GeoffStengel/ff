# Architecture Map

## Scene Coordinator

- `scripts/main.gd`
  - Owns scene lifecycle, game state, input, save/load coordination, sounds, messages, UI refresh, and orchestration.
  - Delegates gameplay rules to systems, farm drawing to renderers, and feature layout to UI modules.

## Gameplay Systems

- `scripts/crop_system.gd`
- `scripts/inventory_system.gd`
- `scripts/order_system.gd`
- `scripts/save_system.gd`
- `scripts/systems/economy_system.gd`
- `scripts/systems/festival_system.gd`
- `scripts/systems/relationship_system.gd`
- `scripts/systems/weather_system.gd`
- `scripts/game_data.gd`
- `scripts/text_library.gd`

## Rendering

- `scripts/render/farm_renderer.gd`
  - Owns pure farm/background/plot/tree/farmer/weather drawing.

## Shared UI Foundation

- `scripts/ui/ui_constants.gd`
- `scripts/ui/theme.gd`
- `scripts/ui/layout.gd`
- `scripts/layout_system.gd`
  - Currently limited to shared farm board geometry and responsive layout checks.
- `scripts/ui/section_header_ui.gd`
  - Shared title-case feature section header creation with optional project texture icons.

## Drawer And Feature UI

- `scripts/ui/drawer_ui.gd`
  - Legacy shared right drawer shell, content/hint geometry, feature panel sizing, and active-panel visibility fallback.
- `scripts/ui/village_requests_ui.gd`
  - Village Requests layout, sizing, card geometry, request display copy, and PageChrome container-mode sizing.
- `scripts/ui/farm_controls_ui.gd`
  - Farm page layout, sizing, spacing, card geometry, and PageChrome container-mode sizing.
- `scripts/ui/pantry_ui.gd`
  - Pantry page layout, sizing, responsive grid sizing, section/card styling wrappers, and pantry display copy.
- `scripts/ui/guide_ui.gd`
  - Guide page layout, sizing, spacing, card geometry, guide display copy, and PageChrome container-mode sizing.
- `scripts/ui/help_ui.gd`
  - More/Help page layout, sizing, spacing, card geometry, help display copy, and PageChrome container-mode sizing.

## Other UI Modules

- `scripts/ui/hud_ui.gd`
- `scripts/ui/bottom_bar_ui.gd`
- `scripts/ui/tool_panel_ui.gd`
- `scripts/ui/page_chrome_ui.gd`
  - Shared mobile-first page shell for all current feature pages.
- `scripts/ui/bottom_navigation_ui.gd`
  - Shared bottom navigation item sizing, naming, icons, and active visual state.
