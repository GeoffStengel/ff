extends RefCounted

# ============================================================
# FarmRenderer
# ------------------------------------------------------------
# Draws farm visuals.
#
# Does NOT:
# - Change gameplay state
# - Handle input
# - Update UI
# ============================================================


# ============================================================
# /*=== SHARED DRAW HELPERS START ===*/
# ============================================================

static func rounded_box(fill: Color, border: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


static func draw_rounded_box(canvas: CanvasItem, rect: Rect2, fill: Color, border: Color, radius: int, border_width: int = 1) -> void:
	canvas.draw_style_box(rounded_box(fill, border, radius, border_width), rect)

# ============================================================
# /*=== SHARED DRAW HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== FARM BOARD START ===*/
# ------------------------------------------------------------
# Draws the wooden board and soil bed behind the plot grid.
# ============================================================

static func draw_farm_board(canvas: CanvasItem, board_rect: Rect2, plot_bed: Rect2) -> void:
	canvas.draw_style_box(
		rounded_box(Color(0.13, 0.08, 0.04, 0.20), Color(0.13, 0.08, 0.04, 0.0), 18),
		Rect2(board_rect.position + Vector2(4, 6), board_rect.size)
	)

	draw_rounded_box(canvas, board_rect, Color("#7a552f"), Color("#5b3b21"), 18, 2)
	draw_rounded_box(canvas, board_rect.grow(-7), Color("#d3b16a"), Color("#9b713d"), 13, 1)
	draw_rounded_box(canvas, board_rect.grow(-14), Color("#c99a58"), Color("#8e6536"), 10, 1)
	draw_rounded_box(canvas, plot_bed, Color("#be8a50"), Color("#744923"), 10, 1)

	for i in 10:
		var grass_pos: Vector2 = Vector2(
			board_rect.position.x + 30.0 + float(i) * 58.0,
			board_rect.end.y - 18.0 + float(i % 2) * 5.0
		)

		canvas.draw_line(grass_pos, grass_pos + Vector2(-5, -12), Color("#4f7f35"), 2.0)
		canvas.draw_line(grass_pos, grass_pos + Vector2(6, -10), Color("#5c913f"), 2.0)

# ============================================================
# /*=== FARM BOARD END ===*/
# ============================================================


# ============================================================
# /*=== BACKGROUND START ===*/
# ------------------------------------------------------------
# Draws sky, ground, hills, sun, and simple weather overlays.
# main.gd still owns weather data and passes it in.
# ============================================================

static func draw_background(
	canvas: CanvasItem,
	weather: Dictionary,
	viewport: Vector2,
	hud_h: int,
	gap: int
) -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO, viewport), Color(String(weather["sky"])))

	var ground_y: float = float(hud_h + gap + 24)

	canvas.draw_rect(
		Rect2(Vector2(0, ground_y), Vector2(viewport.x, viewport.y - ground_y)),
		Color(String(weather["ground"]))
	)

	draw_soft_hill(
		canvas,
		Vector2(-80, ground_y + 80),
		Vector2(viewport.x + 160.0, 170),
		Color(String(weather["ground"])).lightened(0.10)
	)

	draw_soft_hill(
		canvas,
		Vector2(80, ground_y + 144),
		Vector2(viewport.x + 80.0, 190),
		Color(String(weather["ground"])).darkened(0.04)
	)

	draw_background_trees(canvas, ground_y, viewport)
	canvas.draw_circle(Vector2(viewport.x - 240.0, 86), 42, Color("#ffd76a"))

	if String(weather["name"]) == "Rain":
		for i in 18:
			var start: Vector2 = Vector2(28 + i * 68, 86 + (i % 3) * 19)
			canvas.draw_line(start, start + Vector2(-12, 30), Color("#6b93a8"), 2.0)
	elif String(weather["name"]) == "Heat":
		for i in 5:
			var y: int = 126 + i * 28
			canvas.draw_arc(Vector2(610, y), 38, 0.2, 2.9, 18, Color("#d18b42"), 2.0)


