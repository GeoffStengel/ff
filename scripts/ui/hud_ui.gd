extends RefCounted

# ============================================================
# HUDUI
# ------------------------------------------------------------
# Owns the top HUD layout, sizing, text formatting, and
# decorative drawing.
#
# Does NOT:
# - Change gameplay state
# - Read input
# - Play sounds
# - Call main.gd UI refresh or message helpers
# ============================================================

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UILayout := preload("res://scripts/ui/layout.gd")
const UITheme := preload("res://scripts/ui/theme.gd")


# ============================================================
# /*=== HUD LAYOUT START ===*/
# ============================================================

static func build_layout(
	viewport_size: Vector2,
	screen_pad: int,
	hud_height: int
) -> Dictionary:
	var rect: Rect2 = Rect2(
		Vector2(float(screen_pad), 14.0),
		Vector2(maxf(1.0, viewport_size.x - float(screen_pad * 2)), maxf(1.0, float(hud_height - 8)))
	)

	return {
		"rect": rect,
		"row_one_pos": rect.position + Vector2(10, 5),
		"row_two_pos": rect.position + Vector2(10, 29),
		"row_one_height": 24.0,
		"row_two_height": 20.0,
		"row_one_gap": 8,
		"row_two_gap": 12
	}


static func label_width(key: String) -> float:
	match key:
		"Day":
			return 76.0
		"Weather":
			return 700.0
		"Coins":
			return 72.0
		"Water":
			return 78.0
		"Cuts":
			return 78.0
		"Figs":
			return 72.0
		"Compost":
			return 94.0
		"Rep":
			return 82.0
		"Guide":
			return 100.0
		_:
			return 70.0


static func label_minimum_size(key: String, row: int) -> Vector2:
	var height: float = 20.0
	if row == 1:
		height = 24.0
	return Vector2(label_width(key), height)

# ============================================================
# /*=== HUD LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== HUD CONTROL APPLICATION START ===*/
# ------------------------------------------------------------
# Expected controls Dictionary keys:
# - "top_bar": HBoxContainer
# - "hud_second_row": HBoxContainer
# - "hud_labels": Dictionary[String, Label]
# - "hud_fig_icon": TextureRect
#
# top_bar and hud_second_row are direct CanvasLayer children, so
# this helper may position them. Their children are container
# managed, so this helper only changes custom_minimum_size there.
# ============================================================

static func apply_layout(controls: Dictionary, layout: Dictionary) -> void:
	var top_bar: HBoxContainer = controls.get("top_bar", null) as HBoxContainer
	if top_bar != null:
		top_bar.position = layout.get("row_one_pos", Vector2.ZERO)
		top_bar.add_theme_constant_override("separation", int(layout.get("row_one_gap", 8)))

	var hud_second_row: HBoxContainer = controls.get("hud_second_row", null) as HBoxContainer
	if hud_second_row != null:
		hud_second_row.position = layout.get("row_two_pos", Vector2.ZERO)
		hud_second_row.add_theme_constant_override("separation", int(layout.get("row_two_gap", 12)))

	var labels: Dictionary = controls.get("hud_labels", {})
	for key in labels.keys():
		var label: Label = labels.get(key, null) as Label
		if label == null:
			continue
		var row: int = 2
		if not (key in ["Weather", "Guide"]):
			row = 1
		label.custom_minimum_size = label_minimum_size(String(key), row)

	var fig_icon: TextureRect = controls.get("hud_fig_icon", null) as TextureRect
	if fig_icon != null:
		fig_icon.custom_minimum_size = Vector2(20, 20)

# ============================================================
# /*=== HUD CONTROL APPLICATION END ===*/
# ============================================================


# ============================================================
# /*=== HUD TEXT FORMATTERS START ===*/
# ============================================================

static func format_day(day: int) -> String:
	return "📅 Day %s" % day


static func format_coins(coins: int) -> String:
	return "🪙 $%s" % coins


static func format_water(current: int, maximum: int) -> String:
	return "💧 %s/%s" % [current, maximum]


static func format_cuttings(total_cuttings: int) -> String:
	return "🌱 Cuts %s" % total_cuttings


static func format_figs(total_figs: int) -> String:
	return "Figs %s" % total_figs


static func format_compost(compost: int) -> String:
	return "🟤 Comp %s" % compost


static func format_reputation(reputation: int) -> String:
	return "♥ Trust %s" % reputation


static func format_guide(tutorial_text: String) -> String:
	return "📖 " + tutorial_text

# ============================================================
# /*=== HUD TEXT FORMATTERS END ===*/
# ============================================================



# ============================================================
# /*=== HUD DECORATIVE DRAWING START ===*/
# ============================================================

static func draw_top_hud_bar(canvas: CanvasItem, layout: Dictionary) -> void:
	var rect: Rect2 = layout.get("rect", Rect2())
	canvas.draw_style_box(
		rounded_box(Color(0.13, 0.08, 0.04, 0.18), Color(0.13, 0.08, 0.04, 0.0), 12),
		Rect2(rect.position + Vector2(2, 3), rect.size)
	)
	draw_rounded_box(canvas, rect, Color("#7a5229"), Color("#5b3a1d"), 12, 1)
	draw_rounded_box(canvas, rect.grow(-3), Color("#a9793a"), Color("#8b612e"), 9, 1)
	draw_rounded_box(canvas, rect.grow(-7), Color("#f4dfb4"), Color("#d4b16d"), 6, 1)


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
# /*=== HUD DECORATIVE DRAWING END ===*/
# ============================================================
