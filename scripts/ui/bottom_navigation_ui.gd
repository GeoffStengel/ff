extends RefCounted

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UITheme := preload("res://scripts/ui/theme.gd")

# ============================================================
# BottomNavigationUI
# ------------------------------------------------------------
# Purpose:
# Build and update the shared mobile-first bottom navigation.
#
# Responsibilities:
# - Bottom navigation item sizing
# - Runtime node names
# - Icon and label assignment
# - Active/selected visual state
#
# Does NOT:
# - Own callbacks
# - Change side-tab state
# - Mutate gameplay, inventory, orders, saves, or economy
# ============================================================


# ============================================================
# /*=== BOTTOM NAVIGATION BUILD START ===*/
# ============================================================

static func add_item(
	parent: Control,
	node_name: String,
	label: String,
	icon: Texture2D
) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = label
	button.icon = icon
	button.expand_icon = false
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = item_minimum_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", UIConstants.SMALL_SIZE)
	apply_item_style(button, false)
	parent.add_child(button)
	return button


static func item_minimum_size() -> Vector2:
	return Vector2(
		UIConstants.NAV_ITEM_MIN_WIDTH,
		UIConstants.TOUCH_TARGET_MIN
	)

# ============================================================
# /*=== BOTTOM NAVIGATION BUILD END ===*/
# ============================================================


# ============================================================
# /*=== BOTTOM NAVIGATION STATE START ===*/
# ============================================================

static func apply_active_state(
	buttons: Dictionary,
	active_key: String
) -> void:
	for key in buttons.keys():
		var button: Button = buttons[key] as Button
		if button == null:
			continue

		var active: bool = String(key) == active_key
		button.button_pressed = active
		apply_item_style(button, active)


static func apply_item_style(button: Button, active: bool) -> void:
	var fill: Color = Color("#fff8e8")
	var hover: Color = Color("#fff4df")
	var pressed: Color = Color("#ead6aa")
	var border: Color = Color("#d9c49c")
	var font_color: Color = Color("#5b492e")

	if active:
		fill = Color("#dce8bf")
		hover = Color("#e9f2d3")
		pressed = Color("#b7d084")
		border = Color("#82a04c")
		font_color = Color("#3b4a22")

	button.add_theme_stylebox_override(
		"normal",
		UITheme.rounded_style(fill, border, UIConstants.BUTTON_RADIUS, 1)
	)
	button.add_theme_stylebox_override(
		"hover",
		UITheme.rounded_style(hover, border, UIConstants.BUTTON_RADIUS, 1)
	)
	button.add_theme_stylebox_override(
		"pressed",
		UITheme.rounded_style(pressed, border, UIConstants.BUTTON_RADIUS, 1)
	)
	button.add_theme_stylebox_override(
		"disabled",
		UITheme.rounded_style(Color("#ddd3be"), Color("#c1b29a"), UIConstants.BUTTON_RADIUS, 1)
	)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color("#7c7161"))

# ============================================================
# /*=== BOTTOM NAVIGATION STATE END ===*/
# ============================================================


# ============================================================
# /*=== BOTTOM NAVIGATION UI FILE END ===*/
# ============================================================
