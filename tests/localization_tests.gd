extends SceneTree
const Catalog = preload("res://core/evidence_catalog.gd")
const L = preload("res://ui/localization.gd")
const Presentation = preload("res://ui/presentation.gd")
const Generator = preload("res://core/case_generator.gd")
const Data = preload("res://core/case_data.gd")
const Investigation = preload("res://core/investigation.gd")
var failures: Array = []
var checks = 0

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAIL: ", label)

func _initialize() -> void:
	var tables = L.tables()
	check(tables.has("pt_BR") and tables.has("en"), "initial locales available")
	var regex = RegEx.new()
	regex.compile("\\{([A-Za-z_][A-Za-z0-9_]*)\\}")
	for key in tables.pt_BR:
		for locale in tables:
			check(tables[locale].has(key) and tables[locale][key] != "", "complete translations: " + locale + ":" + key)
			check(_placeholders(regex, tables[locale][key]) == _placeholders(regex, tables.pt_BR[key]), "matching named parameters: " + locale + ":" + key)
	for locale in tables:
		check(tables[locale].size() == tables.pt_BR.size() and L.language_name(locale) != locale, "locale has matching keys and display name: " + locale)
	var data: Dictionary = Generator.new().generate(914368).case
	var session = Investigation.new(data)
	var people: Array = session.characters()
	var snapshot = Data.encode(data)
	for id in Catalog.definitions():
		var definition = Catalog.get_definition(id)
		check(tables.pt_BR.has(definition.title_key) and tables.pt_BR.has(definition.text_key), "catalogue text keys: " + id)
		var properties: Dictionary = definition.match.duplicate(true)
		properties.merge({"person": "person_0", "time": 1175, "fabric": "navy_wool", "thread": "gray",
			"pattern": "broad_impact", "start": 1195, "end": 1210, "place": "salon",
			"entries": [{"person": "person_0", "fabric": "navy_wool", "thread": "gray", "place": "garden", "start": 1195, "end": 1220, "status": "attended"}]}, false)
		var observation = {"id": "sample", "definition_id": id, "properties": properties}
		var rendered = {}
		for locale in tables:
			L.set_locale(locale)
			var text = Presentation.describe(observation, people)
			check(not text.contains("{") and not text.contains("evidence.") and not text.contains("term.") and not text.contains("location."), "fully rendered: " + id + ":" + locale)
			check(Presentation.title(observation) != definition.title_key, "translated title: " + id + ":" + locale)
			rendered[locale] = text
		check(rendered.en != rendered.pt_BR, "locale changes the evidence text: " + id)
		check(Catalog.resolve(properties) == id, "unambiguous definition: " + id)
	check(Data.encode(Generator.new().generate(914368).case) == snapshot, "language does not affect generation")
	L.set_locale("en")
	check(not L.set_locale("unsupported") and L.locale() == "en", "unsupported locale preserves current selection")
	L.set_locale("pt_BR")
	var report = {"checks": checks, "failures": failures, "locales": tables.keys(), "definitions": Catalog.definitions().size(), "keys": tables.pt_BR.size()}
	FileAccess.open("res://tests/results/localization.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("Localization checks: %d; failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _placeholders(regex: RegEx, text: String) -> Array:
	var result: Array = []
	for match in regex.search_all(text):
		result.append(match.get_string(1))
	result.sort()
	return result
