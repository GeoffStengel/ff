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