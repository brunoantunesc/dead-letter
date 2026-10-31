extends SceneTree
## Run with an isolated --path, never imports the pack into the production project.
var manifest: Array = []
var reports: Array = []
var output_root = ""
var root_ui: Control
var grid: GridContainer

func _initialize() -> void:
 _run.call_deferred()

func _run() -> void:
 var args = OS.get_cmdline_user_args()
 if args.size() < 2:
  printerr("Usage: -- <absolute manifest.json> <absolute output folder>")
  quit(1)
  return
 manifest = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
 output_root = args[1]
 DirAccess.make_dir_recursive_absolute(output_root)
 root.size = Vector2i(1600, 1100)
 var groups: Dictionary = {}
 for entry in manifest:
  if not groups.has(entry.sheet): groups[entry.sheet] = []
  groups[entry.sheet].append(entry)
 for sheet in groups:
  await _build_sheet(sheet, groups[sheet])
  for frame in range(8): await process_frame
  await RenderingServer.frame_post_draw
  var capture = root.get_texture().get_image()
  capture.save_png(output_root.path_join(sheet + ".png"))
  print("Rendered ", sheet, ": ", groups[sheet].size(), " models")
  root.remove_child(root_ui)
  root_ui.queue_free()
  await process_frame
 var report = {"engine": Engine.get_version_info().string, "renderer": "gl_compatibility", "filter": "as_imported", "samples": reports}
 FileAccess.open(output_root.path_join("godot_report.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
 print("Audit complete: ", reports.size(), " assets")
 quit()

func _build_sheet(sheet: String, entries: Array) -> void:
 root_ui = Control.new()
 root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(root_ui)
 var bg = ColorRect.new()
 bg.color = Color("111820")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root_ui.add_child(bg)
 var margin = MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 20)
 root_ui.add_child(margin)
 var column = VBoxContainer.new()
 column.add_theme_constant_override("separation", 10)
 margin.add_child(column)
 var title = Label.new()
 title.text = "DEAD LETTER / ASSET AUDIT / " + sheet.to_upper()
 title.add_theme_font_size_override("font_size", 26)
 column.add_child(title)
 var subtitle = Label.new()
 subtitle.text = "Godot 4.6.2 · original materials · scale normalized for comparison; dimensions below are native imports"
 column.add_child(subtitle)
 grid = GridContainer.new()
 grid.columns = 4
 grid.add_theme_constant_override("h_separation", 12)
 grid.add_theme_constant_override("v_separation", 12)
 column.add_child(grid)
 for entry in entries:
  var cell = VBoxContainer.new()
  cell.custom_minimum_size = Vector2(378, 310)
  grid.add_child(cell)
  var container = SubViewportContainer.new()
  container.custom_minimum_size = Vector2(378, 245)
  container.stretch = true
  cell.add_child(container)
  var viewport = SubViewport.new()
  viewport.size = Vector2i(378, 245)
  viewport.own_world_3d = true
  viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
  container.add_child(viewport)
  var stage = Node3D.new()
  viewport.add_child(stage)
  var environment = WorldEnvironment.new()
  var settings = Environment.new()
  settings.background_mode = Environment.BG_COLOR
  settings.background_color = Color("242c36")
  settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
  settings.ambient_light_color = Color.WHITE
  settings.ambient_light_energy = 0.75
  settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
  environment.environment = settings
  stage.add_child(environment)
  var light = DirectionalLight3D.new()
  light.rotation_degrees = Vector3(-40, -25, 0)
  light.light_energy = 1.2
  stage.add_child(light)
  var camera = Camera3D.new()
  camera.projection = Camera3D.PROJECTION_ORTHOGONAL
  camera.size = 1.65
  stage.add_child(camera)
  camera.position = Vector3(1.5, 1.1, 1.8)
  camera.look_at(Vector3.ZERO)
  var report = await _load_model(entry, stage)
  reports.append(report)
  var name_label = Label.new()
  name_label.text = entry.id
  name_label.add_theme_font_size_override("font_size", 16)
  cell.add_child(name_label)
  var details = Label.new()
  details.add_theme_font_size_override("font_size", 13)
  if report.ok:
   details.text = "%.3f × %.3f × %.3f m / %d tris" % [report.size[0], report.size[1], report.size[2], report.triangles]
  else: details.text = "IMPORT FAILED: " + str(report.error)
  cell.add_child(details)

func _load_model(entry: Dictionary, stage: Node3D) -> Dictionary:
 var document = GLTFDocument.new()
 var state = GLTFState.new()
 var error = document.append_from_file(entry.local_path, state)
 if error != OK:
  return {"id": entry.id, "path": entry.archive_path, "ok": false, "error": error}
 var scene = document.generate_scene(state)
 if scene == null: return {"id": entry.id, "ok": false, "error": "null scene"}
 var pivot = Node3D.new()
 stage.add_child(pivot)
 pivot.add_child(scene)
 var meshes = _meshes(scene)
 var bounds = AABB()
 var first = true
 var triangles = 0
 var material_report: Array = []
 var collision_count = _count_class(scene, "CollisionObject3D")
 var light_count = _count_class(scene, "Light3D")
 for instance in meshes:
  var aabb: AABB = instance.global_transform * instance.get_aabb()
  if first: bounds = aabb; first = false
  else: bounds = bounds.merge(aabb)
  for surface in range(instance.mesh.get_surface_count()):
   var arrays = instance.mesh.surface_get_arrays(surface)
   var indices = arrays[Mesh.ARRAY_INDEX]
   var vertices = arrays[Mesh.ARRAY_VERTEX]
   triangles += indices.size() / 3 if indices != null and indices.size() > 0 else vertices.size() / 3
   var material = instance.get_active_material(surface)
   if material is BaseMaterial3D:
    var texture = material.get_texture(BaseMaterial3D.TEXTURE_ALBEDO)
    material_report.append({"name": material.resource_name, "texture_filter": material.texture_filter,
      "texture_size": [texture.get_width(), texture.get_height()] if texture != null else [],
      "transparency": material.transparency, "cull_mode": material.cull_mode,
      "shading_mode": material.shading_mode, "emission_enabled": material.emission_enabled})
 var longest = max(bounds.size.x, max(bounds.size.y, bounds.size.z))
 if longest > 0:
  pivot.scale = Vector3.ONE / longest
  pivot.position = -bounds.get_center() / longest
 var plane = MeshInstance3D.new()
 var plane_mesh = PlaneMesh.new()
 plane_mesh.size = Vector2(2, 2)
 plane.mesh = plane_mesh
 var ground = StandardMaterial3D.new()
 ground.albedo_color = Color("303940")
 ground.roughness = 1.0
 plane.material_override = ground
 plane.position.y = -bounds.size.y / max(longest, 0.001) / 2 - 0.01
 stage.add_child(plane)
 return {"id": entry.id, "path": entry.archive_path, "ok": true, "size": [bounds.size.x, bounds.size.y, bounds.size.z],
  "triangles": triangles, "mesh_instances": meshes.size(), "native_lights": light_count, "collision_objects": collision_count,
  "materials": material_report}

func _meshes(node: Node) -> Array:
 var result: Array = []
 if node is MeshInstance3D: result.append(node)
 for child in node.get_children(): result.append_array(_meshes(child))
 return result

func _count_class(node: Node, class_name_: String) -> int:
 var count = 1 if node.is_class(class_name_) else 0
 for child in node.get_children(): count += _count_class(child, class_name_)
 return count
