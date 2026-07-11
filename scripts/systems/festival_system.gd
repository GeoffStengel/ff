# ============================================================
# /*=== FESTIVAL SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# FestivalSystem
# ------------------------------------------------------------
# Owns pure weekly table goals, timing checks, resolution math,
# and equivalent festival status text.
#
# Does NOT:
# - Mutate gameplay state directly
# - Touch scene nodes
# - Play sounds, show messages, or refresh UI
# ============================================================


# ============================================================
# /*=== FESTIVAL GOALS START ===*/
# ============================================================

static func goal_for_week(festival_week: int, reputation: int = 0, _current_balance_data: Dictionary = {}) -> int:
	var scaled_week: int = mini(festival_week, 8)
	return clampi(20 + scaled_week * 4 + reputation * 2, 24, 60)


static func days_left(day: int, festival_length: int) -> int:
	var elapsed: int = (day - 1) % festival_length
	return festival_length - elapsed


static func should_resolve(day: int, festival_length: int) -> bool:
	return (day - 1) % festival_length == 0

# ============================================================
# /*=== FESTIVAL GOALS END ===*/
# ============================================================


# ============================================================
# /*=== FESTIVAL RESOLUTION START ===*/
# ============================================================

static func resolve_week(state: Dictionary) -> Dictionary:
	var week: int = int(state.get("festival_week", 1))
	var goal: int = int(state.get("festival_goal", 24))
	var progress: int = int(state.get("festival_progress", 0))
	var reputation: int = int(state.get("reputation", 0))
	var completed: bool = progress >= goal
	var overflow: int = maxi(0, progress - goal)
	var coins_delta: int = 0
	var reputation_delta: int = 0
	var compost_delta: int = 0

	if completed:
		coins_delta = 30 + week * 8 + overflow * 2
		reputation_delta = 2
		compost_delta = 1

	var next_week: int = week + 1
	var next_reputation: int = reputation + reputation_delta

	return {
		"completed": completed,
		"overflow": overflow,
		"coins_delta": coins_delta,
		"reputation_delta": reputation_delta,
		"compost_delta": compost_delta,
		"next_week": next_week,
		"next_goal": goal_for_week(next_week, next_reputation),
		"next_progress": 0,
		"log_text": resolution_log_text(completed, progress, goal, coins_delta),
		"message_text": resolution_message_text(completed, progress, goal, coins_delta)
	}

# ============================================================
# /*=== FESTIVAL RESOLUTION END ===*/
# ============================================================


# ============================================================
# /*=== FESTIVAL TEXT START ===*/
# ============================================================

static func festival_text(festival_week: int, festival_progress: int, festival_goal: int, days_left_value: int) -> String:
	return "🍽 Weekly Table W%s  %s/%s figs  %s days\nOrders, jam, crates count. Bonus only." % [festival_week, festival_progress, festival_goal, days_left_value]


static func resolution_log_text(completed: bool, progress: int, goal: int, payout: int) -> String:
	if completed:
		return "Weekly table met: %s/%s figs, +$%s, Trust +2." % [progress, goal, payout]
	return "Weekly table ended: %s/%s figs. No Trust loss." % [progress, goal]


static func resolution_message_text(completed: bool, progress: int, goal: int, payout: int) -> String:
	if completed:
		return "Weekly table complete: +$%s, compost, Trust." % payout
	return "Weekly table ended %s/%s. No Trust loss." % [progress, goal]

# ============================================================
# /*=== FESTIVAL TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FESTIVAL SYSTEM FILE END ===*/
# ============================================================
