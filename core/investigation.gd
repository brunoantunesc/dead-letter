extends RefCounted
## Boundary between simulation and presentation. Discoveries do not modify case truth.

const Evaluator = preload("res://core/accusation_evaluator.gd")
const Validator = preload("res://core/case_validator.gd")
const BoardState = preload("res://core/investigation_board.gd")
var _data: Dictionary
var _discovered: Array = []
var _finished = false
var notes: Array = [] # Free hypotheses; never read by the evaluator.
var board = BoardState.new() # Player organization; not part of factual case data.
var _visited: Array = []
var _known_people: Dictionary = {}

func _init(data: Dictionary) -> void:
	_data = data.duplicate(true)
	visit_location(_data.entry_location)
	mention_character(_data.truth.victim) # Named in the initial briefing, never culprit.

func visit_location(id: String) -> bool:
	if (_finished and id not in _visited) or id not in Validator.reachable_locations(_data): return false
	if id not in _visited: _visited.append(id)
	return true

func visited_locations() -> Array:
	return locations().filter(func(room): return room.id in _visited)

func known_characters() -> Array:
	return characters().filter(func(person): return _known_people.has(person.id))

func mention_character(id: String) -> bool:
	return _know(id, "mention")

func record_conversation(id: String) -> bool:
	return _know(id, "conversation")

func _know(id: String, reason: String) -> bool:
	if not _data.characters.has(id): return false
	if not _known_people.has(id): _known_people[id] = []
	if reason not in _known_people[id]: _known_people[id].append(reason)
	return true

func _mentions(value: Variant) -> void:
	if value is Dictionary:
		for field in value:
			if field in ["person", "from_person", "to_person"] and value[field] is String:
				mention_character(value[field])
			elif value[field] is Array or value[field] is Dictionary: _mentions(value[field])
	elif value is Array:
		for entry in value: _mentions(entry)

func locations() -> Array:
	var result: Array = []
	for id in _data.locations:
		result.append({"id": id, "name_key": _data.locations[id].name_key,
			"accessible": _data.locations[id].accessible})
	return result

func characters() -> Array:
	var result: Array = []
	for id in _data.characters:
		var person: Dictionary = _data.characters[id]
		result.append({"id": id, "name": person.name, "name_key": person.get("name_key", ""), "role": person.role, "accusable": person.get("accusable", false)})
	return result

func inspect(evidence_id: String) -> Dictionary:
	if _finished or not _data.evidence.has(evidence_id):
		return {}
	var item: Dictionary = _data.evidence[evidence_id]
	if item.location not in Validator.reachable_locations(_data):
		return {}
	if evidence_id not in _discovered:
		_discovered.append(evidence_id)
	visit_location(item.location)
	_mentions(item.properties)
	if item.get("source_character", "") != "": mention_character(item.source_character)
	return _observation(item)

func objects_at(location_id: String) -> Array:
	var result: Array = []
	if location_id not in Validator.reachable_locations(_data):
		return result
	for item in _data.evidence.values():
		if item.location == location_id:
			result.append({"id": item.id, "definition_id": item.definition_id, "kind": item.kind})
	return result

func discoveries() -> Array:
	var result: Array = []
	for id in _discovered:
		result.append(_observation(_data.evidence[id]))
	return result

func submit(accusation: Dictionary, debug_feedback: bool = false) -> Dictionary:
	if _finished:
		return {"error": "investigation_finished"}
	_finished = true
	var evaluation = Evaluator.evaluate(_data, accusation, _discovered)
	var result = {"outcome": evaluation.outcome}
	if debug_feedback:
		result["debug"] = {"evaluation": evaluation, "truth": _data.truth.duplicate(true)}
	return result

func _observation(item: Dictionary) -> Dictionary:
	# Explicit allowlist: no origins, relevance, weights or hidden facts escape here.
	return {"id": item.id, "kind": item.kind, "location": item.location,
		"definition_id": item.definition_id, "properties": item.properties.duplicate(true)}
