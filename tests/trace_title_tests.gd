extends SceneTree
const Generator = preload('res://core/case_generator.gd')
const Session = preload('res://core/investigation.gd')
const Scenes = preload('res://core/crime_scenes.gd')
const Catalog = preload('res://core/evidence_catalog.gd')
const P = preload('res://ui/presentation.gd')
const L = preload('res://ui/localization.gd')
var checks = 0
var failures: Array = []
func check(ok: bool, label: String):
 checks += 1
 if not ok:
  failures.append(label)
  printerr('FAIL: ',label)
func _initialize():
 run.call_deferred()
func run():
 var font = SystemFont.new()
 font.font_names = PackedStringArray(['Menlo','Consolas','Liberation Mono','monospace'])
 for locale in L.available_locales():
  L.set_locale(locale)
  for profile in Scenes.PROFILES:
   var titles: Dictionary = {}
   var short_titles: Dictionary = {}
   for method in Scenes.SIGNATURES:
    var observation = {'definition_id':'scene_trace.'+profile.location_id,'properties':{'detail_token':profile.trace_tokens[method]}}
    var full = P.title(observation)
    var short_text = P.short_title(observation)
    check(not titles.has(full), 'distinct observable title per weapon in room: '+profile.location_id)
    check(not short_titles.has(short_text), 'distinct card identifier per weapon in room: '+profile.location_id)
    check(not full.contains('evidence.') and not short_text.contains('evidence.'), 'observable titles translated')
    check(font.get_string_size(short_text,HORIZONTAL_ALIGNMENT_LEFT,-1,22).x <= 192, 'short identifier fits existing card')
    var menu_item = {'definition_id':observation.definition_id,'title_token':profile.trace_tokens[method]}
    check(P.title(menu_item) == full, 'room menu and inspected proof use same title')
    titles[full] = true
    short_titles[short_text] = true
 L.set_locale('pt_BR')
 var example_seed = -1
 var example_room = ''
 for seed_value in range(100):
  var data = Generator.new().generate(seed_value).case
  var session = Session.new(data)
  var titles_by_room: Dictionary = {}
  for room in session.locations():
   if not room.accessible: continue
   for item in session.objects_at(room.id):
    if not str(item.definition_id).begins_with('scene_trace.'): continue
    if not titles_by_room.has(room.id): titles_by_room[room.id] = []
    var name_text = P.title(item)
    check(name_text not in titles_by_room[room.id], 'generated traces in same room never share title')
    titles_by_room[room.id].append(name_text)
    var observed = session.inspect(item.id)
    check(P.title(observed) == name_text, 'inspection preserves observable label')
    session.board.sync(session.known_characters(),session.visited_locations(),session.discoveries())
   if titles_by_room.get(room.id,[]).size() > 1:
    example_seed = seed_value
    example_room = room.id
 check(example_seed >= 0,'same-room pair regression found')
 var desk = load('res://ui/main.tscn').instantiate()
 root.add_child(desk)
 await process_frame
 desk.seed_input.text = str(example_seed)
 desk._open_seed()
 desk._show_room(example_room)
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/trace_titles.png')
 print('Trace title checks: ',checks,'; failures: ',failures.size(),'; review seed: ',example_seed,' / ',example_room)
 quit(0 if failures.is_empty() else 1)
