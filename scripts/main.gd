# ============================================================
# /*=== MAIN SCRIPT FILE START ===*/
# ============================================================
# /*=== MAIN.GD FILE START ===*/
# Main scene controller for the farming prototype.
# NOTE: This file is intentionally annotated with START/END markers
# so we can safely find/refactor sections without hunting through 2,900+ lines.
extends Node2D


# ============================================================
# /*=== MAIN.GD NAVIGATION GUIDE START ===*/
# ------------------------------------------------------------
# This file uses explicit START / END markers around every
# top-level function. Search for:
#
#   FUNCTION <NAME> START
#
# to jump directly to a function, or search for the existing
# feature markers such as FARM PANTRY, VILLAGE REQUESTS, HUD,
# DRAWER, SAVE, WEATHER, ORDERS, and FARM ACTIONS.
#
# Runtime Control creation remains inside _build_ui().
# Gameplay and UI refresh coordination remain in main.gd while
# focused systems and UI modules own their rules/presentation.
# ============================================================
# /*=== MAIN.GD NAVIGATION GUIDE END ===*/
# ============================================================


# /*=== PRELOADS / EXTERNAL SYSTEMS START ===*/
# Dependencies loaded from scripts/. These are good extraction targets as main.gd shrinks.
const PAGE_TITLE_FONT: Font = preload(
	"res://assets/fonts/Lora-Bold.ttf"
)
const GameData = preload("res://scripts/game_data.gd")
const AssetLibrary = preload("res://scripts/asset_library.gd")
const AudioLibrary = preload("res://scripts/audio_library.gd")
const SaveSystem = preload("res://scripts/save_system.gd")
const OrderSystem = preload("res://scripts/order_system.gd")
const InventorySystem = preload("res://scripts/inventory_system.gd")
const WeatherSystem = preload("res://scripts/systems/weather_system.gd")
const FestivalSystem = preload("res://scripts/systems/festival_system.gd")
const EconomySystem = preload("res://scripts/systems/economy_system.gd")
const RelationshipSystem = preload("res://scripts/systems/relationship_system.gd")
const TextLibrary = preload("res://scripts/text_library.gd")
const CropSystem = preload("res://scripts/crop_system.gd")
const LayoutSystem = preload("res://scripts/layout_system.gd")
const VillageRequestsUI = preload("res://scripts/ui/village_requests_ui.gd")
const HUDUI = preload("res://scripts/ui/hud_ui.gd")
const BottomBarUI = preload("res://scripts/ui/bottom_bar_ui.gd")
const ToolPanelUI = preload("res://scripts/ui/tool_panel_ui.gd")
const DrawerUI = preload("res://scripts/ui/drawer_ui.gd")
const FarmControlsUI = preload("res://scripts/ui/farm_controls_ui.gd")
const PantryUI = preload("res://scripts/ui/pantry_ui.gd")
const PageChromeUI = preload("res://scripts/ui/page_chrome_ui.gd")
const BottomNavigationUI = preload("res://scripts/ui/bottom_navigation_ui.gd")
const SectionHeaderUI = preload("res://scripts/ui/section_header_ui.gd")
const GuideUI = preload("res://scripts/ui/guide_ui.gd")
const HelpUI = preload("res://scripts/ui/help_ui.gd")
const UIDebugOverlay = preload("res://scripts/ui/ui_debug_overlay.gd")
const UITheme := preload("res://scripts/ui/theme.gd")
const UIConstants = preload("res://scripts/ui/ui_constants.gd")
const FarmRenderer := preload("res://scripts/render/farm_renderer.gd")
# /*=== PRELOADS / EXTERNAL SYSTEMS END ===*/

# /*=== CORE LAYOUT / THEME CONSTANTS START ===*/
# Global dimensions and colors used by the hand-drawn UI.

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
const BG_CREAM := "#fff8e8"
const PANEL_FILL := "#f0ddb5"
const PANEL_BORDER := "#6a4d2e"
const TEXT_DARK := "#3b2b19"
const MUTED_TEXT := "#725431"
const PRIMARY_GREEN := "#5d7f35"
const DISABLED_FILL := "#c8c0ae"

# /*=== CORE LAYOUT / THEME CONSTANTS END ===*/

# /*=== RUNTIME GAME STATE START ===*/
# Core gameplay state: farm, resources, time, weather, orders, and selected UI state.

var tile_size: int = BASE_TILE
var farm_origin: Vector2 = Vector2(230, 116)
var farm_board_position: Vector2 = Vector2(204, 90)
const DAY_LENGTH := 30.0
const BASE_MAX_WATER := 12
const FESTIVAL_LENGTH := 7
const SAVE_PATH := "user://fig_farmer_save.json"

enum Tool { PLANT, WATER, COMPOST, HARVEST }

var varieties: Array[Dictionary] = GameData.varieties()
var weather_table: Array[Dictionary] = WeatherSystem.weather_definitions()
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

# /*=== RUNTIME GAME STATE END ===*/

# /*=== NODE / UI REFERENCES START ===*/
# Runtime-created Control nodes and labels. Built in _build_ui(), positioned in layout functions.
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
var page_chrome_nodes: Dictionary = {}
var bottom_nav_buttons: Dictionary = {}
var pantry_scroll: ScrollContainer
var pantry_panel: VBoxContainer
var pantry_harvest_grid: GridContainer
var pantry_preserve_stats_row: HBoxContainer
var pantry_preserve_actions: HBoxContainer
var pantry_planting_grid: GridContainer
var guide_panel: VBoxContainer
var help_panel: VBoxContainer
var market_title: Label
var crate_button: Button
var order_label: Label
var festival_label: Label
var accept_order_button: Button
var fulfill_order_button: Button
var inventory_label: Label
var pantry_harvest_amount_labels: Array[Label] = []
var pantry_cutting_amount_labels: Array[Label] = []
var pantry_total_figs_label: Label
var pantry_total_cuttings_label: Label
var pantry_jars_count_label: Label
var pantry_jam_count_label: Label
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
var buy_compost_button: Button
var barrel_button: Button
var garden_button: Button
var day_button: Button
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
var help_text_label: Label
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_library: Dictionary = {}
var crop_textures: Dictionary = {}
var item_textures: Dictionary = {}
var ui_textures: Dictionary = {}
var tool_textures: Dictionary = {}
var ui_debug_overlay: CanvasLayer
#============================================================
# /*=== NODE / UI REFERENCES END ===*/
#============================================================

# ============================================================
# /*=== VILLAGE REQUESTS PAGER STATE START ===*/
# ============================================================

var order_page: int = 0
var order_page_label: Label
var order_page_button: Button
var order_page_text_label: Label
var order_previous_button: Button
var order_next_button: Button

# ============================================================
# /*=== VILLAGE REQUESTS PAGER STATE END ===*/
# ============================================================

# ============================================================
# /*=== SELECT ORDER PAGE CARD START ===*/
# ------------------------------------------------------------
# Selects the order currently displayed by the pager card.
# ============================================================

# ============================================================
# /*=== FUNCTION SELECT ORDER PAGE CARD START ===*/
# ============================================================

func _select_order_page_card() -> void:
	var total_orders: int = OrderSystem.order_count(
		accepted_orders,
		order_offers
	)

	if total_orders <= 0:
		return

	order_page = clampi(order_page, 0, total_orders - 1)
	_select_order_slot(order_page)


# ============================================================
# /*=== FUNCTION SELECT ORDER PAGE CARD END ===*/
# ============================================================

# ============================================================
# /*=== SELECT ORDER PAGE CARD END ===*/
# ============================================================
# ============================================================
# /*=== ORDER PAGE NAVIGATION START ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHOW PREVIOUS ORDER PAGE START ===*/
# ============================================================

func _show_previous_order_page() -> void:
	order_page -= 1
	_normalize_order_page()
	_select_order_slot(order_page)



# ============================================================
# /*=== FUNCTION SHOW PREVIOUS ORDER PAGE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHOW NEXT ORDER PAGE START ===*/
# ============================================================

func _show_next_order_page() -> void:
	order_page += 1
	_normalize_order_page()
	_select_order_slot(order_page)


# ============================================================
# /*=== FUNCTION SHOW NEXT ORDER PAGE END ===*/
# ============================================================

# ============================================================
# /*=== ORDER PAGE NAVIGATION END ===*/
# ============================================================
# ============================================================
# /*=== ORDER PAGER UPDATE START ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION NORMALIZE ORDER PAGE START ===*/
# ============================================================

func _normalize_order_page() -> void:
	var total_orders: int = OrderSystem.order_count(
		accepted_orders,
		order_offers
	)

	if total_orders <= 0:
		order_page = 0
		return

	order_page = clampi(order_page, 0, total_orders - 1)



# ============================================================
# /*=== FUNCTION NORMALIZE ORDER PAGE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE ORDER PAGER START ===*/
# ============================================================

func _update_order_pager() -> void:
	if (
		order_page_label == null
		or order_page_button == null
		or order_page_text_label == null
		or order_previous_button == null
		or order_next_button == null
	):
		return

	var total_orders: int = OrderSystem.order_count(
		accepted_orders,
		order_offers
	)

	if total_orders <= 0:
		order_page = 0
		order_page_label.text = "0 / 0"
		order_page_text_label.text = "No available requests"

		order_page_button.disabled = true
		order_page_button.button_pressed = false
		order_previous_button.disabled = true
		order_next_button.disabled = true
		return

	_normalize_order_page()

	order_page_label.text = "%s / %s" % [
		order_page + 1,
		total_orders
	]

	order_page_text_label.text = OrderSystem.order_button_text(
		order_page,
		accepted_orders,
		order_offers,
		varieties
	)

	order_page_button.disabled = false
	order_page_button.button_pressed = selected_order_index == order_page

	order_previous_button.disabled = order_page <= 0
	order_next_button.disabled = order_page >= total_orders - 1
	# ============================================================ 
	# /*=== ORDER PAGER UPDATE END ===*/ 
	# ============================================================




# ============================================================
# /*=== FUNCTION UPDATE ORDER PAGER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION READY START ===*/
# ============================================================

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
	_build_ui_debug_overlay()
	_update_ui()




# ============================================================
# /*=== FUNCTION READY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PROCESS START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PROCESS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UNHANDLED INPUT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION UNHANDLED INPUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION DRAW END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD PLOTS START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION BUILD PLOTS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION IS MOBILE LAYOUT START ===*/
# ============================================================

func _is_mobile_layout() -> bool:
	return LayoutSystem.is_mobile_layout(get_viewport_rect().size)



# ============================================================
# /*=== FUNCTION IS MOBILE LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE LAYOUT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION UPDATE LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION VIEWPORT SIZE START ===*/
# ============================================================

func _viewport_size() -> Vector2:
	return get_viewport_rect().size




# ============================================================
# /*=== FUNCTION VIEWPORT SIZE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FARM BOARD SIZE START ===*/
# ============================================================

func _farm_board_size() -> Vector2:
	return LayoutSystem.farm_board_size(GRID_W, GRID_H, tile_size)



# ============================================================
# /*=== FUNCTION FARM BOARD SIZE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FARM BOARD RECT START ===*/
# ============================================================

func _farm_board_rect() -> Rect2:
	return LayoutSystem.farm_board_rect(farm_board_position, _farm_board_size())



# ============================================================
# /*=== FUNCTION FARM BOARD RECT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT BED RECT START ===*/
# ============================================================

func _plot_bed_rect() -> Rect2:
	return LayoutSystem.plot_bed_rect(farm_origin, GRID_W, GRID_H, tile_size)



# ============================================================
# /*=== FUNCTION PLOT BED RECT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HUD LAYOUT START ===*/
# ============================================================

func _hud_layout() -> Dictionary:
	return HUDUI.build_layout(_viewport_size(), SCREEN_PAD, HUD_H)



# ============================================================
# /*=== FUNCTION HUD LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HUD CONTROLS START ===*/
# ============================================================

func _hud_controls() -> Dictionary:
	return {
		"top_bar": top_bar,
		"hud_second_row": hud_second_row,
		"hud_labels": hud_labels,
		"hud_fig_icon": hud_fig_icon
	}



# ============================================================
# /*=== FUNCTION HUD CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BOTTOM BAR LAYOUT START ===*/
# ============================================================

func _bottom_bar_layout() -> Dictionary:
	return BottomBarUI.build_layout(
		_viewport_size(),
		_farm_board_rect(),
		SCREEN_PAD,
		BOTTOM_BAR_H,
		GAP,
		_is_mobile_layout()
	)



# ============================================================
# /*=== FUNCTION BOTTOM BAR LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BOTTOM BAR CONTROLS START ===*/
# ============================================================

func _bottom_bar_controls() -> Dictionary:
	return {
		"action_label": bottom_action_label,
		"plot_label": plot_card_label,
		"message_label": message_label
	}



# ============================================================
# /*=== FUNCTION BOTTOM BAR CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL PANEL LAYOUT START ===*/
# ============================================================

func _tool_panel_layout() -> Dictionary:
	return ToolPanelUI.build_layout(
		_viewport_size(),
		SCREEN_PAD,
		HUD_H,
		LEFT_DOCK_W,
		BOTTOM_BAR_H,
		GAP,
		_is_mobile_layout()
	)



# ============================================================
# /*=== FUNCTION TOOL PANEL LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL PANEL CONTROLS START ===*/
# ============================================================

func _tool_panel_controls() -> Dictionary:
	return {
		"tool_row": dock_tool_row,
		"menu_row": tab_row,
		"tool_section_label": tool_section_label,
		"menu_section_label": menu_section_label
	}



# ============================================================
# /*=== FUNCTION TOOL PANEL CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAWER LAYOUT START ===*/
# ============================================================

func _drawer_layout() -> Dictionary:
	return DrawerUI.build_layout(
		_viewport_size(),
		SCREEN_PAD,
		HUD_H,
		DRAWER_W,
		BOTTOM_BAR_H,
		GAP,
		_is_mobile_layout()
	)



# ============================================================
# /*=== FUNCTION DRAWER LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PAGE CHROME LAYOUT START ===*/
# ============================================================

func _page_chrome_rect() -> Rect2:
	var chrome_rect: Rect2 = _drawer_layout().get(
		"drawer",
		Rect2()
	)
	var viewport_size: Vector2 = get_viewport_rect().size
	var chrome_edge_margin: float = 72.0
	var ideal_chrome_width: float = (
		UIConstants.READABLE_PAGE_WIDTH
		+ UIConstants.PAGE_CHROME_SAFE_PADDING * 2.0
	)

	chrome_rect.size.x = minf(
		minf(chrome_rect.size.x, ideal_chrome_width),
		maxf(1.0, viewport_size.x - chrome_edge_margin * 2.0)
	)
	chrome_rect.size.y = minf(
		chrome_rect.size.y,
		maxf(1.0, viewport_size.y - chrome_edge_margin * 2.0)
	)

	chrome_rect.position.x = clampf(
		viewport_size.x - chrome_edge_margin - chrome_rect.size.x,
		chrome_edge_margin,
		maxf(chrome_edge_margin, viewport_size.x - chrome_edge_margin - chrome_rect.size.x)
	)
	chrome_rect.position.y = clampf(
		chrome_rect.position.y,
		chrome_edge_margin,
		maxf(chrome_edge_margin, viewport_size.y - chrome_edge_margin - chrome_rect.size.y)
	)

	return chrome_rect


func _page_chrome_content_rect() -> Rect2:
	return PageChromeUI.content_rect_for_layout(_page_chrome_rect())


func _is_page_chrome_open() -> bool:
	return panel_open


func _page_chrome_content_host() -> VBoxContainer:
	return page_chrome_nodes.get("content", null) as VBoxContainer


func _add_page_chrome_panel(panel: Control) -> void:
	var page_content: VBoxContainer = _page_chrome_content_host()
	if page_content == null or panel == null:
		return

	panel.clip_contents = true
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	page_content.add_child(panel)


func _page_chrome_title() -> String:
	match side_tab:
		0:
			return "Farm"
		1:
			return "Village Requests"
		2:
			return "Farm Pantry"
		3:
			return "Fig Guide"
		4:
			return "More"

	return "Fig Farmer"


func _page_chrome_icon() -> Texture2D:
	return _tab_texture(side_tab)


# ============================================================
# /*=== FUNCTION PAGE CHROME LAYOUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAWER PANELS START ===*/
# ============================================================

func _drawer_panels() -> Array:
	return [null, null, null, null, null]



# ============================================================
# /*=== FUNCTION DRAWER PANELS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAWER CONTROLS START ===*/
# ============================================================

