class_name EvidenceRelation
extends Resource
## A source contests one inference drawn from a target, not the raw observation.
## Structural authoring contract only; causal/evaluation semantics belong to #2.
@export var id: String = ""
@export var source_definition_id: String = ""
@export var target_definition_id: String = ""
@export var target_claim_id: String = ""
## source property field -> target property field; all pairs must be equal.
@export var equal_fields: Dictionary = {}
@export var source_claim_id: String = ""
@export var source_rows: String = ""
@export var target_rows: String = ""
@export var context_definition_id: String = ""
## Person to whom this argument applies; empty for object/method claims.
@export var subject_field: String = ""
## Finite predicates: left path, op, and right path OR literal value.
@export var conditions: Array[Dictionary] = []
