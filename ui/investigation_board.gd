extends PanelContainer
## Presents public knowledge and player-authored associations. No case/network access.
signal language_requested(index: int)
const Model = preload("res://core/investigation_board.gd")
const Canvas = preload("res://ui/board_canvas.gd")
const Presentation = preload("res://ui/presentation.gd")
const L = preload("res://ui/localization.gd")
var model: RefCounted
var canvas: Control
var people: Array = []
var rooms: Array = []
var observations: Array = []
var labels: Dictionary = {}
var selected_card = ""
var selected_link = ""
var card_picker: OptionButton
var link_picker: OptionButton
var marker: OptionButton
var link_text: LineEdit
var note_text: TextEdit
var detail_title: Label
var detail_body: Label
var delete_button: Button
var connect_button: Button
var status: Label
var locale_choice: OptionButton
var connection_fields: VBoxContainer
var note_fields: VBoxContainer
var _static_labels: Dictionary = {}
var _editing = false
var _opened = false
var pile_label: Label
var place_button: Button
var stash_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_theme()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("1b211c")
	style.border_color = Color("766e50")
	style.set_border_width_all(2)
	style.set_content_margin_all(20)
	add_theme_stylebox_override("panel", style)
	var page = VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	add_child(page)
	var header = HBoxContainer.new()
	page.add_child(header)
	var title = _label(header, "board.title", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	locale_choice = OptionButton.new()
	for locale_id in L.available_locales():
		locale_choice.add_item(L.language_name(locale_id))
	locale_choice.item_selected.connect(func(index): language_requested.emit(index))
	header.add_child(locale_choice)
	_button(header, "board.close", func(): hide())
	var tools = HBoxContainer.new()
	page.add_child(tools)
	connect_button = _button(tools, "board.connect", _toggle_connect)
	_button(tools, "board.new_note", _add_note)
	_button(tools, "board.fit", func(): canvas.fit_cards())
	status = _label(tools, "board.help", 13)
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	canvas = Canvas.new()
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(320, 300)
	body.add_child(canvas)
	canvas.card_selected.connect(_select_card)
	canvas.link_selected.connect(_select_link)
	var sidebar = VBoxContainer.new()
	sidebar.custom_minimum_size.x = 310
	sidebar.add_theme_constant_override("separation", 9)
	body.add_child(sidebar)
	var pile = Control.new()
	pile.custom_minimum_size.y = 50
	sidebar.add_child(pile)
	for offset in [8, 4, 0]:
		var sheet = ColorRect.new()
		sheet.position = Vector2(offset, offset)
		sheet.size = Vector2(290, 38)
		sheet.color = Color("77745b") if offset > 0 else Color("b5a680")
		sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pile.add_child(sheet)
	pile_label = Label.new()
	pile_label.position = Vector2(10, 8)
	pile_label.add_theme_color_override("font_color", Color("23281f"))
	pile.add_child(pile_label)
	_label(sidebar, "board.cards", 12)
	card_picker = OptionButton.new()
	card_picker.fit_to_longest_item = false
	card_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sidebar.add_child(card_picker)
	card_picker.item_selected.connect(func(index):
		var id = str(card_picker.get_item_metadata(index))
		if id != "":
			_select_card(id)
			canvas.focus_card(id))
	place_button = _button(sidebar, "board.place", _place_selected)
	stash_button = _button(sidebar, "board.stash", _stash_selected)
	_label(sidebar, "board.connections", 12)
	link_picker = OptionButton.new()
	link_picker.fit_to_longest_item = false
	link_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sidebar.add_child(link_picker)
	link_picker.item_selected.connect(func(index):
		var id = str(link_picker.get_item_metadata(index))
		if id != "": _select_link(id))
	sidebar.add_child(HSeparator.new())
	detail_title = _label(sidebar, "", 20)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar.add_child(scroll)
	detail_body = _label(scroll, "", 15)
	detail_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connection_fields = VBoxContainer.new()
	sidebar.add_child(connection_fields)
	_label(connection_fields, "board.marker", 12)
	marker = OptionButton.new()
	connection_fields.add_child(marker)
	marker.item_selected.connect(func(_index): _edit_link())
	_label(connection_fields, "board.link_label", 12)
	link_text = LineEdit.new()
	connection_fields.add_child(link_text)
	link_text.text_changed.connect(func(_text): _edit_link())
	note_fields = VBoxContainer.new()
	sidebar.add_child(note_fields)
	_label(note_fields, "board.note_body", 12)
	note_text = TextEdit.new()
	note_text.custom_minimum_size.y = 150
	note_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	note_fields.add_child(note_text)
	note_text.text_changed.connect(_edit_note)
	delete_button = _button(sidebar, "board.remove", _remove_selected)
	refresh()
	hide()

func _build_theme() -> void:
	# Native monochrome lettering and hard edges; no external font/texture pack.
	var board_theme = theme.duplicate() if theme != null else Theme.new()
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Menlo", "Consolas", "Liberation Mono", "DejaVu Sans Mono", "monospace"])
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	board_theme.default_font = font
	board_theme.default_font_size = 14
	for type in ["Button", "OptionButton", "LineEdit", "TextEdit"]:
		for state in ["normal", "hover", "pressed", "focus"]:
			var box = StyleBoxFlat.new()
			box.bg_color = Color("30382c") if state == "hover" else Color("20291f")
			box.border_color = Color("c5ab74") if state == "focus" else Color("696c50")
			box.set_border_width_all(2 if state == "focus" else 1)
			box.content_margin_left = 10
			box.content_margin_right = 10
			box.content_margin_top = 8
			box.content_margin_bottom = 8
			board_theme.set_stylebox(state, type, box)
	theme = board_theme

func _label(parent: Node, key: String, font_size: int) -> Label:
	var label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	if key != "": _static_labels[label] = key
	return label

func _button(parent: Node, key: String, action: Callable) -> Button:
	var button = Button.new()
	parent.add_child(button)
	_static_labels[button] = key
	button.pressed.connect(action)
	return button

func new_session(state: RefCounted = null) -> void:
	model = state if state != null else Model.new()
	selected_card = ""
	selected_link = ""
	_opened = false
	canvas.pan = Vector2(30, 30)
	canvas.zoom = 0.65
	canvas.connecting = false
	canvas.connection_start = ""
	hide()

func sync(known_people: Array, known_rooms: Array, discoveries: Array) -> void:
	people = known_people.duplicate(true)
	rooms = known_rooms.duplicate(true)
	observations = discoveries.duplicate(true)
	model.sync(people, rooms, observations)
	refresh()

func open_board() -> void:
	show()
	if not _opened:
		_opened = true
		_fit_on_open.call_deferred()
	card_picker.grab_focus()

func _fit_on_open() -> void:
	# Hidden containers finish layout on the first visible frame.
	await get_tree().process_frame
	if visible: canvas.fit_cards()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if canvas.connecting:
			canvas.connecting = false
			canvas.connection_start = ""
			_refresh_selection()
		else: hide()
		get_viewport().set_input_as_handled()

func refresh() -> void:
	if canvas == null: return
	for control in _static_labels:
		control.text = L.text(_static_labels[control])
	locale_choice.select(L.available_locales().find(L.locale()))
	marker.clear()
	for key in ["board.no_marker", "board.question_marker", "board.cross_marker"]:
		marker.add_item(L.text(key))
	link_text.placeholder_text = L.text("board.link_placeholder")
	note_text.placeholder_text = L.text("board.note_placeholder")
	if model == null: return
	labels = {}
	for id in model.cards:
		labels[id] = _content(model.cards[id])
	canvas.rebuild(model, labels)
	_refresh_pickers()
	_refresh_selection()

func _content(card: Dictionary) -> Dictionary:
	var title = ""
	var body = ""
	match card.kind:
		"person":
			title = Presentation.person(card.reference, people)
			for person in people:
				if person.id == card.reference: body = L.text("role." + person.role)
		"room":
			for room in rooms:
				if room.id == card.reference:
					title = L.text(room.name_key)
					body = L.text("board.room_known" if room.accessible else "board.room_closed")
		"evidence", "object":
			var reference: String = card.reference if card.kind == "evidence" else card.evidence_id
			for observation in observations:
				if observation.id == reference:
					title = Presentation.title(observation)
					body = Presentation.describe(observation, people)
					if card.kind == "object":
						body = L.text("board.object_found") + "\n\n" + body
		"note":
			title = str(card.text).get_slice("\n", 0).left(80) if card.text != "" else L.text("board.note")
			body = card.text
	return {"title": title, "body": body, "kind": L.text("board.kind." + card.kind)}

func _refresh_pickers() -> void:
	pile_label.text = L.text("board.pile", {"count": model.cards.size() - model.placed_cards().size()})
	card_picker.clear()
	card_picker.add_item(L.text("board.choose_card"))
	card_picker.set_item_metadata(0, "")
	for id in model.cards:
		card_picker.add_item(L.text("board.on_board" if model.cards[id].placed else "board.in_pile") + " · " + labels[id].kind + " · " + labels[id].title)
		card_picker.set_item_metadata(card_picker.item_count - 1, id)
	link_picker.clear()
	link_picker.add_item(L.text("board.choose_link"))
	link_picker.set_item_metadata(0, "")
	for id in model.links:
		var link: Dictionary = model.links[id]
		if not model.cards[link.from].placed or not model.cards[link.to].placed: continue
		link_picker.add_item(link.mark + " " + labels[link.from].title + " — " + labels[link.to].title)
		link_picker.set_item_metadata(link_picker.item_count - 1, id)
	_select_picker(card_picker, selected_card)
	_select_picker(link_picker, selected_link)

func _select_picker(picker: OptionButton, id: String) -> void:
	for index in picker.item_count:
		if picker.get_item_metadata(index) == id:
			picker.select(index)
			return
	picker.select(0)

func _select_card(id: String) -> void:
	if not model.cards.has(id): return
	if canvas.connecting and model.cards[id].placed:
		if canvas.connection_start == "":
			canvas.connection_start = id
		elif canvas.connection_start != id:
			var link_id: String = model.connect_cards(canvas.connection_start, id)
			canvas.connection_start = ""
			canvas.connecting = false
			_select_link(link_id)
			return
	selected_card = id
	selected_link = ""
	_refresh_selection()

func _select_link(id: String) -> void:
	if not model.links.has(id): return
	selected_link = id
	selected_card = ""
	canvas.connection_start = ""
	canvas.connecting = false
	_refresh_pickers()
	_refresh_selection()

func _refresh_selection() -> void:
	_editing = true
	place_button.visible = selected_card != "" and model.cards.has(selected_card) and not model.cards[selected_card].placed
	stash_button.visible = selected_card != "" and model.cards.has(selected_card) and model.cards[selected_card].placed
	connection_fields.visible = selected_link != "" and model.links.has(selected_link)
	note_fields.visible = selected_card != "" and model.cards.has(selected_card) and model.cards[selected_card].kind == "note"
	delete_button.visible = connection_fields.visible or note_fields.visible
	if connection_fields.visible:
		var link: Dictionary = model.links[selected_link]
		detail_title.text = L.text("board.connection")
		detail_body.text = labels[link.from].title + "\n—\n" + labels[link.to].title
		marker.select(["", "?", "X"].find(link.mark))
		link_text.text = link.text
	elif selected_card != "" and labels.has(selected_card):
		detail_title.text = labels[selected_card].title
		detail_body.text = labels[selected_card].body
		if note_fields.visible:
			note_text.text = model.cards[selected_card].text
	else:
		detail_title.text = L.text("board.choose_card")
		detail_body.text = L.text("board.selection_help")
	_select_picker(card_picker, selected_card)
	_select_picker(link_picker, selected_link)
	canvas.highlight(selected_card, selected_link)
	connect_button.text = L.text("board.cancel_connect" if canvas.connecting else "board.connect")
	status.text = L.text("board.select_second" if canvas.connection_start != "" else ("board.select_first" if canvas.connecting else "board.help"))
	_editing = false

func _toggle_connect() -> void:
	canvas.connecting = not canvas.connecting
	canvas.connection_start = ""
	_refresh_selection()

func _place_selected() -> void:
	if selected_card == "": return
	var center = (canvas.size / 2 - canvas.pan) / canvas.zoom
	var position: Vector2 = model.cards[selected_card].position if model.cards[selected_card].was_placed else center - Canvas.CARD_SIZE / 2
	model.place_card(selected_card, position)
	refresh()

func _stash_selected() -> void:
	if selected_card == "": return
	model.unplace_card(selected_card)
	canvas.connection_start = ""
	refresh()

func _add_note() -> void:
	var center = (canvas.size / 2 - canvas.pan) / canvas.zoom
	var id: String = model.add_note(center - Canvas.CARD_SIZE / 2)
	refresh()
	_select_card(id)
	note_text.grab_focus()

func _edit_link() -> void:
	if _editing or selected_link == "": return
	model.edit_link(selected_link, ["", "?", "X"][marker.selected], link_text.text)
	_refresh_pickers()
	canvas.refresh_links()

func _edit_note() -> void:
	if _editing or selected_card == "": return
	model.edit_note(selected_card, note_text.text)
	labels[selected_card] = _content(model.cards[selected_card])
	canvas.rebuild(model, labels)
	canvas.highlight(selected_card, selected_link)
	_refresh_pickers()
	detail_title.text = labels[selected_card].title
	detail_body.text = labels[selected_card].body

func _remove_selected() -> void:
	if selected_link != "":
		model.remove_link(selected_link)
		selected_link = ""
	elif selected_card != "":
		model.remove_note(selected_card)
		selected_card = ""
	refresh()
