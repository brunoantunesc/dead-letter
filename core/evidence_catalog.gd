extends RefCounted
## Stable content IDs. No translated prose or player state belongs in this catalogue.
const Validator = preload("res://core/catalog/catalog_validator.gd")
const CATALOG = preload("res://data/catalog/catalog.tres")
static var _definitions: Dictionary = {}

static func definitions() -> Dictionary:
	if _definitions.is_empty():
		var errors = Validator.validate(CATALOG, false)
		if not errors.is_empty():
			push_error("Invalid evidence catalog: " + "; ".join(errors))
			return {}
		for definition in CATALOG.definitions:
			_definitions[definition.id] = definition.presentation()
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

static func visual_for(definition_id: String) -> Dictionary:
	var definition = get_definition(definition_id)
	for visual in CATALOG.visuals:
		if visual.id == definition.get("visual_id", ""):
			return {"id": visual.id, "status": visual.status, "asset_path": visual.asset_path}
	return {}
