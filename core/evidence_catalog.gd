extends RefCounted
## Stable content IDs. No translated prose or player state belongs in this catalogue.
static var _definitions: Dictionary = {}

static func definitions() -> Dictionary:
	if _definitions.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/evidence_catalog.json"))
		_definitions = parsed.definitions
	return _definitions.duplicate(true)

static func resolve(properties: Dictionary) -> String:
	var matches: Array = []
	for id in definitions():
		var compatible = true
		for field in _definitions[id].match:
			if properties.get(field) != _definitions[id].match[field]:
				compatible = false
		if compatible:
			matches.append(id)
	return matches[0] if matches.size() == 1 else ""

static func get_definition(id: String) -> Dictionary:
	definitions()
	return _definitions.get(id, {}).duplicate(true)
