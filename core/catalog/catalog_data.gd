class_name EvidenceCatalogData
extends Resource
const Definition = preload("res://core/catalog/evidence_definition.gd")
const Visual = preload("res://core/catalog/evidence_visual.gd")
const Relation = preload("res://core/catalog/evidence_relation.gd")
const Category = preload("res://core/catalog/evidence_category.gd")
@export var version: int = 2
@export var definitions: Array[Definition] = []
@export var visuals: Array[Visual] = []
@export var relations: Array[Relation] = []
@export var categories: Array[Category] = []
