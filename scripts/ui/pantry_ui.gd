extends RefCounted

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UITheme := preload("res://scripts/ui/theme.gd")
const SectionHeaderUI := preload("res://scripts/ui/section_header_ui.gd")

# ============================================================
# PantryUI
# ------------------------------------------------------------
# Purpose:
# Own Farm Pantry layout, sizing, card geometry, spacing, and
# static Pantry display copy.
#
# Responsibilities:
# - Pantry section sizing
# - Pantry action sizing
# - Pantry icon and quantity sizing
# - Pantry card/backplate styling
# - Static Pantry helper copy
#
# Does NOT:
# - Add or remove figs, jars, jam, or cuttings
# - Buy, make, sell, or deliver pantry items
# - Play sounds or show messages
# - Handle input or callbacks
# - Own Village Requests
# ============================================================


# ============================================================
# /*=== PANTRY CONSTANTS START ===*/
# ============================================================

const CONTENT_W := UIConstants.READABLE_PAGE_WIDTH
const NARROW_BREAKPOINT := 390.0
const PANEL_GAP := UIConstants.SECTION_GAP
const ACTION_GAP := UIConstants.CARD_GAP
const STAT_CARD_GAP := UIConstants.CARD_GAP

const PANEL_SIDE_PAD := 0.0
const PANEL_TOP_PAD := 0.0

const TITLE_H := 34.0
const SECTION_HEADER_H := 16.0
const STAT_CARD_H := 42.0
const PRESERVE_STATS_H := 42.0
const PRESERVE_RECIPE_H := 22.0
const ACTION_ROW_H := UIConstants.BUTTON_HEIGHT
const RECIPE_BUTTON_H := UIConstants.BUTTON_HEIGHT_SMALL
const TOTAL_ROW_H := 20.0
const TREES_LABEL_H := 22.0
const HINT_LABEL_H := 54.0

const INVENTORY_ICON_SIZE := Vector2(22.0, 22.0)
const PRESERVE_ICON_SIZE := Vector2(24.0, 24.0)
const QUANTITY_SIZE := Vector2(34.0, 24.0)
const SECTION_MARGIN := 10
const GRID_ITEM_COUNT := 4

# ============================================================
# /*=== PANTRY CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY SIZE HELPERS START ===*/
# ============================================================

static func panel_separation() -> int:
	return PANEL_GAP


static func action_gap() -> int:
	return ACTION_GAP


static func stat_card_gap() -> int:
	return STAT_CARD_GAP


static func section_margin() -> int:
	return SECTION_MARGIN


static func title_minimum_size() -> Vector2:
	return Vector2(0.0, TITLE_H)


static func section_header_minimum_size() -> Vector2:
	return Vector2(0.0, SECTION_HEADER_H)


static func harvest_grid_minimum_size() -> Vector2:
	return grid_minimum_size_for_width(CONTENT_W, GRID_ITEM_COUNT)


static func planting_grid_minimum_size() -> Vector2:
	return grid_minimum_size_for_width(CONTENT_W, GRID_ITEM_COUNT)


static func stat_card_minimum_size() -> Vector2:
	return Vector2(0.0, STAT_CARD_H)


static func inventory_icon_minimum_size() -> Vector2:
	return INVENTORY_ICON_SIZE


static func preserve_icon_minimum_size() -> Vector2:
	return PRESERVE_ICON_SIZE


static func quantity_minimum_size() -> Vector2:
	return QUANTITY_SIZE


static func total_row_minimum_size() -> Vector2:
	return Vector2(0.0, TOTAL_ROW_H)


static func preserve_stats_row_minimum_size() -> Vector2:
	return Vector2(0.0, PRESERVE_STATS_H)


static func preserve_recipe_minimum_size() -> Vector2:
	return Vector2(0.0, PRESERVE_RECIPE_H)


static func action_row_minimum_size() -> Vector2:
	return Vector2(0.0, ACTION_ROW_H)


static func primary_button_minimum_size() -> Vector2:
	return Vector2(0.0, ACTION_ROW_H)


static func recipe_button_minimum_size() -> Vector2:
	return Vector2(0.0, RECIPE_BUTTON_H)


static func trees_label_minimum_size() -> Vector2:
	return Vector2(0.0, TREES_LABEL_H)


static func hint_label_minimum_size() -> Vector2:
	return Vector2(0.0, HINT_LABEL_H)


static func content_width(content: Rect2) -> float:
	var available_width: float = maxf(
		1.0,
		content.size.x - PANEL_SIDE_PAD * 2.0
	)

	return minf(
		CONTENT_W,
		available_width
	)


static func grid_columns_for_width(width: float) -> int:
	if width < NARROW_BREAKPOINT:
		return 1

	return 2


static func grid_minimum_size_for_width(width: float, item_count: int) -> Vector2:
	var columns: int = grid_columns_for_width(width)
	var rows: int = int(ceil(float(item_count) / float(columns)))
	var height: float = float(rows) * STAT_CARD_H

	if rows > 1:
		height += float(rows - 1) * STAT_CARD_GAP

	return Vector2(0.0, height)

# ============================================================
# /*=== PANTRY SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY STYLE HELPERS START ===*/
# ============================================================

