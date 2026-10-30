extends SceneTree
## Minimal terminal consumer. No simulation rules live in this script.
const Generator = preload("res://core/case_generator.gd")
const Presentation = preload("res://ui/presentation.gd")
const L = preload("res://ui/localization.gd")
const Investigation = preload("res://core/investigation.gd")

func _initialize() -> void:
	var options = {}
	for argument in OS.get_cmdline_user_args():
		var pair = argument.trim_prefix("--").split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() == 2 else "true"
	L.set_locale(options.get("language", "pt_BR"))
	var generated = Generator.new().generate(int(options.get("seed", "0")))
	if generated.case.is_empty():
		printerr(JSON.stringify(generated))
		quit(1)
		return
	var session = Investigation.new(generated.case)
	for location in session.locations():
		print(L.text(location.name_key), " [", location.id, "] ", L.text("cli.open" if location.accessible else "cli.closed"))
		for object in session.objects_at(location.id):
			print("  ", object.id, ": ", Presentation.title(object))
	for id in options.get("inspect", "").split(",", false):
		print(JSON.stringify(session.inspect(id)))
	if options.has("culprit"):
		var accusation = {"culprit": options.culprit, "motive": options.get("motive", ""),
			"method": options.get("method", ""), "evidence_ids": Array(options.get("evidence", "").split(",", false))}
		print(JSON.stringify(session.submit(accusation, options.has("debug")), "\t"))
	else:
		print(L.text("cli.help"))
	quit()
