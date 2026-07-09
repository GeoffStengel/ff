extends RefCounted

static func is_mobile_layout(viewport_size: Vector2) -> bool:
	return viewport_size.x < 900.0


static func hud_rect(screen_pad: int, hud_h: int, viewport_size: Vector2) -> Rect2:
	return Rect2(Vector2(screen_pad, 14), Vector2(maxf(1.0, viewport_size.x - float(screen_pad * 2)), hud_h - 8))


static func hud_row_one_pos(hud: Rect2) -> Vector2:
	return hud.position + Vector2(10, 5)


static func hud_row_two_pos(hud: Rect2) -> Vector2:
	return hud.position + Vector2(10, 29)


static func left_dock_rect(screen_pad: int, hud_h: int, left_dock_w: int, bottom_bar_h: int, gap: int, viewport_size: Vector2, mobile: bool) -> Rect2:
	if mobile:
		return Rect2(Vector2(screen_pad, hud_h + gap), Vector2(left_dock_w, maxf(240.0, viewport_size.y - float(hud_h + bottom_bar_h + screen_pad + gap * 2))))
	return Rect2(Vector2(screen_pad, hud_h + gap), Vector2(left_dock_w, 548))


static func tool_pocket_rect(dock: Rect2) -> Rect2:
	return Rect2(dock.position + Vector2(10, 18), Vector2(dock.size.x - 20, 224))


static func menu_pocket_rect(dock: Rect2) -> Rect2:
	return Rect2(dock.position + Vector2(10, 262), Vector2(dock.size.x - 20, dock.size.y - 274))


static func tool_column_pos(tool_pocket: Rect2) -> Vector2:
	return tool_pocket.position + Vector2(15, 20)


static func menu_column_pos(menu_pocket: Rect2) -> Vector2:
	return menu_pocket.position + Vector2(15, 20)


static func drawer_rect(screen_pad: int, hud_h: int, drawer_w: int, bottom_bar_h: int, gap: int, viewport_size: Vector2, mobile: bool) -> Rect2:
	if mobile:
		return Rect2(Vector2(screen_pad, hud_h + gap), Vector2(maxf(1.0, viewport_size.x - float(screen_pad * 2)), viewport_size.y - float(hud_h + bottom_bar_h + screen_pad + gap * 2)))
	return Rect2(Vector2(viewport_size.x - float(screen_pad + drawer_w), hud_h + gap), Vector2(drawer_w, viewport_size.y - float(hud_h + screen_pad + gap)))


static func drawer_content_pos(drawer: Rect2) -> Vector2:
	return drawer.position + Vector2(14, 42)


static func drawer_content_size(drawer: Rect2) -> Vector2:
	return drawer.size - Vector2(28, 56)


static func drawer_hint_pos(drawer: Rect2) -> Vector2:
	return drawer.position + Vector2(20, 18)


static func drawer_hint_size(drawer: Rect2) -> Vector2:
	return Vector2(maxf(1.0, drawer.size.x - 40.0), 18)


static func farm_board_size(grid_w: int, grid_h: int, tile_size: int) -> Vector2:
	return Vector2(float(grid_w * tile_size + 52), float(grid_h * tile_size + 48))


static func farm_board_rect(farm_board_position: Vector2, board_size: Vector2) -> Rect2:
	return Rect2(farm_board_position, board_size)


static func plot_bed_rect(farm_origin: Vector2, grid_w: int, grid_h: int, tile_size: int) -> Rect2:
	return Rect2(farm_origin - Vector2(10, 10), Vector2(grid_w * tile_size - 8 + 20, grid_h * tile_size - 8 + 20))


static func bottom_status_rect(screen_pad: int, bottom_bar_h: int, gap: int, viewport_size: Vector2, board: Rect2, mobile: bool) -> Rect2:
	if mobile:
		return Rect2(Vector2(screen_pad, viewport_size.y - float(bottom_bar_h + screen_pad)), Vector2(maxf(1.0, viewport_size.x - float(screen_pad * 2)), bottom_bar_h))
	return Rect2(Vector2(board.position.x + 10, board.end.y + gap), Vector2(board.size.x - 20, bottom_bar_h))


static func bottom_card_rect(index: int, gap: int, bottom: Rect2) -> Rect2:
	var card_gap: float = float(gap)
	var card_w: float = (bottom.size.x - card_gap - 20.0) * 0.5
	return Rect2(bottom.position + Vector2(10.0 + float(index) * (card_w + card_gap), 10), Vector2(card_w, bottom.size.y - 20))


static func bottom_action_label_pos(card: Rect2) -> Vector2:
	return card.position + Vector2(8, 8)


static func plot_card_label_pos(card: Rect2) -> Vector2:
	return card.position + Vector2(8, 8)


static func bottom_card_label_size(card: Rect2) -> Vector2:
	return card.size - Vector2(16, 14)


static func message_label_pos(bottom: Rect2) -> Vector2:
	return Vector2(bottom.position.x + 16, bottom.position.y - 40)


static func message_label_size(bottom: Rect2) -> Vector2:
	return Vector2(maxf(1.0, bottom.size.x - 32.0), 28)


static func hud_label_width(key: String) -> int:
	match key:
		"Day":
			return 76
		"Weather":
			return 700
		"Coins":
			return 72
		"Water":
			return 78
		"Cuts":
			return 78
		"Figs":
			return 72
		"Compost":
			return 94
		"Rep":
			return 82
		"Guide":
			return 100
	return 70
