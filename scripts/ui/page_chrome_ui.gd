extends RefCounted

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UITheme := preload("res://scripts/ui/theme.gd")

# ============================================================
# PageChromeUI
# ------------------------------------------------------------
# Purpose:
# Build and size the shared mobile-first page shell used by
# migrated feature pages.
#
# Responsibilities:
# - Page chrome Control creation
# - Header/content/bottom-navigation host structure
# - Page chrome responsive sizing
# - Page title/icon updates
#
# Does NOT:
# - Change gameplay state
# - Own navigation callbacks
# - Mutate inventory, orders, crops, saves, or economy
# - Replace the legacy drawer during migration
# ============================================================


# ============================================================
# /*=== PAGE CHROME BUILD START ===*/
# ============================================================

static func build() -> Dictionary:
	var chrome: PanelContainer = PanelContainer.new()
	chrome.name = "GlobalPageChrome"
	chrome.visible = false
	chrome.mouse_filter = Control.MOUSE_FILTER_STOP
	chrome.add_theme_stylebox_override(
		"panel",
		UITheme.page_chrome_style()
	)

	var page_margin: MarginContainer = MarginContainer.new()
	page_margin.name = "GlobalPageChromePadding"
	page_margin.add_theme_constant_override(
		"margin_left",
		int(UIConstants.PAGE_CHROME_SAFE_PADDING)
	)
	page_margin.add_theme_constant_override(
		"margin_top",
		int(UIConstants.PAGE_CHROME_SAFE_PADDING)
	)
	page_margin.add_theme_constant_override(
		"margin_right",
		int(UIConstants.PAGE_CHROME_SAFE_PADDING)
	)
	page_margin.add_theme_constant_override(
		"margin_bottom",
		int(UIConstants.PAGE_CHROME_SAFE_PADDING)
	)
	chrome.add_child(page_margin)

	var page_stack: VBoxContainer = VBoxContainer.new()
	page_stack.name = "GlobalPageStack"
	page_stack.add_theme_constant_override(
		"separation",
		int(UIConstants.PAGE_CHROME_CONTENT_GAP)
	)
	page_margin.add_child(page_stack)

	var header: HBoxContainer = HBoxContainer.new()
	header.name = "GlobalPageHeader"
	header.custom_minimum_size = Vector2(
		0.0,
		UIConstants.PAGE_CHROME_HEADER_HEIGHT
	)
	header.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))
	page_stack.add_child(header)

	var back_button: Button = Button.new()
	back_button.name = "GlobalPageBackButton"
	back_button.text = "<"
	back_button.custom_minimum_size = Vector2(
		UIConstants.TOUCH_TARGET_MIN,
		UIConstants.TOUCH_TARGET_MIN
	)
	header.add_child(back_button)

	var title_slot: CenterContainer = CenterContainer.new()
	title_slot.name = "GlobalPageTitleSlot"
	title_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_slot.custom_minimum_size = Vector2(1.0, UIConstants.TOUCH_TARGET_MIN)
	header.add_child(title_slot)

	var title_group: HBoxContainer = HBoxContainer.new()
	title_group.name = "GlobalPageTitleGroup"
	title_group.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))
	title_slot.add_child(title_group)

	var title_icon: TextureRect = TextureRect.new()
	title_icon.name = "GlobalPageTitleIcon"
	title_icon.custom_minimum_size = Vector2(
		UIConstants.TITLE_ICON_SIZE,
		UIConstants.TITLE_ICON_SIZE
	)
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_group.add_child(title_icon)

	var title_label: Label = Label.new()
	title_label.name = "GlobalPageTitleLabel"
	title_label.text = ""
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_group.add_child(title_label)

	var close_button: Button = Button.new()
	close_button.name = "GlobalPageCloseButton"
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(
		UIConstants.TOUCH_TARGET_MIN,
		UIConstants.TOUCH_TARGET_MIN
	)
	header.add_child(close_button)

	var content_scroll: ScrollContainer = ScrollContainer.new()
	content_scroll.name = "GlobalPageContentScroll"
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_stack.add_child(content_scroll)

	var content_center: CenterContainer = CenterContainer.new()
	content_center.name = "GlobalPageContentCenter"
	content_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.add_child(content_center)

	var content: VBoxContainer = VBoxContainer.new()
	content.name = "GlobalPageContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override(
		"separation",
		int(UIConstants.SECTION_GAP)
	)
	content_center.add_child(content)

	var bottom_navigation: PanelContainer = PanelContainer.new()
	bottom_navigation.name = "GlobalBottomNavigation"
	bottom_navigation.custom_minimum_size = Vector2(
		0.0,
		UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT
	)
	bottom_navigation.add_theme_stylebox_override(
		"panel",
		UITheme.bottom_navigation_style()
	)
	page_stack.add_child(bottom_navigation)

	var bottom_margin: MarginContainer = MarginContainer.new()
	bottom_margin.name = "GlobalBottomNavigationPadding"
	bottom_margin.add_theme_constant_override("margin_left", int(UIConstants.INNER_GAP))
	bottom_margin.add_theme_constant_override("margin_top", int(UIConstants.INNER_GAP))
	bottom_margin.add_theme_constant_override("margin_right", int(UIConstants.INNER_GAP))
	bottom_margin.add_theme_constant_override("margin_bottom", int(UIConstants.INNER_GAP))
	bottom_navigation.add_child(bottom_margin)

	var bottom_row: HBoxContainer = HBoxContainer.new()
	bottom_row.name = "GlobalBottomNavigationRow"
	bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))
	bottom_margin.add_child(bottom_row)

	return {
		"chrome": chrome,
		"header": header,
		"back_button": back_button,
		"title_slot": title_slot,
		"title_group": title_group,
		"title_icon": title_icon,
		"title_label": title_label,
		"close_button": close_button,
		"content_scroll": content_scroll,
		"content_center": content_center,
		"content": content,
		"bottom_navigation": bottom_navigation,
		"bottom_row": bottom_row
	}

