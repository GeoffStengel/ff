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