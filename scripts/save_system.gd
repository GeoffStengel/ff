# ============================================================
# /*=== SAVE SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# SaveSystem
# ------------------------------------------------------------
# Handles safe/default save data helpers.
#
# Goal:
# main.gd should not care how save data is cleaned up.
# It should only ask:
# - Give me a default plot.
# - Normalize this loaded plot.
# - Read this array safely.
#
# This file should stay "dumb":
# - No scene nodes
# - No UI
# - No gameplay messages
# - No audio
# ============================================================


# ============================================================
# PLOT DEFAULTS
# ------------------------------------------------------------
# This is the canonical shape of one farm plot.
# Any new save field for plots should be added here first.
# ============================================================

static func default_plot() -> Dictionary:
	return {
		"planted": false,
		"variety": 0,
		"stage": 0,
		"progress": 0,
		"watered": false,
		"moisture": 0,
		"quality": 1,
		"bonus": false,
		"composted": false,
		"ripe_days": 0,
		"harvested_marker": false
	}


# ============================================================
# PLOT NORMALIZATION
# ------------------------------------------------------------
# Converts loaded save data into a safe plot Dictionary.
#
# Why this matters:
# Old saves, corrupted saves, or missing fields should not crash
# the game. They should fall back to safe defaults.
# ============================================================

static func normalize_plot(source: Variant, variety_count: int) -> Dictionary:
	var plot: Dictionary = default_plot()

	if typeof(source) != TYPE_DICTIONARY:
		return plot

	var loaded: Dictionary = source as Dictionary

	# Copy only known plot fields.
	# This prevents weird/old/debug save keys from leaking into gameplay.
	for key in plot.keys():
		if loaded.has(key):
			plot[key] = loaded[key]

	# Clamp numeric values into valid gameplay ranges.
	plot["variety"] = clampi(int(plot["variety"]), 0, maxi(0, variety_count - 1))
	plot["stage"] = clampi(int(plot["stage"]), 0, 3)
	plot["progress"] = maxi(0, int(plot["progress"]))
	plot["moisture"] = clampi(int(plot["moisture"]), 0, 2)
	plot["quality"] = maxi(0, int(plot["quality"]))
	plot["ripe_days"] = maxi(0, int(plot["ripe_days"]))

	# Force booleans back into true/false.
	plot["planted"] = bool(plot["planted"])
	plot["watered"] = bool(plot["watered"])
	plot["bonus"] = bool(plot["bonus"])
	plot["composted"] = bool(plot["composted"])
	plot["harvested_marker"] = bool(plot.get("harvested_marker", false))

	return plot


# ============================================================
# FARM GRID LOADING
# ------------------------------------------------------------
# Reads the saved 2D plot grid.
#
# Expected shape:
# [
#   [plot, plot, plot],
#   [plot, plot, plot],
#   ...
# ]
#
# If the save grid does not match the current farm size,
# this returns an empty Array so main.gd can rebuild safely.
# ============================================================

static func read_plots_array(
	source: Variant,
	grid_h: int,
	grid_w: int,
	variety_count: int
) -> Array:
	var result: Array = []

	if typeof(source) != TYPE_ARRAY:
		return result

	var source_rows: Array = source as Array

	if source_rows.size() != grid_h:
		return result

	for y in grid_h:
		if typeof(source_rows[y]) != TYPE_ARRAY:
			return []

		var source_row: Array = source_rows[y] as Array

		if source_row.size() != grid_w:
			return []

		var row: Array = []

		for x in grid_w:
			row.append(normalize_plot(source_row[x], variety_count))

		result.append(row)

	return result


# ============================================================
# ORDER LOADING
# ------------------------------------------------------------
# Reads saved order dictionaries.
#
# Note:
# This does not deeply validate order fields yet.
# Later we can add normalize_order() here the same way plots work.
# ============================================================

static func read_order_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if typeof(source) != TYPE_ARRAY:
		return result

	var source_array: Array = source as Array

	for item in source_array:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(item as Dictionary)

	return result


# ============================================================
# STRING ARRAY LOADING
# ------------------------------------------------------------
# Used for logs, recent messages, unlocked names, etc.
#
# max_items prevents huge/corrupted saves from flooding the UI.
# ============================================================

