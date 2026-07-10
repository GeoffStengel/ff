extends RefCounted

# ============================================================
# PantryUI
# ------------------------------------------------------------
# Owns Pantry drawer layout, sizing, card geometry, spacing,
# and pure pantry display copy.
#
# Does NOT:
# - Add or remove figs, jars, jam, or cuttings
# - Buy, make, or sell pantry items
# - Play sounds or show messages
# - Handle input or callbacks
# ============================================================


# ============================================================
# /*=== PANTRY CONSTANTS START ===*/
# ============================================================

const CONTENT_W := 376.0
const PANEL_GAP := 6
const FIGS_LABEL_H := 74.0
const CUTTINGS_LABEL_H := 58.0
const PRESERVES_LABEL_H := 48.0
const PRESERVE_RECIPE_H := 26.0
const PRESERVE_BUTTON_SIZE := Vector2(88, 32)
const TREES_LABEL_H := 54.0
const HINT_LABEL_H := 38.0

# ============================================================
# /*=== PANTRY CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY SIZE HELPERS START ===*/
# ============================================================

static func panel_separation() -> int:
	return PANEL_GAP


static func figs_label_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, FIGS_LABEL_H)


static func cuttings_label_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, CUTTINGS_LABEL_H)


static func preserves_label_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, PRESERVES_LABEL_H)


static func preserve_recipe_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, PRESERVE_RECIPE_H)


static func preserve_button_minimum_size() -> Vector2:
	return PRESERVE_BUTTON_SIZE


static func trees_label_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, TREES_LABEL_H)


static func hint_label_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, HINT_LABEL_H)

# ============================================================
# /*=== PANTRY SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== PANTRY LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: VBoxContainer = controls.get("panel", null) as VBoxContainer
	if panel != null:
		panel.position = content.position
		panel.custom_minimum_size = content.size
		panel.add_theme_constant_override("separation", PANEL_GAP)

	_set_minimum_size(controls, "figs_label", figs_label_minimum_size())
	_set_minimum_size(controls, "cuttings_label", cuttings_label_minimum_size())
	_set_minimum_size(controls, "preserves_label", preserves_label_minimum_size())
	_set_minimum_size(controls, "preserve_label", preserve_recipe_minimum_size())
	_set_minimum_size(controls, "buy_jars_button", preserve_button_minimum_size())
	_set_minimum_size(controls, "make_jam_button", preserve_button_minimum_size())
	_set_minimum_size(controls, "sell_jam_button", preserve_button_minimum_size())
	_set_minimum_size(controls, "recipe_button", preserve_button_minimum_size())
	_set_minimum_size(controls, "trees_label", trees_label_minimum_size())
	_set_minimum_size(controls, "hint_label", hint_label_minimum_size())


static func card_backplates(content: Rect2) -> Array[Rect2]:
	var card_w: float = content.size.x
	var result: Array[Rect2] = []
	result.append(Rect2(Vector2(content.position.x, content.position.y + 48), Vector2(card_w, 92)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 162), Vector2(card_w, 78)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 262), Vector2(card_w, 110)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 394), Vector2(card_w, 98)))
	return result


static func preserve_recipe_text() -> String:
	return "Jam: 5 figs + 1 jar -> $18"


static func _set_minimum_size(controls: Dictionary, key: String, size: Vector2) -> void:
	var control: Control = controls.get(key, null) as Control
	if control != null:
		control.custom_minimum_size = size

# ============================================================
# /*=== PANTRY LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== PANTRY UI FILE END ===*/
# ============================================================
