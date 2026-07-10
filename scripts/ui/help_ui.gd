extends RefCounted

# ============================================================
# HelpUI
# ------------------------------------------------------------
# Owns Help drawer layout, sizing, card geometry, spacing,
# and pure help text formatting.
#
# Does NOT:
# - Change game state
# - Handle input or callbacks
# - Play sounds or show messages
# - Mutate tutorials
# ============================================================

const TextLibrary = preload("res://scripts/text_library.gd")


# ============================================================
# /*=== HELP CONSTANTS START ===*/
# ============================================================

const CONTENT_W := 376.0
const PANEL_GAP := 10
const HELP_TEXT_H := 344.0

# ============================================================
# /*=== HELP CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== HELP SIZE HELPERS START ===*/
# ============================================================

static func panel_separation() -> int:
	return PANEL_GAP


static func help_text_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, HELP_TEXT_H)

# ============================================================
# /*=== HELP SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== HELP LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: VBoxContainer = controls.get("panel", null) as VBoxContainer
	if panel != null:
		panel.position = content.position
		panel.custom_minimum_size = content.size
		panel.add_theme_constant_override("separation", PANEL_GAP)

	_set_minimum_size(controls, "help_text_label", help_text_minimum_size())


static func card_backplates(content: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(
		Rect2(
			Vector2(content.position.x, content.position.y + 48),
			Vector2(content.size.x, minf(470.0, content.size.y - 64.0))
		)
	)
	return result


static func how_to_play_text() -> String:
	return TextLibrary.how_to_play_text()


static func _set_minimum_size(controls: Dictionary, key: String, size: Vector2) -> void:
	var control: Control = controls.get(key, null) as Control
	if control != null:
		control.custom_minimum_size = size

# ============================================================
# /*=== HELP LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== HELP UI FILE END ===*/
# ============================================================
