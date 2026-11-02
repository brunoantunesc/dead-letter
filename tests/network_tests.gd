extends SceneTree
const Generator = preload("res://core/case_generator.gd")
const Validator = preload("res://core/case_validator.gd")
const Catalog = preload("res://core/evidence_catalog.gd")
const CatalogValidator = preload("res://core/catalog/catalog_validator.gd")
const Network = preload("res://core/evidence_network.gd")
const Placement = preload("res://core/evidence_placement.gd")
const Rules = preload("res://core/proof_rules.gd")
const Evaluator = preload("res://core/accusation_evaluator.gd")
const Investigation = preload("res://core/investigation.gd")
const Layout = preload("res://core/catalog/placement_layout.gd")
const CaseData = preload("res://core/case_data.gd")
var checks = 0
var failures: Array = []

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	var base: Dictionary = Generator.new().generate(914368).case
	var material = _selection(base)
	var alternative = _selection(base, true)
	check(Validator.validate(base).valid, "base case valid")
	var original_contact: Dictionary = base.evidence.contact.duplicate(true)
	var contextual = base.duplicate(true)
	_contact(contextual, "legitimate_contact", 1000)
	_finish(contextual)
	check(Validator.validate(contextual).valid, "culprit has legitimate earlier contact, case remains soluble")
	check(_evaluate(contextual, material).outcome == "insufficient_case", "earlier contact defeats material inference")
	check(_evaluate(contextual, alternative).outcome == "solved", "independent argument still convicts")
	check(contextual.evidence.contact == original_contact, "raw trace unchanged across explanations")
	check(_evaluate(base, material).outcome == "solved", "same trace without alternative origin supports argument")
	var accusation = contextual.truth.duplicate()
	accusation.evidence_ids = material
	check(Evaluator.evaluate(contextual, accusation, material).outcome == "insufficient_case", "unfound counterproof still applies")
	var session = Investigation.new(contextual)
	for id in material:
		if base.evidence[id].kind == "testimony":
			session.visit_location("lobby")
			session.ask("porter", id)
		else: session.inspect(id)
	check(session.submit(accusation) == {"outcome": "insufficient_case"}, "counterproof stays hidden from ordinary verdict")
	check(_evaluate(contextual, material + ["legitimate_contact"]).total == _evaluate(contextual, material).total, "selecting counterproof does not add punishment")
	var wrong_person = contextual.duplicate(true)
	var other = "person_1" if contextual.truth.culprit != "person_1" else "person_2"
	wrong_person.evidence.legitimate_contact.properties.person = other
	wrong_person.events.legitimate_contact.effects.person = other
	wrong_person.events.legitimate_contact.actors = [other, "victim"]
	_finish(wrong_person)
	check(_evaluate(wrong_person, material).outcome == "solved", "contact of another person cannot defeat accused's argument")
	var wrong_material = contextual.duplicate(true)
	wrong_material.evidence.legitimate_contact.properties.thread = "different"
	wrong_material.events.legitimate_contact.effects.thread = "different"
	_finish(wrong_material)
	check(_evaluate(wrong_material, material).outcome == "solved", "different residue cannot explain this trace")
	var wrong_time = contextual.duplicate(true)
	wrong_time.evidence.legitimate_contact.properties.time = 1300
	wrong_time.events.legitimate_contact.effects.time = 1300
	wrong_time.events.legitimate_contact.start = 1300
	wrong_time.events.legitimate_contact.end = 1302
	_finish(wrong_time)
	check(_evaluate(wrong_time, material).outcome == "solved", "later contact cannot explain earlier trace")
	check(not Validator.validate(wrong_time).valid, "post-death assistance rejected causally")

	var cleaned = contextual.duplicate(true)
	var residue = contextual.evidence.legitimate_contact.properties
	_record(cleaned, "cleaning", "trace_cleaning", 1050, {"fabric": residue.fabric, "thread": residue.thread}, ["victim", "porter"], ["legitimate_contact"])
	_finish(cleaned)
	check(Validator.validate(cleaned).valid, "removal is causally grounded and case fits budget")
	check(_evaluate(cleaned, material).outcome == "solved", "counterproof to alternative origin restores argument")
	var renewed = cleaned.duplicate(true)
	_contact(renewed, "new_contact", 1100)
	_finish(renewed)
	check(Validator.validate(renewed).valid, "renewed-contact chain remains valid")
	check(_evaluate(renewed, material).outcome == "insufficient_case", "new contact after cleaning defeats restored inference")
	check(_evaluate(renewed, alternative).outcome == "solved", "chain does not imply innocence")

	var forged = base.duplicate(true)
	var wrong_object = base.duplicate(true)
	wrong_object.evidence.incident.properties.object_id = "another_instance"
	var attacks = Network.derive(wrong_object)
	check(not attacks.any(func(a): return a.source == "incident"), "same weapon type but different object instance does not contest")
	check(not Validator.validate(wrong_object).valid, "invented object identity rejected causally")
	forged.counterproofs.append({"fake": true})
	check(not Validator.validate(forged).valid, "forged relation instance rejected")
	_test_placement(base)
	_test_motive(base)
	_test_handover(base)
	_test_examination(base)
	_test_catalog_errors()
	_test_relation_witnesses()
	_test_cycles()
	var families = {"none": 0, "earlier": 0, "cleaned": 0, "culprit_contact": 0, "innocent_contact": 0}
	var review_candidates: Array = []
	for seed_value in range(100):
		var data: Dictionary = Generator.new().generate(seed_value).case
		if data.evidence.has("residue_removal"): families.cleaned += 1
		elif data.evidence.has("earlier_assistance"): families.earlier += 1
		else: families.none += 1
		if data.evidence.has("earlier_assistance"):
			if data.evidence.earlier_assistance.properties.person == data.truth.culprit: families.culprit_contact += 1
			else: families.innocent_contact += 1
		check(not data.counterproofs.is_empty(), "generated relations " + str(seed_value))
		check(Network.resolve(data.counterproofs).unresolved.is_empty(), "grounded network " + str(seed_value))
		review_candidates.append({"seed": seed_value, "trace": data.evidence.contact.properties.duplicate(true),
			"material_supported": _evaluate(data, _selection(data)).outcome == "solved"})
	check(families.values().all(func(n): return n > 0), "context is not a presence/absence guilt marker")
	var review_pair: Array = []
	for a in review_candidates:
		for b in review_candidates:
			if review_pair.is_empty() and a.trace == b.trace and a.material_supported != b.material_supported:
				review_pair = [a, b]
	check(review_pair.size() == 2, "two playable seeds with identical trace and distinct context")
	FileAccess.open("res://tests/results/network.json", FileAccess.WRITE).store_string(JSON.stringify({
		"checks": checks, "failures": failures, "families": families, "relations": Catalog.CATALOG.relations.size(),
		"generator": CaseData.GENERATOR_VERSION, "review_pair": review_pair}, "\t"))
	print("Network checks: %d; failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _selection(data: Dictionary, alternative: bool = false) -> Array:
	var index: String = data.truth.culprit.trim_prefix("person_")
	var result: Array = ["sighting_" + index, "time_record", "scene_trace", "conflict_" + index + "_record"]
	result.append_array(["activity_register"] if alternative else ["contact", "wardrobe"])
	return result

func _evaluate(data: Dictionary, selection: Array) -> Dictionary:
	var accusation = data.truth.duplicate()
	accusation.evidence_ids = selection
	return Evaluator.evaluate(data, accusation, selection)

func _finish(data: Dictionary) -> void:
	data.support_rules = Rules.derive(data.evidence)
	data.counterproofs = Network.derive(data)
	Placement.assign(data, int(data.seed))

func _contact(data: Dictionary, id: String, time: int) -> void:
	var trace: Dictionary = data.evidence.contact.properties
	_record(data, id, "prior_contact", time, {"person": data.truth.culprit, "fabric": trace.fabric, "thread": trace.thread}, [data.truth.culprit, "victim"], [])

func _record(data: Dictionary, id: String, kind: String, time: int, properties: Dictionary, actors: Array, causes: Array) -> void:
	var effects = properties.duplicate(true)
	effects.time = time
	var p = effects.duplicate(true)
	p.observation_type = kind
	data.events[id] = {"id": id, "kind": kind, "location": "laundry", "start": time, "end": time + 2, "actors": actors, "causes": causes, "effects": effects, "observations": {id: p.duplicate(true)}}
	data.evidence[id] = {"id": id, "event_id": id, "location": "laundry", "kind": "document", "definition_id": Catalog.resolve(p), "properties": p, "source_character": ""}
	for actor in actors: data.characters[actor].known_events.append(id)

func _drop(data: Dictionary, id: String) -> void:
	var event_id: String = data.evidence[id].event_id
	data.evidence.erase(id)
	data.events.erase(event_id)
	for person in data.characters.values(): person.known_events.erase(event_id)

func _test_placement(base: Dictionary) -> void:
	check(Placement.category_matches("record.medical", "record"), "subcategory fits parent support")
	check(not Placement.category_matches("material.trace", "record"), "trace cannot be placed in document support")
	var tree = base.placements.duplicate(true)
	var choice = base.evidence.contact.placement_id
	check(tree[choice].room_id == base.evidence.contact.location, "physical origin room preserved")
	var moved = base.duplicate(true)
	moved.evidence.contact.placement_id = "kitchen.slot.material.trace"
	check(not Placement.validate(moved).is_empty(), "teleported trace placement rejected")
	var nested = Layout.new()
	nested.roots.assign([{"id": "world", "children": [{"id": "room", "room_id": "salon", "children": [{"id": "cabinet", "accepts": ["record"], "children": [{"id": "drawer", "children": [{"id": "slot", "children": []}]}]}]}]}])
	var nodes = Placement.nodes(base.locations, nested)
	check(Placement.candidates(nodes, "salon", "record.medical") == ["slot"], "recursive room/cabinet/drawer slot selection")
	check(Placement.candidates(nodes, "salon", "material.trace").is_empty(), "ancestor restriction inherited")
	nodes.cabinet.accessible = false
	check(Placement.candidates(nodes, "salon", "record.medical").is_empty(), "closed container blocks descendants")
	nested.roots[0].children.append({"id": "world", "children": []})
	check(not Placement.validate_layout(base.locations, nested).is_empty(), "duplicate/cyclic placement IDs rejected")
	var blocked = base.duplicate(true)
	blocked.placements[tree[choice].parent].accessible = false
	check(not Placement.validate(blocked).is_empty(), "tampered accessibility rejected")
	var public = Investigation.new(base).inspect("contact")
	check(not public.has("counterproofs") and not public.has("category_id") and not public.has("placement_id"), "internal topology and arguments not exposed")

func _test_motive(base: Dictionary) -> void:
	var data = base.duplicate(true)
	var id = "conflict_" + data.truth.culprit.trim_prefix("person_") + "_record"
	var original: Dictionary = data.evidence[id]
	var decision: Dictionary = data.events[original.event_id]
	var properties = original.properties.duplicate(true)
	properties.state = "settled"
	var event_id = "settlement_revision"
	var effects = decision.effects.duplicate()
	effects.open = false
	data.events[event_id] = {"id": event_id, "kind": "settlement", "location": "lobby", "start": 700, "end": 702,
		"actors": [data.truth.culprit, "victim"], "causes": decision.causes.duplicate(), "effects": effects, "observations": {event_id: properties.duplicate(true)}}
	data.evidence[event_id] = {"id": event_id, "event_id": event_id, "location": original.location, "kind": "document", "definition_id": Catalog.resolve(properties), "properties": properties, "source_character": ""}
	_finish(data)
	check(_evaluate(data, _selection(data)).scores.motive == 0, "later settlement defeats active-conflict argument")
	check(not Validator.validate(data).valid, "case without sufficient motive evidence rejected")
	data.events[event_id].start = 1300
	data.events[event_id].end = 1302
	_finish(data)
	check(_evaluate(data, _selection(data)).scores.motive == 2, "settlement after crime cannot erase motive at time of crime")

func _test_catalog_errors() -> void:
	var data = Catalog.CATALOG.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	data.categories[0].parent_id = data.categories[0].id
	check(not CatalogValidator.validate(data).is_empty(), "cyclic categories rejected")
	data = Catalog.CATALOG.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	data.relations[0].source_claim_id = "invented"
	check(not CatalogValidator.validate(data).is_empty(), "unknown source claim rejected")
	data = Catalog.CATALOG.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	data.relations[0].conditions.assign([{"left": "source.properties.unknown", "op": "eq", "value": 0}])
	check(not CatalogValidator.validate(data).is_empty(), "unknown condition fields rejected")
	data = Catalog.CATALOG.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	data.relations.clear()
	check(not CatalogValidator.validate(data).is_empty(), "missing universal counterproof coverage rejected")

func _test_handover(base: Dictionary) -> void:
	var data = base.duplicate(true)
	var donor = "person_1" if data.truth.culprit != "person_1" else "person_2"
	var garment: Dictionary = {}
	for entry in data.evidence.wardrobe.properties.entries:
		if entry.person == donor: garment = entry
	_record(data, "handover", "garment_transfer", 1000, {"from_person": donor, "to_person": data.truth.culprit, "fabric": garment.fabric, "thread": garment.thread}, [donor, data.truth.culprit], [])
	for field in ["fabric", "thread"]:
		data.events.murder.effects[field] = garment[field]
		data.evidence.contact.properties[field] = garment[field]
		data.events.murder.observations.contact[field] = garment[field]
	_finish(data)
	check(Validator.validate(data).valid, "borrowed garment case respects actual ownership at crime")
	check(_evaluate(data, _selection(data)).outcome == "insufficient_case", "old garment registry alone cannot identify borrower")
	check(_evaluate(data, _selection(data) + ["handover"]).outcome == "solved", "trace plus registry plus handover supports borrower identity")
	var accusation = data.truth.duplicate()
	accusation.culprit = donor
	accusation.evidence_ids = _selection(data)
	check(Evaluator.evaluate(data, accusation, accusation.evidence_ids).scores.culprit < 3, "former owner's garment does not prove former owner killed")

func _test_examination(base: Dictionary) -> void:
	var data = base.duplicate(true)
	# This authored legacy scenario starts after its later medical addendum.
	data.investigation_time = 1300
	var original_pattern: String = load("res://core/case_content.gd").PROFILES[data.truth.method].pattern
	var secondary = "round_perforation" if original_pattern != "round_perforation" else "narrow_cut"
	data.events.murder.effects.secondary_patterns = [secondary]
	var p = {"observation_type": "examination", "pattern": secondary, "place": data.events.murder.location, "start": 1195, "end": 1210}
	data.events.examination = {"id": "examination", "kind": "examination", "location": "laundry", "start": 1240, "end": 1250,
		"actors": ["examiner"], "causes": ["murder"], "effects": {"pattern": secondary, "window_start": 1195, "window_end": 1210}, "observations": {"examination": p.duplicate(true)}}
	data.characters.examiner.known_events.append("examination")
	data.evidence.examination = {"id": "examination", "definition_id": "examination", "event_id": "examination", "location": "lobby", "kind": "document", "source_character": "examiner", "properties": p}
	_record(data, "addendum", "medical_addendum", 1270, {"pattern": original_pattern, "report_id": "examination"}, ["examiner"], ["examination"])
	_finish(data)
	check(Validator.validate(data).valid, "primary/secondary findings are grounded in physical crime effects")
	var selection = _selection(data)
	selection.erase("scene_trace")
	selection.append("examination")
	var without_addendum = selection.duplicate()
	selection.append("addendum")
	check(_evaluate(data, selection).outcome == "solved", "corrected primary finding can support method")
	check(_evaluate(data, without_addendum).outcome == "insufficient_case", "secondary finding alone cannot support correct mechanism")

func _test_cycles() -> void:
	var first = {"source": "a", "target": "b", "source_claim": "x", "target_claim": "x", "subject": ""}
	var second = {"source": "b", "target": "a", "source_claim": "x", "target_claim": "x", "subject": ""}
	check(Network.resolve([first, second]).unresolved.size() == 2, "ungrounded instance cycle diagnosed")
	var ground = {"source": "c", "target": "a", "source_claim": "x", "target_claim": "x", "subject": ""}
	var resolved = Network.resolve([first, second, ground])
	check(resolved.unresolved.is_empty() and first not in resolved.active and second in resolved.active, "grounded counterproof chain resolves")

func _test_relation_witnesses() -> void:
	var examples = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/network_witnesses.json"))
	for relation in Catalog.CATALOG.relations:
		check(examples.has(relation.id), "authored witness exists: " + relation.id)
		if not examples.has(relation.id): continue
		var example: Dictionary = examples[relation.id]
		var attacks = Network.derive(example)
		check(attacks.any(func(a): return a.relation_id == relation.id), "relation has applicable witness: " + relation.id)
		check(example.get("explanation", "") != "", "witness causal explanation: " + relation.id)
