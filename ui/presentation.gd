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
	if observation.get("needs_clarification", false): return L.text("conversation.incident_title")
	var definition = Catalog.get_definition(observation.definition_id)
	var names = _observable_names(observation, definition)
	return L.text(names.get("title_key", definition.title_key))

static func short_title(observation: Dictionary) -> String:
	if observation.get("needs_clarification", false): return L.text("evidence.object_use_record.short")
	var definition = Catalog.get_definition(observation.definition_id)
	var names = _observable_names(observation, definition)
	return L.text(names.get("short_key", str(definition.title_key).trim_suffix(".title") + ".short"))

static func _observable_names(observation: Dictionary, definition: Dictionary) -> Dictionary:
	var token = observation.get("title_token", observation.get("properties", {}).get("detail_token", ""))
	return definition.get("observable_titles", {}).get(token, {})

static func describe(observation: Dictionary, people: Array) -> String:
	var definition = Catalog.get_definition(observation.definition_id)
	var parameters = _parameters(definition.parameters, observation.properties, people)
	if definition.has("rows"):
		var rows: Array[String] = []
		for entry in observation.properties[definition.rows.field]:
			rows.append(L.text(definition.rows.text_key, _parameters(definition.rows.parameters, entry, people)))
		parameters[definition.rows.field] = "\n".join(rows)
	var full_text = L.text(_prose_key(definition.text_key, definition.get("text_variants", []), observation), parameters)
	if observation.get("needs_clarification", false):
		var initial = L.text(_prose_key("conversation.incident_initial", definition.get("initial_text_variants", []), observation), {"person": person(str(observation.properties.person), people), "weapon": word(str(observation.properties.weapon)), "time": "%02d:%02d" % [int(observation.properties.time) / 60, int(observation.properties.time) % 60]})
		return initial + ("\n\n" + L.text("conversation.explanation", {"person": person(str(observation.properties.person), people)}) + "\n" + full_text if observation.get("clarified", false) else "")
	return full_text

static func _prose_key(base_key: String, alternatives: Array, observation: Dictionary) -> String:
	var keys: Array = [base_key] + alternatives
	return str(keys[posmod(int(observation.get("prose_index", 0)), keys.size())])

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
		text += "\n\n" + _argument_review(result.debug, people)
		var truth: Dictionary = result.debug.truth
		var evaluation: Dictionary = result.debug.evaluation
		text += "\n\n" + L.text("verdict.debug", {"person": person(truth.culprit, people),
			"motive": word(truth.motive), "method": word(truth.method), "identity_score": evaluation.scores.culprit,
			"motive_score": evaluation.scores.motive, "method_score": evaluation.scores.method, "total": evaluation.total,
			"identity_required": evaluation.get("minimum_by_claim", {}).get("culprit", 3), "motive_required": evaluation.get("minimum_by_claim", {}).get("motive", 2),
			"method_required": evaluation.get("minimum_by_claim", {}).get("method", 2), "total_required": evaluation.get("minimum_total", 7)})
		for reason in evaluation.reasons:
			var parts: PackedStringArray = reason.split("_", true, 1)
			if parts.size() == 2:
				text += "\n" + L.text("verdict." + parts[0], {"claim": L.text("verdict.total") if parts[1] == "total" else word(parts[1])})
	return text

