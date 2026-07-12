# ============================================================
# /*=== VILLAGE REQUESTS UI FILE START ===*/
# ============================================================
class_name VillageRequestsUI
extends RefCounted

# ============================================================
# VillageRequestsUI
# ------------------------------------------------------------
# Purpose:
# Own the Village Requests drawer layout, sizing, and simple
# display-copy helpers.
#
# Responsibilities:
# - Village Requests card/grid layout
# - minimum sizes for controls created by main.gd
# - card backplate rectangles for decorative drawing
# - request hero/list copy helpers
#
# Does NOT:
# - accept or fulfill orders
# - mutate inventory or save data
# - play sounds or show messages
# - call _update_ui() or touch gameplay state
# ============================================================

const OrderSystem = preload("res://scripts/order_system.gd")
const UITheme = preload("res://scripts/ui/theme.gd")
const UIConstants = preload("res://scripts/ui/ui_constants.gd")
const Layout = preload("res://scripts/ui/layout.gd")


# ============================================================
# /*=== VILLAGE REQUESTS CONSTANTS START ===*/
# ============================================================

const CONTENT_W := 340.0
const HEADER_H := 30.0
const SECTION_LABEL_H := 12.0
const SUPPORT_LABEL_H := 16.0
const LOGBOOK_H := 24.0

const WEEKLY_BACKPLATE_H := UIConstants.WEEKLY_CARD_HEIGHT
const CURRENT_BACKPLATE_H := 164.0
const LIST_BACKPLATE_MIN_H := 146.0

const WEEKLY_LABEL_H := 44.0
const CURRENT_LABEL_H := 94.0
const REQUEST_LIST_MIN_H := 112.0
const ACTION_BUTTON_W := 316.0

const PANEL_LEFT_PAD := 20.0
const CONTRACT_Y := 42.0
const BACKPLATE_GAP := UIConstants.CARD_GAP
const INNER_PAD := UIConstants.CARD_PADDING

# ============================================================
# /*=== VILLAGE REQUESTS CONSTANTS END ===*/
# ============================================================



# ============================================================
# /*=== PANEL SIZE HELPERS START ===*/
# ============================================================

static func panel_position(drawer_content_position: Vector2) -> Vector2:
	return drawer_content_position + Vector2(PANEL_LEFT_PAD, 0.0)


static func panel_size(drawer_content_size: Vector2) -> Vector2:
	var available_width: float = maxf(
		1.0,
		drawer_content_size.x - PANEL_LEFT_PAD * 2.0
	)

	return Vector2(
		minf(CONTENT_W, available_width),
		drawer_content_size.y
	)

static func safe_content_width(content: Rect2) -> float:
	return panel_size(content.size).x

static func content_rect(drawer_content_position: Vector2, drawer_content_size: Vector2) -> Rect2:
	return Rect2(drawer_content_position, drawer_content_size)

# ============================================================
# /*=== PANEL SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== RESPONSIVE LAYOUT START ===*/
# ------------------------------------------------------------
# Village Requests uses three major rows:
# 1. Weekly contract
# 2. Current request hero card
# 3. Paged available request card
#
# Sell Crate no longer belongs to this screen, so the request
# list receives all remaining vertical space.
# ============================================================

static func build_orderbook_layout(content: Rect2) -> Dictionary:
	var page: Rect2 = Layout.with_width(
		content,
		safe_content_width(content)
	)

	var fixed_height: float = (
		CONTRACT_Y
		+ WEEKLY_BACKPLATE_H
		+ CURRENT_BACKPLATE_H
		+ BACKPLATE_GAP * 2.0
	)

	var available_list_h: float = maxf(
		1.0,
		page.size.y
			- fixed_height
			- UIConstants.CARD_PADDING
	)

	var rows: Array[Rect2] = Layout.vertical_stack(
		page.position + Vector2(0.0, CONTRACT_Y),
		page.size.x,
		[
			WEEKLY_BACKPLATE_H,
			CURRENT_BACKPLATE_H,
			available_list_h
		],
		BACKPLATE_GAP
	)

	var weekly: Rect2 = rows[0]
	var current: Rect2 = rows[1]
	var list: Rect2 = rows[2]

	var current_inner: Rect2 = Layout.inset(
		current,
		INNER_PAD
	)

	var primary_button: Rect2 = Rect2(
		current_inner.position + Vector2(
			0.0,
			current_inner.size.y - UIConstants.BUTTON_HEIGHT
		),
		Vector2(
			current_inner.size.x,
			UIConstants.BUTTON_HEIGHT
		)
	)

	var current_text: Rect2 = Rect2(
		current_inner.position,
		Vector2(
			current_inner.size.x,
			maxf(
				0.0,
				current_inner.size.y
					- UIConstants.BUTTON_HEIGHT
					- UIConstants.INNER_GAP
			)
		)
	)

	return {
		"page": page,

		"weekly": weekly,
		"current": current,
		"list": list,

		"weekly_inner": Layout.inset(weekly, INNER_PAD),
		"current_inner": current_inner,
		"current_text": current_text,
		"list_inner": Layout.inset(list, INNER_PAD),

		"primary_button": primary_button
	}

