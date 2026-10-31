extends SceneTree
const Generator = preload("res://core/case_generator.gd")
const Validator = preload("res://core/case_validator.gd")
const Evaluator = preload("res://core/accusation_evaluator.gd")
const Investigation = preload("res://core/investigation.gd")
const Data = preload("res://core/case_data.gd")
const Rules = preload("res://core/proof_rules.gd")
const Presentation = preload("res://ui/presentation.gd")
var failures: Array = []
var checks = 0

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	var generator = Generator.new()
	var report = {"engine": Engine.get_version_info().string, "generator": Data.GENERATOR_VERSION,
		"content": Data.CONTENT_VERSION, "seeds": [], "failed_cases": []}
	var seeds: Array = range(100)
	seeds.append(914368)
	for case_seed in seeds:
		var result = generator.generate(case_seed)
		check(not result.case.is_empty(), "generation seed %d" % case_seed)
		if result.case.is_empty():
			report.failed_cases.append(result)
			continue
		var data: Dictionary = result.case
		check(Validator.validate(data).valid, "valid seed %d" % case_seed)
		check(Data.encode(data) == Data.encode(generator.generate(case_seed).case), "deterministic seed %d" % case_seed)
		var earlier_explains_material = data.evidence.has("earlier_assistance") and data.evidence.earlier_assistance.properties.person == data.truth.culprit and not data.evidence.has("residue_removal")
		check(evaluate(data, proofs(data)).outcome == ("insufficient_case" if earlier_explains_material else "solved"), "material argument respects earlier contact seed %d" % case_seed)
		check(evaluate(data, proofs(data, true)).outcome == "solved", "independent alibi route remains sufficient seed %d" % case_seed)
		_test_short_case(data)
		report.seeds.append({"seed": case_seed, "attempt": data.attempt, "valid": true,
			"observations": data.evidence.size(), "material_route_items": proofs(data).size(), "alibi_route_items": proofs(data, true).size()})
	var sample: Dictionary = generator.generate(914368).case
	_test_accusations(sample)
	_test_invalid_cases(sample)
	_test_boundary(sample)
	_test_reported_seed(sample)
	report["checks"] = checks
	report["failures"] = failures
	var file = FileAccess.open("res://tests/results/latest.json", FileAccess.WRITE)
	if file == null:
		check(false, "write test report")
	else:
		file.store_string(JSON.stringify(report, "\t"))
	print("Checks: %d; failures: %d; seeds: %d" % [checks, failures.size(), report.seeds.size()])
	quit(0 if failures.is_empty() else 1)

func proofs(data: Dictionary, alternative: bool = false) -> Array:
	var index: String = data.truth.culprit.trim_prefix("person_")
	var selection: Array = ["sighting_" + index, "examination", "conflict_" + index + "_record"]
	if alternative:
		selection.append("activity_register")
	else:
		selection.append_array(["contact", "wardrobe"])
	for item in data.evidence.values():
		if item.properties.observation_type == "object" and item.properties.weapon == data.truth.weapon:
			selection.append(item.id)
	return selection

func evaluate(data: Dictionary, ids: Array) -> Dictionary:
	var accusation = data.truth.duplicate(true)
	accusation.evidence_ids = ids
	return Evaluator.evaluate(data, accusation, ids)

func _test_short_case(data: Dictionary) -> void:
	check(data.evidence.size() >= 14 and data.evidence.size() <= 18, "approved short-case budget")
	var topics = {}
	var people_with_grievances = {}
	var objects = 0
	var incidents = 0
	var texts = {}
	var people: Array = Investigation.new(data).characters()
	for item in data.evidence.values():
		var p: Dictionary = item.properties
		match p.observation_type:
			"object":
				objects += 1
				check(not p.has("handled_by") and not p.has("person") and not p.has("blood_owner"), "object never names culprit")
				check(evaluate(data, [item.id]).total == 0, "object alone does not prove murder")
				if data.events[item.event_id].kind != "discard":
					check(evaluate(data, ["examination", item.id]).scores.method == 0, "unrelated suspicious object cannot prove actual method")
			"incident":
				incidents += 1
				var companion = false
				for other in data.evidence.values():
					if other.event_id == item.event_id and other.properties.observation_type == "object" and other.location != item.location:
						companion = true
				check(companion, "misleading object and context share a causal event")
			"grievance":
				topics[p.topic] = topics.get(p.topic, 0) + 1
				people_with_grievances[p.person] = true
				check(evaluate(data, [item.id]).outcome != "solved", "grievance is not guilt")
			"sighting":
				texts[Presentation.describe(item, people)] = true
		var text: String = Presentation.describe(item, people)
		check(not text.contains("viu atacar") and not text.contains("aponta para"), "no direct identity revelation")
	check(objects == 2 and incidents == 1, "one weapon detour plus its contextual explanation")
	check(topics.size() == 3 and topics.values().all(func(n): return n == 1), "no repeated motive topics")
	check(topics.get("withheld_payment", 0) == 1, "exactly one financial history")
	check(people_with_grievances.size() == 3, "different histories belong to different people")
	check(texts.size() == 4, "witness observations describe different actions")
	var fabric_matches = 0
	var thread_matches = 0
	for entry in data.evidence.wardrobe.properties.entries:
		if entry.fabric == data.evidence.contact.properties.fabric:
			fabric_matches += 1
		if entry.thread == data.evidence.contact.properties.thread:
			thread_matches += 1
	check(fabric_matches == 2 and thread_matches == 2, "each material characteristic alone remains ambiguous")
	check(evaluate(data, ["contact"]).scores.culprit == 0, "trace alone cannot name person")
	check(evaluate(data, ["wardrobe"]).scores.culprit == 0, "wardrobe alone cannot name person")
	var without_comparison = proofs(data)
	without_comparison.erase("wardrobe")
	check(evaluate(data, without_comparison).outcome == "insufficient_case", "unsupported identification cannot convict")
	check(proofs(data).size() <= 6 and proofs(data, true).size() <= 6, "no nine-record hidden selection requirement")

