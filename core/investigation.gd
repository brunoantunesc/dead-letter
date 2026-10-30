extends RefCounted
## Boundary between simulation and presentation. Discoveries do not modify case truth.

const Evaluator = preload("res://core/accusation_evaluator.gd")
const Validator = preload("res://core/case_validator.gd")
var _data: Dictionary
var _discovered: Array = []
var _finished = false
var notes: Array = [] # Free hypotheses; never read by the evaluator.

func _init(data: Dictionary) -> void:
	_data = data.duplicate(true)

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
