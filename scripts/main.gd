extends Node2D

const GameData = preload("res://scripts/game_data.gd")
const AssetLibrary = preload("res://scripts/asset_library.gd")
const AudioLibrary = preload("res://scripts/audio_library.gd")
const SaveSystem = preload("res://scripts/save_system.gd")
const OrderSystem = preload("res://scripts/order_system.gd")
const InventorySystem = preload("res://scripts/inventory_system.gd")
const WeatherSystem = preload("res://scripts/weather_system.gd")
const TextLibrary = preload("res://scripts/text_library.gd")
const CropSystem = preload("res://scripts/crop_system.gd")
const LayoutSystem = preload("res://scripts/layout_system.gd")

const GRID_W := 8
const GRID_H := 6
const BASE_TILE := 72
const SCREEN_PAD := 16
const HUD_H := 64
const LEFT_DOCK_W := 96
const DRAWER_W := 420
const BOTTOM_BAR_H := 84
const GAP := 12
const PANEL_RADIUS := 14
const TOOL_BUTTON_SIZE := 46
const BG_CREAM := "#fff8e8"
const PANEL_FILL := "#f0ddb5"
const PANEL_BORDER := "#6a4d2e"
const TEXT_DARK := "#3b2b19"
const MUTED_TEXT := "#725431"
const PRIMARY_GREEN := "#5d7f35"
const DISABLED_FILL := "#c8c0ae"

var tile_size: int = BASE_TILE
var farm_origin: Vector2 = Vector2(230, 116)
var farm_board_position: Vector2 = Vector2(204, 90)
const DAY_LENGTH := 30.0
const BASE_MAX_WATER := 12
const FESTIVAL_LENGTH := 7
const SAVE_PATH := "user://fig_farmer_save.json"

enum Tool { PLANT, WATER, COMPOST, HARVEST }

var varieties: Array[Dictionary] = GameData.varieties()
var weather_table: Array[Dictionary] = GameData.weather_table()
var current_tool: int = Tool.PLANT
var selected_variety: int = 0
var side_tab: int = 0
var panel_open: bool = false
var game_paused: bool = false
var sound_enabled: bool = true
var day: int = 1
var time_left: float = DAY_LENGTH
var coins: int = 26
var water: int = 9
var compost: int = 2
var reputation: int = 0
var tutorial_index: int = 0
var festival_week: int = 1
var festival_goal: int = 24
var festival_progress: int = 0
var relationships: Dictionary = GameData.relationships()
var cuttings: Array[int] = [4, 1, 1, 2]
var fig_bins: Array[int] = [0, 0, 0, 0]
var jam_jars: int = 0
var mason_jars: int = 2
var recipe_expanded: bool = false
var barrel_level: int = 0
var pollinator_garden: bool = false
var current_weather: int = 0
var temperature_f: int = 68
var selected_cell: Vector2i = Vector2i(-1, -1)
var farmer_cell: Vector2i = Vector2i(0, GRID_H - 1)
var farmer_pos: Vector2 = Vector2.ZERO
var farmer_step_bob: float = 0.0
var message: String = "Plant fig cuttings, water them, compost favorites, and harvest ripe fruit for villagers."
var message_timer: float = 6.0
var ui_dirty: bool = true
var last_display_second: int = -1
var last_layout_size: Vector2 = Vector2.ZERO
var dialogue_visible: bool = false
var dialogue_title: String = ""
var dialogue_body: String = ""
var order_offers: Array[Dictionary] = []
var accepted_orders: Array[Dictionary] = []
var selected_order_index: int = 0
var game_log: Array[String] = []

var plots: Array = []
var tool_buttons: Dictionary = {}
var variety_buttons: Dictionary = {}
var hud_labels: Dictionary = {}
var tab_buttons: Dictionary = {}
var order_buttons: Array[Button] = []
var order_scroll: ScrollContainer
var order_list: VBoxContainer
var top_bar: HBoxContainer
var hud_second_row: HBoxContainer
var hud_fig_icon: TextureRect
var dock_tool_row: VBoxContainer
var tab_row: VBoxContainer
var tool_section_label: Label
var menu_section_label: Label
var controls_panel: VBoxContainer
var market_panel: VBoxContainer
var pantry_panel: VBoxContainer
var guide_panel: VBoxContainer
var help_panel: VBoxContainer
var order_label: Label
var festival_label: Label
var accept_order_button: Button
var fulfill_order_button: Button
var inventory_label: Label
var pantry_figs_label: Label
var pantry_cuttings_label: Label
var pantry_preserves_label: Label
var pantry_trees_label: Label
var pantry_hint_label: Label
var relationship_label: Label
var preserve_label: Label
var logbook_label: Label
var action_hint: Label
var message_label: Label
var bottom_action_label: Label
var plot_card_label: Label
var dock_hint_label: Label
var dialogue_title_label: Label
var dialogue_body_label: Label
var pause_label: Label
var pause_overlay_title: Label
var pause_overlay_hint: Label
var notebook_label: Label
var plot_status_label: Label
var guide_legend_label: Label
var buy_cuttings_button: Button
var barrel_button: Button
var garden_button: Button
var save_button: Button
var load_button: Button
var pause_button: Button
var sound_button: Button
var dialogue_close_button: Button
var clipping_button: Button
var clipping_row: HBoxContainer
var make_jam_button: Button
var sell_jam_button: Button
var buy_jars_button: Button
var recipe_button: Button
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_library: Dictionary = {}
var crop_textures: Dictionary = {}
var item_textures: Dictionary = {}
var ui_textures: Dictionary = {}
var tool_textures: Dictionary = {}

func _ready() -> void:
	randomize()
	_build_plots()
	_update_layout()
	farmer_pos = _cell_center(farmer_cell)
	selected_cell = farmer_cell
	_roll_weather()
	_refresh_order_offers()
	_build_sfx()
	AssetLibrary.load_art_assets(crop_textures, item_textures, ui_textures, tool_textures)
	_build_ui()
	_update_ui()


func _process(delta: float) -> void:
	if _update_layout():
		_apply_layout_to_controls()
		_mark_ui_dirty()
	if game_paused:
		if ui_dirty:
			_update_ui()
		queue_redraw()
		return
	var message_was_visible: bool = message_timer > 0.0
	time_left -= delta
	message_timer = maxf(message_timer - delta, 0.0)
	farmer_pos = farmer_pos.lerp(_cell_center(farmer_cell), minf(delta * 12.0, 1.0))
	farmer_step_bob += delta * 8.0
	var display_second: int = int(ceil(time_left))
	if display_second != last_display_second:
		last_display_second = display_second
		_update_hud_labels()
	if message_was_visible != (message_timer > 0.0):
		_update_transient_ui()
	if time_left <= 0.0:
		_start_next_day()
	if ui_dirty:
		_update_ui()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if dialogue_visible and event.keycode == KEY_ESCAPE:
			_close_dialogue()
			return
		if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
			_toggle_pause()
			return
	if game_paused:
		return
	if event is InputEventMouseMotion:
		var hover_cell: Vector2i = _cell_from_mouse(event.position)
		if hover_cell != selected_cell:
			selected_cell = hover_cell
			_mark_ui_dirty()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell: Vector2i = _cell_from_mouse(event.position)
		if _is_cell_inside(cell):
			farmer_cell = cell
			selected_cell = cell
			_handle_plot_click(cell)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_set_tool(Tool.PLANT)
			KEY_2:
				_set_tool(Tool.WATER)
			KEY_3:
				_set_tool(Tool.COMPOST)
			KEY_4:
				_set_tool(Tool.HARVEST)
			KEY_C:
				_take_cutting_from_farmer_plot()
			KEY_I:
				_show_plot_info()
			KEY_Q:
				_select_variety(maxi(selected_variety - 1, 0))
			KEY_E:
				_select_variety(mini(selected_variety + 1, varieties.size() - 1))
			KEY_SPACE:
				_start_next_day()
			KEY_W, KEY_UP:
				_move_farmer(Vector2i(0, -1))
			KEY_S, KEY_DOWN:
				_move_farmer(Vector2i(0, 1))
			KEY_A, KEY_LEFT:
				_move_farmer(Vector2i(-1, 0))
			KEY_D, KEY_RIGHT:
				_move_farmer(Vector2i(1, 0))
			KEY_F, KEY_ENTER, KEY_KP_ENTER:
				_use_farmer_tool()
			KEY_F5:
				call("_save_game")
			KEY_F9:
				call("_load_game")


func _draw() -> void:
	_draw_background()
	_draw_top_hud_bar()
	_draw_sidebar()
	_draw_farm()
	_draw_farmer()
	_draw_side_scene()
	_draw_open_drawer()
	_draw_message_toast()
	_draw_bottom_status_bar()
	_draw_dialogue_popup()
	_draw_pause_overlay()


func _build_plots() -> void:
	for y in GRID_H:
		var row: Array = []
		for x in GRID_W:
			row.append({
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
			})
		plots.append(row)


func _is_mobile_layout() -> bool:
	return LayoutSystem.is_mobile_layout(get_viewport_rect().size)

func _update_layout() -> bool:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size == last_layout_size and farm_origin != Vector2.ZERO:
		return false
	last_layout_size = viewport_size
	if _is_mobile_layout():
		var available_width: float = maxf(1.0, viewport_size.x - float(SCREEN_PAD * 2 + LEFT_DOCK_W + GAP))
		tile_size = clampi(int(floor(available_width / float(GRID_W))), 42, BASE_TILE)
	else:
		tile_size = BASE_TILE
	var board_size: Vector2 = _farm_board_size()
	var play_left: float = float(SCREEN_PAD + LEFT_DOCK_W + GAP)
	var play_right: float = viewport_size.x - float(SCREEN_PAD)
	if not _is_mobile_layout():
		play_right -= float(DRAWER_W + GAP)
	var play_width: float = maxf(board_size.x, play_right - play_left)
	farm_board_position = Vector2(play_left + maxf(0.0, (play_width - board_size.x) * 0.5), float(HUD_H + GAP + 12))
	if _is_mobile_layout():
		farm_board_position = Vector2(float(SCREEN_PAD + LEFT_DOCK_W + GAP), float(HUD_H + GAP))
	farm_origin = farm_board_position + Vector2(26, 26)
	return true


func _viewport_size() -> Vector2:
	return get_viewport_rect().size


func _hud_rect() -> Rect2:
	return LayoutSystem.hud_rect(SCREEN_PAD, HUD_H, _viewport_size())

func _hud_row_one_pos() -> Vector2:
	return LayoutSystem.hud_row_one_pos(_hud_rect())

func _hud_row_two_pos() -> Vector2:
	return LayoutSystem.hud_row_two_pos(_hud_rect())

func _left_dock_rect() -> Rect2:
	return LayoutSystem.left_dock_rect(SCREEN_PAD, HUD_H, LEFT_DOCK_W, BOTTOM_BAR_H, GAP, _viewport_size(), _is_mobile_layout())

func _tool_pocket_rect() -> Rect2:
	return LayoutSystem.tool_pocket_rect(_left_dock_rect())

func _menu_pocket_rect() -> Rect2:
	return LayoutSystem.menu_pocket_rect(_left_dock_rect())

func _tool_column_pos() -> Vector2:
	return LayoutSystem.tool_column_pos(_tool_pocket_rect())

func _menu_column_pos() -> Vector2:
	return LayoutSystem.menu_column_pos(_menu_pocket_rect())

func _drawer_rect() -> Rect2:
	return LayoutSystem.drawer_rect(SCREEN_PAD, HUD_H, DRAWER_W, BOTTOM_BAR_H, GAP, _viewport_size(), _is_mobile_layout())

func _drawer_content_pos() -> Vector2:
	return LayoutSystem.drawer_content_pos(_drawer_rect())

func _drawer_content_size() -> Vector2:
	return LayoutSystem.drawer_content_size(_drawer_rect())

func _drawer_hint_pos() -> Vector2:
	return LayoutSystem.drawer_hint_pos(_drawer_rect())

func _drawer_hint_size() -> Vector2:
	return LayoutSystem.drawer_hint_size(_drawer_rect())

func _farm_board_size() -> Vector2:
	return LayoutSystem.farm_board_size(GRID_W, GRID_H, tile_size)

func _farm_board_rect() -> Rect2:
	return LayoutSystem.farm_board_rect(farm_board_position, _farm_board_size())

func _plot_bed_rect() -> Rect2:
	return LayoutSystem.plot_bed_rect(farm_origin, GRID_W, GRID_H, tile_size)

func _bottom_status_rect() -> Rect2:
	return LayoutSystem.bottom_status_rect(SCREEN_PAD, BOTTOM_BAR_H, GAP, _viewport_size(), _farm_board_rect(), _is_mobile_layout())

func _bottom_card_rect(index: int) -> Rect2:
	return LayoutSystem.bottom_card_rect(index, GAP, _bottom_status_rect())

func _bottom_action_label_pos() -> Vector2:
	return LayoutSystem.bottom_action_label_pos(_bottom_card_rect(0))

func _plot_card_label_pos() -> Vector2:
	return LayoutSystem.plot_card_label_pos(_bottom_card_rect(1))

func _bottom_card_label_size() -> Vector2:
	return LayoutSystem.bottom_card_label_size(_bottom_card_rect(0))

func _message_label_pos() -> Vector2:
	return LayoutSystem.message_label_pos(_bottom_status_rect())

func _message_label_size() -> Vector2:
	return LayoutSystem.message_label_size(_bottom_status_rect())

