extends RefCounted
## Reject inconsistent candidates before exposing them to an investigation.

const Evaluator = preload("res://core/accusation_evaluator.gd")
const Data = preload("res://core/case_data.gd")
const Content = preload("res://core/case_content.gd")
const Catalog = preload("res://core/evidence_catalog.gd")
const Rules = preload("res://core/proof_rules.gd")

static func validate(data: Dictionary) -> Dictionary:
	var errors: Array = []
	for key in ["characters", "locations", "events", "support_rules", "evidence", "truth", "policy"]:
		if not data.get(key) is Dictionary:
			errors.append("invalid_section:" + key)
	if not errors.is_empty():
		return _result(errors)
	if data.get("schema_version") != Data.SCHEMA_VERSION:
		errors.append("unsupported_schema")
	for key in ["culprit", "victim", "method", "motive", "weapon", "event_id"]:
		if not data.truth.get(key) is String:
			errors.append("invalid_truth:" + key)
	for section in ["characters", "locations", "events", "support_rules", "evidence"]:
		for id in data[section]:
			if not data[section][id] is Dictionary:
				errors.append("invalid_entry:" + section + ":" + str(id))
	if not errors.is_empty():
		return _result(errors)
	for id in data.locations:
		var room: Dictionary = data.locations[id]
		if not room.get("neighbors") is Dictionary or not room.get("accessible") is bool:
			errors.append("invalid_location:" + id)
			continue
		for neighbor in room.neighbors:
			if not data.locations.has(neighbor) or not room.neighbors[neighbor] is int or room.neighbors[neighbor] < 0:
				errors.append("invalid_route:" + id)
	for id in data.events:
		var event: Dictionary = data.events[id]
		if not event.get("actors") is Array or not event.get("causes") is Array or not event.get("effects") is Dictionary or not event.get("observations") is Dictionary:
			errors.append("invalid_event:" + id)
			continue
		if not event.get("start") is int and not event.get("start") is float:
			errors.append("invalid_time:" + id)
			continue
		if not event.get("end") is int and not event.get("end") is float:
			errors.append("invalid_time:" + id)
			continue
		if event.start >= event.end:
			errors.append("invalid_interval:" + id)
		if not data.locations.has(event.get("location", "")):
			errors.append("unknown_event_location:" + id)
		for actor in event.actors:
			if not data.characters.has(actor):
				errors.append("unknown_actor:" + id)
		for cause_id in event.causes:
			if not data.events.has(cause_id):
				errors.append("unknown_cause:" + id)
			elif data.events[cause_id].get("end", INF) > event.start:
				errors.append("causal_order:" + id)
	for id in data.evidence:
		var item: Dictionary = data.evidence[id]
		if not data.events.has(item.get("event_id", "")) or not data.locations.has(item.get("location", "")) or not item.get("properties") is Dictionary:
			errors.append("invalid_evidence:" + id)
			continue
	if not errors.is_empty():
		return _result(errors)
	_check_truth(data, errors)
	if not errors.is_empty():
		return _result(errors)
	_check_timeline(data, errors)
	_check_consequences(data, errors)
	_check_proof(data, errors)
	return _result(errors)

static func _check_truth(data: Dictionary, errors: Array) -> void:
	if not data.characters.has(data.truth.culprit) or not data.characters.has(data.truth.victim) or data.truth.culprit == data.truth.victim:
		errors.append("invalid_crime_participants")
	if not data.events.has(data.truth.event_id):
		errors.append("missing_crime")
		return
	var crime: Dictionary = data.events[data.truth.event_id]
	if crime.get("kind") != "murder":
		errors.append("invalid_crime_event")
	for key in ["culprit", "victim", "method", "weapon"]:
		if crime.effects.get(key) != data.truth[key]:
			errors.append("truth_mismatch:" + key)
	for actor in [data.truth.culprit, data.truth.victim]:
		if actor not in crime.actors:
			errors.append("absent_crime_participant:" + actor)
	if not Content.PROFILES.has(data.truth.method) or Content.PROFILES[data.truth.method].weapon != data.truth.weapon:
		errors.append("incompatible_weapon")
		return
	var motivation_found = false
	for relation in data.get("relations", []):
		if relation.get("from") == data.truth.culprit and relation.get("to") == data.truth.victim and relation.get("type") == data.truth.motive:
			motivation_found = true
	if not motivation_found:
		errors.append("missing_motive_relation")
	var cause_found = false
	for cause_id in crime.causes:
		var cause: Dictionary = data.events[cause_id]
		if cause.get("kind") == "conflict" and cause.effects.get("subject") == data.truth.culprit and cause.effects.get("victim") == data.truth.victim and cause.effects.get("motive") == data.truth.motive:
			cause_found = true
	if not cause_found:
		errors.append("missing_causal_motive")
	if not data.events.has("examination"):
		errors.append("missing_examination")
		return
	var examination: Dictionary = data.events.examination
	if data.truth.event_id not in examination.causes or examination.effects.get("pattern") != Content.PROFILES[data.truth.method].pattern:
		errors.append("incompatible_examination")