func _drawer_controls() -> Dictionary:
	return {
		"hint_label": dock_hint_label,
		"panels": _drawer_panels()
	}



# ============================================================
# /*=== FUNCTION DRAWER CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FARM CONTROLS UI CONTROLS START ===*/
# ============================================================

func _farm_controls_ui_controls() -> Dictionary:
	return {
		"panel": controls_panel,
		"container_mode": true,
		"action_hint": action_hint,
		"buy_cuttings_button": buy_cuttings_button,
		"buy_compost_button": buy_compost_button,
		"clipping_button": clipping_button,
		"barrel_button": barrel_button,
		"garden_button": garden_button,
		"day_button": day_button,
		"save_button": save_button,
		"load_button": load_button,
		"pause_button": pause_button,
		"sound_button": sound_button
	}



# ============================================================
# /*=== FUNCTION FARM CONTROLS UI CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PANTRY UI CONTROLS START ===*/
# ============================================================

func _pantry_ui_controls() -> Dictionary:
	return {
		"panel": pantry_panel,
		"scroll": pantry_scroll,
		"container_mode": true,
		"harvest_grid": pantry_harvest_grid,
		"preserve_stats_row": pantry_preserve_stats_row,
		"preserve_actions": pantry_preserve_actions,
		"planting_grid": pantry_planting_grid,
		"preserve_label": preserve_label,
		"make_jam_button": make_jam_button,
		"buy_jars_button": buy_jars_button,
		"recipe_button": recipe_button,
		"trees_label": pantry_trees_label,
		"hint_label": pantry_hint_label
	}



# ============================================================
# /*=== FUNCTION PANTRY UI CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION GUIDE UI CONTROLS START ===*/
# ============================================================

func _guide_ui_controls() -> Dictionary:
	return {
		"panel": guide_panel,
		"container_mode": true,
		"notebook_label": notebook_label,
		"plot_status_label": plot_status_label,
		"legend_label": guide_legend_label
	}



# ============================================================
# /*=== FUNCTION GUIDE UI CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HELP UI CONTROLS START ===*/
# ============================================================

func _help_ui_controls() -> Dictionary:
	return {
		"panel": help_panel,
		"container_mode": true,
		"help_text_label": help_text_label
	}



# ============================================================
# /*=== FUNCTION HELP UI CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION APPLY LAYOUT TO CONTROLS START ===*/
# ============================================================

func _apply_layout_to_controls() -> void:
	HUDUI.apply_layout(_hud_controls(), _hud_layout())
	BottomBarUI.apply_layout(_bottom_bar_controls(), _bottom_bar_layout())
	ToolPanelUI.apply_layout(_tool_panel_controls(), _tool_panel_layout())
	DrawerUI.apply_layout(_drawer_controls(), _drawer_layout())
	PageChromeUI.apply_layout(page_chrome_nodes, _page_chrome_rect())

	var page_content_rect: Rect2 = _page_chrome_content_rect()

	FarmControlsUI.apply_layout(
		_farm_controls_ui_controls(),
		page_content_rect
	)
	PantryUI.apply_layout(
		_pantry_ui_controls(),
		page_content_rect
	)
	GuideUI.apply_layout(
		_guide_ui_controls(),
		page_content_rect
	)
	HelpUI.apply_layout(
		_help_ui_controls(),
		page_content_rect
	)
	VillageRequestsUI.apply_layout(
		_village_requests_controls(),
		page_content_rect
	)


# ============================================================
# /*=== FUNCTION APPLY LAYOUT TO CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD SFX START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION BUILD SFX END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SYNC MUSIC START ===*/
# ============================================================

func _sync_music() -> void:
	if music_player == null:
		return
	if sound_enabled:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()




# ============================================================
# /*=== FUNCTION SYNC MUSIC END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLAY SFX START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PLAY SFX END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TEXTURE FROM START ===*/
# ============================================================

func _texture_from(group: Dictionary, key: String) -> Texture2D:
	if not group.has(key):
		return null
	var texture: Texture2D = group[key] as Texture2D
	return texture




# ============================================================
# /*=== FUNCTION TEXTURE FROM END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION APPLY BUTTON ICON START ===*/
# ============================================================

func _apply_button_icon(button: Button, texture: Texture2D) -> void:
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
	button.text = ""




# ============================================================
# /*=== FUNCTION APPLY BUTTON ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DECORATE BUTTON ICON START ===*/
# ============================================================

func _decorate_button_icon(button: Button, texture: Texture2D) -> void:
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = false




# ============================================================
# /*=== FUNCTION DECORATE BUTTON ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL TEXTURE START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION TOOL TEXTURE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TAB TEXTURE START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION TAB TEXTURE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD UI START ===*/
# ============================================================

