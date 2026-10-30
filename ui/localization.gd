extends RefCounted
## Register editable CSV messages with Godot's native TranslationServer.
static var _tables: Dictionary = {}
static var _locale = "pt_BR"
static var _names: Dictionary = {}

static func initialize() -> void:
	if not _tables.is_empty():
		return
	var file = FileAccess.open("res://localization/messages.csv", FileAccess.READ)
	_names = JSON.parse_string(FileAccess.get_file_as_string("res://localization/languages.json"))
	var header = file.get_csv_line()
	var resources = {}
	for index in range(1, header.size()):
		var translation = Translation.new()
		translation.locale = header[index]
		resources[header[index]] = translation
		_tables[header[index]] = {}
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() != header.size() or row[0] == "":
			continue
		for index in range(1, header.size()):
			_tables[header[index]][row[0]] = row[index]
			resources[header[index]].add_message(row[0], row[index])
	for translation in resources.values():
		TranslationServer.add_translation(translation)
	TranslationServer.set_locale(_locale)

static func set_locale(locale: String) -> bool:
	initialize()
	if not _tables.has(locale):
		return false
	_locale = locale
	TranslationServer.set_locale(locale)
	return true

static func locale() -> String:
	initialize()
	return _locale

static func text(key: String, parameters: Dictionary = {}) -> String:
	initialize()
	return str(TranslationServer.translate(key)).format(parameters)

static func tables() -> Dictionary:
	initialize()
	return _tables.duplicate(true)

static func has_key(key: String) -> bool:
	initialize()
	return _tables.pt_BR.has(key)

static func available_locales() -> Array:
	initialize()
	return _tables.keys()

static func language_name(locale_id: String) -> String:
	initialize()
	return _names.get(locale_id, locale_id)
