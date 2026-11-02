extends Control
## Development desk. All case rules remain in the scene-independent core.
const Generator = preload("res://core/case_generator.gd")
const Investigation = preload("res://core/investigation.gd")
const Presentation = preload("res://ui/presentation.gd")
const L = preload("res://ui/localization.gd")
const Content = preload("res://core/case_content.gd")
const Board = preload("res://ui/investigation_board.gd")
const INK = Color("e9e2d2")
const MUTED = Color("aaa99c")
const GOLD = Color("c5a76b")
var session: RefCounted
var people: Array = []
var selected_proofs: Array = []
var seed_input: LineEdit
var room_list: VBoxContainer
var object_list: VBoxContainer
var discovery_list: VBoxContainer
var inspector_title: Label
var inspector_body: RichTextLabel
var room_title: Label
var status: Label
var culprit_choice: OptionButton
var motive_choice: OptionButton
var method_choice: OptionButton
var submit_button: Button
var debug_toggle: CheckBox
var finished = false
var language_choice: OptionButton
var _current_room = ""
var _inspected_id = ""
var _conversation_id = ""
var conversation_actions: VBoxContainer
var conversation_proofs: OptionButton
var _dialogue_fragments: Dictionary = {}
var _dialogue_mode = ""
var _dialogue_proof = ""
var _last_verdict: Dictionary = {}
var board: Control

