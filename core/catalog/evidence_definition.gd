class_name EvidenceDefinition
extends Resource
## Authoring only. Instances and discoveries remain in the case/session.
@export var id: String = ""
@export var selector: Dictionary = {}
@export var title_key: String = ""
@export var text_key: String = ""
@export var parameters: Dictionary = {}
@export var rows: Dictionary = {}
## Stable reference, even when no artwork exists yet.
@export var visual_id: String = ""
## Physical support, never relevance or guilt.
@export var category_id: String = ""
@export var claim_ids: PackedStringArray = []
@export var causal_kinds: PackedStringArray = []
## Canonical fields available to scoped relations, including non-text parameters.
@export var observation_fields: PackedStringArray = []

func presentation() -> Dictionary:
	var result = {"match": selector.duplicate(true), "title_key": title_key,
		"text_key": text_key, "parameters": parameters.duplicate(true), "visual_id": visual_id}
	if not rows.is_empty():
		result["rows"] = rows.duplicate(true)
	return result
