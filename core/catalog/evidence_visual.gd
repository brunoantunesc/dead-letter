class_name EvidenceVisual
extends Resource
## No direct asset dependency: a pending visual must not break catalog loading.
@export var id: String = ""
@export_enum("pending", "ready") var status: String = "pending"
@export_file("*.tscn", "*.tres", "*.res", "*.png", "*.jpg", "*.webp", "*.svg", "*.glb") var asset_path: String = ""
## Internal production note, never rendered as evidence text.
@export_multiline var author_note: String = ""
