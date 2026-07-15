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

## 2026-07-10 Village Requests Visual Polish

### Goal
Polish the Village Requests screen into a cleaner delivery-app-style interface without changing order logic, payouts, timers, callbacks, save data, or gameplay behavior.

### Completed
- Tightened the weekly contract into a compact supporting card.
- Made the selected request read as one unified hero card with status, customer, timer, request, payout, and one primary action.
- Kept Accept/Fulfill as the only primary action row and moved Sell crate into a smaller secondary action below the request list.
- Increased available request list space and switched request cards to compact two-line delivery-style summaries.
- Added searchable VillageRequestsUI sections for weekly contract, hero card, primary action, available requests, secondary actions, and responsive layout.

### Next
- Manually test Orders tab selection, scroll behavior, Accept/Fulfill visibility, Sell crate, and narrower window sizes in Godot.



## 2026-07-12 - Village Requests Pager Polish

### Goal

Clean up the Available Requests section and fix the request card overflowing the drawer.

### Completed

- Replaced the old request list with a one-card pager.
- Added page count and compact previous/next arrow controls.
- Synchronized pager navigation with the selected request.
- Simplified request card text into a compact two-line summary.
- Removed the obsolete request-list backplate.
- Isolated Available Requests inside a fixed-width `request_pager_section`.
- Moved request text into a clipped child Label.
- Removed `order_page_button` from the generic Village Requests layout pass.
- Fixed the request card overflowing outside the drawer.

### Result

Village Requests now has a cleaner hierarchy and a working Available Requests pager.

The current build is a strong known-good fallback point before the next feature or architecture pass.

### Next

- Update the repository.
- Create a known-good checkpoint commit/tag.
- Continue UI/UX polish and bounded `main.gd` cleanup.

## 2026-07-13 - Runtime UI Inspection

### Goal

Add safe runtime UI inspection tooling and descriptive runtime node names without changing gameplay, layout, save compatibility, callbacks, or architecture.

### Completed

- Added `scripts/ui/ui_debug_overlay.gd`.
- Wired a high-layer developer overlay into `main.gd`.
- Ctrl+Shift+D toggles visible Control bounds and hovered Control metadata.
- Named important runtime-created Controls across HUD, tool/menu dock, drawer panels, Village Requests, Pantry, Guide, Help, bottom bar, and dialogue.
- Documented the runtime naming convention in CodingStandards.

### Next

- Manually test Ctrl+Shift+D in Godot and hover over the Village Requests pager card, Pantry cards, HUD labels, and bottom bar labels.


## 2026-07-14 UI Design Direction

### Goal

Establish a long-term visual direction for the entire game before beginning a larger UI redesign.

### Discussion

- Evaluated the current Pantry layout using the runtime UI debug overlay.
- Identified several UX pain points:
  - weak visual hierarchy,
  - inconsistent spacing,
  - excessive use of bordered panels,
  - generic typography,
  - competing button styles,
  - limited mobile responsiveness.
- Explored a mobile-first interface inspired by modern delivery apps and cozy farming games.
- Agreed that desktop layouts should expand the mobile experience rather than becoming completely different interfaces.
- Decided to continue growing `UIStyleGuide.md` as the project's design system instead of creating a separate design document.

### Next

- Define typography and font selection.
- Establish a reusable card and button system.
- Design a shared visual language for all feature screens.
- Prototype a redesigned Pantry using the updated style guide before applying the design system across the rest of the game.


## 2026-07-14 Pantry Redesign Prototype

### Goal

Complete one bounded mobile-first Pantry redesign phase without changing gameplay behavior.

### Completed

- Added shared readable-width, breakpoint, spacing, radius, button-height, typography, and button-intent tokens.
- Added reusable journal card, section card, quiet card, and quantity badge style helpers.
- Redesigned Pantry as a vertically focused scrollable page with Harvest, Preserves, Planting Stock, and About Jam sections.
- Kept `FarmPantryPanel` as the Pantry VBox and added `FarmPantryScroll` as the drawer scroll shell.
- Preserved Pantry callbacks, inventory labels, crafting buttons, and save/gameplay behavior.
- Confirmed no bundled licensed font files were present, so typography roles still use the current font/fallback.

### Next

- Manually test Pantry in Godot at desktop and narrow widths.
- If the prototype feels good, migrate Guide next because it has mostly static educational content and lower gameplay risk.


## 2026-07-14 Fig Farmer OS v1

### Goal

Create the first reusable mobile-first page shell and migrate Pantry into it without changing gameplay.

### Completed

- Added `PageChromeUI` for the shared page header, centered title group, content scroll host, and bottom navigation host.
- Added `BottomNavigationUI` for touch-friendly nav items with icons, labels, runtime names, and selected state.
- Migrated Pantry content into the PageChrome content host.
- Reused existing `_set_side_tab()` callbacks for bottom navigation.
- Kept the old drawer navigation as fallback for Farm, Village Requests, Guide, and More/Help.
- Back now returns to the Farm/default drawer view because no page-history stack exists yet.

### Next

- Manually test PageChrome and Pantry in Godot.
- Migrate Guide next if the PageChrome pattern feels solid.


## 2026-07-14 PageChrome Remaining Pages

### Goal

Move the remaining drawer feature pages into the shared PageChrome shell without changing gameplay behavior, callbacks, save data, or feature text ownership.

### Completed

- Mounted Farm, Village Requests, Pantry, Guide, and More/Help under the single `GlobalPageContent` host.
- Kept the old drawer shell and side dock code as fallback architecture, but stopped exposing migrated panels through the old drawer panel list.
- Added container-mode layout handling to FarmControlsUI, VillageRequestsUI, GuideUI, and HelpUI.
- Updated bottom navigation to open and switch PageChrome pages directly instead of toggling the page closed through `_set_side_tab()`.
- Added SectionHeaderUI and routed existing feature section-label helpers through it.
- Kept all gameplay callbacks in `main.gd`.

### Next

- Manually test all five bottom navigation pages in Godot.
- Check narrow/mobile-ish window widths and confirm `GlobalPageContentScroll` is the only vertical scroll owner for migrated pages.
- Continue replacing remaining text-heavy page bodies with shared section/card components.