func _test_accusations(data: Dictionary) -> void:
	var ids = proofs(data)
	var accusation = data.truth.duplicate(true)
	accusation.evidence_ids = ids
	check(Evaluator.evaluate(data, accusation, []).outcome == "insufficient_case", "unfound proofs cannot convict")
	var wrong = accusation.duplicate(true)
	wrong.culprit = "victim"
	check(Evaluator.evaluate(data, wrong, ids).outcome == "wrong_culprit", "wrong culprit")
	for claim in ["method", "motive"]:
		wrong = accusation.duplicate(true)
		wrong[claim] = "incorrect"
		check(Evaluator.evaluate(data, wrong, ids).outcome == "insufficient_case", "wrong " + claim)
	var both_routes: Array = ids + ids + ["activity_register"]
	check(evaluate(data, both_routes).total == evaluate(data, ids).total, "repeated facts and alternative arguments do not accumulate")
	check(evaluate(data, ["incident", "room_request"]).total == 0, "context does not secretly prove crime")
	check(evaluate(data, ["nonexistent"]).outcome == "insufficient_case", "unknown evidence ignored")
	var no_motive = ids.duplicate()
	no_motive.erase("conflict_" + data.truth.culprit.trim_prefix("person_") + "_record")
	for item in data.evidence.values():
		if item.properties.observation_type == "grievance" and item.properties.person != data.truth.culprit:
			no_motive.append(item.id)
	check(evaluate(data, no_motive).scores.motive == 0, "another person's grievance cannot subsidize accusation")
	var weighted = data.duplicate(true)
	for rule in weighted.support_rules.values():
		if rule.claim == "culprit":
			rule.weight = 100
	check(evaluate(weighted, no_motive).outcome == "insufficient_case", "high global score cannot replace missing motive")

func _reject(data: Dictionary, code: String, label: String) -> void:
	var validation = Validator.validate(data)
	check(not validation.valid and code in validation.errors, label)

