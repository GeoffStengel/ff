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