static func _argument_review(debug: Dictionary, people: Array) -> String:
	var evaluation: Dictionary = debug.evaluation
	var index: Dictionary = debug.get("evidence", {})
	var selected: Array = evaluation.get("selected_evidence", [])
	var mentioned: Array = []
	var lines: Array[String] = [L.text("verdict.review.title")]
	var gaps: Array = []
	for argument in evaluation.get("arguments", []):
		if "insufficient_" + str(argument.claim) not in evaluation.reasons or argument.status != "incomplete" or not argument.blockers.is_empty(): continue
		if not argument.requires.any(func(id): return id in selected): continue
		for id in argument.missing:
			if id not in gaps: gaps.append(id)
	if not gaps.is_empty():
		lines.append(L.text("verdict.review.gaps", {"proofs": _proof_list(gaps, index, people, true)}))
	var ordered: Array = evaluation.get("arguments", []).duplicate()
	var order = {"supported": 0, "contested": 1, "incomplete": 2}
	ordered.sort_custom(func(a, b): return order[a.status] < order[b.status] if a.status != b.status else str(a.id) < str(b.id))
	for claim in ["culprit", "motive", "method"]:
		var sufficient = evaluation.scores[claim] >= evaluation.get("minimum_by_claim", {}).get(claim, 0)
		lines.append("\n" + L.text("verdict.review.claim", {"claim": word(claim), "status": L.text("verdict.review.sufficient" if sufficient else "verdict.review.insufficient")}))
		if "incorrect_" + claim in evaluation.reasons:
			lines.append(L.text("verdict.review.incorrect", {"claim": word(claim)}))
		var has_complete = false
		for argument in ordered:
			if argument.claim != claim: continue
			var partly_presented = argument.requires.any(func(id): return id in selected)
			if argument.status == "incomplete" and (not partly_presented or (sufficient and argument.blockers.is_empty())): continue
			var names = _proof_list(argument.requires, index, people, false)
			var explanation_key = "verdict.argument." + str(argument.inference_id)
			var explanation = L.text(explanation_key) if L.has_key(explanation_key) else L.text("verdict.argument.generic")
			lines.append(L.text("verdict.review." + argument.status, {"proofs": names, "explanation": explanation}))
			for id in argument.requires:
				if id in selected and id not in mentioned: mentioned.append(id)
			if argument.status != "incomplete": has_complete = true
			if not argument.missing.is_empty():
				lines.append(L.text("verdict.review.missing", {"proofs": _proof_list(argument.missing, index, people, true)}))
			for blocker in argument.blockers:
				var id: String = blocker.evidence_id
				var description = ""
				if index.has(id):
					var observation: Dictionary = index[id].duplicate(true)
					observation["clarified"] = true # Explicit debug explanation; does not discover or clarify it in-session.
					description = describe(observation, people)
				lines.append(L.text("verdict.review.counterproof", {"proof": _proof_name(id, index, people, true), "explanation": description}))
		if not has_complete and not sufficient:
			lines.append(L.text("verdict.review.no_complete"))
	var other: Array = selected.filter(func(id): return id not in mentioned)
	if not other.is_empty():
		lines.append("\n" + L.text("verdict.review.other", {"proofs": _proof_list(other, index, people, false)}))
	if not evaluation.get("ignored_evidence", []).is_empty():
		lines.append(L.text("verdict.review.ignored", {"proofs": _proof_list(evaluation.ignored_evidence, index, people, true)}))
	lines.append("\n" + L.text("verdict.review.scope"))
	return "\n".join(lines)

static func _proof_list(ids: Array, index: Dictionary, people: Array, with_status: bool) -> String:
	var names: Array[String] = []
	for id in ids: names.append(_proof_name(str(id), index, people, with_status))
	return " + ".join(names)

static func _proof_name(id: String, index: Dictionary, people: Array, with_status: bool) -> String:
	if not index.has(id): return id
	var observation: Dictionary = index[id]
	# A witness account is identified by the place described, not its legacy physical-placement slot.
	var location = observation.properties.get("place", observation.location) if observation.get("kind") == "testimony" else observation.location
	var name_text = title(observation) + " [" + L.text("location." + str(location)) + "]"
	if observation.properties.has("person"):
		name_text += " — " + person(str(observation.properties.person), people)
	if with_status:
		var state = "presented" if observation.presented else ("discovered" if observation.discovered else "undiscovered")
		name_text += " (" + L.text("verdict.review." + state)
		if observation.get("needs_clarification", false) and not observation.get("clarified", false):
			name_text += "; " + L.text("verdict.review.unclarified")
		name_text += ")"
	return name_text