func _apply_layout_to_controls() -> void:
	if top_bar != null:
		top_bar.position = _hud_row_one_pos()
	if hud_second_row != null:
		hud_second_row.position = _hud_row_two_pos()
	if dock_tool_row != null:
		dock_tool_row.position = _tool_column_pos()
	if tab_row != null:
		tab_row.position = _menu_column_pos()
	if tool_section_label != null:
		tool_section_label.position = _tool_pocket_rect().position + Vector2(10, 4)
		tool_section_label.custom_minimum_size = Vector2(_tool_pocket_rect().size.x - 20, 14)
	if menu_section_label != null:
		menu_section_label.position = _menu_pocket_rect().position + Vector2(10, 4)
		menu_section_label.custom_minimum_size = Vector2(_menu_pocket_rect().size.x - 20, 14)
	for panel in [controls_panel, market_panel, pantry_panel, guide_panel, help_panel]:
		if panel != null:
			panel.position = _drawer_content_pos()
			panel.custom_minimum_size = _drawer_content_size()
	if bottom_action_label != null:
		bottom_action_label.position = _bottom_action_label_pos()
		bottom_action_label.custom_minimum_size = _bottom_card_label_size()
	if plot_card_label != null:
		plot_card_label.position = _plot_card_label_pos()
		plot_card_label.custom_minimum_size = _bottom_card_label_size()
	if dock_hint_label != null:
		dock_hint_label.position = _drawer_hint_pos()
		dock_hint_label.custom_minimum_size = _drawer_hint_size()
	if message_label != null:
		message_label.position = _message_label_pos()
		message_label.custom_minimum_size = _message_label_size()
	if order_scroll != null:
		order_scroll.custom_minimum_size = Vector2(_drawer_content_size().x, 130)


func _hud_label_width(key: String) -> int:
	return LayoutSystem.hud_label_width(key)

func _build_sfx() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -10.0
	add_child(sfx_player)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -25.0
	add_child(music_player)
	sfx_library["plant"] = AudioLibrary.make_tone(260.0, 0.10, 0.20)
	sfx_library["water"] = AudioLibrary.make_tone(540.0, 0.12, 0.16)
	sfx_library["compost"] = AudioLibrary.make_tone(190.0, 0.11, 0.18)
	sfx_library["harvest"] = AudioLibrary.make_tone(760.0, 0.12, 0.18)
	sfx_library["sell"] = AudioLibrary.make_tone(880.0, 0.10, 0.18)
	sfx_library["order"] = AudioLibrary.make_tone(660.0, 0.14, 0.18)
	sfx_library["day"] = AudioLibrary.make_tone(420.0, 0.14, 0.16)
	sfx_library["pause"] = AudioLibrary.make_tone(320.0, 0.08, 0.16)
	sfx_library["save"] = AudioLibrary.make_tone(620.0, 0.08, 0.14)
	var music_stream: AudioStream = load("res://assets/audio/fig_farmer_loop.wav") as AudioStream
	if music_stream != null:
		music_player.stream = music_stream
	_sync_music()


func _sync_music() -> void:
	if music_player == null:
		return
	if sound_enabled:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()


func _play_sfx(name: String) -> void:
	if not sound_enabled:
		return
	if sfx_player == null:
		return
	if not sfx_library.has(name):
		return
	sfx_player.stop()
	sfx_player.stream = sfx_library[name]
	sfx_player.play()


func _texture_from(group: Dictionary, key: String) -> Texture2D:
	if not group.has(key):
		return null
	var texture: Texture2D = group[key] as Texture2D
	return texture


func _apply_button_icon(button: Button, texture: Texture2D) -> void:
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
	button.text = ""


func _decorate_button_icon(button: Button, texture: Texture2D) -> void:
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = false


func _tool_texture(tool: int) -> Texture2D:
	match tool:
		Tool.PLANT:
			return _texture_from(tool_textures, "plant")
		Tool.WATER:
			return _texture_from(tool_textures, "water")
		Tool.COMPOST:
			return _texture_from(tool_textures, "compost")
		Tool.HARVEST:
			return _texture_from(tool_textures, "harvest")
	return null


func _tab_texture(tab: int) -> Texture2D:
	match tab:
		0:
			return _texture_from(ui_textures, "farm")
		1:
			return _texture_from(ui_textures, "orders")
		2:
			return _texture_from(ui_textures, "pantry")
		3:
			return _texture_from(ui_textures, "guide")
		4:
			return _texture_from(ui_textures, "help")
	return null


func _draw_texture_centered(texture: Texture2D, center: Vector2, size: Vector2) -> void:
	if texture == null:
		return
	var rect: Rect2 = Rect2(center - size * 0.5, size)
	draw_texture_rect(texture, rect, false)


