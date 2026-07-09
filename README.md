# ff
we shall see
# Fig Farmer

A cozy 2D Godot 4 prototype about planting fig cuttings, watering trees, composting favorites, harvesting ripe fruit, and serving a village market.

## Play

Open this folder in Godot 4.x and run `scenes/main.tscn`.

## Controls

- `1`: Plant tool
- `2`: Water tool
- `3`: Compost tool
- `4`: Harvest tool
- `WASD` or arrow keys: Move the farmer
- `F` or `Enter`: Use the selected tool on the farmer's plot
- `C`: Take a cutting from an established or ripe tree
- `I`: Open the selected-plot inspection card in the Guide
- `Q/E`: Change selected fig variety
- `Space`: End the day
- `P` or `Esc`: Pause/resume
- `Esc`: Close an open note popup, or pause when no note is open
- `F5`: Save the farm
- `F9`: Load the saved farm
- Sound button: Toggle game sound on/off
- Left sidebar page buttons: Open or close Farm, Orders, Pantry, Guide, and Help drawers
- Left click: Move to a plot and use the selected tool

## Current Loop

Move your farmer around the farm, then plant Chicago Hardy, Black Madeira, White Madeira #1, or Ronde de Bordeaux fig cuttings. Each variety grows differently and is stored separately after harvest. Weather changes each day with a season and temperature, the market board offers several optional orders, villagers build friendships over time, weekly Fig Table goals reward planning, and coins can buy starter trees, compost, mason jars, water capacity, or a pollinator garden.

## Design Direction

Fig Farmer should feel like a small village economy, not just a crop timer. The strongest future additions are named villagers with relationship meters, seasonal festivals, fig preserving recipes, soil personalities, and farm layouts that let players specialize in speed, quality, or big harvests.

## Progression

- Weekly Fig Table goals track figs delivered through accepted orders, crates, and jam sales. Hit the target for coins, compost, and Trust. If you miss the weekly target, the week simply rolls over with no Trust loss.
- The order board can show 1-5 order offers. Browsing or ignoring offers has no Trust penalty.
- Accepting an order starts its timer. Completing accepted orders builds friendship and Trust; missing accepted orders can lower both.
- Friendship improves future order rewards and unlocks milestone gifts from each villager.

## Fig Learning

- The Fig Guide explains the selected cultivar and includes a selected-plot inspection card with cultivar, moisture, growth, cutting readiness, next step, and care notes.
- Growth is compressed for gameplay: real nursery-grown figs often need 1-3 years before reliable fruit, while the game turns that patience into watered days.
- Watering matters most while trees are young and while fruit is forming. Missing water slows growth; heat can reduce quality.
- Figs should ripen on the tree. In game, harvest when visible ripe figs appear; in real life, ripe figs soften, droop, and detach easily.
- Chicago Hardy is used as its own cultivar here, not simply renamed Brown Turkey.

## Saving

Use the Save and Load buttons, or press `F5` and `F9`. The save file lives in Godot's `user://` data folder as `fig_farmer_save.json`.

## Order Logbook

The Orders tab includes a compact Logbook that records recent accepted orders, completed orders, jam sales, crate sales, and Weekly Fig Table results. Repeated same-day entries are collapsed so the log stays readable.

## Tutorial Guide

The notebook now includes a five-step guide:

- Plant a Chicago Hardy cutting.
- Water a planted tree.
- Wait through days until figs appear.
- Harvest ripe figs.
- Fulfill a village order.

Completing the guide gives a small coin and compost bonus.

## Ripeness

Ripe figs now have timing:

- Newly ripe figs are harvestable.
- Peak-ripe figs give the best yield.
- Very soft figs are still usable but no longer get the peak bonus.
- Overripe figs reduce yield.

This teaches the real fig habit of ripening on the tree and rewarding careful harvest timing.

## Propagation

Established or ripe fig trees can be clipped for a same-cultivar cutting with `C` or the Take Cutting button. This teaches that named fig cultivars are usually propagated by cuttings, which clone the parent tree. Clipping a tree sets back its fruit progress, so the player chooses between harvest now or expand the nursery.

## Visual Cues

- Small rounded patterned color tabs on plots show the planted cultivar: red stripe for Chicago, blue dots for Black Madeira, yellow band for White Madeira #1, and green triangle for RdB.
- Blue drops mean a tree is watered today.
- A bright ring means ripe fruit; sparkles mean peak-ripe figs.
- Dark fruit or fallen fruit means overripe figs.
- A green sprout marker means the tree can provide a cutting.
- The icon beside the farmer shows the selected tool.

