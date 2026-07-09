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
const HEADER_H := 34.0
const SECTION_LABEL_H := 12.0
const SUPPORT_LABEL_H := 20.0
const LOGBOOK_H := 34.0

const WEEKLY_BACKPLATE_H := UIConstants.WEEKLY_CARD_HEIGHT
const CURRENT_BACKPLATE_H := UIConstants.HERO_CARD_HEIGHT
const ACTION_BACKPLATE_H := UIConstants.BUTTON_HEIGHT + UIConstants.CARD_PADDING * 2.0
const LIST_BACKPLATE_H := 176.0

const WEEKLY_LABEL_H := 54.0
const CURRENT_LABEL_H := 126.0
const REQUEST_LIST_H := 150.0
const ACTION_BUTTON_W := 108.0

const PANEL_LEFT_PAD := 20.0
const CONTRACT_Y := 46.0
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
	return Vector2(CONTENT_W, drawer_content_size.y)


static func content_rect(drawer_content_position: Vector2, drawer_content_size: Vector2) -> Rect2:
	return Rect2(drawer_content_position, drawer_content_size)

# ============================================================
# /*=== PANEL SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== VILLAGE REQUESTS LAYOUT MAP START ===*/
# ============================================================

static func build_orderbook_layout(content: Rect2) -> Dictionary:
	var page: Rect2 = Layout.with_width(content, minf(CONTENT_W, content.size.x))
	var row_heights: Array[float] = [
		WEEKLY_BACKPLATE_H,
		CURRENT_BACKPLATE_H,
		ACTION_BACKPLATE_H,
		LIST_BACKPLATE_H
	]
	var rows: Array[Rect2] = Layout.vertical_stack(
		page.position + Vector2(0.0, CONTRACT_Y),
		page.size.x,
		row_heights,
		BACKPLATE_GAP
	)

	var weekly: Rect2 = rows[0]
	var current: Rect2 = rows[1]
	var action: Rect2 = rows[2]
	var list: Rect2 = rows[3]
	var action_inner: Rect2 = Layout.inset(action, INNER_PAD)

	return {
		"page": page,
		"weekly": weekly,
		"current": current,
		"action": action,
		"list": list,
		"weekly_inner": Layout.inset(weekly, INNER_PAD),
		"current_inner": Layout.inset(current, INNER_PAD),
		"action_inner": action_inner,
		"list_inner": Layout.inset(list, INNER_PAD),
		"action_button": Layout.center_in(action_inner, Vector2(action_inner.size.x, UIConstants.BUTTON_HEIGHT))
	}


static func card_backplates(content: Rect2) -> Array[Rect2]:
	var layout: Dictionary = build_orderbook_layout(content)
	var result: Array[Rect2] = []
	result.append(layout["weekly"])
	result.append(layout["current"])
	result.append(layout["action"])
	result.append(layout["list"])
	return result


static func inner_padded_rects(content: Rect2) -> Dictionary:
	var layout: Dictionary = build_orderbook_layout(content)
	return {
		"weekly": layout["weekly_inner"],
		"current": layout["current_inner"],
		"action": layout["action_inner"],
		"list": layout["list_inner"]
	}

# ============================================================
# /*=== VILLAGE REQUESTS LAYOUT MAP END ===*/
# ============================================================


# ============================================================
# /*=== CONTROL SIZE HELPERS START ===*/
# ============================================================

static func title_minimum_size(content: Rect2) -> Vector2:
	return Vector2(minf(CONTENT_W, content.size.x), HEADER_H)


static func section_label_minimum_size(content: Rect2) -> Vector2:
	return Vector2(minf(CONTENT_W, content.size.x), SECTION_LABEL_H)


static func weekly_contract_minimum_size(content: Rect2) -> Vector2:
	var layout: Dictionary = build_orderbook_layout(content)
	return Vector2(layout["weekly_inner"].size.x, WEEKLY_LABEL_H)


static func current_request_minimum_size(content: Rect2) -> Vector2:
	var layout: Dictionary = build_orderbook_layout(content)
	return Vector2(layout["current_inner"].size.x, CURRENT_LABEL_H)


static func action_button_minimum_size() -> Vector2:
	return Vector2(ACTION_BUTTON_W, UIConstants.BUTTON_HEIGHT)


static func request_list_rect(content: Rect2) -> Rect2:
	var layout: Dictionary = build_orderbook_layout(content)
	var inner: Rect2 = layout["list_inner"]
	return Rect2(inner.position, Vector2(inner.size.x, REQUEST_LIST_H))