func _build_ui() -> void:
	var ui: CanvasLayer = CanvasLayer.new()
	add_child(ui)

	top_bar = HBoxContainer.new()
	top_bar.position = _hud_row_one_pos()
	top_bar.add_theme_constant_override("separation", 8)
	ui.add_child(top_bar)

	for key in ["Day", "Coins", "Water", "Cuts", "Figs", "Compost", "Rep"]:
		if key == "Figs":
			hud_fig_icon = TextureRect.new()
			hud_fig_icon.custom_minimum_size = Vector2(20, 20)
			hud_fig_icon.texture = _texture_from(item_textures, "fig")
			hud_fig_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			top_bar.add_child(hud_fig_icon)
		var label: Label = Label.new()
		label.custom_minimum_size = Vector2(_hud_label_width(key), 24)
		_style_label(label, 15, Color("#31401f"))
		top_bar.add_child(label)
		hud_labels[key] = label

	hud_second_row = HBoxContainer.new()
	hud_second_row.position = _hud_row_two_pos()
	hud_second_row.add_theme_constant_override("separation", 12)
	ui.add_child(hud_second_row)
	for key in ["Weather", "Guide"]:
		var label: Label = Label.new()
		label.custom_minimum_size = Vector2(_hud_label_width(key), 20)
		label.clip_text = true
		_style_label(label, 13, Color("#31401f"))
		hud_second_row.add_child(label)
		hud_labels[key] = label

	pause_label = Label.new()
	pause_label.position = Vector2(690, 42)
	pause_label.custom_minimum_size = Vector2(58, 24)
	_style_label(pause_label, 15, Color("#4b2d1c"))
	ui.add_child(pause_label)

	pause_overlay_title = Label.new()
	pause_overlay_title.position = Vector2(350, 250)
	pause_overlay_title.custom_minimum_size = Vector2(150, 28)
	pause_overlay_title.text = "Paused"
	_style_label(pause_overlay_title, 26, Color("#3b2b19"))
	ui.add_child(pause_overlay_title)

	pause_overlay_hint = Label.new()
	pause_overlay_hint.position = Vector2(306, 286)
	pause_overlay_hint.custom_minimum_size = Vector2(236, 24)
	pause_overlay_hint.text = "Press P, Esc, or Resume"
	_style_label(pause_overlay_hint, 14, Color("#5b492e"))
	ui.add_child(pause_overlay_hint)

	dock_tool_row = VBoxContainer.new()
	dock_tool_row.position = _tool_column_pos()
	dock_tool_row.add_theme_constant_override("separation", GAP / 2)
	ui.add_child(dock_tool_row)

	tool_section_label = Label.new()
	tool_section_label.text = "TOOLS"
	_style_label(tool_section_label, 10, Color(MUTED_TEXT))
	ui.add_child(tool_section_label)

	_add_tool_button(dock_tool_row, "🌱", Tool.PLANT)
	_add_tool_button(dock_tool_row, "💧", Tool.WATER)
	_add_tool_button(dock_tool_row, "🟤", Tool.COMPOST)
	_add_tool_button(dock_tool_row, "✂", Tool.HARVEST)

	tab_row = VBoxContainer.new()
	tab_row.position = _menu_column_pos()
	tab_row.add_theme_constant_override("separation", GAP / 2)
	ui.add_child(tab_row)

	menu_section_label = Label.new()
	menu_section_label.text = "MENUS"
	_style_label(menu_section_label, 10, Color(MUTED_TEXT))
	ui.add_child(menu_section_label)

	_add_tab_button(tab_row, "Farm", 0)
	_add_tab_button(tab_row, "Orders", 1)
	_add_tab_button(tab_row, "Pantry", 2)
	_add_tab_button(tab_row, "Guide", 3)
	_add_tab_button(tab_row, "Help", 4)

	controls_panel = VBoxContainer.new()
	controls_panel.position = _drawer_content_pos()
	controls_panel.custom_minimum_size = _drawer_content_size()
	controls_panel.add_theme_constant_override("separation", 5)
	ui.add_child(controls_panel)

	var title: Label = Label.new()
	title.text = "Fig Farmer 🌿"
	_style_label(title, 26, Color("#3b2b19"))
	controls_panel.add_child(title)


	_add_section_label(controls_panel, "CUTTINGS")
	var variety_row: HBoxContainer = HBoxContainer.new()
	variety_row.add_theme_constant_override("separation", 5)
	controls_panel.add_child(variety_row)
	for i in varieties.size():
		_add_variety_button(variety_row, i)

	action_hint = Label.new()
	action_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_hint.custom_minimum_size = Vector2(376, 24)
	_style_label(action_hint, 13, Color("#4c3c25"))
	controls_panel.add_child(action_hint)

	_add_section_label(controls_panel, "SHOP")
	var shop_row: HBoxContainer = HBoxContainer.new()
	shop_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(shop_row)
	buy_cuttings_button = Button.new()
	buy_cuttings_button.custom_minimum_size = Vector2(184, 32)
	_style_button(buy_cuttings_button, 13, "secondary")
	_decorate_button_icon(buy_cuttings_button, _texture_from(item_textures, "seeds"))
	buy_cuttings_button.pressed.connect(_buy_cuttings)
	shop_row.add_child(buy_cuttings_button)
	var buy_compost: Button = Button.new()
	buy_compost.text = "💰 Compost x2        $7"
	buy_compost.custom_minimum_size = Vector2(184, 32)
	_style_button(buy_compost, 13, "secondary")
	_decorate_button_icon(buy_compost, _texture_from(item_textures, "fertilizer"))
	buy_compost.pressed.connect(_buy_compost)
	shop_row.add_child(buy_compost)

	clipping_row = HBoxContainer.new()
	clipping_row.add_theme_constant_override("separation", 0)
	controls_panel.add_child(clipping_row)
	clipping_button = Button.new()
	clipping_button.text = "Clip cutting (C)"
	clipping_button.custom_minimum_size = Vector2(376, 28)
	_style_button(clipping_button, 12, "muted")
	clipping_button.pressed.connect(func() -> void: call("_take_cutting_from_farmer_plot"))
	clipping_row.add_child(clipping_button)

	var upgrade_row: HBoxContainer = HBoxContainer.new()
	upgrade_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(upgrade_row)
	barrel_button = Button.new()
	barrel_button.custom_minimum_size = Vector2(184, 32)
	_style_button(barrel_button, 13, "secondary")
	_decorate_button_icon(barrel_button, _texture_from(item_textures, "barrel"))
	barrel_button.pressed.connect(_buy_barrel_upgrade)
	upgrade_row.add_child(barrel_button)
	garden_button = Button.new()
	garden_button.custom_minimum_size = Vector2(184, 32)
	_style_button(garden_button, 13, "secondary")
	_decorate_button_icon(garden_button, _texture_from(item_textures, "flower"))
	garden_button.pressed.connect(_buy_pollinator_garden)
	upgrade_row.add_child(garden_button)

	_add_section_label(controls_panel, "DAY")
	var day_row: HBoxContainer = HBoxContainer.new()
	day_row.add_theme_constant_override("separation", 0)
	controls_panel.add_child(day_row)
	var day_button: Button = Button.new()
	day_button.text = "🌙  End Day"
	day_button.custom_minimum_size = Vector2(376, 34)
	_style_button(day_button, 13, "action")
	day_button.pressed.connect(_start_next_day)
	day_row.add_child(day_button)

	var save_row: HBoxContainer = HBoxContainer.new()
	save_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(save_row)
	save_button = Button.new()
	save_button.text = "▣ Save"
	save_button.custom_minimum_size = Vector2(88, 30)
	_style_button(save_button, 12, "secondary")
	save_button.pressed.connect(func() -> void: call("_save_game"))
	save_row.add_child(save_button)
	load_button = Button.new()
	load_button.text = "▣ Load"
	load_button.custom_minimum_size = Vector2(88, 30)
	_style_button(load_button, 12, "secondary")
	load_button.pressed.connect(func() -> void: call("_load_game"))
	save_row.add_child(load_button)
	pause_button = Button.new()
	pause_button.custom_minimum_size = Vector2(88, 30)
	_style_button(pause_button, 12, "secondary")
	pause_button.pressed.connect(func() -> void: call("_toggle_pause"))
	save_row.add_child(pause_button)
	sound_button = Button.new()
	sound_button.custom_minimum_size = Vector2(88, 30)
	_style_button(sound_button, 12, "secondary")
	sound_button.pressed.connect(func() -> void: call("_toggle_sound"))
	save_row.add_child(sound_button)

	market_panel = VBoxContainer.new()
	market_panel.position = _drawer_content_pos()
	market_panel.custom_minimum_size = _drawer_content_size()
	market_panel.add_theme_constant_override("separation", 4)
	ui.add_child(market_panel)

	var market_title: Label = Label.new()
	market_title.text = "Order Board"
	_style_label(market_title, 24, Color("#3b2b19"))
	market_panel.add_child(market_title)

	_add_section_label(market_panel, "WEEKLY TABLE")
	festival_label = Label.new()
	festival_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	festival_label.custom_minimum_size = Vector2(376, 36)
	_style_label(festival_label, 14, Color("#4c3c25"))
	market_panel.add_child(festival_label)

	_add_section_label(market_panel, "SELECTED ORDER")
	order_label = Label.new()
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_label.custom_minimum_size = Vector2(376, 52)
	_style_label(order_label, 14, Color("#4c3c25"))
	market_panel.add_child(order_label)

	_add_section_label(market_panel, "POSTED ORDERS")
	order_scroll = ScrollContainer.new()
	order_scroll.custom_minimum_size = Vector2(376, 130)
	market_panel.add_child(order_scroll)
	order_list = VBoxContainer.new()
	order_list.add_theme_constant_override("separation", 6)
	order_scroll.add_child(order_list)
	for i in 5:
		_add_order_button(order_list, i)

	inventory_label = Label.new()
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.custom_minimum_size = Vector2(376, 24)
	_style_label(inventory_label, 13, Color("#5b492e"))
	market_panel.add_child(inventory_label)

	_add_section_label(market_panel, "STATUS")
	relationship_label = Label.new()
	relationship_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relationship_label.custom_minimum_size = Vector2(376, 24)
	_style_label(relationship_label, 13, Color("#5b492e"))
	market_panel.add_child(relationship_label)

	_add_section_label(market_panel, "LOGBOOK")
	logbook_label = Label.new()
	logbook_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	logbook_label.custom_minimum_size = Vector2(376, 44)
	logbook_label.clip_text = true
	_style_label(logbook_label, 12, Color("#4c3c25"))
	market_panel.add_child(logbook_label)

	var market_row: HBoxContainer = HBoxContainer.new()
	market_row.add_theme_constant_override("separation", 8)
	market_panel.add_child(market_row)
	accept_order_button = Button.new()
	accept_order_button.text = "Accept"
	accept_order_button.custom_minimum_size = Vector2(120, 34)
	_style_button(accept_order_button, 13, "action")
	accept_order_button.pressed.connect(func() -> void: call("_accept_selected_order"))
	market_row.add_child(accept_order_button)
	fulfill_order_button = Button.new()
	fulfill_order_button.text = "Fulfill"
	fulfill_order_button.custom_minimum_size = Vector2(120, 34)
	_style_button(fulfill_order_button, 13, "primary")
	fulfill_order_button.pressed.connect(func() -> void: call("_fulfill_order"))
	market_row.add_child(fulfill_order_button)
	var crate_button: Button = Button.new()
	crate_button.text = "Sell crate"
	crate_button.custom_minimum_size = Vector2(120, 34)
	_style_button(crate_button, 13, "secondary")
	crate_button.pressed.connect(_sell_crate)
	market_row.add_child(crate_button)

	pantry_panel = VBoxContainer.new()
	pantry_panel.position = _drawer_content_pos()
	pantry_panel.custom_minimum_size = _drawer_content_size()
	pantry_panel.add_theme_constant_override("separation", 6)
	ui.add_child(pantry_panel)

	var pantry_title: Label = Label.new()
	pantry_title.text = "Farm Pantry"
	_style_label(pantry_title, 25, Color("#3b2b19"))
	pantry_panel.add_child(pantry_title)

	_add_section_label(pantry_panel, "HARVEST")
	pantry_figs_label = Label.new()
	pantry_figs_label.custom_minimum_size = Vector2(376, 74)
	pantry_figs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(pantry_figs_label, 13, Color("#3d2e1c"))
	pantry_panel.add_child(pantry_figs_label)

	_add_section_label(pantry_panel, "PLANTING STOCK")
	pantry_cuttings_label = Label.new()
	pantry_cuttings_label.custom_minimum_size = Vector2(376, 58)
	pantry_cuttings_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(pantry_cuttings_label, 13, Color("#3d2e1c"))
	pantry_panel.add_child(pantry_cuttings_label)

	_add_section_label(pantry_panel, "PRESERVES")
	pantry_preserves_label = Label.new()
	pantry_preserves_label.custom_minimum_size = Vector2(376, 48)
	pantry_preserves_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(pantry_preserves_label, 13, Color("#3d2e1c"))
	pantry_panel.add_child(pantry_preserves_label)

	preserve_label = Label.new()
	preserve_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preserve_label.custom_minimum_size = Vector2(376, 26)
	_style_label(preserve_label, 12, Color("#5b492e"))
	pantry_panel.add_child(preserve_label)

	var preserve_row: HBoxContainer = HBoxContainer.new()
	preserve_row.add_theme_constant_override("separation", 7)
	pantry_panel.add_child(preserve_row)
	buy_jars_button = Button.new()
	buy_jars_button.text = "Buy jars"
	buy_jars_button.custom_minimum_size = Vector2(88, 32)
	_style_button(buy_jars_button, 12, "secondary")
	buy_jars_button.pressed.connect(func() -> void: call("_buy_mason_jars"))
	preserve_row.add_child(buy_jars_button)
	make_jam_button = Button.new()
	make_jam_button.text = "Make jam"
	make_jam_button.custom_minimum_size = Vector2(88, 32)
	_style_button(make_jam_button, 12, "action")
	_decorate_button_icon(make_jam_button, _texture_from(item_textures, "jam"))
	make_jam_button.pressed.connect(func() -> void: call("_make_jam"))
	preserve_row.add_child(make_jam_button)
	sell_jam_button = Button.new()
	sell_jam_button.text = "Sell jam"
	sell_jam_button.custom_minimum_size = Vector2(88, 32)
	_style_button(sell_jam_button, 12, "secondary")
	_decorate_button_icon(sell_jam_button, _texture_from(item_textures, "jam"))
	sell_jam_button.pressed.connect(func() -> void: call("_sell_jam"))
	preserve_row.add_child(sell_jam_button)
	recipe_button = Button.new()
	recipe_button.text = "Recipe"
	recipe_button.custom_minimum_size = Vector2(88, 32)
	_style_button(recipe_button, 12, "secondary")
	recipe_button.pressed.connect(func() -> void: call("_show_recipe"))
	preserve_row.add_child(recipe_button)

	_add_section_label(pantry_panel, "TREES")
	pantry_trees_label = Label.new()
	pantry_trees_label.custom_minimum_size = Vector2(376, 54)
	pantry_trees_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(pantry_trees_label, 13, Color("#3d2e1c"))
	pantry_panel.add_child(pantry_trees_label)

	pantry_hint_label = Label.new()
	pantry_hint_label.custom_minimum_size = Vector2(376, 38)
	pantry_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(pantry_hint_label, 12, Color("#5b492e"))
	pantry_panel.add_child(pantry_hint_label)

	guide_panel = VBoxContainer.new()
	guide_panel.position = _drawer_content_pos()
	guide_panel.custom_minimum_size = _drawer_content_size()
	guide_panel.add_theme_constant_override("separation", 10)
	ui.add_child(guide_panel)

	var guide_title: Label = Label.new()
	guide_title.text = "Fig Guide"
	_style_label(guide_title, 26, Color("#3b2b19"))
	guide_panel.add_child(guide_title)

	_add_section_label(guide_panel, "CULTIVAR")
	notebook_label = Label.new()
	notebook_label.custom_minimum_size = Vector2(376, 66)
	notebook_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(notebook_label, 14, Color("#332414"))
	guide_panel.add_child(notebook_label)

	_add_section_label(guide_panel, "SELECTED PLOT")
	plot_status_label = Label.new()
	plot_status_label.custom_minimum_size = Vector2(376, 132)
	plot_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(plot_status_label, 13, Color("#3d2e1c"))
	guide_panel.add_child(plot_status_label)

	_add_section_label(guide_panel, "VISUAL KEY")
	var moisture_key_row: HBoxContainer = HBoxContainer.new()
	moisture_key_row.add_theme_constant_override("separation", 14)
	guide_panel.add_child(moisture_key_row)
	_add_moisture_key(moisture_key_row, Color("#6f4a34"), "Wet")
	_add_moisture_key(moisture_key_row, Color("#8f6040"), "Moist")
	_add_moisture_key(moisture_key_row, Color("#bd8352"), "Dry")

	guide_legend_label = Label.new()
	guide_legend_label.custom_minimum_size = Vector2(376, 150)
	guide_legend_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(guide_legend_label, 13, Color("#4d3b24"))
	guide_panel.add_child(guide_legend_label)

	help_panel = VBoxContainer.new()
	help_panel.position = _drawer_content_pos()
	help_panel.custom_minimum_size = _drawer_content_size()
	help_panel.add_theme_constant_override("separation", 10)
	ui.add_child(help_panel)

	var help_title: Label = Label.new()
	help_title.text = "How to Play"
	_style_label(help_title, 26, Color("#3b2b19"))
	help_panel.add_child(help_title)

	_add_section_label(help_panel, "QUICK START")
	var help_text: Label = Label.new()
	help_text.custom_minimum_size = Vector2(376, 344)
	help_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_text.text = _how_to_play_text()
	_style_label(help_text, 13, Color("#3d2e1c"))
	help_panel.add_child(help_text)

	bottom_action_label = Label.new()
	bottom_action_label.position = _bottom_action_label_pos()
	bottom_action_label.custom_minimum_size = _bottom_card_label_size()
	bottom_action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(bottom_action_label, 13, Color("#2f3b1f"))
	ui.add_child(bottom_action_label)

	plot_card_label = Label.new()
	plot_card_label.position = _plot_card_label_pos()
	plot_card_label.custom_minimum_size = _bottom_card_label_size()
	plot_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(plot_card_label, 12, Color("#2f3b1f"))
	ui.add_child(plot_card_label)

	dock_hint_label = Label.new()
	dock_hint_label.position = _drawer_hint_pos()
	dock_hint_label.custom_minimum_size = _drawer_hint_size()
	dock_hint_label.clip_text = true
	_style_label(dock_hint_label, 11, Color("#725431"))
	ui.add_child(dock_hint_label)

	message_label = Label.new()
	message_label.position = _message_label_pos()
	message_label.custom_minimum_size = _message_label_size()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(message_label, 13, Color("#2f3b1f"))
	ui.add_child(message_label)


	dialogue_title_label = Label.new()
	dialogue_title_label.position = Vector2(418, 218)
	dialogue_title_label.custom_minimum_size = Vector2(372, 30)
	_style_label(dialogue_title_label, 22, Color("#3b2b19"))
	ui.add_child(dialogue_title_label)

	dialogue_body_label = Label.new()
	dialogue_body_label.position = Vector2(418, 256)
	dialogue_body_label.custom_minimum_size = Vector2(438, 190)
	dialogue_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(dialogue_body_label, 14, Color("#3d2e1c"))
	ui.add_child(dialogue_body_label)

	dialogue_close_button = Button.new()
	dialogue_close_button.text = "Close"
	dialogue_close_button.position = Vector2(744, 462)
	dialogue_close_button.custom_minimum_size = Vector2(112, 32)
	_style_button(dialogue_close_button, 13, "secondary")
	dialogue_close_button.pressed.connect(func() -> void: call("_close_dialogue"))
	ui.add_child(dialogue_close_button)
	_apply_layout_to_controls()


func _add_section_label(parent: Control, text: String) -> void:
	var spacer: ColorRect = ColorRect.new()
	spacer.color = Color(1.0, 1.0, 1.0, 0.0)
	spacer.custom_minimum_size = Vector2(376, 6)
	parent.add_child(spacer)
	var label: Label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(376, 13)
	_style_label(label, 10, Color("#725431"))
	parent.add_child(label)


func _add_tab_button(parent: Control, text: String, tab: int) -> void:
	var button: Button = Button.new()
	button.text = _tab_icon(tab)
	button.tooltip_text = text
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(TOOL_BUTTON_SIZE, TOOL_BUTTON_SIZE)
	_style_button(button, 18, _tab_role(tab))
	_apply_button_icon(button, _tab_texture(tab))
	button.pressed.connect(func() -> void: call("_set_side_tab", tab))
	parent.add_child(button)
	tab_buttons[tab] = button


func _tab_role(tab: int) -> String:
	match tab:
		0:
			return "tab_farm"
		1:
			return "tab_orders"
		2:
			return "tab_pantry"
		3:
			return "tab_guide"
		4:
			return "tab_help"
	return "nav"


func _tab_icon(tab: int) -> String:
	match tab:
		0:
			return "🏡"
		1:
			return "📋"
		2:
			return "🧺"
		3:
			return "📖"
		4:
			return "?"
	return "•"


func _set_side_tab(tab: int) -> void:
	var next_tab: int = clampi(tab, 0, 4)
	if panel_open and side_tab == next_tab:
		panel_open = false
	else:
		side_tab = next_tab
		panel_open = true
	_update_ui()


func _add_order_button(parent: Control, slot: int) -> void:
	var button: Button = Button.new()
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(376, 42)
	button.clip_text = true
	_style_button(button, 12, "secondary")
	button.pressed.connect(func() -> void: call("_select_order_slot", slot))
	parent.add_child(button)
	order_buttons.append(button)


func _add_moisture_key(parent: Control, swatch_color: Color, label_text: String) -> void:
	var group: HBoxContainer = HBoxContainer.new()
	group.add_theme_constant_override("separation", 4)
	parent.add_child(group)
	var swatch: ColorRect = ColorRect.new()
	swatch.color = swatch_color
	swatch.custom_minimum_size = Vector2(18, 18)
	group.add_child(swatch)
	var label: Label = Label.new()
	label.text = label_text
	_style_label(label, 12, Color("#4d3b24"))
	group.add_child(label)


func _style_label(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 1.0, 0.28))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)


func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	return style


