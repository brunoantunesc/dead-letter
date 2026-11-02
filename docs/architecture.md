# Procedural core — competing investigative hypotheses

## Approved direction

Godot **4.6.2.stable.official.71f334935** is installed on this computer. GDScript is the production runtime; Python remains an executable reference. Accusations are structured and use selected evidence, without free-text interpretation. Scores remain hidden during investigation; full post-verdict diagnostics are approved for development.

The first version stated authorship, motive and method explicitly and weakened the reference experience. Following the project owner's playtest, the approved direction was to recover the Python structure: proximity accounts, multiple suspicious weapons, competing conflicts and distributed explanations, now backed by causes and validation. The GDD was not changed.

After testing seed 914368, the owner approved a short case with 14–18 observations and two distinct false leads. They also requested different investigative functions and histories: financial conflicts must not be repeated for every suspect. The previous snapshot and transcript were preserved in `tests/fixtures/`.

## Responsibilities

- `case_data.gd`: private snapshot, schema 6, generator 0.7.0 and content `hotel_prose_1`.
- `evidence_catalog.gd`, `core/catalog/` and `data/catalog/catalog.tres`: Resources for definitions, relations and visual references; presentation uses data copies without loading artwork in the core. See [authoring](evidence-resources.md).
- `case_content.gd`: small vocabulary of methods, physical forms and conflicts recovered from the reference.
- `case_generator.gd`: characters, relations, events, consequences and positions. Local PRNG; at most three attempts. Returns snapshots and diagnostics for rejected candidates.
- `proof_rules.gd`: derives internal comparisons from observable properties without consulting crime truth. The UI does not call it to guide the player.
- `case_validator.gd`: checks references, timing, travel, causes, source knowledge, properties, clothing material, contextual explanations, proof rules and sufficiency of reachable evidence.
- `accusation_evaluator.gd`: evaluates accuracy and sufficiency of explicitly selected, discovered evidence.
- `investigation.gd`: separates the private snapshot, discoveries and notes. Exposes only permitted observations.
- `investigation_board.gd`: free organization per session, without access to truth or the causal network; presented by `ui/investigation_board.gd` and `ui/board_canvas.gd`. See [contract and controls](investigation-board.md).
- `ui/main.gd` and `ui/presentation.gd`: testing desk and descriptions. They do not decide relevance or verdicts.
- `tools/investigate.gd`: terminal consumer, without core rules.

No core class depends on Node, scenes, HUDs or assets. The rules do not require loading the 3D hotel.

## Model and causality

The snapshot contains `characters`, `locations`, `entry_location`, `relations`, `events`, `evidence`, `support_rules`, `counterproofs`, `placements`, `truth` and `policy`, plus versioning and investigation-time metadata.

Characters have identity, role, a public accusation-eligibility flag and known events. There are four suspects (Ana, Bruno, Carlos and Diana), Vicente as the victim, Amadeu as the porter and an examination/removal officer. The porter witnesses encounters at reception, not the murder; the officer removes the body. No completed examination is available in currently generated cases.

The eight-location topology remains fixed. The archive may be closed. Connections have travel costs; accessibility refers to the investigation phase. Events precede the session and use relative intervals in minutes. Participation cannot overlap or require impossible travel.

Each event has participants, location, interval, causes, effects and observable consequences. Evidence stores its origin, location, presentation form, properties and human source where applicable. The validator compares consequences with event effects and rejects tampering and silent omissions. Documents may describe events elsewhere; physical objects and traces stay at their origin. Discarding the weapon is a later event with verifiable travel.

Current generation provides no completed examination: service records establish timing and environmental traces support mechanisms. Medical models remain in the legacy catalog and authored tests. Fabric and thread come from physical contact during the event; the weapon is discarded later. Each alternative object comes from an independent use: kitchen accident, rope work, firearm inspection, sporting wear or cleaning. Each conflict has a later decision that leaves it open or settles it.

## Short cases and diversity

The [gameplay review](gameplay-feedback.md) defines the current slice: 15–16 observations, two concrete contacts with the victim, five possible rooms within the fixed floor plan and a pending autopsy. Times are service records; mechanisms are inferred from room-specific marks. Physical consequences are stored in their originating event and respect travel and accessibility.

The catalog has 37 models and 73 relations. Authored profiles in `data/catalog/scenes` describe different consequences by room and method. This slice does not assign an independent-use explanation to the actual weapon. False leads still have their own events.

## Accusation and proof

Input: `culprit`, `motive`, `method`, `evidence_ids`. Unknown or undiscovered IDs are ignored. Discovering information does not automatically include it in the report.

`support_rules` represents evidentiary arguments, not factual truth or player knowledge. Each rule requires observations, a compatible candidate/claim, a weight and an independence group. The validator derives these rules again from properties so an arbitrary label cannot turn a clue into proof.

In the current slice:

- Authorship: comparing material traces (fabric and stitching) with clothing records supports identity. An alternative route excludes three alibis covering the crime window. A temporally compatible proximity account supplies the additional opportunity argument. Identity routes share a group and do not inflate points when both are submitted.
- Method: relevant physical scene traces support the alleged mechanism without requiring the weapon object. The earlier clinical-findings/object route remains in legacy authored tests; it is not an available autopsy in current generation.
- Motive: the contextualized record of an open conflict supports that person's motive. It already includes history and response; no second record is required to repeat the same information. A resolved problem or another person's conflict does not support the accusation.

