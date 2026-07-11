# ============================================================
# /*=== RELATIONSHIP SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

const EconomySystem = preload("res://scripts/systems/economy_system.gd")

# ============================================================
# RelationshipSystem
# ------------------------------------------------------------
# Owns pure villager score lookups, score changes, relationship
# reward modifiers, short names, summaries, and milestone deltas.
#
# Does NOT:
# - Mutate main.gd state directly
# - Touch scene nodes
# - Play sounds, show messages, or refresh UI
# ============================================================


# ============================================================
# /*=== SCORE HELPERS START ===*/
# ============================================================

static func score_for(relationships: Dictionary, customer: String) -> int:
	return int(relationships.get(customer, 0))


static func apply_change(relationships: Dictionary, customer: String, amount: int) -> Dictionary:
	var updated: Dictionary = relationships.duplicate(true)
	updated[customer] = maxi(0, score_for(updated, customer) + amount)
	return updated


static func order_completion_gain(patience: int) -> int:
	var gain: int = 1
	if patience >= 3:
		gain += 1
	return gain


static func bonus_for_customer(relationships: Dictionary, customer: String) -> int:
	return int(floor(float(score_for(relationships, customer)) / 2.0)) * 3


static func relationship_level(score: int) -> int:
	return score


static func relationship_label(score: int) -> String:
	if score <= 0:
		return "New"
	return "Lv %s" % relationship_level(score)

# ============================================================
# /*=== SCORE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== CUSTOMER NAME HELPERS START ===*/
# ============================================================

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

# ============================================================
# /*=== CUSTOMER NAME HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== DISPLAY FORMATTING START ===*/
# ============================================================

static func relationship_summary(relationships: Dictionary) -> String:
	var best_name: String = "No favorites yet"
	var best_score: int = -1
	for customer in relationships.keys():
		var score: int = int(relationships[customer])
		if score > best_score:
			best_score = score
			best_name = String(customer)
	if best_score <= 0:
		return "🤝 Friends: complete accepted orders"
	return "🤝 Best: %s  Lv %s" % [short_customer_name(best_name), best_score]

# ============================================================
# /*=== DISPLAY FORMATTING END ===*/
# ============================================================


# ============================================================
# /*=== MILESTONE REWARDS START ===*/
# ============================================================

static func milestone_result(customer: String, score: int) -> Dictionary:
	if score != 3 and score != 6:
		return _empty_milestone()

	if score == 6:
		return {
			"message": "%s sent a %s coin thank-you purse." % [short_customer_name(customer), EconomySystem.RELATIONSHIP_PURSE_REWARD],
			"coins_delta": EconomySystem.RELATIONSHIP_PURSE_REWARD,
			"compost_delta": 0,
			"water_to_max": false,
			"cuttings_delta": [0, 0, 0, 0],
			"festival_progress_delta": 0
		}

	var result: Dictionary = _empty_milestone()
	match customer:
		"Mara the baker":
			result["compost_delta"] = 2
			result["message"] = "Mara shared bakery compost."
		"Oren the innkeeper":
			result["water_to_max"] = true
			result["message"] = "Oren filled the barrel."
		"Sel the jam maker":
			result["cuttings_delta"] = [0, 2, 0, 0]
			result["message"] = "Sel saved Black Madeira cuttings for you."
		"Niko the chef":
			result["cuttings_delta"] = [0, 0, 2, 0]
			result["message"] = "Niko found White Madeira #1 cuttings."
		"Tavi from the festival":
			result["cuttings_delta"] = [0, 0, 0, 3]
			result["festival_progress_delta"] = 6
			result["message"] = "Tavi boosted the festival table with RdB cuttings."
	return result


static func _empty_milestone() -> Dictionary:
	return {
		"message": "",
		"coins_delta": 0,
		"compost_delta": 0,
		"water_to_max": false,
		"cuttings_delta": [0, 0, 0, 0],
		"festival_progress_delta": 0
	}

# ============================================================
# /*=== MILESTONE REWARDS END ===*/
# ============================================================

# ============================================================
# /*=== RELATIONSHIP SYSTEM FILE END ===*/
# ============================================================
