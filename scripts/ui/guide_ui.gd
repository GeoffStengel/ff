extends RefCounted

# ============================================================
# GuideUI
# ------------------------------------------------------------
# Owns Guide drawer layout, sizing, card geometry, spacing,
# and pure guide display formatting.
#
# Does NOT:
# - Change selected cultivar
# - Change plot state
# - Advance tutorials
# - Play sounds or handle input
# ============================================================

const TextLibrary = preload("res://scripts/text_library.gd")


# ============================================================
# /*=== GUIDE CONSTANTS START ===*/
# ============================================================

const CONTENT_W := 376.0
const PANEL_GAP := 10
const NOTEBOOK_H := 66.0
const PLOT_STATUS_H := 132.0
const VISUAL_KEY_GAP := 14
const LEGEND_H := 150.0

# ============================================================
# /*=== GUIDE CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== GUIDE SIZE HELPERS START ===*/
# ============================================================

static func panel_separation() -> int:
	return PANEL_GAP


static func notebook_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, NOTEBOOK_H)


static func plot_status_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, PLOT_STATUS_H)


static func visual_key_gap() -> int:
	return VISUAL_KEY_GAP


static func legend_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, LEGEND_H)

# ============================================================
# /*=== GUIDE SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== GUIDE LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: VBoxContainer = controls.get("panel", null) as VBoxContainer
	if panel != null:
		panel.position = content.position
		panel.custom_minimum_size = content.size
		panel.add_theme_constant_override("separation", PANEL_GAP)

	_set_minimum_size(controls, "notebook_label", notebook_minimum_size())
	_set_minimum_size(controls, "plot_status_label", plot_status_minimum_size())
	_set_minimum_size(controls, "legend_label", legend_minimum_size())


static func card_backplates(content: Rect2) -> Array[Rect2]:
	var card_w: float = content.size.x
	var result: Array[Rect2] = []
	result.append(Rect2(Vector2(content.position.x, content.position.y + 48), Vector2(card_w, 112)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 182), Vector2(card_w, 184)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 396), Vector2(card_w, 164)))
	return result


static func notebook_text(variety: Dictionary) -> String:
	return "Cultivar: %s\n%s" % [
		String(variety.get("short", "")),
		String(variety.get("lesson", ""))
	]


static func legend_text(
	season_name: String,
	temperature_f: int,
	season_growing_note: String,
	recipe_expanded: bool
) -> String:
	return TextLibrary.guide_legend_text(season_name, temperature_f, season_growing_note, recipe_expanded)


static func _set_minimum_size(controls: Dictionary, key: String, size: Vector2) -> void:
	var control: Control = controls.get(key, null) as Control
	if control != null:
		control.custom_minimum_size = size

# ============================================================
# /*=== GUIDE LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== GUIDE UI FILE END ===*/
# ============================================================
