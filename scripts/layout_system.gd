# ============================================================
# /*=== LAYOUT SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# LayoutSystem
# ------------------------------------------------------------
# Centralized helper for shared farm board geometry and
# responsive/mobile layout checks.
#
# This file should stay "dumb":
# - No gameplay state
# - No node references
# - No drawing
# - Only geometry calculations
# ============================================================


# ============================================================
# RESPONSIVE BREAKPOINTS
# ============================================================

const MOBILE_WIDTH_THRESHOLD: float = 900.0


static func is_mobile_layout(viewport_size: Vector2) -> bool:
	return viewport_size.x < MOBILE_WIDTH_THRESHOLD


# ============================================================
# FARM BOARD
# ------------------------------------------------------------
# Controls the physical rectangle around the farm grid.
# ============================================================

static func farm_board_size(grid_w: int, grid_h: int, tile_size: int) -> Vector2:
	var w: float = float(grid_w * tile_size + 52)
	var h: float = float(grid_h * tile_size + 48)

	return Vector2(w, h)


static func farm_board_rect(farm_board_position: Vector2, board_size: Vector2) -> Rect2:
	return Rect2(farm_board_position, board_size)


static func plot_bed_rect(farm_origin: Vector2, grid_w: int, grid_h: int, tile_size: int) -> Rect2:
	var pad: float = 10.0
	var x: float = farm_origin.x - pad
	var y: float = farm_origin.y - pad
	var w: float = float(grid_w * tile_size - 8) + pad * 2.0
	var h: float = float(grid_h * tile_size - 8) + pad * 2.0

	return Rect2(Vector2(x, y), Vector2(w, h))


# ============================================================
# /*=== LAYOUT SYSTEM FILE END ===*/
# ============================================================