static func draw_soft_hill(canvas: CanvasItem, pos: Vector2, size: Vector2, color: Color) -> void:
	var rect: Rect2 = Rect2(pos, size)
	canvas.draw_style_box(rounded_box(color, Color(color.r, color.g, color.b, 0.0), 90), rect)


static func draw_background_trees(canvas: CanvasItem, ground_y: float, viewport: Vector2) -> void:
	for i in 11:
		var x: float = 30.0 + float(i) * 118.0
		var trunk: Rect2 = Rect2(Vector2(x, ground_y + 42.0), Vector2(10, 42))
		canvas.draw_rect(trunk, Color("#6e4326"))

		canvas.draw_circle(Vector2(x + 5.0, ground_y + 35.0), 28, Color("#476d35"))
		canvas.draw_circle(Vector2(x - 10.0, ground_y + 46.0), 22, Color("#557e3d"))
		canvas.draw_circle(Vector2(x + 19.0, ground_y + 48.0), 22, Color("#3f6130"))

# ============================================================
# /*=== BACKGROUND END ===*/
# ============================================================


# ============================================================
# /*=== FARM PLOTS START ===*/
# ------------------------------------------------------------
# Draws the farm plot grid.
#
# FarmRenderer owns plot surface, plant, marker, and selection visuals.
# ============================================================

static func draw_farm_plots(
	canvas: CanvasItem,
	plots: Array,
	varieties: Array[Dictionary],
	crop_textures: Dictionary,
	grid_w: int,
	grid_h: int,
	farm_origin: Vector2,
	tile_size: int,
	selected_cell: Vector2i,
	farmer_cell: Vector2i
) -> void:
	for y in grid_h:
		for x in grid_w:
			var plot: Dictionary = plots[y][x]
			var pos: Vector2 = farm_origin + Vector2(x * tile_size, y * tile_size)
			var rect: Rect2 = Rect2(pos, Vector2(tile_size - 8, tile_size - 8))
			var soil: Color = Color("#9b653d")

			if (x + y) % 2 == 1:
				soil = Color("#a56c42")

			if bool(plot.get("planted", false)):
				var moisture: int = int(plot.get("moisture", 0))

				if moisture >= 2:
					soil = Color("#6f4a34")
				elif moisture == 1:
					soil = Color("#8f6040")
				else:
					soil = Color("#bd8352")

			canvas.draw_style_box(
				rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 8),
				Rect2(rect.position + Vector2(3, 4), rect.size)
			)

			draw_rounded_box(canvas, rect, soil, Color("#50321f"), 8, 2)
			draw_plot_texture(canvas, rect)

			if bool(plot.get("planted", false)) and int(plot.get("moisture", 0)) <= 0:
				draw_dry_cracks(canvas, rect)

			if bool(plot.get("composted", false)):
				draw_compost_specks(canvas, rect)

			draw_plot_plant(canvas, rect, plot, varieties, crop_textures)
			draw_plot_state_markers(canvas, rect, plot, varieties)

			if selected_cell == Vector2i(x, y):
				draw_rounded_box(canvas, rect.grow(4), Color(1.0, 1.0, 1.0, 0.0), Color("#ffe98a"), 10, 3)

			if farmer_cell == Vector2i(x, y):
				draw_rounded_box(canvas, rect.grow(8), Color(1.0, 1.0, 1.0, 0.0), Color("#fff6c7"), 12, 2)
# ============================================================
# /*=== FARM PLOTS END ===*/
# ============================================================


# ============================================================
# /*=== PLOT DETAIL HELPERS START ===*/
# ============================================================

static func draw_dry_cracks(canvas: CanvasItem, rect: Rect2) -> void:
	for i in 3:
		var start: Vector2 = rect.position + Vector2(16 + i * 17, 18 + (i % 2) * 18)

		canvas.draw_line(start, start + Vector2(10, 5), Color(0.28, 0.16, 0.09, 0.55), 2.0)
		canvas.draw_line(start + Vector2(10, 5), start + Vector2(16, 1), Color(0.28, 0.16, 0.09, 0.55), 1.5)


static func draw_plot_texture(canvas: CanvasItem, rect: Rect2) -> void:
	for i in 3:
		var y: float = rect.position.y + 20.0 + i * 16.0

		canvas.draw_line(
			Vector2(rect.position.x + 12.0, y),
			Vector2(rect.end.x - 14.0, y + 2.0),
			Color(0.31, 0.18, 0.10, 0.45),
			1.5
		)