static func read_string_array(source: Variant, max_items: int) -> Array[String]:
	var result: Array[String] = []

	if typeof(source) != TYPE_ARRAY:
		return result

	var source_array: Array = source as Array

	for item in source_array:
		if result.size() >= max_items:
			break

		result.append(String(item))

	return result


# ============================================================
# INTEGER ARRAY LOADING
# ------------------------------------------------------------
# Reads fixed-size integer lists.
#
# Example:
# Inventory counts, crop counts, relationship levels, etc.
#
# If save data is missing or too short, fill_value is used.
# ============================================================

static func read_int_array(
	source: Variant,
	expected_size: int,
	fill_value: int
) -> Array[int]:
	var result: Array[int] = []

	if typeof(source) != TYPE_ARRAY:
		for i in expected_size:
			result.append(fill_value)

		return result

	var source_array: Array = source as Array

	for i in expected_size:
		if i < source_array.size():
			result.append(int(source_array[i]))
		else:
			result.append(fill_value)

	return result


# ============================================================
# /*=== SAVE DATA BUILDER START ===*/
# ------------------------------------------------------------
# Converts current game state into a Dictionary that can be
# written to disk as JSON.
#
# NOTE:
# This function does NOT open files.
# This function does NOT play sounds.
# This function does NOT show messages.
#
# main.gd handles those things.
# ============================================================

static func build_save_data(state: Dictionary) -> Dictionary:
	return {
		"version": 1,

		# ---------- Time ----------
		"day": state["day"],
		"time_left": state["time_left"],

		# ---------- Economy ----------
		"coins": state["coins"],
		"water": state["water"],
		"compost": state["compost"],
		"reputation": state["reputation"],

		# ---------- Settings ----------
		"sound_enabled": state["sound_enabled"],
		"tutorial_index": state["tutorial_index"],

		# ---------- Festival ----------
		"festival_week": state["festival_week"],
		"festival_goal": state["festival_goal"],
		"festival_progress": state["festival_progress"],

		# ---------- Villagers ----------
		"relationships": state["relationships"],

		# ---------- Inventory ----------
		"cuttings": state["cuttings"],
		"fig_bins": state["fig_bins"],
		"jam_jars": state["jam_jars"],
		"mason_jars": state["mason_jars"],

		# ---------- Upgrades ----------
		"recipe_expanded": state["recipe_expanded"],
		"barrel_level": state["barrel_level"],
		"pollinator_garden": state["pollinator_garden"],

		# ---------- Weather ----------
		"current_weather": state["current_weather"],
		"temperature_f": state["temperature_f"],

		# ---------- Orders ----------
		"order_offers": state["order_offers"],
		"accepted_orders": state["accepted_orders"],
		"selected_order_index": state["selected_order_index"],

		# ---------- Log ----------
		"game_log": state["game_log"],

		# ---------- UI ----------
		"selected_variety": state["selected_variety"],
		"current_tool": state["current_tool"],
		"side_tab": state["side_tab"],
		"panel_open": state["panel_open"],

		# ---------- Farmer ----------
		"farmer_x": state["farmer_cell"].x,
		"farmer_y": state["farmer_cell"].y,

		# ---------- Farm ----------
		"plots": state["plots"]
	}

# /*=== SAVE DATA BUILDER END ===*/


# ============================================================
# /*=== SAVE DATA READER START ===*/
# ------------------------------------------------------------
# Safely reads loaded JSON save data into normalized values.
#
# NOTE:
# This does NOT update UI.
# This does NOT play sounds.
# This does NOT refresh orders.
# This does NOT move the farmer visually.
#
# main.gd still handles those game-specific side effects.
# ============================================================

