extends RefCounted
## Internal evaluation only. Score and truth are exposed solely by explicit debug tools.

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
	for rule in data.support_rules.values():
		var claim: String = rule.claim
		if rule.value != accusation.get(claim, "") or (rule.subject != "" and rule.subject != accusation.get("culprit", "")):
			continue
		var complete = true
		for id in rule.requires:
			if id not in selected:
				complete = false
		if complete:
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
		"total": total, "ignored_evidence": ignored, "supported_comparisons": supported}
