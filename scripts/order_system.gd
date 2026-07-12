# ============================================================
# /*=== ORDER SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

const EconomySystem = preload("res://scripts/systems/economy_system.gd")
const RelationshipSystem = preload("res://scripts/systems/relationship_system.gd")

# ============================================================
# OrderSystem
# ------------------------------------------------------------
# Creates, formats, and validates customer orders.
#
# Design goal:
# Make each order read like a clean delivery-app card:
# - Status badge
# - Customer name
# - Requested item
# - Quantity
# - Reward
# - Time left / action hint
# ============================================================


# ============================================================
# ORDER CREATION
# ============================================================

static func make_order_offer(
	templates: Array[Dictionary],
	reputation: int,
	relationships: Dictionary
) -> Dictionary:
	if templates.is_empty():
		return {}

	var pick: Dictionary = templates[randi_range(0, templates.size() - 1)]
	var variety_index: int = int(pick.get("variety", -1))
	var customer_name: String = String(pick.get("customer", "Customer"))

	var need: int = randi_range(4 + reputation, 7 + reputation * 2)
	var reward: int = EconomySystem.order_reward(
		need,
		variety_index,
		randi_range(6, 14),
		RelationshipSystem.bonus_for_customer(relationships, customer_name)
	)

	return {
		"customer": customer_name,
		"label": String(pick.get("label", "Fresh figs")),
		"need": need,
		"variety": variety_index,
		"reward": reward,
		"patience": 4,
		"accepted": false
	}


# ============================================================
# ORDER DETAILS PANEL TEXT
# ------------------------------------------------------------
# This is the larger text shown when an order is selected.
# Think of it like the expanded DoorDash/Uber Eats order view.
# ============================================================

static func order_text(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary],
	varieties: Array[Dictionary]
) -> String:
	var selected: Dictionary = order_at(selected_index, accepted_orders, order_offers)

	if selected.is_empty():
		return "📋 Order Book\n\nNo orders posted right now.\nCheck back tomorrow."

	var accepted: bool = selected_order_is_accepted(selected_index, accepted_orders)
	var status: String = "ACTIVE ORDER" if accepted else "NEW OFFER"
	var action_hint: String = "Fulfill this order before time runs out." if accepted else "Review this offer, then accept if it looks good."
	var timer_text: String = day_count_text(int(selected.get("patience", 0))) + " left"
	var customer: String = short_customer_name(String(selected.get("customer", "Customer")))
	var item_label: String = String(selected.get("label", "Fresh figs"))
	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = variety_short_name(int(selected.get("variety", -1)), varieties)
	var reward: int = int(selected.get("reward", 0))

	return (
		"📋 %s\n\n" % status
		+ "Customer\n"
		+ "  %s\n\n" % customer
		+ "Order\n"
		+ "  %sx %s figs\n" % [quantity, variety_name]
		+ "  %s\n\n" % item_label
		+ "Payout\n"
		+ "  $%s\n\n" % reward
		+ "Time\n"
		+ "  %s\n\n" % timer_text
		+ "%s" % action_hint
	)


# ============================================================
# /*=== ORDER PAGER CARD TEXT START ===*/
# ------------------------------------------------------------
# Compact two-line text for the single Available Request card.
# The pager already handles browsing, so instructional filler
# like "Tap to review" is unnecessary.
# ============================================================

static func order_button_text(
	index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary],
	varieties: Array[Dictionary]
) -> String:
	var selected: Dictionary = order_at(
		index,
		accepted_orders,
		order_offers
	)

	if selected.is_empty():
		return ""

	var accepted: bool = selected_order_is_accepted(
		index,
		accepted_orders
	)

	var status_icon: String = "✅" if accepted else "🆕"
	var status_text: String = "ACCEPTED" if accepted else "NEW"

	var customer: String = short_customer_name(
		String(selected.get("customer", "Customer"))
	)

	var quantity: int = int(selected.get("need", 0))
	var variety_name: String = variety_short_name(
		int(selected.get("variety", -1)),
		varieties
	)

	var reward: int = int(selected.get("reward", 0))
	var patience: int = int(selected.get("patience", 0))

	var footer_text: String = (
		day_count_text(patience) + " left"
		if accepted
		else "Review"
	)

	return "%s %s  👤 %s  •  $%s\n%s× %s figs  •  %s" % [
		status_icon,
		status_text,
		customer,
		reward,
		quantity,
		variety_name,
		footer_text
	]

