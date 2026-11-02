extends RefCounted
const PROFILES = [
	preload("res://data/catalog/scenes/salon.tres"),
	preload("res://data/catalog/scenes/kitchen.tres"),
	preload("res://data/catalog/scenes/garden.tres"),
	preload("res://data/catalog/scenes/storage.tres"),
	preload("res://data/catalog/scenes/laundry.tres")
]
const SIGNATURES = {"stabbing": "edge_cut", "strangulation": "loop_marks",
	"gunshot": "metal_impact", "blunt_force": "heavy_impact", "poisoning": "chemical_residue"}

static func choose(locations: Dictionary, case_seed: int, method: String = "") -> String:
	var choices: Array[String] = []
	for profile in PROFILES:
		if locations.get(profile.location_id, {}).get("accessible", false) and (method == "" or profile.trace_tokens.has(method)):
			choices.append(profile.location_id)
	var rng = RandomNumberGenerator.new()
	rng.seed = case_seed ^ 32452843
	return choices[rng.randi_range(0, choices.size() - 1)] if not choices.is_empty() else ""

static func token(location: String, method: String) -> String:
	for profile in PROFILES:
		if profile.location_id == location: return profile.trace_tokens.get(method, "")
	return ""

static func method_for(signature: String) -> String:
	var found: Array[String] = []
	for method in SIGNATURES:
		if SIGNATURES[method] == signature: found.append(method)
	return found[0] if found.size() == 1 else ""
