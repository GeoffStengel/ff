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

## Drawer And Feature UI

- `scripts/ui/drawer_ui.gd`
  - Shared right drawer shell, content/hint geometry, feature panel sizing, and active-panel visibility.
- `scripts/ui/village_requests_ui.gd`
  - Village Requests layout, sizing, card geometry, and request display copy.
- `scripts/ui/farm_controls_ui.gd`
  - Farm tab layout, sizing, spacing, and card geometry.
- `scripts/ui/pantry_ui.gd`
  - Pantry tab layout, sizing, spacing, card geometry, and pantry display copy.
- `scripts/ui/guide_ui.gd`
  - Guide tab layout, sizing, spacing, card geometry, and guide display copy.
- `scripts/ui/help_ui.gd`
  - Help tab layout, sizing, spacing, card geometry, and help display copy.

## Other UI Modules

- `scripts/ui/hud_ui.gd`
- `scripts/ui/bottom_bar_ui.gd`
- `scripts/ui/tool_panel_ui.gd`