# ============================================================
# /*=== ORDER PAGER CARD TEXT END ===*/
# ============================================================

# ============================================================
# ORDER LOOKUP HELPERS
# ============================================================

static func order_at(
	index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> Dictionary:
	if index < 0:
		return {}

	if index < accepted_orders.size():
		return accepted_orders[index]

	var offer_index: int = index - accepted_orders.size()

	if offer_index >= 0 and offer_index < order_offers.size():
		return order_offers[offer_index]

	return {}


static func order_count(
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> int:
	return accepted_orders.size() + order_offers.size()


static func selected_order_is_accepted(
	selected_index: int,
	accepted_orders: Array[Dictionary]
) -> bool:
	return selected_index >= 0 and selected_index < accepted_orders.size()


# ============================================================
# ORDER ACTION RULES
# ============================================================

static func can_accept_selected_order(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> bool:
	if selected_order_is_accepted(selected_index, accepted_orders):
		return false

	if accepted_orders.size() >= 5:
		return false

	return not order_at(selected_index, accepted_orders, order_offers).is_empty()


static func can_fulfill_selected_order(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> bool:
	return (
		selected_order_is_accepted(selected_index, accepted_orders)
		and not order_at(selected_index, accepted_orders, order_offers).is_empty()
	)


static func normalize_selected_order(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> int:
	var total: int = order_count(accepted_orders, order_offers)

	if total <= 0:
		return 0

	return clampi(selected_index, 0, total - 1)


# ============================================================
# /*=== ORDER STATE RESULTS START ===*/
# ============================================================

static func accept_selected_order(
	selected_index: int,
	accepted_orders: Array[Dictionary],
	order_offers: Array[Dictionary]
) -> Dictionary:
	if selected_order_is_accepted(selected_index, accepted_orders):
		return {"ok": false, "reason": "already_accepted"}

	if not can_accept_selected_order(selected_index, accepted_orders, order_offers):
		return {"ok": false, "reason": "not_available"}

	var offer_index: int = selected_index - accepted_orders.size()
	if offer_index < 0 or offer_index >= order_offers.size():
		return {"ok": false, "reason": "already_accepted"}

	var selected: Dictionary = order_offers[offer_index]
	selected["accepted"] = true
	selected["patience"] = 4
	order_offers.remove_at(offer_index)
	accepted_orders.append(selected)

	return {
		"ok": true,
		"selected": selected,
		"selected_order_index": accepted_orders.size() - 1
	}


static func process_order_day(
	accepted_orders: Array[Dictionary],
	relationships: Dictionary,
	reputation: int
) -> Dictionary:
	var kept_orders: Array[Dictionary] = []
	var expired_names: Array[String] = []
	var updated_relationships: Dictionary = relationships.duplicate(true)

	for order_data in accepted_orders:
		order_data["patience"] = int(order_data.get("patience", 0)) - 1

		if int(order_data["patience"]) <= 0:
			var customer: String = String(order_data.get("customer", "Customer"))
			reputation = maxi(0, reputation - 1)
			updated_relationships = RelationshipSystem.apply_change(updated_relationships, customer, -1)
			expired_names.append(short_customer_name(customer))
		else:
			kept_orders.append(order_data)

	return {
		"accepted_orders": kept_orders,
		"expired_names": expired_names,
		"reputation": reputation,
		"relationships": updated_relationships
	}

# ============================================================
# /*=== ORDER STATE RESULTS END ===*/
# ============================================================


# ============================================================
# DISPLAY TEXT HELPERS
# ============================================================

static func day_count_text(count: int) -> String:
	if count == 1:
		return "1 day"

	return "%s days" % count


static func variety_short_name(
	variety_index: int,
	varieties: Array[Dictionary]
) -> String:
	if variety_index < 0:
		return "mixed"

	if variety_index >= varieties.size():
		return "mixed"

	return String(varieties[variety_index].get("short", "mixed"))


static func short_customer_name(customer: String) -> String:
	return RelationshipSystem.short_customer_name(customer)
# ============================================================
# /*=== ORDER SYSTEM FILE END ===*/
# ============================================================
