extends RefCounted

static func make_order_offer(templates: Array[Dictionary], reputation: int, relationships: Dictionary) -> Dictionary:
	var pick: Dictionary = templates[randi_range(0, templates.size() - 1)]
	var variety_index: int = int(pick["variety"])
	var need: int = randi_range(4 + reputation, 7 + reputation * 2)
	var customer_name: String = String(pick["customer"])
	var reward: int = need * 4 + randi_range(6, 14) + maxi(0, variety_index) * 4 + customer_bonus(customer_name, relationships)
	return {
		"customer": customer_name,
		"label": String(pick["label"]),
		"need": need,
		"variety": variety_index,
		"reward": reward,
		"patience": 4,
		"accepted": false
	}


static func customer_bonus(customer: String, relationships: Dictionary) -> int:
	return int(floor(float(int(relationships.get(customer, 0))) / 2.0)) * 3


static func order_text(selected_index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary], varieties: Array[Dictionary]) -> String:
	var selected: Dictionary = order_at(selected_index, accepted_orders, order_offers)
	if selected.is_empty():
		return "📋 No orders posted. Check tomorrow."
	var variety_index: int = int(selected["variety"])
	var want: String = "mixed"
	if variety_index >= 0:
		want = String(varieties[variety_index]["short"])
	var status: String = "Offer: safe to ignore"
	if selected_order_is_accepted(selected_index, accepted_orders):
		status = "Accepted: %s left" % day_count_text(int(selected["patience"]))
	return "📋 %s\n%s - %s\nNeed %s %s  |  $%s" % [status, short_customer_name(String(selected["customer"])), String(selected["label"]), int(selected["need"]), want, int(selected["reward"])]


static func order_button_text(index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary], varieties: Array[Dictionary]) -> String:
	var selected: Dictionary = order_at(index, accepted_orders, order_offers)
	if selected.is_empty():
		return ""
	var prefix: String = "Offer"
	var timer_text: String = "browse safely"
	if index < accepted_orders.size():
		prefix = "Accepted"
		timer_text = "%s left" % day_count_text(int(selected["patience"]))
	var variety_index: int = int(selected["variety"])
	var want: String = "mixed"
	if variety_index >= 0:
		want = String(varieties[variety_index]["short"])
	return "%s ? %s ? %s %s ? $%s ? %s" % [prefix, short_customer_name(String(selected["customer"])), int(selected["need"]), want, int(selected["reward"]), timer_text]


static func order_at(index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary]) -> Dictionary:
	if index < 0:
		return {}
	if index < accepted_orders.size():
		return accepted_orders[index]
	var offer_index: int = index - accepted_orders.size()
	if offer_index >= 0 and offer_index < order_offers.size():
		return order_offers[offer_index]
	return {}


static func order_count(accepted_orders: Array[Dictionary], order_offers: Array[Dictionary]) -> int:
	return accepted_orders.size() + order_offers.size()


static func selected_order_is_accepted(selected_index: int, accepted_orders: Array[Dictionary]) -> bool:
	return selected_index >= 0 and selected_index < accepted_orders.size()


static func can_accept_selected_order(selected_index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary]) -> bool:
	if selected_order_is_accepted(selected_index, accepted_orders):
		return false
	if accepted_orders.size() >= 5:
		return false
	return not order_at(selected_index, accepted_orders, order_offers).is_empty()


static func can_fulfill_selected_order(selected_index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary]) -> bool:
	return selected_order_is_accepted(selected_index, accepted_orders) and not order_at(selected_index, accepted_orders, order_offers).is_empty()


static func normalize_selected_order(selected_index: int, accepted_orders: Array[Dictionary], order_offers: Array[Dictionary]) -> int:
	var total: int = order_count(accepted_orders, order_offers)
	if total <= 0:
		return 0
	return clampi(selected_index, 0, total - 1)


static func day_count_text(count: int) -> String:
	if count == 1:
		return "1 day"
	return "%s days" % count


static func short_customer_name(customer: String) -> String:
	match customer:
		"Mara the baker":
			return "Mara"
		"Oren the innkeeper":
			return "Oren"
		"Sel the jam maker":
			return "Sel"
		"Niko the chef":
			return "Niko"
		"Tavi from the festival":
			return "Tavi"
	return customer
