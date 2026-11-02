extends RefCounted
## Player-authored organization only. Receives public knowledge, never case truth.
var cards: Dictionary = {}
var links: Dictionary = {}
var _next_note = 1
var _next_link = 1

func sync(people: Array, rooms: Array, discoveries: Array) -> void:
	for person in people:
		_add("person", str(person.id))
	for room in rooms:
		_add("room", str(room.id))
	for observation in discoveries:
		# A mention inside a document does not discover its physical object.
		if observation.kind == "object":
			var object_id: String = str(observation.properties.get("object_id", observation.id))
			var id = _add("object", object_id, str(observation.id))
			if observation.id not in cards[id].evidence_ids:
				cards[id].evidence_ids.append(observation.id)
		else:
			_add("evidence", str(observation.id))

func _add(kind: String, reference: String, evidence_id: String = "") -> String:
	var id = kind + ":" + reference
	if not cards.has(id):
		cards[id] = {"id": id, "kind": kind, "reference": reference,
			"evidence_id": evidence_id, "evidence_ids": [], "position": Vector2.ZERO, "text": "", "placed": false, "was_placed": false}
	return id

func place_card(id: String, position: Vector2) -> void:
	if cards.has(id) and position.is_finite():
		cards[id].placed = true
		cards[id].was_placed = true
		cards[id].position = position

func unplace_card(id: String) -> void:
	if not cards.has(id): return
	cards[id].placed = false

func placed_cards() -> Dictionary:
	var result = {}
	for id in cards:
		if cards[id].placed: result[id] = cards[id]
	return result

func add_note(position: Vector2) -> String:
	var id = _add("note", str(_next_note))
	_next_note += 1
	place_card(id, position)
	return id

func move_card(id: String, position: Vector2) -> void:
	if cards.has(id) and position.is_finite():
		cards[id].position = position

func edit_note(id: String, text: String) -> void:
	if cards.has(id) and cards[id].kind == "note":
		cards[id].text = text

func remove_note(id: String) -> bool:
	if not cards.has(id) or cards[id].kind != "note":
		return false
	cards.erase(id)
	for link_id in links.keys():
		if links[link_id].from == id or links[link_id].to == id:
			links.erase(link_id)
	return true

func connect_cards(from: String, to: String) -> String:
	if from == to or not cards.has(from) or not cards.has(to):
		return ""
	if not cards[from].placed or not cards[to].placed:
		return ""
	# One undirected connection per pair. Selecting it permits edits.
	for id in links:
		if [links[id].from, links[id].to].has(from) and [links[id].from, links[id].to].has(to):
			return id
	var id = "link:" + str(_next_link)
	_next_link += 1
	links[id] = {"id": id, "from": from, "to": to, "mark": "", "text": ""}
	return id

func edit_link(id: String, mark: String, text: String) -> void:
	if links.has(id) and mark in ["", "?", "X"]:
		links[id].mark = mark
		links[id].text = text

func remove_link(id: String) -> void:
	links.erase(id)
