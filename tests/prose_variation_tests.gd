extends SceneTree
const Catalog = preload('res://core/evidence_catalog.gd')
const Generator = preload('res://core/case_generator.gd')
const Session = preload('res://core/investigation.gd')
const Data = preload('res://core/case_data.gd')
const P = preload('res://ui/presentation.gd')
const L = preload('res://ui/localization.gd')
var checks = 0
var failures: Array = []
func check(ok: bool, label: String):
 checks += 1
 if not ok:
  failures.append(label)
  printerr('FAIL: ',label)
func fields(text: String) -> Array:
 var regex = RegEx.new()
 regex.compile('\\{([a-z_]+)\\}')
 var result: Array = []
 for found in regex.search_all(text): result.append(found.get_string(1))
 result.sort()
 return result
func acquire(session: RefCounted, item: Dictionary) -> Dictionary:
 if item.kind == 'testimony':
  session.visit_location('lobby')
  return session.ask('porter', item.id)
 return session.inspect(item.id)
func _initialize():
 var tables = L.tables()
 var models = 0
 var alternatives = 0
 for definition in Catalog.definitions().values():
  if definition.has('text_variants'):
   models += 1
   alternatives += definition.text_variants.size()
  for pair in [[definition.text_key, definition.get('text_variants', [])], ['conversation.incident_initial', definition.get('initial_text_variants', [])]]:
   for key in pair[1]:
    for locale in tables:
     check(tables[locale].has(key), 'variant translated: ' + str(key))
     check(fields(tables[locale][key]) == fields(tables[locale][pair[0]]), 'same factual parameters: ' + str(key))
 check(models == 28 and alternatives == 58, '28 models with 58 alternative bodies')
 var seen: Dictionary = {}
 for seed_value in range(100):
  var data = Generator.new().generate(seed_value).case
  var before = Data.encode(data)
  var session = Session.new(data)
  var repeated = Session.new(data)
  for item in data.evidence.values():
   var observation = acquire(session, item)
   var again = acquire(repeated, item)
   check(observation.prose_index == again.prose_index, 'same seed and observation preserve prose choice')
   var definition = Catalog.get_definition(item.definition_id)
   var count = definition.get('text_variants', []).size() + 1
   if not seen.has(item.definition_id): seen[item.definition_id] = {}
   seen[item.definition_id][observation.prose_index % count] = true
   for locale in tables:
    L.set_locale(locale)
    var text = P.describe(observation, session.characters())
    check(not text.is_empty() and not text.contains('{') and not text.contains('evidence.'), 'complete generated prose')
    check(P.describe(again, repeated.characters()) == text, 'repeated run renders same prose')
    if item.kind == 'testimony':
     var time = '%02d:%02d' % [int(item.properties.time) / 60, int(item.properties.time) % 60]
     check(text.contains(P.person(item.properties.person, session.characters())) and text.contains(L.text('location.' + item.properties.place)) and text.contains(time), 'testimony retains person, room and exact time')
   L.set_locale('pt_BR')
  check(Data.encode(data) == before, 'wording and language never change factual case')
 for id in ['sighting.0', 'sighting.1']:
  check(seen[id].size() == 4, 'all four witness versions selected across seeds: ' + id)
 var report = {'checks':checks,'failures':failures,'models':models,'additional_bodies':alternatives,'seeds':100}
 FileAccess.open('res://tests/results/prose.json',FileAccess.WRITE).store_string(JSON.stringify(report,'\t'))
 print('Prose checks: ',checks,'; failures: ',failures.size())
 quit(0 if failures.is_empty() else 1)