# ============================================================
# /*=== RESPONSIVE LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== CONTROL SIZE HELPERS START ===*/
# ============================================================

static func title_minimum_size(content: Rect2) -> Vector2:
	return Vector2(
		safe_content_width(content),
		HEADER_H
	)


static func section_label_minimum_size(content: Rect2) -> Vector2:
	return Vector2(
		safe_content_width(content),
		SECTION_LABEL_H
	)

# ============================================================
# /*=== WEEKLY CONTRACT START ===*/
# ============================================================

static func weekly_contract_minimum_size(content: Rect2) -> Vector2:
	var layout: Dictionary = build_orderbook_layout(content)
	return Vector2(layout["weekly_inner"].size.x, WEEKLY_LABEL_H)

# ============================================================
# /*=== WEEKLY CONTRACT END ===*/
# ============================================================


# ============================================================
# /*=== CURRENT REQUEST HERO CARD START ===*/
# ============================================================

static func current_request_minimum_size(content: Rect2) -> Vector2:
	var layout: Dictionary = build_orderbook_layout(content)
	return Vector2(layout["current_text"].size.x, CURRENT_LABEL_H)

# ============================================================
# /*=== CURRENT REQUEST HERO CARD END ===*/
# ============================================================


# ============================================================
# /*=== PRIMARY ACTION START ===*/
# ============================================================

static func action_button_minimum_size() -> Vector2:
	return Vector2(ACTION_BUTTON_W, UIConstants.BUTTON_HEIGHT)

# ============================================================
# /*=== PRIMARY ACTION END ===*/
# ============================================================



# ============================================================
# /*=== AVAILABLE REQUESTS START ===*/
# ------------------------------------------------------------
# The list uses only the space allocated by the orderbook
# layout. ScrollContainer handles additional request cards.
# ============================================================

static func request_list_rect(content: Rect2) -> Rect2:
	var layout: Dictionary = build_orderbook_layout(content)
	return layout["list_inner"]


static func request_list_minimum_size(content: Rect2) -> Vector2:
	var list_rect: Rect2 = request_list_rect(content)

	return Vector2(
		list_rect.size.x,
		maxf(1.0, list_rect.size.y)
	)


static func request_card_minimum_size(content: Rect2) -> Vector2:
	return Vector2(
		safe_content_width(content),
		UIConstants.REQUEST_CARD_HEIGHT
	)

# ============================================================
# /*=== AVAILABLE REQUESTS END ===*/
# ============================================================

static func support_label_minimum_size(content: Rect2) -> Vector2:
	return Vector2(
		safe_content_width(content),
		SUPPORT_LABEL_H
	)


static func logbook_minimum_size(content: Rect2) -> Vector2:
	return Vector2(
		safe_content_width(content),
		LOGBOOK_H
	)


static func action_button_rect(content: Rect2) -> Rect2:
	var layout: Dictionary = build_orderbook_layout(content)
	return layout["primary_button"]
# ============================================================
# /*=== CONTROL SIZE HELPERS END ===*/
# ============================================================

# ============================================================
# /*=== CARD BACKPLATES START ===*/
# ------------------------------------------------------------
# Weekly Contract and Current Request use custom-drawn cards.
#
# Available Requests now uses a real styled Button pager card,
# so it no longer needs a second custom backplate behind it.
# ============================================================

static func card_backplates(content: Rect2) -> Array[Rect2]:
	var layout: Dictionary = build_orderbook_layout(content)

	return [
		layout["weekly"],
		layout["current"]
	]

# ============================================================
# /*=== CARD BACKPLATES END ===*/
# ============================================================


# ============================================================
# /*=== APPLY LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: Control = _control_or_null(controls, "market_panel")

	if panel != null:
		var safe_panel_size: Vector2 = panel_size(content.size)

		panel.position = panel_position(content.position)
		panel.custom_minimum_size = safe_panel_size
		panel.size = safe_panel_size
		panel.size_flags_horizontal = Control.SIZE_FILL
		panel.size_flags_vertical = Control.SIZE_FILL
		panel.add_theme_constant_override("separation", 4)

	_set_minimum_size(
		controls,
		"market_title",
		title_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"weekly_label",
		weekly_contract_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"order_detail_label",
		current_request_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"accept_button",
		action_button_minimum_size()
	)

	_set_minimum_size(
		controls,
		"fulfill_button",
		action_button_minimum_size()
	)

	_set_minimum_size(
		controls,
		"inventory_label",
		support_label_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"relationship_label",
		support_label_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"logbook_label",
		logbook_minimum_size(content)
	)

	_set_minimum_size(
		controls,
		"order_page_button",
		request_card_minimum_size(content)
	)

	var order_page_button: Control = _control_or_null(
		controls,
		"order_page_button"
	)

	if order_page_button != null:
		order_page_button.size_flags_horizontal = Control.SIZE_FILL


