extends RefCounted
## Short cases: distinct investigative functions, not repeated grievances for every actor.
const Data = preload("res://core/case_data.gd")
const Validator = preload("res://core/case_validator.gd")
const Content = preload("res://core/case_content.gd")
const Rules = preload("res://core/proof_rules.gd")
const Catalog = preload("res://core/evidence_catalog.gd")
const Network = preload("res://core/evidence_network.gd")
const Placement = preload("res://core/evidence_placement.gd")
const Scenes = preload("res://core/crime_scenes.gd")
const NAMES = ["Ana", "Bruno", "Carlos", "Diana"]

func generate(case_seed: int, max_attempts: int = 3) -> Dictionary:
	var failures: Array = []
	for attempt in range(max_attempts):
		var candidate = build_candidate(case_seed, attempt)
		var validation = Validator.validate(candidate)
		if validation.valid:
			return {"case": candidate, "failures": failures}
		failures.append({"seed": case_seed, "attempt": attempt, "errors": validation.errors, "case": candidate})
	return {"case": {}, "failures": failures, "error": "generation_exhausted"}

func build_candidate(case_seed: int, attempt: int = 0) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = case_seed + attempt
	var data = Data.create(case_seed)
	data["attempt"] = attempt
	var room_ids = ["lobby", "salon", "kitchen", "restaurant", "laundry", "storage", "garden", "archive"]
	for id in room_ids:
		data.locations[id] = {"name_key": "location." + id, "accessible": id != "archive" or rng.randi_range(0, 1) == 1,
			"neighbors": {"lobby": 5} if id != "lobby" else {}}
		if id != "lobby":
			data.locations.lobby.neighbors[id] = 5
	for i in range(4):
		data.characters["person_%d" % i] = {"name": NAMES[i], "role": ["manager", "guest", "cook", "guest"][i], "accusable": true, "known_events": []}
	for person in ["victim", "porter", "examiner"]:
		data.characters[person] = {"name": {"victim": "Vicente", "porter": "Amadeu", "examiner": ""}[person],
			"role": {"victim": "administrator", "porter": "porter", "examiner": "examiner"}[person], "accusable": false, "known_events": []}
	data.characters.examiner["name_key"] = "person.examiner"
	# Preserve this part of the seed interpretation, including the reported regression case.
	var culprit = "person_%d" % rng.randi_range(0, 3)
	var method: String = Content.METHODS[rng.randi_range(0, 4)]
	var motive: String = Content.MOTIVES[rng.randi_range(0, 2)]
	data.truth = {"culprit": culprit, "victim": "victim", "motive": motive, "method": method,
		"weapon": Content.PROFILES[method].weapon, "event_id": "murder"}
	var crime_room = Scenes.choose(data.locations, case_seed, method)
	var others: Array = data.characters.keys().filter(func(id): return data.characters[id].accusable and id != culprit)
	_shuffle(others, rng)
	var other_motives: Array = Content.MOTIVES.duplicate()
	other_motives.erase(motive)
	_shuffle(other_motives, rng)
	# Each motive appears once: one financial history, one personal history, one dismissal.
	_conflict(data, "conflict_" + culprit.trim_prefix("person_"), culprit, motive, true, 600)
	_conflict(data, "conflict_" + others[0].trim_prefix("person_"), others[0], other_motives[0], true, 620)
	_conflict(data, "conflict_" + others[1].trim_prefix("person_"), others[1], other_motives[1], false, 640)
	_event(data, "room_request", "room_request", "lobby", 670, 675, [others[2]], [], {"person": others[2], "reason": "plumbing_noise"})
	_observe(data, "room_request", "room_request", "lobby", "document",
		{"observation_type": "room_request", "person": others[2], "reason": "plumbing_noise"})
	var outfits = [{"fabric": "navy_wool", "thread": "copper"}, {"fabric": "navy_wool", "thread": "gray"},
		{"fabric": "charcoal_wool", "thread": "copper"}, {"fabric": "charcoal_wool", "thread": "gray"}]
	_shuffle(outfits, rng)
	var entries: Array = []
	var records: Array = []
	var record_sources: Array = []
	var context_rng = RandomNumberGenerator.new()
	context_rng.seed = case_seed ^ 104729
	var close_people: Array = [culprit, others[context_rng.randi_range(0, 2)]]
	_shuffle(close_people, context_rng)
	var ordinary: Array = others.filter(func(person): return person not in close_people)
	var accounts: Array = []
	for role in range(2):
		accounts.append({"person": close_people[role], "activity": role, "with_victim": true, "place": "lobby", "time": 1189})
	_event(data, "victim_contacts", "victim_contact", "lobby", 1189, 1190,
		[close_people[0], close_people[1], "victim", "porter"], [], {"accounts": accounts})
	for i in range(4):
		var person = "person_%d" % i
		var entry: Dictionary = outfits[i].duplicate()
		entry.person = person
		entries.append(entry)
		var sighting_event = "victim_contacts"
		var account: Dictionary
		if person in close_people:
			account = accounts[close_people.find(person)].duplicate(true)
		else:
			var role = ordinary.find(person) + 2
			var place: String = "garden" if role == 2 else "restaurant"
			var time = 1140 if role == 2 else 1155
			account = {"person": person, "activity": role, "with_victim": false, "place": place, "time": time}
			sighting_event = "sighting_%d" % i
			_event(data, sighting_event, "passing", place, time, time + 1, [person, "porter"], [], account.duplicate(true))
		account["observation_type"] = "sighting"
		if person in close_people:
			_observe(data, sighting_event, "sighting_%d" % i, "restaurant", "testimony", account, "porter")
		var room: String = ["restaurant", "kitchen", "garden"][i % 3]
		if room == crime_room:
			room = "storage" if crime_room != "storage" else "laundry"
		var attended = person != culprit
		var source_id = "attendance_%d" % i if attended else "booking_%d" % i
		_event(data, source_id, "attendance" if attended else "booking", room if attended else "lobby",
			1195 if attended else 800 + i * 5, 1220 if attended else 801 + i * 5, [person], [],
			{"person": person, "place": room, "planned_start": 1195, "planned_end": 1220})
		record_sources.append(source_id)
		records.append({"person": person, "place": room, "start": 1195, "end": 1220, "status": "attended" if attended else "reserved"})
	_event(data, "activity_register", "activity_register", "lobby", 1225, 1226, ["porter"], record_sources, {"entries": records})
	_observe(data, "activity_register", "activity_register", "lobby", "document",
		{"observation_type": "activity_register", "entries": records.duplicate(true)}, "porter")
	_event(data, "wardrobe", "cloakroom_intake", "laundry", 900, 920, ["person_0", "person_1", "person_2", "person_3"], [], {"entries": entries})
	_observe(data, "wardrobe", "wardrobe", "laundry", "document",  {"observation_type": "wardrobe", "entries": entries.duplicate(true)})
	var coat: Dictionary = entries[int(culprit.trim_prefix("person_"))]
	_event(data, "murder", "murder", crime_room, 1200, 1205, [culprit, "victim"], ["conflict_" + culprit.trim_prefix("person_")],
		{"culprit": culprit, "victim": "victim", "method": method, "weapon": data.truth.weapon, "fabric": coat.fabric, "thread": coat.thread, "contact": "sleeve_gripped"})
	_observe(data, "murder", "contact", crime_room, "trace", {"observation_type": "contact", "fabric": coat.fabric, "thread": coat.thread})
	_scene_trace(data, "murder", "scene_trace", crime_room, method, "instrument_" + data.truth.weapon)
	_event(data, "last_contact", "service_visit", crime_room, 1195, 1196, ["porter", "victim"], [], {})
	_event(data, "body_discovery", "body_discovery", crime_room, 1210, 1211, ["porter", "victim"], ["murder"], {})
	_event(data, "body_removal", "body_removal", crime_room, 1220, 1222, ["examiner", "victim"], ["body_discovery"], {"autopsy_status": "pending"})
	_event(data, "time_record", "discovery_record", "lobby", 1223, 1224, ["porter"], ["last_contact", "body_discovery"],
		{"place": crime_room, "start": 1195, "end": 1210})
	_observe(data, "time_record", "time_record", "lobby", "document",
		{"observation_type": "time_record", "place": crime_room, "start": 1195, "end": 1210}, "porter")
	var alternative_methods: Array = Content.METHODS.duplicate()
	alternative_methods.erase(method)
	var misleading_method: String = alternative_methods[rng.randi_range(0, alternative_methods.size() - 1)]
	var methods: Array = [method, misleading_method]
	_shuffle(methods, rng)
	for i in range(methods.size()):
		var candidate: String = methods[i]
		var profile: Dictionary = Content.PROFILES[candidate]
		var event_id = "use_%d" % i
		if candidate == method:
			_event(data, event_id, "discard", profile.room, 1215, 1216, [culprit], ["murder"], {"weapon": profile.weapon})
		else:
			var owner = "person_2" if profile.incident == "cut" else "person_0"
			_event(data, event_id, profile.incident, profile.room, 300, 310, [owner], [], {"weapon": profile.weapon})
			_observe(data, event_id, "incident", "lobby", "document",
				{"observation_type": "incident", "incident": profile.incident, "person": owner, "time": 300, "weapon": profile.weapon, "object_id": "instrument_" + profile.weapon})
		_observe(data, event_id, "object_%d" % i, profile.room, "object",
			{"observation_type": "object", "form": profile.form, "weapon": profile.weapon, "object_id": "instrument_" + profile.weapon})
		data.events[event_id].effects["object_id"] = "instrument_" + profile.weapon
		if candidate != method and case_seed % 3 != 0:
			_scene_trace(data, event_id, "context_trace", profile.room, candidate, "instrument_" + profile.weapon)
	if case_seed % 3 == 0:
		var helper_index = context_rng.randi_range(0, 3)
		var helper = "person_%d" % helper_index
		var helper_coat: Dictionary = entries[helper_index]
		var previous_contact = {"person": helper, "fabric": helper_coat.fabric, "thread": helper_coat.thread, "time": 1000}
		_event(data, "earlier_assistance", "prior_contact", "laundry", 1000, 1002, [helper, "victim"], [], previous_contact.duplicate(true))
		var observed = previous_contact.duplicate(true)
		observed["observation_type"] = "prior_contact"
		_observe(data, "earlier_assistance", "earlier_assistance", "laundry", "document", observed)
		if case_seed % 6 == 0:
			var cleaning = {"fabric": helper_coat.fabric, "thread": helper_coat.thread, "time": 1050}
			_event(data, "residue_removal", "trace_cleaning", "laundry", 1050, 1052, ["victim", "porter"], ["earlier_assistance"], cleaning.duplicate(true))
			var cleaning_observed = cleaning.duplicate(true)
			cleaning_observed["observation_type"] = "trace_cleaning"
			_observe(data, "residue_removal", "residue_removal", "laundry", "document", cleaning_observed, "porter")
	# Investigation snapshot after body removal, separate from historical event locations.
	var npc_rng = RandomNumberGenerator.new()
	npc_rng.seed = case_seed ^ 49999
	var guest_rooms = ["salon", "restaurant", "garden"]
	var current_rooms = {"person_0": "lobby", "person_1": guest_rooms[npc_rng.randi_range(0, 2)],
		"person_2": "kitchen", "person_3": guest_rooms[npc_rng.randi_range(0, 2)], "porter": "lobby", "examiner": "lobby"}
	for person_id in data.characters:
		data.characters[person_id]["current_location"] = current_rooms.get(person_id, "")
		data.characters[person_id]["location_reason_key"] = "conversation.location." + ("guest" if person_id in ["person_1", "person_3"] else person_id)
	var ids: Array = data.evidence.keys()
	_shuffle(ids, rng)
	var mixed = {}
	for id in ids:
		mixed[id] = data.evidence[id]
	data.evidence = mixed
	data.support_rules = Rules.derive(data.evidence)
	data.counterproofs = Network.derive(data)
	Placement.assign(data, case_seed)
	return data