Experimental policy requires authorship 3 (identity 2 and opportunity 1), motive 2, method 2 and total 7. These are logic-test settings, not final balancing. For each claim/group, only the highest weight counts once. Repeated evidence or copies do not accumulate points.

Sufficient sets contain five or six findings depending on the argument; nine attachments are not required. Authorship can use traces or reconstructed alibis. A closed archive does not block investigation. Evidence copies are not added to fill the map. Automatic validation uses the same evaluator with reachable evidence. This is valid because this slice has no consumable actions, mutually exclusive discoveries or tool prerequisites.

Outcomes are `wrong_culprit`, `insufficient_case` and `solved`. Irrelevant attachments incur no extra penalty; they do not contribute. Approved policy considers every existing, applicable counterproof, even if undiscovered/unsubmitted; only affected arguments stop contributing. See [network and placement](evidence-network.md).

## UI boundary

`Investigation.characters()` returns only ID, name, role and accusation eligibility. `locations()` and `objects_at()` support navigation; `inspect()` reveals one item at a time, without batch discoveries. Testimony is acquired through conversations. `discoveries()` returns observation copies. The evaluator does not read notes.

`submit()` permanently closes the session. Without debug it returns only the outcome. Debug adds truth, failure reasons, scores and argument diagnostics only after submission. The desk enables this development diagnostic by default; it can be unchecked.

Lists support scrolling while the submission button remains visible. Opening another seed or repeating the same seed starts a clean session, without saving or confirmation. The test UI is not the final investigative interface or 3D exploration.

## Reproduction, tests and limits

Record seed, attempt, engine, generator version and content version. Attempt N uses seed + N for the local PRNG. There is no promise of identical results across Godot/catalog versions or an identical random sequence to Python. IDs are stable only within a case and version.

`CaseData.encode/decode` round-trips the private snapshot through JSON; the seed is a string to preserve 64-bit integers. Previous schemas are rejected, without session-save migration (session saving was never implemented). Decoding checks basic format only: validate before consuming a snapshot. This is not a hardened parser for hostile content.

`tests/run_tests.gd` covers seeds 0–99 and regression 914368: reproduction, sufficient or legitimately contested routes, observation budget, thematic diversity, alternative candidates, material ambiguity, absence of wording that revealed authorship, deduplication, causality, chronology, testimony/activity-record sources, the correct person's context, accessibility and serialization. Reports are in `tests/results/latest.json`; generation failures include rejected snapshots.

`tests/ui_smoke.gd` exercises real controls, three verdicts, restart and invalid seeds. Rendered runs capture screens for visual inspection. `tools/characterize_legacy.py` continues checking original examples and known defects.

Limits: events and temporal structure still use a small authored vocabulary. Clothing uses a small combination of features; documented alibis are reliable in this slice. Recurring forms may become predictable after several runs. Observations are directly available; there are no complete forensic tools, continuous simulation, systemic lying, document authentication or progression. The desk's free board allows manual organization without 3D integration. Automated checks guarantee specific properties, not difficulty, subtlety or enjoyable deduction. Human case review remains the investigative-quality criterion.

The validator rejects cases over 18 observations or repeated conflict themes, in addition to consistency checks. The original seed 914368 fixture has 38 observations from version 0.2.0; the short-case test requires the same factual truth and measures the current scope (15 observations without a public autopsy).

## Localization

Each observation exposes `id`, `definition_id`, form, location and canonical properties, without translated titles in the core. Rendering resolves external keys and parameters in the selected language. Locations and roles also use IDs. Switching between Portuguese and English preserves the session. See [localization](localization.md) and [counterproof network](evidence-network.md), including vocabulary/support-rule limits still in GDScript.

## Network and logical placement

The [current specification](evidence-network.md) describes 37 models, 73 relations, nine categories, rotating contexts and an inspection-point tree. Player knowledge does not control counterproof existence or effectiveness. Placement uses support categories, not relevance labels; it preserves causal locations and loads no scenes.

Existing support operators were retained and extended for garment handovers and medical findings. Counterproof relations are external and parameterized. Garment possession is reconstructed through intake/handover chronology; the initial record is not presumed valid after a loan. These additional scenarios exist in tests; default generation does not rotate every family yet.

The board receives only `visited_locations()` and `known_characters()`, plus discoveries. The full roster and desk map do not automatically create cards. Available cards stay in the pile; `placed` controls player placement only. Mentions and conversations are recorded without consulting relevance.

Since version 0.6.0, the desk has no separate notes field. Hypotheses and notes belong to the board; the old `session.notes` field was removed. The public briefing gives body-discovery location and pending-autopsy status without exposing the culprit.

The [first interrogation slice](interrogation.md) moves the two porter accounts into conversations, adds NPC positions and clarifies the equipment record within the same evidence entry.

[Prose variations](prose-variations.md) are localized Resource alternatives selected by seed without changing facts or evaluation.

[Post-verdict diagnostics](verdict-feedback.md) turns the evaluator's trace into localized explanations. The hidden-evidence index is exposed only in the diagnostic return from a closed accusation.

## Investigation desk readability

The desk uses 20 px controls, 22 px reading/conversation/verdict text with line spacing, 16–18 px labels and enlarged headings. Side columns have minimum widths of 260 px and 380 px. The form and evidence list share a scroll area; diagnostics, submission and the closure warning stay in the report footer. This keeps submission accessible in smaller windows without reducing font size. Long NPC names use ellipsis and a tooltip. The board retains its own presentation.

`tests/board_resize.gd` also checks desk reading/footer layout at 1280×820 and 1920×1080, with `desk_readable.png` and `desk_readable_large.png` captures.