func _build_ui() -> void:
	var ui: CanvasLayer = CanvasLayer.new()
	ui.name = "MainUICanvas"
	add_child(ui)

	top_bar = HBoxContainer.new()
	top_bar.name = "TopHUD"
	top_bar.position = _hud_layout().get("row_one_pos", Vector2.ZERO)
	top_bar.add_theme_constant_override("separation", 8)
	ui.add_child(top_bar)

	for key in ["Day", "Coins", "Water", "Cuts", "Figs", "Compost", "Rep"]:
		if key == "Figs":
			hud_fig_icon = TextureRect.new()
			hud_fig_icon.name = "TopHUDFigIcon"
			hud_fig_icon.custom_minimum_size = Vector2(20, 20)
			hud_fig_icon.texture = _texture_from(item_textures, "fig")
			hud_fig_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			top_bar.add_child(hud_fig_icon)
		var label: Label = Label.new()
		label.name = "TopHUD%sLabel" % key
		label.custom_minimum_size = HUDUI.label_minimum_size(key, 1)
		_style_label(label, 15, Color("#31401f"))
		top_bar.add_child(label)
		hud_labels[key] = label

	hud_second_row = HBoxContainer.new()
	hud_second_row.name = "TopHUDSecondaryRow"
	hud_second_row.position = _hud_layout().get("row_two_pos", Vector2.ZERO)
	hud_second_row.add_theme_constant_override("separation", 12)
	ui.add_child(hud_second_row)
	for key in ["Weather", "Guide"]:
		var label: Label = Label.new()
		label.name = "TopHUD%sLabel" % key
		label.custom_minimum_size = HUDUI.label_minimum_size(key, 2)
		label.clip_text = true
		_style_label(label, 13, Color("#31401f"))
		hud_second_row.add_child(label)
		hud_labels[key] = label

	pause_label = Label.new()
	pause_label.name = "PauseStatusLabel"
	pause_label.position = Vector2(690, 42)
	pause_label.custom_minimum_size = Vector2(58, 24)
	_style_label(pause_label, 15, Color("#4b2d1c"))
	ui.add_child(pause_label)

	pause_overlay_title = Label.new()
	pause_overlay_title.name = "PauseOverlayTitle"
	pause_overlay_title.position = Vector2(350, 250)
	pause_overlay_title.custom_minimum_size = Vector2(150, 28)
	pause_overlay_title.text = "Paused"
	_style_label(pause_overlay_title, 26, Color("#3b2b19"))
	ui.add_child(pause_overlay_title)

	pause_overlay_hint = Label.new()
	pause_overlay_hint.name = "PauseOverlayHint"
	pause_overlay_hint.position = Vector2(306, 286)
	pause_overlay_hint.custom_minimum_size = Vector2(236, 24)
	pause_overlay_hint.text = "Press P, Esc, or Resume"
	_style_label(pause_overlay_hint, 14, Color("#5b492e"))
	ui.add_child(pause_overlay_hint)

	dock_tool_row = VBoxContainer.new()
	dock_tool_row.name = "ToolDock"
	dock_tool_row.position = _tool_panel_layout().get("tool_column_pos", Vector2.ZERO)
	dock_tool_row.add_theme_constant_override("separation", ToolPanelUI.row_separation())
	ui.add_child(dock_tool_row)

	tool_section_label = Label.new()
	tool_section_label.name = "ToolDockSectionLabel"
	tool_section_label.text = "TOOLS"
	var tool_label_rect: Rect2 = _tool_panel_layout().get("tool_section_label", Rect2())
	tool_section_label.position = tool_label_rect.position
	tool_section_label.custom_minimum_size = tool_label_rect.size
	_style_label(tool_section_label, 10, Color(MUTED_TEXT))
	ui.add_child(tool_section_label)

	_add_tool_button(dock_tool_row, "🌱", Tool.PLANT)
	_add_tool_button(dock_tool_row, "💧", Tool.WATER)
	_add_tool_button(dock_tool_row, "🟤", Tool.COMPOST)
	_add_tool_button(dock_tool_row, "✂", Tool.HARVEST)

	tab_row = VBoxContainer.new()
	tab_row.name = "MenuDock"
	tab_row.position = _tool_panel_layout().get("menu_column_pos", Vector2.ZERO)
	tab_row.add_theme_constant_override("separation", ToolPanelUI.row_separation())
	ui.add_child(tab_row)

	menu_section_label = Label.new()
	menu_section_label.name = "MenuDockSectionLabel"
	menu_section_label.text = "MENUS"
	var menu_label_rect: Rect2 = _tool_panel_layout().get("menu_section_label", Rect2())
	menu_section_label.position = menu_label_rect.position
	menu_section_label.custom_minimum_size = menu_label_rect.size
	_style_label(menu_section_label, 10, Color(MUTED_TEXT))
	ui.add_child(menu_section_label)

	_add_tab_button(tab_row, "Farm", 0)
	_add_tab_button(tab_row, "Orders", 1)
	_add_tab_button(tab_row, "Pantry", 2)
	_add_tab_button(tab_row, "Guide", 3)
	_add_tab_button(tab_row, "Help", 4)

	_build_page_chrome(ui)

	controls_panel = VBoxContainer.new()
	controls_panel.name = "FarmPageContent"
	var drawer_content_rect: Rect2 = _drawer_layout().get("content", Rect2())
	controls_panel.custom_minimum_size = drawer_content_rect.size
	controls_panel.add_theme_constant_override("separation", FarmControlsUI.panel_separation())
	_add_page_chrome_panel(controls_panel)

	var title: Label = Label.new()
	title.name = "FarmControlsTitle"
	title.text = "Fig Farmer 🌿"
	_style_label(title, 26, Color("#3b2b19"))
	controls_panel.add_child(title)


	_add_section_label(controls_panel, "CUTTINGS")
	var variety_row: HBoxContainer = HBoxContainer.new()
	variety_row.name = "FarmCuttingsRow"
	variety_row.add_theme_constant_override("separation", 5)
	controls_panel.add_child(variety_row)
	for i in varieties.size():
		_add_variety_button(variety_row, i)

	action_hint = Label.new()
	action_hint.name = "FarmActionHint"
	action_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_hint.custom_minimum_size = FarmControlsUI.action_hint_minimum_size()
	_style_label(action_hint, 13, Color("#4c3c25"))
	controls_panel.add_child(action_hint)

	_add_section_label(controls_panel, "SHOP")
	var shop_row: HBoxContainer = HBoxContainer.new()
	shop_row.name = "FarmShopRow"
	shop_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(shop_row)
	buy_cuttings_button = Button.new()
	buy_cuttings_button.name = "FarmBuyCuttingsButton"
	buy_cuttings_button.custom_minimum_size = FarmControlsUI.shop_button_minimum_size()
	_style_button(buy_cuttings_button, 13, "secondary")
	_decorate_button_icon(buy_cuttings_button, _texture_from(item_textures, "seeds"))
	buy_cuttings_button.pressed.connect(_buy_cuttings)
	shop_row.add_child(buy_cuttings_button)
	buy_compost_button = Button.new()
	buy_compost_button.name = "FarmBuyCompostButton"
	buy_compost_button.text = "💰 Compost x2        $7"
	buy_compost_button.custom_minimum_size = FarmControlsUI.shop_button_minimum_size()
	_style_button(buy_compost_button, 13, "secondary")
	_decorate_button_icon(buy_compost_button, _texture_from(item_textures, "fertilizer"))
	buy_compost_button.pressed.connect(_buy_compost)
	shop_row.add_child(buy_compost_button)

	clipping_row = HBoxContainer.new()
	clipping_row.name = "FarmClippingRow"
	clipping_row.add_theme_constant_override("separation", 0)
	controls_panel.add_child(clipping_row)
	clipping_button = Button.new()
	clipping_button.name = "FarmClipCuttingButton"
	clipping_button.text = "Clip cutting (C)"
	clipping_button.custom_minimum_size = FarmControlsUI.clipping_button_minimum_size()
	_style_button(clipping_button, 12, "muted")
	clipping_button.pressed.connect(func() -> void: call("_take_cutting_from_farmer_plot"))
	clipping_row.add_child(clipping_button)

	var upgrade_row: HBoxContainer = HBoxContainer.new()
	upgrade_row.name = "FarmUpgradeRow"
	upgrade_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(upgrade_row)
	barrel_button = Button.new()
	barrel_button.name = "FarmBarrelUpgradeButton"
	barrel_button.custom_minimum_size = FarmControlsUI.upgrade_button_minimum_size()
	_style_button(barrel_button, 13, "secondary")
	_decorate_button_icon(barrel_button, _texture_from(item_textures, "barrel"))
	barrel_button.pressed.connect(_buy_barrel_upgrade)
	upgrade_row.add_child(barrel_button)
	garden_button = Button.new()
	garden_button.name = "FarmPollinatorGardenButton"
	garden_button.custom_minimum_size = FarmControlsUI.upgrade_button_minimum_size()
	_style_button(garden_button, 13, "secondary")
	_decorate_button_icon(garden_button, _texture_from(item_textures, "flower"))
	garden_button.pressed.connect(_buy_pollinator_garden)
	upgrade_row.add_child(garden_button)

	_add_section_label(controls_panel, "DAY")
	var day_row: HBoxContainer = HBoxContainer.new()
	day_row.name = "FarmDayRow"
	day_row.add_theme_constant_override("separation", 0)
	controls_panel.add_child(day_row)
	day_button = Button.new()
	day_button.name = "FarmEndDayButton"
	day_button.text = "🌙  End Day"
	day_button.custom_minimum_size = FarmControlsUI.day_button_minimum_size()
	_style_button(day_button, 13, "action")
	day_button.pressed.connect(_start_next_day)
	day_row.add_child(day_button)

	var save_row: HBoxContainer = HBoxContainer.new()
	save_row.name = "FarmSaveRow"
	save_row.add_theme_constant_override("separation", 8)
	controls_panel.add_child(save_row)
	save_button = Button.new()
	save_button.name = "FarmSaveButton"
	save_button.text = "▣ Save"
	save_button.custom_minimum_size = FarmControlsUI.save_button_minimum_size()
	_style_button(save_button, 12, "secondary")
	save_button.pressed.connect(func() -> void: call("_save_game"))
	save_row.add_child(save_button)
	load_button = Button.new()
	load_button.name = "FarmLoadButton"
	load_button.text = "▣ Load"
	load_button.custom_minimum_size = FarmControlsUI.save_button_minimum_size()
	_style_button(load_button, 12, "secondary")
	load_button.pressed.connect(func() -> void: call("_load_game"))
	save_row.add_child(load_button)
	pause_button = Button.new()
	pause_button.name = "FarmPauseButton"
	pause_button.custom_minimum_size = FarmControlsUI.save_button_minimum_size()
	_style_button(pause_button, 12, "secondary")
	pause_button.pressed.connect(func() -> void: call("_toggle_pause"))
	save_row.add_child(pause_button)
	sound_button = Button.new()
	sound_button.name = "FarmSoundButton"
	sound_button.custom_minimum_size = FarmControlsUI.save_button_minimum_size()
	_style_button(sound_button, 12, "secondary")
	sound_button.pressed.connect(func() -> void: call("_toggle_sound"))
	save_row.add_child(sound_button)

	# ============================================================
	# /*=== VILLAGE REQUESTS CONTROLS START ===*/
	# ============================================================
	market_panel = VBoxContainer.new()
	market_panel.name = "VillageRequestsPageContent"
	_add_page_chrome_panel(market_panel)

	var content: Rect2 = _village_requests_content_rect()
	market_title = Label.new()
	market_title.name = "VillageRequestsTitle"
	market_title.text = "Village Requests"
	market_title.custom_minimum_size = VillageRequestsUI.title_minimum_size(content)
	_style_label(market_title, 25, Color("#3b2b19"))
	market_panel.add_child(market_title)

	_add_market_section_label(market_panel, "WEEKLY CONTRACT")
	festival_label = Label.new()
	festival_label.name = "VillageRequestsWeeklyContract"
	festival_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	festival_label.custom_minimum_size = VillageRequestsUI.weekly_contract_minimum_size(content)
	_style_label(festival_label, 13, Color("#4c3c25"))
	market_panel.add_child(festival_label)

	_add_market_section_label(market_panel, "CURRENT REQUEST")
	order_label = Label.new()
	order_label.name = "VillageRequestsCurrentCard"
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_label.custom_minimum_size = VillageRequestsUI.current_request_minimum_size(content)
	_style_label(order_label, 14, Color("#3b2b19"))
	market_panel.add_child(order_label)

	# Primary action row: keep the current request action visually dominant.
	# Sell crate lives below the scroll list as a secondary market action.
	var market_row: HBoxContainer = HBoxContainer.new()
	market_row.name = "VillageRequestsPrimaryActionRow"
	market_row.add_theme_constant_override("separation", int(UIConstants.CARD_GAP))
	market_panel.add_child(market_row)

	accept_order_button = Button.new()
	accept_order_button.name = "VillageRequestsAcceptButton"
	accept_order_button.text = "ACCEPT ORDER"
	accept_order_button.custom_minimum_size = VillageRequestsUI.action_button_minimum_size()
	_style_button(accept_order_button, 13, "action")
	accept_order_button.pressed.connect(func() -> void: call("_accept_selected_order"))
	market_row.add_child(accept_order_button)

	fulfill_order_button = Button.new()
	fulfill_order_button.name = "VillageRequestsFulfillButton"
	fulfill_order_button.text = "FULFILL ORDER"
	fulfill_order_button.custom_minimum_size = VillageRequestsUI.action_button_minimum_size()
	_style_button(fulfill_order_button, 13, "action")
	fulfill_order_button.pressed.connect(func() -> void: call("_fulfill_order"))
	market_row.add_child(fulfill_order_button)

	# ============================================================
	# /*=== AVAILABLE REQUESTS PAGER START ===*/
	# ------------------------------------------------------------
	# The pager is isolated inside a fixed-width VBoxContainer.
	#
	# Why:
	# - market_panel may be wider than the visible request column.
	# - the pager card must never inherit that extra width.
	# - the text lives in a child Label, so text cannot force the
	#   clickable Button wider.
	#
	# The pager section owns its width. Its children only fill the
	# pager section, not the entire market_panel.
	# ============================================================

	var request_pager_width: float = VillageRequestsUI.action_button_minimum_size().x

	var request_pager_section: VBoxContainer = VBoxContainer.new()
	request_pager_section.name = "VillageRequestsPagerSection"
	request_pager_section.custom_minimum_size = Vector2(
		request_pager_width,
		0.0
	)
	request_pager_section.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	request_pager_section.add_theme_constant_override(
		"separation",
		4
	)
	market_panel.add_child(request_pager_section)

	# ============================================================
	# /*=== AVAILABLE REQUESTS HEADER START ===*/
	# ============================================================

	var available_header_row: HBoxContainer = HBoxContainer.new()
	available_header_row.name = "VillageRequestsPagerHeader"
	available_header_row.custom_minimum_size = Vector2(
		request_pager_width,
		18.0
	)
	available_header_row.size_flags_horizontal = Control.SIZE_FILL
	available_header_row.add_theme_constant_override(
		"separation",
		int(UIConstants.CARD_GAP)
	)
	request_pager_section.add_child(available_header_row)

	var available_requests_label: Label = Label.new()
	available_requests_label.name = "VillageRequestsPagerTitle"
	available_requests_label.text = "AVAILABLE REQUESTS"
	available_requests_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(available_requests_label, 10, Color("#725431"))
	available_header_row.add_child(available_requests_label)

	order_page_label = Label.new()
	order_page_label.name = "VillageRequestsPagerCount"
	order_page_label.text = "0 / 0"
	order_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	order_page_label.custom_minimum_size = Vector2(52.0, 18.0)
	order_page_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	_style_label(order_page_label, 11, Color("#725431"))
	available_header_row.add_child(order_page_label)

	# ============================================================
	# /*=== AVAILABLE REQUESTS HEADER END ===*/
	# ============================================================

	# ============================================================
	# /*=== AVAILABLE REQUEST CARD START ===*/
	# ------------------------------------------------------------
	# The Button is intentionally text-free.
	# The child Label owns display text and clips inside the card.
	# ============================================================

	order_page_button = Button.new()
	order_page_button.name = "VillageRequestsPagerCard"
	order_page_button.toggle_mode = true
	order_page_button.text = ""
	order_page_button.custom_minimum_size = Vector2(
		request_pager_width,
		UIConstants.REQUEST_CARD_HEIGHT
	)
	order_page_button.size_flags_horizontal = Control.SIZE_FILL
	order_page_button.clip_contents = true
	_style_button(order_page_button, 12, "secondary")
	order_page_button.pressed.connect(_select_order_page_card)
	request_pager_section.add_child(order_page_button)

	order_page_text_label = Label.new()
	order_page_text_label.name = "VillageRequestsPagerCardText"
	order_page_text_label.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	order_page_text_label.offset_left = 10.0
	order_page_text_label.offset_top = 6.0
	order_page_text_label.offset_right = -10.0
	order_page_text_label.offset_bottom = -6.0
	order_page_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	order_page_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	order_page_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	order_page_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_page_text_label.clip_text = true
	order_page_text_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_style_label(order_page_text_label, 12, Color("#3b2b19"))
	order_page_button.add_child(order_page_text_label)

	# ============================================================
	# /*=== AVAILABLE REQUEST CARD END ===*/
	# ============================================================

	# ============================================================
	# /*=== ORDER PAGER NAVIGATION START ===*/
	# ------------------------------------------------------------
	# Navigation lives inside the same fixed-width pager section.
	# Flexible space pushes the compact arrow buttons to the right.
	# ============================================================

	var order_navigation_row: HBoxContainer = HBoxContainer.new()
	order_navigation_row.name = "VillageRequestsPagerNavigation"
	order_navigation_row.custom_minimum_size = Vector2(
		request_pager_width,
		30.0
	)
	order_navigation_row.size_flags_horizontal = Control.SIZE_FILL
	order_navigation_row.add_theme_constant_override(
		"separation",
		int(UIConstants.CARD_GAP)
	)
	request_pager_section.add_child(order_navigation_row)

	var navigation_spacer: Control = Control.new()
	navigation_spacer.name = "VillageRequestsPagerNavigationSpacer"
	navigation_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order_navigation_row.add_child(navigation_spacer)

	order_previous_button = Button.new()
	order_previous_button.name = "VillageRequestsPreviousButton"
	order_previous_button.text = "◀"
	order_previous_button.tooltip_text = "Previous request"
	order_previous_button.custom_minimum_size = Vector2(48.0, 30.0)
	_style_button(order_previous_button, 14, "secondary")
	order_previous_button.pressed.connect(_show_previous_order_page)
	order_navigation_row.add_child(order_previous_button)

	order_next_button = Button.new()
	order_next_button.name = "VillageRequestsNextButton"
	order_next_button.text = "▶"
	order_next_button.tooltip_text = "Next request"
	order_next_button.custom_minimum_size = Vector2(48.0, 30.0)
	_style_button(order_next_button, 14, "secondary")
	order_next_button.pressed.connect(_show_next_order_page)
	order_navigation_row.add_child(order_next_button)

	# ============================================================
	# /*=== ORDER PAGER NAVIGATION END ===*/
	# ============================================================

	# ============================================================
	# /*=== AVAILABLE REQUESTS PAGER END ===*/
	# ============================================================



	# Compact supporting info. These stay below the request list so they
	# do not compete with the selected request and primary action button.
	inventory_label = Label.new()
	inventory_label.name = "VillageRequestsAcceptedCount"
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.custom_minimum_size = VillageRequestsUI.support_label_minimum_size(content)
	_style_label(inventory_label, 12, Color("#5b492e"))
	market_panel.add_child(inventory_label)

	relationship_label = Label.new()
	relationship_label.name = "VillageRequestsRelationshipSummary"
	relationship_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relationship_label.custom_minimum_size = VillageRequestsUI.support_label_minimum_size(content)
	_style_label(relationship_label, 12, Color("#5b492e"))
	market_panel.add_child(relationship_label)

	logbook_label = Label.new()
	logbook_label.name = "VillageRequestsLogbook"
	logbook_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	logbook_label.custom_minimum_size = VillageRequestsUI.logbook_minimum_size(content)
	logbook_label.clip_text = true
	_style_label(logbook_label, 11, Color("#4c3c25"))
	market_panel.add_child(logbook_label)
	VillageRequestsUI.apply_layout(_village_requests_controls(), content)
	# ============================================================
	# /*=== VILLAGE REQUESTS CONTROLS END ===*/
	# ============================================================



	# ============================================================
	# /*=== FARM PANTRY CONTROLS START ===*/
	# ------------------------------------------------------------
	# Pantry is an inventory and crafting screen.
	# Delivery and selling remain in Village Requests.
	# ============================================================

	pantry_scroll = page_chrome_nodes.get(
		"content_scroll",
		null
	) as ScrollContainer

	pantry_panel = VBoxContainer.new()
	pantry_panel.name = "PantryPageContent"
	pantry_panel.custom_minimum_size = drawer_content_rect.size
	pantry_panel.add_theme_constant_override(
		"separation",
		PantryUI.panel_separation()
	)
	_add_page_chrome_panel(pantry_panel)

	# ============================================================
	# /*=== PANTRY TITLE START ===*/
	# ============================================================

	var pantry_title: Label = Label.new()
	pantry_title.name = "PantryTitle"
	pantry_title.text = "Farm Pantry 🫙"
	pantry_title.custom_minimum_size = PantryUI.title_minimum_size()
	pantry_title.visible = false
	_style_label(pantry_title, 25, Color("#3b2b19"))
	pantry_panel.add_child(pantry_title)

	# ============================================================
	# /*=== PANTRY TITLE END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY HARVEST GRID START ===*/
	# ------------------------------------------------------------
	# Each harvest card uses the real fig texture rather than an
	# emoji, with a full variety name and right-aligned quantity.
	# ============================================================

	var harvest_section: PanelContainer = PanelContainer.new()
	harvest_section.name = "PantryHarvestSection"
	harvest_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	harvest_section.add_theme_stylebox_override(
		"panel",
		PantryUI.section_style_box()
	)
	pantry_panel.add_child(harvest_section)

	var harvest_margin: MarginContainer = MarginContainer.new()
	harvest_margin.name = "PantryHarvestSectionPadding"
	harvest_margin.add_theme_constant_override("margin_left", PantryUI.section_margin())
	harvest_margin.add_theme_constant_override("margin_top", PantryUI.section_margin())
	harvest_margin.add_theme_constant_override("margin_right", PantryUI.section_margin())
	harvest_margin.add_theme_constant_override("margin_bottom", PantryUI.section_margin())
	harvest_section.add_child(harvest_margin)

	var harvest_stack: VBoxContainer = VBoxContainer.new()
	harvest_stack.name = "PantryHarvestSectionStack"
	harvest_stack.add_theme_constant_override("separation", PantryUI.stat_card_gap())
	harvest_margin.add_child(harvest_stack)

	harvest_stack.add_child(PantryUI.create_section_header(
		"PantryHarvestSection",
		"Harvest",
		_texture_from(item_textures, "fig")
	))

	pantry_harvest_grid = GridContainer.new()
	pantry_harvest_grid.name = "PantryHarvestGrid"
	pantry_harvest_grid.columns = 2
	pantry_harvest_grid.custom_minimum_size = PantryUI.harvest_grid_minimum_size()
	pantry_harvest_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pantry_harvest_grid.add_theme_constant_override(
		"h_separation",
		PantryUI.stat_card_gap()
	)
	pantry_harvest_grid.add_theme_constant_override(
		"v_separation",
		PantryUI.stat_card_gap()
	)
	harvest_stack.add_child(pantry_harvest_grid)

	pantry_harvest_amount_labels.clear()

	for variety_index in varieties.size():
		var harvest_card: PanelContainer = PanelContainer.new()
		harvest_card.name = "PantryHarvestCard_%s" % variety_index
		harvest_card.custom_minimum_size = PantryUI.stat_card_minimum_size()
		harvest_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var harvest_card_style: StyleBoxFlat = PantryUI.item_card_style_box()
		harvest_card_style.content_margin_left = 8.0
		harvest_card_style.content_margin_right = 8.0
		harvest_card_style.content_margin_top = 4.0
		harvest_card_style.content_margin_bottom = 4.0
		
		harvest_card.add_theme_stylebox_override(
			"panel",
			harvest_card_style
		)
		pantry_harvest_grid.add_child(harvest_card)

		var harvest_row: HBoxContainer = HBoxContainer.new()
		harvest_row.name = "PantryHarvestRow_%s" % variety_index
		harvest_row.add_theme_constant_override("separation", 5)
		harvest_card.add_child(harvest_row)

		var harvest_icon: TextureRect = TextureRect.new()
		harvest_icon.name = "PantryHarvestIcon_%s" % variety_index
		harvest_icon.custom_minimum_size = PantryUI.inventory_icon_minimum_size()
		harvest_icon.texture = _texture_from(item_textures, "fig")
		harvest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		harvest_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		harvest_row.add_child(harvest_icon)

		var harvest_name: Label = Label.new()
		harvest_name.name = "PantryHarvestName_%s" % variety_index
		harvest_name.text = String(
			varieties[variety_index].get("name", "Fig")
		)
		harvest_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		harvest_name.clip_text = true
		harvest_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_style_label(harvest_name, 12, Color("#3d2e1c"))
		harvest_row.add_child(harvest_name)

		var harvest_amount: Label = Label.new()
		harvest_amount.name = "PantryHarvestAmount_%s" % variety_index
		harvest_amount.text = "0"
		harvest_amount.custom_minimum_size = PantryUI.quantity_minimum_size()
		harvest_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		harvest_amount.add_theme_stylebox_override("normal",PantryUI.harvest_quantity_style_box())
		_style_label(harvest_amount, 13, Color("#35421f"))
		harvest_row.add_child(harvest_amount)

		pantry_harvest_amount_labels.append(harvest_amount)

	# ============================================================
	# /*=== PANTRY HARVEST TOTAL START ===*/
	# ------------------------------------------------------------
	# Margin keeps the total from touching the card's right edge.
	# ============================================================

	var harvest_total_margin: MarginContainer = MarginContainer.new()
	harvest_total_margin.name = "PantryHarvestTotalRow"
	harvest_total_margin.custom_minimum_size = PantryUI.total_row_minimum_size()
	harvest_total_margin.add_theme_constant_override("margin_right", 8)
	harvest_stack.add_child(harvest_total_margin)

	pantry_total_figs_label = Label.new()
	pantry_total_figs_label.name = "PantryHarvestTotalAmount"
	pantry_total_figs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pantry_total_figs_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(pantry_total_figs_label, 11, Color("#725431"))
	harvest_total_margin.add_child(pantry_total_figs_label)

	# ============================================================
	# /*=== PANTRY HARVEST TOTAL END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY HARVEST GRID END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY PRESERVES START ===*/
	# ============================================================

	var preserve_section: PanelContainer = PanelContainer.new()
	preserve_section.name = "PantryPreservesSection"
	preserve_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preserve_section.add_theme_stylebox_override("panel", PantryUI.section_style_box())
	pantry_panel.add_child(preserve_section)

	var preserve_margin: MarginContainer = MarginContainer.new()
	preserve_margin.name = "PantryPreservesSectionPadding"
	preserve_margin.add_theme_constant_override("margin_left", PantryUI.section_margin())
	preserve_margin.add_theme_constant_override("margin_top", PantryUI.section_margin())
	preserve_margin.add_theme_constant_override("margin_right", PantryUI.section_margin())
	preserve_margin.add_theme_constant_override("margin_bottom", PantryUI.section_margin())
	preserve_section.add_child(preserve_margin)

	var preserve_stack: VBoxContainer = VBoxContainer.new()
	preserve_stack.name = "PantryPreservesSectionStack"
	preserve_stack.add_theme_constant_override("separation", PantryUI.stat_card_gap())
	preserve_margin.add_child(preserve_stack)

	preserve_stack.add_child(PantryUI.create_section_header(
		"PantryPreservesSection",
		"Preserves",
		_texture_from(item_textures, "jam")
	))

	pantry_preserve_stats_row = HBoxContainer.new()
	pantry_preserve_stats_row.name = "PantryPreserveStatsRow"
	pantry_preserve_stats_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pantry_preserve_stats_row.custom_minimum_size = PantryUI.preserve_stats_row_minimum_size()
	pantry_preserve_stats_row.add_theme_constant_override(
		"separation",
		PantryUI.stat_card_gap()
	)
	preserve_stack.add_child(pantry_preserve_stats_row)

	# ============================================================
	# /*=== PANTRY JARS STAT START ===*/
	# ============================================================

	var jars_card: PanelContainer = PanelContainer.new()
	jars_card.name = "PantryJarsCard"
	jars_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jars_card.add_theme_stylebox_override("panel",PantryUI.jars_card_style_box())
	pantry_preserve_stats_row.add_child(jars_card)

	var jars_row: HBoxContainer = HBoxContainer.new()
	jars_row.name = "PantryJarsRow"
	jars_row.add_theme_constant_override("separation", 6)
	jars_card.add_child(jars_row)

	var jars_name: Label = Label.new()
	jars_name.name = "PantryJarsName"
	jars_name.text = "🫙  Jars"
	jars_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(jars_name, 18, Color("#fff8e8"))
	jars_row.add_child(jars_name)

	pantry_jars_count_label = Label.new()
	pantry_jars_count_label.name = "PantryJarsAmount"
	pantry_jars_count_label.custom_minimum_size = PantryUI.quantity_minimum_size()
	pantry_jars_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pantry_jars_count_label.add_theme_stylebox_override("normal", PantryUI.quantity_style_box())
	_style_label(pantry_jars_count_label, 14, Color("#3d2e1c"))
	jars_row.add_child(pantry_jars_count_label)

	# ============================================================
	# /*=== PANTRY JARS STAT END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY JAM STAT START ===*/
	# ============================================================

	var jam_card: PanelContainer = PanelContainer.new()
	jam_card.name = "PantryJamCard"
	jam_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jam_card.add_theme_stylebox_override("panel",PantryUI.jam_card_style_box())
	pantry_preserve_stats_row.add_child(jam_card)

	var jam_row: HBoxContainer = HBoxContainer.new()
	jam_row.name = "PantryJamRow"
	jam_row.add_theme_constant_override("separation", 6)
	jam_card.add_child(jam_row)

	var jam_icon: TextureRect = TextureRect.new()
	jam_icon.name = "PantryJamIcon"
	jam_icon.custom_minimum_size = PantryUI.preserve_icon_minimum_size()
	jam_icon.texture = _texture_from(item_textures, "jam")
	jam_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	jam_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jam_row.add_child(jam_icon)

	var jam_name: Label = Label.new()
	jam_name.name = "PantryJamName"
	jam_name.text = "Jam"
	jam_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(jam_name, 18, Color("#fff8e8"))
	jam_row.add_child(jam_name)

	pantry_jam_count_label = Label.new()
	pantry_jam_count_label.name = "PantryJamAmount"
	pantry_jam_count_label.custom_minimum_size = PantryUI.quantity_minimum_size()
	pantry_jam_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pantry_jam_count_label.add_theme_stylebox_override("normal", PantryUI.quantity_style_box())
	_style_label(pantry_jam_count_label, 14, Color("#3d2e1c"))
	jam_row.add_child(pantry_jam_count_label)

	# ============================================================
	# /*=== PANTRY JAM STAT END ===*/
	# ============================================================

	preserve_label = Label.new()
	preserve_label.name = "PantryPreserveRecipe"
	preserve_label.text = PantryUI.preserve_recipe_text()
	preserve_label.custom_minimum_size = PantryUI.preserve_recipe_minimum_size()
	_style_label(preserve_label, 11, Color("#5b492e"))
	preserve_stack.add_child(preserve_label)

	pantry_preserve_actions = HBoxContainer.new()
	pantry_preserve_actions.name = "PantryPreserveActions"
	pantry_preserve_actions.custom_minimum_size = PantryUI.action_row_minimum_size()
	pantry_preserve_actions.add_theme_constant_override(
		"separation",
		PantryUI.action_gap()
	)
	preserve_stack.add_child(pantry_preserve_actions)

	make_jam_button = Button.new()
	make_jam_button.name = "PantryMakeJamButton"
	make_jam_button.text = "Make Jam"
	make_jam_button.custom_minimum_size = PantryUI.primary_button_minimum_size()
	make_jam_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(make_jam_button, 12, "action")
	_decorate_button_icon(
		make_jam_button,
		_texture_from(item_textures, "jam")
	)
	make_jam_button.pressed.connect(func() -> void: call("_make_jam"))
	pantry_preserve_actions.add_child(make_jam_button)

	buy_jars_button = Button.new()
	buy_jars_button.name = "PantryBuyJarsButton"
	buy_jars_button.text = "Buy Jars"
	buy_jars_button.custom_minimum_size = PantryUI.primary_button_minimum_size()
	buy_jars_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(buy_jars_button, 12, "secondary")
	buy_jars_button.pressed.connect(func() -> void: call("_buy_mason_jars"))
	pantry_preserve_actions.add_child(buy_jars_button)

	recipe_button = Button.new()
	recipe_button.name = "PantryRecipesButton"
	recipe_button.text = "📖  Jam Recipes"
	recipe_button.custom_minimum_size = PantryUI.recipe_button_minimum_size()
	recipe_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(recipe_button, 12, "tertiary")
	recipe_button.pressed.connect(func() -> void: call("_show_recipe"))
	preserve_stack.add_child(recipe_button)

	# ============================================================
	# /*=== PANTRY PRESERVES END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY PLANTING STOCK GRID START ===*/
	# ------------------------------------------------------------
	# Planting stock mirrors Harvest but uses the existing seed /
	# cutting texture and softer styling.
	# ============================================================

	var planting_section: PanelContainer = PanelContainer.new()
	planting_section.name = "PantryPlantingSection"
	planting_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	planting_section.add_theme_stylebox_override(
		"panel",
		PantryUI.section_style_box()
	)
	pantry_panel.add_child(planting_section)

	var planting_margin: MarginContainer = MarginContainer.new()
	planting_margin.name = "PantryPlantingSectionPadding"
	planting_margin.add_theme_constant_override("margin_left", PantryUI.section_margin())
	planting_margin.add_theme_constant_override("margin_top", PantryUI.section_margin())
	planting_margin.add_theme_constant_override("margin_right", PantryUI.section_margin())
	planting_margin.add_theme_constant_override("margin_bottom", PantryUI.section_margin())
	planting_section.add_child(planting_margin)

	var planting_stack: VBoxContainer = VBoxContainer.new()
	planting_stack.name = "PantryPlantingSectionStack"
	planting_stack.add_theme_constant_override("separation", PantryUI.stat_card_gap())
	planting_margin.add_child(planting_stack)

	planting_stack.add_child(PantryUI.create_section_header(
		"PantryPlantingSection",
		"Planting Stock",
		_texture_from(item_textures, "seeds")
	))

	pantry_planting_grid = GridContainer.new()
	pantry_planting_grid.name = "PantryPlantingStockGrid"
	pantry_planting_grid.columns = 2
	pantry_planting_grid.custom_minimum_size = PantryUI.planting_grid_minimum_size()
	pantry_planting_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pantry_planting_grid.add_theme_constant_override(
		"h_separation",
		PantryUI.stat_card_gap()
	)
	pantry_planting_grid.add_theme_constant_override(
		"v_separation",
		PantryUI.stat_card_gap()
	)
	planting_stack.add_child(pantry_planting_grid)

	pantry_cutting_amount_labels.clear()

	for variety_index in varieties.size():
		var cutting_card: PanelContainer = PanelContainer.new()
		cutting_card.name = "PantryCuttingCard_%s" % variety_index
		cutting_card.custom_minimum_size = PantryUI.stat_card_minimum_size()
		cutting_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cutting_card.add_theme_stylebox_override("panel", PantryUI.item_card_style_box())
		pantry_planting_grid.add_child(cutting_card)

		var cutting_row: HBoxContainer = HBoxContainer.new()
		cutting_row.name = "PantryCuttingRow_%s" % variety_index
		cutting_row.add_theme_constant_override("separation", 5)
		cutting_card.add_child(cutting_row)

		var cutting_icon: TextureRect = TextureRect.new()
		cutting_icon.name = "PantryCuttingIcon_%s" % variety_index
		cutting_icon.custom_minimum_size = PantryUI.inventory_icon_minimum_size()
		cutting_icon.texture = _texture_from(item_textures, "seeds")
		cutting_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cutting_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cutting_row.add_child(cutting_icon)

		var cutting_name: Label = Label.new()
		cutting_name.name = "PantryCuttingName_%s" % variety_index
		cutting_name.text = String(
			varieties[variety_index].get("name", "Cutting")
		)
		cutting_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cutting_name.clip_text = true
		cutting_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_style_label(cutting_name, 11, Color("#4f402d"))
		cutting_row.add_child(cutting_name)

		var cutting_amount: Label = Label.new()
		cutting_amount.name = "PantryCuttingAmount_%s" % variety_index
		cutting_amount.text = "0"
		cutting_amount.custom_minimum_size = PantryUI.quantity_minimum_size()
		cutting_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cutting_amount.add_theme_stylebox_override("normal", PantryUI.quantity_style_box())
		_style_label(cutting_amount, 12, Color("#4f402d"))
		cutting_row.add_child(cutting_amount)

		pantry_cutting_amount_labels.append(cutting_amount)

	# ============================================================
	# /*=== PANTRY CUTTINGS TOTAL START ===*/
	# ============================================================

	var cuttings_total_margin: MarginContainer = MarginContainer.new()
	cuttings_total_margin.name = "PantryCuttingsTotalRow"
	cuttings_total_margin.custom_minimum_size = PantryUI.total_row_minimum_size()
	cuttings_total_margin.add_theme_constant_override("margin_right", 8)
	planting_stack.add_child(cuttings_total_margin)

	pantry_total_cuttings_label = Label.new()
	pantry_total_cuttings_label.name = "PantryCuttingsTotalAmount"
	pantry_total_cuttings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pantry_total_cuttings_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(pantry_total_cuttings_label, 11, Color("#725431"))
	cuttings_total_margin.add_child(pantry_total_cuttings_label)

	# ============================================================
	# /*=== PANTRY CUTTINGS TOTAL END ===*/
	# ============================================================

	pantry_trees_label = Label.new()
	pantry_trees_label.name = "PantryTreesSummary"
	pantry_trees_label.custom_minimum_size = PantryUI.trees_label_minimum_size()
	pantry_trees_label.clip_text = true
	pantry_trees_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_style_label(pantry_trees_label, 11, Color("#5b492e"))
	planting_stack.add_child(pantry_trees_label)

	# ============================================================
	# /*=== PANTRY PLANTING STOCK GRID END ===*/
	# ============================================================

	# ============================================================
	# /*=== PANTRY ABOUT JAM START ===*/
	# ============================================================

	var about_section: PanelContainer = PanelContainer.new()
	about_section.name = "PantryAboutSection"
	about_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	about_section.add_theme_stylebox_override(
		"panel",
		PantryUI.quiet_section_style_box()
	)
	pantry_panel.add_child(about_section)

	var about_margin: MarginContainer = MarginContainer.new()
	about_margin.name = "PantryAboutSectionPadding"
	about_margin.add_theme_constant_override("margin_left", PantryUI.section_margin())
	about_margin.add_theme_constant_override("margin_top", PantryUI.section_margin())
	about_margin.add_theme_constant_override("margin_right", PantryUI.section_margin())
	about_margin.add_theme_constant_override("margin_bottom", PantryUI.section_margin())
	about_section.add_child(about_margin)

	var about_stack: VBoxContainer = VBoxContainer.new()
	about_stack.name = "PantryAboutSectionStack"
	about_stack.add_theme_constant_override("separation", PantryUI.stat_card_gap())
	about_margin.add_child(about_stack)

	about_stack.add_child(PantryUI.create_section_header(
		"PantryAboutSection",
		"About Jam",
		_texture_from(ui_textures, "guide")
	))

	pantry_hint_label = Label.new()
	pantry_hint_label.name = "PantryAboutJamText"
	pantry_hint_label.custom_minimum_size = PantryUI.hint_label_minimum_size()
	pantry_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pantry_hint_label.text = PantryUI.about_jam_text()
	_style_label(pantry_hint_label, 11, Color("#5b492e"))
	about_stack.add_child(pantry_hint_label)

	# ============================================================
	# /*=== PANTRY ABOUT JAM END ===*/
	# ============================================================

	# ============================================================
	# /*=== FARM PANTRY CONTROLS END ===*/
	# ============================================================

	guide_panel = VBoxContainer.new()
	guide_panel.name = "GuidePageContent"
	guide_panel.custom_minimum_size = drawer_content_rect.size
	guide_panel.add_theme_constant_override("separation", GuideUI.panel_separation())
	_add_page_chrome_panel(guide_panel)

	var guide_title: Label = Label.new()
	guide_title.name = "GuideTitle"
	guide_title.text = "Fig Guide"
	_style_label(guide_title, 26, Color("#3b2b19"))
	guide_panel.add_child(guide_title)

	_add_section_label(guide_panel, "CULTIVAR")
	notebook_label = Label.new()
	notebook_label.name = "GuideNotebook"
	notebook_label.custom_minimum_size = GuideUI.notebook_minimum_size()
	notebook_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(notebook_label, 14, Color("#332414"))
	guide_panel.add_child(notebook_label)

	_add_section_label(guide_panel, "SELECTED PLOT")
	plot_status_label = Label.new()
	plot_status_label.name = "GuideSelectedPlot"
	plot_status_label.custom_minimum_size = GuideUI.plot_status_minimum_size()
	plot_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(plot_status_label, 13, Color("#3d2e1c"))
	guide_panel.add_child(plot_status_label)

	_add_section_label(guide_panel, "VISUAL KEY")
	var moisture_key_row: HBoxContainer = HBoxContainer.new()
	moisture_key_row.name = "GuideMoistureKeyRow"
	moisture_key_row.add_theme_constant_override("separation", GuideUI.visual_key_gap())
	guide_panel.add_child(moisture_key_row)
	_add_moisture_key(moisture_key_row, Color("#6f4a34"), "Wet")
	_add_moisture_key(moisture_key_row, Color("#8f6040"), "Moist")
	_add_moisture_key(moisture_key_row, Color("#bd8352"), "Dry")

	guide_legend_label = Label.new()
	guide_legend_label.name = "GuideLegend"
	guide_legend_label.custom_minimum_size = GuideUI.legend_minimum_size()
	guide_legend_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(guide_legend_label, 13, Color("#4d3b24"))
	guide_panel.add_child(guide_legend_label)

	help_panel = VBoxContainer.new()
	help_panel.name = "MorePageContent"
	help_panel.custom_minimum_size = drawer_content_rect.size
	help_panel.add_theme_constant_override("separation", HelpUI.panel_separation())
	_add_page_chrome_panel(help_panel)

	var help_title: Label = Label.new()
	help_title.name = "HelpTitle"
	help_title.text = "How to Play"
	_style_label(help_title, 26, Color("#3b2b19"))
	help_panel.add_child(help_title)

	_add_section_label(help_panel, "QUICK START")
	help_text_label = Label.new()
	help_text_label.name = "HelpText"
	help_text_label.custom_minimum_size = HelpUI.help_text_minimum_size()
	help_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_text_label.text = HelpUI.how_to_play_text()
	_style_label(help_text_label, 13, Color("#3d2e1c"))
	help_panel.add_child(help_text_label)

	bottom_action_label = Label.new()
	bottom_action_label.name = "BottomStatusBarActionCard"
	var bottom_action_rect: Rect2 = _bottom_bar_layout().get("action_label", Rect2())
	bottom_action_label.position = bottom_action_rect.position
	bottom_action_label.custom_minimum_size = bottom_action_rect.size
	bottom_action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(bottom_action_label, 13, Color("#2f3b1f"))
	ui.add_child(bottom_action_label)

	plot_card_label = Label.new()
	plot_card_label.name = "BottomStatusBarPlotCard"
	var plot_card_rect: Rect2 = _bottom_bar_layout().get("plot_label", Rect2())
	plot_card_label.position = plot_card_rect.position
	plot_card_label.custom_minimum_size = plot_card_rect.size
	plot_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(plot_card_label, 12, Color("#2f3b1f"))
	ui.add_child(plot_card_label)

	dock_hint_label = Label.new()
	dock_hint_label.name = "DrawerHintLabel"
	var drawer_hint_rect: Rect2 = _drawer_layout().get("hint", Rect2())
	dock_hint_label.position = drawer_hint_rect.position
	dock_hint_label.custom_minimum_size = drawer_hint_rect.size
	dock_hint_label.clip_text = true
	_style_label(dock_hint_label, 11, Color("#725431"))
	ui.add_child(dock_hint_label)

	message_label = Label.new()
	message_label.name = "BottomStatusBarMessage"
	var message_rect: Rect2 = _bottom_bar_layout().get("message", Rect2())
	message_label.position = message_rect.position
	message_label.custom_minimum_size = message_rect.size
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(message_label, 13, Color("#2f3b1f"))
	ui.add_child(message_label)


	dialogue_title_label = Label.new()
	dialogue_title_label.name = "DialogueTitle"
	dialogue_title_label.position = Vector2(418, 218)
	dialogue_title_label.custom_minimum_size = Vector2(372, 30)
	_style_label(dialogue_title_label, 22, Color("#3b2b19"))
	ui.add_child(dialogue_title_label)

	dialogue_body_label = Label.new()
	dialogue_body_label.name = "DialogueBody"
	dialogue_body_label.position = Vector2(418, 256)
	dialogue_body_label.custom_minimum_size = Vector2(438, 190)
	dialogue_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(dialogue_body_label, 14, Color("#3d2e1c"))
	ui.add_child(dialogue_body_label)

	dialogue_close_button = Button.new()
	dialogue_close_button.name = "DialogueCloseButton"
	dialogue_close_button.text = "Close"
	dialogue_close_button.position = Vector2(744, 462)
	dialogue_close_button.custom_minimum_size = Vector2(112, 32)
	_style_button(dialogue_close_button, 13, "secondary")
	dialogue_close_button.pressed.connect(func() -> void: call("_close_dialogue"))
	ui.add_child(dialogue_close_button)
	_apply_layout_to_controls()