func _test_invalid_cases(data: Dictionary) -> void:
	var broken = data.duplicate(true)
	broken.events.murder.start = 1
	_reject(broken, "causal_order:murder", "causal chronology rejected")
	broken = data.duplicate(true)
	broken.events["impossible_trip"] = {"id": "impossible_trip", "kind": "visit", "location": "kitchen", "start": 1198, "end": 1199,
		"actors": [data.truth.culprit], "causes": [], "effects": {}, "observations": {}}
	_reject(broken, "impossible_schedule:" + data.truth.culprit, "travel time checked")
	broken = data.duplicate(true)
	broken.evidence.examination.properties.pattern = "impossible"
	_reject(broken, "incompatible_consequence:examination", "method traces checked")
	broken = data.duplicate(true)
	broken.evidence.sighting_0.source_character = "unknown"
	_reject(broken, "unknown_testimony_source:sighting_0", "testimony knowledge checked")
	broken = data.duplicate(true)
	var grievance = "conflict_" + data.truth.culprit.trim_prefix("person_") + "_record"
	broken.evidence[grievance].properties.person = "victim"
	_reject(broken, "incompatible_consequence:" + grievance, "context cannot silently explain the wrong person's dispute")
	broken = data.duplicate(true)
	for entry in broken.evidence.activity_register.properties.entries:
		if entry.status == "reserved":
			entry.status = "attended"
	_reject(broken, "incompatible_consequence:activity_register", "reservation cannot become proof of attendance")
	broken = data.duplicate(true)
	broken.locations.lobby.accessible = false
	_reject(broken, "insoluble_case", "inaccessible necessary evidence rejected")
	broken = data.duplicate(true)
	broken.evidence.contact.location = "kitchen"
	_reject(broken, "unexplained_object_location:contact", "physical evidence cannot teleport")
	broken = data.duplicate(true)
	broken.events.murder.effects.weapon = "impossible"
	_reject(broken, "truth_mismatch:weapon", "truth and events checked")
	broken = data.duplicate(true)
	broken.support_rules.values()[0].weight = 999
	_reject(broken, "unsupported_comparison", "unsupported probative labels rejected")
	broken = data.duplicate(true)
	broken.events.murder.causes = []
	_reject(broken, "missing_causal_motive", "motive must causally precede murder")
	broken = data.duplicate(true)
	broken.entry_location = "archive"
	broken.locations.archive.accessible = true
	broken.locations.archive.neighbors = {}
	_reject(broken, "insoluble_case", "open but unreachable evidence rejected")
	broken = data.duplicate(true)
	broken.evidence.contact.properties = {}
	_reject(broken, "altered_observation:contact", "missing observable properties cannot still prove identity")
	broken = data.duplicate(true)
	broken.evidence.erase("incident")
	_reject(broken, "missing_consequence:incident", "context cannot be silently discarded")
	broken = data.duplicate(true)
	var original: Dictionary = broken.evidence[grievance]
	var clone: Dictionary = original.duplicate(true)
	clone.id = "duplicate_grievance"
	broken.evidence[clone.id] = clone
	broken.events[clone.event_id].observations[clone.id] = clone.properties.duplicate(true)
	_reject(broken, "repeated_grievance_topic:" + clone.properties.topic, "repeated grievance stories rejected")
	broken = data.duplicate(true)
	for i in range(4):
		var extra: Dictionary = broken.evidence.room_request.duplicate(true)
		extra.id = "extra_paper_%d" % i
		broken.evidence[extra.id] = extra
		broken.events[extra.event_id].observations[extra.id] = extra.properties.duplicate(true)
	_reject(broken, "observation_budget_exceeded", "case budget rejects redundant filler")
	check(not Validator.validate({}).valid, "malformed data rejected")
	check(Generator.new().generate(0, 0).case.is_empty(), "bounded exhaustion")

func _test_boundary(data: Dictionary) -> void:
	var original = Data.encode(data)
	var session = Investigation.new(data)
	check(session.discoveries().is_empty(), "knowledge begins empty")
	var roster: Array = session.characters()
	check(roster.filter(func(p): return p.accusable).size() == 4 and not roster[0].has("known_events"), "roster hides knowledge and lists four suspects")
	roster[0].name = "Changed"
	check(session.characters()[0].name != "Changed", "public roster cannot mutate simulation")
	var observation = session.inspect("contact")
	check(not observation.has("support_rules") and not observation.has("event_id"), "observation allowlist")
	observation.properties.fabric = "changed"
	check(session.discoveries()[0].properties.fabric == data.evidence.contact.properties.fabric, "presentation cannot mutate discovery")
	session.notes.append({"culprit": "victim"})
	check(Data.encode(data) == original, "discoveries and hypotheses preserve truth")
	var accusation = data.truth.duplicate(true)
	accusation.evidence_ids = proofs(data)
	for id in accusation.evidence_ids:
		session.inspect(id)
	check(session.submit(accusation) == {"outcome": "solved"}, "normal verdict hides score and truth")
	check(session.submit(accusation).has("error"), "accusation is final")
	check(Investigation.new(data).submit(accusation, true).debug.has("truth"), "explicit post-verdict debug")
	var closed = data.duplicate(true)
	closed.locations.laundry.accessible = false
	check(Investigation.new(closed).inspect("wardrobe").is_empty(), "closed location cannot be inspected")
	check(Data.decode("invalid").is_empty(), "invalid serialization rejected")
	check(Data.encode(Data.decode(original)) == original, "serialization roundtrip")
	check(Validator.validate(Data.decode(original)).valid, "restored case remains valid")
	var large_seed = data.duplicate(true)
	large_seed.seed = 9223372036854775807
	check(Data.decode(Data.encode(large_seed)).seed == large_seed.seed, "64 bit seed preserved")

func _test_reported_seed(current: Dictionary) -> void:
	var archived = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/seed_914368_v0_2_0.json"))
	check(archived.seed == "914368" and archived.generator_version == "0.2.0" and archived.evidence.size() == 38, "reported case preserved verbatim")
	check(archived.truth == current.truth, "reported seed retains its factual solution")
	check(current.evidence.size() == 16, "reported seed retains short case plus one routine-use context")
