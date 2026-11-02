extends SceneTree
const Generator = preload('res://core/case_generator.gd')
const Session = preload('res://core/investigation.gd')
const Presentation = preload('res://ui/presentation.gd')
const Data = preload('res://core/case_data.gd')
var checks = 0
var failures: Array = []
var fallback_keys: Dictionary = {}
func check(ok: bool, label: String):
 checks += 1
 if not ok:
  failures.append(label)
  printerr('FAIL: ',label)
func _initialize():
 run.call_deferred()
func run():
 for seed_value in range(100):
  var data = Generator.new().generate(seed_value).case
  var snapshot = Data.encode(data)
  var greetings = Session.new(data)
  for person_id in data.characters:
   if person_id == 'victim': continue
   greetings.visit_location(data.characters[person_id].current_location)
   var opening = greetings.dialogue(person_id)
   check(not opening.is_empty() and not str(opening.text_key).begins_with('conversation.location.'), 'every living NPC has authored first-person opening')
  var session = Session.new(data)
  var accounts = data.evidence.values().filter(func(item): return item.kind == 'testimony')
  check(accounts.size() == 2, 'two authored witness accounts')
  for room in session.locations():
   if room.accessible:
    session.visit_location(room.id)
    check(not session.objects_at(room.id).any(func(item): return item.kind == 'testimony'), 'no testimony on room floor')
  session.visit_location('lobby')
  for account in accounts:
   check(session.inspect(account.id).is_empty(), 'testimony cannot be inspected')
   check(session.ask('person_0', account.id).is_empty(), 'wrong speaker cannot answer')
   check(not session.ask('porter', account.id).is_empty(), 'witness answers known event')
   var count = session.discoveries().size()
   session.ask('porter', account.id)
   check(session.discoveries().size() == count, 'repeat question never duplicates evidence')
  var item = data.evidence.incident
  var owner = item.properties.person
  check(session.present_proof(owner, item.id).is_empty(), 'undiscovered proof cannot be presented')
  var initial = session.inspect(item.id)
  check(not initial.clarified and not Presentation.describe(initial, session.characters()).contains('Esclarecimento'), 'initial record leaves cause ambiguous')
  var count = session.discoveries().size()
  session.visit_location('lobby')
  var fallback = session.introduce_proof('porter', item.id)
  fallback_keys[fallback.text_key] = true
  check(fallback.fragments.is_empty(), 'neutral response introduces no clue')
  check(session.introduce_proof('porter', item.id) == fallback, 'neutral response stable for same speaker and proof')
  var owner_room = data.characters[owner].current_location
  session.visit_location(owner_room)
  check(not session.begin_conversation(owner).is_empty(), 'related NPC reachable in current room')
  check(session.present_proof(owner, item.id).is_empty(), 'must introduce evidence before requesting clarification')
  var introduced = session.introduce_proof(owner, item.id)
  check(introduced.get('fragments', {}).has('task'), 'presented evidence introduces spoken topic')
  check(not session.discoveries().filter(func(found): return found.id == item.id)[0].clarified, 'introducing evidence alone does not finish clarification')
  var clarified = session.present_proof(owner, item.id)
  check(clarified.get('clarified', false), 'related participant clarifies known event')
  check(Presentation.describe(clarified, session.characters()).contains('Esclarecimento'), 'full explanation appended')
  check(session.discoveries().size() == count, 'clarification updates same proof')
  session.board.sync(session.known_characters(), session.visited_locations(), session.discoveries())
  check(session.board.cards.has('evidence:incident'), 'updated proof retains card identity')
  check(Data.encode(data) == snapshot, 'conversation never changes factual case')
  var elsewhere = 'garden' if owner_room != 'garden' else 'lobby'
  session.visit_location(elsewhere)
  check(session.present_proof(owner, item.id).is_empty(), 'cannot converse remotely after leaving')
  check(session.begin_conversation('victim').is_empty(), 'victim unavailable')
 check(fallback_keys.size() == 4, 'four neutral response variants exercised')
 var desk = load('res://ui/main.tscn').instantiate()
 root.add_child(desk)
 await process_frame
 desk.seed_input.text = '258361'
 desk._open_seed()
 desk._show_room('lobby')
 desk._talk('porter')
 check(desk._dialogue_fragments.size() == 2 and not desk.inspector_body.meta_underlined, 'spoken fragments clickable without underline')
 check(desk.session.discoveries().is_empty(), 'opening does not auto-acquire evidence')
 check(not desk.inspector_body.get_parsed_text().contains('{'), 'localized speech resolves clickable fragments')
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/conversation_opening.png')
 desk.inspector_body.meta_clicked.emit('handover')
 check(desk.session.discoveries().size() == 1, 'clicking a phrase acquires testimony')
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/conversation.png')
 var incident = desk.session.inspect('incident')
 desk._show_room('lobby')
 desk._talk('person_0')
 desk._present_proof('person_0','incident')
 check(not desk.inspector_body.get_parsed_text().contains('Esclarecimento') and desk._dialogue_fragments.has('task'), 'showing proof introduces a natural spoken hook')
 desk._change_language(1)
 check(desk._dialogue_fragments.has('task') and desk.inspector_body.get_parsed_text().contains('earlier task'), 'introduced hook survives language change')
 desk._change_language(0)
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/conversation_hook.png')
 desk.inspector_body.meta_clicked.emit('task')
 check(desk.inspector_body.text.contains('Esclarecimento'), 'UI appends explanation to proof')
 check(desk.board.labels['evidence:incident'].body.contains('Esclarecimento'), 'same board card receives clarification')
 desk._change_language(1)
 check(desk.inspector_body.text.contains('Clarification'), 'clarification survives locale change')
 desk._change_language(0)
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/conversation_clarified.png')
 desk._show_room('kitchen')
 desk._talk('person_2')
 check(desk.inspector_body.get_parsed_text().begins_with('O serviço da cozinha'), 'Carlos speaks instead of receiving a location description')
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/conversation_carlos.png')
 print('Conversation checks: ',checks,'; failures: ',failures.size())
 quit(0 if failures.is_empty() else 1)