# ============================================================
# /*=== FUNCTION BUILD UI END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD PAGE CHROME START ===*/
# ============================================================

func _build_page_chrome(parent: Node) -> void:
	page_chrome_nodes = PageChromeUI.build()
	var chrome: Control = page_chrome_nodes.get("chrome", null) as Control
	if chrome != null:
		parent.add_child(chrome)

	var back_button: Button = page_chrome_nodes.get("back_button", null) as Button
	if back_button != null:
		back_button.tooltip_text = "Back to Farm"
		_style_button(back_button, 18, "tertiary")
		back_button.pressed.connect(_page_chrome_back)

	var close_button: Button = page_chrome_nodes.get("close_button", null) as Button
	if close_button != null:
		close_button.tooltip_text = "Close page"
		_style_button(close_button, 18, "tertiary")
		close_button.pressed.connect(_close_page_chrome)

	var title_label: Label = page_chrome_nodes.get(
		"title_label",
		null
	) as Label
	if title_label != null:
		title_label.add_theme_font_override(
			"font",
			PAGE_TITLE_FONT
		)
		_style_label(
			title_label,
			UIConstants.TITLE_SIZE,
			Color("#3b2b19")
		)

	PageChromeUI.set_title(page_chrome_nodes, _page_chrome_title(), _page_chrome_icon())
	_build_global_bottom_navigation()




