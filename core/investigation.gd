extends RefCounted
## Boundary between simulation and presentation. Discoveries do not modify case truth.

const ConversationContent = preload("res://core/conversation_content.gd")
const Evaluator = preload("res://core/accusation_evaluator.gd")
const Validator = preload("res://core/case_validator.gd")
const BoardState = preload("res://core/investigation_board.gd")
var _data: Dictionary
var _discovered: Array = []
var _finished = false
var _clarified: Array = []
var _introduced: Dictionary = {}
var board = BoardState.new() # Player organization; not part of factual case data.
var _visited: Array = []
var _current_location = ""
var _known_people: Dictionary = {}

func _init(data: Dictionary) -> void:
	_data = data.duplicate(true)
	visit_location(_data.entry_location)
	mention_character(_data.truth.victim) # Named in the initial briefing, never culprit.

func visit_location(id: String) -> bool:
	if (_finished and id not in _visited) or id not in Validator.reachable_locations(_data): return false
	_current_location = id
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

func briefing() -> Dictionary:
	var discovery: Dictionary = _data.events.get("body_discovery", {})
	return {"discovery_location": discovery.get("location", ""), "autopsy_status": "pending"}

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
	if item.kind == "testimony": return {}
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
		if item.location == location_id and item.kind != "testimony":
			result.append({"id": item.id, "definition_id": item.definition_id, "kind": item.kind, "needs_clarification": item.properties.get("observation_type") == "incident", "title_token": item.properties.get("detail_token", "")})
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
		# Explicit post-verdict opt-in only. Never add this index to live discoveries.
		var evidence_index = {}
		for id in _data.evidence:
			var observation = _observation(_data.evidence[id])
			observation["discovered"] = id in _discovered
			observation["presented"] = id in evaluation.selected_evidence
			evidence_index[id] = observation
		result.debug["evidence"] = evidence_index
	return result

func _observation(item: Dictionary) -> Dictionary:
	# Explicit allowlist: no origins, relevance, weights or hidden facts escape here.
	return {"id": item.id, "kind": item.kind, "location": item.location,
		"definition_id": item.definition_id, "properties": item.properties.duplicate(true),
		"prose_index": (str(_data.seed) + "|" + str(item.id) + "|prose").hash(),
		"needs_clarification": item.properties.get("observation_type") == "incident", "clarified": item.id in _clarified}

func characters_at(location_id: String) -> Array:
	if location_id != _current_location: return []
	var result: Array = []
	for person in characters():
		var private_person: Dictionary = _data.characters[person.id]
		if private_person.get("current_location", "") == location_id and person.id != "victim":
			mention_character(person.id)
			result.append(person)
	return result

func begin_conversation(person_id: String) -> Dictionary:
	if _finished or not _data.characters.has(person_id): return {}
	var person: Dictionary = _data.characters[person_id]
	if person.get("current_location", "") == "" or person.current_location != _current_location: return {}
	record_conversation(person_id)
	return {"person_id": person_id, "location": person.current_location, "reason_key": person.location_reason_key}

func conversation_topics(person_id: String) -> Array:
	if begin_conversation(person_id).is_empty(): return []
	var topics: Array = []
	for item in _data.evidence.values():
		if item.kind == "testimony" and item.get("source_character", "") == person_id and item.event_id in _data.characters[person_id].known_events:
			topics.append({"id": item.id, "definition_id": item.definition_id})
	return topics

func ask(person_id: String, topic_id: String) -> Dictionary:
	if not conversation_topics(person_id).any(func(topic): return topic.id == topic_id): return {}
	var item: Dictionary = _data.evidence[topic_id]
	if topic_id not in _discovered: _discovered.append(topic_id)
	_mentions(item.properties)
	return _observation(item)

func related_proofs(person_id: String) -> Array:
	if begin_conversation(person_id).is_empty(): return []
	var result: Array = []
	for id in _discovered:
		var item: Dictionary = _data.evidence[id]
		if item.properties.get("observation_type") == "incident" and item.properties.get("person") == person_id and item.event_id in _data.characters[person_id].known_events:
			result.append(_observation(item))
	return result

func present_proof(person_id: String, evidence_id: String) -> Dictionary:
	if evidence_id not in _introduced.get(person_id, []) or not related_proofs(person_id).any(func(item): return item.id == evidence_id): return {}
	if evidence_id not in _clarified: _clarified.append(evidence_id)
	return _observation(_data.evidence[evidence_id])

func dialogue(person_id: String) -> Dictionary:
	var context = begin_conversation(person_id)
	if context.is_empty(): return {}
	var response: Dictionary = ConversationContent.OPENINGS.get(person_id, ConversationContent.DEFAULT_OPENING).duplicate(true)
	var topics = conversation_topics(person_id)
	for key in response.fragments.keys():
		var fragment: Dictionary = response.fragments[key]
		var matches = topics.filter(func(topic): return topic.definition_id == fragment.definition_id)
		if matches.is_empty():
			response.fragments.erase(key)
		else:
			fragment["target"] = matches[0].id
			fragment["action"] = "ask"
	return response

func introduce_proof(person_id: String, evidence_id: String) -> Dictionary:
	if begin_conversation(person_id).is_empty() or evidence_id not in _discovered: return {}
	if not related_proofs(person_id).any(func(item): return item.id == evidence_id):
		# Stable per case/speaker/proof; independent from guilt and the generator RNG.
		var index = (str(_data.seed) + "|" + person_id + "|" + evidence_id).hash() % ConversationContent.NO_RESPONSE_KEYS.size()
		return {"text_key": ConversationContent.NO_RESPONSE_KEYS[index], "fragments": {}}
	if not _introduced.has(person_id): _introduced[person_id] = []
	if evidence_id not in _introduced[person_id]: _introduced[person_id].append(evidence_id)
	var response = ConversationContent.INCIDENT_RESPONSE.duplicate(true)
	response.fragments.task["target"] = evidence_id
	return response