func _rounded_box(fill: Color, border: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
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


func _draw_rounded_box(rect: Rect2, fill: Color, border: Color, radius: int, border_width: int = 1) -> void:
	draw_style_box(_rounded_box(fill, border, radius, border_width), rect)


func _style_button(button: Button, size: int, role: String = "neutral") -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", size)
	var fill: Color = Color("#efe0c2")
	var hover: Color = Color("#f7ead0")
	var pressed: Color = Color("#d7bd78")
	var border: Color = Color("#a37a43")
	var font_color: Color = Color("#3b2b19")
	if role == "nav":
		fill = Color("#ead9bb")
		hover = Color("#f4e7ce")
		pressed = Color("#cda56a")
		border = Color("#b58d58")
		font_color = Color("#3b2b19")
	elif role == "tab_farm":
		fill = Color("#dce8bf")
		hover = Color("#e9f2d3")
		pressed = Color("#b7d084")
		border = Color("#82a04c")
	elif role == "tab_orders":
		fill = Color("#f0d59c")
		hover = Color("#f7e3b9")
		pressed = Color("#d3aa62")
		border = Color("#aa7a35")
	elif role == "tab_pantry":
		fill = Color("#eecfb0")
		hover = Color("#f5ddc4")
		pressed = Color("#cf9a68")
		border = Color("#a36a38")
	elif role == "tab_guide":
		fill = Color("#d3e4ea")
		hover = Color("#e3f0f3")
		pressed = Color("#9fc2cf")
		border = Color("#6c97a6")
	elif role == "tab_help":
		fill = Color("#eee2c9")
		hover = Color("#f7ecd8")
		pressed = Color("#d5bc8e")
		border = Color("#ab8954")
	elif role == "muted":
		fill = Color("#ddd3be")
		hover = Color("#e5dac7")
		pressed = Color("#c8bca7")
		border = Color("#c1b29a")
		font_color = Color("#8a8170")
	elif role == "primary":
		fill = Color("#5d7f35")
		hover = Color("#6d9141")
		pressed = Color("#3f6125")
		border = Color("#31491e")
		font_color = Color("#fff8e8")
	elif role == "water":
		fill = Color("#4f83a0")
		hover = Color("#6197b4")
		pressed = Color("#376984")
		border = Color("#2f5368")
		font_color = Color("#fff8e8")
	elif role == "compost":
		fill = Color("#8b6535")
		hover = Color("#9b7645")
		pressed = Color("#6c4d2a")
		border = Color("#5c3e21")
		font_color = Color("#fff8e8")
	elif role == "harvest":
		fill = Color("#66406b")
		hover = Color("#78517d")
		pressed = Color("#4d2d52")
		border = Color("#3c243f")
		font_color = Color("#fff8e8")
	elif role == "action":
		fill = Color("#638532")
		hover = Color("#73983e")
		pressed = Color("#456321")
		border = Color("#365019")
		font_color = Color("#fff8e8")
	elif role == "secondary":
		fill = Color("#f4ead6")
		hover = Color("#fff4df")
		pressed = Color("#dfc996")
		border = Color("#c5a66f")
	button.add_theme_stylebox_override("normal", _button_style(fill, border))
	button.add_theme_stylebox_override("hover", _button_style(hover, border))
	button.add_theme_stylebox_override("pressed", _button_style(pressed, border))
	button.add_theme_stylebox_override("disabled", _button_style(Color("#c8c0ae"), Color("#8f826e")))
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color("#5f574b"))


func _add_tool_button(parent: Control, text: String, tool: int) -> void:
	var button: Button = Button.new()
	button.text = text
	button.tooltip_text = "%s  [%s]" % [_tool_name(tool), _tool_shortcut(tool)]
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(TOOL_BUTTON_SIZE, TOOL_BUTTON_SIZE)
	var role: String = "primary"
	match tool:
		Tool.WATER:
			role = "water"
		Tool.COMPOST:
			role = "compost"
		Tool.HARVEST:
			role = "harvest"
	_style_button(button, 20, role)
	_apply_button_icon(button, _tool_texture(tool))
	button.pressed.connect(func() -> void: _set_tool(tool))
	parent.add_child(button)
	if not tool_buttons.has(tool):
		tool_buttons[tool] = []
	var buttons: Array = tool_buttons[tool]
	buttons.append(button)
	tool_buttons[tool] = buttons


func _add_variety_button(parent: Control, index: int) -> void:
	var variety: Dictionary = varieties[index]
	var button: Button = Button.new()
	button.text = String(variety["short"])
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(90, 34)
	_style_button(button, 12, "secondary")
	button.pressed.connect(func() -> void: _select_variety(index))
	parent.add_child(button)
	variety_buttons[index] = button


func _draw_background() -> void:
	var weather: Dictionary = weather_table[current_weather]
	var viewport: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(String(weather["sky"])))
	var ground_y: float = float(HUD_H + GAP + 24)
	draw_rect(Rect2(Vector2(0, ground_y), Vector2(viewport.x, viewport.y - ground_y)), Color(String(weather["ground"])))
	_draw_soft_hill(Vector2(-80, ground_y + 80), Vector2(viewport.x + 160.0, 170), Color(String(weather["ground"])).lightened(0.10))
	_draw_soft_hill(Vector2(80, ground_y + 144), Vector2(viewport.x + 80.0, 190), Color(String(weather["ground"])).darkened(0.04))
	_draw_background_trees(ground_y)
	draw_circle(Vector2(viewport.x - 240.0, 86), 42, Color("#ffd76a"))
	_draw_farm_board()
	if String(weather["name"]) == "Rain":
		for i in 18:
			var start: Vector2 = Vector2(28 + i * 68, 86 + (i % 3) * 19)
			draw_line(start, start + Vector2(-12, 30), Color("#6b93a8"), 2.0)
	elif String(weather["name"]) == "Heat":
		for i in 5:
			var y: int = 126 + i * 28
			draw_arc(Vector2(610, y), 38, 0.2, 2.9, 18, Color("#d18b42"), 2.0)


func _draw_soft_hill(pos: Vector2, size: Vector2, color: Color) -> void:
	var center: Vector2 = pos + Vector2(size.x * 0.5, size.y)
	draw_arc(center, size.x * 0.5, PI, TAU, 40, color, size.y)


func _draw_background_trees(ground_y: float) -> void:
	for i in 7:
		var x: float = 56.0 + float(i) * 188.0
		var base_y: float = ground_y + 52.0 + float(i % 2) * 18.0
		draw_line(Vector2(x, base_y + 42.0), Vector2(x, base_y - 18.0), Color("#6b4329"), 8.0)
		draw_circle(Vector2(x - 18.0, base_y - 18.0), 24.0, Color(0.25, 0.45, 0.22, 0.24))
		draw_circle(Vector2(x + 12.0, base_y - 24.0), 28.0, Color(0.25, 0.45, 0.22, 0.22))
		draw_circle(Vector2(x, base_y - 44.0), 22.0, Color(0.25, 0.45, 0.22, 0.20))


func _draw_open_drawer() -> void:
	if not panel_open:
		return
	_draw_ui_panel(_drawer_rect())
	_draw_drawer_cards()


func _draw_drawer_cards() -> void:
	var content: Rect2 = Rect2(_drawer_content_pos(), _drawer_content_size())
	var card_x: float = content.position.x
	var card_w: float = content.size.x
	match side_tab:
		0:
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 48), Vector2(card_w, 116)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 186), Vector2(card_w, 158)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 368), Vector2(card_w, 176)))
		1:
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 48), Vector2(card_w, 66)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 128), Vector2(card_w, 98)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 244), Vector2(card_w, 158)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 418), Vector2(card_w, 58)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 492), Vector2(card_w, 68)))
		2:
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 48), Vector2(card_w, 92)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 162), Vector2(card_w, 78)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 262), Vector2(card_w, 110)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 394), Vector2(card_w, 98)))
		3:
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 48), Vector2(card_w, 112)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 182), Vector2(card_w, 184)))
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 396), Vector2(card_w, 164)))
		4:
			_draw_drawer_card(Rect2(Vector2(card_x, content.position.y + 48), Vector2(card_w, minf(470.0, content.size.y - 64.0))))


func _draw_drawer_card(rect: Rect2) -> void:
	draw_style_box(_rounded_box(Color(0.82, 0.65, 0.36, 0.12), Color(0.82, 0.65, 0.36, 0.0), 10), Rect2(rect.position + Vector2(1, 2), rect.size))
	_draw_rounded_box(rect, Color("#fffaf0"), Color("#ead6aa"), 10, 1)


func _draw_top_hud_bar() -> void:
	var rect: Rect2 = _hud_rect()
	draw_style_box(_rounded_box(Color(0.13, 0.08, 0.04, 0.18), Color(0.13, 0.08, 0.04, 0.0), 12), Rect2(rect.position + Vector2(2, 3), rect.size))
	_draw_rounded_box(rect, Color("#7a5229"), Color("#5b3a1d"), 12, 1)
	_draw_rounded_box(rect.grow(-3), Color("#a9793a"), Color("#8b612e"), 9, 1)
	_draw_rounded_box(rect.grow(-7), Color("#f4dfb4"), Color("#d4b16d"), 6, 1)


func _draw_sidebar() -> void:
	var rect: Rect2 = _left_dock_rect()
	draw_style_box(_rounded_box(Color(0.13, 0.08, 0.04, 0.20), Color(0.13, 0.08, 0.04, 0.0), 16), Rect2(rect.position + Vector2(3, 5), rect.size))
	_draw_rounded_box(rect, Color("#7a5a35"), Color("#5b4228"), 16, 2)
	_draw_rounded_box(rect.grow(-5), Color("#f0ddb5"), Color("#c9a96a"), 12, 1)
	_draw_rounded_box(_tool_pocket_rect(), Color(BG_CREAM), Color("#ead6aa"), 9, 1)
	_draw_rounded_box(_menu_pocket_rect(), Color(BG_CREAM), Color("#ead6aa"), 9, 1)
	draw_line(_tool_pocket_rect().position + Vector2(10, 10), _tool_pocket_rect().position + Vector2(_tool_pocket_rect().size.x - 10, 10), Color(0.50, 0.36, 0.18, 0.20), 1.0)
	draw_line(_menu_pocket_rect().position + Vector2(10, 10), _menu_pocket_rect().position + Vector2(_menu_pocket_rect().size.x - 10, 10), Color(0.50, 0.36, 0.18, 0.20), 1.0)


func _draw_farm_board() -> void:
	var board_rect: Rect2 = _farm_board_rect()
	draw_style_box(_rounded_box(Color(0.13, 0.08, 0.04, 0.20), Color(0.13, 0.08, 0.04, 0.0), 18), Rect2(board_rect.position + Vector2(4, 6), board_rect.size))
	_draw_rounded_box(board_rect, Color("#7a552f"), Color("#5b3b21"), 18, 2)
	_draw_rounded_box(board_rect.grow(-7), Color("#d3b16a"), Color("#9b713d"), 13, 1)
	_draw_rounded_box(board_rect.grow(-14), Color("#c99a58"), Color("#8e6536"), 10, 1)
	var plot_bed: Rect2 = _plot_bed_rect()
	_draw_rounded_box(plot_bed, Color("#be8a50"), Color("#744923"), 10, 1)
	for i in 10:
		var grass_pos: Vector2 = Vector2(board_rect.position.x + 30 + i * 58, board_rect.end.y - 18 + (i % 2) * 5)
		draw_line(grass_pos, grass_pos + Vector2(-5, -12), Color("#4f7f35"), 2.0)
		draw_line(grass_pos, grass_pos + Vector2(6, -10), Color("#5c913f"), 2.0)


func _draw_ui_panel(rect: Rect2) -> void:
	draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 16), Rect2(rect.position + Vector2(3, 4), rect.size))
	_draw_rounded_box(rect, Color("#7a5a35"), Color("#5b4228"), 16, 2)
	_draw_rounded_box(rect.grow(-4), Color("#f0ddb5"), Color("#c9a96a"), 13, 1)
	_draw_rounded_box(rect.grow(-14), Color("#fff8e8"), Color("#ead6aa"), 10, 1)


func _draw_dialogue_popup() -> void:
	if not dialogue_visible:
		return
	var rect: Rect2 = Rect2(Vector2(388, 186), Vector2(504, 324))
	draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.24), Color(0.16, 0.10, 0.05, 0.0), 18), Rect2(rect.position + Vector2(4, 6), rect.size))
	_draw_rounded_box(rect, Color("#7a5a35"), Color("#5b4228"), 18, 2)
	_draw_rounded_box(rect.grow(-6), Color("#f0ddb5"), Color("#c9a96a"), 14, 1)
	_draw_rounded_box(rect.grow(-18), Color("#fff8e8"), Color("#ead6aa"), 10, 1)
	draw_line(Vector2(416, 250), Vector2(862, 250), Color(0.50, 0.36, 0.18, 0.22), 1.5)


func _draw_message_toast() -> void:
	if message_timer <= 0.0:
		return
	var rect: Rect2 = Rect2(_message_label_pos() - Vector2(8, 6), _message_label_size() + Vector2(16, 12))
	draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 10), Rect2(rect.position + Vector2(2, 3), rect.size))
	_draw_rounded_box(rect, Color("#d7bd78"), Color("#6a4d2e"), 10, 1)
	_draw_rounded_box(rect.grow(-7), Color("#fff9e9"), Color("#e8d29d"), 6, 1)


func _draw_pause_overlay() -> void:
	if not game_paused:
		return
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.10, 0.08, 0.05, 0.36))
	var rect: Rect2 = Rect2(Vector2(272, 228), Vector2(296, 92))
	draw_rect(rect, Color(0.20, 0.14, 0.09, 0.90))
	draw_rect(rect.grow(-5), Color("#f3dfb8"))
	draw_rect(rect.grow(-16), Color("#fff6df"))
	draw_rect(rect, Color("#4f3722"), false, 3.0)


func _draw_bottom_status_bar() -> void:
	var rect: Rect2 = _bottom_status_rect()
	draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 14), Rect2(rect.position + Vector2(3, 4), rect.size))
	_draw_rounded_box(rect, Color("#d7bd78"), Color("#6a4d2e"), 14, 1)
	_draw_rounded_box(rect.grow(-7), Color("#fff9e9"), Color("#e8d29d"), 10, 1)
	var action_rect: Rect2 = _bottom_card_rect(0)
	var plot_rect: Rect2 = _bottom_card_rect(1)
	_draw_rounded_box(action_rect, Color("#fffdf2"), Color("#d8c78e"), 8, 1)
	_draw_rounded_box(plot_rect, Color("#fffdf2"), Color("#d8c78e"), 8, 1)