static func request_list_minimum_size(content: Rect2) -> Vector2:
	return request_list_rect(content).size


static func request_card_minimum_size(content: Rect2) -> Vector2:
	var list_rect: Rect2 = request_list_rect(content)
	return Vector2(list_rect.size.x, UIConstants.REQUEST_CARD_HEIGHT)


static func support_label_minimum_size(content: Rect2) -> Vector2:
	return Vector2(minf(CONTENT_W, content.size.x), SUPPORT_LABEL_H)


static func logbook_minimum_size(content: Rect2) -> Vector2:
	return Vector2(minf(CONTENT_W, content.size.x), LOGBOOK_H)


static func action_button_rect(content: Rect2) -> Rect2:
	var layout: Dictionary = build_orderbook_layout(content)
	return layout["action_button"]

# ============================================================
# /*=== CONTROL SIZE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== APPLY LAYOUT START ===*/
# ============================================================

static func apply_layout(controls: Dictionary, content: Rect2) -> void:
	var panel: Control = _control_or_null(controls, "market_panel")
	if panel != null:
		panel.position = panel_position(content.position)
		panel.custom_minimum_size = panel_size(content.size)
		panel.add_theme_constant_override("separation", int(UIConstants.INNER_GAP))

	_set_minimum_size(controls, "market_title", title_minimum_size(content))
	_set_minimum_size(controls, "weekly_label", weekly_contract_minimum_size(content))
	_set_minimum_size(controls, "order_detail_label", current_request_minimum_size(content))
	_set_minimum_size(controls, "accept_button", action_button_minimum_size())
	_set_minimum_size(controls, "fulfill_button", action_button_minimum_size())
	_set_minimum_size(controls, "crate_button", action_button_minimum_size())
	_set_minimum_size(controls, "order_scroll", request_list_minimum_size(content))
	_set_minimum_size(controls, "inventory_label", support_label_minimum_size(content))
	_set_minimum_size(controls, "relationship_label", support_label_minimum_size(content))
	_set_minimum_size(controls, "logbook_label", logbook_minimum_size(content))

	var order_buttons: Array = Array(controls.get("order_buttons", []))
	for item in order_buttons:
		if item is Control:
			(item as Control).custom_minimum_size = request_card_minimum_size(content)


static func _set_minimum_size(controls: Dictionary, key: String, size: Vector2) -> void:
	var control: Control = _control_or_null(controls, key)
	if control != null:
		control.custom_minimum_size = size


static func _control_or_null(controls: Dictionary, key: String) -> Control:
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
	var selected: Dictionary = OrderSystem.order_at(selected_index, accepted_orders, order_offers)
	if selected.is_empty():
		return "📋 No request selected

Available requests will show here when villagers post them."

	var accepted: bool = OrderSystem.selected_order_is_accepted(selected_index, accepted_orders)
	var status: String = "✅ ACTIVE REQUEST" if accepted else "🆕 NEW OFFER"
	var customer: String = OrderSystem.short_customer_name(String(selected.get("customer", "Customer")))
	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = _display_variety_short(int(selected.get("variety", -1)), varieties)
	var label: String = String(selected.get("label", "Fresh figs"))
	var reward: int = int(selected.get("reward", 0))
	var patience: int = int(selected.get("patience", 0))
	var action_line: String = "Ready when packed." if accepted else "Accept when your pantry can handle it."

	return "%s
%s

%sx %s figs
%s

💰 $%s      ⏳ %s left
%s" % [
		status,
		customer,
		quantity,
		variety_name,
		label,
		reward,
		OrderSystem.day_count_text(patience),
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
	var selected: Dictionary = OrderSystem.order_at(index, accepted_orders, order_offers)
	if selected.is_empty():
		return ""

	var accepted: bool = OrderSystem.selected_order_is_accepted(index, accepted_orders)
	var status_icon: String = "✅" if accepted else "🆕"
	var customer: String = OrderSystem.short_customer_name(String(selected.get("customer", "Customer")))
	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = _display_variety_short(int(selected.get("variety", -1)), varieties)
	var reward: int = int(selected.get("reward", 0))
	var patience: int = int(selected.get("patience", 0))
	var time_text: String = OrderSystem.day_count_text(patience) if accepted else "review"

	return "%s %s
%sx %s figs   ?   $%s   ?   %s" % [
		status_icon,
		customer,
		quantity,
		variety_name,
		reward,
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