## UX Notes

The UI update loop now avoids rebuilding every label and button on every frame; full UI refreshes happen after state changes, while lightweight HUD/message updates keep time-sensitive text fresh. Save loading also validates plot grid dimensions and fills missing plot keys before applying saved data.

A layout-system pass centralizes the main spacing constants (`SCREEN_PAD`, `HUD_H`, `LEFT_DOCK_W`, `DRAWER_W`, `BOTTOM_BAR_H`, `GAP`, and `PANEL_RADIUS`) and computes the farm board, drawer, sidebar, HUD, and bottom status positions from helper rectangles instead of scattered coordinates. The farm origin and tile size are now layout-driven, with an initial narrow-screen fallback that keeps the game usable while a true mobile bottom toolbar remains a future polish pass.

Plot inspection and the jam recipe open as a centered Farmer's Note popup, making learning feel more like in-world guidance and less like another permanent menu. The farm view keeps moment-to-moment hints in the bottom cards instead of speech bubbles over the farmer.

The farm grid now sits on a framed orchard board, while the tutorial-inspired left sidebar holds tools, page buttons, and quick supplies. Farm, Orders, Pantry, Guide, and Help open as a right-side drawer so the farm stays visible without the old heavy permanent panel.

The farmer tool icon only appears when the selected tool can be used on the current plot. If it disappears, check the bottom action bar for the reason, such as no cuttings, empty barrel, occupied plot, or figs not ripe yet.

A mockup-inspired UI pass adds rounded frames, a wide top HUD strip for day, weather, coins, supplies, Trust, and guide progress, icon-forward status labels, styled role-based buttons, a compact sound toggle, and a polished bottom command strip with the selected action on the left and a visual selected-plot card on the right. End-of-day messages now summarize what changed, including growth, drying soil, ripening figs, and order timers. Pause freezes the day timer and prevents accidental farm actions. Short toast messages appear above the bottom action bar so important feedback stays readable, with softened borders and cleaner HUD spacing. Small procedural sound cues now confirm planting, watering, composting, harvesting, selling, accepting orders, saving, loading, pausing, and starting a new day.

## Side Tabs

The page navigation now lives in the left sidebar as padded icon buttons for Farm, Orders, Pantry, Guide, and Help; hovering shows the name, tapping opens the matching right drawer, and tapping it again closes the drawer. UI buttons do not take keyboard focus, so arrow keys keep moving the farmer. Each page uses compact section labels, card-style section backgrounds, a consistent inset content grid, and slightly inset full-width action bars for clearer scanning. Farm holds tools and shop actions in a reference-inspired control layout with a header divider, consistent action rows, contextual cutting controls that only appear when useful, and clearer shop price labels. Orders holds the optional order board, crate sales, and the compact logbook, Pantry holds stored figs/cuttings/jars/jam plus preserve actions, Guide holds cultivar notes and visual cues, and Help explains how to play.

## Pantry

The Pantry tab collects stored harvested figs by cultivar, starter cuttings, empty mason jars, finished jam, and clone-ready trees. This keeps inventory readable without crowding the Market tab.

## Weather And Seasons

The top HUD now shows the current season, temperature, and daily weather. Spring leans rainier, summer leans hotter and dries soil faster, autumn favors fog and finishing fruit, and winter is cooler planning time.

## Starter Tree Prices

The shop uses more realistic starter-tree prices as game values:

- Chicago Hardy: $20
- Black Madeira: $50
- White Madeira #1: $60
- Ronde de Bordeaux: $50

## Preserves

The Market tab can preserve harvested figs into jam. Jam now needs five mixed figs plus one empty mason jar. Three mason jars cost 6 coins, and finished jam sells for 18 coins per jar. The Recipe button opens the Guide tab with a short fig jam method: ripe figs, sugar, lemon juice, simmer until thick, then jar it.

Soil moisture is staged now: wet soil is dark, moist soil is medium brown, and dry soil is light with cracks.

## Soil Moisture

Soil now has three visible states: wet, moist, and dry. Wet soil is darker, moist soil is medium brown, and dry soil is light with cracks. Heat dries soil faster, while rain sets planted plots back to wet.

Trust is the visible name for village reputation. It rises from successful orders and festival weeks, and can fall when obligations are missed.
