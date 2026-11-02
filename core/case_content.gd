extends RefCounted
## Vocabulary migrated from Python. Observations describe properties, not guilt.
const METHODS = ["stabbing", "strangulation", "gunshot", "blunt_force", "poisoning"]
const MOTIVES = ["money", "jealousy", "revenge"]
const RECENT_CONTACT_MINUTES = 6
const PROFILES = {
	"stabbing": {"weapon": "knife", "pattern": "narrow_cut", "form": "narrow_edge", "room": "kitchen", "incident": "cut"},
	"strangulation": {"weapon": "rope", "pattern": "neck_band", "form": "braided_loop", "room": "storage", "incident": "lifting"},
	"gunshot": {"weapon": "pistol", "pattern": "round_perforation", "form": "small_bore", "room": "garden", "incident": "inspection"},
	"blunt_force": {"weapon": "bat", "pattern": "broad_impact", "form": "heavy_wood", "room": "garden", "incident": "sports"},
	"poisoning": {"weapon": "poison_vial", "pattern": "internal_reaction", "form": "chemical_residue", "room": "laundry", "incident": "cleaning"}}
const TOPICS = {"money": "withheld_payment", "jealousy": "private_letters", "revenge": "dismissal"}

static func motive_for(topic: String) -> String:
	for motive in TOPICS:
		if TOPICS[motive] == topic:
			return motive
	return ""

static func method_for(pattern: String, form: String) -> String:
	for method in PROFILES:
		if PROFILES[method].pattern == pattern and PROFILES[method].form == form:
			return method
	return ""

static func method_from_pattern(pattern: String) -> String:
	var matches: Array[String] = []
	for method in PROFILES:
		if PROFILES[method].pattern == pattern:
			matches.append(method)
	return matches[0] if matches.size() == 1 else ""