func _ready() -> void:
	L.initialize()
	get_window().title = L.text("ui.window_title")
	_build_theme()
	var background = ColorRect.new()
	background.color = Color("111b1b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var page = _column(margin, 16)
	var header = HBoxContainer.new()
	page.add_child(header)
	var heading = _column(header, 4)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(heading, "DEAD LETTER", 36, GOLD)
	_label(heading, "ui.subtitle", 16, MUTED)
	var seed_controls = HBoxContainer.new()
	seed_controls.alignment = BoxContainer.ALIGNMENT_END
	header.add_child(seed_controls)
	var seed_label = _label(seed_controls, "ui.seed", 18, MUTED)
	seed_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	seed_label.custom_minimum_size.x = 48
	seed_input = LineEdit.new()
	seed_input.custom_minimum_size.x = 110
	seed_input.text = str(randi_range(0, 999999))
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--seed=") and argument.trim_prefix("--seed=").is_valid_int():
			seed_input.text = argument.trim_prefix("--seed=")
	seed_input.placeholder_text = L.text("ui.case_number")
	seed_controls.add_child(seed_input)
	seed_input.text_submitted.connect(func(_text): _open_seed())
	_button(seed_controls, "ui.open_seed", _open_seed)
	_button(seed_controls, "ui.new_case", func():
		seed_input.text = str(randi_range(0, 999999))
		_open_seed())
	_button(seed_controls, "board.open", _open_board)
	language_choice = OptionButton.new()
	for locale_id in L.available_locales():
		language_choice.add_item(L.language_name(locale_id))
		language_choice.set_item_metadata(language_choice.item_count - 1, locale_id)
		if locale_id == L.locale():
			language_choice.selected = language_choice.item_count - 1
	language_choice.item_selected.connect(_change_language)
	seed_controls.add_child(language_choice)
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	var left = _panel(body, 260)
	_label(left, "ui.locations", 16, GOLD)
	room_list = _column(left, 6)
	left.add_child(HSeparator.new())
	room_title = _label(left, "ui.choose_location", 22)
	var object_scroll = ScrollContainer.new()
	object_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	object_scroll.custom_minimum_size.y = 90
	object_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(object_scroll)
	object_list = _column(object_scroll, 7)
	object_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var middle = _panel(body, 0)
	middle.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(middle, "ui.examine", 16, GOLD)
	inspector_title = _label(middle, "ui.what_happened", 30)
	var detail_scroll = ScrollContainer.new()
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	middle.add_child(detail_scroll)
	inspector_body = RichTextLabel.new()
	inspector_body.fit_content = true
	inspector_body.meta_underlined = false
	inspector_body.add_theme_constant_override("line_separation", 4)
	inspector_body.add_theme_font_size_override("normal_font_size", 22)
	inspector_body.add_theme_color_override("default_color", INK)
	inspector_body.meta_clicked.connect(_follow_dialogue)
	detail_scroll.add_child(inspector_body)
	inspector_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conversation_actions = _column(middle, 6)
	var right_frame = _panel(body, 380)
	var report_scroll = ScrollContainer.new()
	report_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_frame.add_child(report_scroll)
	var right = _column(report_scroll, 8)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(right, "ui.report", 16, GOLD)
	_label(right, "ui.build_accusation", 24)
	_label(right, "ui.report_help", 16, MUTED)
	_label(right, "ui.accused", 16, MUTED)
	culprit_choice = _choice(right)
	_label(right, "ui.motive", 16, MUTED)
	motive_choice = _choice(right)
	_fill_choices(motive_choice, ["money", "jealousy", "revenge"])
	_label(right, "ui.method", 16, MUTED)
	method_choice = _choice(right)
	_fill_choices(method_choice, Content.METHODS)
	_label(right, "ui.discoveries", 16, GOLD)
	discovery_list = _column(right, 5)
	discovery_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_toggle = CheckBox.new()
	_set_text(debug_toggle, "ui.debug")
	debug_toggle.button_pressed = true
	debug_toggle.tooltip_text = L.text("ui.debug_tooltip")
	right_frame.add_child(debug_toggle)
	submit_button = _button(right_frame, "ui.submit", _submit)
	_label(right_frame, "ui.final_warning", 16, MUTED)
	status = _label(page, "", 16, MUTED)
	board = Board.new()
	add_child(board)
	board.language_requested.connect(_change_language)
	_open_seed()

func _build_theme() -> void:
	var desk_theme = Theme.new()
	desk_theme.default_font_size = 20
	desk_theme.set_color("font_color", "Label", INK)
	desk_theme.set_color("font_color", "Button", INK)
	desk_theme.set_color("font_color", "CheckBox", INK)
	desk_theme.set_color("font_color", "LineEdit", INK)
	desk_theme.set_color("font_color", "TextEdit", INK)
	desk_theme.set_color("font_color", "OptionButton", INK)
	for type in ["Button", "OptionButton", "LineEdit", "TextEdit"]:
		for state in ["normal", "hover", "pressed", "focus"]:
			var box = StyleBoxFlat.new()
			box.bg_color = Color("263735") if state == "hover" else Color("192827")
			box.border_color = GOLD if state == "focus" else Color("42504a")
			box.set_border_width_all(1)
			box.set_corner_radius_all(0)
			box.content_margin_left = 12
			box.content_margin_right = 12
			box.content_margin_top = 9
			box.content_margin_bottom = 9
			desk_theme.set_stylebox(state, type, box)
	theme = desk_theme

func _column(parent: Node, spacing: int) -> VBoxContainer:
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", spacing)
	parent.add_child(column)
	return column

func _panel(parent: Node, minimum_width: int) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size.x = minimum_width
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color("1c2927")
	style.border_color = Color("3a4841")
	style.set_border_width_all(1)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return _column(panel, 12)

func _label(parent: Node, text: String, size: int, color: Color = INK) -> Label:
	var label = Label.new()
	_set_text(label, text)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button = Button.new()
	_set_text(button, text)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _choice(parent: Node) -> OptionButton:
	var choice = OptionButton.new()
	choice.add_item(L.text("ui.choose"))
	choice.set_item_metadata(0, "")
	parent.add_child(choice)
	return choice

func _fill_choices(choice: OptionButton, values: Array) -> void:
	for value in values:
		choice.add_item(Presentation.word(value))
		choice.set_item_metadata(choice.item_count - 1, value)

func _clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _open_seed() -> void:
	if not seed_input.text.is_valid_int():
		_set_text(status, "ui.invalid_seed")
		return
	var generated = Generator.new().generate(int(seed_input.text))
	if generated.case.is_empty():
		_set_text(status, "ui.generation_failed")
		push_error(JSON.stringify(generated))
		return
	session = Investigation.new(generated.case)
	people = session.characters()
	board.new_session(session.board)
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	selected_proofs.clear()
	finished = false
	_current_room = ""
	_inspected_id = ""
	_last_verdict = {}
	culprit_choice.clear()
	culprit_choice.add_item(L.text("ui.choose"))
	culprit_choice.set_item_metadata(0, "")
	for character in people:
		if not character.accusable:
			continue
		culprit_choice.add_item(Presentation.person(character.id, people) + " · " + L.text("role." + character.role))
		culprit_choice.set_item_metadata(culprit_choice.item_count - 1, character.id)
	for choice in [culprit_choice, motive_choice, method_choice]:
		choice.selected = 0
		choice.disabled = false
	submit_button.disabled = false
	debug_toggle.disabled = false
	_conversation_id = ""
	_clear(conversation_actions)
	_clear(room_list)
	_clear(object_list)
	_clear(discovery_list)
	_label(discovery_list, "ui.inspect_help", 18, MUTED)
	_refresh_rooms()
	room_title.text = L.text("ui.items")
	inspector_title.text = L.text("ui.intro_title")
	inspector_body.text = L.text("ui.intro", {"place": L.text("location." + session.briefing().discovery_location)})
	_set_text(status, "ui.case_opened", {"seed": seed_input.text})

func _open_board() -> void:
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	board.open_board()

func _show_room(id: String, _title: String = "") -> void:
	if not session.visit_location(id): return
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	_current_room = id
	_conversation_id = ""
	_clear(conversation_actions)
	_clear(object_list)
	room_title.text = L.text("location." + id)
	for character in session.characters_at(id):
		var name_text = Presentation.person(character.id, people)
		var npc_button = _button(object_list, L.text("conversation.talk", {"person": name_text}), _talk.bind(character.id))
		npc_button.clip_text = true
		npc_button.tooltip_text = L.text("conversation.talk", {"person": name_text})
		npc_button.disabled = finished
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	for item in session.objects_at(id):
		var button = _button(object_list, Presentation.title(item), _inspect.bind(item.id))
		button.clip_text = true
		button.tooltip_text = Presentation.title(item)
		button.disabled = finished

func _inspect(id: String) -> void:
	if finished:
		return
	var observation: Dictionary = session.inspect(id)
	if observation.is_empty():
		return
	_conversation_id = ""
	_clear(conversation_actions)
	_inspected_id = id
	inspector_title.text = Presentation.title(observation)
	inspector_body.text = Presentation.word(observation.kind) + "\n\n" + Presentation.describe(observation, people)
	_refresh_discoveries()
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	_set_text(status, "ui.discovered")

func _refresh_discoveries() -> void:
	_clear(discovery_list)
	if session.discoveries().is_empty():
		_label(discovery_list, "ui.inspect_help", 18, MUTED)
	var groups: Dictionary = {}
	for observation in session.discoveries():
		var key = "object:" + str(observation.properties.get("object_id", observation.id)) if observation.kind == "object" else "evidence:" + str(observation.id)
		if not groups.has(key): groups[key] = []
		groups[key].append(observation)
	for group in groups.values():
		var observation: Dictionary = group[0]
		var ids: Array = group.map(func(item): return item.id)
		if ids.any(func(id): return id in selected_proofs):
			_toggle_proof_group(true, ids)
		var row = HBoxContainer.new()
		discovery_list.add_child(row)
		var box = CheckBox.new()
		box.button_pressed = ids.all(func(id): return id in selected_proofs)
		box.tooltip_text = L.text("ui.include_proof")
		box.disabled = finished
		row.add_child(box)
		box.toggled.connect(_toggle_proof_group.bind(ids))
		var revisit = _button(row, Presentation.title(observation), _review_proof_group.bind(group))
		revisit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		revisit.clip_text = true
		revisit.disabled = finished

func _toggle_proof_group(pressed: bool, ids: Array) -> void:
	for id in ids: _toggle_proof(pressed, str(id))

func _review_proof_group(group: Array) -> void:
	inspector_title.text = Presentation.title(group[0])
	var descriptions: Array[String] = []
	for observation in group:
		descriptions.append(Presentation.describe(observation, people))
	inspector_body.text = "\n\n".join(descriptions)

func _toggle_proof(pressed: bool, id: String) -> void:
	if pressed and id not in selected_proofs:
		selected_proofs.append(id)
	elif not pressed:
		selected_proofs.erase(id)

func _submit() -> void:
	if finished:
		return
	for choice in [culprit_choice, motive_choice, method_choice]:
		if choice.selected == 0:
			_set_text(status, "ui.incomplete_report")
			return
	var accusation = {"culprit": culprit_choice.get_item_metadata(culprit_choice.selected),
		"motive": motive_choice.get_item_metadata(motive_choice.selected),
		"method": method_choice.get_item_metadata(method_choice.selected), "evidence_ids": selected_proofs.duplicate()}
	var verdict: Dictionary = session.submit(accusation, debug_toggle.button_pressed)
	_clear(conversation_actions)
	_last_verdict = verdict
	finished = true
	inspector_title.text = L.text("ui.verdict")
	inspector_body.text = Presentation.verdict_text(verdict, people)
	for choice in [culprit_choice, motive_choice, method_choice]:
		choice.disabled = true
	submit_button.disabled = true
	debug_toggle.disabled = true
	for container in [room_list, object_list]:
		for button in container.get_children():
			if button is Button:
				button.disabled = true
	for row in discovery_list.get_children():
		for control in row.get_children():
			if control is BaseButton:
				control.disabled = true
	_set_text(status, "ui.finished")

func _set_text(control: Control, key: String, parameters: Dictionary = {}) -> void:
	if L.has_key(key):
		control.set_meta("text_key", key)
		control.set_meta("text_parameters", parameters.duplicate(true))
	control.set("text", L.text(key, parameters))

func _refresh_rooms() -> void:
	_clear(room_list)
	for location in session.locations():
		var title = L.text(location.name_key)
		if not location.accessible:
			title = L.text("ui.closed_location", {"name": title})
		var button = _button(room_list, title, _show_room.bind(location.id))
		button.disabled = finished or not location.accessible

func _change_language(index: int) -> void:
	var conversation_person = _conversation_id
	var previous_inspection = _inspected_id
	var previous_dialogue_mode = _dialogue_mode
	var previous_dialogue_proof = _dialogue_proof
	language_choice.selected = index
	L.set_locale(language_choice.get_item_metadata(index))
	_refresh_static_text(self)
	get_window().title = L.text("ui.window_title")
	seed_input.placeholder_text = L.text("ui.case_number")
	debug_toggle.tooltip_text = L.text("ui.debug_tooltip")
	for choice in [motive_choice, method_choice]:
		choice.set_item_text(0, L.text("ui.choose"))
		for item in range(1, choice.item_count):
			choice.set_item_text(item, Presentation.word(choice.get_item_metadata(item)))
	culprit_choice.set_item_text(0, L.text("ui.choose"))
	for item in range(1, culprit_choice.item_count):
		var id: String = culprit_choice.get_item_metadata(item)
		for character in people:
			if character.id == id:
				culprit_choice.set_item_text(item, Presentation.person(id, people) + " · " + L.text("role." + character.role))
	_refresh_rooms()
	if _current_room != "":
		_show_room(_current_room)
	else:
		room_title.text = L.text("ui.items")
	_refresh_discoveries()
	if conversation_person != "" and not finished:
		_talk(conversation_person)
		if previous_dialogue_mode == "introduced": _present_proof(conversation_person, previous_dialogue_proof)
		_inspected_id = previous_inspection
	if not _last_verdict.is_empty():
		inspector_title.text = L.text("ui.verdict")
		inspector_body.text = Presentation.verdict_text(_last_verdict, people)
	elif _inspected_id != "":
		for observation in session.discoveries():
			if observation.id == _inspected_id:
				inspector_title.text = Presentation.title(observation)
				inspector_body.text = Presentation.word(observation.kind) + "\n\n" + Presentation.describe(observation, people)
	elif conversation_person == "" or finished:
		inspector_title.text = L.text("ui.intro_title")
		inspector_body.text = L.text("ui.intro", {"place": L.text("location." + session.briefing().discovery_location)})
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())

