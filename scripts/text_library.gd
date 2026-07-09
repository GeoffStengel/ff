extends RefCounted

static func how_to_play_text() -> String:
	return "Goal\nGrow figs, learn cultivars, fill accepted orders, and build Trust.\n\nControls\nMove: WASD or arrow keys\nUse tool: F, Enter, or click\nInspect: I  |  Cuttings: C\nEnd day: Space  |  Pause: P/Esc\n\nFarm Loop\nPlant -> water -> wait for ripe figs -> harvest. Rain wets soil; heat dries it faster.\n\nOrders\nView offers freely. Accept only when you want the timer. Finished orders raise Trust.\n\nPantry\nStore figs, cuttings, jars, jam, and clone-ready trees."


static func logbook_text(game_log: Array[String]) -> String:
	if game_log.is_empty():
		return "Logbook\nNo entries yet."
	var lines: Array[String] = ["Logbook"]
	var shown: int = mini(2, game_log.size())
	for i in shown:
		lines.append(game_log[i])
	return "\n".join(lines)


static func tutorial_text(tutorial_index: int) -> String:
	match tutorial_index:
		0:
			return "Guide 1/5  Plant Chicago Hardy"
		1:
			return "Guide 2/5  Water once today"
		2:
			return "Guide 3/5  Wait for ripe figs"
		3:
			return "Guide 4/5  Harvest ripe figs"
		4:
			return "Guide 5/5  Fulfill an order"
	return "Guide complete  Try cultivars, ripeness, cuttings, weekly table"


static func tutorial_short_text(tutorial_index: int) -> String:
	match tutorial_index:
		0:
			return "Guide 1/5"
		1:
			return "Guide 2/5"
		2:
			return "Guide 3/5"
		3:
			return "Guide 4/5"
		4:
			return "Guide 5/5"
	return "Guide done"


static func ripeness_yield_bonus(ripe_days: int) -> int:
	if ripe_days <= 0:
		return 1
	if ripe_days == 1:
		return 2
	if ripe_days == 2:
		return 0
	return -2


static func ripeness_label(ripe_days: int) -> String:
	if ripe_days <= 0:
		return "newly ripe"
	if ripe_days == 1:
		return "peak ripe"
	if ripe_days == 2:
		return "very soft"
	return "overripe"


static func ripeness_harvest_note(ripe_days: int) -> String:
	match ripeness_label(ripe_days):
		"peak ripe":
			return "Perfect timing: peak-ripe figs give a bonus."
		"very soft":
			return "Very soft figs are sweet but fragile."
		"overripe":
			return "Some figs were overripe, so the yield dropped."
	return "Newly ripe figs are ready, but another day can improve them."


static func guide_legend_text(season: String, temperature_f: int, growing_note: String, recipe_expanded: bool) -> String:
	var text: String = "Season: %s at %s F\n%s\n\nTags: red stripe Chicago, blue dots Black Madeira, yellow band White M1, green triangle RdB\nSoil: dark wet, medium moist, light cracked dry\nMarkers: drops watered, ring ripe, sparkles peak, sprout cutting-ready\nTrust = village reputation" % [season, temperature_f, growing_note]
	if recipe_expanded:
		text += "\n\nJam: 5 ripe figs + 1 clean jar. Add sugar and lemon, simmer thick, then jar. In game: $18."
	else:
		text += "\n\nRecipe button opens the jam card."
	return text


static func day_summary_text(day: int, weather_icon: String, grew_count: int, dried_count: int, ripened_count: int, softened_count: int, order_tick_count: int, expired_order_count: int, weather_name: String, extra_note: String) -> String:
	var parts: Array[String] = []
	if grew_count > 0:
		parts.append("🌱 %s grew" % grew_count)
	if dried_count > 0:
		parts.append("💧 %s dried" % dried_count)
	if ripened_count > 0:
		parts.append("Figs ripened: %s" % ripened_count)
	if softened_count > 0:
		parts.append("? %s softened" % softened_count)
	if order_tick_count > 0:
		parts.append("📋 %s orders ticked" % order_tick_count)
	if expired_order_count > 0:
		parts.append("? %s expired" % expired_order_count)
	if extra_note != "":
		parts.append(extra_note)
	if parts.is_empty():
		parts.append("farm rested")
	return "Day %s %s %s: %s" % [day, weather_icon, weather_name, ", ".join(parts)]


static func progress_bar(current: int, maximum: int, width: int = 5) -> String:
	var filled: int = 0
	if maximum > 0:
		filled = clampi(int(ceil((float(current) / float(maximum)) * float(width))), 0, width)
	var pieces: Array[String] = []
	for i in width:
		if i < filled:
			pieces.append("?")
		else:
			pieces.append("?")
	return "".join(pieces)


static func moisture_icon(moisture: int) -> String:
	if moisture >= 2:
		return "💧💧"
	if moisture == 1:
		return "💧"
	return "?"


static func tool_icon(tool: int) -> String:
	match tool:
		0:
			return "🌱"
		1:
			return "💧"
		2:
			return "🟤"
		3:
			return "?"
	return "?"


static func tool_shortcut(tool: int) -> String:
	match tool:
		0:
			return "1"
		1:
			return "2"
		2:
			return "3"
		3:
			return "4"
	return "?"


static func drawer_header_text(side_tab: int) -> String:
	match side_tab:
		0:
			return "🏡 Farm"
		1:
			return "📋 Orders"
		2:
			return "🧺 Pantry"
		3:
			return "📖 Guide"
		4:
			return "? Help"
	return "Menu"


static func tool_name(tool: int) -> String:
	match tool:
		0:
			return "Plant"
		1:
			return "Water"
		2:
			return "Compost"
		3:
			return "Harvest"
	return "Tool"


static func moisture_label(moisture: int) -> String:
	if moisture >= 2:
		return "wet soil"
	if moisture == 1:
		return "moist soil"
	return "dry soil"


static func recipe_card_text() -> String:
	return "A simple fig jam rhythm:\n1. Use 5 ripe figs and 1 clean jar.\n2. Add sugar and a squeeze of lemon.\n3. Simmer until glossy and thick.\n4. Spoon into jars while warm.\n\nIn game: Make jam in Pantry, then sell each jar for $18."


static func day_count_text(count: int) -> String:
	if count == 1:
		return "1 day"
	return "%s days" % count


static func growth_stage_label(stage: int) -> String:
	match stage:
		0:
			return "young cutting"
		1:
			return "leafing out"
		2:
			return "setting fruit"
	return "ripe"


static func festival_goal_for_week(festival_week: int, reputation: int) -> int:
	var scaled_week: int = mini(festival_week, 8)
	return clampi(20 + scaled_week * 4 + reputation * 2, 24, 60)


static func festival_text(festival_week: int, festival_progress: int, festival_goal: int, days_left: int) -> String:
	return "🍽 Weekly Table W%s  %s/%s figs  %s days\nOrders, jam, crates count. Bonus only." % [festival_week, festival_progress, festival_goal, days_left]


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