static func draw_compost_specks(canvas: CanvasItem, rect: Rect2) -> void:
	for i in 4:
		var dot: Vector2 = rect.position + Vector2(14 + i * 13, rect.size.y - 18 - (i % 2) * 11)
		canvas.draw_circle(dot, 3, Color("#d3b65b"))

# ============================================================
# /*=== PLOT DETAIL HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== PLOT STATE MARKERS START ===*/
# ------------------------------------------------------------
# Draws small visual state markers on a planted plot:
# - variety tag
# - watered drops
# - ripe/overripe ring
# - peak sparkle
#
# Marker sub-drawing stays local to avoid callback bridges.
# ============================================================

static func draw_plot_state_markers(
	canvas: CanvasItem,
	rect: Rect2,
	plot: Dictionary,
	varieties: Array[Dictionary]
) -> void:
	if not bool(plot.get("planted", false)):
		return

	var variety_index: int = _safe_variety_index(plot, varieties)
	draw_variety_tag(canvas, rect, variety_index)

	if bool(plot.get("watered", false)):
		draw_water_drop(canvas, rect.position + Vector2(rect.size.x - 15, 15))
		draw_water_drop(canvas, rect.position + Vector2(rect.size.x - 27, 24))

	if int(plot.get("stage", 0)) >= 3:
		var ripe_days: int = int(plot.get("ripe_days", 0))
		var ring_color: Color = Color("#f1cf5a")

		if ripe_days == 1:
			ring_color = Color("#fff07a")
		elif ripe_days == 2:
			ring_color = Color("#d9a24d")
		elif ripe_days >= 3:
			ring_color = Color("#6b3a2d")

		draw_rounded_box(canvas, rect.grow(5), Color(1.0, 1.0, 1.0, 0.0), ring_color, 12, 3)

		if ripe_days == 1:
			draw_peak_sparkles(canvas, rect.position + rect.size * 0.5)
# ============================================================
# /*=== PLOT STATE MARKERS END ===*/
# ============================================================


# ============================================================
# /*=== WATER DROP MARKER START ===*/
# ============================================================

static func draw_water_drop(canvas: CanvasItem, pos: Vector2) -> void:
	canvas.draw_circle(pos + Vector2(0, 3), 4, Color("#5ca4d8"))
	canvas.draw_colored_polygon(
		[
			pos + Vector2(0, -6),
			pos + Vector2(-4, 2),
			pos + Vector2(4, 2)
		],
		Color("#5ca4d8")
	)

# ============================================================
# /*=== WATER DROP MARKER END ===*/
# ============================================================

# ============================================================
# /*=== VARIETY MARKERS START ===*/
# ============================================================

static func draw_variety_tag(canvas: CanvasItem, rect: Rect2, variety_index: int) -> void:
	var marker_color: Color = variety_marker_color(variety_index)
	var marker_rect: Rect2 = Rect2(rect.end - Vector2(18, 18), Vector2(12, 12))
	draw_rounded_box(canvas, marker_rect, marker_color, Color("#2a1d14"), 3, 1)


static func variety_marker_color(variety_index: int) -> Color:
	match variety_index:
		0:
			return Color("#d65a4a")
		1:
			return Color("#4d3e9a")
		2:
			return Color("#f1d86a")
		3:
			return Color("#2f9f83")
	return Color("#ffffff")

# ============================================================
# /*=== VARIETY MARKERS END ===*/
# ============================================================


# ============================================================
# /*=== RIPE SPARKLES START ===*/
# ============================================================

static func draw_peak_sparkles(canvas: CanvasItem, center: Vector2) -> void:
	var offsets: Array[Vector2] = [Vector2(-28, -24), Vector2(28, -20), Vector2(24, 24)]
	for offset in offsets:
		var p: Vector2 = center + offset
		canvas.draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color("#fff07a"), 2.0)
		canvas.draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color("#fff07a"), 2.0)

# ============================================================
# /*=== RIPE SPARKLES END ===*/
# ============================================================