static func _check_timeline(data: Dictionary, errors: Array) -> void:
	for actor in data.characters:
		var schedule: Array = []
		for event in data.events.values():
			if actor in event.actors:
				schedule.append(event)
		schedule.sort_custom(func(a, b): return a.start < b.start)
		for i in range(1, schedule.size()):
			var previous: Dictionary = schedule[i - 1]
			var current: Dictionary = schedule[i]
			var travel = _distance(data.locations, previous.location, current.location)
			if previous.end + travel > current.start:
				errors.append("impossible_schedule:" + actor)

static func _distance(locations: Dictionary, origin: String, destination: String) -> float:
	var distances = {origin: 0.0}
	var remaining = locations.keys()
	while not remaining.is_empty():
		remaining.sort_custom(func(a, b): return distances.get(a, INF) < distances.get(b, INF))
		var current = remaining.pop_front()
		if current == destination:
			return distances.get(current, INF)
		for neighbor in locations[current].neighbors:
			distances[neighbor] = min(distances.get(neighbor, INF), distances.get(current, INF) + locations[current].neighbors[neighbor])
	return INF

static func _check_consequences(data: Dictionary, errors: Array) -> void:
	for event in data.events.values():
		for id in event.observations:
			if not data.evidence.has(id) or data.evidence[id].event_id != event.id:
				errors.append("missing_consequence:" + id)
	for id in data.evidence:
		var item: Dictionary = data.evidence[id]
		var event: Dictionary = data.events[item.event_id]
		var p: Dictionary = item.properties
		var effects: Dictionary = event.effects
		if item.get("definition_id", "") == "" or item.get("definition_id") != Catalog.resolve(p):
			errors.append("invalid_definition:" + id)
		if item.id != id or event.observations.get(id) != p:
			errors.append("altered_observation:" + id)
		var source: String = item.get("source_character", "")
		if source != "":
			if not data.characters.has(source) or item.event_id not in data.characters[source].get("known_events", []) or source not in event.actors:
				errors.append("unknown_testimony_source:" + id)
		if item.kind in ["object", "trace"] and item.location != event.location:
			errors.append("unexplained_object_location:" + id)
		var compatible = true
		match p.get("observation_type", ""):
			"contact": compatible = p.get("fabric") == effects.get("fabric") and p.get("thread") == effects.get("thread")
			"examination":
				var crime: Dictionary = data.events[data.truth.event_id]
				compatible = event.kind == "examination" and p.get("pattern") == effects.get("pattern") and p.get("start", INF) == effects.get("window_start") and p.get("end", -INF) == effects.get("window_end") and p.start <= crime.start and p.end >= crime.end and p.get("place") == crime.location
			"wardrobe": compatible = p.get("entries") == effects.get("entries")
			"sighting": compatible = p.get("person") == effects.get("person") and p.get("time") == event.start and p.get("activity") == effects.get("activity") and source in event.actors
			"activity_register":
				compatible = p.get("entries") == effects.get("entries")
				for entry in p.get("entries", []):
					var grounded = false
					for cause_id in event.causes:
						var cause: Dictionary = data.events[cause_id]
						if cause.effects.get("person") != entry.person:
							continue
						grounded = cause.effects.get("place") == entry.place and cause.effects.get("planned_start") == entry.start and cause.effects.get("planned_end") == entry.end
						grounded = grounded and ((entry.status == "attended" and cause.kind == "attendance" and cause.start == entry.start and cause.end == entry.end and cause.location == entry.place) or (entry.status == "reserved" and cause.kind == "booking"))
					compatible = compatible and grounded
			"object", "incident":
				compatible = p.get("weapon") == effects.get("weapon")
				if p.observation_type == "object":
					var form_found = false
					for profile in Content.PROFILES.values():
						if profile.weapon == p.get("weapon") and profile.form == p.get("form"):
							form_found = true
					compatible = compatible and form_found
				else:
					compatible = compatible and p.get("incident") == event.kind and p.get("time") == event.start and p.get("person") in event.actors
			"grievance":
				compatible = p.get("person") == effects.get("subject") and Content.TOPICS.get(effects.get("motive")) == p.get("topic") and (p.get("state") == "open") == effects.get("open")
				var parent_found = false
				for cause_id in event.causes:
					var parent: Dictionary = data.events[cause_id]
					if parent.kind == "conflict" and parent.effects.get("subject") == p.get("person") and parent.effects.get("motive") == effects.get("motive"):
						parent_found = true
				compatible = compatible and parent_found
			"room_request": compatible = p.get("person") == effects.get("person") and p.get("reason") == effects.get("reason")
			_: compatible = false
		if not compatible:
			errors.append("incompatible_consequence:" + id)
	if not errors.is_empty():
		return
	if data.evidence.size() > 18:
		errors.append("observation_budget_exceeded")
	var topics = {}
	for item in data.evidence.values():
		if item.properties.observation_type == "grievance":
			var topic: String = item.properties.topic
			if topics.has(topic):
				errors.append("repeated_grievance_topic:" + topic)
			topics[topic] = true
	# No forged support can be added just by labelling a clue as probative.
	if data.support_rules != Rules.derive(data.evidence):
		errors.append("unsupported_comparison")
	var murder: Dictionary = data.events[data.truth.event_id]
	var entries: Array = data.events.wardrobe.effects.entries
	var matching_coats = 0
	for entry in entries:
		if entry.person == data.truth.culprit and entry.fabric == murder.effects.fabric and entry.thread == murder.effects.thread:
			matching_coats += 1
	if matching_coats != 1:
		errors.append("unexplained_material_transfer")
	for item in data.evidence.values():
		if item.properties.get("observation_type") != "object":
			continue
		var event: Dictionary = data.events[item.event_id]
		if event.kind == "discard":
			if "murder" not in event.causes or event.effects.weapon != data.truth.weapon or data.truth.culprit not in event.actors:
				errors.append("unexplained_discard:" + item.id)
			continue
		var explained = false
		for other in data.evidence.values():
			if other.event_id == item.event_id and other.properties.get("observation_type") == "incident" and other.location != item.location:
				explained = true
		if not explained:
			errors.append("missing_context:" + item.id)

