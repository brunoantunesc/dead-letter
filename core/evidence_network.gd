extends RefCounted
## Internal scoped arguments. Never exposed as automatic player connections.
const Catalog = preload("res://core/evidence_catalog.gd")

static func derive(data: Dictionary) -> Array:
	var attacks: Array = []
	var ids: Array = data.evidence.keys()
	ids.sort()
	var by_definition = {}
	for id in ids:
		var item: Dictionary = data.evidence[id]
		if not by_definition.has(item.definition_id):
			by_definition[item.definition_id] = []
		by_definition[item.definition_id].append(item)
	for relation in Catalog.CATALOG.relations:
		for source in by_definition.get(relation.source_definition_id, []):
			var source_id: String = source.id
			for target in by_definition.get(relation.target_definition_id, []):
				var target_id: String = target.id
				if source_id == target_id:
					continue
				var contexts: Array = [{}]
				if relation.context_definition_id != "":
					contexts = by_definition.get(relation.context_definition_id, [])
				for sr in _rows(source, relation.source_rows):
					for tr in _rows(target, relation.target_rows):
						for context in contexts:
							var frame = {"source": source, "target": target, "source_row": sr, "target_row": tr,
								"source_event": data.events.get(source.event_id, {}),
								"target_event": data.events.get(target.event_id, {}), "context": context}
							if not _matches(relation, frame):
								continue
							var subject = str(read(frame, relation.subject_field)) if relation.subject_field != "" else ""
							var attack = {"relation_id": relation.id, "source": source_id, "target": target_id,
								"source_claim": relation.source_claim_id, "target_claim": relation.target_claim_id,
								"subject": subject, "context": context.get("id", "")}
							if attack not in attacks:
								attacks.append(attack)
	return attacks

static func _rows(item: Dictionary, field: String) -> Array:
	return item.properties.get(field, []) if field != "" else [{}]

static func read(frame: Dictionary, path: String) -> Variant:
	var value: Variant = frame
	for field in path.split("."):
		if not value is Dictionary or not value.has(field):
			return null
		value = value[field]
	return value

static func _matches(relation: Resource, frame: Dictionary) -> bool:
	for source in relation.equal_fields:
		var a = read(frame, "source.properties." + source)
		var b = read(frame, "target.properties." + relation.equal_fields[source])
		if a == null or b == null or a != b:
			return false
	for condition in relation.conditions:
		var left = read(frame, condition.left)
		var right = read(frame, condition.right) if condition.has("right") else condition.get("value")
		if left == null or right == null:
			return false
		match condition.op:
			"eq":
				if left != right: return false
			"ne":
				if left == right: return false
			"lt", "lte", "gt", "gte":
				if typeof(left) not in [TYPE_INT, TYPE_FLOAT] or typeof(right) not in [TYPE_INT, TYPE_FLOAT]: return false
				if condition.op == "lt" and not left < right: return false
				if condition.op == "lte" and not left <= right: return false
				if condition.op == "gt" and not left > right: return false
				if condition.op == "gte" and not left >= right: return false
			_: return false
	return true

static func resolve(attacks: Array) -> Dictionary:
	var states = {}
	var active: Array = []
	var unresolved: Array = []
	for i in attacks.size():
		var status = _status(i, attacks, states, {})
		if status == 1: active.append(attacks[i])
		elif status == -1: unresolved.append(attacks[i])
	return {"active": active, "unresolved": unresolved}

static func _status(index: int, attacks: Array, states: Dictionary, visiting: Dictionary) -> int:
	if states.has(index):
		return states[index]
	if visiting.has(index):
		return -1
	visiting[index] = true
	var attack: Dictionary = attacks[index]
	var unknown = false
	var status = 1
	for other in attacks.size():
		var counter: Dictionary = attacks[other]
		if counter.target != attack.source or counter.target_claim != attack.source_claim:
			continue
		if counter.subject != "" and attack.subject != "" and counter.subject != attack.subject:
			continue
		var counter_status = _status(other, attacks, states, visiting)
		if counter_status == 1:
			status = 0
			break
		if counter_status == -1:
			unknown = true
	visiting.erase(index)
	if status != 0 and unknown:
		return -1
	states[index] = status
	return status
