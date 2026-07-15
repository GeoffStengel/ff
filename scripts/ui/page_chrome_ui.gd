extends RefCounted

const UIConstants := preload("res://scripts/ui/ui_constants.gd")
const UITheme := preload("res://scripts/ui/theme.gd")

const SCROLLBAR_GUTTER := 0.0
const TITLE_GROUP_MAX_W := 220.0
const BOTTOM_NAV_ITEM_COUNT := 5

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
	var chrome: Panel = Panel.new()
	chrome.name = "GlobalPageChrome"
	chrome.visible = false
	chrome.clip_contents = true
	chrome.mouse_filter = Control.MOUSE_FILTER_STOP
	chrome.add_theme_stylebox_override(
		"panel",
		UITheme.page_chrome_style()
	)

	var page_margin: MarginContainer = MarginContainer.new()
	page_margin.name = "GlobalPageChromePadding"
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	page_stack.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	page_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_stack.add_theme_constant_override(
		"separation",
		int(UIConstants.PAGE_CHROME_CONTENT_GAP)
	)
	page_margin.add_child(page_stack)

	var header: Control = Control.new()
	header.name = "GlobalPageHeader"
	header.clip_contents = true
	header.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	header.custom_minimum_size = Vector2(
		0.0,
		UIConstants.PAGE_CHROME_HEADER_HEIGHT
	)
	header.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))
	page_stack.add_child(header)

	var back_button: Button = Button.new()
	back_button.name = "GlobalPageBackButton"
	back_button.text = "<"
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back_button.custom_minimum_size = Vector2(
		UIConstants.TOUCH_TARGET_MIN,
		UIConstants.TOUCH_TARGET_MIN
	)
	header.add_child(back_button)

	var title_slot: Control = Control.new()
	title_slot.name = "GlobalPageTitleSlot"
	title_slot.clip_contents = true
	title_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_slot.custom_minimum_size = Vector2(1.0, UIConstants.TOUCH_TARGET_MIN)
	header.add_child(title_slot)

	var title_group: HBoxContainer = HBoxContainer.new()
	title_group.name = "GlobalPageTitleGroup"
	title_group.clip_contents = true
	title_group.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
	title_label.clip_text = true
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_group.add_child(title_label)

	var close_button: Button = Button.new()
	close_button.name = "GlobalPageCloseButton"
	close_button.text = ">"
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	close_button.custom_minimum_size = Vector2(
		UIConstants.TOUCH_TARGET_MIN,
		UIConstants.TOUCH_TARGET_MIN
	)
	header.add_child(close_button)

	var content_scroll: ScrollContainer = ScrollContainer.new()
	content_scroll.name = "GlobalPageContentScroll"
	content_scroll.clip_contents = true
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	page_stack.add_child(content_scroll)

	var content_center: VBoxContainer = VBoxContainer.new()
	content_center.name = "GlobalPageContentCenter"
	content_center.clip_contents = true
	content_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_center.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	content_scroll.add_child(content_center)

	var content: VBoxContainer = VBoxContainer.new()
	content.name = "GlobalPageContent"
	content.clip_contents = true
	content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_theme_constant_override(
		"separation",
		int(UIConstants.SECTION_GAP)
	)
	content_center.add_child(content)

	var bottom_navigation: Panel = Panel.new()
	bottom_navigation.name = "GlobalBottomNavigation"
	bottom_navigation.clip_contents = true
	bottom_navigation.custom_minimum_size = Vector2(
		0.0,
		UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT
	)
	bottom_navigation.add_theme_stylebox_override(
		"panel",
		UITheme.bottom_navigation_style()
	)
	page_stack.add_child(bottom_navigation)

	var bottom_slot: Control = Control.new()
	bottom_slot.name = "GlobalBottomNavigationSlot"
	bottom_slot.clip_contents = true
	bottom_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_navigation.add_child(bottom_slot)

	var bottom_row: HBoxContainer = HBoxContainer.new()
	bottom_row.name = "GlobalBottomNavigationRow"
	bottom_row.clip_contents = true
	bottom_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bottom_row.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))
	bottom_slot.add_child(bottom_row)

	return {
		"chrome": chrome,
		"page_margin": page_margin,
		"page_stack": page_stack,
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
		"bottom_slot": bottom_slot,
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
		maxf(1.0, inner_width - SCROLLBAR_GUTTER)
	)
	var title_width: float = maxf(
		1.0,
		inner_width
			- UIConstants.TOUCH_TARGET_MIN * 2.0
			- UIConstants.INNER_GAP * 2.0
	)
	var title_label_width: float = maxf(
		1.0,
		minf(title_width, TITLE_GROUP_MAX_W)
			- UIConstants.TITLE_ICON_SIZE
			- UIConstants.INNER_GAP
	)
	var title_group_width: float = minf(
		title_width,
		UIConstants.TITLE_ICON_SIZE
			+ UIConstants.INNER_GAP
			+ title_label_width
	)
	var bottom_slot_width: float = maxf(
		1.0,
		inner_width - UIConstants.INNER_GAP * 2.0
	)
	var bottom_slot_height: float = maxf(
		1.0,
		UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT - UIConstants.INNER_GAP * 2.0
	)
	var bottom_nav_min_width: float = (
		UIConstants.NAV_ITEM_MIN_WIDTH * float(BOTTOM_NAV_ITEM_COUNT)
		+ UIConstants.INNER_GAP * float(BOTTOM_NAV_ITEM_COUNT - 1)
	)
	var bottom_row_width: float = minf(
		bottom_slot_width,
		maxf(bottom_nav_min_width, bottom_slot_width)
	)
	var bottom_row_height: float = UIConstants.TOUCH_TARGET_MIN
	var scroll_height: float = maxf(
		1.0,
		rect.size.y
			- UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
			- UIConstants.PAGE_CHROME_HEADER_HEIGHT
			- UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT
			- UIConstants.PAGE_CHROME_CONTENT_GAP * 2.0
	)

	_set_minimum(
		controls.get("page_margin", null) as Control,
		rect.size
	)
	_set_position(
		controls.get("page_margin", null) as Control,
		Vector2.ZERO
	)
	_set_size(
		controls.get("page_margin", null) as Control,
		rect.size
	)
	_set_minimum(
		controls.get("page_stack", null) as Control,
		Vector2(inner_width, maxf(1.0, rect.size.y - UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0))
	)
	_set_position(
		controls.get("page_stack", null) as Control,
		Vector2.ZERO
	)
	_set_size(
		controls.get("page_stack", null) as Control,
		Vector2(inner_width, maxf(1.0, rect.size.y - UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0))
	)
	_set_minimum(
		controls.get("header", null) as Control,
		Vector2(inner_width, UIConstants.PAGE_CHROME_HEADER_HEIGHT)
	)
	_set_minimum(
		controls.get("title_slot", null) as Control,
		Vector2(title_width, UIConstants.TOUCH_TARGET_MIN)
	)


	_set_position(
		controls.get("back_button", null) as Control,
		Vector2.ZERO
	)
	_set_size(
		controls.get("back_button", null) as Control,
		Vector2(UIConstants.TOUCH_TARGET_MIN, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_position(
		controls.get("close_button", null) as Control,
		Vector2(inner_width - UIConstants.TOUCH_TARGET_MIN, 0.0)
	)
	_set_size(
		controls.get("close_button", null) as Control,
		Vector2(UIConstants.TOUCH_TARGET_MIN, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_position(
		controls.get("title_slot", null) as Control,
		Vector2(
			UIConstants.TOUCH_TARGET_MIN + UIConstants.INNER_GAP,
			0.0
		)
	)
	_set_size(
		controls.get("title_slot", null) as Control,
		Vector2(title_width, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_minimum(
		controls.get("title_group", null) as Control,
		Vector2(title_group_width, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_position(
		controls.get("title_group", null) as Control,
		Vector2(maxf(0.0, (title_width - title_group_width) * 0.5), 0.0)
	)
	_set_size(
		controls.get("title_group", null) as Control,
		Vector2(title_group_width, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_minimum(
		controls.get("title_label", null) as Control,
		Vector2(title_label_width, UIConstants.TOUCH_TARGET_MIN)
	)
	_set_size(
		controls.get("title_label", null) as Control,
		Vector2(title_label_width, UIConstants.TOUCH_TARGET_MIN)
	)


	_set_minimum(
		controls.get("content_scroll", null) as Control,
		Vector2(inner_width, scroll_height)
	)
	_set_minimum(
		controls.get("content_center", null) as Control,
		Vector2(inner_width, 1.0)
	)
	_set_minimum(
		controls.get("content", null) as Control,
		Vector2(content_width, 1.0)
	)

	_set_horizontal_center_shrink(
		controls.get("content", null) as Control
	)
	_set_size(
		controls.get("header", null) as Control,
		Vector2(inner_width, UIConstants.PAGE_CHROME_HEADER_HEIGHT)
	)
	_set_size(
		controls.get("content_scroll", null) as Control,
		Vector2(inner_width, scroll_height)
	)
	_set_position(
		controls.get("content_center", null) as Control,
		Vector2.ZERO
	)
	_set_size(
		controls.get("content_center", null) as Control,
		Vector2(inner_width, scroll_height)
	)
	_set_size(
		controls.get("bottom_navigation", null) as Control,
		Vector2(inner_width, UIConstants.PAGE_CHROME_BOTTOM_NAV_HEIGHT)
	)
	_set_minimum(
		controls.get("bottom_slot", null) as Control,
		Vector2(bottom_slot_width, bottom_slot_height)
	)
	_set_position(
		controls.get("bottom_slot", null) as Control,
		Vector2(UIConstants.INNER_GAP, UIConstants.INNER_GAP)
	)
	_set_size(
		controls.get("bottom_slot", null) as Control,
		Vector2(bottom_slot_width, bottom_slot_height)
	)
	_set_minimum(
		controls.get("bottom_row", null) as Control,
		Vector2(bottom_row_width, bottom_row_height)
	)
	_set_position(
		controls.get("bottom_row", null) as Control,
		Vector2(
			maxf(0.0, (bottom_slot_width - bottom_row_width) * 0.5),
			maxf(0.0, (bottom_slot_height - bottom_row_height) * 0.5)
		)
	)
	_set_size(
		controls.get("bottom_row", null) as Control,
		Vector2(bottom_row_width, bottom_row_height)
	)
	_set_size(
		controls.get("content", null) as Control,
		Vector2(content_width, scroll_height)
	)


static func content_rect_for_layout(rect: Rect2) -> Rect2:
	var inner_width: float = maxf(
		1.0,
		rect.size.x
			- UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
			- SCROLLBAR_GUTTER
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


static func _set_size(control: Control, size: Vector2) -> void:
	if control != null:
		control.size = size


static func _set_position(control: Control, position: Vector2) -> void:
	if control != null:
		control.position = position


static func _set_horizontal_center_shrink(control: Control) -> void:
	if control != null:
		control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

# ============================================================
# /*=== PAGE CHROME LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== PAGE CHROME UI FILE END ===*/
# ============================================================