# ============================================================
# /*=== PLANT AND TREE DRAWING START ===*/
# ============================================================

static func draw_plot_plant(
	canvas: CanvasItem,
	rect: Rect2,
	plot: Dictionary,
	varieties: Array[Dictionary],
	crop_textures: Dictionary
) -> void:
	if not bool(plot.get("planted", false)):
		if bool(plot.get("harvested_marker", false)):
			var harvested_texture: Texture2D = texture_from(crop_textures, "harvested")
			if harvested_texture != null:
				draw_texture_centered(canvas, harvested_texture, rect.position + rect.size * 0.5 + Vector2(0, 1), Vector2(rect.size.x + 6.0, rect.size.y + 6.0))
				return
		canvas.draw_line(rect.position + Vector2(12, rect.size.y - 14), rect.end - Vector2(12, 14), Color("#6e3f27"), 2.0)
		return

	var center: Vector2 = rect.position + rect.size * 0.5
	var crop_texture: Texture2D = crop_texture_for_plot(plot, varieties, crop_textures)
	if crop_texture != null:
		var sprite_size: Vector2 = Vector2(rect.size.x + 8.0, rect.size.y + 8.0)
		if crop_texture.get_width() > 64:
			sprite_size = Vector2(rect.size.x + 22.0, rect.size.y + 22.0)
		draw_texture_centered(canvas, crop_texture, center + Vector2(0, 1), sprite_size)
	else:
		canvas.draw_line(center + Vector2(0, 22), center + Vector2(0, -14), Color("#6b3f24"), 6.0)
		canvas.draw_circle(center + Vector2(0, -18), 16, Color("#3f8738"))

	if bool(plot.get("bonus", false)):
		draw_bee_icon(canvas, center + Vector2(23, -24), 0.72)

	if can_take_cutting_visual(plot, varieties):
		var clip_pos: Vector2 = rect.position + Vector2(16, 14)
		canvas.draw_line(clip_pos + Vector2(0, 9), clip_pos + Vector2(0, -4), Color("#4f7f35"), 3.0)
		canvas.draw_circle(clip_pos + Vector2(-5, -3), 4, Color("#8fcf5b"))
		canvas.draw_circle(clip_pos + Vector2(5, -5), 4, Color("#8fcf5b"))


static func crop_texture_for_plot(plot: Dictionary, varieties: Array[Dictionary], crop_textures: Dictionary) -> Texture2D:
	var stage: int = int(plot.get("stage", 0))
	var variety_index: int = _safe_variety_index(plot, varieties)
	var progress: int = int(plot.get("progress", 0))
	var grow_days: int = int(varieties[variety_index].get("grow_days", 1))
	if stage >= 3:
		if variety_index == 2:
			return texture_from(crop_textures, "ripe_green")
		return texture_from(crop_textures, "ripe_purple")
	if progress <= 0:
		return texture_from(crop_textures, "cutting")
	if grow_days <= 2:
		if progress <= 1:
			return texture_from(crop_textures, "young")
		return texture_from(crop_textures, "growing")
	if progress == 1:
		return texture_from(crop_textures, "sprout")
	if progress <= maxi(2, grow_days - 2):
		return texture_from(crop_textures, "young")
	return texture_from(crop_textures, "growing")


static func can_take_cutting_visual(plot: Dictionary, varieties: Array[Dictionary]) -> bool:
	if not bool(plot.get("planted", false)):
		return false
	if int(plot.get("stage", 0)) >= 3:
		return true
	var variety_index: int = _safe_variety_index(plot, varieties)
	var grow_days: int = int(varieties[variety_index].get("grow_days", 1))
	return int(plot.get("progress", 0)) >= grow_days

# ============================================================
# /*=== PLANT AND TREE DRAWING END ===*/
# ============================================================


# ============================================================
# /*=== FARM PROPS AND SIDE SCENE START ===*/
# ============================================================

