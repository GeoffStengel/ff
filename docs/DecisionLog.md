# Decision Log

## 2026-07-08

### Refactored Save System

Reason:
Save/load code had grown inside main.gd and was difficult to maintain.

Decision:
Moved save data building and normalization into SaveSystem.

Benefits:
- Smaller main.gd
- Easier testing
- Clear ownership

## Village Requests v2

Reason

Orderbook layout had become split between
main.gd,
layout helpers,
and UI drawing.

Decision

VillageRequestsUI now owns the entire feature layout.

Benefits

- One owner
- Easier redesign
- Future screens can copy the pattern
- Less coupling to main.gd

## FarmRenderer Extraction

Reason:
Farm/background/plot/tree/farmer drawing had grown inside main.gd, making gameplay coordination harder to scan.

Decision:
FarmRenderer owns pure farm-scene drawing. main.gd keeps scene lifecycle, input, gameplay state, UI controls, sounds, messages, and draw orchestration.

Benefits:
- Smaller visual surface in main.gd
- Farm visuals have one focused owner
- Easier future sprite/style work without touching save, input, orders, or crop logic

## HUDUI Extraction

Reason:
The top HUD layout, label sizing, text formatting, and decorative drawing were split between main.gd and LayoutSystem.

Decision:
HUDUI owns top HUD layout, sizing, formatting, and decorative drawing. main.gd still owns gameplay state, creates the existing Control nodes, and assigns updated values.

Benefits:
- main.gd stays focused on coordination
- HUD spacing and text rules have one owner
- LayoutSystem no longer carries HUD feature-specific helpers

## BottomBarUI Extraction

Reason:
The bottom action/status bar layout and drawing were split between main.gd and LayoutSystem.

Decision:
BottomBarUI owns bottom-bar placement, action/plot card rectangles, message toast geometry, label sizing, and decorative drawing. main.gd keeps current tool state, selected plot state, messages, and text assignment.

Benefits:
- Bottom-bar visual rules have one focused owner
- LayoutSystem stays focused on shared layout instead of feature UI
- main.gd keeps coordinating gameplay without drawing bottom-card details

## ToolPanelUI Extraction

Reason:
The left dock/tool/menu panel layout and decorative drawing were split between main.gd and LayoutSystem.

Decision:
ToolPanelUI owns left dock geometry, tool/menu pocket rectangles, row placement, section label placement, button sizing, row spacing, responsive dock geometry, and decorative drawing. main.gd still creates buttons, wires callbacks, and owns selected tool/side-tab state.

Benefits:
- Left dock visual rules have one focused owner
- Button callbacks and gameplay state stay in main.gd
- LayoutSystem continues shrinking toward shared geometry only

## DrawerUI Extraction

Reason:
The shared right-side drawer shell layout and decorative drawing were split between main.gd and LayoutSystem.

Decision:
DrawerUI owns the shared drawer rectangle, content/hint rectangles, feature panel sizing, active-panel visibility helper, and decorative shell drawing. main.gd keeps side_tab, panel_open, tab callbacks, gameplay, feature text updates, and feature-specific card drawing.

Benefits:
- Shared drawer shell has one owner
- Feature modules can lay out inside the drawer content area consistently
- LayoutSystem now stays focused on shared farm geometry and responsive checks

## Phase 3 Feature UI Extraction

Reason:
Farm Controls, Pantry, Guide, and Help drawer tabs still had feature-specific sizing, spacing, card geometry, and pure display formatting embedded in main.gd.

Decision:
Created FarmControlsUI, PantryUI, GuideUI, and HelpUI. These modules own feature tab layout, control minimum sizes, card backplate geometry, and pure display text helpers. main.gd keeps node creation, callbacks, gameplay state, mutations, UI refresh, sounds, and orchestration.

Benefits:
- Feature tabs can be adjusted in their own files
- main.gd keeps shrinking toward coordinator-only responsibilities
- DrawerUI remains the shared shell while feature modules own internal drawer presentation

## WeatherSystem Extraction

Reason:
Weather definitions, rolling, temperature rules, and weather text helpers belonged with pure gameplay systems instead of being split between GameData and main.gd wrappers.

Decision:
WeatherSystem now owns weather definitions, lookup helpers, seasonal rolling, temperature generation, weather text/icon formatting, rain/heat checks, pollinator chance, and max-water calculation. main.gd still stores current weather and temperature, decides when to roll weather, and coordinates crop updates, sounds, messages, UI refresh, and save/load. GameData delegates weather_table() to WeatherSystem for compatibility.

Benefits:
- One owner for weather rules and display text helpers
- Save/load keys and numeric weather order stay compatible
- CropSystem can keep using weather names without depending on WeatherSystem
- FarmRenderer continues drawing weather visuals from passed weather data only

## Festival, Economy, And Relationship Systems

Reason:
Weekly table rewards, price math, purchase checks, order reward bonuses, and relationship milestones were still embedded in main.gd, InventorySystem, OrderSystem, and TextLibrary.

Decision:
FestivalSystem owns weekly table goals, timing checks, resolution deltas, and equivalent weekly table text. EconomySystem owns prices, affordability, sale values, order payout math, and upgrade capacity math. RelationshipSystem owns score lookup/changes, customer bonuses, short names, summaries, and milestone reward deltas. main.gd still stores state and applies returned deltas while handling input, sounds, messages, logs, and UI refresh.

Benefits:
- Gameplay numbers have focused owners
- Save keys and current balancing stay unchanged
- InventorySystem still mutates inventory while EconomySystem owns money math
- OrderSystem still owns order state while RelationshipSystem owns relationship math

## Pantry Mobile-First Prototype

Reason:
The Pantry screen had become a useful test case for the new cozy journal direction, but its rows, grids, and width constants were still visually cramped and uneven.

Decision:
Pantry now uses shared design tokens, reusable soft card styles, a scrollable drawer page shell, section cards, scannable quantity badges, and responsive one/two-column grids. main.gd still creates the controls, preserves all callbacks, and owns gameplay state.

Benefits:
- Pantry can grow vertically without clipping the drawer
- Shared readable-width and spacing tokens replace Pantry-only magic numbers
- Make Jam is the single obvious primary action
- Pantry becomes the prototype pattern for migrating other screens later

## Fig Farmer OS v1 PageChrome

Reason:
The project needs one reusable mobile-first page shell before migrating more screens, so each future page does not invent its own header, scroll host, and navigation.

Decision:
Added PageChromeUI and BottomNavigationUI. Pantry is the first page hosted inside PageChrome. The legacy drawer and left-dock tabs remain during migration. Bottom navigation reuses the existing `_set_side_tab()` callback instead of creating a new router.

Back behavior:
No navigation history exists yet, so Back returns to the Farm/default drawer view. Close uses the existing panel-close behavior by setting the panel closed.

Benefits:
- One shared mobile-page composition
- One intentional scroll owner for migrated pages
- Existing callbacks and gameplay behavior stay intact
- Future pages can migrate without rebuilding the chrome
