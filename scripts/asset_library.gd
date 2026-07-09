extends RefCounted

static func load_art_assets(crop_textures: Dictionary, item_textures: Dictionary, ui_textures: Dictionary, tool_textures: Dictionary) -> void:
	crop_textures["cutting"] = _load_texture("res://assets/sprites/crops/cutting_64x64.png")
	crop_textures["sprout"] = _load_texture("res://assets/sprites/crops/sprout_64x64.png")
	crop_textures["young"] = _load_texture("res://assets/sprites/crops/young_64x64.png")
	crop_textures["growing"] = _load_texture("res://assets/sprites/crops/growing_64x64.png")
	crop_textures["ripe_green"] = _load_texture("res://assets/sprites/crops/ripe_green_fig_tree_64x64.png")
	crop_textures["ripe_purple"] = _load_texture("res://assets/sprites/crops/ripe_purple_fig_tree_64x64.png")
	crop_textures["harvested"] = _load_texture("res://assets/sprites/crops/harvested_tree_64x64.png")
	item_textures["barrel"] = _load_texture("res://assets/sprites/items/barrel.png")
	item_textures["crate"] = _load_texture("res://assets/ui/icons/orders_icon.png")
	item_textures["flower"] = _load_texture("res://assets/sprites/items/flower.png")
	item_textures["fig"] = _load_texture("res://assets/sprites/items/fig.png")
	item_textures["jam"] = _load_texture("res://assets/sprites/items/jam.png")
	item_textures["fertilizer"] = _load_texture("res://assets/sprites/items/fertilizer.png")
	item_textures["seeds"] = _load_texture("res://assets/sprites/items/seeds.png")
	tool_textures["plant"] = _load_texture("res://assets/ui/icons/plant_icon_48x48.png")
	tool_textures["water"] = _load_texture("res://assets/ui/icons/water_icon_48x48.png")
	tool_textures["compost"] = _load_texture("res://assets/ui/icons/comp_icon_48x48.png")
	tool_textures["harvest"] = _load_texture("res://assets/ui/icons/harvest_icon.png")
	ui_textures["farm"] = _load_texture("res://assets/ui/buttons/cuttings_icon.png")
	ui_textures["orders"] = _load_texture("res://assets/ui/buttons/orders_icon.png")
	ui_textures["pantry"] = _load_texture("res://assets/ui/buttons/pantry_icon.png")
	ui_textures["guide"] = _load_texture("res://assets/ui/buttons/guide_icon.png")
	ui_textures["help"] = _load_texture("res://assets/ui/buttons/help_icon.png")
	ui_textures["save"] = _load_texture("res://assets/ui/buttons/save_icon.png")
	ui_textures["load"] = _load_texture("res://assets/ui/buttons/load_icon.png")
	ui_textures["pause"] = _load_texture("res://assets/ui/buttons/pause_icon.png")
	ui_textures["sound"] = _load_texture("res://assets/ui/buttons/sound_icon.png")
	ui_textures["fig"] = _load_texture("res://assets/ui/buttons/fig_icon.png")



static func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var texture: Texture2D = load(path) as Texture2D
	return texture