static func draw_side_scene(canvas: CanvasItem, board_rect: Rect2, item_textures: Dictionary, pollinator_garden: bool) -> void:
	draw_farm_props(canvas, item_textures)
	if pollinator_garden:
		var flower_texture: Texture2D = texture_from(item_textures, "flower")
		for i in 10:
			var flower_center: Vector2 = Vector2(board_rect.position.x + 34.0 + float(i) * 34.0, board_rect.end.y - 22.0 - float(i % 2) * 8.0)
			if flower_texture != null:
				draw_texture_centered(canvas, flower_texture, flower_center, Vector2(28, 28))
			else:
				canvas.draw_line(flower_center + Vector2(0, 12), flower_center, Color("#3f7b35"), 2.0)
				canvas.draw_circle(flower_center + Vector2(-4, 0), 4, Color("#d86f90"))
				canvas.draw_circle(flower_center + Vector2(4, 0), 4, Color("#d86f90"))
				canvas.draw_circle(flower_center + Vector2(0, -4), 4, Color("#ffd966"))
		for i in 3:
			draw_bee_icon(canvas, Vector2(board_rect.position.x + 84.0 + float(i) * 118.0, board_rect.position.y + 28.0 + float(i % 2) * 30.0), 0.82)


static func draw_farm_props(canvas: CanvasItem, item_textures: Dictionary) -> void:
	var barrel_pos: Vector2 = Vector2(174, 504)
	var barrel_texture: Texture2D = texture_from(item_textures, "barrel")
	if barrel_texture != null:
		draw_texture_centered(canvas, barrel_texture, barrel_pos + Vector2(17, 26), Vector2(42, 54))
	else:
		draw_rounded_box(canvas, Rect2(barrel_pos, Vector2(34, 52)), Color("#8e5a32"), Color("#4b2d1c"), 4, 2)
		canvas.draw_rect(Rect2(barrel_pos + Vector2(4, 8), Vector2(26, 8)), Color("#5d7fa3"))

	var sign_rect: Rect2 = Rect2(Vector2(828, 516), Vector2(58, 34))
	var crate_texture: Texture2D = texture_from(item_textures, "crate")
	if crate_texture != null:
		draw_texture_centered(canvas, crate_texture, sign_rect.position + sign_rect.size * 0.5, Vector2(54, 42))
	else:
		draw_rounded_box(canvas, sign_rect, Color("#a46b3a"), Color("#5a3520"), 4, 2)
		canvas.draw_line(sign_rect.position + Vector2(8, 11), sign_rect.position + Vector2(sign_rect.size.x - 8, 11), Color("#754521"), 2.0)
		canvas.draw_line(sign_rect.position + Vector2(8, 23), sign_rect.position + Vector2(sign_rect.size.x - 8, 23), Color("#754521"), 2.0)
	canvas.draw_line(Vector2(204, 570), Vector2(832, 570), Color("#d4b16d"), 8.0)

# ============================================================
# /*=== FARM PROPS AND SIDE SCENE END ===*/
# ============================================================


# ============================================================
# /*=== FARMER DRAWING START ===*/
# ============================================================

static func draw_farmer(
	canvas: CanvasItem,
	farmer_pos: Vector2,
	farmer_step_bob: float,
	current_tool: int,
	tool_textures: Dictionary,
	tool_usable: bool
) -> void:
	var bob: float = sin(farmer_step_bob) * 1.8
	var base: Vector2 = farmer_pos + Vector2(0, bob)
	canvas.draw_circle(base + Vector2(0, 18), 16, Color(0.13, 0.09, 0.05, 0.22))
	canvas.draw_line(base + Vector2(-7, 8), base + Vector2(-11, 22), Color("#263b4d"), 4.0)
	canvas.draw_line(base + Vector2(7, 8), base + Vector2(11, 22), Color("#263b4d"), 4.0)
	canvas.draw_rect(Rect2(base + Vector2(-12, -19), Vector2(24, 28)), Color("#5f8f52"))
	canvas.draw_rect(Rect2(base + Vector2(-12, -19), Vector2(24, 28)), Color("#2f4d2c"), false, 2.0)
	canvas.draw_line(base + Vector2(-12, -8), base + Vector2(-24, 2), Color("#8b5a3c"), 4.0)
	canvas.draw_line(base + Vector2(12, -8), base + Vector2(24, 2), Color("#8b5a3c"), 4.0)
	canvas.draw_circle(base + Vector2(0, -30), 13, Color("#b7784e"))
	canvas.draw_rect(Rect2(base + Vector2(-17, -44), Vector2(34, 7)), Color("#d2a64d"))
	canvas.draw_colored_polygon([base + Vector2(-11, -43), base + Vector2(11, -43), base + Vector2(6, -56), base + Vector2(-6, -56)], Color("#d2a64d"))
	canvas.draw_circle(base + Vector2(-4, -32), 2, Color("#2c1a14"))
	canvas.draw_circle(base + Vector2(5, -32), 2, Color("#2c1a14"))
	canvas.draw_line(base + Vector2(-4, -25), base + Vector2(5, -24), Color("#2c1a14"), 1.5)
	if tool_usable:
		draw_farmer_tool_icon(canvas, base + Vector2(27, -18), current_tool, tool_textures)