static func _set_minimum_size(
	controls: Dictionary,
	key: String,
	size: Vector2
) -> void:
	var control: Control = _control_or_null(controls, key)

	if control != null:
		control.custom_minimum_size = size


static func _control_or_null(
	controls: Dictionary,
	key: String
) -> Control:
	if not controls.has(key):
		return null

	var value: Variant = controls[key]

	if value == null:
		return null

	if value is Control:
		return value as Control

	return null

# ============================================================
# /*=== APPLY LAYOUT END ===*/
# ============================================================


# ============================================================
# /*=== DECORATIVE DRAWING HELPERS START ===*/
# ============================================================

static func draw_card_backplates(canvas: CanvasItem, content: Rect2) -> void:
	for rect in card_backplates(content):
		UITheme.draw_card(canvas, rect)

# ============================================================
# /*=== DECORATIVE DRAWING HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== CURRENT REQUEST HERO TEXT START ===*/
# ============================================================

static func current_request_text(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary],
	varieties: Array[Dictionary]
) -> String:
	var selected: Dictionary = OrderSystem.order_at(
		selected_index,
		accepted_orders,
		order_offers
	)

	if selected.is_empty():
		return (
			"No request selected\n\n"
			+ "Available requests will show here when villagers post them."
		)

	var accepted: bool = OrderSystem.selected_order_is_accepted(
		selected_index,
		accepted_orders
	)

	var status: String = "ACCEPTED" if accepted else "NEW OFFER"
	var customer: String = OrderSystem.short_customer_name(
		String(selected.get("customer", "Customer"))
	)

	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = _display_variety_short(
		int(selected.get("variety", -1)),
		varieties
	)

	var label: String = String(selected.get("label", "Fresh figs"))
	var reward: int = int(selected.get("reward", 0))
	var patience: int = int(selected.get("patience", 0))

	var action_line: String = (
		"Fulfill from pantry when packed."
		if accepted
		else
		"Review only. No Trust risk until accepted."
	)

	return (
		"%s                         %s left\n"
		+ "👤 %s\n"
		+ "%sx %s figs\n"
		+ "%s\n"
		+ "PAYOUT  $%s\n"
		+ "%s"
	) % [
		status,
		OrderSystem.day_count_text(patience),
		customer,
		quantity,
		variety_name,
		label,
		reward,
		action_line
	]

# ============================================================
# /*=== CURRENT REQUEST HERO TEXT END ===*/
# ============================================================

# ============================================================
# /*=== AVAILABLE REQUEST CARD TEXT START ===*/
# ============================================================

static func request_card_text(
	index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary],
	varieties: Array[Dictionary]
) -> String:
	var selected: Dictionary = OrderSystem.order_at(
		index,
		accepted_orders,
		order_offers
	)

	if selected.is_empty():
		return ""

	var accepted: bool = OrderSystem.selected_order_is_accepted(
		index,
		accepted_orders
	)

	var status_text: String = "ACCEPTED" if accepted else "NEW"
	var customer: String = OrderSystem.short_customer_name(
		String(selected.get("customer", "Customer"))
	)
	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = _display_variety_short(
		int(selected.get("variety", -1)),
		varieties
	)
	var reward: int = int(selected.get("reward", 0))
	var patience: int = int(selected.get("patience", 0))
	var time_text: String = (
		OrderSystem.day_count_text(patience)
		if accepted
		else "Review"
	)

	return (
		"%s  👤 %s  •  $%s\n"
		+ "%s× %s figs  •  %s"
	) % [
		status_text,
		customer,
		reward,
		quantity,
		variety_name,
		time_text
	]

# ============================================================
# /*=== AVAILABLE REQUEST CARD TEXT END ===*/
# ============================================================


# ============================================================
# /*=== INTERNAL TEXT HELPERS START ===*/
# ============================================================

static func _display_variety_short(variety_index: int, varieties: Array[Dictionary]) -> String:
	if variety_index < 0 or variety_index >= varieties.size():
		return "Mixed"
	return String(varieties[variety_index].get("short", "Mixed"))

# ============================================================
# /*=== INTERNAL TEXT HELPERS END ===*/
# ============================================================

# ============================================================
# /*=== VILLAGE REQUESTS UI FILE END ===*/
# ============================================================
