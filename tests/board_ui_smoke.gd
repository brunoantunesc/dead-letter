extends SceneTree
const Generator = preload("res://core/case_generator.gd")
const PresentationCatalog = preload("res://core/evidence_catalog.gd")
const Localization = preload("res://ui/localization.gd")
const Data = preload("res://core/case_data.gd")
var checks = 0
var failures: Array = []

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var desk = load("res://ui/main.tscn").instantiate()
	root.add_child(desk)
	await process_frame
	await process_frame
	desk.seed_input.text = "42"
	desk._open_seed()
	var board = desk.board
	var state = board.model
	check(state == desk.session.board, "session owns board state independently of the view")
	check(not board.visible and state.links.is_empty(), "board begins closed and unconnected")
	board.open_board()
	await process_frame
	await process_frame
	await process_frame
	check(board.visible and board.canvas.widgets.is_empty() and state.cards.size() == 2, "empty canvas with only two cards in pile")
	await _capture("board_pile")
	var data: Dictionary = Generator.new().generate(42).case
	var original = Data.encode(data)
	var weapon = ""
	for item in data.evidence.values():
		if item.kind == "object" and item.properties.weapon == data.truth.weapon:
			weapon = item.id
	for id in ["contact", "wardrobe", "sighting_0", "time_record", "scene_trace", "conflict_0_record", weapon]:
		if id.begins_with("sighting_"):
			desk._show_room("lobby")
			desk._talk("porter")
			desk._ask("porter", id)
		else:
			desk._inspect(id)
	desk.selected_proofs.assign(["contact", "wardrobe", "sighting_0", "time_record", "scene_trace", "conflict_0_record", weapon])
	check(not state.cards.has("evidence:" + weapon) and state.cards.has("object:" + data.evidence[weapon].properties.object_id), "physical clue has only one card")
	check(desk.discovery_list.get_child_count() == desk.session.discoveries().size(), "report lists each discovered proof once")
	var evidence_id = "evidence:contact"
	check(board.canvas.widgets.is_empty(), "new discoveries do not auto-place cards")
	board._select_card(evidence_id)
	board._place_selected()
	check(state.cards[evidence_id].placed and board.canvas.widgets.size() == 1, "player places a card from pile")
	board._stash_selected()
	check(not state.cards[evidence_id].placed and board.canvas.widgets.is_empty(), "returning card to pile hides it")
	board._place_selected()
	check(state.cards[evidence_id].placed and board.canvas.widgets.size() == 1, "card can be placed again")
	var slot = 0
	for id in state.cards:
		state.place_card(id, Vector2(40 + (slot % 3) * 246, 40 + (slot / 3) * 156))
		slot += 1
	var position = Vector2(140, 160)
	state.move_card(evidence_id, position)
	board.refresh()
	board._select_card(evidence_id)
	board.canvas.focus_card(evidence_id)
	await process_frame
	var start: Vector2 = board.canvas.widgets[evidence_id].get_global_rect().position + Vector2(30, 24)
	_mouse_button(start, true)
	await process_frame
	var motion = InputEventMouseMotion.new()
	motion.position = start + Vector2(72, 32)
	motion.global_position = motion.position
	motion.relative = Vector2(72, 32)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	_mouse_button(motion.position, false)
	await process_frame
	check(state.cards[evidence_id].position != position, "mouse drag moves the actual rendered card")
	check(state.cards[evidence_id].position.is_equal_approx(position + Vector2(72, 32) / board.canvas.zoom), "drag distance accounts for canvas zoom")
	position = state.cards[evidence_id].position
	board._toggle_connect()
	board._select_card(evidence_id)
	board._select_card("person:person_1")
	check(state.links.size() == 1, "connect mode creates manual hypothesis")
	var link: String = state.links.keys()[0]
	board.marker.select(1)
	board.link_text.text = "Será que esse horário confere?"
	board._edit_link()
	check(state.links[link].mark == "?" and state.links[link].text == "Será que esse horário confere?", "connection marking and free label editable")
	board._add_note()
	var note: String = board.selected_card
	board.note_text.text = "Talvez seja coincidência.\nComparar os registros."
	board._edit_note()
	state.move_card(note, Vector2(430, 350))
	board._select_card("room:salon")
	check(board.detail_title.text == "Salão", "room card has localized known identity")
	board._toggle_connect()
	board._select_card(note)
	board._select_card("room:salon")
	var note_link: String = board.selected_link
	board.marker.select(2)
	board.link_text.text = "Não faz sentido?"
	board._edit_link()
	check(state.links[note_link].mark == "X", "X is player-authored")
	var hypothesis = state.links.duplicate(true)
	var selected: Array = desk.selected_proofs.duplicate()
	board.hide()
	board.open_board()
	check(board.model == state and state.cards[evidence_id].position == position and state.links == hypothesis, "close/reopen preserves board")
	# Deliberate player arrangement for visual review; never applied by production.
	var index = 0
	for id in state.cards:
		state.move_card(id, Vector2(40 + (index % 3) * 246, 940 + (index / 3) * 156))
		index += 1
	state.move_card(evidence_id, Vector2(40, 250))
	state.move_card("person:person_1", Vector2(40, 10))
	state.move_card("evidence:wardrobe", Vector2(390, 250))
	state.move_card("object:" + data.evidence[weapon].properties.object_id, Vector2(390, 10))
	state.move_card(note, Vector2(390, 490))
	state.move_card("room:salon", Vector2(750, 490))
	board.canvas.zoom = 0.8
	board.canvas.pan = Vector2(28, 42)
	board.canvas._layout()
	board._select_card(evidence_id)
	await _capture("board_evidence")
	board.canvas.widgets[evidence_id].get_node("OpenClue").pressed.emit()
	await process_frame
	check(board.clue_window.visible and board.clue_body.text.contains(board.labels[evidence_id].body), "card icon opens full public clue")
	await _capture("board_clue")
	board.clue_window.hide()
	for locale_index in [0, 1]:
		desk._change_language(locale_index)
		for definition in PresentationCatalog.definitions().values():
			var key = str(definition.title_key).trim_suffix(".title") + ".short"
			var text = Localization.text(key)
			check(text != key and board.get_theme_default_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x <= 192, "short clue title fits: " + key)
	desk._change_language(0)
	desk._change_language(1)
	check(board.detail_title.text == "Fibres preserved at the scene", "selected evidence changes language")
	check(state.links == hypothesis and state.cards[note].text.begins_with("Talvez"), "language does not rewrite hypotheses")
	check(desk.selected_proofs == selected and desk.session.discoveries().size() == 7, "board preserves explicit accusation and discoveries")
	check(Data.encode(Generator.new().generate(42).case) == original, "board does not affect deterministic truth")
	board._select_link(link)
	await _capture("board_connection")
	desk._change_language(0)
	# Drag into the fixed bin using actual mouse events, including a note with links.
	board.canvas.focus_card(note)
	await process_frame
	var note_position: Vector2 = state.cards[note].position
	var drag_start: Vector2 = board.canvas.widgets[note].get_global_rect().position + Vector2(30, 24)
	var drop: Vector2 = board.canvas.get_global_transform_with_canvas() * board.canvas.trash_rect().get_center()
	_mouse_button(drag_start, true)
	await process_frame
	var trash_motion = InputEventMouseMotion.new()
	trash_motion.position = drop
	trash_motion.global_position = drop
	trash_motion.relative = drop - drag_start
	trash_motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(trash_motion)
	await process_frame
	check(board.canvas._trash_hover, "bin highlights while dragging over it")
	await _capture("board_trash")
	_mouse_button(drop, false)
	await process_frame
	await process_frame
	check(not state.cards[note].placed and not board.canvas.widgets.has(note), "dropping note in bin returns it to pile")
	check(state.cards[note].position == note_position and state.links.has(note_link) and state.cards[note].text.begins_with("Talvez"), "bin preserves original position, note and connections")
	board._select_card(note)
	board._place_selected()
	check(state.cards[note].placed and state.links.has(note_link), "binned card can be restored with connections")
	board._select_link(note_link)
	board._remove_selected()
	check(not state.links.has(note_link), "remove connection through UI")
	board._select_card(note)
	board._remove_selected()
	check(not state.cards.has(note), "remove note through UI")
	board.hide()
	desk.culprit_choice.select(1)
	desk.motive_choice.select(2)
	desk.method_choice.select(1)
	desk.debug_toggle.button_pressed = false
	desk._submit()
	check(desk.inspector_body.text.contains("CASO SUSTENTADO"), "wrong manual connection does not change verdict")
	desk._open_seed()
	check(board.model != state and board.model.links.is_empty() and board.model.cards.size() == 2 and board.canvas.widgets.is_empty(), "new run clears previous board")
	print("Board UI checks: %d; failures: %d" % [checks, failures.size()])
	FileAccess.open("res://tests/results/board_ui.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks, "failures": failures}, "\t"))
	quit(0 if failures.is_empty() else 1)

func _capture(filename: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/results/" + filename + ".png")

func _mouse_button(point: Vector2, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	Input.parse_input_event(event)