func _draw_farm() -> void:
	for y in GRID_H:
		for x in GRID_W:
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
			draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.18), Color(0.16, 0.10, 0.05, 0.0), 8), Rect2(rect.position + Vector2(3, 4), rect.size))
			_draw_rounded_box(rect, soil, Color("#50321f"), 8, 2)
			_draw_plot_texture(rect)
			if bool(plot.get("planted", false)) and int(plot.get("moisture", 0)) <= 0:
				_draw_dry_cracks(rect)
			if bool(plot["composted"]):
				_draw_compost_specks(rect)
			_draw_plot_plant(rect, plot)
			_draw_plot_state_markers(rect, plot)
			if selected_cell == Vector2i(x, y):
				_draw_rounded_box(rect.grow(4), Color(1.0, 1.0, 1.0, 0.0), Color("#ffe98a"), 10, 3)
			if farmer_cell == Vector2i(x, y):
				_draw_rounded_box(rect.grow(8), Color(1.0, 1.0, 1.0, 0.0), Color("#fff6c7"), 12, 2)


func _draw_plot_state_markers(rect: Rect2, plot: Dictionary) -> void:
	if not bool(plot.get("planted", false)):
		return
	var variety_index: int = int(plot["variety"])
	_draw_variety_tag(rect, variety_index)
	if bool(plot["watered"]):
		_draw_water_drop(rect.position + Vector2(rect.size.x - 15, 15))
		_draw_water_drop(rect.position + Vector2(rect.size.x - 27, 24))
	if int(plot["stage"]) >= 3:
		var ripe_days: int = int(plot.get("ripe_days", 0))
		var ring_color: Color = Color("#f1cf5a")
		if ripe_days == 1:
			ring_color = Color("#fff07a")
		elif ripe_days == 2:
			ring_color = Color("#d9a24d")
		elif ripe_days >= 3:
			ring_color = Color("#6b3a2d")
		_draw_rounded_box(rect.grow(5), Color(1.0, 1.0, 1.0, 0.0), ring_color, 12, 3)
		if ripe_days == 1:
			_draw_peak_sparkles(rect.position + rect.size * 0.5)


func _draw_variety_tag(rect: Rect2, variety_index: int) -> void:
	var marker_color: Color = _variety_marker_color(variety_index)
	var marker_rect: Rect2 = Rect2(rect.end - Vector2(18, 18), Vector2(12, 12))
	_draw_rounded_box(marker_rect, marker_color, Color("#2a1d14"), 3, 1)


func _variety_marker_color(variety_index: int) -> Color:
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


func _draw_water_drop(pos: Vector2) -> void:
	draw_circle(pos + Vector2(0, 3), 4, Color("#5ca4d8"))
	draw_colored_polygon([pos + Vector2(0, -6), pos + Vector2(-4, 2), pos + Vector2(4, 2)], Color("#5ca4d8"))


func _draw_peak_sparkles(center: Vector2) -> void:
	for offset in [Vector2(-28, -24), Vector2(28, -20), Vector2(24, 24)]:
		var p: Vector2 = center + offset
		draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color("#fff07a"), 2.0)
		draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color("#fff07a"), 2.0)


func _draw_dry_cracks(rect: Rect2) -> void:
	for i in 3:
		var start: Vector2 = rect.position + Vector2(16 + i * 17, 18 + (i % 2) * 18)
		draw_line(start, start + Vector2(10, 5), Color(0.28, 0.16, 0.09, 0.55), 2.0)
		draw_line(start + Vector2(10, 5), start + Vector2(16, 1), Color(0.28, 0.16, 0.09, 0.55), 1.5)


func _draw_plot_texture(rect: Rect2) -> void:
	for i in 3:
		var y: float = rect.position.y + 20.0 + i * 16.0
		draw_line(Vector2(rect.position.x + 12.0, y), Vector2(rect.end.x - 14.0, y + 2.0), Color(0.31, 0.18, 0.10, 0.45), 1.5)


func _draw_compost_specks(rect: Rect2) -> void:
	for i in 4:
		var dot: Vector2 = rect.position + Vector2(14 + i * 13, rect.size.y - 18 - (i % 2) * 11)
		draw_circle(dot, 3, Color("#d3b65b"))


func _draw_plot_plant(rect: Rect2, plot: Dictionary) -> void:
	if not bool(plot["planted"]):
		if bool(plot.get("harvested_marker", false)):
			var harvested_texture: Texture2D = _texture_from(crop_textures, "harvested")
			if harvested_texture != null:
				_draw_texture_centered(harvested_texture, rect.position + rect.size * 0.5 + Vector2(0, 1), Vector2(rect.size.x + 6.0, rect.size.y + 6.0))
				return
		draw_line(rect.position + Vector2(12, rect.size.y - 14), rect.end - Vector2(12, 14), Color("#6e3f27"), 2.0)
		return
	var center: Vector2 = rect.position + rect.size * 0.5
	var crop_texture: Texture2D = _crop_texture_for_plot(plot)
	if crop_texture != null:
		var sprite_size: Vector2 = Vector2(rect.size.x + 8.0, rect.size.y + 8.0)
		if crop_texture.get_width() > 64:
			sprite_size = Vector2(rect.size.x + 22.0, rect.size.y + 22.0)
		_draw_texture_centered(crop_texture, center + Vector2(0, 1), sprite_size)
	else:
		draw_line(center + Vector2(0, 22), center + Vector2(0, -14), Color("#6b3f24"), 6.0)
		draw_circle(center + Vector2(0, -18), 16, Color("#3f8738"))
	if bool(plot["bonus"]):
		_draw_bee_icon(center + Vector2(23, -24), 0.72)
	if _can_take_cutting(plot):
		var clip_pos: Vector2 = rect.position + Vector2(16, 14)
		draw_line(clip_pos + Vector2(0, 9), clip_pos + Vector2(0, -4), Color("#4f7f35"), 3.0)
		draw_circle(clip_pos + Vector2(-5, -3), 4, Color("#8fcf5b"))
		draw_circle(clip_pos + Vector2(5, -5), 4, Color("#8fcf5b"))


func _crop_texture_for_plot(plot: Dictionary) -> Texture2D:
	var stage: int = int(plot.get("stage", 0))
	var variety_index: int = int(plot.get("variety", 0))
	var progress: int = int(plot.get("progress", 0))
	var grow_days: int = int(varieties[variety_index]["grow_days"])
	if stage >= 3:
		if variety_index == 2:
			return _texture_from(crop_textures, "ripe_green")
		return _texture_from(crop_textures, "ripe_purple")
	if progress <= 0:
		return _texture_from(crop_textures, "cutting")
	if grow_days <= 2:
		if progress <= 1:
			return _texture_from(crop_textures, "young")
		return _texture_from(crop_textures, "growing")
	if progress == 1:
		return _texture_from(crop_textures, "sprout")
	if progress <= maxi(2, grow_days - 2):
		return _texture_from(crop_textures, "young")
	return _texture_from(crop_textures, "growing")


func _draw_bee_icon(pos: Vector2, scale: float = 1.0) -> void:
	draw_circle(pos + Vector2(-5, -5) * scale, 5.0 * scale, Color(1.0, 1.0, 1.0, 0.55))
	draw_circle(pos + Vector2(5, -5) * scale, 5.0 * scale, Color(1.0, 1.0, 1.0, 0.55))
	draw_circle(pos + Vector2(-3, 1) * scale, 6.0 * scale, Color("#ffd45c"))
	draw_circle(pos + Vector2(3, 1) * scale, 6.0 * scale, Color("#ffd45c"))
	draw_line(pos + Vector2(-3, -4) * scale, pos + Vector2(-3, 6) * scale, Color("#5d3b18"), 2.0 * scale)
	draw_line(pos + Vector2(3, -4) * scale, pos + Vector2(3, 6) * scale, Color("#5d3b18"), 2.0 * scale)
	draw_circle(pos + Vector2(9, 1) * scale, 3.0 * scale, Color("#2c1a14"))


func _draw_side_scene() -> void:
	_draw_farm_props()
	if pollinator_garden:
		var board: Rect2 = _farm_board_rect()
		var flower_texture: Texture2D = _texture_from(item_textures, "flower")
		for i in 10:
			var flower_center: Vector2 = Vector2(board.position.x + 34.0 + float(i) * 34.0, board.end.y - 22.0 - float(i % 2) * 8.0)
			if flower_texture != null:
				_draw_texture_centered(flower_texture, flower_center, Vector2(28, 28))
			else:
				draw_line(flower_center + Vector2(0, 12), flower_center, Color("#3f7b35"), 2.0)
				draw_circle(flower_center + Vector2(-4, 0), 4, Color("#d86f90"))
				draw_circle(flower_center + Vector2(4, 0), 4, Color("#d86f90"))
				draw_circle(flower_center + Vector2(0, -4), 4, Color("#ffd966"))
		for i in 3:
			_draw_bee_icon(Vector2(board.position.x + 84.0 + float(i) * 118.0, board.position.y + 28.0 + float(i % 2) * 30.0), 0.82)


func _current_tool_is_usable() -> bool:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	match current_tool:
		Tool.PLANT:
			return not bool(plot["planted"]) and cuttings[selected_variety] > 0
		Tool.WATER:
			return bool(plot["planted"]) and not bool(plot["watered"]) and water > 0
		Tool.COMPOST:
			return bool(plot["planted"]) and not bool(plot["composted"]) and compost > 0
		Tool.HARVEST:
			return bool(plot["planted"]) and int(plot["stage"]) >= 3
	return false


func _draw_farmer_tool_icon(pos: Vector2) -> void:
	draw_circle(pos, 12, Color("#fff6df"))
	draw_circle(pos, 12, Color("#4f3722"), false, 2.0)
	var texture: Texture2D = _tool_texture(current_tool)
	if texture != null:
		_draw_texture_centered(texture, pos, Vector2(23, 23))
		return
	draw_circle(pos, 5, Color("#5d7f35"))


func _draw_farm_props() -> void:
	var barrel_pos: Vector2 = Vector2(174, 504)
	var barrel_texture: Texture2D = _texture_from(item_textures, "barrel")
	if barrel_texture != null:
		_draw_texture_centered(barrel_texture, barrel_pos + Vector2(17, 26), Vector2(42, 54))
	else:
		_draw_rounded_box(Rect2(barrel_pos, Vector2(34, 52)), Color("#8e5a32"), Color("#4b2d1c"), 4, 2)
		draw_rect(Rect2(barrel_pos + Vector2(4, 8), Vector2(26, 8)), Color("#5d7fa3"))
	var sign_rect: Rect2 = Rect2(Vector2(828, 516), Vector2(58, 34))
	var crate_texture: Texture2D = _texture_from(item_textures, "crate")
	if crate_texture != null:
		_draw_texture_centered(crate_texture, sign_rect.position + sign_rect.size * 0.5, Vector2(54, 42))
	else:
		_draw_rounded_box(sign_rect, Color("#a46b3a"), Color("#5a3520"), 4, 2)
		draw_line(sign_rect.position + Vector2(8, 11), sign_rect.position + Vector2(sign_rect.size.x - 8, 11), Color("#754521"), 2.0)
		draw_line(sign_rect.position + Vector2(8, 23), sign_rect.position + Vector2(sign_rect.size.x - 8, 23), Color("#754521"), 2.0)
	draw_line(Vector2(204, 570), Vector2(832, 570), Color("#d4b16d"), 8.0)


func _draw_farmer() -> void:
	var bob: float = sin(farmer_step_bob) * 1.8
	var base: Vector2 = farmer_pos + Vector2(0, bob)
	draw_circle(base + Vector2(0, 18), 16, Color(0.13, 0.09, 0.05, 0.22))
	draw_line(base + Vector2(-7, 8), base + Vector2(-11, 22), Color("#263b4d"), 4.0)
	draw_line(base + Vector2(7, 8), base + Vector2(11, 22), Color("#263b4d"), 4.0)
	draw_rect(Rect2(base + Vector2(-12, -19), Vector2(24, 28)), Color("#5f8f52"))
	draw_rect(Rect2(base + Vector2(-12, -19), Vector2(24, 28)), Color("#2f4d2c"), false, 2.0)
	draw_line(base + Vector2(-12, -8), base + Vector2(-24, 2), Color("#8b5a3c"), 4.0)
	draw_line(base + Vector2(12, -8), base + Vector2(24, 2), Color("#8b5a3c"), 4.0)
	draw_circle(base + Vector2(0, -30), 13, Color("#b7784e"))
	draw_rect(Rect2(base + Vector2(-17, -44), Vector2(34, 7)), Color("#d2a64d"))
	draw_colored_polygon([base + Vector2(-11, -43), base + Vector2(11, -43), base + Vector2(6, -56), base + Vector2(-6, -56)], Color("#d2a64d"))
	draw_circle(base + Vector2(-4, -32), 2, Color("#2c1a14"))
	draw_circle(base + Vector2(5, -32), 2, Color("#2c1a14"))
	draw_line(base + Vector2(-4, -25), base + Vector2(5, -24), Color("#2c1a14"), 1.5)
	if _current_tool_is_usable():
		_draw_farmer_tool_icon(base + Vector2(27, -18))


func _move_farmer(delta_cell: Vector2i) -> void:
	var next_cell: Vector2i = farmer_cell + delta_cell
	if not _is_cell_inside(next_cell):
		return
	farmer_cell = next_cell
	selected_cell = farmer_cell
	_mark_ui_dirty()


func _use_farmer_tool() -> void:
	selected_cell = farmer_cell
	_handle_plot_click(farmer_cell)


func _info_cell() -> Vector2i:
	if _is_cell_inside(selected_cell):
		return selected_cell
	return farmer_cell


func _info_cell_label(cell: Vector2i) -> String:
	if cell == farmer_cell:
		return "Current plot"
	return "Hover plot"


func _cell_center(cell: Vector2i) -> Vector2:
	return farm_origin + Vector2(cell.x * tile_size + (tile_size - 8) * 0.5, cell.y * tile_size + (tile_size - 8) * 0.5)


func _handle_plot_click(cell: Vector2i) -> void:
	var plot: Dictionary = plots[cell.y][cell.x]
	match current_tool:
		Tool.PLANT:
			_plant_plot(plot)
		Tool.WATER:
			_water_plot(plot)
		Tool.COMPOST:
			_compost_plot(plot)
		Tool.HARVEST:
			_harvest_plot(plot)