func _refresh_static_text(node: Node) -> void:
	if node.has_meta("text_key"):
		node.set("text", L.text(node.get_meta("text_key"), node.get_meta("text_parameters", {})))
	for child in node.get_children():
		_refresh_static_text(child)

func _talk(person_id: String) -> void:
	var response: Dictionary = session.dialogue(person_id)
	if response.is_empty(): return
	_conversation_id = person_id
	_dialogue_mode = "opening"
	_dialogue_proof = ""
	_inspected_id = ""
	inspector_title.text = Presentation.person(person_id, people)
	_render_dialogue(response)
	_set_text(status, "conversation.help")
	_clear(conversation_actions)
	var proof_row = HBoxContainer.new()
	conversation_actions.add_child(proof_row)
	conversation_proofs = OptionButton.new()
	conversation_proofs.fit_to_longest_item = false
	conversation_proofs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refresh_conversation_proofs()
	proof_row.add_child(conversation_proofs)
	_button(proof_row, "conversation.show", func():
		var id = str(conversation_proofs.get_item_metadata(conversation_proofs.selected))
		if id != "": _present_proof(person_id, id))
	_button(conversation_actions, "conversation.resume", func(): _talk(person_id))
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())

func _render_dialogue(response: Dictionary) -> void:
	_dialogue_fragments = response.fragments.duplicate(true)
	inspector_body.clear()
	var text = L.text(response.text_key)
	var expression = RegEx.new()
	expression.compile("\\{([a-z_]+)\\}")
	var offset = 0
	for match_result in expression.search_all(text):
		inspector_body.add_text(text.substr(offset, match_result.get_start() - offset))
		var key = match_result.get_string(1)
		if _dialogue_fragments.has(key):
			inspector_body.push_meta(key)
			inspector_body.add_text(L.text(_dialogue_fragments[key].text_key))
			inspector_body.pop()
		offset = match_result.get_end()
	inspector_body.add_text(text.substr(offset))