static func page_style_box() -> StyleBoxFlat:
	return UITheme.page_card_style()


static func section_style_box() -> StyleBoxFlat:
	return UITheme.section_card_style()


static func quiet_section_style_box() -> StyleBoxFlat:
	return UITheme.quiet_card_style()


static func item_card_style_box() -> StyleBoxFlat:
	return UITheme.quiet_card_style()



static func jars_card_style_box() -> StyleBoxFlat:
	var style: StyleBoxFlat = UITheme.rounded_style(
		Color("#a8bd63"),
		Color("#6f8738"),
		10,
		1
	)

	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0

	return style


static func jam_card_style_box() -> StyleBoxFlat:
	var style: StyleBoxFlat = UITheme.rounded_style(
		Color("#a65bad"),
		Color("#713576"),
		10,
		1
	)

	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0

	return style


static func harvest_quantity_style_box() -> StyleBoxFlat:
	var style: StyleBoxFlat = UITheme.rounded_style(
		Color("#b8c978"),
		Color("#8fa04f"),
		8,
		1
	)

	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0

	return style


static func quantity_style_box() -> StyleBoxFlat:
	return UITheme.quantity_badge_style()

# ============================================================
# /*=== PANTRY STYLE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY SECTION HEADER START ===*/
# ============================================================

static func create_section_header(
	node_prefix: String,
	title: String,
	icon: Texture2D
) -> HBoxContainer:
	return SectionHeaderUI.create(node_prefix, title, icon)

# ============================================================
# /*=== PANTRY SECTION HEADER END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY DISPLAY COPY START ===*/
# ============================================================

static func preserve_recipe_text() -> String:
	return "Recipe: 5 figs + 1 jar -> 1 jam"


static func about_jam_text() -> String:
	return (
		"Different figs make different flavors.\n"
		+ "Craft preserves here. Deliver jam through Village Requests."
	)

# ============================================================
# /*=== PANTRY DISPLAY COPY END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY LAYOUT START ===*/
# ============================================================

static func apply_layout(
	controls: Dictionary,
	content: Rect2
) -> void:
	var panel: VBoxContainer = controls.get(
		"panel",
		null
	) as VBoxContainer
	var scroll: ScrollContainer = controls.get(
		"scroll",
		null
	) as ScrollContainer
	var container_mode: bool = bool(controls.get("container_mode", false))

	var panel_width: float = content_width(content)
	var panel_offset: Vector2 = Vector2(
		maxf(PANEL_SIDE_PAD, (content.size.x - panel_width) * 0.5),
		PANEL_TOP_PAD
	)

	if scroll != null and not container_mode:
		scroll.position = content.position
		scroll.custom_minimum_size = content.size
		scroll.size = content.size
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if panel != null:
		var panel_size: Vector2 = Vector2(
			panel_width,
			1.0 if container_mode else maxf(
				1.0,
				content.size.y - PANEL_TOP_PAD
			)
		)

		if container_mode:
			panel.position = Vector2.ZERO
		elif scroll != null:
			panel.position = panel_offset
		else:
			panel.position = content.position + panel_offset

		panel.custom_minimum_size = panel_size
		if not container_mode:
			panel.size = panel_size
		panel.clip_contents = true
		panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		panel.add_theme_constant_override(
			"separation",
			PANEL_GAP
		)

	var grid_columns: int = grid_columns_for_width(panel_width)

	_set_grid_layout(
		controls,
		"harvest_grid",
		grid_columns,
		grid_minimum_size_for_width(panel_width, GRID_ITEM_COUNT)
	)

	_set_grid_layout(
		controls,
		"planting_grid",
		grid_columns,
		grid_minimum_size_for_width(panel_width, GRID_ITEM_COUNT)
	)

	_set_minimum_size(
		controls,
		"preserve_stats_row",
		preserve_stats_row_minimum_size()
	)

	_set_minimum_size(
		controls,
		"preserve_actions",
		action_row_minimum_size()
	)

	_set_minimum_size(
		controls,
		"preserve_label",
		preserve_recipe_minimum_size()
	)

	_set_minimum_size(
		controls,
		"make_jam_button",
		primary_button_minimum_size()
	)

	_set_minimum_size(
		controls,
		"buy_jars_button",
		primary_button_minimum_size()
	)

	_set_minimum_size(
		controls,
		"recipe_button",
		recipe_button_minimum_size()
	)

	_set_minimum_size(
		controls,
		"trees_label",
		trees_label_minimum_size()
	)

	_set_minimum_size(
		controls,
		"hint_label",
		hint_label_minimum_size()
	)


static func card_backplates(content: Rect2) -> Array[Rect2]:
	return []


static func _set_minimum_size(
	controls: Dictionary,
	key: String,
	size: Vector2
) -> void:
	var control: Control = controls.get(
		key,
		null
	) as Control

	if control != null:
		control.custom_minimum_size = size


static func _set_grid_layout(
	controls: Dictionary,
	key: String,
	columns: int,
	size: Vector2
) -> void:
	var grid: GridContainer = controls.get(
		key,
		null
	) as GridContainer

	if grid != null:
		grid.columns = columns
		grid.custom_minimum_size = size

# ============================================================
# /*=== PANTRY LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY UI FILE END ===*/
# ============================================================