# ============================================================
# /*=== FUNCTION BUILD PAGE CHROME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD GLOBAL BOTTOM NAVIGATION START ===*/
# ============================================================

func _build_global_bottom_navigation() -> void:
	bottom_nav_buttons.clear()

	var bottom_row: HBoxContainer = page_chrome_nodes.get(
		"bottom_row",
		null
	) as HBoxContainer
	if bottom_row == null:
		return

	_add_bottom_nav_button(bottom_row, "farm", "Farm", 0, "GlobalBottomNavFarmButton")
	_add_bottom_nav_button(bottom_row, "village", "Village", 1, "GlobalBottomNavVillageButton")
	_add_bottom_nav_button(bottom_row, "pantry", "Pantry", 2, "GlobalBottomNavPantryButton")
	_add_bottom_nav_button(bottom_row, "guide", "Guide", 3, "GlobalBottomNavGuideButton")
	_add_bottom_nav_button(bottom_row, "more", "More", 4, "GlobalBottomNavMoreButton")


func _add_bottom_nav_button(
	parent: Control,
	key: String,
	label: String,
	tab: int,
	node_name: String
) -> void:
	var button: Button = BottomNavigationUI.add_item(
		parent,
		node_name,
		label,
		_tab_texture(tab)
	)
	button.tooltip_text = label
	button.pressed.connect(func() -> void: call("_open_page_chrome_tab", tab))
	bottom_nav_buttons[key] = button




# ============================================================
# /*=== FUNCTION BUILD GLOBAL BOTTOM NAVIGATION END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PAGE CHROME NAVIGATION START ===*/
# ============================================================

func _page_chrome_back() -> void:
	side_tab = 0
	panel_open = true
	_update_ui()


func _close_page_chrome() -> void:
	panel_open = false
	_update_ui()


func _open_page_chrome_tab(tab: int) -> void:
	side_tab = clampi(tab, 0, 4)
	panel_open = true
	_update_ui()


func _apply_page_chrome_state() -> void:
	var page_chrome: Control = page_chrome_nodes.get("chrome", null) as Control
	if page_chrome != null:
		page_chrome.visible = _is_page_chrome_open()

	PageChromeUI.set_title(page_chrome_nodes, _page_chrome_title(), _page_chrome_icon())

	var panels: Array = [
		controls_panel,
		market_panel,
		pantry_panel,
		guide_panel,
		help_panel
	]

	for index in range(panels.size()):
		var panel: Control = panels[index] as Control
		if panel == null:
			continue
		panel.visible = _is_page_chrome_open() and index == side_tab


func _bottom_nav_active_key() -> String:
	if not panel_open:
		return ""

	match side_tab:
		0:
			return "farm"
		1:
			return "village"
		2:
			return "pantry"
		3:
			return "guide"
		4:
			return "more"
	return ""




# ============================================================
# /*=== FUNCTION PAGE CHROME NAVIGATION END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUILD UI DEBUG OVERLAY START ===*/
# ============================================================

func _build_ui_debug_overlay() -> void:
	if ui_debug_overlay != null:
		return
	ui_debug_overlay = UIDebugOverlay.new()
	ui_debug_overlay.name = "UIDebugOverlay"
	add_child(ui_debug_overlay)
	ui_debug_overlay.set_root_node(self)




# ============================================================
# /*=== FUNCTION BUILD UI DEBUG OVERLAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD SECTION LABEL START ===*/
# ============================================================

func _add_section_label(parent: Control, text: String) -> void:
	var spacer: ColorRect = ColorRect.new()
	spacer.name = "%sSectionSpacer" % String(text).replace(" ", "")
	spacer.color = Color(1.0, 1.0, 1.0, 0.0)
	spacer.custom_minimum_size = DrawerUI.section_spacer_minimum_size()
	parent.add_child(spacer)
	var header: HBoxContainer = SectionHeaderUI.create(
		"%s" % String(text).replace(" ", ""),
		text
	)
	parent.add_child(header)




# ============================================================
# /*=== FUNCTION ADD SECTION LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION VILLAGE REQUESTS CONTENT RECT START ===*/
# ============================================================

func _village_requests_content_rect() -> Rect2:
	return _drawer_layout().get("content", Rect2())



# ============================================================
# /*=== FUNCTION VILLAGE REQUESTS CONTENT RECT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION VILLAGE REQUESTS CONTROLS START ===*/
# ============================================================

func _village_requests_controls() -> Dictionary:
	return {
		"market_panel": market_panel,
		"container_mode": true,
		"market_title": market_title,
		"weekly_label": festival_label,
		"order_detail_label": order_label,
		"accept_button": accept_order_button,
		"fulfill_button": fulfill_order_button,
		"crate_button": crate_button,
		# Pager width is owned locally by request_pager_section.
		# Do not pass order_page_button to VillageRequestsUI.apply_layout().
		"inventory_label": inventory_label,
		"relationship_label": relationship_label,
		"logbook_label": logbook_label
	}



# ============================================================
# /*=== FUNCTION VILLAGE REQUESTS CONTROLS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD MARKET SECTION LABEL START ===*/
# ============================================================

func _add_market_section_label(parent: Control, text: String) -> void:
	# ============================================================
	# VILLAGE REQUESTS SECTION LABEL
	# ------------------------------------------------------------
	# Local version of _add_section_label() with no spacer and with the
	# orderbook width. This keeps the request drawer tighter and avoids
	# the uneven vertical gaps seen in the first pass.
	# ============================================================
	var header: HBoxContainer = SectionHeaderUI.create(
		"VillageRequests%s" % String(text).replace(" ", ""),
		text
	)
	header.custom_minimum_size = VillageRequestsUI.section_label_minimum_size(_village_requests_content_rect())
	parent.add_child(header)




# ============================================================
# /*=== FUNCTION ADD MARKET SECTION LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD TAB BUTTON START ===*/
# ============================================================

func _add_tab_button(parent: Control, text: String, tab: int) -> void:
	var button: Button = Button.new()
	button.name = "MenuDock%sButton" % text
	button.text = _tab_icon(tab)
	button.tooltip_text = text
	button.toggle_mode = true
	button.custom_minimum_size = ToolPanelUI.button_minimum_size()
	_style_button(button, 18, _tab_role(tab))
	_apply_button_icon(button, _tab_texture(tab))
	button.pressed.connect(func() -> void: call("_set_side_tab", tab))
	parent.add_child(button)
	tab_buttons[tab] = button




# ============================================================
# /*=== FUNCTION ADD TAB BUTTON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TAB ROLE START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION TAB ROLE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TAB ICON START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION TAB ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SET SIDE TAB START ===*/
# ============================================================

func _set_side_tab(tab: int) -> void:
	var next_tab: int = clampi(tab, 0, 4)
	if panel_open and side_tab == next_tab:
		panel_open = false
	else:
		side_tab = next_tab
		panel_open = true
	_update_ui()




# ============================================================
# /*=== FUNCTION SET SIDE TAB END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD ORDER BUTTON START ===*/
# ============================================================

func _add_order_button(parent: Control, slot: int) -> void:
	# ============================================================
	# AVAILABLE REQUEST CARD BUTTON
	# ------------------------------------------------------------
	# Each order in the scroll list is still a Button, but we size it
	# like a small delivery-app card instead of a single cramped line.
	# Text comes from OrderSystem.order_button_text().
	# ============================================================
	var button: Button = Button.new()
	button.name = "VillageRequestsLegacyOrderButton_%s" % slot
	button.toggle_mode = true
	var content: Rect2 = _village_requests_content_rect()
	button.custom_minimum_size = VillageRequestsUI.request_card_minimum_size(content)
	button.clip_text = true
	_style_button(button, 12, "secondary")
	button.pressed.connect(func() -> void: call("_select_order_slot", slot))
	parent.add_child(button)
	order_buttons.append(button)




# ============================================================
# /*=== FUNCTION ADD ORDER BUTTON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD MOISTURE KEY START ===*/
# ============================================================

func _add_moisture_key(parent: Control, swatch_color: Color, label_text: String) -> void:
	var group: HBoxContainer = HBoxContainer.new()
	group.name = "GuideMoistureKey%s" % label_text
	group.add_theme_constant_override("separation", 4)
	parent.add_child(group)
	var swatch: ColorRect = ColorRect.new()
	swatch.name = "GuideMoistureSwatch%s" % label_text
	swatch.color = swatch_color
	swatch.custom_minimum_size = Vector2(18, 18)
	group.add_child(swatch)
	var label: Label = Label.new()
	label.name = "GuideMoistureLabel%s" % label_text
	label.text = label_text
	_style_label(label, 12, Color("#4d3b24"))
	group.add_child(label)




# ============================================================
# /*=== FUNCTION ADD MOISTURE KEY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION STYLE LABEL START ===*/
# ============================================================

func _style_label(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 1.0, 0.28))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)




# ============================================================
# /*=== FUNCTION STYLE LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUTTON STYLE START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION BUTTON STYLE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ROUNDED BOX START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION ROUNDED BOX END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW ROUNDED BOX START ===*/
# ============================================================

func _draw_rounded_box(rect: Rect2, fill: Color, border: Color, radius: int, border_width: int = 1) -> void:
	draw_style_box(_rounded_box(fill, border, radius, border_width), rect)




# ============================================================
# /*=== FUNCTION DRAW ROUNDED BOX END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION STYLE BUTTON START ===*/
# ============================================================

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
	elif role == "tertiary":
		fill = Color("#fff8e8")
		hover = Color("#fff4df")
		pressed = Color("#ead6aa")
		border = Color("#d9c49c")
		font_color = Color("#5b492e")
	elif role == "jam_primary":
		fill = Color("#8b4a91")
		hover = Color("#9d5ca3")
		pressed = Color("#703975")
		border = Color("#653169")
		font_color = Color("#fff8e8")
	elif role == "jars_secondary":
		fill = Color("#8fa94c")
		hover = Color("#a0b95c")
		pressed = Color("#71873a")
		border = Color("#667934")
		font_color = Color("#fff8e8")	
	button.add_theme_stylebox_override("normal", _button_style(fill, border))
	button.add_theme_stylebox_override("hover", _button_style(hover, border))
	button.add_theme_stylebox_override("pressed", _button_style(pressed, border))
	button.add_theme_stylebox_override("disabled", _button_style(Color("#c8c0ae"), Color("#8f826e")))
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color("#5f574b"))




# ============================================================
# /*=== FUNCTION STYLE BUTTON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD TOOL BUTTON START ===*/
# ============================================================

func _add_tool_button(parent: Control, text: String, tool: int) -> void:
	var button: Button = Button.new()
	button.name = "ToolDock%sButton" % _tool_name(tool)
	button.text = text
	button.tooltip_text = "%s  [%s]" % [_tool_name(tool), _tool_shortcut(tool)]
	button.toggle_mode = true
	button.custom_minimum_size = ToolPanelUI.button_minimum_size()
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




# ============================================================
# /*=== FUNCTION ADD TOOL BUTTON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADD VARIETY BUTTON START ===*/
# ============================================================

func _add_variety_button(parent: Control, index: int) -> void:
	var variety: Dictionary = varieties[index]
	var button: Button = Button.new()
	button.name = "FarmCuttingButton_%s" % index
	button.text = String(variety["short"])
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(90, 34)
	_style_button(button, 12, "secondary")
	button.pressed.connect(func() -> void: _select_variety(index))
	parent.add_child(button)
	variety_buttons[index] = button



# ============================================================
# /*=== FUNCTION ADD VARIETY BUTTON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW BACKGROUND START ===*/
# ============================================================

func _draw_background() -> void:
	FarmRenderer.draw_background(
		self,
		weather_table[current_weather],
		get_viewport_rect().size,
		HUD_H,
		GAP
	)
	FarmRenderer.draw_farm_board(self, _farm_board_rect(), _plot_bed_rect())



# ============================================================
# /*=== FUNCTION DRAW BACKGROUND END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW FARM START ===*/
# ============================================================

func _draw_farm() -> void:
	FarmRenderer.draw_farm_plots(
		self,
		plots,
		varieties,
		crop_textures,
		GRID_W,
		GRID_H,
		farm_origin,
		tile_size,
		selected_cell,
		farmer_cell
	)


# ============================================================
# /*=== FUNCTION DRAW FARM END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW OPEN DRAWER START ===*/
# ============================================================

func _draw_open_drawer() -> void:
	if not panel_open:
		return
	if _is_page_chrome_open():
		return
	DrawerUI.draw_drawer_shell(self, _drawer_layout())
	_draw_drawer_cards()




# ============================================================
# /*=== FUNCTION DRAW OPEN DRAWER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW DRAWER CARDS START ===*/
# ============================================================

func _draw_drawer_cards() -> void:
	var content: Rect2 = _village_requests_content_rect()

	match side_tab:
		0:
			for backplate in FarmControlsUI.card_backplates(content):
				_draw_drawer_card(backplate)

		1:
			for backplate in VillageRequestsUI.card_backplates(content):
				_draw_drawer_card(backplate)

		2:
			for backplate in PantryUI.card_backplates(content):
				_draw_drawer_card(backplate)

		3:
			for backplate in GuideUI.card_backplates(content):
				_draw_drawer_card(backplate)

		4:
			for backplate in HelpUI.card_backplates(content):
				_draw_drawer_card(backplate)



# ============================================================
# /*=== FUNCTION DRAW DRAWER CARDS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW DRAWER CARD START ===*/
# ============================================================

func _draw_drawer_card(rect: Rect2) -> void:
	draw_style_box(_rounded_box(Color(0.82, 0.65, 0.36, 0.12), Color(0.82, 0.65, 0.36, 0.0), 10), Rect2(rect.position + Vector2(1, 2), rect.size))
	_draw_rounded_box(rect, Color("#fffaf0"), Color("#ead6aa"), 10, 1)




