extends Control
## Spatial interaction only. No knowledge of causal relations or verdicts.
signal card_selected(id: String)
signal link_selected(id: String)
const CARD_SIZE = Vector2(220, 132)
var model: RefCounted
var widgets: Dictionary = {}
var titles: Dictionary = {}
var pan = Vector2(30, 30)
var zoom = 0.65
var selected_card = ""
var selected_link = ""
var connecting = false
var connection_start = ""
var _drag_card = ""
var _dragging_background = false
var _font: Font
var _annotations: Control

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = get_theme_default_font()
	_annotations = Control.new()
	_annotations.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_annotations.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_annotations)
	_annotations.draw.connect(_draw_labels.bind(_annotations))
	resized.connect(refresh_links)

func rebuild(board: RefCounted, labels: Dictionary) -> void:
	model = board
	titles = labels
	for widget in widgets.values():
		remove_child(widget)
		widget.queue_free()
	widgets.clear()
	for id in model.placed_cards():
		var card: Dictionary = model.cards[id]
		var panel = Panel.new()
		panel.custom_minimum_size = CARD_SIZE
		panel.size = CARD_SIZE
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if connecting else Control.CURSOR_DRAG
		var color = {"person": "b5a680", "room": "9fa79a", "evidence": "c9bea1", "object": "ada793", "note": "c0b088"}[card.kind]
		var style = StyleBoxFlat.new()
		style.bg_color = Color(color)
		style.border_color = Color("a45e40") if id == selected_card or id == connection_start else Color("605b46")
		style.set_border_width_all(2 if id == selected_card or id == connection_start else 1)
		panel.add_theme_stylebox_override("panel", style)
		var pin = ColorRect.new()
		pin.color = Color("645c48")
		pin.position = Vector2(106, 4)
		pin.size = Vector2(7, 5)
		pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(pin)
		var type_label = Label.new()
		type_label.text = labels[id].kind
		type_label.position = Vector2(14, 12)
		type_label.size = Vector2(192, 20)
		type_label.add_theme_font_size_override("font_size", 11)
		type_label.add_theme_color_override("font_color", Color("504d3a"))
		type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(type_label)
		var title = Label.new()
		title.text = labels[id].title
		title.position = Vector2(14, 38)
		title.size = Vector2(192, 72)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.max_lines_visible = 3
		title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title.add_theme_font_size_override("font_size", 17)
		title.add_theme_color_override("font_color", Color("23281f"))
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(title)
		add_child(panel)
		widgets[id] = panel
		panel.gui_input.connect(_card_input.bind(id))
	move_child(_annotations, get_child_count() - 1)
	_layout()

func _layout() -> void:
	if model == null: return
	for id in widgets:
		widgets[id].position = model.cards[id].position * zoom + pan
		widgets[id].scale = Vector2.ONE * zoom
	refresh_links()

func refresh_links() -> void:
	queue_redraw()
	if _annotations != null: _annotations.queue_redraw()

func highlight(card_id: String, link_id: String) -> void:
	selected_card = card_id
	selected_link = link_id
	for id in widgets:
		var style = widgets[id].get_theme_stylebox("panel").duplicate()
		var selected = id == selected_card or id == connection_start
		style.border_color = Color("a45e40") if selected else Color("605b46")
		style.set_border_width_all(2 if selected else 1)
		widgets[id].add_theme_stylebox_override("panel", style)
		widgets[id].mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if connecting else Control.CURSOR_DRAG
	refresh_links()

func focus_card(id: String) -> void:
	if model != null and model.cards.has(id) and model.cards[id].placed:
		zoom = maxf(0.8, zoom)
		pan = size / 2 - (model.cards[id].position + CARD_SIZE / 2) * zoom
		_layout()

func fit_cards() -> void:
	if model == null or model.placed_cards().is_empty(): return
	var bounds = Rect2(model.placed_cards().values()[0].position, CARD_SIZE)
	for card in model.placed_cards().values():
		bounds = bounds.merge(Rect2(card.position, CARD_SIZE))
	zoom = clampf(minf((size.x - 64) / bounds.size.x, (size.y - 64) / bounds.size.y), 0.35, 1.5)
	pan = size / 2 - bounds.get_center() * zoom
	_layout()

func _card_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			_zoom_at(get_local_mouse_position(), 1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				card_selected.emit(id)
				if not connecting:
					_drag_card = id
					move_child(widgets[id], maxi(0, get_child_count() - 2))
			else:
				_drag_card = ""
			accept_event()
	elif event is InputEventMouseMotion and _drag_card == id and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# global mouse movement avoids jumps when the card moves under the cursor.
		model.move_card(id, model.cards[id].position + event.relative)
		_layout()
		accept_event()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			_zoom_at(event.position, 1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging_background = event.pressed
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var link_id = _link_at(event.position)
				if link_id != "": link_selected.emit(link_id)
				else: _dragging_background = true
			else: _dragging_background = false
		accept_event()
	elif event is InputEventMouseMotion and _dragging_background:
		pan += event.relative
		_layout()
		accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE]:
		_drag_card = ""
		_dragging_background = false

func _zoom_at(point: Vector2, factor: float) -> void:
	var world = (point - pan) / zoom
	zoom = clampf(zoom * factor, 0.35, 1.5)
	pan = point - world * zoom
	_layout()

func _center(id: String) -> Vector2:
	return (model.cards[id].position + CARD_SIZE / 2) * zoom + pan

func _link_at(point: Vector2) -> String:
	if model == null: return ""
	var closest = ""
	var distance = 14.0
	for id in model.links:
		var link: Dictionary = model.links[id]
		if not model.cards[link.from].placed or not model.cards[link.to].placed: continue
		var start = _center(link.from)
		var end = _center(link.to)
		var candidate = point.distance_to(Geometry2D.get_closest_point_to_segment(point, start, end))
		if candidate < distance:
			distance = candidate
			closest = id
	return closest

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("2b2c23"))
	# Fixed pixel grain suggests a physical surface without animated noise or blur.
	for x in range(0, int(size.x), 12):
		for y in range(0, int(size.y), 13):
			var variation = (x * 17 + y * 31) % 7
			draw_rect(Rect2(Vector2(x + variation, y), Vector2(2 + variation % 2, 2)), Color("393a2d") if variation < 3 else Color("23271f"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("71664b"), false, 3)
	if model == null or _font == null: return
	for id in model.links:
		var link: Dictionary = model.links[id]
		if not model.cards[link.from].placed or not model.cards[link.to].placed: continue
		var start = _center(link.from)
		var end = _center(link.to)
		var color = Color("dfb877") if id == selected_link else Color("b57d58")
		draw_line(start, end, color, 3 if id == selected_link else 2, false)

func _draw_labels(layer: Control) -> void:
	if model == null or _font == null: return
	for id in model.links:
		var link: Dictionary = model.links[id]
		if not model.cards[link.from].placed or not model.cards[link.to].placed: continue
		var start = _center(link.from)
		var end = _center(link.to)
		var color = Color("dfb877") if id == selected_link else Color("b57d58")
		var text = link.mark
		if link.text != "":
			text += (" " if text != "" else "") + str(link.text).left(32)
			if link.text.length() > 32: text += "…"
		if text == "": continue
		var midpoint = (start + end) / 2
		var text_size = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
		var rect = Rect2(midpoint - Vector2(text_size.x / 2 + 8, 15), Vector2(text_size.x + 16, 28))
		layer.draw_rect(rect, Color("172825"))
		layer.draw_rect(rect, color, false)
		layer.draw_string(_font, rect.position + Vector2(8, 20), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("efe1c4"))
