extends SceneTree
const Validator = preload("res://core/catalog/catalog_validator.gd")

func _initialize() -> void:
	var catalog = load("res://data/catalog/catalog.tres")
	var errors = Validator.validate(catalog)
	for error in errors:
		printerr(error)
	var pending = 0
	for visual in catalog.visuals:
		if visual.status == "pending":
			pending += 1
	print("Definitions: %d; visuals pending: %d/%d; relations: %d; errors: %d" % [
		catalog.definitions.size(), pending, catalog.visuals.size(), catalog.relations.size(), errors.size()])
	print("Catalog structure only. Case causality, scoped counterproofs and solvability are checked by case_validator and network/seed tests.")
	quit(0 if errors.is_empty() else 1)