static func _check_proof(data: Dictionary, errors: Array) -> void:
	if not data.policy.get("minimum_by_claim") is Dictionary or not data.policy.get("minimum_total") is int:
		errors.append("invalid_policy")
		return
	for claim in ["culprit", "motive", "method"]:
		if not data.policy.minimum_by_claim.get(claim) is int or data.policy.minimum_by_claim[claim] <= 0:
			errors.append("invalid_policy:" + claim)
	if not errors.is_empty():
		return
	var available: Array = []
	var reachable = reachable_locations(data)
	for id in data.evidence:
		if data.evidence[id].location in reachable:
			available.append(id)
	var accusation = data.truth.duplicate(true)
	accusation.evidence_ids = available
	if Evaluator.evaluate(data, accusation, available).outcome != "solved":
		errors.append("insoluble_case")

static func reachable_locations(data: Dictionary) -> Array:
	var entry: String = data.get("entry_location", "")
	if not data.locations.has(entry) or not data.locations[entry].accessible:
		return []
	var visited: Array = [entry]
	var queue: Array = [entry]
	while not queue.is_empty():
		var current = queue.pop_front()
		for neighbor in data.locations[current].neighbors:
			if data.locations[neighbor].accessible and neighbor not in visited:
				visited.append(neighbor)
				queue.append(neighbor)
	return visited

static func _result(errors: Array) -> Dictionary:
	return {"valid": errors.is_empty(), "errors": errors}
