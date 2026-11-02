extends RefCounted
const Catalog = preload("res://core/evidence_catalog.gd")
const LAYOUT = preload("res://data/catalog/hotel_placement.tres")

static func category_matches(category: String, accepted: String) -> bool:
	var parents = {}
	for entry in Catalog.CATALOG.categories:
		parents[entry.id] = entry.parent_id
	var seen = {}
	while category != "" and not seen.has(category):
		if category == accepted: return true
		seen[category] = true
		category = parents.get(category, "")
	return false

static func nodes(locations: Dictionary, layout: Resource = LAYOUT) -> Dictionary:
	var result = {}
	for root in layout.roots:
		_flatten(root, "", "", true, locations, result, {})
	return result

static func _flatten(node: Dictionary, parent: String, room: String, accessible: bool, locations: Dictionary, result: Dictionary, visited: Dictionary) -> void:
	var id: String = node.get("id", "")
	if id == "" or visited.has(id) or result.has(id):
		return
	visited[id] = true
	room = node.get("room_id", room)
	accessible = accessible and node.get("accessible", true) and (room == "" or locations.get(room, {}).get("accessible", false))
	result[id] = {"id": id, "parent": parent, "room_id": room, "accessible": accessible,
		"accepts": node.get("accepts", []), "children": []}
	for child in node.get("children", []):
		if child is Dictionary:
			_flatten(child, id, room, accessible, locations, result, visited)
			if result.has(child.get("id", "")):
				result[id].children.append(child.id)
	visited.erase(id)

static func candidates(tree: Dictionary, room: String, category: String) -> Array:
	var result: Array = []
	var ids = tree.keys()
	ids.sort()
	for id in ids:
		if tree[id].parent == "":
			_collect(id, tree, room, category, true, {}, result)
	return result

static func _collect(id: String, tree: Dictionary, room: String, category: String, allowed: bool, seen: Dictionary, result: Array) -> void:
	if seen.has(id) or not tree.has(id): return
	seen[id] = true
	var node: Dictionary = tree[id]
	allowed = allowed and node.accessible
	if not node.accepts.is_empty():
		allowed = allowed and node.accepts.any(func(accepted): return category_matches(category, accepted))
	if allowed:
		if node.children.is_empty() and node.room_id == room:
			result.append(id)
		for child in node.children:
			_collect(child, tree, room, category, allowed, seen, result)
	seen.erase(id)

static func assign(data: Dictionary, case_seed: int, layout: Resource = LAYOUT) -> void:
	data.placements = nodes(data.locations, layout)
	var rng = RandomNumberGenerator.new()
	rng.seed = case_seed ^ 7919
	var ids = data.evidence.keys()
	ids.sort()
	for id in ids:
		var item: Dictionary = data.evidence[id]
		var definition = _definition(item.definition_id)
		if definition == null:
			item["placement_id"] = ""
			continue
		var choices = candidates(data.placements, item.location, definition.category_id)
		item["placement_id"] = choices[rng.randi_range(0, choices.size() - 1)] if not choices.is_empty() else ""

static func _definition(id: String) -> Resource:
	for definition in Catalog.CATALOG.definitions:
		if definition.id == id: return definition
	return null

static func validate(data: Dictionary, layout: Resource = LAYOUT) -> Array[String]:
	var errors: Array[String] = validate_layout(data.locations, layout)
	if not data.get("placements") is Dictionary or data.placements != nodes(data.locations, layout):
		return ["invalid_placement_tree"]
	for id in data.evidence:
		var item: Dictionary = data.evidence[id]
		var definition = _definition(item.definition_id)
		if definition == null: continue
		if item.get("placement_id", "") not in candidates(data.placements, item.location, definition.category_id):
			errors.append("invalid_evidence_placement:" + id)
	return errors

static func validate_layout(locations: Dictionary, layout: Resource = LAYOUT) -> Array[String]:
	var errors: Array[String] = []
	var ids = {}
	for root in layout.roots:
		_check_node(root, locations, ids, errors)
	return errors

static func _check_node(node: Dictionary, locations: Dictionary, ids: Dictionary, errors: Array[String]) -> void:
	var id = node.get("id", "")
	if not id is String or id == "" or ids.has(id):
		errors.append("duplicate_or_cyclic_placement_node")
		return
	ids[id] = true
	if node.has("room_id") and not locations.has(node.room_id):
		errors.append("unknown_placement_room:" + id)
	if not node.get("children", []) is Array or not node.get("accepts", []) is Array or not node.get("accessible", true) is bool:
		errors.append("invalid_placement_node:" + id)
		return
	for category in node.get("accepts", []):
		if not Catalog.CATALOG.categories.any(func(entry): return entry.id == category):
			errors.append("unknown_placement_category:" + id)
	for child in node.get("children", []):
		if child is Dictionary: _check_node(child, locations, ids, errors)
		else: errors.append("invalid_placement_child:" + id)