func _take_cutting_from_farmer_plot() -> void:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	if not bool(plot["planted"]):
		_say("Cuttings come from living fig wood. Plant a tree here first.")
		return
	if not _can_take_cutting(plot):
		_say("This fig is too young for cuttings. Let it establish or ripen first.")
		return
	var variety_index: int = int(plot["variety"])
	cuttings[variety_index] += 1
	plot["progress"] = maxi(0, int(plot["progress"]) - 1)
	var grow_days: int = int(varieties[variety_index]["grow_days"])
	var recalculated_stage: int = mini(3, int(floor((float(int(plot["progress"])) / float(grow_days)) * 3.0)))
	plot["stage"] = maxi(2, recalculated_stage)
	plot["ripe_days"] = 0
	plot["bonus"] = false
	_play_sfx("harvest")
	_say("Clipped one %s cutting. Fig cultivars are usually propagated by cuttings, which clone the parent tree." % _variety_name(variety_index))


func _can_take_cutting(plot: Dictionary) -> bool:
	return CropSystem.can_take_cutting(plot, varieties)

func _plant_plot(plot: Dictionary) -> void:
	if bool(plot["planted"]):
		_say("That plot already has a fig tree.")
		return
	if cuttings[selected_variety] <= 0:
		_say("No %s cuttings left. Buy more from the shop." % _variety_name(selected_variety))
		return
	cuttings[selected_variety] -= 1
	plot["planted"] = true
	plot["variety"] = selected_variety
	plot["stage"] = 0
	plot["progress"] = 0
	plot["watered"] = _is_rainy()
	plot["moisture"] = 1
	if _is_rainy():
		plot["moisture"] = 2
	plot["quality"] = 1
	plot["bonus"] = false
	plot["composted"] = false
	plot["ripe_days"] = 0
	plot["harvested_marker"] = false
	if selected_variety == 0:
		_advance_tutorial(0)
	_play_sfx("plant")
	_say("Planted %s. In real gardens figs often need 1-3 years to bear; this game compresses that into watered days." % _variety_name(selected_variety))


func _water_plot(plot: Dictionary) -> void:
	if not bool(plot["planted"]):
		_say("Water helps trees, but this soil is empty.")
		return
	if bool(plot["watered"]):
		_say("This tree is already watered. Deep, steady watering matters most while young or fruiting.")
		return
	if water <= 0:
		_say("The barrel is empty. A dry day slows growth, and heat can lower fig quality.")
		return
	water -= 1
	plot["watered"] = true
	plot["moisture"] = 2
	plot["quality"] = int(plot["quality"]) + 1
	_advance_tutorial(1)
	_play_sfx("water")
	if randf() < _pollinator_chance():
		plot["bonus"] = true
		_say("A pollinator visit marked this tree for extra sweet figs.")
	else:
		_say("The tree drinks deeply. Watered days move it closer to fruit.")


func _compost_plot(plot: Dictionary) -> void:
	if not bool(plot["planted"]):
		_say("Compost works best around planted trees.")
		return
	if bool(plot["composted"]):
		_say("This tree already has compost around its roots.")
		return
	if compost <= 0:
		_say("No compost left. Buy a bag from the shop.")
		return
	compost -= 1
	plot["composted"] = true
	plot["quality"] = int(plot["quality"]) + 2
	_play_sfx("compost")
	_say("Compost added. This tree should give better figs.")


func _harvest_plot(plot: Dictionary) -> void:
	if not bool(plot["planted"]):
		_say("Nothing to harvest here yet.")
		return
	if int(plot["stage"]) < 3:
		_say("These figs need more time. Figs sweeten on the tree and should be picked soft and ripe.")
		return
	var variety_index: int = int(plot["variety"])
	var ripe_days: int = int(plot.get("ripe_days", 0))
	var ripeness_bonus: int = _ripeness_yield_bonus(ripe_days)
	var harvest: int = maxi(1, 2 + int(plot["quality"]) + int(varieties[variety_index]["yield_bonus"]) + ripeness_bonus)
	if bool(plot["bonus"]):
		harvest += 2
	if bool(plot["composted"]):
		harvest += 1
	fig_bins[variety_index] += harvest
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
	_advance_tutorial(3)
	_play_sfx("harvest")
	_say("Harvested %s %s figs. %s" % [harvest, _variety_name(variety_index), _ripeness_harvest_note(ripe_days)])


func _start_next_day() -> void:
	day += 1
	time_left = DAY_LENGTH
	_play_sfx("day")
	_roll_weather()
	water = mini(_max_water(), water + 4 + barrel_level)
	var weather_name: String = _weather_name()
	var grew_count: int = 0
	var dried_count: int = 0
	var ripened_count: int = 0
	var softened_count: int = 0
	var order_tick_count: int = accepted_orders.size()
	for y in GRID_H:
		for x in GRID_W:
			var plot: Dictionary = plots[y][x]
			if not bool(plot.get("planted", false)):
				plot["harvested_marker"] = false
			if bool(plot["planted"]):
				var old_progress: int = int(plot.get("progress", 0))
				var old_stage: int = int(plot.get("stage", 0))
				var old_moisture: int = int(plot.get("moisture", 0))
				var old_ripe_days: int = int(plot.get("ripe_days", 0))
				if weather_name == "Rain":
					plot["watered"] = true
					plot["moisture"] = 2
					old_moisture = mini(old_moisture, 1)
				_advance_tree(plot)
				_update_plot_moisture(plot, weather_name)
				if int(plot.get("progress", 0)) > old_progress:
					grew_count += 1
				if int(plot.get("moisture", 0)) < old_moisture:
					dried_count += 1
				if old_stage < 3 and int(plot.get("stage", 0)) >= 3:
					ripened_count += 1
				elif int(plot.get("stage", 0)) >= 3 and int(plot.get("ripe_days", 0)) > old_ripe_days:
					softened_count += 1
				plot["watered"] = false
	var expired_orders: Array[String] = _order_day_passed()
	if _has_ripe_tree():
		_advance_tutorial(2)
	var extra_note: String = ""
	if randf() < 0.22:
		var free_index: int = randi_range(0, varieties.size() - 1)
		cuttings[free_index] += 1
		extra_note = "Neighbor shared %s." % _variety_name(free_index)
	var summary_text: String = _day_summary_text(grew_count, dried_count, ripened_count, softened_count, order_tick_count, expired_orders.size(), weather_name, extra_note)
	if (day - 1) % FESTIVAL_LENGTH == 0:
		_resolve_festival_week(weather_name, summary_text)
		return
	_say(summary_text)


func _update_plot_moisture(plot: Dictionary, weather_name: String) -> void:
	CropSystem.update_plot_moisture(plot, weather_name)

func _advance_tree(plot: Dictionary) -> void:
	CropSystem.advance_tree(plot, varieties, _weather_name())

func _fulfill_order() -> void:
	if not _selected_order_is_accepted():
		_say("Accept an order before fulfilling it. Browsing offers has no Trust penalty.")
		return
	var accepted_index: int = selected_order_index
	if accepted_index < 0 or accepted_index >= accepted_orders.size():
		_say("Choose an accepted order first.")
		return
	var order_data: Dictionary = accepted_orders[accepted_index]
	var need: int = int(order_data["need"])
	var variety_index: int = int(order_data["variety"])
	if variety_index >= 0:
		if fig_bins[variety_index] < need:
			_say("%s still needs %s %s figs." % [String(order_data["customer"]), need, _variety_name(variety_index)])
			return
		fig_bins[variety_index] -= need
	else:
		if _total_figs() < need:
			_say("The order needs %s figs total." % need)
			return
		_take_any_figs(need)
	var customer: String = String(order_data["customer"])
	_advance_tutorial(4)
	var relationship_gain: int = 1
	if int(order_data["patience"]) >= 3:
		relationship_gain += 1
	var new_friendship: int = int(relationships.get(customer, 0)) + relationship_gain
	relationships[customer] = new_friendship
	var milestone_note: String = _grant_relationship_milestone(customer, new_friendship)
	festival_progress += need
	coins += int(order_data["reward"])
	reputation += 1
	if reputation % 3 == 0:
		compost += 1
	accepted_orders.remove_at(accepted_index)
	_normalize_selected_order()
	var complete_message: String = "Order complete for %s. Friendship +%s and weekly table +%s." % [customer, relationship_gain, need]
	if milestone_note != "":
		complete_message += " " + milestone_note
	_log_event("Order done: %s +%s figs, Trust +1, $%s." % [_short_customer_name(customer), need, int(order_data["reward"])])
	_play_sfx("order")
	_say(complete_message)


func _make_jam() -> void:
	var needed_figs: int = 5
	if _total_figs() < needed_figs:
		_say("Jam needs 5 figs. Save mixed ripe figs, then preserve them.")
		return
	if mason_jars <= 0:
		_say("Jam needs an empty mason jar. Buy jars at the market first.")
		return
	_take_any_figs(needed_figs)
	mason_jars -= 1
	jam_jars += 1
	_log_event("Made jam: 5 figs became 1 jar.")
	_play_sfx("order")
	_say("Made 1 jar of fig jam: ripe figs, sugar, lemon juice, then simmer until thick.")


func _sell_jam() -> void:
	if jam_jars <= 0:
		_say("No jam jars ready to sell.")
		return
	var sold_jars: int = jam_jars
	var payout: int = sold_jars * 18
	var festival_credit: int = sold_jars * 5
	coins += payout
	festival_progress += festival_credit
	_log_event("Sold jam: +$%s, weekly table +%s figs." % [payout, festival_credit])
	_play_sfx("sell")
	_say("Sold %s of fig jam for %s coins. Weekly table +%s figs." % [_jar_count_text(sold_jars), payout, festival_credit])
	jam_jars = 0


func _buy_mason_jars() -> void:
	if coins < 6:
		_say("Three clean mason jars cost 6 coins.")
		return
	coins -= 6
	mason_jars += 3
	_play_sfx("sell")
	_say("Bought three mason jars for preserves.")


func _show_recipe() -> void:
	recipe_expanded = true
	_show_dialogue("Fig Jam Recipe", _recipe_card_text())
	_update_ui()


func _sell_crate() -> void:
	var total: int = _total_figs()
	if total <= 0:
		_say("No harvested figs to sell yet.")
		return
	var payout: int = 0
	for i in fig_bins.size():
		payout += fig_bins[i] * int(varieties[i]["value"])
		fig_bins[i] = 0
	coins += payout
	festival_progress += total
	_log_event("Sold crate: +$%s, weekly table +%s figs." % [payout, total])
	_play_sfx("sell")
	_say("Sold a mixed crate for %s coins. Weekly table +%s figs." % [payout, total])


func _make_order_offer() -> Dictionary:
	return OrderSystem.make_order_offer(GameData.order_templates(), reputation, relationships)

func _refresh_order_offers() -> void:
	order_offers.clear()
	var open_slots: int = maxi(0, 5 - accepted_orders.size())
	if open_slots <= 0:
		_normalize_selected_order()
		return
	var target_total: int = randi_range(1, 5)
	var offer_count: int = clampi(target_total - accepted_orders.size(), 1, open_slots)
	for i in offer_count:
		order_offers.append(_make_order_offer())
	_normalize_selected_order()


func _new_order() -> void:
	_refresh_order_offers()


func _order_day_passed() -> Array[String]:
	var kept_orders: Array[Dictionary] = []
	var expired_names: Array[String] = []
	for order_data in accepted_orders:
		order_data["patience"] = int(order_data["patience"]) - 1
		if int(order_data["patience"]) <= 0:
			var customer: String = String(order_data["customer"])
			reputation = maxi(0, reputation - 1)
			relationships[customer] = maxi(0, int(relationships.get(customer, 0)) - 1)
			expired_names.append(_short_customer_name(customer))
		else:
			kept_orders.append(order_data)
	accepted_orders = kept_orders
	_refresh_order_offers()
	if expired_names.size() > 0:
		_log_event("Expired accepted order: %s. Trust dipped." % ", ".join(expired_names))
	return expired_names


func _buy_cuttings() -> void:
	var cost: int = int(varieties[selected_variety]["seed_cost"])
	if coins < cost:
		_say("A %s starter tree costs %s coins." % [_variety_name(selected_variety), cost])
		return
	coins -= cost
	cuttings[selected_variety] += 1
	_play_sfx("sell")
	_say("Bought one %s starter tree for planting." % _variety_name(selected_variety))


func _buy_compost() -> void:
	if coins < 7:
		_say("A compost bag costs 7 coins.")
		return
	coins -= 7
	compost += 2
	_play_sfx("sell")
	_say("Bought two compost bags.")


func _buy_barrel_upgrade() -> void:
	var cost: int = 18 + barrel_level * 10
	if barrel_level >= 3:
		_say("The barrel is already as big as the stall can build.")
		return
	if coins < cost:
		_say("The next barrel upgrade costs %s coins." % cost)
		return
	coins -= cost
	barrel_level += 1
	water = _max_water()
	_play_sfx("sell")
	_say("Barrel upgraded. More water fits now.")


func _buy_pollinator_garden() -> void:
	if pollinator_garden:
		_say("The pollinator garden is already blooming.")
		return
	if coins < 24:
		_say("The pollinator garden costs 24 coins.")
		return
	coins -= 24
	pollinator_garden = true
	_play_sfx("sell")
	_say("Flowers planted by the fence. Sweet harvests are more likely.")


