extends RefCounted
## Private simulation snapshot. Never pass this dictionary directly to a player UI.

const SCHEMA_VERSION = 5
const GENERATOR_VERSION = "0.5.0"
const CONTENT_VERSION = "hotel_network_1"

static func create(case_seed: int) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION, "generator_version": GENERATOR_VERSION,
		"content_version": CONTENT_VERSION, "seed": case_seed,
		"characters": {}, "locations": {}, "entry_location": "lobby", "relations": [], "events": {},
		"support_rules": {}, "counterproofs": [], "placements": {}, "evidence": {}, "truth": {},
		# Experimental policy for the logic test, not final balancing.
		"policy": {"minimum_by_claim": {"culprit": 3, "motive": 2, "method": 2}, "minimum_total": 7,
			"counterproof_scope": "existing"}
	}

static func encode(data: Dictionary) -> String:
	var snapshot = data.duplicate(true)
	# JSON numbers cannot reliably preserve the complete signed 64-bit seed range.
	snapshot.seed = str(snapshot.seed)
	return JSON.stringify(snapshot, "\t", true, true)

static func decode(text: String) -> Dictionary:
	var parser = JSON.new()
	if parser.parse(text) != OK:
		return {}
	var parsed = parser.data
	if not parsed is Dictionary or parsed.get("schema_version") != SCHEMA_VERSION or not parsed.get("seed") is String or not parsed.seed.is_valid_int():
		return {}
	parsed = _restore_integers(parsed)
	parsed.seed = int(parsed.seed)
	return parsed

static func _restore_integers(value: Variant) -> Variant:
	if value is Dictionary:
		for key in value:
			value[key] = _restore_integers(value[key])
	elif value is Array:
		for index in range(value.size()):
			value[index] = _restore_integers(value[index])
	elif value is float and is_finite(value) and value == floor(value):
		return int(value)
	return value
