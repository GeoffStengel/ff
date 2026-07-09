extends RefCounted

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


static func normalize_plot(source: Variant, variety_count: int) -> Dictionary:
	var plot: Dictionary = default_plot()
	if typeof(source) != TYPE_DICTIONARY:
		return plot
	var loaded: Dictionary = source as Dictionary
	for key in plot.keys():
		if loaded.has(key):
			plot[key] = loaded[key]
	plot["variety"] = clampi(int(plot["variety"]), 0, maxi(0, variety_count - 1))
	plot["stage"] = clampi(int(plot["stage"]), 0, 3)
	plot["progress"] = maxi(0, int(plot["progress"]))
	plot["moisture"] = clampi(int(plot["moisture"]), 0, 2)
	plot["quality"] = maxi(0, int(plot["quality"]))
	plot["ripe_days"] = maxi(0, int(plot["ripe_days"]))
	plot["planted"] = bool(plot["planted"])
	plot["watered"] = bool(plot["watered"])
	plot["bonus"] = bool(plot["bonus"])
	plot["composted"] = bool(plot["composted"])
	plot["harvested_marker"] = bool(plot.get("harvested_marker", false))
	return plot


static func read_plots_array(source: Variant, grid_h: int, grid_w: int, variety_count: int) -> Array:
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


static func read_order_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(source) == TYPE_ARRAY:
		var source_array: Array = source as Array
		for item in source_array:
			if typeof(item) == TYPE_DICTIONARY:
				result.append(item as Dictionary)
	return result


static func read_string_array(source: Variant, max_items: int) -> Array[String]:
	var result: Array[String] = []
	if typeof(source) == TYPE_ARRAY:
		var source_array: Array = source as Array
		for item in source_array:
			if result.size() >= max_items:
				break
			result.append(String(item))
	return result


static func read_int_array(source: Variant, expected_size: int, fill_value: int) -> Array[int]:
	var result: Array[int] = []
	if typeof(source) == TYPE_ARRAY:
		var source_array: Array = source as Array
		for i in expected_size:
			if i < source_array.size():
				result.append(int(source_array[i]))
			else:
				result.append(fill_value)
	else:
		for i in expected_size:
			result.append(fill_value)
	return result