# ============================================================
# /*=== FUNCTION DRAW DRAWER CARD END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW TOP HUD BAR START ===*/
# ============================================================

func _draw_top_hud_bar() -> void:
	HUDUI.draw_top_hud_bar(self, _hud_layout())




# ============================================================
# /*=== FUNCTION DRAW TOP HUD BAR END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW SIDEBAR START ===*/
# ============================================================

func _draw_sidebar() -> void:
	ToolPanelUI.draw_panel(self, _tool_panel_layout(), BG_CREAM)




# ============================================================
# /*=== FUNCTION DRAW SIDEBAR END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW DIALOGUE POPUP START ===*/
# ============================================================

func _draw_dialogue_popup() -> void:
	if not dialogue_visible:
		return
	var rect: Rect2 = Rect2(Vector2(388, 186), Vector2(504, 324))
	draw_style_box(_rounded_box(Color(0.16, 0.10, 0.05, 0.24), Color(0.16, 0.10, 0.05, 0.0), 18), Rect2(rect.position + Vector2(4, 6), rect.size))
	_draw_rounded_box(rect, Color("#7a5a35"), Color("#5b4228"), 18, 2)
	_draw_rounded_box(rect.grow(-6), Color("#f0ddb5"), Color("#c9a96a"), 14, 1)
	_draw_rounded_box(rect.grow(-18), Color("#fff8e8"), Color("#ead6aa"), 10, 1)
	draw_line(Vector2(416, 250), Vector2(862, 250), Color(0.50, 0.36, 0.18, 0.22), 1.5)




# ============================================================
# /*=== FUNCTION DRAW DIALOGUE POPUP END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW MESSAGE TOAST START ===*/
# ============================================================

func _draw_message_toast() -> void:
	if message_timer <= 0.0:
		return
	BottomBarUI.draw_message_toast(self, _bottom_bar_layout())




# ============================================================
# /*=== FUNCTION DRAW MESSAGE TOAST END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW PAUSE OVERLAY START ===*/
# ============================================================

func _draw_pause_overlay() -> void:
	if not game_paused:
		return
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.10, 0.08, 0.05, 0.36))
	var rect: Rect2 = Rect2(Vector2(272, 228), Vector2(296, 92))
	draw_rect(rect, Color(0.20, 0.14, 0.09, 0.90))
	draw_rect(rect.grow(-5), Color("#f3dfb8"))
	draw_rect(rect.grow(-16), Color("#fff6df"))
	draw_rect(rect, Color("#4f3722"), false, 3.0)




# ============================================================
# /*=== FUNCTION DRAW PAUSE OVERLAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW BOTTOM STATUS BAR START ===*/
# ============================================================

func _draw_bottom_status_bar() -> void:
	BottomBarUI.draw_bottom_bar(self, _bottom_bar_layout())


# ============================================================
# /*=== FUNCTION DRAW BOTTOM STATUS BAR END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW SIDE SCENE START ===*/
# ============================================================

func _draw_side_scene() -> void:
	FarmRenderer.draw_side_scene(
		self,
		_farm_board_rect(),
		item_textures,
		pollinator_garden
	)


# ============================================================
# /*=== FUNCTION DRAW SIDE SCENE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CURRENT TOOL IS USABLE START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION CURRENT TOOL IS USABLE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAW FARMER START ===*/
# ============================================================

func _draw_farmer() -> void:
	FarmRenderer.draw_farmer(
		self,
		farmer_pos,
		farmer_step_bob,
		current_tool,
		tool_textures,
		_current_tool_is_usable()
	)


# ============================================================
# /*=== FUNCTION DRAW FARMER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MOVE FARMER START ===*/
# ============================================================

func _move_farmer(delta_cell: Vector2i) -> void:
	var next_cell: Vector2i = farmer_cell + delta_cell
	if not _is_cell_inside(next_cell):
		return
	farmer_cell = next_cell
	selected_cell = farmer_cell
	_mark_ui_dirty()




# ============================================================
# /*=== FUNCTION MOVE FARMER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION USE FARMER TOOL START ===*/
# ============================================================

func _use_farmer_tool() -> void:
	selected_cell = farmer_cell
	_handle_plot_click(farmer_cell)




# ============================================================
# /*=== FUNCTION USE FARMER TOOL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION INFO CELL START ===*/
# ============================================================

func _info_cell() -> Vector2i:
	if _is_cell_inside(selected_cell):
		return selected_cell
	return farmer_cell




# ============================================================
# /*=== FUNCTION INFO CELL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION INFO CELL LABEL START ===*/
# ============================================================

func _info_cell_label(cell: Vector2i) -> String:
	if cell == farmer_cell:
		return "Current plot"
	return "Hover plot"




# ============================================================
# /*=== FUNCTION INFO CELL LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CELL CENTER START ===*/
# ============================================================

func _cell_center(cell: Vector2i) -> Vector2:
	return farm_origin + Vector2(cell.x * tile_size + (tile_size - 8) * 0.5, cell.y * tile_size + (tile_size - 8) * 0.5)




# ============================================================
# /*=== FUNCTION CELL CENTER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HANDLE PLOT CLICK START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION HANDLE PLOT CLICK END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TAKE CUTTING FROM FARMER PLOT START ===*/
# ============================================================

func _take_cutting_from_farmer_plot() -> void:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	var result: Dictionary = CropSystem.take_cutting(plot, varieties)

	if not bool(result["ok"]):
		match String(result["reason"]):
			"empty":
				_say("Cuttings come from living fig wood. Plant a tree here first.")
			"young":
				_say("This fig is too young for cuttings. Let it establish or ripen first.")
			_:
				_say("This fig is not ready for cuttings yet.")
		return

	var variety_index: int = int(result["variety_index"])
	cuttings[variety_index] += 1
	_play_sfx("harvest")
	_say("Clipped one %s cutting. Fig cultivars are usually propagated by cuttings, which clone the parent tree." % _variety_name(variety_index))



# ============================================================
# /*=== FUNCTION TAKE CUTTING FROM FARMER PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CAN TAKE CUTTING START ===*/
# ============================================================

func _can_take_cutting(plot: Dictionary) -> bool:
	return CropSystem.can_take_cutting(plot, varieties)



# ============================================================
# /*=== FUNCTION CAN TAKE CUTTING END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLANT PLOT START ===*/
# ============================================================

func _plant_plot(plot: Dictionary) -> void:
	var result: Dictionary = CropSystem.plant_plot(plot, cuttings, selected_variety, _is_rainy())

	if not bool(result["ok"]):
		match String(result["reason"]):
			"occupied":
				_say("That plot already has a fig tree.")
			"no_cuttings":
				_say("No %s cuttings left. Buy more from the shop." % _variety_name(selected_variety))
			_:
				_say("That plot is not ready to plant.")
		return

	if selected_variety == 0:
		_advance_tutorial(0)
	_play_sfx("plant")
	_say("Planted %s. In real gardens figs often need 1-3 years to bear; this game compresses that into watered days." % _variety_name(selected_variety))



# ============================================================
# /*=== FUNCTION PLANT PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION WATER PLOT START ===*/
# ============================================================

func _water_plot(plot: Dictionary) -> void:
	var result: Dictionary = CropSystem.water_plot(plot, water, _pollinator_chance())

	if not bool(result["ok"]):
		match String(result["reason"]):
			"empty":
				_say("Water helps trees, but this soil is empty.")
			"already_watered":
				_say("This tree is already watered. Deep, steady watering matters most while young or fruiting.")
			"no_water":
				_say("The barrel is empty. A dry day slows growth, and heat can lower fig quality.")
			_:
				_say("This tree cannot be watered right now.")
		return

	water = int(result["water"])
	_advance_tutorial(1)
	_play_sfx("water")
	if bool(result["pollinator_visit"]):
		_say("A pollinator visit marked this tree for extra sweet figs.")
	else:
		_say("The tree drinks deeply. Watered days move it closer to fruit.")



# ============================================================
# /*=== FUNCTION WATER PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION COMPOST PLOT START ===*/
# ============================================================

func _compost_plot(plot: Dictionary) -> void:
	var result: Dictionary = CropSystem.compost_plot(plot, compost)

	if not bool(result["ok"]):
		match String(result["reason"]):
			"empty":
				_say("Compost works best around planted trees.")
			"already_composted":
				_say("This tree already has compost around its roots.")
			"no_compost":
				_say("No compost left. Buy a bag from the shop.")
			_:
				_say("This tree cannot use compost right now.")
		return

	compost = int(result["compost"])
	_play_sfx("compost")
	_say("Compost added. This tree should give better figs.")



# ============================================================
# /*=== FUNCTION COMPOST PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HARVEST PLOT START ===*/
# ============================================================

func _harvest_plot(plot: Dictionary) -> void:
	var result: Dictionary = CropSystem.harvest_plot(plot, varieties)

	if not bool(result["ok"]):
		match String(result["reason"]):
			"empty":
				_say("Nothing to harvest here yet.")
			"not_ripe":
				_say("These figs need more time. Figs sweeten on the tree and should be picked soft and ripe.")
			_:
				_say("These figs are not ready to harvest yet.")
		return

	var variety_index: int = int(result["variety_index"])
	var harvest: int = int(result["harvest"])
	var ripe_days: int = int(result["ripe_days"])
	fig_bins[variety_index] += harvest
	_advance_tutorial(3)
	_play_sfx("harvest")
	_say("Harvested %s %s figs. %s" % [harvest, _variety_name(variety_index), _ripeness_harvest_note(ripe_days)])



# ============================================================
# /*=== FUNCTION HARVEST PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION START NEXT DAY START ===*/
# ============================================================

func _start_next_day() -> void:
	day += 1
	time_left = DAY_LENGTH

	_play_sfx("day")
	_roll_weather()

	water = mini(_max_water(), water + 4 + barrel_level)

	var weather_name: String = _weather_name()
	var order_tick_count: int = accepted_orders.size()

	var crop_day_result: Dictionary = CropSystem.process_new_day_for_plots(
		plots,
		GRID_H,
		GRID_W,
		varieties,
		weather_name
	)

	var expired_orders: Array[String] = _order_day_passed()

	if _has_ripe_tree():
		_advance_tutorial(2)

	var extra_note: String = ""

	if randf() < 0.22:
		var free_index: int = randi_range(0, varieties.size() - 1)
		cuttings[free_index] += 1
		extra_note = "Neighbor shared %s." % _variety_name(free_index)

	var summary_text: String = _day_summary_text(
		int(crop_day_result["grew_count"]),
		int(crop_day_result["dried_count"]),
		int(crop_day_result["ripened_count"]),
		int(crop_day_result["softened_count"]),
		order_tick_count,
		expired_orders.size(),
		weather_name,
		extra_note
	)

	if FestivalSystem.should_resolve(day, FESTIVAL_LENGTH):
		_resolve_festival_week(weather_name, summary_text)
		return

	_say(summary_text)


# ============================================================
# /*=== FUNCTION START NEXT DAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE PLOT MOISTURE START ===*/
# ============================================================

func _update_plot_moisture(plot: Dictionary, weather_name: String) -> void:
	CropSystem.update_plot_moisture(plot, weather_name)




# ============================================================
# /*=== FUNCTION UPDATE PLOT MOISTURE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FULFILL ORDER START ===*/
# ============================================================

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
	var relationship_gain: int = RelationshipSystem.order_completion_gain(int(order_data["patience"]))
	relationships = RelationshipSystem.apply_change(relationships, customer, relationship_gain)
	var new_friendship: int = RelationshipSystem.score_for(relationships, customer)
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




# ============================================================
# /*=== FUNCTION FULFILL ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MAKE JAM START ===*/
# ============================================================

func _make_jam() -> void:
	var result: Dictionary = InventorySystem.make_jam(fig_bins, mason_jars, jam_jars)

	if not bool(result["ok"]):
		match String(result["reason"]):
			"not_enough_figs":
				_say("Jam needs 5 figs. Save mixed ripe figs, then preserve them.")
			"no_jars":
				_say("Jam needs an empty mason jar. Buy jars at the market first.")
			_:
				_say("Jam needs figs and a clean jar.")
		return

	mason_jars = int(result["mason_jars"])
	jam_jars = int(result["jam_jars"])
	_log_event("Made jam: 5 figs became 1 jar.")
	_play_sfx("order")
	_say("Made 1 jar of fig jam: ripe figs, sugar, lemon juice, then simmer until thick.")


# ============================================================
# /*=== FUNCTION MAKE JAM END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELL JAM START ===*/
# ============================================================

func _sell_jam() -> void:
	var result: Dictionary = InventorySystem.sell_jam(jam_jars)

	if not bool(result["ok"]):
		_say("No jam jars ready to sell.")
		return

	var sold_jars: int = int(result["sold_jars"])
	var payout: int = int(result["payout"])
	var festival_credit: int = int(result["festival_credit"])
	jam_jars = int(result["jam_jars"])
	coins += payout
	festival_progress += festival_credit
	_log_event("Sold jam: +$%s, weekly table +%s figs." % [payout, festival_credit])
	_play_sfx("sell")
	_say("Sold %s of fig jam for %s coins. Weekly table +%s figs." % [_jar_count_text(sold_jars), payout, festival_credit])


# ============================================================
# /*=== FUNCTION SELL JAM END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUY MASON JARS START ===*/
# ============================================================

func _buy_mason_jars() -> void:
	var result: Dictionary = InventorySystem.buy_mason_jars(coins, mason_jars)

	if not bool(result["ok"]):
		_say("Three clean mason jars cost %s coins." % EconomySystem.MASON_JARS_COST)
		return

	coins = int(result["coins"])
	mason_jars = int(result["mason_jars"])
	_play_sfx("sell")
	_say("Bought three mason jars for preserves.")


# ============================================================
# /*=== FUNCTION BUY MASON JARS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHOW RECIPE START ===*/
# ============================================================

func _show_recipe() -> void:
	recipe_expanded = true
	_show_dialogue("Fig Jam Recipe", _recipe_card_text())
	_update_ui()




# ============================================================
# /*=== FUNCTION SHOW RECIPE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELL CRATE START ===*/
# ============================================================

func _sell_crate() -> void:
	var result: Dictionary = InventorySystem.sell_crate(fig_bins, varieties)

	if not bool(result["ok"]):
		_say("No harvested figs to sell yet.")
		return

	var total: int = int(result["total"])
	var payout: int = int(result["payout"])
	coins += payout
	festival_progress += total
	_log_event("Sold crate: +$%s, weekly table +%s figs." % [payout, total])
	_play_sfx("sell")
	_say("Sold a mixed crate for %s coins. Weekly table +%s figs." % [payout, total])


# ============================================================
# /*=== FUNCTION SELL CRATE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MAKE ORDER OFFER START ===*/
# ============================================================

func _make_order_offer() -> Dictionary:
	return OrderSystem.make_order_offer(GameData.order_templates(), reputation, relationships)



# ============================================================
# /*=== FUNCTION MAKE ORDER OFFER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION REFRESH ORDER OFFERS START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION REFRESH ORDER OFFERS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION NEW ORDER START ===*/
# ============================================================

func _new_order() -> void:
	_refresh_order_offers()




# ============================================================
# /*=== FUNCTION NEW ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ORDER DAY PASSED START ===*/
# ============================================================

func _order_day_passed() -> Array[String]:
	var result: Dictionary = OrderSystem.process_order_day(accepted_orders, relationships, reputation)
	accepted_orders = result["accepted_orders"]
	reputation = int(result["reputation"])
	relationships = result["relationships"]
	var expired_names: Array[String] = []
	for expired_name in result["expired_names"]:
		expired_names.append(String(expired_name))

	_refresh_order_offers()
	if expired_names.size() > 0:
		_log_event("Expired accepted order: %s. Trust dipped." % ", ".join(expired_names))
	return expired_names



# ============================================================
# /*=== FUNCTION ORDER DAY PASSED END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUY CUTTINGS START ===*/
# ============================================================

func _buy_cuttings() -> void:
	var cost: int = EconomySystem.cutting_cost(varieties, selected_variety)
	var purchase: Dictionary = EconomySystem.purchase_result(coins, cost)
	if not bool(purchase["ok"]):
		_say("A %s starter tree costs %s coins." % [_variety_name(selected_variety), cost])
		return
	coins = int(purchase["coins"])
	cuttings[selected_variety] += 1
	_play_sfx("sell")
	_say("Bought one %s starter tree for planting." % _variety_name(selected_variety))




