# Coding Standards

## Section Markers

Every important section uses:

```gdscript
# ============================================================
# /*=== SECTION NAME START ===*/
# ============================================================

...

# ============================================================
# /*=== SECTION NAME END ===*/
# ============================================================
```

---

## File Header

Every file begins with:

Purpose

Responsibilities

Things this file should NOT do

---

## Constants

Never scatter magic numbers.

Instead use:

const PAGE_PADDING := 18
const CARD_HEIGHT := 54

---

## Functions

Prefer many small functions over giant ones.

Ideal length:

20–60 lines

---

## Systems

Systems should never:

- play sounds
- show UI
- call _say()

Instead return data to main.gd.

---

## Comments

Explain WHY.

Avoid comments that only repeat WHAT the code says.

Good:

# Compost gives a 35% bonus growth chance.

Bad:

# Add one to progress.

---

## Runtime UI Node Names

Runtime-created UI Controls should get descriptive `.name` values when they are important for live inspection.

Use:

`Feature + Role + OptionalIndex`

Examples:

- `VillageRequestsPanel`
- `VillageRequestsPagerCard`
- `PantryHarvestCard_0`
- `PantryHarvestAmount_0`
- `TopHUDDayLabel`
- `BottomStatusBarActionCard`

Name feature containers, cards, important labels, grids, rows, and buttons first. Decorative spacers only need names when they help debug layout.

---

## UI Debug Overlay

The developer-only runtime UI inspector toggles with `Ctrl+Shift+D`.

It draws visible Control bounds, highlights the hovered Control, and shows runtime layout metadata without changing gameplay, layout, save data, callbacks, or mouse input.


## Additional Standards

- One responsibility per helper function.
- Avoid creating anonymous Controls. Name important runtime Controls immediately after creation.
- Do not mix layout code with gameplay logic.
- Every important Container should receive a descriptive runtime `.name`.
- Prefer composition over deeply nested helper functions.
- Keep feature-specific UI inside its corresponding UI module whenever practical.