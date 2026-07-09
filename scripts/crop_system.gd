extends RefCounted

static func can_take_cutting(plot: Dictionary, varieties: Array[Dictionary]) -> bool:
	if not bool(plot.get("planted", false)):
		return false
	if int(plot.get("stage", 0)) >= 3:
		return true
	var variety_index: int = int(plot.get("variety", 0))
	var grow_days: int = int(varieties[variety_index]["grow_days"])
	return int(plot.get("progress", 0)) >= grow_days


static func cutting_status_text(plot: Dictionary, varieties: Array[Dictionary]) -> String:
	if can_take_cutting(plot, varieties):
		return "ready with C"
	return "let tree establish first"


static func update_plot_moisture(plot: Dictionary, weather_name: String) -> void:
	var moisture: int = int(plot.get("moisture", 0))
	if bool(plot.get("watered", false)):
		moisture = 2
	elif weather_name == "Heat":
		moisture = maxi(0, moisture - 2)
	else:
		moisture = maxi(0, moisture - 1)
	plot["moisture"] = moisture


static func advance_tree(plot: Dictionary, varieties: Array[Dictionary], weather_name: String) -> void:
	var variety_index: int = int(plot["variety"])
	var old_stage: int = int(plot.get("stage", 0))
	var progress: int = int(plot["progress"])
	if bool(plot["watered"]):
		progress += 1
		if bool(plot["composted"]) and randf() < 0.35:
			progress += 1
		if weather_name == "Heat":
			plot["quality"] = int(plot["quality"]) + 1
	else:
		if weather_name == "Heat":
			plot["quality"] = maxi(1, int(plot["quality"]) - 1)
	plot["progress"] = progress
	var grow_days: int = int(varieties[variety_index]["grow_days"])
	var stage: int = mini(3, int(floor((float(progress) / float(grow_days)) * 3.0)))
	plot["stage"] = stage
	if stage >= 3:
		if old_stage >= 3:
			plot["ripe_days"] = int(plot.get("ripe_days", 0)) + 1
		else:
			plot["ripe_days"] = 0
	else:
		plot["ripe_days"] = 0


static func has_ripe_tree(plots: Array, grid_h: int, grid_w: int) -> bool:
	for y in grid_h:
		for x in grid_w:
			var plot: Dictionary = plots[y][x]
			if bool(plot["planted"]) and int(plot["stage"]) >= 3:
				return true
	return false
