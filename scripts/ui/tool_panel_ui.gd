extends RefCounted

# ============================================================
# ToolPanelUI
# ------------------------------------------------------------
# Owns the left dock/tool/menu panel layout, sizing, spacing,
# responsive geometry, and decorative drawing.
#
# Does NOT:
# - Create gameplay buttons
# - Change selected tool or side-tab state
# - Handle input
# - Play sounds or show messages
# - Mutate gameplay state
# ============================================================

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UILayout := preload("res://scripts/ui/layout.gd")
const UITheme := preload("res://scripts/ui/theme.gd")


# ============================================================
# /*=== TOOL PANEL CONSTANTS START ===*/
# ============================================================

const TOOL_BUTTON_SIZE := 46.0
const ROW_GAP := 6
const POCKET_PAD := 10.0
const COLUMN_INSET := Vector2(15, 20)
const SECTION_LABEL_INSET := Vector2(10, 4)
const SECTION_LABEL_H := 14.0

# ============================================================
# /*=== TOOL PANEL CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== TOOL PANEL LAYOUT START ===*/
# ============================================================

static func build_layout(
	viewport_size: Vector2,
	screen_pad: int,
	hud_height: int,
	left_dock_width: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Dictionary:
	var dock: Rect2 = left_dock_rect(
		viewport_size,
		screen_pad,
		hud_height,
		left_dock_width,
		bottom_bar_height,
		gap,
		mobile
	)
	var tool_pocket: Rect2 = tool_pocket_rect(dock)
	var menu_pocket: Rect2 = menu_pocket_rect(dock)

	return {
		"dock": dock,
		"tool_pocket": tool_pocket,
		"menu_pocket": menu_pocket,
		"tool_column_pos": tool_column_pos(tool_pocket),
		"menu_column_pos": menu_column_pos(menu_pocket),
		"tool_section_label": section_label_rect(tool_pocket),
		"menu_section_label": section_label_rect(menu_pocket),
		"row_gap": ROW_GAP,
		"button_size": Vector2(TOOL_BUTTON_SIZE, TOOL_BUTTON_SIZE)
	}


static func left_dock_rect(
	viewport_size: Vector2,
	screen_pad: int,
	hud_height: int,
	left_dock_width: int,
	bottom_bar_height: int,
	gap: int,
	mobile: bool
) -> Rect2:
	var x: float = float(screen_pad)
	var y: float = float(hud_height + gap)
	var w: float = float(left_dock_width)

	if mobile:
		var h: float = viewport_size.y - float(hud_height + bottom_bar_height + screen_pad + gap * 2)
		return Rect2(Vector2(x, y), Vector2(w, maxf(240.0, h)))

	return Rect2(Vector2(x, y), Vector2(w, 548.0))


static func tool_pocket_rect(dock: Rect2) -> Rect2:
	var x: float = dock.position.x + POCKET_PAD
	var y: float = dock.position.y + 18.0
	var w: float = maxf(1.0, dock.size.x - POCKET_PAD * 2.0)
	var h: float = 224.0
	return Rect2(Vector2(x, y), Vector2(w, h))


static func menu_pocket_rect(dock: Rect2) -> Rect2:
	var x: float = dock.position.x + POCKET_PAD
	var y: float = dock.position.y + 262.0
	var w: float = maxf(1.0, dock.size.x - POCKET_PAD * 2.0)
	var h: float = maxf(1.0, dock.size.y - 274.0)
	return Rect2(Vector2(x, y), Vector2(w, h))


static func tool_column_pos(tool_pocket: Rect2) -> Vector2:
	return tool_pocket.position + COLUMN_INSET


static func menu_column_pos(menu_pocket: Rect2) -> Vector2:
	return menu_pocket.position + COLUMN_INSET


static func section_label_rect(pocket: Rect2) -> Rect2:
	return Rect2(
		pocket.position + SECTION_LABEL_INSET,
		Vector2(maxf(1.0, pocket.size.x - SECTION_LABEL_INSET.x * 2.0), SECTION_LABEL_H)
	)


static func button_minimum_size() -> Vector2:
	return Vector2(TOOL_BUTTON_SIZE, TOOL_BUTTON_SIZE)


static func row_separation() -> int:
	return ROW_GAP

# ============================================================
# /*=== TOOL PANEL LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== TOOL PANEL CONTROL APPLICATION START ===*/
# ------------------------------------------------------------
# Expected controls Dictionary keys:
# - "tool_row": VBoxContainer for tool buttons
# - "menu_row": VBoxContainer for menu buttons
# - "tool_section_label": Label for the tools heading
# - "menu_section_label": Label for the menus heading
#
# Rows and labels are direct CanvasLayer children, so this helper
# may position them. Button children stay container-managed.
# ============================================================

static func apply_layout(controls: Dictionary, layout: Dictionary) -> void:
	var tool_row: VBoxContainer = controls.get("tool_row", null) as VBoxContainer
	if tool_row != null:
		tool_row.position = layout.get("tool_column_pos", Vector2.ZERO)
		tool_row.add_theme_constant_override("separation", int(layout.get("row_gap", ROW_GAP)))

	var menu_row: VBoxContainer = controls.get("menu_row", null) as VBoxContainer
	if menu_row != null:
		menu_row.position = layout.get("menu_column_pos", Vector2.ZERO)
		menu_row.add_theme_constant_override("separation", int(layout.get("row_gap", ROW_GAP)))

	var tool_label: Label = controls.get("tool_section_label", null) as Label
	if tool_label != null:
		var tool_label_rect: Rect2 = layout.get("tool_section_label", Rect2())
		tool_label.position = tool_label_rect.position
		tool_label.custom_minimum_size = tool_label_rect.size

	var menu_label: Label = controls.get("menu_section_label", null) as Label
	if menu_label != null:
		var menu_label_rect: Rect2 = layout.get("menu_section_label", Rect2())
		menu_label.position = menu_label_rect.position
		menu_label.custom_minimum_size = menu_label_rect.size

# ============================================================
# /*=== TOOL PANEL CONTROL APPLICATION END ===*/
# ============================================================


# ============================================================
# /*=== TOOL PANEL DRAWING START ===*/
# ============================================================

static func draw_panel(canvas: CanvasItem, layout: Dictionary, bg_cream: String) -> void:
	var dock: Rect2 = layout.get("dock", Rect2())
	var tool_pocket: Rect2 = layout.get("tool_pocket", Rect2())
	var menu_pocket: Rect2 = layout.get("menu_pocket", Rect2())

	canvas.draw_style_box(
		rounded_box(Color(0.13, 0.08, 0.04, 0.20), Color(0.13, 0.08, 0.04, 0.0), 16),
		Rect2(dock.position + Vector2(3, 5), dock.size)
	)
	draw_rounded_box(canvas, dock, Color("#7a5a35"), Color("#5b4228"), 16, 2)
	draw_rounded_box(canvas, dock.grow(-5), Color("#f0ddb5"), Color("#c9a96a"), 12, 1)
	draw_rounded_box(canvas, tool_pocket, Color(bg_cream), Color("#ead6aa"), 9, 1)
	draw_rounded_box(canvas, menu_pocket, Color(bg_cream), Color("#ead6aa"), 9, 1)
	canvas.draw_line(
		tool_pocket.position + Vector2(10, 10),
		tool_pocket.position + Vector2(tool_pocket.size.x - 10, 10),
		Color(0.50, 0.36, 0.18, 0.20),
		1.0
	)
	canvas.draw_line(
		menu_pocket.position + Vector2(10, 10),
		menu_pocket.position + Vector2(menu_pocket.size.x - 10, 10),
		Color(0.50, 0.36, 0.18, 0.20),
		1.0
	)


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
# /*=== TOOL PANEL DRAWING END ===*/
# ============================================================
