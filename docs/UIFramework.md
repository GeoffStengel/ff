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


## Common Layout Patterns

Preferred Container usage:

- VBoxContainer
  - Vertical page layout.
  - Similar to CSS flex-direction: column.

- HBoxContainer
  - Horizontal rows.
  - Similar to CSS flex row.

- GridContainer
  - Uniform card grids.
  - Similar to CSS grid.

Preferred responsive pattern:

Page
↓
Section
↓
Grid / Row
↓
Card
↓
Content

Whenever practical:

- Parent Containers define available width.
- Child Containers use `SIZE_EXPAND_FILL`.
- `custom_minimum_size` defines minimum size, not fixed size.
- Avoid hardcoded widths unless required by the design.


## Shared Design Tokens

The shared UI foundation now includes mobile-first design tokens for:

- readable page width,
- narrow content breakpoint,
- compact page padding,
- section and card gaps,
- section padding,
- standard button heights,
- card and panel radii,
- typography roles,
- button intent names.

Feature modules should use these tokens before creating feature-specific constants.


## Reusable Components

`UITheme` owns reusable soft journal styles:

- page card style,
- section card style,
- quiet card style,
- quantity badge style.

Feature UI modules may expose feature-specific wrappers around those styles when that keeps one screen easy to understand.

`SectionHeaderUI` owns shared title-case section header Controls. Use it for feature section headings instead of duplicating plain Label construction in `main.gd`.


## Pantry Responsive Pattern

Pantry is the current prototype for later screen migration.

Its responsive chain is:

Drawer content width
-> Pantry scroll shell
-> centered readable Pantry VBox
-> section card
-> grid/row
-> item card
-> expanding label plus fixed quantity badge

At narrow widths, Pantry item grids fall back to one column while preserving callbacks and gameplay references in `main.gd`.


## Page Chrome

PageChrome is the shared mobile-first shell for current feature screens.

Structure:

PageChrome
-> PageHeader
-> Scrollable feature content
-> BottomNavigation

The header owns a left Back slot, centered title group, and right Close slot. The title group contains the feature icon on the left and the page title on the right.

Desktop keeps the same mobile composition. Larger widths center the readable feature content and add breathing room rather than switching to an unrelated desktop layout.

Farm, Village Requests, Pantry, Guide, and More/Help are mounted as children of `GlobalPageContent`. `GlobalPageContentScroll` is the intentional vertical scroll owner for these pages. Feature modules should use container-mode sizing when their controls live inside PageChrome so they do not manually position themselves with drawer coordinates.


## Bottom Navigation

BottomNavigation is the shared navigation row for migrated pages.

Each item has:

- icon,
- readable label,
- descriptive runtime node name,
- active/selected state,
- touch-friendly minimum size.

Bottom navigation opens and switches PageChrome pages directly. The old side dock and drawer shell remain as fallback architecture, but migrated feature panels are not shown through the old drawer panel list.
