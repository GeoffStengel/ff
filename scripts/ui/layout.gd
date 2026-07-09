extends RefCounted

# ============================================================
# UILayout
# ------------------------------------------------------------
# Shared geometry helpers for Fig Farmer UI.
#
# Purpose:
# Make UI positioning feel more like CSS layout helpers.
#
# Does NOT:
# - Draw anything
# - Know gameplay
# - Change state
# ============================================================

const UIConstants := preload("res://scripts/ui/ui_constants.gd")


# ============================================================
# /*=== BASIC RECT HELPERS START ===*/
# ============================================================

static func inset(rect: Rect2, padding: float) -> Rect2:
	return Rect2(
		rect.position + Vector2(padding, padding),
		rect.size - Vector2(padding * 2.0, padding * 2.0)
	)


static func below(rect: Rect2, height: float, gap: float = UIConstants.SECTION_GAP) -> Rect2:
	return Rect2(
		Vector2(rect.position.x, rect.end.y + gap),
		Vector2(rect.size.x, height)
	)


static func with_height(rect: Rect2, height: float) -> Rect2:
	return Rect2(rect.position, Vector2(rect.size.x, height))


static func with_width(rect: Rect2, width: float) -> Rect2:
	return Rect2(rect.position, Vector2(width, rect.size.y))

# ============================================================
# /*=== BASIC RECT HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== STACK HELPERS START ===*/
# ============================================================

static func vertical_stack(
	origin: Vector2,
	width: float,
	heights: Array[float],
	gap: float = UIConstants.SECTION_GAP
) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var y: float = origin.y

	for height in heights:
		var rect: Rect2 = Rect2(origin.x, y, width, height)
		rects.append(rect)
		y += height + gap

	return rects

# ============================================================
# /*=== STACK HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== BUTTON HELPERS START ===*/
# ============================================================

static func button_rect(container: Rect2) -> Rect2:
	return Rect2(
		container.position,
		Vector2(container.size.x, UIConstants.BUTTON_HEIGHT)
	)


static func bottom_button(container: Rect2) -> Rect2:
	return Rect2(
		Vector2(container.position.x, container.end.y - UIConstants.BUTTON_HEIGHT),
		Vector2(container.size.x, UIConstants.BUTTON_HEIGHT)
	)

# ============================================================
# /*=== BUTTON HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== TEXT POSITION HELPERS START ===*/
# ============================================================

static func padded_text_pos(rect: Rect2, x_pad: float = UIConstants.CARD_PADDING, y_pad: float = 22.0) -> Vector2:
	return rect.position + Vector2(x_pad, y_pad)


static func row_pos(rect: Rect2, row: int, x_pad: float = UIConstants.CARD_PADDING, row_h: float = 18.0) -> Vector2:
	return rect.position + Vector2(x_pad, 22.0 + float(row) * row_h)

# ============================================================
# /*=== TEXT POSITION HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== SPLIT HELPERS START ===*/
# ============================================================

static func split_vertical(rect: Rect2, top_height: float, gap: float = UIConstants.SECTION_GAP) -> Dictionary:
	var top: Rect2 = Rect2(rect.position, Vector2(rect.size.x, top_height))

	var bottom: Rect2 = Rect2(
		Vector2(rect.position.x, top.end.y + gap),
		Vector2(rect.size.x, rect.size.y - top_height - gap)
	)

	return {
		"top": top,
		"bottom": bottom
	}


static func split_horizontal(rect: Rect2, left_width: float, gap: float = UIConstants.SECTION_GAP) -> Dictionary:
	var left: Rect2 = Rect2(rect.position, Vector2(left_width, rect.size.y))

	var right: Rect2 = Rect2(
		Vector2(left.end.x + gap, rect.position.y),
		Vector2(rect.size.x - left_width - gap, rect.size.y)
	)

	return {
		"left": left,
		"right": right
	}

# ============================================================
# /*=== SPLIT HELPERS END ===*/
# ============================================================

# ============================================================
# /*=== ALIGNMENT HELPERS START ===*/
# ============================================================

static func center_in(parent: Rect2, size: Vector2) -> Rect2:
	return Rect2(
		parent.position + (parent.size - size) * 0.5,
		size
	)


static func anchor_bottom(parent: Rect2, height: float) -> Rect2:
	return Rect2(
		Vector2(parent.position.x, parent.end.y - height),
		Vector2(parent.size.x, height)
	)

# ============================================================
# /*=== ALIGNMENT HELPERS END ===*/
# ============================================================


# ============================================================
# /*=== FILL HELPERS START ===*/
# ============================================================

static func fill_remaining(top: Rect2, parent: Rect2, gap: float = UIConstants.SECTION_GAP) -> Rect2:
	return Rect2(
		Vector2(parent.position.x, top.end.y + gap),
		Vector2(parent.size.x, parent.end.y - top.end.y - gap)
	)

# ============================================================
# /*=== FILL HELPERS END ===*/
# ============================================================