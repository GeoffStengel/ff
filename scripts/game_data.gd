extends RefCounted

static func varieties() -> Array[Dictionary]:
	return [
	{
		"name": "Chicago Hardy",
		"short": "Chi Hardy",
		"color": "#6b2d5c",
		"tag_color": "#c94d4d",
		"seed_cost": 20,
		"grow_days": 3,
		"yield_bonus": 1,
		"value": 5,
		"lesson": "Cold-hardy, forgiving, and often confused with Brown Turkey.",
		"care": "Forgiving strain: steady water while young, tolerates cooler weather, fruits on new growth."
	},
	{
		"name": "Black Madeira",
		"short": "BLK Madeira",
		"color": "#2d173a",
		"tag_color": "#3d3a86",
		"seed_cost": 50,
		"grow_days": 5,
		"yield_bonus": 2,
		"value": 9,
		"lesson": "Premium dark fig with rich berry-jam flavor. Slow but valuable.",
		"care": "Slow and valuable: compost helps, missed watering delays harvest more than cheap varieties."
	},
	{
		"name": "White Madeira #1",
		"short": "White M #1",
		"color": "#c6d36e",
		"tag_color": "#d7c84f",
		"seed_cost": 60,
		"grow_days": 4,
		"yield_bonus": 1,
		"value": 7,
		"lesson": "Green-yellow fig with a bright honey flavor when fully ripe.",
		"care": "Likes even moisture during fruit swell. Harvest only when soft; pale figs can look ripe early."
	},
	{
		"name": "Ronde de Bordeaux",
		"short": "Ronde",
		"color": "#3b214d",
		"tag_color": "#2f8a76",
		"seed_cost": 50,
		"grow_days": 2,
		"yield_bonus": 0,
		"value": 6,
		"lesson": "Early French fig with small dark fruit. Great for short seasons.",
		"care": "Fast ripener: good for festival deadlines, but each harvest is smaller."
	}
]


static func weather_table() -> Array[Dictionary]:
	return [
	{"name": "Sunny", "description": "Steady growing weather.", "sky": "#dcecc8", "ground": "#9cc26f"},
	{"name": "Rain", "description": "Trees start the day watered.", "sky": "#b9d5df", "ground": "#82b86f"},
	{"name": "Heat", "description": "Watered trees get sweeter. Dry trees lose quality.", "sky": "#f2d59b", "ground": "#b9b45f"},
	{"name": "Fog", "description": "Gentle mornings boost pollinator visits.", "sky": "#d9e1d8", "ground": "#91bb79"}
]


static func relationships() -> Dictionary:
	return {
	"Mara the baker": 0,
	"Oren the innkeeper": 0,
	"Sel the jam maker": 0,
	"Niko the chef": 0,
	"Tavi from the festival": 0
}


static func order_templates() -> Array[Dictionary]:
	return [
		{"customer": "Mara the baker", "label": "Fig tart filling", "variety": -1},
		{"customer": "Oren the innkeeper", "label": "Cold-climate breakfast", "variety": 0},
		{"customer": "Sel the jam maker", "label": "Black Madeira jam", "variety": 1},
		{"customer": "Niko the chef", "label": "White Madeira plates", "variety": 2},
		{"customer": "Tavi from the festival", "label": "Early RdB tasting", "variety": 3}
	]

