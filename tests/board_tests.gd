extends SceneTree
const Board = preload("res://core/investigation_board.gd")
const Generator = preload("res://core/case_generator.gd")
const Investigation = preload("res://core/investigation.gd")
const Data = preload("res://core/case_data.gd")
var checks = 0
var failures: Array = []

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	var data: Dictionary = Generator.new().generate(914368).case
	var original = Data.encode(data)
	var session = Investigation.new(data)
	var board = Board.new()
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	check(board.cards.size() == 2, "only briefing victim and entry room initially available")
	check(_count(board, "evidence") == 0 and _count(board, "object") == 0, "undiscovered evidence and objects absent")
	check(board.links.is_empty(), "no automatic associations")
	session.inspect("routine_checkout")
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	check(_count(board, "evidence") == 1 and _count(board, "object") == 0, "object mentioned in document is not a found object")
	var found: Dictionary = {}
	for item in data.evidence.values():
		if item.kind == "object":
			found = session.inspect(item.id)
			break
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	var physical_id = "object:" + str(found.properties.object_id)
	var evidence_id = "evidence:" + str(found.id)
	check(board.cards.has(physical_id) and board.cards.has(evidence_id), "physical object and observation have separate cards")
	check(board.links.is_empty(), "finding object does not draw a connection")
	check(session.visited_locations().size() >= 1 and not session.visited_locations().any(func(room): return room.id == "archive"), "unvisited rooms absent")
	check(session.record_conversation("person_1") and session.known_characters().any(func(person): return person.id == "person_1"), "conversation registers known person")
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	var count = board.cards.size()
	session.inspect(found.id)
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	check(board.cards.size() == count, "reinspection never duplicates cards")
	var repeated_entity = found.duplicate(true)
	repeated_entity.id = "another_observation"
	board.sync([], [], [repeated_entity])
	check(_count(board, "object") == 1 and board.cards.has("evidence:another_observation"), "different observations share one physical object card")
	check(board.placed_cards().is_empty(), "discoveries enter pile, never canvas")
	check(board.connect_cards(physical_id, "person:victim") == "", "unplaced cards cannot form visible connections")
	board.place_card("person:victim", Vector2(100, 100))
	board.place_card(evidence_id, Vector2(400, 100))
	var position = Vector2(-450, 900)
	board.place_card(physical_id, position)
	board.move_card(physical_id, position)
	board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
	check(board.cards[physical_id].position == position, "sync preserves freely chosen negative positions")
	var note = board.add_note(Vector2(800, -300))
	board.edit_note(note, "E se eu estiver errado?\nNão ligar isso automaticamente.")
	check(board.cards[note].text.contains("errado"), "free note accepts arbitrary interpretation")
	var link = board.connect_cards(physical_id, "person:victim")
	check(link != "" and board.connect_cards("person:victim", physical_id) == link, "manual cross-type association has stable identity")
	for mark in ["?", "X", ""]:
		board.edit_link(link, mark, "Hipótese propositalmente errada")
		check(board.links[link].mark == mark, "manual marker " + mark)
	board.edit_link(link, "automatic_truth", "bad")
	check(board.links[link].mark == "", "only supported visual markers accepted")
	check(board.connect_cards("unknown", note) == "" and board.connect_cards(note, note) == "", "invalid geometric endpoints rejected")
	var note_link = board.connect_cards(note, evidence_id)
	check(note_link != "", "note can connect to evidence")
	check(not board.remove_note(physical_id), "note deletion cannot erase known physical entity")
	check(board.remove_note(note) and not board.links.has(note_link), "removing note removes dangling connections")
	board.unplace_card(physical_id)
	check(board.links.has(link) and not board.cards[physical_id].placed, "stashing preserves authored link")
	board.place_card(physical_id, position)
	check(board.links.has(link), "returning card restores association")
	board.remove_link(link)
	check(board.links.is_empty(), "manual connection removable")
	check(Data.encode(data) == original, "arrangement and hypotheses never modify causal truth")
	check(session.discoveries().size() == 2, "board actions never discover evidence")
	var other_run = Board.new()
	check(other_run.cards.is_empty() and other_run.links.is_empty(), "new board has no previous hypotheses")
	# Unknown entries must not be inferred from missing references in known facts.
	var restricted = Board.new()
	restricted.sync([session.characters()[0]], [session.locations()[0]], [])
	check(restricted.cards.size() == 2, "only supplied public roster/locations enter board")
	FileAccess.open("res://tests/results/board.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks, "failures": failures}, "\t"))
	print("Board checks: %d; failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _count(board: RefCounted, kind: String) -> int:
	return board.cards.values().filter(func(card): return card.kind == kind).size()
