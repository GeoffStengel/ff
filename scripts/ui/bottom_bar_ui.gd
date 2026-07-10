extends RefCounted

# ============================================================
# BottomBarUI
# ------------------------------------------------------------
# Owns the bottom action/status bar layout, sizing, label
# placement, message toast geometry, and decorative drawing.
#
# Does NOT:
# - Change gameplay state
# - Read input
# - Play sounds
# - Call main.gd message or UI refresh helpers
# ============================================================

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UILayout := preload("res://scripts/ui/layout.gd")
const UITheme := preload("res://scripts/ui/theme.gd")


# ============================================================
# /*=== BOTTOM BAR LAYOUT START ===*/
# ============================================================

static func build_layout(
	viewport_size: Vector2,
	board_rect: Rect2,
	screen_pad: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Dictionary:
	var bar: Rect2 = bottom_status_rect(
		viewport_size,
		board_rect,
		screen_pad,
		bottom_bar_height,
		gap,
		mobile
	)
	var action_card: Rect2 = bottom_card_rect(0, gap, bar)
	var plot_card: Rect2 = bottom_card_rect(1, gap, bar)
	var message: Rect2 = message_rect(bar)

	return {
		"bar": bar,
		"action_card": action_card,
		"plot_card": plot_card,
		"message": message,
		"action_label": label_rect(action_card),
		"plot_label": label_rect(plot_card)
	}


static func bottom_status_rect(
	viewport_size: Vector2,
	board: Rect2,
	screen_pad: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Rect2:
	if mobile:
		var x: float = float(screen_pad)
		var y: float = viewport_size.y - float(bottom_bar_height + screen_pad)
		var w: float = maxf(1.0, viewport_size.x - float(screen_pad * 2))
		var h: float = float(bottom_bar_height)
		return Rect2(Vector2(x, y), Vector2(w, h))

	var desktop_x: float = board.position.x + 10.0
	var desktop_y: float = board.end.y + float(gap)
	var desktop_w: float = maxf(1.0, board.size.x - 20.0)
	return Rect2(Vector2(desktop_x, desktop_y), Vector2(desktop_w, float(bottom_bar_height)))


static func bottom_card_rect(index: int, gap: int, bottom: Rect2) -> Rect2:
	var safe_index: int = clampi(index, 0, 1)
	var outer_pad: float = 10.0
	var card_gap: float = float(gap)
	var card_w: float = maxf(1.0, (bottom.size.x - card_gap - outer_pad * 2.0) * 0.5)
	var card_h: float = maxf(1.0, bottom.size.y - outer_pad * 2.0)
	var x: float = bottom.position.x + outer_pad + float(safe_index) * (card_w + card_gap)
	var y: float = bottom.position.y + outer_pad
	return Rect2(Vector2(x, y), Vector2(card_w, card_h))


static func label_rect(card: Rect2) -> Rect2:
	return Rect2(card.position + Vector2(8, 8), card.size - Vector2(16, 14))


static func message_rect(bottom: Rect2) -> Rect2:
	return Rect2(
		Vector2(bottom.position.x + 16.0, bottom.position.y - 40.0),
		Vector2(maxf(1.0, bottom.size.x - 32.0), 28.0)
	)

# ============================================================
# /*=== BOTTOM BAR LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== BOTTOM BAR CONTROL APPLICATION START ===*/
# ------------------------------------------------------------
# Expected controls Dictionary keys:
# - "action_label": Label for the current action card
# - "plot_label": Label for the selected plot card
# - "message_label": Label for transient messages
#
# These labels are direct CanvasLayer children, so this helper may
# position them. For future container-managed controls, keep using
# custom_minimum_size only.
# ============================================================

static func apply_layout(controls: Dictionary, layout: Dictionary) -> void:
	var action_label: Label = controls.get("action_label", null) as Label
	if action_label != null:
		var action_rect: Rect2 = layout.get("action_label", Rect2())
		action_label.position = action_rect.position
		action_label.custom_minimum_size = action_rect.size

	var plot_label: Label = controls.get("plot_label", null) as Label
	if plot_label != null:
		var plot_rect: Rect2 = layout.get("plot_label", Rect2())
		plot_label.position = plot_rect.position
		plot_label.custom_minimum_size = plot_rect.size

	var message_label: Label = controls.get("message_label", null) as Label
	if message_label != null:
		var message: Rect2 = layout.get("message", Rect2())
		message_label.position = message.position
		message_label.custom_minimum_size = message.size

# ============================================================
# /*=== BOTTOM BAR CONTROL APPLICATION END ===*/
# ============================================================


# ============================================================
# /*=== BOTTOM BAR DRAWING START ===*/
# ============================================================

static func draw_bottom_bar(canvas: CanvasItem, layout: Dictionary) -> void:
	var bar: Rect2 = layout.get("bar", Rect2())
	var action_card: Rect2 = layout.get("action_card", Rect2())
	var plot_card: Rect2 = layout.get("plot_card", Rect2())

	canvas.draw_style_box(
		rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 14),
		Rect2(bar.position + Vector2(3, 4), bar.size)
	)
	draw_rounded_box(canvas, bar, Color("#d7bd78"), Color("#6a4d2e"), 14, 1)
	draw_rounded_box(canvas, bar.grow(-7), Color("#fff9e9"), Color("#e8d29d"), 10, 1)
	draw_rounded_box(canvas, action_card, Color("#fffdf2"), Color("#d8c78e"), 8, 1)
	draw_rounded_box(canvas, plot_card, Color("#fffdf2"), Color("#d8c78e"), 8, 1)


static func draw_message_toast(canvas: CanvasItem, layout: Dictionary) -> void:
	var label_rect: Rect2 = layout.get("message", Rect2())
	var toast_rect: Rect2 = Rect2(label_rect.position - Vector2(8, 6), label_rect.size + Vector2(16, 12))

	canvas.draw_style_box(
		rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 10),
		Rect2(toast_rect.position + Vector2(2, 3), toast_rect.size)
	)
	draw_rounded_box(canvas, toast_rect, Color("#d7bd78"), Color("#6a4d2e"), 10, 1)
	draw_rounded_box(canvas, toast_rect.grow(-7), Color("#fff9e9"), Color("#e8d29d"), 6, 1)


static func rounded_box(fill: Color, border: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
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


static func draw_rounded_box(
	canvas: CanvasItem,
	rect: Rect2,
	fill: Color,
	border: Color,
	radius: int,
	border_width: int = 1
) -> void:
	canvas.draw_style_box(rounded_box(fill, border, radius, border_width), rect)

# ============================================================
# /*=== BOTTOM BAR DRAWING END ===*/
# ============================================================
