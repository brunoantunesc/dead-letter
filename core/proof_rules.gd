extends RefCounted
## Comparisons are internal and evaluated only on submitted discoveries.
const Content = preload("res://core/case_content.gd")

static func derive(evidence: Dictionary) -> Dictionary:
	var rules = {}
	for item in evidence.values():
		var p: Dictionary = item.properties
		match p.get("observation_type", ""):
			"contact":
				for record in evidence.values():
					if record.properties.get("observation_type") != "wardrobe":
						continue
					for entry in record.properties.entries:
						if entry.fabric == p.fabric and entry.thread == p.thread:
							_add(rules, "material:" + entry.person, "culprit", entry.person, entry.person,
								2, "identity:" + entry.person, [item.id, record.id])
			"sighting":
				for report in evidence.values():
					if report.properties.get("observation_type") != "examination":
						continue
					var window: Dictionary = report.properties
					if p.time <= window.end and p.time >= window.start - 30:
						_add(rules, "presence:" + item.id, "culprit", p.person, p.person,
							1, "presence:" + p.person, [item.id, report.id])
						for register in evidence.values():
							if register.properties.get("observation_type") != "activity_register":
								continue
							var alibis = {}
							for entry in register.properties.entries:
								if entry.person != p.person and entry.status == "attended" and entry.start <= window.start and entry.end >= window.end and entry.place != window.place:
									alibis[entry.person] = true
							if alibis.size() == 3:
								_add(rules, "exclusion:" + p.person, "culprit", p.person, p.person,
									2, "identity:" + p.person, [register.id, report.id])
			"examination":
				for object in evidence.values():
					if object.properties.get("observation_type") == "object":
						var method = Content.method_for(p.pattern, object.properties.form)
						if method != "":
							_add(rules, "method:" + object.id, "method", method, "", 2,
								"injury_mechanism", [item.id, object.id])
			"grievance":
				if p.state == "open":
					var motive = Content.motive_for(p.topic)
					if motive != "":
						_add(rules, "motive:" + item.id, "motive", motive, p.person,
							2, "grievance:" + p.person, [item.id])
	return rules

static func _add(rules: Dictionary, id: String, claim: String, value: String, subject: String,
		weight: int, group: String, requires: Array) -> void:
	requires.sort()
	rules[id] = {"claim": claim, "value": value, "subject": subject, "weight": weight,
		"independence_group": group, "requires": requires}
