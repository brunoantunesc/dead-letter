extends SceneTree
const Data = preload("res://core/catalog/catalog_data.gd")
const Definition = preload("res://core/catalog/evidence_definition.gd")
const Visual = preload("res://core/catalog/evidence_visual.gd")
const Relation = preload("res://core/catalog/evidence_relation.gd")
const Validator = preload("res://core/catalog/catalog_validator.gd")
const Catalog = preload("res://core/evidence_catalog.gd")
const Category = preload("res://core/catalog/evidence_category.gd")
var checks = 0
var failures: Array[String] = []

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	var production = load("res://data/catalog/catalog.tres")
	check(Validator.validate(production).is_empty(), "production catalog valid")
	var legacy = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/evidence_catalog_v1.json")).definitions
	check(Catalog.definitions().size() == 37 and legacy.size() == 25, "existing definitions preserved plus six contexts")
	for id in legacy:
		var current = Catalog.get_definition(id)
		var visual = Catalog.visual_for(id)
		current.erase("visual_id")
		# Prose alternatives are approved additions; baseline facts and templates remain.
		current.erase("text_variants")
		current.erase("initial_text_variants")
		if id in ["sighting.0", "sighting.1"]:
			check(current.parameters.get("place") == {"field": "place", "format": "location"}, "approved witness location parameter: " + id)
			current.parameters.erase("place")
		# JSON parsed numeric selectors as floats; .tres preserves integers.
		check(JSON.parse_string(JSON.stringify(current)) == legacy[id], "presentation preserved: " + id)
		check(visual.get("id", "") != "" and visual.get("status") == "pending" and visual.get("asset_path") == "", "explicit pending visual: " + id)
	check(Catalog.visual_for("unknown").is_empty(), "unknown visual is not a pending valid reference")
	var copy = Catalog.get_definition("contact")
	copy.parameters.fabric.field = "changed"
	check(Catalog.get_definition("contact").parameters.fabric.field == "fabric", "consumer cannot mutate shared definitions")

	var variant_count = Catalog.get_definition("contact").text_variants.size()
	copy.text_variants.append("invalid.consumer.change")
	check(Catalog.get_definition("contact").text_variants.size() == variant_count, "consumer cannot mutate prose alternatives")
	var sample = _sample()
	sample.definitions[0].text_variants = PackedStringArray(["", "example"])
	check(not Validator.validate(sample).is_empty(), "empty prose key rejected")
	sample = _sample()
	sample.definitions[0].text_variants = PackedStringArray(["example", "example"])
	check(not Validator.validate(sample).is_empty(), "repeated prose key rejected")
	sample = _sample()
	check(Validator.validate(sample).is_empty(), "scoped cyclic network valid")
	check(ResourceSaver.save(sample, "user://catalog_roundtrip.tres") == OK, "save authored resources")
	var restored = ResourceLoader.load("user://catalog_roundtrip.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
	check(restored != null and Validator.validate(restored).is_empty() and restored.relations[0].equal_fields == {"person": "person"}, "resource roundtrip preserves bindings")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://catalog_roundtrip.tres"))

	sample = _sample()
	sample.definitions.append(sample.definitions[0])
	check(not Validator.validate(sample).is_empty(), "duplicate definition rejected")
	sample = _sample()
	sample.visuals.append(sample.visuals[0])
	check(not Validator.validate(sample).is_empty(), "duplicate visual rejected")
	sample = _sample()
	sample.relations.append(sample.relations[0])
	check(not Validator.validate(sample).is_empty(), "duplicate relation rejected")
	sample = _sample()
	sample.definitions[0].visual_id = "missing"
	check(not Validator.validate(sample).is_empty(), "broken visual link rejected")
	sample = _sample()
	sample.visuals[0].status = "ready"
	sample.visuals[0].asset_path = "res://missing.tscn"
	check(not Validator.validate(sample).is_empty(), "missing ready asset rejected")
	sample.visuals[0].asset_path = "res://data/catalog/catalog.tres"
	check(not Validator.validate(sample).is_empty(), "unsupported visual resource rejected")
	sample.visuals[0].asset_path = "res://tests/fixtures/catalog_visual_mesh.tres"
	check(not ResourceLoader.has_cached(sample.visuals[0].asset_path), "visual fixture initially unloaded")
	check(Validator.validate(sample, false).is_empty() and not ResourceLoader.has_cached(sample.visuals[0].asset_path), "runtime metadata validation does not load art")
	check(Validator.validate(sample).is_empty(), "ready mesh accepted by authoring validation")
	# A generated mesh is enough to exercise ready assets; no third-party art.
	ResourceSaver.save(BoxMesh.new(), "user://catalog_test_mesh.tres")
	sample.visuals[0].asset_path = "user://catalog_test_mesh.tres"
	check(not Validator.validate(sample).is_empty(), "non-project visual path rejected")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://catalog_test_mesh.tres"))
	sample = _sample()
	sample.visuals[0].asset_path = "res://data/catalog/catalog.tres"
	check(not Validator.validate(sample).is_empty(), "pending visual cannot silently carry an asset")
	sample = _sample()
	sample.definitions[0].parameters.person.format = "unknown"
	check(not Validator.validate(sample).is_empty(), "invalid parameter format rejected")
	sample = _sample()
	sample.definitions[0].parameters.person = {"format": "person"}
	check(not Validator.validate(sample).is_empty(), "missing parameter field rejected")
	sample = _sample()
	sample.definitions[0].rows = {"field": "entries"}
	check(not Validator.validate(sample).is_empty(), "malformed row template rejected")
	sample = _sample()
	sample.definitions[1].selector = sample.definitions[0].selector.duplicate()
	check(not Validator.validate(sample).is_empty(), "overlapping selectors rejected")
	sample = _sample()
	sample.relations[0].target_definition_id = "missing"
	check(not Validator.validate(sample).is_empty(), "broken relation rejected")
	sample = _sample()
	sample.relations[0].target_claim_id = ""
	check(not Validator.validate(sample).is_empty(), "unscoped inference rejected")
	sample = _sample()
	sample.relations[0].equal_fields = {}
	check(not Validator.validate(sample).is_empty(), "missing participant binding rejected")
	sample = _sample()
	sample.relations[0].equal_fields = {"other_person": "person"}
	check(not Validator.validate(sample).is_empty(), "unknown binding field rejected")
	check(production.relations.size() == 73, "production counterproof network populated")
	var report = {"checks": checks, "failures": failures, "definitions": production.definitions.size(), "pending_visuals": production.visuals.size(), "relations": production.relations.size()}
	FileAccess.open("res://tests/results/catalog.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("Catalog checks: %d; failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _sample() -> Data:
	var catalog = Data.new()
	var category = Category.new()
	category.id = "sample"
	catalog.categories.append(category)
	for id in ["sample_a", "sample_b"]:
		var definition = Definition.new()
		definition.id = id
		definition.selector = {"observation_type": id}
		definition.title_key = "sample.title"
		definition.text_key = "sample.body"
		definition.parameters = {"person": {"field": "person", "format": "person"}}
		definition.visual_id = "visual." + id
		definition.category_id = "sample"
		definition.claim_ids = PackedStringArray(["sample.inference"])
		definition.causal_kinds = PackedStringArray(["sample_event"])
		catalog.definitions.append(definition)
		var visual = Visual.new()
		visual.id = definition.visual_id
		catalog.visuals.append(visual)
	for i in 2:
		var relation = Relation.new()
		relation.id = "relation_" + str(i)
		relation.source_definition_id = catalog.definitions[i].id
		relation.target_definition_id = catalog.definitions[1 - i].id
		relation.target_claim_id = "sample.inference"
		relation.source_claim_id = "sample.inference"
		relation.equal_fields = {"person": "person"}
		catalog.relations.append(relation)
	return catalog
