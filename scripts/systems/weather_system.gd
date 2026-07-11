# ============================================================
# /*=== WEATHER SYSTEM FILE START ===*/
# ============================================================
extends RefCounted

# ============================================================
# WeatherSystem
# ------------------------------------------------------------
# Owns pure weather data, lookup, rolling, temperature, and
# formatting helpers.
#
# Does NOT:
# - Mutate gameplay state
# - Draw weather visuals
# - Play sounds or show messages
# - Refresh UI
# ============================================================


# ============================================================
# /*=== WEATHER DEFINITIONS START ===*/
# ============================================================

static func weather_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	definitions.append({"name": "Sunny", "description": "Steady growing weather.", "sky": "#dcecc8", "ground": "#9cc26f"})
	definitions.append({"name": "Rain", "description": "Trees start the day watered.", "sky": "#b9d5df", "ground": "#82b86f"})
	definitions.append({"name": "Heat", "description": "Watered trees get sweeter. Dry trees lose quality.", "sky": "#f2d59b", "ground": "#b9b45f"})
	definitions.append({"name": "Fog", "description": "Gentle mornings boost pollinator visits.", "sky": "#d9e1d8", "ground": "#91bb79"})
	return definitions

# ============================================================
# /*=== WEATHER DEFINITIONS END ===*/
# ============================================================


# ============================================================
# /*=== WEATHER LOOKUPS START ===*/
# ============================================================

static func normalize_weather_index(weather_index: int, weather_count: int) -> int:
	return clampi(weather_index, 0, maxi(0, weather_count - 1))


static func weather_at(weather_table: Array[Dictionary], weather_index: int) -> Dictionary:
	if weather_table.is_empty():
		return {}
	return weather_table[normalize_weather_index(weather_index, weather_table.size())]


static func weather_name(weather_table: Array[Dictionary], weather_index: int) -> String:
	return String(weather_at(weather_table, weather_index).get("name", "Sunny"))


static func weather_name_from_index(weather_index: int) -> String:
	return weather_name(weather_definitions(), weather_index)


static func sky_color(weather_table: Array[Dictionary], weather_index: int) -> String:
	return String(weather_at(weather_table, weather_index).get("sky", "#dcecc8"))


static func ground_color(weather_table: Array[Dictionary], weather_index: int) -> String:
	return String(weather_at(weather_table, weather_index).get("ground", "#9cc26f"))

# ============================================================
# /*=== WEATHER LOOKUPS END ===*/
# ============================================================


# ============================================================
# /*=== WEATHER ROLLING START ===*/
# ============================================================

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

	return {
		"weather_index": weather_index,
		"temperature_f": roll_temperature(season, weather_name_from_index(weather_index))
	}

# ============================================================
# /*=== WEATHER ROLLING END ===*/
# ============================================================


# ============================================================
# /*=== WEATHER FORMATTING START ===*/
# ============================================================

static func weather_detail_text(weather_table: Array[Dictionary], weather_index: int, day: int, temperature_f: int) -> String:
	var weather: Dictionary = weather_at(weather_table, weather_index)
	return "%s %s %s°F • %s" % [
		weather_icon(weather_table, weather_index),
		season_name(day),
		temperature_f,
		String(weather.get("description", "Steady growing weather."))
	]


static func weather_icon(weather_table: Array[Dictionary], weather_index: int) -> String:
	return weather_icon_from_name(weather_name(weather_table, weather_index))


static func weather_icon_from_name(weather: String) -> String:
	match weather:
		"Rain":
			return "🌧"
		"Heat":
			return "🔥"
		"Fog":
			return "🌫"
	return "☀"

# ============================================================
# /*=== WEATHER FORMATTING END ===*/
# ============================================================


# ============================================================
# /*=== SEASON AND TEMPERATURE START ===*/
# ============================================================

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

# ============================================================
# /*=== SEASON AND TEMPERATURE END ===*/
# ============================================================


# ============================================================
# /*=== WEATHER RULE HELPERS START ===*/
# ============================================================

static func is_rain(weather_table: Array[Dictionary], weather_index: int) -> bool:
	return weather_name(weather_table, weather_index) == "Rain"


static func is_heat(weather_table: Array[Dictionary], weather_index: int) -> bool:
	return weather_name(weather_table, weather_index) == "Heat"


static func is_rainy(weather: String) -> bool:
	return weather == "Rain"


static func pollinator_chance(pollinator_garden: bool, weather: String) -> float:
	var chance: float = 0.12
	if pollinator_garden:
		chance += 0.18
	if weather == "Fog":
		chance += 0.12
	return chance

# ============================================================
# /*=== WEATHER RULE HELPERS END ===*/
# ============================================================

# ============================================================
# /*=== WEATHER SYSTEM FILE END ===*/
# ============================================================
