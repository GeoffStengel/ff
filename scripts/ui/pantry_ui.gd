extends RefCounted

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
# - Pantry card backplates
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

const CONTENT_W := 376.0
const PANEL_GAP := 3
const ACTION_GAP := 8
const STAT_CARD_GAP := 6

const PANEL_SIDE_PAD := 10.0
const PANEL_TOP_PAD := 4.0

const TITLE_H := 32.0
const STAT_CARD_H := 34.0
const HARVEST_GRID_H := 74.0
const PRESERVE_STATS_H := 36.0
const PRESERVE_RECIPE_H := 18.0
const ACTION_ROW_H := 36.0
const RECIPE_BUTTON_H := 32.0
const PLANTING_GRID_H := 74.0
const TOTAL_ROW_H := 16.0
const TREES_LABEL_H := 18.0
const HINT_LABEL_H := 42.0

const INVENTORY_ICON_SIZE := Vector2(20.0, 20.0)
const PRESERVE_ICON_SIZE := Vector2(24.0, 24.0)
const QUANTITY_SIZE := Vector2(22.0, 22.0)

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


static func title_minimum_size() -> Vector2:
	return Vector2(0.0, TITLE_H)


static func harvest_grid_minimum_size() -> Vector2:
	return Vector2(0.0, HARVEST_GRID_H)


static func planting_grid_minimum_size() -> Vector2:
	return Vector2(0.0, PLANTING_GRID_H)


static func stat_card_minimum_size() -> Vector2:
	return Vector2(
		0.0,
		STAT_CARD_H
	)


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

# ============================================================
# /*=== PANTRY SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY DISPLAY COPY START ===*/
# ============================================================

static func preserve_recipe_text() -> String:
	return "Current recipe: 5 figs + 1 jar → 1 jam"


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

	if panel != null:
		var available_width: float = maxf(
			1.0,
			content.size.x - PANEL_SIDE_PAD * 2.0
		)

		var panel_width: float = minf(
			CONTENT_W,
			available_width
		)

		var panel_size: Vector2 = Vector2(
			panel_width,
			maxf(
				1.0,
				content.size.y - PANEL_TOP_PAD
			)
		)

		panel.position = content.position + Vector2(
			PANEL_SIDE_PAD,
			PANEL_TOP_PAD
		)

		panel.custom_minimum_size = panel_size
		panel.size = panel_size
		panel.size_flags_horizontal = Control.SIZE_FILL

		panel.add_theme_constant_override(
			"separation",
			PANEL_GAP
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
	var card_w: float = minf(
		CONTENT_W,
		content.size.x - PANEL_SIDE_PAD * 2.0
	)

	var card_origin: Vector2 = content.position + Vector2(
		PANEL_SIDE_PAD,
		PANEL_TOP_PAD
	)

	return [
		Rect2(
			card_origin + Vector2(0.0, 44.0),
			Vector2(card_w, 112.0)
		),
		Rect2(
			card_origin + Vector2(0.0, 176.0),
			Vector2(card_w, 158.0)
		),
		Rect2(
			card_origin + Vector2(0.0, 354.0),
			Vector2(card_w, 126.0)
		),
		Rect2(
			card_origin + Vector2(0.0, 500.0),
			Vector2(card_w, 60.0)
		)
	]


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

# ============================================================
# /*=== PANTRY LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY UI FILE END ===*/
# ============================================================
