extends RefCounted

# ============================================================
# FarmControlsUI
# ------------------------------------------------------------
# Owns Farm tab drawer layout, control sizing, spacing, and
# decorative card backplates.
#
# Does NOT:
# - Change selected tools or cultivars
# - Buy items or mutate inventory
# - Start days, save, load, pause, or play sound
# - Handle input or callbacks
# ============================================================


# ============================================================
# /*=== FARM CONTROLS CONSTANTS START ===*/
# ============================================================

const CONTENT_W := 376.0
const PANEL_GAP := 5
const ACTION_HINT_H := 24.0
const SHOP_BUTTON_SIZE := Vector2(184, 32)
const CLIPPING_BUTTON_SIZE := Vector2(CONTENT_W, 28)
const UPGRADE_BUTTON_SIZE := Vector2(184, 32)
const DAY_BUTTON_SIZE := Vector2(CONTENT_W, 34)
const SAVE_BUTTON_SIZE := Vector2(88, 30)

# ============================================================
# /*=== FARM CONTROLS CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== FARM CONTROLS SIZE HELPERS START ===*/
# ============================================================

static func panel_separation() -> int:
	return PANEL_GAP


static func action_hint_minimum_size() -> Vector2:
	return Vector2(CONTENT_W, ACTION_HINT_H)


static func shop_button_minimum_size() -> Vector2:
	return SHOP_BUTTON_SIZE


static func clipping_button_minimum_size() -> Vector2:
	return CLIPPING_BUTTON_SIZE


static func upgrade_button_minimum_size() -> Vector2:
	return UPGRADE_BUTTON_SIZE


static func day_button_minimum_size() -> Vector2:
	return DAY_BUTTON_SIZE


static func save_button_minimum_size() -> Vector2:
	return SAVE_BUTTON_SIZE

# ============================================================
# /*=== FARM CONTROLS SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== FARM CONTROLS LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: VBoxContainer = controls.get("panel", null) as VBoxContainer
	if panel != null:
		panel.position = content.position
		panel.custom_minimum_size = content.size
		panel.add_theme_constant_override("separation", PANEL_GAP)

	_set_minimum_size(controls, "action_hint", action_hint_minimum_size())
	_set_minimum_size(controls, "buy_cuttings_button", shop_button_minimum_size())
	_set_minimum_size(controls, "buy_compost_button", shop_button_minimum_size())
	_set_minimum_size(controls, "clipping_button", clipping_button_minimum_size())
	_set_minimum_size(controls, "barrel_button", upgrade_button_minimum_size())
	_set_minimum_size(controls, "garden_button", upgrade_button_minimum_size())
	_set_minimum_size(controls, "day_button", day_button_minimum_size())
	_set_minimum_size(controls, "save_button", save_button_minimum_size())
	_set_minimum_size(controls, "load_button", save_button_minimum_size())
	_set_minimum_size(controls, "pause_button", save_button_minimum_size())
	_set_minimum_size(controls, "sound_button", save_button_minimum_size())


static func card_backplates(content: Rect2) -> Array[Rect2]:
	var card_w: float = content.size.x
	var result: Array[Rect2] = []
	result.append(Rect2(Vector2(content.position.x, content.position.y + 48), Vector2(card_w, 116)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 186), Vector2(card_w, 158)))
	result.append(Rect2(Vector2(content.position.x, content.position.y + 368), Vector2(card_w, 176)))
	return result


static func _set_minimum_size(controls: Dictionary, key: String, size: Vector2) -> void:
	var control: Control = controls.get(key, null) as Control
	if control != null:
		control.custom_minimum_size = size

# ============================================================
# /*=== FARM CONTROLS LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FARM CONTROLS UI FILE END ===*/
# ============================================================
