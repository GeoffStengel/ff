# UI Style Guide

# Design Philosophy

Fig Farmer's interface should feel like a cozy farmer's journal rather than a traditional game menu.

The UI should emphasize readability, warmth, and simplicity. Every screen should present one primary task at a time while remaining visually consistent across desktop and mobile devices.

## Core Principles

- Mobile-first, responsive layout.
- Desktop expands the mobile layout instead of replacing it.
- Single-column pages are preferred unless multiple columns clearly improve readability.
- Cards are the primary organizational component.
- Whitespace should separate content before borders are added.
- Every page should have one obvious primary action.
- Icons should support recognition without replacing readable text.
- UI elements should feel handcrafted, soft, and inviting.
- Decorative elements should never reduce readability.
- Consistent spacing is more important than adding more visual decoration.


# Responsive Layout Philosophy

Fig Farmer is designed using a mobile-first layout strategy.

Pages should be designed to work comfortably at approximately 375 pixels wide. Larger resolutions should provide additional breathing room rather than completely different layouts.

Preferred responsive behavior:

Drawer
    ↓
Page Container
    ↓
Section Cards
    ↓
Content

Containers should expand naturally using Godot's Container system.

Avoid fixed widths whenever practical.

Use:
- custom_minimum_size for minimum dimensions.
- SIZE_EXPAND_FILL for controls that should occupy available space.
- descriptive runtime node names.

# Player Experience Goals

Every screen should feel:

- Calm.
- Cozy.
- Easy to scan.
- Comfortable on both mouse and touch devices.

Players should immediately understand:

- where they are,
- what information is important,
- and what action should be taken next.

Interfaces should avoid visual clutter, excessive borders, and competing primary actions.


# Typography

Typography should establish a clear visual hierarchy.

Recommended text roles:

- Display Title
- Page Title
- Section Header
- Card Title
- Body Text
- Metadata
- Button Text
- Helper Text

Titles should be warm and inviting.

Body text should prioritize readability.

Small helper text should remain readable without drawing unnecessary attention.



Goal:

Cozy modern farming game.

Inspired by:

- DoorDash
- Uber Eats
- Stardew Valley
- Animal Crossing
- Steam Deck UI

---


## Design Language

Large cards.

Rounded corners.

Soft spacing.

Clear typography.

Minimal borders.

---

## Spacing

Page Padding

18

Section Gap

8

Card Padding

12

Card Gap

8

Button Height

40

Hero Card

180

---

## Information Hierarchy

Header

↓

Hero Card

↓

Primary Action

↓

Scrollable List

---

## Cards

Cards should contain:

Title

Main content

Small metadata row

Primary action

---

## Buttons

One primary button.

Avoid multiple competing buttons.

---

## Typography

Large

Section titles

Medium

Card titles

Small

Metadata

Tiny

Hints


## UIStyleGuide.md

1. Design Philosophy

2. Player Experience Goals

3. Responsive Layout Philosophy

4. Typography

5. Color Palette

6. Spacing Scale

7. Card System

8. Buttons

9. Icons

10. Lists & Grids

11. Forms

12. Dialogs

13. Mobile Rules

14. Animation

15. Accessibility

16. Runtime Naming

17. START/END Comment Convention


# Visual Hierarchy

Every page should follow roughly this order:

Page Title

↓

Primary Information

↓

Primary Action

↓

Supporting Information

↓

Reference / Help Text

Whitespace should establish hierarchy before borders are added.

Cards should group related information.

Buttons should communicate importance through consistent styling rather than color alone.