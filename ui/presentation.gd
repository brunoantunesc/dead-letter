extends RefCounted
## Data-only evidence templates; changing language never changes the case.
const Catalog = preload("res://core/evidence_catalog.gd")
const L = preload("res://ui/localization.gd")

static func word(value: String) -> String:
	return L.text("term." + value)

static func person(id: String, people: Array) -> String:
	for character in people:
		if character.id == id:
			return L.text(character.name_key) if character.get("name_key", "") != "" else character.name
	return id

static func title(observation: Dictionary) -> String:
	return L.text(Catalog.get_definition(observation.definition_id).title_key)

static func describe(observation: Dictionary, people: Array) -> String:
	var definition = Catalog.get_definition(observation.definition_id)
	var parameters = _parameters(definition.parameters, observation.properties, people)
	if definition.has("rows"):
		var rows: Array[String] = []
		for entry in observation.properties[definition.rows.field]:
			rows.append(L.text(definition.rows.text_key, _parameters(definition.rows.parameters, entry, people)))
		parameters[definition.rows.field] = "\n".join(rows)
	return L.text(definition.text_key, parameters)

static func _parameters(specifications: Dictionary, properties: Dictionary, people: Array) -> Dictionary:
	var result = {}
	for key in specifications:
		var spec: Dictionary = specifications[key]
		var value = properties.get(spec.field, "")
		match spec.format:
			"person": result[key] = person(str(value), people)
			"term": result[key] = word(str(value))
			"location": result[key] = L.text("location." + str(value))
			"time": result[key] = "%02d:%02d" % [int(value) / 60, int(value) % 60]
			_: result[key] = str(value)
	return result

static func verdict_text(result: Dictionary, people: Array) -> String:
	var text = L.text("verdict." + result.outcome + "_title") + "\n\n" + L.text("verdict." + result.outcome + "_body")
	if result.has("debug"):
		var truth: Dictionary = result.debug.truth
		var evaluation: Dictionary = result.debug.evaluation
		text += "\n\n" + L.text("verdict.debug", {"person": person(truth.culprit, people),
			"motive": word(truth.motive), "method": word(truth.method), "identity_score": evaluation.scores.culprit,
			"motive_score": evaluation.scores.motive, "method_score": evaluation.scores.method, "total": evaluation.total})
		for reason in evaluation.reasons:
			var parts: PackedStringArray = reason.split("_", true, 1)
			if parts.size() == 2:
				text += "\n" + L.text("verdict." + parts[0], {"claim": L.text("verdict.total") if parts[1] == "total" else word(parts[1])})
	return text
