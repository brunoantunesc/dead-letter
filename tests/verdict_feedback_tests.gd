extends SceneTree
const Generator = preload('res://core/case_generator.gd')
const Session = preload('res://core/investigation.gd')
const P = preload('res://ui/presentation.gd')
const L = preload('res://ui/localization.gd')
const Data = preload('res://core/case_data.gd')
var checks = 0
var failures: Array = []
func check(ok: bool, label: String):
 checks += 1
 if not ok:
  failures.append(label)
  printerr('FAIL: ',label)
func session_with(data: Dictionary, ids: Array) -> RefCounted:
 var session = Session.new(data)
 for id in ids:
  if not data.evidence.has(id): continue
  if data.evidence[id].kind == 'testimony':
   session.visit_location('lobby')
   session.ask('porter',id)
  else: session.inspect(id)
 return session
func accusation(data: Dictionary, selected: Array) -> Dictionary:
 var result = data.truth.duplicate()
 result.evidence_ids = selected
 return result
func _initialize():
 run.call_deferred()
func run():
 var data = Generator.new().generate(258361).case
 var snapshot = Data.encode(data)
 var selected: Array = ['scene_trace','contact','activity_register','conflict_1_record','sighting_1','wardrobe']
 for item in data.evidence.values():
  if item.kind == 'object' and item.properties.weapon == 'rope': selected.append(item.id)
 var session = session_with(data, data.evidence.keys())
 var report = session.submit(accusation(data,selected),true)
 check(report.outcome == 'insufficient_case' and report.debug.evaluation.scores == {'culprit':2,'motive':2,'method':2}, 'reported seed reproduces original 2/2/2 result')
 for inference in ['opportunity','attendance']:
  var matches = report.debug.evaluation.arguments.filter(func(argument): return argument.inference_id == inference)
  check(matches.size() == 1 and matches[0].status == 'incomplete' and matches[0].missing == ['time_record'], 'actual missing chronology in ' + inference)
 check(report.debug.evidence.time_record.discovered and not report.debug.evidence.time_record.presented, 'known timing record was not submitted')
 var pt = P.verdict_text(report, session.characters())
 check(pt.contains('descoberta, mas não apresentada') and pt.contains('Registro do encontro do corpo'), 'diagnostic names omitted known evidence')
 check(pt.contains('A entrega a Vicente [Recepção]') and not pt.contains('A entrega a Vicente [Restaurante]'), 'witness account uses reported room rather than obsolete physical placement')
 check(pt.contains('intervalo entre') and pt.contains('Aceito:'), 'diagnostic explains temporal connection and accepted evidence')
 check(pt.contains('Autoria: 2/3') and pt.contains('Total: 6/7'), 'debug shows actual minimums')
 check(not pt.contains('verdict.') and not pt.contains('{'), 'all explanation text localized and rendered')
 check(session.submit(accusation(data,selected),true).has('error'), 'diagnostic does not reopen case')
 L.set_locale('en')
 var en = P.verdict_text(report, session.characters())
 check(en.contains('discovered, but not submitted') and en.contains('Incomplete argument'), 'English explanation names same omission')
 L.set_locale('pt_BR')
 var undiscovered_session = session_with(data,selected)
 var hidden_report = undiscovered_session.submit(accusation(data,selected),true)
 check(not hidden_report.debug.evidence.time_record.discovered and P.verdict_text(hidden_report,session.characters()).contains('não descoberta'), 'distinguishes evidence never discovered')
 var fixed = selected + ['time_record']
 var solved = session_with(data,fixed).submit(accusation(data,fixed),true)
 check(solved.outcome == 'solved' and solved.debug.evaluation.scores.culprit == 3, 'submitting timing record supports original solution')
 check(solved.debug.evaluation.total == 7, 'converging identity arguments do not count twice')
 check(session_with(data,selected).submit(accusation(data,selected)) == {'outcome':'insufficient_case'}, 'normal verdict exposes no diagnostic or hidden evidence')
 check(Data.encode(data) == snapshot, 'diagnostic never mutates factual case')
 var wrong = accusation(data, selected)
 wrong.method = 'gunshot'
 var wrong_report = session_with(data,selected).submit(wrong,true)
 check(P.verdict_text(wrong_report,session.characters()).contains('não corresponde à verdade'), 'incorrect explanation is distinguished from insufficient proof')
 var invalid = selected + ['nonexistent']
 var ignored_report = session_with(data,selected).submit(accusation(data,invalid),true)
 check(P.verdict_text(ignored_report,session.characters()).contains('Não consideradas: nonexistent'), 'invalid attachment explained')
 var counterproof_tested = false
 for seed_value in range(100):
  var contextual = Generator.new().generate(seed_value).case
  if not contextual.evidence.has('earlier_assistance') or contextual.evidence.has('residue_removal'): continue
  if contextual.evidence.earlier_assistance.properties.person != contextual.truth.culprit: continue
  var culprit_index = contextual.truth.culprit.trim_prefix('person_')
  var ids: Array = ['contact','wardrobe','sighting_'+culprit_index,'time_record','scene_trace','conflict_'+culprit_index+'_record']
  var contextual_session = session_with(contextual,ids)
  var count = contextual_session.discoveries().size()
  var contested = contextual_session.submit(accusation(contextual,ids),true)
  var material = contested.debug.evaluation.arguments.filter(func(argument): return argument.inference_id == 'material_identity')
  check(material.size() == 1 and material[0].status == 'contested' and not material[0].blockers.is_empty(), 'causally applicable counterproof explains defeated material argument')
  var text = P.verdict_text(contested, contextual_session.characters())
  check(text.contains('Contestação aplicável:') and text.contains('não descoberta'), 'unknown counterproof explicitly labeled in opt-in debug')
  check(contextual_session.discoveries().size() == count, 'revealing diagnostic does not discover counterproof')
  counterproof_tested = true
  break
 check(counterproof_tested,'counterproof regression exercised')
 var desk = load('res://ui/main.tscn').instantiate()
 root.add_child(desk)
 await process_frame
 desk.seed_input.text = '258361'
 desk._open_seed()
 for id in data.evidence:
  if data.evidence[id].kind == 'testimony':
   desk._show_room('lobby')
   desk._talk('porter')
   desk._ask('porter',id)
  else: desk._inspect(id)
 check(not desk.inspector_body.text.contains('ANÁLISE DA ACUSAÇÃO'), 'no analysis before submission')
 desk.selected_proofs.assign(selected)
 desk.culprit_choice.select(2)
 desk.motive_choice.select(1)
 desk.method_choice.select(2)
 desk.debug_toggle.button_pressed = true
 desk._submit()
 check(desk.inspector_body.text.contains('descoberta, mas não apresentada') and desk.finished, 'actual UI renders diagnostic after closing case')
 if DisplayServer.get_name() != 'headless':
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://tests/results/verdict_feedback.png')
 print('Verdict feedback checks: ',checks,'; failures: ',failures.size())
 quit(0 if failures.is_empty() else 1)
