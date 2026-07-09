# ============================================================
# /*=== CROP SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# CropSystem
# ------------------------------------------------------------
# Handles crop/tree rules only.
#
# main.gd should handle:
# - Input
# - UI updates
# - Sounds
# - Player messages
#
# CropSystem should handle:
# - Can this crop do X?
# - How does this plot grow?
# - What happens to moisture/quality?
# ============================================================


# ============================================================
# /*=== CUTTINGS RULES START ===*/
# ============================================================

static func can_take_cutting(plot: Dictionary, varieties: Array[Dictionary]) -> bool:
	if not bool(plot.get("planted", false)):
		return false

	if int(plot.get("stage", 0)) >= 3:
		return true

	var variety_index: int = _safe_variety_index(plot, varieties)
	var grow_days: int = int(varieties[variety_index].get("grow_days", 1))

	return int(plot.get("progress", 0)) >= grow_days


static func cutting_status_text(plot: Dictionary, varieties: Array[Dictionary]) -> String:
	if can_take_cutting(plot, varieties):
		return "ready with C"

	return "let tree establish first"

# ============================================================
# /*=== CUTTINGS RULES END ===*/
# ============================================================


# ============================================================
# /*=== CROP ACTION RESULTS START ===*/
# ============================================================

static func take_cutting(plot: Dictionary, varieties: Array[Dictionary]) -> Dictionary:
	if not bool(plot.get("planted", false)):
		return {"ok": false, "reason": "empty"}

	if not can_take_cutting(plot, varieties):
		return {"ok": false, "reason": "young"}

	var variety_index: int = _safe_variety_index(plot, varieties)
	plot["progress"] = maxi(0, int(plot.get("progress", 0)) - 1)
	var grow_days: int = maxi(1, int(varieties[variety_index].get("grow_days", 1)))
	var recalculated_stage: int = mini(3, int(floor((float(int(plot["progress"])) / float(grow_days)) * 3.0)))
	plot["stage"] = maxi(2, recalculated_stage)
	plot["ripe_days"] = 0
	plot["bonus"] = false

	return {"ok": true, "variety_index": variety_index}


static func plant_plot(plot: Dictionary, cuttings: Array[int], selected_variety: int, rainy: bool) -> Dictionary:
	if bool(plot.get("planted", false)):
		return {"ok": false, "reason": "occupied"}

	if selected_variety < 0 or selected_variety >= cuttings.size() or cuttings[selected_variety] <= 0:
		return {"ok": false, "reason": "no_cuttings"}

	cuttings[selected_variety] -= 1
	plot["planted"] = true
	plot["variety"] = selected_variety
	plot["stage"] = 0
	plot["progress"] = 0
	plot["watered"] = rainy
	plot["moisture"] = 2 if rainy else 1
	plot["quality"] = 1
	plot["bonus"] = false
	plot["composted"] = false
	plot["ripe_days"] = 0
	plot["harvested_marker"] = false

	return {"ok": true, "variety_index": selected_variety}


static func water_plot(plot: Dictionary, water: int, pollinator_chance: float) -> Dictionary:
	if not bool(plot.get("planted", false)):
		return {"ok": false, "reason": "empty", "water": water, "pollinator_visit": false}

	if bool(plot.get("watered", false)):
		return {"ok": false, "reason": "already_watered", "water": water, "pollinator_visit": false}

	if water <= 0:
		return {"ok": false, "reason": "no_water", "water": water, "pollinator_visit": false}

	water -= 1
	plot["watered"] = true
	plot["moisture"] = 2
	plot["quality"] = int(plot.get("quality", 1)) + 1
	var pollinator_visit: bool = randf() < pollinator_chance
	if pollinator_visit:
		plot["bonus"] = true

	return {"ok": true, "water": water, "pollinator_visit": pollinator_visit}


static func compost_plot(plot: Dictionary, compost: int) -> Dictionary:
	if not bool(plot.get("planted", false)):
		return {"ok": false, "reason": "empty", "compost": compost}

	if bool(plot.get("composted", false)):
		return {"ok": false, "reason": "already_composted", "compost": compost}

	if compost <= 0:
		return {"ok": false, "reason": "no_compost", "compost": compost}

	compost -= 1
	plot["composted"] = true
	plot["quality"] = int(plot.get("quality", 1)) + 2

	return {"ok": true, "compost": compost}


static func harvest_plot(plot: Dictionary, varieties: Array[Dictionary]) -> Dictionary:
	if not bool(plot.get("planted", false)):
		return {"ok": false, "reason": "empty"}

	if int(plot.get("stage", 0)) < 3:
		return {"ok": false, "reason": "not_ripe"}

	var variety_index: int = _safe_variety_index(plot, varieties)
	var ripe_days: int = int(plot.get("ripe_days", 0))
	var ripeness_bonus: int = ripeness_yield_bonus(ripe_days)
	var harvest: int = maxi(1, 2 + int(plot.get("quality", 1)) + int(varieties[variety_index].get("yield_bonus", 0)) + ripeness_bonus)

	if bool(plot.get("bonus", false)):
		harvest += 2

	if bool(plot.get("composted", false)):
		harvest += 1

	plot["planted"] = false
	plot["stage"] = 0
	plot["progress"] = 0
	plot["watered"] = false
	plot["moisture"] = 0
	plot["quality"] = 1
	plot["bonus"] = false
	plot["composted"] = false
	plot["ripe_days"] = 0
	plot["harvested_marker"] = true

	return {"ok": true, "variety_index": variety_index, "harvest": harvest, "ripe_days": ripe_days}


static func ripeness_yield_bonus(ripe_days: int) -> int:
	if ripe_days <= 0:
		return 1
	if ripe_days == 1:
		return 2
	if ripe_days == 2:
		return 0
	return -2

