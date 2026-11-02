extends SceneTree
## Real scene workflow smoke check; run without --headless to capture rendered frames.
var failures: Array = []

func check(condition: bool, label: String) -> void:
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
	check(desk.session.discoveries().is_empty(), "UI starts with no discoveries")
	check(not desk.inspector_body.text.contains("Força das provas"), "no score during investigation")
	await _capture("desk_initial")
	desk._show_room("salon", "Salão")
	desk.object_list.get_child(0).pressed.emit()
	check(desk.session.discoveries().size() == 1, "object button discovers only one object")
	var needed: Array = ["contact", "wardrobe", "sighting_0", "time_record", "scene_trace", "conflict_0_record"]
	var data: Dictionary = load("res://core/case_generator.gd").new().generate(42).case
	for item in data.evidence.values():
		if item.properties.observation_type == "object" and item.properties.weapon == data.truth.weapon:
			needed.append(item.id)
	for id in needed:
		if id.begins_with("sighting_"):
			desk._show_room("lobby")
			desk._talk("porter")
			desk._ask("porter", id)
		else:
			desk._inspect(id)
	for row in desk.discovery_list.get_children():
		var checkbox = row.get_child(0)
		checkbox.button_pressed = true
	check(desk.selected_proofs.size() == needed.size(), "proof checkboxes feed comparative accusation")
	desk.culprit_choice.select(1) # Seed 42: Ana.
	desk.motive_choice.select(2) # Ciúme.
	desk.method_choice.select(1) # Esfaqueamento.
	var note_id: String = desk.session.board.add_note(Vector2(40, 40))
	desk.session.board.edit_note(note_id, "Conferir os registros de horário e comparar as amostras com as fichas de roupas.")
	desk._inspect("wardrobe")
	await process_frame
	await _capture("desk_investigation")
	var session_before = desk.session
	var discoveries_before: Array = desk.session.discoveries()
	var proofs_before: Array = desk.selected_proofs.duplicate()
	var notes_before: String = desk.session.board.cards[note_id].text
	desk._change_language(1)
	check(desk.inspector_title.text == "Returned garment records", "evidence title changes to English")
	check(desk.inspector_body.text.contains("before dinner"), "evidence description changes to English")
	check(desk.session == session_before and desk.session.discoveries() == discoveries_before, "locale switch preserves session and discoveries")
	check(desk.selected_proofs == proofs_before and desk.session.board.cards[note_id].text == notes_before, "locale switch preserves selected proof and player notes")
	check(desk.culprit_choice.selected == 1 and desk.motive_choice.selected == 2 and desk.method_choice.selected == 1, "locale switch preserves accusation choices")
	await _capture("desk_english")
	desk._change_language(0)
	desk.submit_button.pressed.emit()
	check(desk.finished and desk.submit_button.disabled, "submission ends UI session")
	check(desk.inspector_body.text.contains("CASO SUSTENTADO"), "UI can win by presenting proofs")
	check(desk.inspector_body.text.contains("DIAGNÓSTICO"), "post-verdict debug visible")
	desk._change_language(1)
	check(desk.inspector_body.text.contains("CASE SUBSTANTIATED") and desk.finished and desk.submit_button.disabled, "verdict can change language without reopening case")
	desk._change_language(0)
	await _capture("desk_verdict")
	desk._open_seed()
	check(not desk.finished and desk.selected_proofs.is_empty(), "restart clears previous run")
	desk.culprit_choice.select(2)
	desk.motive_choice.select(1)
	desk.method_choice.select(1)
	desk.debug_toggle.button_pressed = false
	desk.submit_button.pressed.emit()
	check(desk.inspector_body.text.contains("ACUSAÇÃO INCORRETA") and not desk.inspector_body.text.contains("DIAGNÓSTICO"), "wrong culprit without debug")
	desk._open_seed()
	desk.culprit_choice.select(1)
	desk.motive_choice.select(2)
	desk.method_choice.select(1)
	desk.submit_button.pressed.emit()
	check(desk.inspector_body.text.contains("CASO INSUFICIENTE"), "correct answer without proofs fails")
	desk.seed_input.text = "inválida"
	desk._open_seed()
	check(desk.status.text.contains("inteiro"), "invalid seed reported")
	desk.seed_input.text = "914368"
	desk._open_seed()
	var listed = 0
	for location in desk.session.locations():
		listed += desk.session.objects_at(location.id).size()
	check(listed == 13, "reported seed has thirteen physical observations plus two conversational accounts")
	await _capture("desk_short_initial")
	desk._show_room("lobby", "Recepção")
	desk._inspect("activity_register")
	check(desk.session.discoveries().size() == 1, "consolidated register is one discovery")
	await _capture("desk_short_register")
	print("UI workflow failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)

func _capture(filename: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	image.save_png("res://tests/results/" + filename + ".png")