static func draw_farmer_tool_icon(canvas: CanvasItem, pos: Vector2, current_tool: int, tool_textures: Dictionary) -> void:
	canvas.draw_circle(pos, 12, Color("#fff6df"))
	canvas.draw_circle(pos, 12, Color("#4f3722"), false, 2.0)
	var texture: Texture2D = tool_texture(current_tool, tool_textures)
	if texture != null:
		draw_texture_centered(canvas, texture, pos, Vector2(23, 23))
		return
	canvas.draw_circle(pos, 5, Color("#5d7f35"))

# ============================================================
# /*=== FARMER DRAWING END ===*/
# ============================================================


# ============================================================
# /*=== TEXTURE HELPERS START ===*/
# ============================================================

static func texture_from(group: Dictionary, key: String) -> Texture2D:
	if not group.has(key):
		return null
	var texture: Texture2D = group[key] as Texture2D
	return texture


static func draw_texture_centered(canvas: CanvasItem, texture: Texture2D, center: Vector2, size: Vector2) -> void:
	var target: Rect2 = Rect2(center - size * 0.5, size)
	canvas.draw_texture_rect(texture, target, false)


static func tool_texture(tool: int, tool_textures: Dictionary) -> Texture2D:
	match tool:
		0:
			return texture_from(tool_textures, "plant")
		1:
			return texture_from(tool_textures, "water")
		2:
			return texture_from(tool_textures, "compost")
		3:
			return texture_from(tool_textures, "harvest")
	return null


static func _safe_variety_index(plot: Dictionary, varieties: Array[Dictionary]) -> int:
	if varieties.is_empty():
		return 0
	return clampi(int(plot.get("variety", 0)), 0, varieties.size() - 1)

# ============================================================
# /*=== TEXTURE HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== BEE ICON START ===*/
# ------------------------------------------------------------
# Draws the small pollinator bee used on bonus plots and around
# the pollinator garden.
# ============================================================

static func draw_bee_icon(
	canvas: CanvasItem,
	pos: Vector2,
	scale: float = 1.0
) -> void:
	canvas.draw_circle(
		pos + Vector2(-5, -5) * scale,
		5.0 * scale,
		Color(1.0, 1.0, 1.0, 0.55)
	)

	canvas.draw_circle(
		pos + Vector2(5, -5) * scale,
		5.0 * scale,
		Color(1.0, 1.0, 1.0, 0.55)
	)

	canvas.draw_circle(
		pos + Vector2(-3, 1) * scale,
		6.0 * scale,
		Color("#ffd45c")
	)

	canvas.draw_circle(
		pos + Vector2(3, 1) * scale,
		6.0 * scale,
		Color("#ffd45c")
	)

	canvas.draw_line(
		pos + Vector2(-3, -4) * scale,
		pos + Vector2(-3, 6) * scale,
		Color("#5d3b18"),
		2.0 * scale
	)

	canvas.draw_line(
		pos + Vector2(3, -4) * scale,
		pos + Vector2(3, 6) * scale,
		Color("#5d3b18"),
		2.0 * scale
	)

	canvas.draw_circle(
		pos + Vector2(9, 1) * scale,
		3.0 * scale,
		Color("#2c1a14")
	)

# ============================================================
# /*=== BEE ICON END ===*/
# ============================================================