# ============================================================
# /*=== FUNCTION BUY CUTTINGS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUY COMPOST START ===*/
# ============================================================

func _buy_compost() -> void:
	var purchase: Dictionary = EconomySystem.purchase_result(coins, EconomySystem.COMPOST_BAG_COST, EconomySystem.COMPOST_BAG_QUANTITY)
	if not bool(purchase["ok"]):
		_say("A compost bag costs %s coins." % EconomySystem.COMPOST_BAG_COST)
		return
	coins = int(purchase["coins"])
	compost += int(purchase["quantity"])
	_play_sfx("sell")
	_say("Bought two compost bags.")




# ============================================================
# /*=== FUNCTION BUY COMPOST END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUY BARREL UPGRADE START ===*/
# ============================================================

func _buy_barrel_upgrade() -> void:
	var cost: int = EconomySystem.barrel_upgrade_cost(barrel_level)
	if not EconomySystem.can_upgrade_barrel(barrel_level):
		_say("The barrel is already as big as the stall can build.")
		return
	var purchase: Dictionary = EconomySystem.purchase_result(coins, cost)
	if not bool(purchase["ok"]):
		_say("The next barrel upgrade costs %s coins." % cost)
		return
	coins = int(purchase["coins"])
	barrel_level += 1
	water = _max_water()
	_play_sfx("sell")
	_say("Barrel upgraded. More water fits now.")




# ============================================================
# /*=== FUNCTION BUY BARREL UPGRADE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BUY POLLINATOR GARDEN START ===*/
# ============================================================

func _buy_pollinator_garden() -> void:
	if pollinator_garden:
		_say("The pollinator garden is already blooming.")
		return
	var cost: int = EconomySystem.pollinator_garden_cost()
	var purchase: Dictionary = EconomySystem.purchase_result(coins, cost)
	if not bool(purchase["ok"]):
		_say("The pollinator garden costs %s coins." % cost)
		return
	coins = int(purchase["coins"])
	pollinator_garden = true
	_play_sfx("sell")
	_say("Flowers planted by the fence. Sweet harvests are more likely.")




# ============================================================
# /*=== FUNCTION BUY POLLINATOR GARDEN END ===*/
# ============================================================

# ============================================================
# Saves the current farm to disk.
# ============================================================

# ============================================================
# /*=== FUNCTION SAVE GAME START ===*/
# ============================================================

func _save_game() -> void:
	var data: Dictionary = SaveSystem.build_save_data(_current_save_state())

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		_say("Could not save the farm right now.")
		return

	file.store_string(JSON.stringify(data))

	_play_sfx("save")
	_say("Farm saved. You can come back to this fig season later.")



# ============================================================
# /*=== FUNCTION SAVE GAME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION LOAD GAME START ===*/
# ============================================================

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

	var loaded: Dictionary = SaveSystem.read_save_data(
		data,
		_current_save_state(),
		varieties.size(),
		weather_table.size(),
		GRID_W,
		GRID_H,
		DAY_LENGTH,
		_festival_goal_for_week()
	)

	# ---------- Apply loaded state ----------
	day = loaded["day"]
	time_left = loaded["time_left"]
	coins = loaded["coins"]
	water = loaded["water"]
	compost = loaded["compost"]
	reputation = loaded["reputation"]

	sound_enabled = loaded["sound_enabled"]
	_sync_music()

	tutorial_index = loaded["tutorial_index"]
	festival_week = loaded["festival_week"]
	festival_goal = loaded["festival_goal"]
	festival_progress = loaded["festival_progress"]

	relationships = loaded["relationships"]

	cuttings = loaded["cuttings"]
	fig_bins = loaded["fig_bins"]
	jam_jars = loaded["jam_jars"]
	mason_jars = loaded["mason_jars"]

	recipe_expanded = loaded["recipe_expanded"]
	barrel_level = loaded["barrel_level"]
	pollinator_garden = loaded["pollinator_garden"]

	current_weather = loaded["current_weather"]
	temperature_f = loaded["temperature_f"]

	order_offers = loaded["order_offers"]
	accepted_orders = loaded["accepted_orders"]
	selected_order_index = loaded["selected_order_index"]

	game_log = loaded["game_log"]

	selected_variety = loaded["selected_variety"]
	current_tool = clampi(int(loaded["current_tool"]), Tool.PLANT, Tool.HARVEST)
	side_tab = loaded["side_tab"]
	panel_open = loaded["panel_open"]

	if not loaded["plots"].is_empty():
		plots = loaded["plots"]

	farmer_cell = loaded["farmer_cell"]
	selected_cell = farmer_cell
	farmer_pos = _cell_center(farmer_cell)

	# ---------- Post-load cleanup ----------
	if order_offers.is_empty() and accepted_orders.is_empty():
		_refresh_order_offers()

	_normalize_selected_order()
	_update_ui()

	_play_sfx("save")
	_say("Farm loaded. Back to the figs.")



# ============================================================
# /*=== FUNCTION LOAD GAME END ===*/
# ============================================================

# ============================================================
# Collects all current game state values that SaveSystem needs.
#
# Why this exists:
# _save_game() and _load_game() both need the same state snapshot.
# Keeping it here prevents huge duplicate Dictionaries everywhere.
# ============================================================

# ============================================================
# /*=== FUNCTION CURRENT SAVE STATE START ===*/
# ============================================================

func _current_save_state() -> Dictionary:
	return {
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

		"plots": plots,
		"farmer_cell": farmer_cell
	}




# ============================================================
# /*=== FUNCTION CURRENT SAVE STATE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DEFAULT PLOT START ===*/
# ============================================================

func _default_plot() -> Dictionary:
	return SaveSystem.default_plot()



# ============================================================
# /*=== FUNCTION DEFAULT PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION NORMALIZE PLOT START ===*/
# ============================================================

func _normalize_plot(source: Variant) -> Dictionary:
	return SaveSystem.normalize_plot(source, varieties.size())



# ============================================================
# /*=== FUNCTION NORMALIZE PLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION READ PLOTS ARRAY START ===*/
# ============================================================

func _read_plots_array(source: Variant) -> Array:
	return SaveSystem.read_plots_array(source, GRID_H, GRID_W, varieties.size())



# ============================================================
# /*=== FUNCTION READ PLOTS ARRAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION READ ORDER ARRAY START ===*/
# ============================================================

func _read_order_array(source: Variant) -> Array[Dictionary]:
	return SaveSystem.read_order_array(source)



# ============================================================
# /*=== FUNCTION READ ORDER ARRAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION READ STRING ARRAY START ===*/
# ============================================================

func _read_string_array(source: Variant, max_items: int) -> Array[String]:
	return SaveSystem.read_string_array(source, max_items)



# ============================================================
# /*=== FUNCTION READ STRING ARRAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION READ INT ARRAY START ===*/
# ============================================================

func _read_int_array(source: Variant, expected_size: int, fill_value: int) -> Array[int]:
	return SaveSystem.read_int_array(source, expected_size, fill_value)



# ============================================================
# /*=== FUNCTION READ INT ARRAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOGGLE SOUND START ===*/
# ============================================================

func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	_sync_music()
	if sound_enabled:
		_play_sfx("save")
		_say("Sound and music on.")
	else:
		_say("Sound and music muted.")
	_update_ui()




# ============================================================
# /*=== FUNCTION TOGGLE SOUND END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOGGLE PAUSE START ===*/
# ============================================================

func _toggle_pause() -> void:
	game_paused = not game_paused
	_play_sfx("pause")
	if game_paused:
		_say("Paused. Press P, Esc, or Resume to keep farming.")
	else:
		_say("Back to the figs.")
	_update_ui()




# ============================================================
# /*=== FUNCTION TOGGLE PAUSE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SET TOOL START ===*/
# ============================================================

func _set_tool(tool: int) -> void:
	current_tool = clampi(tool, Tool.PLANT, Tool.HARVEST)
	_update_ui()




# ============================================================
# /*=== FUNCTION SET TOOL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELECT VARIETY START ===*/
# ============================================================

func _select_variety(index: int) -> void:
	selected_variety = clampi(index, 0, varieties.size() - 1)
	_update_ui()




# ============================================================
# /*=== FUNCTION SELECT VARIETY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MARK UI DIRTY START ===*/
# ============================================================

func _mark_ui_dirty() -> void:
	ui_dirty = true




# ============================================================
# /*=== FUNCTION MARK UI DIRTY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE HUD LABELS START ===*/
# ============================================================

func _update_hud_labels() -> void:
	if hud_labels.is_empty():
		return
	hud_labels["Day"].text = HUDUI.format_day(day)
	hud_labels["Weather"].text = _weather_detail_text()
	hud_labels["Coins"].text = HUDUI.format_coins(coins)
	hud_labels["Water"].text = HUDUI.format_water(water, _max_water())
	hud_labels["Cuts"].text = HUDUI.format_cuttings(_total_cuttings())
	hud_labels["Figs"].text = HUDUI.format_figs(_total_figs())
	hud_labels["Compost"].text = HUDUI.format_compost(compost)
	hud_labels["Rep"].text = HUDUI.format_reputation(reputation)
	hud_labels["Guide"].text = HUDUI.format_guide(_tutorial_short_text())




# ============================================================
# /*=== FUNCTION UPDATE HUD LABELS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE TRANSIENT UI START ===*/
# ============================================================

func _update_transient_ui() -> void:
	if message_label != null:
		if message_timer > 0.0:
			message_label.text = message
		else:
			message_label.text = ""
	if dock_hint_label != null:
		dock_hint_label.visible = panel_open and not _is_page_chrome_open()
		if dock_hint_label.visible:
			dock_hint_label.text = "%s  • click icon again to close" % _drawer_header_text()




# ============================================================
# /*=== FUNCTION UPDATE TRANSIENT UI END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE UI START ===*/
# ============================================================

func _update_ui() -> void:
	_update_hud_labels()
	buy_cuttings_button.text = "🌱 %s tree        $%s" % [String(varieties[selected_variety]["short"]), EconomySystem.cutting_cost(varieties, selected_variety)]
	if EconomySystem.can_upgrade_barrel(barrel_level):
		barrel_button.text = "▣ Barrel +        $%s" % EconomySystem.barrel_upgrade_cost(barrel_level)
	else:
		barrel_button.text = "▣ Barrel max"
	if pollinator_garden:
		garden_button.text = "🌸 Flowers done"
	else:
		garden_button.text = "🌸 Flowers        $%s" % EconomySystem.pollinator_garden_cost()
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
	DrawerUI.apply_active_panel(_drawer_panels(), side_tab, panel_open)
	_apply_page_chrome_state()
	BottomNavigationUI.apply_active_state(
		bottom_nav_buttons,
		_bottom_nav_active_key()
	)
	for tab in tab_buttons.keys():
		tab_buttons[tab].button_pressed = panel_open and int(tab) == side_tab
	festival_label.text = _festival_text()
	_update_order_buttons()
	order_label.text = _order_text()

	# Village Requests action state:
	# Only show one primary action at a time, like a delivery/order app.
	# - New offer selected: ACCEPT ORDER
	# - Accepted order selected: FULFILL ORDER
	# - Nothing actionable: hide/disable both
	var can_accept_order: bool = _can_accept_selected_order()
	var can_fulfill_order: bool = _can_fulfill_selected_order()
	accept_order_button.visible = can_accept_order
	fulfill_order_button.visible = can_fulfill_order
	accept_order_button.disabled = not can_accept_order
	fulfill_order_button.disabled = not can_fulfill_order

	inventory_label.text = "Accepted requests: %s/5" % accepted_orders.size()
	for variety_index in mini(
		pantry_harvest_amount_labels.size(),
		fig_bins.size()
	):
		pantry_harvest_amount_labels[variety_index].text = str(
			fig_bins[variety_index]
		)

	for variety_index in mini(
		pantry_cutting_amount_labels.size(),
		cuttings.size()
	):
		pantry_cutting_amount_labels[variety_index].text = str(
			cuttings[variety_index]
		)

	pantry_total_figs_label.text = "Total figs: %s" % _total_figs()
	pantry_total_cuttings_label.text = "Total cuttings: %s" % _total_cuttings()
	pantry_jars_count_label.text = str(mason_jars)
	pantry_jam_count_label.text = str(jam_jars)
	# ============================================================
	# /*=== PANTRY TREE STATUS UPDATE START ===*/
	# ------------------------------------------------------------
	# The total cutting count already appears above. Keep this row
	# focused on planted trees and cutting-ready status.
	# ============================================================

	var pantry_tree_lines: PackedStringArray = _pantry_trees_text().split("\n")
	var pantry_tree_status: String = "🌳 Trees 0 • Ready: none"

	if not pantry_tree_lines.is_empty():
		pantry_tree_status = String(pantry_tree_lines[0])
		pantry_tree_status = pantry_tree_status.replace(
			" | cutting-ready ",
			" • Ready: "
		)

	pantry_trees_label.text = pantry_tree_status

	# ============================================================
	# /*=== PANTRY TREE STATUS UPDATE END ===*/
	# ============================================================
	relationship_label.text = _relationship_summary()
	preserve_label.text = PantryUI.preserve_recipe_text()
	logbook_label.text = _logbook_text()
	buy_jars_button.disabled = not EconomySystem.can_afford(coins, EconomySystem.MASON_JARS_COST)
	make_jam_button.disabled = _total_figs() < 5 or mason_jars <= 0
	notebook_label.text = GuideUI.notebook_text(varieties[selected_variety])
	plot_status_label.text = _plot_status_text()
	guide_legend_label.text = GuideUI.legend_text(_season_name(), temperature_f, _season_growing_note(), recipe_expanded)
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




# ============================================================
# /*=== FUNCTION UPDATE UI END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION LOG EVENT START ===*/
# ============================================================

func _log_event(entry: String) -> void:
	var stamped_entry: String = "D%s  %s" % [day, entry]
	if game_log.size() > 0 and game_log[0] == stamped_entry:
		return
	game_log.insert(0, stamped_entry)
	while game_log.size() > 8:
		game_log.pop_back()




# ============================================================
# /*=== FUNCTION LOG EVENT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION LOGBOOK TEXT START ===*/
# ============================================================

func _logbook_text() -> String:
	return TextLibrary.logbook_text(game_log)



# ============================================================
# /*=== FUNCTION LOGBOOK TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TUTORIAL TEXT START ===*/
# ============================================================

func _tutorial_text() -> String:
	return TextLibrary.tutorial_text(tutorial_index)



# ============================================================
# /*=== FUNCTION TUTORIAL TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TUTORIAL SHORT TEXT START ===*/
# ============================================================

func _tutorial_short_text() -> String:
	return TextLibrary.tutorial_short_text(tutorial_index)



# ============================================================
# /*=== FUNCTION TUTORIAL SHORT TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ADVANCE TUTORIAL START ===*/
# ============================================================

func _advance_tutorial(step: int) -> void:
	if tutorial_index != step:
		return
	tutorial_index += 1
	if tutorial_index == 5:
		coins += 12
		compost += 1
		_say("Tutorial complete. Bonus: 12 coins and compost for the next planting.")




# ============================================================
# /*=== FUNCTION ADVANCE TUTORIAL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION HAS RIPE TREE START ===*/
# ============================================================

func _has_ripe_tree() -> bool:
	return CropSystem.has_ripe_tree(plots, GRID_H, GRID_W)



# ============================================================
# /*=== FUNCTION HAS RIPE TREE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION RIPENESS LABEL START ===*/
# ============================================================

func _ripeness_label(ripe_days: int) -> String:
	return TextLibrary.ripeness_label(ripe_days)



# ============================================================
# /*=== FUNCTION RIPENESS LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION RIPENESS HARVEST NOTE START ===*/
# ============================================================

func _ripeness_harvest_note(ripe_days: int) -> String:
	return TextLibrary.ripeness_harvest_note(ripe_days)



# ============================================================
# /*=== FUNCTION RIPENESS HARVEST NOTE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FARM HINT TEXT START ===*/
# ============================================================

func _farm_hint_text() -> String:
	var hint: String = "%s: %s" % [_tool_name(current_tool), _tool_block_reason()]
	if _current_tool_is_usable():
		hint = "%s ready. Click a plot to use." % _tool_name(current_tool)
	return hint




# ============================================================
# /*=== FUNCTION FARM HINT TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DAY SUMMARY TEXT START ===*/
# ============================================================

