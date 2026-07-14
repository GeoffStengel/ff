extends RefCounted

# ============================================================
# UITheme
# ------------------------------------------------------------
# Shared drawing helpers for Fig Farmer UI.
#
# Purpose:
# Keep cards, panels, buttons, dividers, and badges consistent
# across every UI screen.
#
# Does NOT:
# - Handle gameplay
# - Read input
# - Change game state
# ============================================================
const UIConstants := preload("res://scripts/ui/ui_constants.gd")

# ============================================================
# /*=== COLORS START ===*/
# ============================================================

const PANEL_FILL := Color(0.22, 0.15, 0.09, 0.92)
const CARD_FILL := Color(0.34, 0.24, 0.14, 0.94)
const CARD_FILL_SOFT := Color(0.42, 0.31, 0.18, 0.92)
const BORDER := Color(0.78, 0.57, 0.31, 0.95)
const JOURNAL_PAGE := Color("#fff8e8")
const JOURNAL_CARD := Color("#fffaf0")
const JOURNAL_CARD_SOFT := Color("#f8eed8")
const JOURNAL_BORDER := Color("#ead6aa")
const JOURNAL_BORDER_STRONG := Color("#c9a96a")

const TEXT_MAIN := Color(0.98, 0.90, 0.72, 1.0)
const TEXT_MUTED := Color(0.78, 0.66, 0.48, 1.0)
const TEXT_DARK := Color(0.22, 0.15, 0.09, 1.0)
const TEXT_HELPER := Color("#725431")

const ACCENT_GREEN := Color(0.45, 0.74, 0.38, 1.0)
const ACCENT_GOLD := Color(0.96, 0.72, 0.28, 1.0)
const ACCENT_BLUE := Color(0.42, 0.63, 0.90, 1.0)
const ACCENT_RED := Color(0.86, 0.35, 0.28, 1.0)

# ============================================================
# /*=== COLORS END ===*/
# ============================================================


# ============================================================
# /*=== SPACING START ===*/
# ============================================================

const PAGE_PADDING := UIConstants.PAGE_PADDING
const CARD_PADDING := UIConstants.CARD_PADDING
const SECTION_GAP := UIConstants.SECTION_GAP
const CARD_GAP := UIConstants.CARD_GAP
const RADIUS := UIConstants.BUTTON_RADIUS
const BORDER_WIDTH := 2.0

# ============================================================
# /*=== SPACING END ===*/
# ============================================================


# ============================================================
# /*=== STYLEBOX HELPERS START ===*/
# ============================================================

static func rounded_style(
	fill: Color,
	border: Color,
	radius: int,
	border_width: int = 1
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


static func page_card_style() -> StyleBoxFlat:
	return rounded_style(
		JOURNAL_PAGE,
		Color(0.0, 0.0, 0.0, 0.0),
		UIConstants.PANEL_RADIUS,
		0
	)


static func section_card_style() -> StyleBoxFlat:
	return rounded_style(
		JOURNAL_CARD,
		JOURNAL_BORDER,
		UIConstants.CARD_RADIUS,
		1
	)


static func quiet_card_style() -> StyleBoxFlat:
	return rounded_style(
		JOURNAL_CARD_SOFT,
		Color("#f0dfbd"),
		UIConstants.CARD_RADIUS,
		1
	)


static func quantity_badge_style() -> StyleBoxFlat:
	return rounded_style(
		Color("#efe0c2"),
		Color("#d0b984"),
		8,
		1
	)

# ============================================================
# /*=== STYLEBOX HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== CARD DRAWING START ===*/
# ============================================================

static func draw_panel(canvas: CanvasItem, rect: Rect2) -> void:
	canvas.draw_rect(rect, PANEL_FILL, true)
	canvas.draw_rect(rect, BORDER, false, BORDER_WIDTH)


static func draw_card(canvas: CanvasItem, rect: Rect2, selected: bool = false) -> void:
	var fill: Color = CARD_FILL_SOFT if selected else CARD_FILL
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, BORDER, false, BORDER_WIDTH)


static func draw_divider(canvas: CanvasItem, from: Vector2, width: float) -> void:
	canvas.draw_line(from, from + Vector2(width, 0), BORDER, 1.0)

# ============================================================
# /*=== CARD DRAWING END ===*/
# ============================================================


# ============================================================
# /*=== TEXT DRAWING START ===*/
# ============================================================

static func draw_label(
	canvas: CanvasItem,
	font: Font,
	text: String,
	pos: Vector2,
	size: int = 16,
	color: Color = TEXT_MAIN
) -> void:
	canvas.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


static func draw_muted(
	canvas: CanvasItem,
	font: Font,
	text: String,
	pos: Vector2,
	size: int = 14
) -> void:
	draw_label(canvas, font, text, pos, size, TEXT_MUTED)


static func draw_title(
	canvas: CanvasItem,
	font: Font,
	text: String,
	pos: Vector2
) -> void:
	draw_label(canvas, font, text, pos, 20, TEXT_MAIN)

# ============================================================
# /*=== TEXT DRAWING END ===*/
# ============================================================


# ============================================================
# /*=== BADGE DRAWING START ===*/
# ============================================================

static func draw_badge(
	canvas: CanvasItem,
	font: Font,
	rect: Rect2,
	text: String,
	fill: Color = ACCENT_BLUE
) -> void:
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, BORDER, false, 1.0)

	var text_pos: Vector2 = rect.position + Vector2(8, rect.size.y - 8)
	canvas.draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, TEXT_DARK)

# ============================================================
# /*=== BADGE DRAWING END ===*/
# ============================================================
