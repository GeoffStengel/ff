# ============================================================
# /*=== LAYOUT SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# LayoutSystem
# ------------------------------------------------------------
# Centralized helper for positioning UI panels, HUD elements,
# drawers, farm board, bottom cards, and responsive/mobile layout.
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
# HUD / TOP BAR
# ============================================================

static func hud_rect(screen_pad: int, hud_h: int, viewport_size: Vector2) -> Rect2:
	var x: float = float(screen_pad)
	var y: float = 14.0
	var w: float = maxf(1.0, viewport_size.x - float(screen_pad * 2))
	var h: float = maxf(1.0, float(hud_h - 8))

	return Rect2(Vector2(x, y), Vector2(w, h))


static func hud_row_one_pos(hud: Rect2) -> Vector2:
	return hud.position + Vector2(10, 5)


static func hud_row_two_pos(hud: Rect2) -> Vector2:
	return hud.position + Vector2(10, 29)


static func hud_label_width(key: String) -> int:
	match key:
		"Day":
			return 76
		"Weather":
			return 700
		"Coins":
			return 72
		"Water":
			return 78
		"Cuts":
			return 78
		"Figs":
			return 72
		"Compost":
			return 94
		"Rep":
			return 82
		"Guide":
			return 100
		_:
			return 70


# ============================================================
# LEFT DOCK
# ------------------------------------------------------------
# Left dock contains:
# - Tool pocket
# - Menu pocket
#
# On desktop: fixed height.
# On mobile: fills available vertical space.
# ============================================================

static func left_dock_rect(
	screen_pad: int,
	hud_h: int,
	left_dock_w: int,
	bottom_bar_h: int,
	gap: int,
	viewport_size: Vector2,
	mobile: bool
) -> Rect2:
	var x: float = float(screen_pad)
	var y: float = float(hud_h + gap)
	var w: float = float(left_dock_w)

	if mobile:
		var h: float = viewport_size.y - float(hud_h + bottom_bar_h + screen_pad + gap * 2)
		return Rect2(Vector2(x, y), Vector2(w, maxf(240.0, h)))

	return Rect2(Vector2(x, y), Vector2(w, 548.0))


static func tool_pocket_rect(dock: Rect2) -> Rect2:
	var pad: float = 10.0
	var x: float = dock.position.x + pad
	var y: float = dock.position.y + 18.0
	var w: float = maxf(1.0, dock.size.x - pad * 2.0)
	var h: float = 224.0

	return Rect2(Vector2(x, y), Vector2(w, h))


static func menu_pocket_rect(dock: Rect2) -> Rect2:
	var pad: float = 10.0
	var x: float = dock.position.x + pad
	var y: float = dock.position.y + 262.0
	var w: float = maxf(1.0, dock.size.x - pad * 2.0)
	var h: float = maxf(1.0, dock.size.y - 274.0)

	return Rect2(Vector2(x, y), Vector2(w, h))


static func tool_column_pos(tool_pocket: Rect2) -> Vector2:
	return tool_pocket.position + Vector2(15, 20)


static func menu_column_pos(menu_pocket: Rect2) -> Vector2:
	return menu_pocket.position + Vector2(15, 20)


# ============================================================
# RIGHT DRAWER / ORDER BOOK AREA
# ------------------------------------------------------------
# This is the important design area for the order book.
#
# Desktop:
# - Drawer sits on the right side.
# - Width is controlled by drawer_w.
#
# Mobile:
# - Drawer spans nearly full width.
# - Starts below HUD.
# - Avoids bottom bar.
# ============================================================

static func drawer_rect(
	screen_pad: int,
	hud_h: int,
	drawer_w: int,
	bottom_bar_h: int,
	gap: int,
	viewport_size: Vector2,
	mobile: bool
) -> Rect2:
	var y: float = float(hud_h + gap)

	if mobile:
		var x: float = float(screen_pad)
		var w: float = maxf(1.0, viewport_size.x - float(screen_pad * 2))
		var h: float = viewport_size.y - float(hud_h + bottom_bar_h + screen_pad + gap * 2)

		return Rect2(Vector2(x, y), Vector2(w, maxf(1.0, h)))

	var x: float = viewport_size.x - float(screen_pad + drawer_w)
	var w: float = float(drawer_w)
	var h: float = viewport_size.y - float(hud_h + screen_pad + gap)

	return Rect2(Vector2(x, y), Vector2(w, maxf(1.0, h)))


static func drawer_hint_pos(drawer: Rect2) -> Vector2:
	return drawer.position + Vector2(20, 18)


static func drawer_hint_size(drawer: Rect2) -> Vector2:
	return Vector2(maxf(1.0, drawer.size.x - 40.0), 18.0)


static func drawer_content_pos(drawer: Rect2) -> Vector2:
	return drawer.position + Vector2(14, 42)


static func drawer_content_size(drawer: Rect2) -> Vector2:
	return drawer.size - Vector2(28, 56)


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
# BOTTOM STATUS BAR
# ------------------------------------------------------------
# Contains two bottom cards:
# - Current action / controls
# - Selected plot info
#
# On desktop, it follows the farm board.
# On mobile, it locks to the bottom of the screen.
# ============================================================

static func bottom_status_rect(
	screen_pad: int,
	bottom_bar_h: int,
	gap: int,
	viewport_size: Vector2,
	board: Rect2,
	mobile: bool
) -> Rect2:
	if mobile:
		var x: float = float(screen_pad)
		var y: float = viewport_size.y - float(bottom_bar_h + screen_pad)
		var w: float = maxf(1.0, viewport_size.x - float(screen_pad * 2))
		var h: float = float(bottom_bar_h)

		return Rect2(Vector2(x, y), Vector2(w, h))

	var desktop_x: float = board.position.x + 10.0
	var desktop_y: float = board.end.y + float(gap)
	var desktop_w: float = maxf(1.0, board.size.x - 20.0)

	return Rect2(Vector2(desktop_x, desktop_y), Vector2(desktop_w, float(bottom_bar_h)))


static func bottom_card_rect(index: int, gap: int, bottom: Rect2) -> Rect2:
	var safe_index: int = clampi(index, 0, 1)
	var outer_pad: float = 10.0
	var card_gap: float = float(gap)
	var card_w: float = maxf(1.0, (bottom.size.x - card_gap - outer_pad * 2.0) * 0.5)
	var card_h: float = maxf(1.0, bottom.size.y - outer_pad * 2.0)
	var x: float = bottom.position.x + outer_pad + float(safe_index) * (card_w + card_gap)
	var y: float = bottom.position.y + outer_pad

	return Rect2(Vector2(x, y), Vector2(card_w, card_h))


static func bottom_action_label_pos(card: Rect2) -> Vector2:
	return card.position + Vector2(8, 8)


static func plot_card_label_pos(card: Rect2) -> Vector2:
	return card.position + Vector2(8, 8)


static func bottom_card_label_size(card: Rect2) -> Vector2:
	return card.size - Vector2(16, 14)


# ============================================================
# MESSAGE / TOAST LABEL
# ------------------------------------------------------------
# Small message label that appears above the bottom status area.
# ============================================================

static func message_label_pos(bottom: Rect2) -> Vector2:
	return Vector2(bottom.position.x + 16.0, bottom.position.y - 40.0)


static func message_label_size(bottom: Rect2) -> Vector2:
	return Vector2(maxf(1.0, bottom.size.x - 32.0), 28.0)
# ============================================================
# /*=== LAYOUT SYSTEM FILE END ===*/
# ============================================================
