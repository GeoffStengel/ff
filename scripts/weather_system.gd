extends RefCounted

static func roll_weather(day: int) -> Dictionary:
	var season: String = season_name(day)
	var roll: float = randf()
	var weather_index: int = 0
	if season == "Spring":
		if roll < 0.40:
			weather_index = 0
		elif roll < 0.68:
			weather_index = 1
		elif roll < 0.78:
			weather_index = 2
		else:
			weather_index = 3
	elif season == "Summer":
		if roll < 0.42:
			weather_index = 0
		elif roll < 0.54:
			weather_index = 1
		elif roll < 0.84:
			weather_index = 2
		else:
			weather_index = 3
	elif season == "Autumn":
		if roll < 0.42:
			weather_index = 0
		elif roll < 0.62:
			weather_index = 1
		elif roll < 0.72:
			weather_index = 2
		else:
			weather_index = 3
	else:
		if roll < 0.44:
			weather_index = 0
		elif roll < 0.62:
			weather_index = 1
		elif roll < 0.68:
			weather_index = 2
		else:
			weather_index = 3
	return {"weather_index": weather_index, "temperature_f": roll_temperature(season, weather_name_from_index(weather_index))}


static func weather_name(weather_table: Array[Dictionary], current_weather: int) -> String:
	return String(weather_table[current_weather]["name"])


static func weather_name_from_index(current_weather: int) -> String:
	match current_weather:
		1:
			return "Rain"
		2:
			return "Heat"
		3:
			return "Fog"
	return "Sunny"


static func weather_detail_text(weather_table: Array[Dictionary], current_weather: int, day: int, temperature_f: int) -> String:
	var weather: Dictionary = weather_table[current_weather]
	return "%s %s %s?F ? %s" % [weather_icon(weather_table, current_weather), season_name(day), temperature_f, String(weather["description"])]


static func weather_icon(weather_table: Array[Dictionary], current_weather: int) -> String:
	return weather_icon_from_name(weather_name(weather_table, current_weather))


static func weather_icon_from_name(weather: String) -> String:
	match weather:
		"Rain":
			return "🌧"
		"Heat":
			return "🔥"
		"Fog":
			return "🌫"
	return "☀"


static func season_name(day: int) -> String:
	var season_index: int = int(floor(float((day - 1) % 56) / 14.0))
	match season_index:
		0:
			return "Spring"
		1:
			return "Summer"
		2:
			return "Autumn"
	return "Winter"


static func season_base_temperature(season: String) -> int:
	match season:
		"Spring":
			return 66
		"Summer":
			return 84
		"Autumn":
			return 70
	return 52


static func roll_temperature(season: String, weather: String) -> int:
	var adjustment: int = 0
	if weather == "Heat":
		adjustment = 10
	elif weather == "Rain":
		adjustment = -5
	elif weather == "Fog":
		adjustment = -2
	return clampi(season_base_temperature(season) + adjustment + randi_range(-5, 5), 38, 104)


static func season_growing_note(day: int) -> String:
	match season_name(day):
		"Spring":
			return "Spring favors new roots, but rain can do some watering for you."
		"Summer":
			return "Summer grows fast, but hot days dry soil quicker."
		"Autumn":
			return "Autumn is good for finishing fruit and taking cuttings."
	return "Winter is slow practice time; protect young figs and plan the pantry."


static func is_rainy(weather: String) -> bool:
	return weather == "Rain"


static func pollinator_chance(pollinator_garden: bool, weather: String) -> float:
	var chance: float = 0.12
	if pollinator_garden:
		chance += 0.18
	if weather == "Fog":
		chance += 0.12
	return chance


static func max_water(base_max_water: int, barrel_level: int) -> int:
	return base_max_water + barrel_level * 4