static func read_save_data(
	data: Dictionary,
	current_state: Dictionary,
	variety_count: int,
	weather_count: int,
	grid_w: int,
	grid_h: int,
	day_length: float,
	festival_goal_limit: int
) -> Dictionary:
	var result: Dictionary = {}

	# ---------- Time ----------
	result["day"] = int(data.get("day", current_state["day"]))
	result["time_left"] = float(data.get("time_left", day_length))

	# ---------- Economy ----------
	result["coins"] = int(data.get("coins", current_state["coins"]))
	result["water"] = int(data.get("water", current_state["water"]))
	result["compost"] = int(data.get("compost", current_state["compost"]))
	result["reputation"] = int(data.get("reputation", current_state["reputation"]))

	# ---------- Settings ----------
	result["sound_enabled"] = bool(data.get("sound_enabled", current_state["sound_enabled"]))
	result["tutorial_index"] = clampi(int(data.get("tutorial_index", current_state["tutorial_index"])), 0, 5)

	# ---------- Festival ----------
	result["festival_week"] = int(data.get("festival_week", current_state["festival_week"]))
	result["festival_goal"] = mini(int(data.get("festival_goal", current_state["festival_goal"])), festival_goal_limit)
	result["festival_progress"] = int(data.get("festival_progress", current_state["festival_progress"]))

	# ---------- Relationships ----------
	var loaded_relationships: Variant = data.get("relationships", current_state["relationships"])
	result["relationships"] = current_state["relationships"]
	if typeof(loaded_relationships) == TYPE_DICTIONARY:
		result["relationships"] = loaded_relationships as Dictionary

	# ---------- Inventory ----------
	result["cuttings"] = read_int_array(data.get("cuttings", current_state["cuttings"]), variety_count, 0)
	result["fig_bins"] = read_int_array(data.get("fig_bins", current_state["fig_bins"]), variety_count, 0)
	result["jam_jars"] = int(data.get("jam_jars", current_state["jam_jars"]))
	result["mason_jars"] = int(data.get("mason_jars", current_state["mason_jars"]))

	# ---------- Upgrades ----------
	result["recipe_expanded"] = bool(data.get("recipe_expanded", current_state["recipe_expanded"]))
	result["barrel_level"] = int(data.get("barrel_level", current_state["barrel_level"]))
	result["pollinator_garden"] = bool(data.get("pollinator_garden", current_state["pollinator_garden"]))

	# ---------- Weather ----------
	result["current_weather"] = clampi(int(data.get("current_weather", current_state["current_weather"])), 0, maxi(0, weather_count - 1))
	result["temperature_f"] = int(data.get("temperature_f", current_state["temperature_f"]))

	# ---------- Orders ----------
	result["order_offers"] = read_order_array(data.get("order_offers", []))
	result["accepted_orders"] = read_order_array(data.get("accepted_orders", []))
	result["selected_order_index"] = int(data.get("selected_order_index", current_state["selected_order_index"]))

	# Legacy save support: older saves had one "order" Dictionary.
	if result["order_offers"].is_empty() and result["accepted_orders"].is_empty():
		var legacy_order: Variant = data.get("order", {})
		if typeof(legacy_order) == TYPE_DICTIONARY:
			var legacy_dict: Dictionary = legacy_order as Dictionary
			if not legacy_dict.is_empty():
				legacy_dict["accepted"] = false
				result["order_offers"].append(legacy_dict)

	# ---------- Log ----------
	result["game_log"] = read_string_array(data.get("game_log", current_state["game_log"]), 8)

	# ---------- UI ----------
	result["selected_variety"] = clampi(int(data.get("selected_variety", current_state["selected_variety"])), 0, maxi(0, variety_count - 1))
	result["current_tool"] = int(data.get("current_tool", current_state["current_tool"]))
	result["side_tab"] = clampi(int(data.get("side_tab", current_state["side_tab"])), 0, 4)
	result["panel_open"] = bool(data.get("panel_open", current_state["panel_open"]))

	# ---------- Farm ----------
	result["plots"] = read_plots_array(data.get("plots", current_state["plots"]), grid_h, grid_w, variety_count)

	# ---------- Farmer ----------
	result["farmer_cell"] = Vector2i(
		clampi(int(data.get("farmer_x", current_state["farmer_cell"].x)), 0, grid_w - 1),
		clampi(int(data.get("farmer_y", current_state["farmer_cell"].y)), 0, grid_h - 1)
	)

	return result

# /*=== SAVE DATA READER END ===*/
# ============================================================
# /*=== SAVE SYSTEM FILE END ===*/
# ============================================================
