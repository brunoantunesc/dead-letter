extends RefCounted
const CatalogData = preload("res://core/catalog/catalog_data.gd")
const Definition = preload("res://core/catalog/evidence_definition.gd")
const FORMATS = ["person", "term", "location", "time", "value"]

static func validate(catalog: CatalogData, inspect_assets: bool = true) -> Array[String]:
	var errors: Array[String] = []
	if catalog == null:
		return ["catalog: missing resource"]
	if catalog.version != 2:
		errors.append("catalog: unsupported version")
	if catalog.definitions.is_empty():
		errors.append("catalog: no definitions")
	var definitions = {}
	var visuals = {}
	var relations = {}
	var categories = {}
	for category in catalog.categories:
		if category == null:
			errors.append("category: null entry")
		else:
			_register(category.id, category, categories, "category", errors)
	for id in categories:
		var visited = {}
		var cursor: String = id
		while cursor != "":
			if not categories.has(cursor) or visited.has(cursor):
				errors.append(id + ": missing parent or cyclic category")
				break
			visited[cursor] = true
			cursor = categories[cursor].parent_id
	for visual in catalog.visuals:
		if visual == null:
			errors.append("visual: null entry")
			continue
		_register(visual.id, visual, visuals, "visual", errors)
		if visual.status not in ["pending", "ready"]:
			errors.append(visual.id + ": invalid visual status")
		if visual.status == "pending" and not visual.asset_path.is_empty():
			errors.append(visual.id + ": pending visual must have no asset")
		if visual.status == "ready":
			if not visual.asset_path.begins_with("res://") or not ResourceLoader.exists(visual.asset_path):
				errors.append(visual.id + ": ready visual asset missing")
			elif inspect_assets:
				var asset = load(visual.asset_path)
				if not (asset is Texture2D or asset is Mesh or asset is PackedScene):
					errors.append(visual.id + ": unsupported visual asset type")
	for definition in catalog.definitions:
		if definition == null:
			errors.append("definition: null entry")
			continue
		_register(definition.id, definition, definitions, "definition", errors)
		if not categories.has(definition.category_id):
			errors.append(definition.id + ": unknown category")
		if definition.claim_ids.is_empty() or definition.causal_kinds.is_empty():
			errors.append(definition.id + ": claims and causal kinds required")
		if definition.selector.is_empty() or definition.title_key.is_empty() or definition.text_key.is_empty():
			errors.append(definition.id + ": selector and text keys required")
		for field in definition.selector:
			if not field is String or str(field).is_empty() or typeof(definition.selector[field]) not in [TYPE_STRING, TYPE_INT, TYPE_BOOL]:
				errors.append(definition.id + ": invalid selector")
		if definition.visual_id.is_empty() or not visuals.has(definition.visual_id):
			errors.append(definition.id + ": unknown visual_id")
		for token in definition.observable_titles:
			var titles = definition.observable_titles[token]
			if not token is String or str(token).is_empty() or not titles is Dictionary or not titles.get("title_key") is String or str(titles.get("title_key", "")).is_empty() or not titles.get("short_key") is String or str(titles.get("short_key", "")).is_empty():
				errors.append(definition.id + ": invalid observable title")
		for alternatives in [definition.text_variants, definition.initial_text_variants]:
			var seen_keys = {}
			for key in alternatives:
				if key.is_empty() or key == definition.text_key or seen_keys.has(key):
					errors.append(definition.id + ": invalid or repeated text variant")
				seen_keys[key] = true
		_parameters(definition.parameters, definition.id, errors)
		if not definition.rows.is_empty():
			var rows = definition.rows
			if not rows.get("field") is String or str(rows.get("field", "")).is_empty() or not rows.get("text_key") is String or str(rows.get("text_key", "")).is_empty() or not rows.get("parameters") is Dictionary:
				errors.append(definition.id + ": invalid rows")
			else:
				_parameters(rows.parameters, definition.id + ".rows", errors)
	# Any compatible selectors can resolve the same observation: reject ambiguity.
	for i in catalog.definitions.size():
		var a = catalog.definitions[i]
		if a == null:
			continue
		for j in range(i + 1, catalog.definitions.size()):
			var b = catalog.definitions[j]
			if b == null:
				continue
			var overlaps = true
			for field in a.selector:
				if b.selector.has(field) and a.selector[field] != b.selector[field]:
					overlaps = false
			if overlaps:
				errors.append(a.id + "/" + b.id + ": overlapping selectors")
	for relation in catalog.relations:
		if relation == null:
			errors.append("relation: null entry")
			continue
		_register(relation.id, relation, relations, "relation", errors)
		if not definitions.has(relation.source_definition_id) or not definitions.has(relation.target_definition_id):
			errors.append(relation.id + ": unknown relation endpoint")
			continue
		var source_definition = definitions[relation.source_definition_id]
		var target_definition = definitions[relation.target_definition_id]
		if relation.target_claim_id not in target_definition.claim_ids or relation.source_claim_id not in source_definition.claim_ids:
			errors.append(relation.id + ": unknown source or target claim")
		if relation.equal_fields.is_empty() and relation.conditions.is_empty():
			errors.append(relation.id + ": explicit scope binding required")
		var source_fields = _fields(definitions[relation.source_definition_id])
		var target_fields = _fields(definitions[relation.target_definition_id])
		for source in relation.equal_fields:
			var target = relation.equal_fields[source]
			if not source is String or not target is String or not source_fields.has(source) or not target_fields.has(target):
				errors.append(relation.id + ": unknown scope field")
		if relation.context_definition_id != "" and not definitions.has(relation.context_definition_id):
			errors.append(relation.id + ": unknown context")
		for side in ["source", "target"]:
			var field: String = relation.source_rows if side == "source" else relation.target_rows
			var definition = source_definition if side == "source" else target_definition
			if field != "" and field != definition.rows.get("field", ""):
				errors.append(relation.id + ": invalid row binding")
		if relation.subject_field != "" and not _path_valid(relation.subject_field, relation, definitions):
			errors.append(relation.id + ": invalid subject binding")
		for condition in relation.conditions:
			if not condition.get("left") is String or condition.get("op") not in ["eq", "ne", "lt", "lte", "gt", "gte"]:
				errors.append(relation.id + ": invalid condition")
				continue
			if not _path_valid(condition.left, relation, definitions):
				errors.append(relation.id + ": unknown condition field")
			if condition.has("right") == condition.has("value"):
				errors.append(relation.id + ": condition needs right path or literal")
			elif condition.has("right") and (not condition.right is String or not _path_valid(condition.right, relation, definitions)):
				errors.append(relation.id + ": unknown comparison field")
	for id in definitions:
		var covered = false
		for relation in catalog.relations:
			if relation != null and relation.target_definition_id == id:
				covered = true
		if not covered:
			errors.append(id + ": no possible counterproof")
	return errors

