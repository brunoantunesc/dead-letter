extends RefCounted
## Internal evaluation only. Score and truth are exposed solely by explicit debug tools.
const Network = preload("res://core/evidence_network.gd")

static func evaluate(data: Dictionary, accusation: Dictionary, discovered: Array) -> Dictionary:
	var scores = {"culprit": 0, "motive": 0, "method": 0}
	var groups = {}
	var ignored: Array = []
	var selected: Array = []
	for evidence_id in accusation.get("evidence_ids", []):
		if evidence_id not in discovered or not data.evidence.has(evidence_id):
			ignored.append(evidence_id)
			continue
		if evidence_id not in selected:
			selected.append(evidence_id)
	var supported: Array = []
	var contested: Array = []
	var arguments: Array = []
	# All existing applicable counterproofs, even undiscovered/unselected, per approval.
	var network = Network.resolve(data.get("counterproofs", []))
	for rule_id in data.support_rules:
		var rule: Dictionary = data.support_rules[rule_id]
		var claim: String = rule.claim
		if rule.value != accusation.get(claim, "") or (rule.subject != "" and rule.subject != accusation.get("culprit", "")):
			continue
		var missing: Array = []
		for id in rule.requires:
			if id not in selected:
				missing.append(id)
		var blockers: Array = []
		for attack in network.active:
			if attack.target in rule.requires and attack.target_claim == rule.get("inference_id", "") and (attack.subject == "" or rule.subject == "" or attack.subject == rule.subject):
				blockers.append({"evidence_id": attack.source, "relation_id": attack.relation_id})
				if missing.is_empty():
					contested.append({"argument": rule.requires, "counterproof": attack.source, "relation": attack.relation_id})
		arguments.append({"id": rule_id, "claim": claim, "inference_id": rule.get("inference_id", ""),
			"requires": rule.requires.duplicate(), "missing": missing, "blockers": blockers,
			"independence_group": rule.independence_group, "weight": rule.weight,
			"status": "incomplete" if not missing.is_empty() else ("contested" if not blockers.is_empty() else "supported")})
		if missing.is_empty():
			if not blockers.is_empty():
				continue
			var key: String = claim + ":" + rule.independence_group
			groups[key] = max(groups.get(key, 0), rule.weight)
			supported.append(rule.requires)
	for key in groups:
		scores[key.get_slice(":", 0)] += groups[key]
	var reasons: Array = []
	var total: int = scores.culprit + scores.motive + scores.method
	for claim in scores:
		if accusation.get(claim, "") != data.truth[claim]:
			reasons.append("incorrect_" + claim)
		if scores[claim] < data.policy.minimum_by_claim[claim]:
			reasons.append("insufficient_" + claim)
	if total < data.policy.minimum_total:
		reasons.append("insufficient_total")
	var outcome = "solved"
	if accusation.get("culprit", "") != data.truth.culprit:
		outcome = "wrong_culprit"
	elif not reasons.is_empty():
		outcome = "insufficient_case"
	return {"outcome": outcome, "reasons": reasons, "scores": scores,
		"total": total, "ignored_evidence": ignored, "supported_comparisons": supported,
		"contested_comparisons": contested, "arguments": arguments, "selected_evidence": selected,
		"minimum_by_claim": data.policy.minimum_by_claim.duplicate(), "minimum_total": data.policy.minimum_total}