func _save_game() -> void:
	var data: Dictionary = {
		"version": 1,
		"day": day,
		"time_left": time_left,
		"coins": coins,
		"water": water,
		"compost": compost,
		"reputation": reputation,
		"sound_enabled": sound_enabled,
		"tutorial_index": tutorial_index,
		"festival_week": festival_week,
		"festival_goal": festival_goal,
		"festival_progress": festival_progress,
		"relationships": relationships,
		"cuttings": cuttings,
		"fig_bins": fig_bins,
		"jam_jars": jam_jars,
		"mason_jars": mason_jars,
		"recipe_expanded": recipe_expanded,
		"barrel_level": barrel_level,
		"pollinator_garden": pollinator_garden,
		"current_weather": current_weather,
		"temperature_f": temperature_f,
		"order_offers": order_offers,
		"accepted_orders": accepted_orders,
		"selected_order_index": selected_order_index,
		"game_log": game_log,
		"selected_variety": selected_variety,
		"current_tool": current_tool,
		"side_tab": side_tab,
		"panel_open": panel_open,
		"farmer_x": farmer_cell.x,
		"farmer_y": farmer_cell.y,
		"plots": plots
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_say("Could not save the farm right now.")
		return
	file.store_string(JSON.stringify(data))
	_play_sfx("save")
	_say("Farm saved. You can come back to this fig season later.")


func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_say("No saved farm found yet.")
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_say("Could not open the saved farm.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_say("That save file could not be read.")
		return
	var data: Dictionary = parsed as Dictionary
	day = int(data.get("day", day))
	time_left = float(data.get("time_left", DAY_LENGTH))
	coins = int(data.get("coins", coins))
	water = int(data.get("water", water))
	compost = int(data.get("compost", compost))
	reputation = int(data.get("reputation", reputation))
	sound_enabled = bool(data.get("sound_enabled", sound_enabled))
	_sync_music()
	tutorial_index = clampi(int(data.get("tutorial_index", tutorial_index)), 0, 5)
	festival_week = int(data.get("festival_week", festival_week))
	festival_goal = mini(int(data.get("festival_goal", festival_goal)), _festival_goal_for_week())
	festival_progress = int(data.get("festival_progress", festival_progress))
	var loaded_relationships: Variant = data.get("relationships", relationships)
	if typeof(loaded_relationships) == TYPE_DICTIONARY:
		relationships = loaded_relationships as Dictionary
	cuttings = _read_int_array(data.get("cuttings", cuttings), varieties.size(), 0)
	fig_bins = _read_int_array(data.get("fig_bins", fig_bins), varieties.size(), 0)
	jam_jars = int(data.get("jam_jars", jam_jars))
	mason_jars = int(data.get("mason_jars", mason_jars))
	recipe_expanded = bool(data.get("recipe_expanded", recipe_expanded))
	barrel_level = int(data.get("barrel_level", barrel_level))
	pollinator_garden = bool(data.get("pollinator_garden", pollinator_garden))
	current_weather = clampi(int(data.get("current_weather", current_weather)), 0, weather_table.size() - 1)
	temperature_f = int(data.get("temperature_f", temperature_f))
	order_offers = _read_order_array(data.get("order_offers", []))
	accepted_orders = _read_order_array(data.get("accepted_orders", []))
	if order_offers.is_empty() and accepted_orders.is_empty():
		var legacy_order: Variant = data.get("order", {})
		if typeof(legacy_order) == TYPE_DICTIONARY:
			var legacy_dict: Dictionary = legacy_order as Dictionary
			if not legacy_dict.is_empty():
				legacy_dict["accepted"] = false
				order_offers.append(legacy_dict)
	selected_order_index = int(data.get("selected_order_index", selected_order_index))
	game_log = _read_string_array(data.get("game_log", game_log), 8)
	if order_offers.is_empty() and accepted_orders.is_empty():
		_refresh_order_offers()
	_normalize_selected_order()
	selected_variety = clampi(int(data.get("selected_variety", selected_variety)), 0, varieties.size() - 1)
	current_tool = clampi(int(data.get("current_tool", current_tool)), Tool.PLANT, Tool.HARVEST)
	side_tab = clampi(int(data.get("side_tab", side_tab)), 0, 4)
	panel_open = bool(data.get("panel_open", panel_open))
	var loaded_plots: Variant = data.get("plots", plots)
	var normalized_plots: Array = _read_plots_array(loaded_plots)
	if not normalized_plots.is_empty():
		plots = normalized_plots
	farmer_cell = Vector2i(clampi(int(data.get("farmer_x", farmer_cell.x)), 0, GRID_W - 1), clampi(int(data.get("farmer_y", farmer_cell.y)), 0, GRID_H - 1))
	selected_cell = farmer_cell
	farmer_pos = _cell_center(farmer_cell)
	_update_ui()
	_play_sfx("save")
	_say("Farm loaded. Back to the figs.")


func _default_plot() -> Dictionary:
	return SaveSystem.default_plot()

func _normalize_plot(source: Variant) -> Dictionary:
	return SaveSystem.normalize_plot(source, varieties.size())

func _read_plots_array(source: Variant) -> Array:
	return SaveSystem.read_plots_array(source, GRID_H, GRID_W, varieties.size())

func _read_order_array(source: Variant) -> Array[Dictionary]:
	return SaveSystem.read_order_array(source)

func _read_string_array(source: Variant, max_items: int) -> Array[String]:
	return SaveSystem.read_string_array(source, max_items)

func _read_int_array(source: Variant, expected_size: int, fill_value: int) -> Array[int]:
	return SaveSystem.read_int_array(source, expected_size, fill_value)

func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	_sync_music()
	if sound_enabled:
		_play_sfx("save")
		_say("Sound and music on.")
	else:
		_say("Sound and music muted.")
	_update_ui()


func _toggle_pause() -> void:
	game_paused = not game_paused
	_play_sfx("pause")
	if game_paused:
		_say("Paused. Press P, Esc, or Resume to keep farming.")
	else:
		_say("Back to the figs.")
	_update_ui()


func _set_tool(tool: int) -> void:
	current_tool = clampi(tool, Tool.PLANT, Tool.HARVEST)
	_update_ui()


func _select_variety(index: int) -> void:
	selected_variety = clampi(index, 0, varieties.size() - 1)
	_update_ui()


func _mark_ui_dirty() -> void:
	ui_dirty = true


func _update_hud_labels() -> void:
	if hud_labels.is_empty():
		return
	hud_labels["Day"].text = "📅 Day %s" % day
	hud_labels["Weather"].text = _weather_detail_text()
	hud_labels["Coins"].text = "🪙 $%s" % coins
	hud_labels["Water"].text = "💧 %s/%s" % [water, _max_water()]
	hud_labels["Cuts"].text = "🌱 Cuts %s" % _total_cuttings()
	hud_labels["Figs"].text = "Figs %s" % _total_figs()
	hud_labels["Compost"].text = "🟤 Comp %s" % compost
	hud_labels["Rep"].text = "♥ Trust %s" % reputation
	hud_labels["Guide"].text = "📖 " + _tutorial_short_text()


func _update_transient_ui() -> void:
	if message_label != null:
		if message_timer > 0.0:
			message_label.text = message
		else:
			message_label.text = ""
	if dock_hint_label != null:
		dock_hint_label.visible = panel_open
		if panel_open:
			dock_hint_label.text = "%s  • click icon again to close" % _drawer_header_text()


func _update_ui() -> void:
	_update_hud_labels()
	buy_cuttings_button.text = "🌱 %s tree        $%s" % [String(varieties[selected_variety]["short"]), int(varieties[selected_variety]["seed_cost"])]
	if barrel_level < 3:
		barrel_button.text = "▣ Barrel +        $%s" % (18 + barrel_level * 10)
	else:
		barrel_button.text = "▣ Barrel max"
	if pollinator_garden:
		garden_button.text = "🌸 Flowers done"
	else:
		garden_button.text = "🌸 Flowers        $24"
	garden_button.disabled = pollinator_garden
	if game_paused:
		pause_button.text = "▶ Resume"
		pause_label.text = "Paused"
	else:
		pause_button.text = "Ⅱ Pause"
		pause_label.text = ""
	if sound_enabled:
		sound_button.text = "🔊 Sound"
	else:
		sound_button.text = "🔇 Muted"
	pause_label.visible = game_paused
	pause_overlay_title.visible = game_paused
	pause_overlay_hint.visible = game_paused
	var can_clip_cutting: bool = _can_take_cutting(plots[farmer_cell.y][farmer_cell.x])
	clipping_row.visible = can_clip_cutting
	clipping_button.disabled = not can_clip_cutting
	clipping_button.text = "🌿 Clip cutting (C)"
	controls_panel.visible = panel_open and side_tab == 0
	market_panel.visible = panel_open and side_tab == 1
	pantry_panel.visible = panel_open and side_tab == 2
	guide_panel.visible = panel_open and side_tab == 3
	help_panel.visible = panel_open and side_tab == 4
	for tab in tab_buttons.keys():
		tab_buttons[tab].button_pressed = panel_open and int(tab) == side_tab
	festival_label.text = _festival_text()
	_update_order_buttons()
	order_label.text = _order_text()
	accept_order_button.disabled = not _can_accept_selected_order()
	fulfill_order_button.disabled = not _can_fulfill_selected_order()
	inventory_label.text = "Accepted orders: %s/5" % accepted_orders.size()
	pantry_figs_label.text = _pantry_figs_text()
	pantry_cuttings_label.text = _pantry_cuttings_text()
	pantry_preserves_label.text = _pantry_preserves_text()
	pantry_trees_label.text = _pantry_trees_text()
	pantry_hint_label.text = _pantry_hint_text()
	relationship_label.text = _relationship_summary()
	preserve_label.text = "Jam: 5 figs + 1 jar -> $18"
	logbook_label.text = _logbook_text()
	buy_jars_button.disabled = coins < 6
	make_jam_button.disabled = _total_figs() < 5 or mason_jars <= 0
	sell_jam_button.disabled = jam_jars <= 0
	notebook_label.text = _notebook_text()
	plot_status_label.text = _plot_status_text()
	guide_legend_label.text = _guide_legend_text()
	_update_transient_ui()
	dialogue_title_label.visible = dialogue_visible
	dialogue_body_label.visible = dialogue_visible
	dialogue_close_button.visible = dialogue_visible
	dialogue_title_label.text = dialogue_title
	dialogue_body_label.text = dialogue_body
	action_hint.text = _farm_hint_text()
	bottom_action_label.text = _bottom_action_text()
	plot_card_label.text = _plot_card_summary_text()
	for tool in tool_buttons.keys():
		var buttons: Array = tool_buttons[tool]
		for button_item in buttons:
			var tool_button: Button = button_item as Button
			if tool_button != null:
				tool_button.button_pressed = int(tool) == current_tool
	for index in variety_buttons.keys():
		variety_buttons[index].button_pressed = int(index) == selected_variety
	ui_dirty = false


func _how_to_play_text() -> String:
	return TextLibrary.how_to_play_text()

func _log_event(entry: String) -> void:
	var stamped_entry: String = "D%s  %s" % [day, entry]
	if game_log.size() > 0 and game_log[0] == stamped_entry:
		return
	game_log.insert(0, stamped_entry)
	while game_log.size() > 8:
		game_log.pop_back()


func _logbook_text() -> String:
	return TextLibrary.logbook_text(game_log)

func _tutorial_text() -> String:
	return TextLibrary.tutorial_text(tutorial_index)

func _tutorial_short_text() -> String:
	return TextLibrary.tutorial_short_text(tutorial_index)

func _advance_tutorial(step: int) -> void:
	if tutorial_index != step:
		return
	tutorial_index += 1
	if tutorial_index == 5:
		coins += 12
		compost += 1
		_say("Tutorial complete. Bonus: 12 coins and compost for the next planting.")


func _has_ripe_tree() -> bool:
	return CropSystem.has_ripe_tree(plots, GRID_H, GRID_W)

func _ripeness_yield_bonus(ripe_days: int) -> int:
	return TextLibrary.ripeness_yield_bonus(ripe_days)

func _ripeness_label(ripe_days: int) -> String:
	return TextLibrary.ripeness_label(ripe_days)

func _ripeness_harvest_note(ripe_days: int) -> String:
	return TextLibrary.ripeness_harvest_note(ripe_days)

func _guide_legend_text() -> String:
	return TextLibrary.guide_legend_text(_season_name(), temperature_f, _season_growing_note(), recipe_expanded)

func _farm_hint_text() -> String:
	var hint: String = "%s: %s" % [_tool_name(current_tool), _tool_block_reason()]
	if _current_tool_is_usable():
		hint = "%s ready. Click a plot to use." % _tool_name(current_tool)
	return hint


func _day_summary_text(grew_count: int, dried_count: int, ripened_count: int, softened_count: int, order_tick_count: int, expired_order_count: int, weather_name: String, extra_note: String) -> String:
	return TextLibrary.day_summary_text(day, _weather_icon(), grew_count, dried_count, ripened_count, softened_count, order_tick_count, expired_order_count, weather_name, extra_note)

func _progress_bar(current: int, maximum: int, width: int = 5) -> String:
	return TextLibrary.progress_bar(current, maximum, width)

func _moisture_icon(moisture: int) -> String:
	return TextLibrary.moisture_icon(moisture)

func _bottom_action_text() -> String:
	var tool_name: String = _tool_name(current_tool)
	if _current_tool_is_usable():
		match current_tool:
			Tool.PLANT:
				return "%s %s\nPlant %s with F or click" % [_tool_icon(current_tool), tool_name, String(varieties[selected_variety]["short"])]
			Tool.WATER:
				return "%s %s\nWater this tree with F or click" % [_tool_icon(current_tool), tool_name]
			Tool.COMPOST:
				return "%s %s\nCompost this tree with F or click" % [_tool_icon(current_tool), tool_name]
			Tool.HARVEST:
				return "%s %s\nPick ripe figs with F or click" % [_tool_icon(current_tool), tool_name]
	return "%s %s\n%s" % [_tool_icon(current_tool), tool_name, _tool_block_reason()]


func _plot_card_summary_text() -> String:
	var cell: Vector2i = _info_cell()
	var plot: Dictionary = plots[cell.y][cell.x]
	var title: String = _info_cell_label(cell)
	if not bool(plot["planted"]):
		var selected: Dictionary = varieties[selected_variety]
		return "%s: empty soil\nPlantable: %s x%s\nMoisture: dry" % [title, String(selected["short"]), cuttings[selected_variety]]
	var variety_index: int = int(plot["variety"])
	var variety: Dictionary = varieties[variety_index]
	var moisture: int = int(plot.get("moisture", 0))
	var moisture_text: String = _moisture_label(moisture)
	if bool(plot["watered"]):
		moisture_text = "watered today"
	if int(plot["stage"]) >= 3:
		var ripe_days: int = int(plot.get("ripe_days", 0))
		var cutting_text: String = "cutting ready"
		if not _can_take_cutting(plot):
			cutting_text = "cutting waits"
		return "%s: %s\n%s, %s\n%s" % [title, String(variety["short"]), _ripeness_label(ripe_days), moisture_text, cutting_text]
	var grow_days: int = int(variety["grow_days"])
	var progress: int = int(plot["progress"])
	var days_left: int = maxi(0, grow_days - progress)
	return "%s: %s tree\n%s, %s left\nGrowth %s" % [title, String(variety["short"]), moisture_text, _day_count_text(days_left), _progress_bar(progress, grow_days)]


func _tool_icon(tool: int) -> String:
	return TextLibrary.tool_icon(tool)

func _tool_shortcut(tool: int) -> String:
	return TextLibrary.tool_shortcut(tool)

func _drawer_header_text() -> String:
	return TextLibrary.drawer_header_text(side_tab)

func _tool_name(tool: int) -> String:
	return TextLibrary.tool_name(tool)

func _pantry_figs_text() -> String:
	return InventorySystem.pantry_figs_text(varieties, fig_bins)

func _pantry_cuttings_text() -> String:
	return InventorySystem.pantry_cuttings_text(varieties, cuttings)

func _pantry_preserves_text() -> String:
	return InventorySystem.pantry_preserves_text(_total_figs(), mason_jars, jam_jars)

func _pantry_trees_text() -> String:
	return InventorySystem.pantry_trees_text(varieties, plots, cuttings, GRID_H, GRID_W)

func _pantry_hint_text() -> String:
	return InventorySystem.pantry_hint_text()

func _notebook_text() -> String:
	var variety: Dictionary = varieties[selected_variety]
	return "Cultivar: %s\n%s" % [String(variety["short"]), String(variety["lesson"])]


func _moisture_label(moisture: int) -> String:
	return TextLibrary.moisture_label(moisture)

func _show_dialogue(title: String, body: String) -> void:
	dialogue_title = title
	dialogue_body = body
	dialogue_visible = true
	panel_open = false
	_play_sfx("save")


func _close_dialogue() -> void:
	dialogue_visible = false
	_update_ui()


func _plot_dialogue_title() -> String:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	if not bool(plot["planted"]):
		return "Farmer's Note"
	var variety_index: int = int(plot["variety"])
	return "%s Tree" % String(varieties[variety_index]["short"])


func _recipe_card_text() -> String:
	return TextLibrary.recipe_card_text()

func _show_plot_info() -> void:
	_show_dialogue(_plot_dialogue_title(), _plot_info_text())
	_update_ui()


func _plot_info_text() -> String:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	if not bool(plot["planted"]):
		return "Plot info: empty soil. Selected cutting is %s; plant with F or click." % String(varieties[selected_variety]["short"])
	var variety_index: int = int(plot["variety"])
	var variety: Dictionary = varieties[variety_index]
	var water_note: String = _moisture_label(int(plot.get("moisture", 0)))
	if bool(plot["watered"]):
		water_note = "watered today"
	if int(plot["stage"]) >= 3:
		return "Plot info: %s is %s with %s. Harvest ripe figs or press C for a cutting." % [String(variety["short"]), _ripeness_label(int(plot.get("ripe_days", 0))), water_note]
	var days_left: int = maxi(0, int(variety["grow_days"]) - int(plot["progress"]))
	return "Plot info: %s has %s. About %s until fruit. %s" % [String(variety["short"]), water_note, _day_count_text(days_left), String(variety["care"])]


func _day_count_text(count: int) -> String:
	return TextLibrary.day_count_text(count)

func _jar_count_text(count: int) -> String:
	return InventorySystem.jar_count_text(count)

func _plot_status_text() -> String:
	var cell: Vector2i = _info_cell()
	var plot: Dictionary = plots[cell.y][cell.x]
	var title: String = _info_cell_label(cell)
	if not bool(plot["planted"]):
		var selected: Dictionary = varieties[selected_variety]
		return "%s\nStatus: empty soil\nReady to plant: %s x%s\nMoisture: dry soil unless rain starts it wet\nNext: use Plant with F/click.\nCare note: %s" % [title, String(selected["short"]), cuttings[selected_variety], String(selected["care"])]
	var variety_index: int = int(plot["variety"])
	var variety: Dictionary = varieties[variety_index]
	var progress: int = int(plot["progress"])
	var grow_days: int = int(variety["grow_days"])
	var days_left: int = maxi(0, grow_days - progress)
	var water_note: String = _moisture_label(int(plot.get("moisture", 0)))
	if bool(plot["watered"]):
		water_note = "watered today"
	var stage_text: String = _growth_stage_label(int(plot["stage"]))
	var ready_text: String = _cutting_status_text(plot)
	var next_text: String = _plot_next_step_text(plot, days_left)
	if int(plot["stage"]) >= 3:
		stage_text = _ripeness_label(int(plot.get("ripe_days", 0)))
	return "%s\nCultivar: %s (%s)\nState: %s | %s\nGrowth: %s/%s good days, %s left\nCuttings: %s\nNext: %s\nCare: %s" % [title, String(variety["name"]), String(variety["short"]), stage_text, water_note, progress, grow_days, _day_count_text(days_left), ready_text, next_text, String(variety["care"])]


func _growth_stage_label(stage: int) -> String:
	return TextLibrary.growth_stage_label(stage)

func _cutting_status_text(plot: Dictionary) -> String:
	return CropSystem.cutting_status_text(plot, varieties)

func _plot_next_step_text(plot: Dictionary, days_left: int) -> String:
	if int(plot["stage"]) >= 3:
		return "Harvest now, or press C to clone before harvest."
	if bool(plot["watered"]):
		return "End day to convert watering into growth."
	if water <= 0:
		return "Refill/upgrade barrel soon; dry heat slows quality."
	if days_left <= 1:
		return "Water once more; fruit should appear soon."
	return "Water steadily. Compost if this tree matters."


func _resolve_festival_week(weather_name: String, day_summary: String = "") -> void:
	if festival_progress >= festival_goal:
		var overflow: int = festival_progress - festival_goal
		var payout: int = 30 + festival_week * 8 + overflow * 2
		coins += payout
		reputation += 2
		compost += 1
		_log_event("Weekly table met: %s/%s figs, +$%s, Trust +2." % [festival_progress, festival_goal, payout])
		var met_message: String = "Weekly table complete: +$%s, compost, Trust. %s" % [payout, day_summary]
		_say(met_message.strip_edges())
	else:
		_log_event("Weekly table ended: %s/%s figs. No Trust loss." % [festival_progress, festival_goal])
		var missed_message: String = "Weekly table ended %s/%s. No Trust loss. %s" % [festival_progress, festival_goal, day_summary]
		_say(missed_message.strip_edges())
	festival_week += 1
	festival_goal = _festival_goal_for_week()
	festival_progress = 0


func _festival_goal_for_week() -> int:
	return TextLibrary.festival_goal_for_week(festival_week, reputation)

func _festival_text() -> String:
	return TextLibrary.festival_text(festival_week, festival_progress, festival_goal, _festival_days_left())

func _festival_days_left() -> int:
	var elapsed: int = (day - 1) % FESTIVAL_LENGTH
	return FESTIVAL_LENGTH - elapsed


func _relationship_summary() -> String:
	return TextLibrary.relationship_summary(relationships)

func _customer_bonus(customer: String) -> int:
	return OrderSystem.customer_bonus(customer, relationships)

func _grant_relationship_milestone(customer: String, score: int) -> String:
	if score != 3 and score != 6:
		return ""
	if score == 6:
		coins += 25
		return "%s sent a 25 coin thank-you purse." % _short_customer_name(customer)
	match customer:
		"Mara the baker":
			compost += 2
			return "Mara shared bakery compost."
		"Oren the innkeeper":
			water = _max_water()
			return "Oren filled the barrel."
		"Sel the jam maker":
			cuttings[1] += 2
			return "Sel saved Black Madeira cuttings for you."
		"Niko the chef":
			cuttings[2] += 2
			return "Niko found White Madeira #1 cuttings."
		"Tavi from the festival":
			cuttings[3] += 3
			festival_progress += 6
			return "Tavi boosted the festival table with RdB cuttings."
	return ""


func _short_customer_name(customer: String) -> String:
	return OrderSystem.short_customer_name(customer)

func _order_text() -> String:
	return OrderSystem.order_text(selected_order_index, accepted_orders, order_offers, varieties)

func _order_button_text(index: int) -> String:
	return OrderSystem.order_button_text(index, accepted_orders, order_offers, varieties)

func _update_order_buttons() -> void:
	var total: int = _order_count()
	for i in order_buttons.size():
		var button: Button = order_buttons[i]
		if i < total:
			button.visible = true
			button.text = _order_button_text(i)
			button.disabled = false
			button.button_pressed = i == selected_order_index
		else:
			button.visible = false
			button.disabled = true


func _select_order_slot(slot: int) -> void:
	selected_order_index = clampi(slot, 0, maxi(0, _order_count() - 1))
	_update_ui()


func _selected_order() -> Dictionary:
	return OrderSystem.order_at(selected_order_index, accepted_orders, order_offers)

func _order_at(index: int) -> Dictionary:
	return OrderSystem.order_at(index, accepted_orders, order_offers)

func _order_count() -> int:
	return OrderSystem.order_count(accepted_orders, order_offers)

func _selected_order_is_accepted() -> bool:
	return OrderSystem.selected_order_is_accepted(selected_order_index, accepted_orders)

func _can_accept_selected_order() -> bool:
	return OrderSystem.can_accept_selected_order(selected_order_index, accepted_orders, order_offers)

func _can_fulfill_selected_order() -> bool:
	return OrderSystem.can_fulfill_selected_order(selected_order_index, accepted_orders, order_offers)

func _accept_selected_order() -> void:
	if not _can_accept_selected_order():
		_say("Pick an open offer to accept. Browsing alone has no Trust penalty.")
		return
	var offer_index: int = selected_order_index - accepted_orders.size()
	if offer_index < 0 or offer_index >= order_offers.size():
		_say("That order is already accepted.")
		return
	var selected: Dictionary = order_offers[offer_index]
	selected["accepted"] = true
	selected["patience"] = 4
	order_offers.remove_at(offer_index)
	accepted_orders.append(selected)
	selected_order_index = accepted_orders.size() - 1
	_log_event("Accepted order: %s needs %s figs." % [_short_customer_name(String(selected["customer"])), int(selected["need"])])
	_play_sfx("order")
	_say("Accepted %s's order. Finish it before the timer runs out to gain Trust." % _short_customer_name(String(selected["customer"])))
	_update_ui()


func _normalize_selected_order() -> void:
	selected_order_index = OrderSystem.normalize_selected_order(selected_order_index, accepted_orders, order_offers)

func _tool_block_reason() -> String:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	match current_tool:
		Tool.PLANT:
			if bool(plot["planted"]):
				return "Plot occupied."
			if cuttings[selected_variety] <= 0:
				return "No selected cuttings."
		Tool.WATER:
			if not bool(plot["planted"]):
				return "No tree here."
			if bool(plot["watered"]):
				return "Already watered."
			if water <= 0:
				return "Barrel empty."
		Tool.COMPOST:
			if not bool(plot["planted"]):
				return "No tree here."
			if bool(plot["composted"]):
				return "Already composted."
			if compost <= 0:
				return "No compost."
		Tool.HARVEST:
			if not bool(plot["planted"]):
				return "No tree here."
			if int(plot["stage"]) < 3:
				return "Not ripe yet."
	return "Move to a valid plot."


func _roll_weather() -> void:
	var result: Dictionary = WeatherSystem.roll_weather(day)
	current_weather = int(result["weather_index"])
	temperature_f = int(result["temperature_f"])

func _weather_name() -> String:
	return WeatherSystem.weather_name(weather_table, current_weather)

func _weather_detail_text() -> String:
	return WeatherSystem.weather_detail_text(weather_table, current_weather, day, temperature_f)

func _weather_icon() -> String:
	return WeatherSystem.weather_icon(weather_table, current_weather)

func _season_name() -> String:
	return WeatherSystem.season_name(day)

func _season_base_temperature(season: String) -> int:
	return WeatherSystem.season_base_temperature(season)

func _roll_temperature(season: String) -> void:
	temperature_f = WeatherSystem.roll_temperature(season, _weather_name())

func _season_growing_note() -> String:
	return WeatherSystem.season_growing_note(day)

func _is_rainy() -> bool:
	return WeatherSystem.is_rainy(_weather_name())

func _pollinator_chance() -> float:
	return WeatherSystem.pollinator_chance(pollinator_garden, _weather_name())

func _max_water() -> int:
	return WeatherSystem.max_water(BASE_MAX_WATER, barrel_level)

func _total_cuttings() -> int:
	return InventorySystem.total_items(cuttings)

func _total_figs() -> int:
	return InventorySystem.total_items(fig_bins)

func _take_any_figs(amount: int) -> void:
	InventorySystem.take_any(fig_bins, amount)

func _variety_name(index: int) -> String:
	return String(varieties[index]["name"])


func _say(text: String) -> void:
	message = text
	message_timer = 5.0
	_mark_ui_dirty()


func _cell_from_mouse(mouse_pos: Vector2) -> Vector2i:
	var local: Vector2 = mouse_pos - farm_origin
	return Vector2i(floori(local.x / tile_size), floori(local.y / tile_size))


func _is_cell_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_W and cell.y < GRID_H
