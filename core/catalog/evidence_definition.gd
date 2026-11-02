class_name EvidenceDefinition
extends Resource
## Authoring only. Instances and discoveries remain in the case/session.
@export var id: String = ""
@export var selector: Dictionary = {}
@export var title_key: String = ""
## Observable detail token -> localized full/short names, never factual relevance.
@export var observable_titles: Dictionary = {}
@export var text_key: String = ""
## Alternative wording only: same observable facts and named parameters.
@export var text_variants: PackedStringArray = []
@export var initial_text_variants: PackedStringArray = []
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
	if not observable_titles.is_empty(): result["observable_titles"] = observable_titles.duplicate(true)
	if not text_variants.is_empty(): result["text_variants"] = Array(text_variants)
	if not initial_text_variants.is_empty(): result["initial_text_variants"] = Array(initial_text_variants)
	if not rows.is_empty():
		result["rows"] = rows.duplicate(true)
	return result