# ============================================================
# /*=== PAGE CHROME BUILD END ===*/
# ============================================================


# ============================================================
# /*=== PAGE CHROME LAYOUT START ===*/
# ============================================================

static func apply_layout(
	controls: Dictionary,
	rect: Rect2
) -> void:
	var chrome: Control = controls.get("chrome", null) as Control
	if chrome == null:
		return

	chrome.position = rect.position
	chrome.custom_minimum_size = rect.size
	chrome.size = rect.size

	var inner_width: float = maxf(
		1.0,
		rect.size.x - UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
	)
	var content_width: float = minf(
		UIConstants.READABLE_PAGE_WIDTH,
		inner_width
	)
	var scroll_height: float = maxf(
		1.0,
		rect.size.y
			- UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
			- UIConstants.PAGE_CHROME_HEADER_HEIGHT
			- UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT
			- UIConstants.PAGE_CHROME_CONTENT_GAP * 2.0
	)

	_set_minimum(
		controls.get("content_scroll", null) as Control,
		Vector2(inner_width, scroll_height)
	)
	_set_minimum(
		controls.get("content_center", null) as Control,
		Vector2(inner_width, scroll_height)
	)
	_set_minimum(
		controls.get("content", null) as Control,
		Vector2(content_width, 1.0)
	)


static func content_rect_for_layout(rect: Rect2) -> Rect2:
	var inner_width: float = maxf(
		1.0,
		rect.size.x - UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
	)
	var content_width: float = minf(
		UIConstants.READABLE_PAGE_WIDTH,
		inner_width
	)
	var scroll_height: float = maxf(
		1.0,
		rect.size.y
			- UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
			- UIConstants.PAGE_CHROME_HEADER_HEIGHT
			- UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT
			- UIConstants.PAGE_CHROME_CONTENT_GAP * 2.0
	)

	return Rect2(Vector2.ZERO, Vector2(content_width, scroll_height))


static func set_title(
	controls: Dictionary,
	title: String,
	icon: Texture2D
) -> void:
	var title_label: Label = controls.get("title_label", null) as Label
	if title_label != null:
		title_label.text = title

	var title_icon: TextureRect = controls.get("title_icon", null) as TextureRect
	if title_icon != null:
		title_icon.texture = icon
		title_icon.visible = icon != null


static func _set_minimum(control: Control, size: Vector2) -> void:
	if control != null:
		control.custom_minimum_size = size

# ============================================================
# /*=== PAGE CHROME LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== PAGE CHROME UI FILE END ===*/
# ============================================================
