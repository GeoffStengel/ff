# ============================================================
# /*=== ECONOMY SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# EconomySystem
# ------------------------------------------------------------
# Owns pure pricing, affordability, reward, sale, and upgrade
# calculations.
#
# Does NOT:
# - Mutate inventory
# - Mutate gameplay state
# - Touch scene nodes
# - Play sounds, show messages, or refresh UI
# ============================================================


# ============================================================
# /*=== PRICE CONSTANTS START ===*/
# ============================================================

const COMPOST_BAG_COST := 7
const COMPOST_BAG_QUANTITY := 2
const MASON_JARS_COST := 6
const MASON_JARS_QUANTITY := 3
const JAM_UNIT_PRICE := 18
const JAM_FESTIVAL_CREDIT := 5
const BARREL_BASE_COST := 18
const BARREL_LEVEL_COST := 10
const BARREL_MAX_LEVEL := 3
const BARREL_WATER_BONUS := 4
const POLLINATOR_GARDEN_COST := 24
const RELATIONSHIP_PURSE_REWARD := 25

# ============================================================
# /*=== PRICE CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== AFFORDABILITY START ===*/
# ============================================================

static func can_afford(coins: int, cost: int) -> bool:
	return coins >= cost


static func purchase_result(coins: int, cost: int, quantity: int = 1) -> Dictionary:
	if not can_afford(coins, cost):
		return {"ok": false, "reason": "not_enough_coins", "coins": coins, "cost": cost, "quantity": quantity}
	return {"ok": true, "coins": coins - cost, "cost": cost, "quantity": quantity}

# ============================================================
# /*=== AFFORDABILITY END ===*/
# ============================================================


# ============================================================
# /*=== SALES AND VALUE START ===*/
# ============================================================

static func sale_result(coins: int, unit_price: int, quantity: int) -> Dictionary:
	var payout: int = unit_price * quantity
	return {"coins": coins + payout, "payout": payout, "quantity": quantity}


static func jam_sale_value(jam_count: int, unit_price: int = JAM_UNIT_PRICE) -> int:
	return jam_count * unit_price


static func jam_festival_credit(jam_count: int) -> int:
	return jam_count * JAM_FESTIVAL_CREDIT


static func crate_value(fig_bins: Array[int], varieties: Array[Dictionary]) -> int:
	var payout: int = 0
	for i in fig_bins.size():
		payout += int(fig_bins[i]) * int(varieties[i]["value"])
	return payout

# ============================================================
# /*=== SALES AND VALUE END ===*/
# ============================================================


# ============================================================
# /*=== SHOP AND UPGRADES START ===*/
# ============================================================

static func cutting_cost(varieties: Array[Dictionary], variety_index: int) -> int:
	return int(varieties[variety_index]["seed_cost"])


static func barrel_upgrade_cost(barrel_level: int) -> int:
	return BARREL_BASE_COST + barrel_level * BARREL_LEVEL_COST


static func can_upgrade_barrel(barrel_level: int) -> bool:
	return barrel_level < BARREL_MAX_LEVEL


static func pollinator_garden_cost() -> int:
	return POLLINATOR_GARDEN_COST


static func max_water(base_max_water: int, barrel_level: int) -> int:
	return base_max_water + barrel_level * BARREL_WATER_BONUS

# ============================================================
# /*=== SHOP AND UPGRADES END ===*/
# ============================================================


# ============================================================
# /*=== ORDER REWARDS START ===*/
# ============================================================

static func order_reward(need: int, variety_index: int, random_bonus: int, relationship_bonus: int) -> int:
	return need * 4 + random_bonus + maxi(0, variety_index) * 4 + relationship_bonus

# ============================================================
# /*=== ORDER REWARDS END ===*/
# ============================================================

# ============================================================
# /*=== ECONOMY SYSTEM FILE END ===*/
# ============================================================
