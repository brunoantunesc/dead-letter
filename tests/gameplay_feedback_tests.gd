extends SceneTree
const Generator = preload("res://core/case_generator.gd")
const Validator = preload("res://core/case_validator.gd")
const Evaluator = preload("res://core/accusation_evaluator.gd")
const Investigation = preload("res://core/investigation.gd")
const Rules = preload("res://core/proof_rules.gd")
const Scenes = preload("res://core/crime_scenes.gd")
const Content = preload("res://core/case_content.gd")
const Presentation = preload("res://ui/presentation.gd")
var checks = 0
var failures: Array = []

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func evaluate(data: Dictionary, ids: Array, method: String = "") -> Dictionary:
	var accusation = data.truth.duplicate()
	accusation.evidence_ids = ids
	if method != "": accusation.method = method
	return Evaluator.evaluate(data, accusation, ids)

func _initialize() -> void:
	var archived = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/seed_708272_v0_5_0.json"))
	var original_ids = ["activity_register", "contact", "examination", "conflict_3_record", "wardrobe"]
	var old_result = evaluate(archived, original_ids)
	check(old_result.scores.culprit == 2 and old_result.scores.motive == 2 and old_result.scores.method == 0, "user's five submitted proofs reproduce 2/2/0 exactly")
	var current: Dictionary = Generator.new().generate(708272).case
	check(current.truth == archived.truth, "regression keeps Diana/jealousy/gunshot factual solution")
	check(not current.evidence.has("examination") and not current.events.has("examination"), "autopsy not generated or distributed")
	check(Investigation.new(current).briefing().autopsy_status == "pending", "body removal and pending examination in public briefing")
	var index: String = current.truth.culprit.trim_prefix("person_")
	var compact: Array = ["sighting_" + index, "time_record", "scene_trace", "conflict_" + index + "_record", "activity_register"]
	check(evaluate(current, compact).outcome == "solved", "five distinct proofs can sustain full current case without weapon item")
	var no_witness = compact.duplicate()
	no_witness.erase("sighting_" + index)
	check(evaluate(current, no_witness).scores.culprit == 2, "authorship still requires a concrete additional circumstance")
	check(evaluate(current, ["scene_trace"]).scores.method == 2, "physical scene can support firearm mechanism, not a particular gun")
	check(evaluate(current, ["time_record"]).scores.method == 0, "service timing does not reveal mechanism")
	check(evaluate(current, compact + compact + ["wardrobe", "contact"]).total == 7, "volume and redundant routes do not inflate points")
	var rooms = {}
	var examples = {}
	var innocent_contacts = 0
	var environment_tokens = {}
	var seeds: Array = range(100)
	seeds.append(708272)
	seeds.append(914368)
	for seed_value in seeds:
		var data: Dictionary = Generator.new().generate(seed_value).case
		var room: String = data.events.murder.location
		rooms[room] = rooms.get(room, 0) + 1
		if not examples.has(room): examples[room] = seed_value
		check(Validator.validate(data).valid, "causal spatial consistency " + str(seed_value))
		check(not data.evidence.has("examination") and not data.evidence.has("routine_checkout"), "no public autopsy or everyday use of true weapon " + str(seed_value))
		check(data.evidence.size() >= 14 and data.evidence.size() <= 18, "short-case budget " + str(seed_value))
		var seen = 0
		for item in data.evidence.values():
			var p: Dictionary = item.properties
			if p.observation_type == "sighting":
				seen += 1
				check(p.with_victim and p.time >= data.evidence.time_record.properties.start - Content.RECENT_CONTACT_MINUTES, "witness saw a real recent interaction " + str(seed_value))
				if p.person != data.truth.culprit: innocent_contacts += 1
			if p.observation_type in ["incident", "object_use_record"]:
				check(p.weapon != data.truth.weapon, "detour never clears crime weapon by everyday-use story " + str(seed_value))
			if p.observation_type == "scene_trace":
				check(item.location == data.events[item.event_id].location and p.scene_profile == item.location, "environmental consequences stay at origin " + str(seed_value))
		check(seen == 2, "two concrete accounts rather than four generic proximity accounts")
		var truth_index: String = data.truth.culprit.trim_prefix("person_")
		var five = ["sighting_" + truth_index, "time_record", "scene_trace", "conflict_" + truth_index + "_record", "activity_register"]
		check(evaluate(data, five).outcome == "solved", "compact route sufficient " + str(seed_value))
		if data.evidence.has("context_trace"):
			var false_method = Scenes.method_for(data.evidence.context_trace.properties.signature)
			check(evaluate(data, ["context_trace"], false_method).scores.method == 0, "causal context defeats interpretation of unrelated scene mark")
		environment_tokens[room] = data.evidence.scene_trace.properties.detail_token
	check(rooms.size() == 5 and innocent_contacts == seeds.size(), "five crime environments and one innocent near victim in every case")
	var descriptions = {}
	for profile in Scenes.PROFILES:
		check(profile.trace_tokens.size() == Content.METHODS.size(), "complete method coverage: " + profile.location_id)
		for method in Content.METHODS:
			var text = Presentation.word(Scenes.token(profile.location_id, method))
			check(not text.begins_with("term."), "localized observable environment trace")
			descriptions[text] = true
	check(descriptions.size() == 25, "25 distinct environmental consequences, not room-name substitutions")
	FileAccess.open("res://tests/results/gameplay_feedback.json", FileAccess.WRITE).store_string(JSON.stringify({
		"checks": checks, "failures": failures, "crime_locations": rooms, "review_seeds": examples, "reported_seed": 708272}, "\t"))
	print("Gameplay feedback checks: %d; failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