# ============================================================
# /*=== CROP ACTION RESULTS END ===*/
# ============================================================


# ============================================================
# /*=== MOISTURE RULES START ===*/
# ------------------------------------------------------------
# Updates plot moisture after the day changes.
#
# Rules:
# - Watered plots become fully moist.
# - Heat dries soil faster.
# - Other weather dries soil normally.
# ============================================================

static func update_plot_moisture(plot: Dictionary, weather_name: String) -> void:
	var moisture: int = int(plot.get("moisture", 0))

	if bool(plot.get("watered", false)):
		moisture = 2
	elif weather_name == "Heat":
		moisture = maxi(0, moisture - 2)
	else:
		moisture = maxi(0, moisture - 1)

	plot["moisture"] = moisture

# ============================================================
# /*=== MOISTURE RULES END ===*/
# ============================================================


# ============================================================
# /*=== TREE GROWTH RULES START ===*/
# ------------------------------------------------------------
# Advances one planted tree by one day.
#
# Rules:
# - Watered trees gain progress.
# - Compost may add bonus progress.
# - Heat rewards watered trees but punishes dry trees.
# - Stage is derived from progress / grow_days.
# - ripe_days tracks how long a tree has been mature.
# ============================================================

static func advance_tree(
	plot: Dictionary,
	varieties: Array[Dictionary],
	weather_name: String
) -> void:
	if not bool(plot.get("planted", false)):
		return

	if varieties.is_empty():
		return

	var variety_index: int = _safe_variety_index(plot, varieties)
	var old_stage: int = int(plot.get("stage", 0))
	var progress: int = int(plot.get("progress", 0))

	if bool(plot.get("watered", false)):
		progress += 1

		if bool(plot.get("composted", false)) and randf() < 0.35:
			progress += 1

		if weather_name == "Heat":
			plot["quality"] = int(plot.get("quality", 1)) + 1
	else:
		if weather_name == "Heat":
			plot["quality"] = maxi(1, int(plot.get("quality", 1)) - 1)

	plot["progress"] = progress

	var grow_days: int = maxi(1, int(varieties[variety_index].get("grow_days", 1)))
	var stage: int = mini(3, int(floor((float(progress) / float(grow_days)) * 3.0)))

	plot["stage"] = stage

	if stage >= 3:
		if old_stage >= 3:
			plot["ripe_days"] = int(plot.get("ripe_days", 0)) + 1
		else:
			plot["ripe_days"] = 0
	else:
		plot["ripe_days"] = 0

# ============================================================
# /*=== TREE GROWTH RULES END ===*/
# ============================================================

# ============================================================
# /*=== FARM DAY PROCESSING START ===*/
# ------------------------------------------------------------
# Processes all farm plots when a new day begins.
#
# Returns summary counts so main.gd can build messages/UI.
#
# main.gd still handles:
# - Weather rolling
# - Orders
# - Tutorial
# - Festivals
# - Sounds/messages
# ============================================================

static func process_new_day_for_plots(
	plots: Array,
	grid_h: int,
	grid_w: int,
	varieties: Array[Dictionary],
	weather_name: String
) -> Dictionary:
	var result: Dictionary = {
		"grew_count": 0,
		"dried_count": 0,
		"ripened_count": 0,
		"softened_count": 0
	}

	for y in grid_h:
		for x in grid_w:
			var plot: Dictionary = plots[y][x]

			if not bool(plot.get("planted", false)):
				plot["harvested_marker"] = false
				continue

			var old_progress: int = int(plot.get("progress", 0))
			var old_stage: int = int(plot.get("stage", 0))
			var old_moisture: int = int(plot.get("moisture", 0))
			var old_ripe_days: int = int(plot.get("ripe_days", 0))

			if weather_name == "Rain":
				plot["watered"] = true
				plot["moisture"] = 2
				old_moisture = mini(old_moisture, 1)

			advance_tree(plot, varieties, weather_name)
			update_plot_moisture(plot, weather_name)

			if int(plot.get("progress", 0)) > old_progress:
				result["grew_count"] += 1

			if int(plot.get("moisture", 0)) < old_moisture:
				result["dried_count"] += 1

			if old_stage < 3 and int(plot.get("stage", 0)) >= 3:
				result["ripened_count"] += 1
			elif int(plot.get("stage", 0)) >= 3 and int(plot.get("ripe_days", 0)) > old_ripe_days:
				result["softened_count"] += 1

			plot["watered"] = false

	return result

# /*=== FARM DAY PROCESSING END ===*/


# ============================================================
# /*=== FARM SCAN HELPERS START ===*/
# ============================================================

static func has_ripe_tree(plots: Array, grid_h: int, grid_w: int) -> bool:
	for y in grid_h:
		for x in grid_w:
			var plot: Dictionary = plots[y][x]

			if bool(plot.get("planted", false)) and int(plot.get("stage", 0)) >= 3:
				return true

	return false

# ============================================================
# /*=== FARM SCAN HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== INTERNAL SAFETY HELPERS START ===*/
# ------------------------------------------------------------
# Private-ish helpers.
# GDScript does not enforce private functions, so the underscore
# means "please do not call this outside CropSystem."
# ============================================================

static func _safe_variety_index(plot: Dictionary, varieties: Array[Dictionary]) -> int:
	if varieties.is_empty():
		return 0

	return clampi(int(plot.get("variety", 0)), 0, varieties.size() - 1)

# ============================================================
# /*=== INTERNAL SAFETY HELPERS END ===*/
# ============================================================
# ============================================================
# /*=== CROP SYSTEM FILE END ===*/
# ============================================================
