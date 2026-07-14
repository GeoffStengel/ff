# ============================================================
# /*=== UI DEBUG OVERLAY FILE START ===*/
# ============================================================
class_name UIDebugOverlay
extends CanvasLayer

# ============================================================
# UIDebugOverlay
# ------------------------------------------------------------
# Purpose:
# Developer-only runtime Control inspection overlay.
#
# Responsibilities:
# - Toggle with Ctrl+Shift+D
# - Draw bounds around visible Control nodes
# - Highlight the Control under the mouse
# - Show useful runtime layout metadata
#
# Does NOT:
# - Modify gameplay state
# - Modify layout
# - Consume mouse input
# - Change save data
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY CONSTANTS START ===*/
# ============================================================

const OVERLAY_LAYER := 4096
const PANEL_PADDING := 10.0
const LINE_HEIGHT := 16.0
const MAX_INSPECTED_CONTROLS := 512

const BOUNDS_COLOR := Color(0.2, 0.65, 1.0, 0.62)
const HOVER_COLOR := Color(1.0, 0.72, 0.15, 0.95)
const PANEL_FILL := Color(0.06, 0.045, 0.035, 0.86)
const PANEL_BORDER := Color(1.0, 0.78, 0.38, 0.9)
const TEXT_COLOR := Color(1.0, 0.95, 0.82, 1.0)

# ============================================================
# /*=== DEBUG OVERLAY CONSTANTS END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY STATE START ===*/
# ============================================================

var _enabled: bool = false
var _root_node: Node
var _canvas: Control
var _hovered_control: Control
var _font: Font

# ============================================================
# /*=== DEBUG OVERLAY STATE END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY SETUP START ===*/
# ============================================================

func _ready() -> void:
	layer = OVERLAY_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = ThemeDB.fallback_font

	_canvas = Control.new()
	_canvas.name = "UIDebugOverlayCanvas"
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_overlay)
	add_child(_canvas)

	set_process_input(true)
	set_process(true)
	visible = false


func set_root_node(root_node: Node) -> void:
	_root_node = root_node

# ============================================================
# /*=== DEBUG OVERLAY SETUP END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY INPUT START ===*/
# ============================================================

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_D and key_event.ctrl_pressed and key_event.shift_pressed:
				_enabled = not _enabled
				visible = _enabled
				_refresh()
				get_viewport().set_input_as_handled()

# ============================================================
# /*=== DEBUG OVERLAY INPUT END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY PROCESS START ===*/
# ============================================================

func _process(_delta: float) -> void:
	if not _enabled:
		return
	var hovered: Control = _find_hovered_control()
	if hovered != _hovered_control:
		_hovered_control = hovered
	_refresh()


func _refresh() -> void:
	if _canvas != null:
		_canvas.queue_redraw()

# ============================================================
# /*=== DEBUG OVERLAY PROCESS END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY DRAWING START ===*/
# ============================================================

func _draw_overlay() -> void:
	if not _enabled:
		return

	var controls: Array[Control] = _visible_controls()
	for control in controls:
		var rect: Rect2 = _control_global_rect(control)
		_canvas.draw_rect(rect, BOUNDS_COLOR, false, 1.0)

	if _hovered_control != null and is_instance_valid(_hovered_control):
		var hover_rect: Rect2 = _control_global_rect(_hovered_control)
		_canvas.draw_rect(hover_rect, HOVER_COLOR, false, 3.0)
		_draw_info_panel(_hovered_control, hover_rect)


func _draw_info_panel(control: Control, hover_rect: Rect2) -> void:
	var lines: Array[String] = _control_info_lines(control)
	var width: float = 460.0
	var height: float = PANEL_PADDING * 2.0 + float(lines.size()) * LINE_HEIGHT
	var viewport_size: Vector2 = _canvas.get_viewport_rect().size
	var position: Vector2 = hover_rect.position + Vector2(12.0, 12.0)

	if position.x + width > viewport_size.x:
		position.x = maxf(8.0, viewport_size.x - width - 8.0)
	if position.y + height > viewport_size.y:
		position.y = maxf(8.0, hover_rect.position.y - height - 8.0)

	var panel_rect: Rect2 = Rect2(position, Vector2(width, height))
	_canvas.draw_rect(panel_rect, PANEL_FILL, true)
	_canvas.draw_rect(panel_rect, PANEL_BORDER, false, 1.0)

	for i in lines.size():
		var text_position: Vector2 = panel_rect.position + Vector2(PANEL_PADDING, PANEL_PADDING + 12.0 + float(i) * LINE_HEIGHT)
		_canvas.draw_string(_font, text_position, lines[i], HORIZONTAL_ALIGNMENT_LEFT, width - PANEL_PADDING * 2.0, 12, TEXT_COLOR)

# ============================================================
# /*=== DEBUG OVERLAY DRAWING END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY CONTROL COLLECTION START ===*/
# ============================================================

func _visible_controls() -> Array[Control]:
	var result: Array[Control] = []
	var root: Node = _root_node
	if root == null:
		root = get_tree().root
	_collect_visible_controls(root, result)
	return result


func _collect_visible_controls(node: Node, result: Array[Control]) -> void:
	if result.size() >= MAX_INSPECTED_CONTROLS:
		return
	if node == self or node == _canvas:
		return

	if node is Control:
		var control: Control = node as Control
		if control.visible and control.is_visible_in_tree():
			result.append(control)

	for child in node.get_children():
		_collect_visible_controls(child, result)


func _find_hovered_control() -> Control:
	var mouse_position: Vector2 = _canvas.get_global_mouse_position()
	var controls: Array[Control] = _visible_controls()
	for i in range(controls.size() - 1, -1, -1):
		var control: Control = controls[i]
		if _control_global_rect(control).has_point(mouse_position):
			return control
	return null

# ============================================================
# /*=== DEBUG OVERLAY CONTROL COLLECTION END ===*/
# ============================================================


# ============================================================
# /*=== DEBUG OVERLAY INFO START ===*/
# ============================================================

func _control_info_lines(control: Control) -> Array[String]:
	var parent_name: String = "<none>"
	if control.get_parent() != null:
		parent_name = String(control.get_parent().name)

	return [
		"name: %s" % String(control.name),
		"class: %s" % control.get_class(),
		"path: %s" % String(control.get_path()),
		"size: %s" % _format_vector(control.size),
		"custom_minimum_size: %s" % _format_vector(control.custom_minimum_size),
		"size_flags: H=%s V=%s" % [control.size_flags_horizontal, control.size_flags_vertical],
		"parent: %s" % parent_name
	]


func _control_global_rect(control: Control) -> Rect2:
	return Rect2(control.global_position, control.size)


func _format_vector(value: Vector2) -> String:
	return "%.1f x %.1f" % [value.x, value.y]

# ============================================================
# /*=== DEBUG OVERLAY INFO END ===*/
# ============================================================

# ============================================================
# /*=== UI DEBUG OVERLAY FILE END ===*/
# ============================================================