func _day_summary_text(grew_count: int, dried_count: int, ripened_count: int, softened_count: int, order_tick_count: int, expired_order_count: int, weather_name: String, extra_note: String) -> String:
	return TextLibrary.day_summary_text(day, _weather_icon(), grew_count, dried_count, ripened_count, softened_count, order_tick_count, expired_order_count, weather_name, extra_note)



# ============================================================
# /*=== FUNCTION DAY SUMMARY TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PROGRESS BAR START ===*/
# ============================================================

func _progress_bar(current: int, maximum: int, width: int = 5) -> String:
	return TextLibrary.progress_bar(current, maximum, width)



# ============================================================
# /*=== FUNCTION PROGRESS BAR END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MOISTURE ICON START ===*/
# ============================================================

func _moisture_icon(moisture: int) -> String:
	return TextLibrary.moisture_icon(moisture)



# ============================================================
# /*=== FUNCTION MOISTURE ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION BOTTOM ACTION TEXT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION BOTTOM ACTION TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT CARD SUMMARY TEXT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PLOT CARD SUMMARY TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL ICON START ===*/
# ============================================================

func _tool_icon(tool: int) -> String:
	return TextLibrary.tool_icon(tool)



# ============================================================
# /*=== FUNCTION TOOL ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL SHORTCUT START ===*/
# ============================================================

func _tool_shortcut(tool: int) -> String:
	return TextLibrary.tool_shortcut(tool)



# ============================================================
# /*=== FUNCTION TOOL SHORTCUT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DRAWER HEADER TEXT START ===*/
# ============================================================

func _drawer_header_text() -> String:
	return TextLibrary.drawer_header_text(side_tab)



# ============================================================
# /*=== FUNCTION DRAWER HEADER TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL NAME START ===*/
# ============================================================

func _tool_name(tool: int) -> String:
	return TextLibrary.tool_name(tool)




# ============================================================
# /*=== FUNCTION TOOL NAME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PANTRY PRESERVES TEXT START ===*/
# ============================================================

func _pantry_preserves_text() -> String:
	return InventorySystem.pantry_preserves_text(_total_figs(), mason_jars, jam_jars)



# ============================================================
# /*=== FUNCTION PANTRY PRESERVES TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PANTRY TREES TEXT START ===*/
# ============================================================

func _pantry_trees_text() -> String:
	return InventorySystem.pantry_trees_text(varieties, plots, cuttings, GRID_H, GRID_W)



# ============================================================
# /*=== FUNCTION PANTRY TREES TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PANTRY HINT TEXT START ===*/
# ============================================================

func _pantry_hint_text() -> String:
	return InventorySystem.pantry_hint_text()



# ============================================================
# /*=== FUNCTION PANTRY HINT TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MOISTURE LABEL START ===*/
# ============================================================

func _moisture_label(moisture: int) -> String:
	return TextLibrary.moisture_label(moisture)



# ============================================================
# /*=== FUNCTION MOISTURE LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHOW DIALOGUE START ===*/
# ============================================================

func _show_dialogue(title: String, body: String) -> void:
	dialogue_title = title
	dialogue_body = body
	dialogue_visible = true
	panel_open = false
	_play_sfx("save")




# ============================================================
# /*=== FUNCTION SHOW DIALOGUE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CLOSE DIALOGUE START ===*/
# ============================================================

func _close_dialogue() -> void:
	dialogue_visible = false
	_update_ui()




# ============================================================
# /*=== FUNCTION CLOSE DIALOGUE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT DIALOGUE TITLE START ===*/
# ============================================================

func _plot_dialogue_title() -> String:
	var plot: Dictionary = plots[farmer_cell.y][farmer_cell.x]
	if not bool(plot["planted"]):
		return "Farmer's Note"
	var variety_index: int = int(plot["variety"])
	return "%s Tree" % String(varieties[variety_index]["short"])




# ============================================================
# /*=== FUNCTION PLOT DIALOGUE TITLE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION RECIPE CARD TEXT START ===*/
# ============================================================

func _recipe_card_text() -> String:
	return TextLibrary.recipe_card_text()



# ============================================================
# /*=== FUNCTION RECIPE CARD TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHOW PLOT INFO START ===*/
# ============================================================

func _show_plot_info() -> void:
	_show_dialogue(_plot_dialogue_title(), _plot_info_text())
	_update_ui()




# ============================================================
# /*=== FUNCTION SHOW PLOT INFO END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT INFO TEXT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PLOT INFO TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION DAY COUNT TEXT START ===*/
# ============================================================

func _day_count_text(count: int) -> String:
	return TextLibrary.day_count_text(count)



# ============================================================
# /*=== FUNCTION DAY COUNT TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION JAR COUNT TEXT START ===*/
# ============================================================

func _jar_count_text(count: int) -> String:
	return InventorySystem.jar_count_text(count)



# ============================================================
# /*=== FUNCTION JAR COUNT TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT STATUS TEXT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PLOT STATUS TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION GROWTH STAGE LABEL START ===*/
# ============================================================

func _growth_stage_label(stage: int) -> String:
	return TextLibrary.growth_stage_label(stage)



# ============================================================
# /*=== FUNCTION GROWTH STAGE LABEL END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CUTTING STATUS TEXT START ===*/
# ============================================================

func _cutting_status_text(plot: Dictionary) -> String:
	return CropSystem.cutting_status_text(plot, varieties)



# ============================================================
# /*=== FUNCTION CUTTING STATUS TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION PLOT NEXT STEP TEXT START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION PLOT NEXT STEP TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION RESOLVE FESTIVAL WEEK START ===*/
# ============================================================

func _resolve_festival_week(_weather_name: String, day_summary: String = "") -> void:
	var result: Dictionary = FestivalSystem.resolve_week({
		"festival_week": festival_week,
		"festival_goal": festival_goal,
		"festival_progress": festival_progress,
		"reputation": reputation
	})

	coins += int(result["coins_delta"])
	reputation += int(result["reputation_delta"])
	compost += int(result["compost_delta"])
	_log_event(String(result["log_text"]))
	var resolved_message: String = "%s %s" % [String(result["message_text"]), day_summary]
	_say(resolved_message.strip_edges())

	festival_week = int(result["next_week"])
	festival_goal = int(result["next_goal"])
	festival_progress = int(result["next_progress"])




# ============================================================
# /*=== FUNCTION RESOLVE FESTIVAL WEEK END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FESTIVAL GOAL FOR WEEK START ===*/
# ============================================================

func _festival_goal_for_week() -> int:
	return FestivalSystem.goal_for_week(festival_week, reputation)



# ============================================================
# /*=== FUNCTION FESTIVAL GOAL FOR WEEK END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FESTIVAL TEXT START ===*/
# ============================================================

func _festival_text() -> String:
	return FestivalSystem.festival_text(festival_week, festival_progress, festival_goal, _festival_days_left())



# ============================================================
# /*=== FUNCTION FESTIVAL TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION FESTIVAL DAYS LEFT START ===*/
# ============================================================

func _festival_days_left() -> int:
	return FestivalSystem.days_left(day, FESTIVAL_LENGTH)




# ============================================================
# /*=== FUNCTION FESTIVAL DAYS LEFT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION RELATIONSHIP SUMMARY START ===*/
# ============================================================

func _relationship_summary() -> String:
	return RelationshipSystem.relationship_summary(relationships)



# ============================================================
# /*=== FUNCTION RELATIONSHIP SUMMARY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION GRANT RELATIONSHIP MILESTONE START ===*/
# ============================================================

func _grant_relationship_milestone(customer: String, score: int) -> String:
	var result: Dictionary = RelationshipSystem.milestone_result(customer, score)
	coins += int(result["coins_delta"])
	compost += int(result["compost_delta"])
	if bool(result["water_to_max"]):
		water = _max_water()
	var cutting_delta: Array = result["cuttings_delta"] as Array
	for i in mini(cuttings.size(), cutting_delta.size()):
		cuttings[i] += int(cutting_delta[i])
	festival_progress += int(result["festival_progress_delta"])
	return String(result["message"])




# ============================================================
# /*=== FUNCTION GRANT RELATIONSHIP MILESTONE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SHORT CUSTOMER NAME START ===*/
# ============================================================

func _short_customer_name(customer: String) -> String:
	return RelationshipSystem.short_customer_name(customer)


# ============================================================
# /*=== FUNCTION SHORT CUSTOMER NAME END ===*/
# ============================================================

# ============================================================
# VILLAGE REQUESTS TEXT FORMATTERS
# ------------------------------------------------------------
# These format the text that appears inside the orderbook Controls.
# Keep layout-heavy spacing here, not in OrderSystem, so the gameplay
# order logic can stay separate from UI presentation.
# ============================================================


# ============================================================
# /*=== FUNCTION ORDER VARIETY SHORT START ===*/
# ============================================================

func _order_variety_short(variety_index: int) -> String:
	if variety_index < 0 or variety_index >= varieties.size():
		return "Mixed"
	return String(varieties[variety_index].get("short", "Mixed"))




# ============================================================
# /*=== FUNCTION ORDER VARIETY SHORT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ORDER TEXT START ===*/
# ============================================================

func _order_text() -> String:
	return VillageRequestsUI.current_request_text(
		selected_order_index,
		accepted_orders,
		order_offers,
		varieties
	)



# ============================================================
# /*=== FUNCTION ORDER TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ORDER BUTTON TEXT START ===*/
# ============================================================

func _order_button_text(index: int) -> String:
	return VillageRequestsUI.request_card_text(
		index,
		accepted_orders,
		order_offers,
		varieties
	)



# ============================================================
# /*=== FUNCTION ORDER BUTTON TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION UPDATE ORDER BUTTONS START ===*/
# ============================================================

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

	_update_order_pager()



# ============================================================
# /*=== FUNCTION UPDATE ORDER BUTTONS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELECT ORDER SLOT START ===*/
# ============================================================

func _select_order_slot(slot: int) -> void:
	selected_order_index = clampi(
		slot,
		0,
		maxi(0, _order_count() - 1)
	)

	order_page = selected_order_index
	_update_ui()



# ============================================================
# /*=== FUNCTION SELECT ORDER SLOT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELECTED ORDER START ===*/
# ============================================================

func _selected_order() -> Dictionary:
	return OrderSystem.order_at(selected_order_index, accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION SELECTED ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ORDER AT START ===*/
# ============================================================

func _order_at(index: int) -> Dictionary:
	return OrderSystem.order_at(index, accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION ORDER AT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ORDER COUNT START ===*/
# ============================================================

func _order_count() -> int:
	return OrderSystem.order_count(accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION ORDER COUNT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SELECTED ORDER IS ACCEPTED START ===*/
# ============================================================

func _selected_order_is_accepted() -> bool:
	return OrderSystem.selected_order_is_accepted(selected_order_index, accepted_orders)



# ============================================================
# /*=== FUNCTION SELECTED ORDER IS ACCEPTED END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CAN ACCEPT SELECTED ORDER START ===*/
# ============================================================

func _can_accept_selected_order() -> bool:
	return OrderSystem.can_accept_selected_order(selected_order_index, accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION CAN ACCEPT SELECTED ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CAN FULFILL SELECTED ORDER START ===*/
# ============================================================

func _can_fulfill_selected_order() -> bool:
	return OrderSystem.can_fulfill_selected_order(selected_order_index, accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION CAN FULFILL SELECTED ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ACCEPT SELECTED ORDER START ===*/
# ============================================================

func _accept_selected_order() -> void:
	var result: Dictionary = OrderSystem.accept_selected_order(selected_order_index, accepted_orders, order_offers)

	if not bool(result["ok"]):
		match String(result["reason"]):
			"not_available":
				_say("Pick an open offer to accept. Browsing alone has no Trust penalty.")
			"already_accepted":
				_say("That order is already accepted.")
			_:
				_say("That order cannot be accepted right now.")
		return

	var selected: Dictionary = result["selected"]
	selected_order_index = int(result["selected_order_index"])
	_log_event("Accepted order: %s needs %s figs." % [_short_customer_name(String(selected["customer"])), int(selected["need"])])
	_play_sfx("order")
	_say("Accepted %s's order. Finish it before the timer runs out to gain Trust." % _short_customer_name(String(selected["customer"])))
	_update_ui()



# ============================================================
# /*=== FUNCTION ACCEPT SELECTED ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION NORMALIZE SELECTED ORDER START ===*/
# ============================================================

func _normalize_selected_order() -> void:
	selected_order_index = OrderSystem.normalize_selected_order(selected_order_index, accepted_orders, order_offers)



# ============================================================
# /*=== FUNCTION NORMALIZE SELECTED ORDER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOOL BLOCK REASON START ===*/
# ============================================================

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




# ============================================================
# /*=== FUNCTION TOOL BLOCK REASON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION ROLL WEATHER START ===*/
# ============================================================

func _roll_weather() -> void:
	var result: Dictionary = WeatherSystem.roll_weather(day)
	current_weather = int(result["weather_index"])
	temperature_f = int(result["temperature_f"])



# ============================================================
# /*=== FUNCTION ROLL WEATHER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION WEATHER NAME START ===*/
# ============================================================

func _weather_name() -> String:
	return WeatherSystem.weather_name(weather_table, current_weather)



# ============================================================
# /*=== FUNCTION WEATHER NAME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION WEATHER DETAIL TEXT START ===*/
# ============================================================

func _weather_detail_text() -> String:
	return WeatherSystem.weather_detail_text(weather_table, current_weather, day, temperature_f)



# ============================================================
# /*=== FUNCTION WEATHER DETAIL TEXT END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION WEATHER ICON START ===*/
# ============================================================

func _weather_icon() -> String:
	return WeatherSystem.weather_icon(weather_table, current_weather)



# ============================================================
# /*=== FUNCTION WEATHER ICON END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SEASON NAME START ===*/
# ============================================================

func _season_name() -> String:
	return WeatherSystem.season_name(day)



# ============================================================
# /*=== FUNCTION SEASON NAME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SEASON GROWING NOTE START ===*/
# ============================================================

func _season_growing_note() -> String:
	return WeatherSystem.season_growing_note(day)



# ============================================================
# /*=== FUNCTION SEASON GROWING NOTE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION IS RAINY START ===*/
# ============================================================

func _is_rainy() -> bool:
	return WeatherSystem.is_rainy(_weather_name())



# ============================================================
# /*=== FUNCTION IS RAINY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION POLLINATOR CHANCE START ===*/
# ============================================================

func _pollinator_chance() -> float:
	return WeatherSystem.pollinator_chance(pollinator_garden, _weather_name())



# ============================================================
# /*=== FUNCTION POLLINATOR CHANCE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION MAX WATER START ===*/
# ============================================================

func _max_water() -> int:
	return EconomySystem.max_water(BASE_MAX_WATER, barrel_level)



# ============================================================
# /*=== FUNCTION MAX WATER END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOTAL CUTTINGS START ===*/
# ============================================================

func _total_cuttings() -> int:
	return InventorySystem.total_items(cuttings)



# ============================================================
# /*=== FUNCTION TOTAL CUTTINGS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TOTAL FIGS START ===*/
# ============================================================

func _total_figs() -> int:
	return InventorySystem.total_items(fig_bins)



# ============================================================
# /*=== FUNCTION TOTAL FIGS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION TAKE ANY FIGS START ===*/
# ============================================================

func _take_any_figs(amount: int) -> void:
	InventorySystem.take_any(fig_bins, amount)



# ============================================================
# /*=== FUNCTION TAKE ANY FIGS END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION VARIETY NAME START ===*/
# ============================================================

func _variety_name(index: int) -> String:
	return String(varieties[index]["name"])




# ============================================================
# /*=== FUNCTION VARIETY NAME END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION SAY START ===*/
# ============================================================

func _say(text: String) -> void:
	message = text
	message_timer = 5.0
	_mark_ui_dirty()




# ============================================================
# /*=== FUNCTION SAY END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION CELL FROM MOUSE START ===*/
# ============================================================

func _cell_from_mouse(mouse_pos: Vector2) -> Vector2i:
	var local: Vector2 = mouse_pos - farm_origin
	return Vector2i(floori(local.x / tile_size), floori(local.y / tile_size))




# ============================================================
# /*=== FUNCTION CELL FROM MOUSE END ===*/
# ============================================================

# ============================================================
# /*=== FUNCTION IS CELL INSIDE START ===*/
# ============================================================

func _is_cell_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_W and cell.y < GRID_H


# ============================================================
# /*=== FUNCTION IS CELL INSIDE END ===*/
# ============================================================

# /*=== MAIN.GD FILE END ===*/
# ============================================================
# /*=== MAIN SCRIPT FILE END ===*/
# ============================================================
