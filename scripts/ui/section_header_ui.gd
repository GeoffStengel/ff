extends RefCounted

const UIConstants := preload("res://scripts/ui/ui_constants.gd")

# ============================================================
# SectionHeaderUI
# ------------------------------------------------------------
# Purpose:
# Build small shared feature-section headers for PageChrome
# pages and legacy drawer fallback content.
#
# Does NOT:
# - Own gameplay state
# - Handle input or callbacks
# - Mutate layout outside the returned header Control
# ============================================================


# ============================================================
# /*=== SECTION HEADER BUILD START ===*/
# ============================================================

static func create(
	node_prefix: String,
	title: String,
	icon: Texture2D = null
) -> HBoxContainer:
	var header: HBoxContainer = HBoxContainer.new()
	header.name = "%sSectionHeader" % node_prefix
	header.custom_minimum_size = minimum_size()
	header.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))

	var icon_rect: TextureRect = TextureRect.new()
	icon_rect.name = "%sSectionHeaderIcon" % node_prefix
	icon_rect.custom_minimum_size = Vector2(
		UIConstants.SECTION_HEADER_ICON_SIZE,
		UIConstants.SECTION_HEADER_ICON_SIZE
	)
	icon_rect.texture = icon
	icon_rect.visible = icon != null
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(icon_rect)

	var title_label: Label = Label.new()
	title_label.name = "%sSectionHeaderTitle" % node_prefix
	title_label.text = _title_case(title)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override(
		"font_size",
		UIConstants.SECTION_HEADER_SIZE
	)
	title_label.add_theme_color_override("font_color", Color("#725431"))
	header.add_child(title_label)

	return header


static func minimum_size() -> Vector2:
	return Vector2(0.0, UIConstants.SECTION_HEADER_ICON_SIZE)


static func _title_case(value: String) -> String:
	var words: PackedStringArray = value.to_lower().split(" ", false)
	var result: PackedStringArray = []

	for word in words:
		if word.is_empty():
			continue
		result.append(word.substr(0, 1).to_upper() + word.substr(1))

	return " ".join(result)

# ============================================================
# /*=== SECTION HEADER BUILD END ===*/
# ============================================================


# ============================================================
# /*=== SECTION HEADER UI FILE END ===*/
# ============================================================