func _follow_dialogue(key: Variant) -> void:
	if not _dialogue_fragments.has(str(key)): return
	var fragment: Dictionary = _dialogue_fragments[str(key)]
	if fragment.action == "ask": _ask(_conversation_id, fragment.target)
	elif fragment.action == "clarify": _deepen_proof(_conversation_id, fragment.target)

func _ask(person_id: String, topic_id: String) -> void:
	var observation: Dictionary = session.ask(person_id, topic_id)
	if observation.is_empty(): return
	_inspected_id = topic_id
	_dialogue_mode = "answer"
	_dialogue_fragments = {}
	inspector_body.text = Presentation.describe(observation, people)
	_refresh_discoveries()
	_refresh_conversation_proofs()
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())

func _present_proof(person_id: String, evidence_id: String) -> void:
	var response: Dictionary = session.introduce_proof(person_id, evidence_id)
	if response.is_empty(): return
	_dialogue_mode = "introduced"
	_dialogue_proof = evidence_id
	_inspected_id = ""
	_render_dialogue(response)

func _deepen_proof(person_id: String, evidence_id: String) -> void:
	var observation: Dictionary = session.present_proof(person_id, evidence_id)
	if observation.is_empty(): return
	_inspected_id = evidence_id
	_dialogue_mode = "answer"
	_dialogue_fragments = {}
	inspector_body.text = Presentation.describe(observation, people)
	_refresh_discoveries()
	_refresh_conversation_proofs()
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())

func _refresh_conversation_proofs() -> void:
	if not is_instance_valid(conversation_proofs): return
	conversation_proofs.clear()
	conversation_proofs.add_item(L.text("conversation.choose_proof"))
	conversation_proofs.set_item_metadata(0, "")
	for proof in session.discoveries():
		conversation_proofs.add_item(Presentation.title(proof))
		conversation_proofs.set_item_metadata(conversation_proofs.item_count - 1, proof.id)