static func _register(id: String, entry: Resource, index: Dictionary, kind: String, errors: Array[String]) -> void:
	if id.strip_edges().is_empty():
		errors.append(kind + ": empty id")
	elif index.has(id):
		errors.append(kind + ": duplicate id " + id)
	else:
		index[id] = entry

static func _parameters(parameters: Dictionary, context: String, errors: Array[String]) -> void:
	for name in parameters:
		var spec = parameters[name]
		if not name is String or str(name).is_empty() or not spec is Dictionary:
			errors.append(context + ": invalid parameter")
			continue
		if not spec.get("field") is String or str(spec.get("field", "")).is_empty() or spec.get("format", "") not in FORMATS:
			errors.append(context + ": invalid parameter " + str(name))

static func _fields(definition: Definition) -> Array:
	var fields = definition.selector.keys()
	fields.append_array(Array(definition.observation_fields))
	for spec in definition.parameters.values():
		if spec is Dictionary and spec.get("field") is String:
			fields.append(spec.field)
	# Row fields are deliberately excluded: binding a whole observation is not
	# equivalent to choosing a participant inside one of its rows.
	return fields

static func _path_valid(path: String, relation: Resource, definitions: Dictionary) -> bool:
	var parts = path.split(".")
	if parts.size() == 2 and parts[0] in ["source_event", "target_event"]:
		return parts[1] in ["start", "end", "kind", "location"]
	if parts.size() == 2 and parts[0] in ["source", "target", "context"]:
		return parts[1] in ["id", "event_id", "location"]
	var side = parts[0]
	if side not in ["source", "target", "source_row", "target_row", "context"]:
		return false
	var definition_id: String = relation.source_definition_id
	if side.begins_with("target"): definition_id = relation.target_definition_id
	if side == "context": definition_id = relation.context_definition_id
	if not definitions.has(definition_id):
		return false
	var definition = definitions[definition_id]
	if side.ends_with("_row"):
		if parts.size() != 2: return false
		for spec in definition.rows.get("parameters", {}).values():
			if spec is Dictionary and spec.get("field") == parts[1]: return true
		return false
	return parts.size() == 3 and parts[1] == "properties" and parts[2] in _fields(definition)
