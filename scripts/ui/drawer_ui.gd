extends RefCounted

# ============================================================
# DrawerUI
# ------------------------------------------------------------
# Owns the shared right-side drawer shell geometry, layout,
# visibility helpers, and decorative drawing.
#
# Does NOT:
# - Change active tab state
# - Know what any tab means
# - Draw feature-specific cards
# - Update feature text
# - Mutate gameplay state
# ============================================================

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UILayout := preload("res://scripts/ui/layout.gd")
const UITheme := preload("res://scripts/ui/theme.gd")


# ============================================================
# /*=== SHARED DRAWER CONTENT CONSTANTS START ===*/
# ============================================================

const SECTION_CONTENT_W := 376.0
const SECTION_SPACER_H := 6.0
const SECTION_LABEL_H := 13.0

# ============================================================
# /*=== SHARED DRAWER CONTENT CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== DRAWER LAYOUT START ===*/
# ============================================================

static func build_layout(
	viewport_size: Vector2,
	screen_pad: int,
	hud_height: int,
	drawer_width: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Dictionary:
	var drawer: Rect2 = drawer_rect(
		viewport_size,
		screen_pad,
		hud_height,
		drawer_width,
		bottom_bar_height,
		gap,
		mobile
	)
	var content: Rect2 = drawer_content_rect(drawer)
	var hint: Rect2 = drawer_hint_rect(drawer)

	return {
		"drawer": drawer,
		"content": content,
		"hint": hint,
		"content_position": content.position,
		"content_size": content.size
	}


static func drawer_rect(
	viewport_size: Vector2,
	screen_pad: int,
	hud_height: int,
	drawer_width: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Rect2:
	var y: float = float(hud_height + gap)

	if mobile:
		var x: float = float(screen_pad)
		var w: float = maxf(1.0, viewport_size.x - float(screen_pad * 2))
		var h: float = viewport_size.y - float(hud_height + bottom_bar_height + screen_pad + gap * 2)
		return Rect2(Vector2(x, y), Vector2(w, maxf(1.0, h)))

	var x: float = viewport_size.x - float(screen_pad + drawer_width)
	var w: float = float(drawer_width)
	var h: float = viewport_size.y - float(hud_height + screen_pad + gap)
	return Rect2(Vector2(x, y), Vector2(w, maxf(1.0, h)))


static func drawer_hint_rect(drawer: Rect2) -> Rect2:
	return Rect2(
		drawer.position + Vector2(20, 18),
		Vector2(maxf(1.0, drawer.size.x - 40.0), 18.0)
	)


static func drawer_content_rect(drawer: Rect2) -> Rect2:
	return Rect2(
		drawer.position + Vector2(14, 42),
		drawer.size - Vector2(28, 56)
	)


static func section_spacer_minimum_size() -> Vector2:
	return Vector2(SECTION_CONTENT_W, SECTION_SPACER_H)


static func section_label_minimum_size() -> Vector2:
	return Vector2(SECTION_CONTENT_W, SECTION_LABEL_H)

# ============================================================
# /*=== DRAWER LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== DRAWER CONTROL APPLICATION START ===*/
# ------------------------------------------------------------
# Expected controls Dictionary keys:
# - "hint_label": Label shown above drawer content
# - "panels": Array of feature panels sized to the drawer content
#
# The current architecture keeps these as direct CanvasLayer
# children, so this helper may position them and set minimum size.
# ============================================================

static func apply_layout(controls: Dictionary, layout: Dictionary) -> void:
	var hint_label: Label = controls.get("hint_label", null) as Label
	if hint_label != null:
		var hint: Rect2 = layout.get("hint", Rect2())
		hint_label.position = hint.position
		hint_label.custom_minimum_size = hint.size

	var panels: Array = controls.get("panels", [])
	var content: Rect2 = layout.get("content", Rect2())
	for panel_value in panels:
		var panel: Control = panel_value as Control
		if panel == null:
			continue
		panel.position = content.position
		panel.custom_minimum_size = content.size


static func apply_active_panel(panels: Array, active_index: int, panel_open: bool) -> void:
	for i in panels.size():
		var panel: Control = panels[i] as Control
		if panel == null:
			continue
		panel.visible = panel_open and i == active_index

# ============================================================
# /*=== DRAWER CONTROL APPLICATION END ===*/
# ============================================================


# ============================================================
# /*=== DRAWER DRAWING START ===*/
# ============================================================

static func draw_drawer_shell(canvas: CanvasItem, layout: Dictionary) -> void:
	var drawer: Rect2 = layout.get("drawer", Rect2())
	canvas.draw_style_box(
		rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 16),
		Rect2(drawer.position + Vector2(3, 4), drawer.size)
	)
	draw_rounded_box(canvas, drawer, Color("#7a5a35"), Color("#5b4228"), 16, 2)
	draw_rounded_box(canvas, drawer.grow(-4), Color("#f0ddb5"), Color("#c9a96a"), 13, 1)
	draw_rounded_box(canvas, drawer.grow(-14), Color("#fff8e8"), Color("#ead6aa"), 10, 1)


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
# /*=== DRAWER DRAWING END ===*/
# ============================================================