func _scene_trace(data: Dictionary, event_id: String, id: String, location: String, method: String, object_id: String) -> void:
	var properties = {"observation_type": "scene_trace", "scene_profile": location, "signature": Scenes.SIGNATURES[method],
		"detail_token": Scenes.token(location, method), "object_id": object_id, "place": location}
	if not data.events[event_id].effects.has("scene_traces"):
		data.events[event_id].effects["scene_traces"] = {}
	data.events[event_id].effects.scene_traces[id] = properties.duplicate(true)
	_observe(data, event_id, id, location, "trace", properties)

func _conflict(data: Dictionary, id: String, person: String, motive: String, remains_open: bool, time: int) -> void:
	data.relations.append({"from": person, "to": "victim", "type": motive, "open": remains_open})
	_event(data, id, "conflict", "lobby", time, time + 5, [person, "victim"], [], {"subject": person, "victim": "victim", "motive": motive, "open": remains_open})
	_event(data, id + "_status", "decision" if remains_open else "settlement", "lobby", time + 7, time + 8, [person, "victim"], [id],
		{"subject": person, "motive": motive, "open": remains_open})
	_observe(data, id + "_status", id + "_record", {"money": "lobby", "jealousy": "laundry", "revenge": "storage"}[motive], "document",
		{"observation_type": "grievance", "person": person, "topic": Content.TOPICS[motive], "state": "open" if remains_open else "settled"})

func _event(data: Dictionary, id: String, kind: String, location: String, start: int, end: int, actors: Array, causes: Array, effects: Dictionary) -> void:
	data.events[id] = {"id": id, "kind": kind, "location": location, "start": start, "end": end,
		"actors": actors, "causes": causes, "effects": effects, "observations": {}}
	for actor in actors:
		data.characters[actor].known_events.append(id)

func _observe(data: Dictionary, event_id: String, id: String, location: String, kind: String, properties: Dictionary, source: String = "") -> void:
	data.events[event_id].observations[id] = properties.duplicate(true)
	data.evidence[id] = {"id": id, "event_id": event_id, "location": location, "kind": kind,
		"definition_id": Catalog.resolve(properties), "properties": properties.duplicate(true), "source_character": source}

func _shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for i in range(values.size() - 1, 0, -1):
		var other = rng.randi_range(0, i)
		var old = values[i]
		values[i] = values[other]
		values[other] = old
