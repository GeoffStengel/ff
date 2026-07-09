extends RefCounted

static func pantry_figs_text(varieties: Array[Dictionary], fig_bins: Array[int]) -> String:
	var lines: Array[String] = ["Figs"]
	for i in varieties.size():
		var count: int = fig_bins[i]
		var value: int = int(varieties[i]["value"])
		lines.append("%s %s  $%s" % [String(varieties[i]["short"]), count, value])
	return "\n".join(lines)


static func pantry_cuttings_text(varieties: Array[Dictionary], cuttings: Array[int]) -> String:
	var lines: Array[String] = ["🌱 Cuttings"]
	for i in varieties.size():
		lines.append("%s %s" % [String(varieties[i]["short"]), cuttings[i]])
	return "\n".join(lines)


static func pantry_preserves_text(total_figs: int, mason_jars: int, jam_jars: int) -> String:
	var possible_jam: int = mini(int(floor(float(total_figs) / 5.0)), mason_jars)
	return "🫙 Jars %s  Jam %s\nCan make: %s" % [mason_jars, jam_jars, jar_count_text(possible_jam)]


static func pantry_trees_text(varieties: Array[Dictionary], plots: Array, cuttings: Array[int], grid_h: int, grid_w: int) -> String:
	var ready_counts: Array[int] = []
	for i in varieties.size():
		ready_counts.append(0)
	var planted_count: int = 0
	for y in grid_h:
		for x in grid_w:
			var plot: Dictionary = plots[y][x]
			if bool(plot.get("planted", false)):
				planted_count += 1
				if can_take_cutting(plot, varieties):
					var variety_index: int = int(plot["variety"])
					ready_counts[variety_index] += 1
	var ready_parts: Array[String] = []
	for i in varieties.size():
		if ready_counts[i] > 0:
			ready_parts.append("%s:%s" % [String(varieties[i]["short"]), ready_counts[i]])
	var ready_text: String = "none"
	if ready_parts.size() > 0:
		ready_text = "  ".join(ready_parts)
	return "🌳 Trees %s | cutting-ready %s\nStored cuttings: %s" % [planted_count, ready_text, total_items(cuttings)]


static func pantry_hint_text() -> String:
	return "C clips clone-ready trees. Orders tab sells crates; Pantry makes jam."


static func jar_count_text(count: int) -> String:
	if count == 1:
		return "1 jar"
	return "%s jars" % count


static func total_items(items: Array[int]) -> int:
	var total: int = 0
	for count in items:
		total += int(count)
	return total


static func take_any(items: Array[int], amount: int) -> void:
	var left: int = amount
	for i in items.size():
		var take: int = mini(items[i], left)
		items[i] -= take
		left -= take
		if left <= 0:
			return


static func can_take_cutting(plot: Dictionary, varieties: Array[Dictionary]) -> bool:
	if not bool(plot.get("planted", false)):
		return false
	if int(plot.get("stage", 0)) >= 3:
		return true
	var variety_index: int = int(plot.get("variety", 0))
	var grow_days: int = int(varieties[variety_index]["grow_days"])
	return int(plot.get("progress", 0)) >= grow_days
