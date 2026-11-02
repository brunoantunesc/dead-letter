# Counterproof network and placement by physical support

Implements the direction of #2 on top of #11 authoring. The owner's decision for this stage: **consider every existing, applicable counterproof**, including undiscovered or unsubmitted ones. Remove only the contested argument, without extra penalties or an automatic conclusion of innocence.

The GDD was not changed. Experimental weights and thresholds remain unchanged.

## Data and responsibilities

The catalog has **37 definitions, 73 relations, nine support categories and 37 pending visual references**. The previous 25 IDs were retained. Six contextual models added earlier cover prior contact, residue removal, borrowed-garment handover, medical addendum, service completion and equipment-use records. Later additions cover scene traces and service timing.

- Resources under `data/catalog/definitions/`: models, parameters, possible claims, categories and originating event types.
- `data/catalog/relations/`: counterproof relations, scope, conditions and dependencies on other claims.
- `data/catalog/categories/`: physical/documentary hierarchy. It does not classify guilt or relevance.
- `data/catalog/hotel_placement.tres`: hierarchy of logical placement points.
- `core/evidence_network.gd`: applies relations to existing findings and resolves chains.
- `core/evidence_placement.gd`: traverses the support hierarchy and assigns each finding an admissible point.
- `core/case_validator.gd`: checks causal origin, chronology, garment possession, rederived relations, placement and sufficiency.

`catalog.tres` is an explicit index; new files must be included. Relations are indexed by models present in the case, avoiding comparisons between every model and every hotel object.

## What a relation means

An observation may support different claims. A relation contests one of them:

| Source → target | Contested claim | Required scope |
|---|---|---|
| Recorded attendance → passing account | Proximity supports participation in the crime | Same person; attendance elsewhere covers the crime window |
| Prior contact → found fragments | The material identifies contact during the crime | Same fabric/thread, argument subject and contact before the window |
| Residue removal → prior contact | That prior contact still explains the fragments | Same material; removal later than contact but before the crime |
| New contact → residue removal | Removal rules out any later residue | Same material; contact after removal and before the crime |
| Coat handover → laundry record | The recorded person still had the garment during the crime | Material, previous owner and time after the record |
| Medical addendum → examination | The earlier finding is the principal finding for the method | Report identity, different finding and later revision |
| Accident/routine use → object | The traces can only have a criminal origin | Same object instance, not merely the same type |
| New use → earlier incident | The incident explains the entire later history | Same instance and later use |
| Settlement/reopening → conflict | The earlier state still determines the motive | Same person and subject; change before the crime |
| Repair/new request → service record | The issue remains open or permanently resolved | Same person, problem and temporal order |

An accident does not erase an object, and legitimate use does not make a weapon incompatible with injuries. Therefore `criminal_origin` and `injury_method` are different claims. The evaluator rejects only arguments whose `inference_id`, target and person match the active counterproof.

The catalog includes entries with no probative force for the murder, such as room-service requests. Having a possible counterproof does not turn an everyday fact into evidence of guilt.

## Relation authoring contract

- `source_definition_id` and `target_definition_id`: source and target models.
- `source_claim_id`: source claim required for the counterproof.
- `target_claim_id`: target claim being contested.
- `source_rows` / `target_rows`: select a record row where needed; do not attribute every row to the same person.
- `context_definition_id`: additional contextual observation, such as the record establishing the time window.
- `subject_field`: path to the affected person for a personal relation.
- `equal_fields`: simple correspondence between properties of two observations.
- `conditions`: finite predicates eq, ne, lt, lte, gt, gte. Each condition has `left` and `right` paths or a literal `value`. Every condition must hold.

Paths are restricted to declared properties, rows and permitted origin metadata. Conditions cannot execute content scripts, SQL or arbitrary expressions, or access crime truth.

Every definition, including new counterproofs, has a possible incoming relation. Validation rejects missing references, unknown claims, invalid scope parameters, ambiguous selectors and missing coverage. This does not replace a causal example for a new relation.

## Chains without solving the investigation for the player

Type-level relations may form cycles: contact may qualify removal, and removal may qualify contact. Instance-level people, materials and times determine which links actually exist.

A counterproof is active only if its source claim is not defeated by another active counterproof. Resolution uses active, defeated and unresolved states. An instance cycle without external grounding invalidates the case; the system does not choose an arbitrary solution.

Internal connections, categories and placement points are not returned by public discovery APIs. The player board stays free. Contested-argument diagnostics appear only in the development result after accusation.

## Categories and recursive placement

The category tree is:

```text
evidence
├── material
│   ├── material.object
│   └── material.trace
├── record
│   ├── record.administrative
│   ├── record.medical
│   └── record.personal
└── support.testimony
```

The environment tree is independent. A point may accept an ancestor category: a `record` support accepts medical, administrative and personal documents. Ancestor category/accessibility restrictions are inherited.

Supported example: environment → room → cabinet → drawer → inspection point. Selection recursively traverses descendants. The definition chooses the support type; causal origin and observation location constrain the search. Placement does not move a physical trace into another room to fix insufficient space.

The current hotel uses generic logical points for documents, objects, traces and testimony in each room, with IDs fixed between runs. **This system does not yet materialize furniture, coordinates, collisions, physical capacity or 3D scenes.** Concrete supports can replace the layout without changing evidentiary relations. The placer accepts another layout Resource.

The snapshot stores the tree and each finding's `placement_id`. Validation rederives the tree, checks location and rejects incompatible points, broken references, accessibility tampering and category cycles. The core still checks travel costs and sufficiency.

## Generation and reproduction

Schema 6, generator 0.7.0, content `hotel_prose_1`. The [gameplay review](gameplay-feedback.md) supersedes the earlier slice: 15–16 observations, two concrete contacts with the victim, pending autopsy, service timing separate from traces and five possible crime environments. Current generation does not assign independent-use explanations to the actual weapon.

The same seed/version reproduces events, relations and points. The hotel floor plan remains fixed. There is no global frequency history across runs; content is still authored and limited.

## Validation and human review

```sh
godot --headless --path . --script tools/validate_catalog.gd
godot --headless --path . --script tests/catalog_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tests/ui_smoke.gd
```

Network tests cover absence/presence, undiscovered/unselected counterproofs, incorrect person/material/object/time, counterproof chains, no automatic innocence, garment loans, medical context, motives, cycles and recursive container searches. `tests/fixtures/network_witnesses.json` contains partial applicability examples for all 73 relations, not complete simulated worlds. Full cases cover central families and the seed batch.

**Review in the desk: seeds 0 and 3.** They show the same found-material description with different contexts. Investigate each without consulting truth before the verdict. The private `tests/results/network.json` report records the expected difference. Seed 914368 remains the historical regression and now contains 15 observations.

Human review of difficulty, readability and investigative fairness remains in #4. Automated validation does not certify subtlety. New relations need player-perceptible context; comparisons of similar objects will need distinguishable visual/textual identification in their future presentation.

The network delivery passed 468 network checks and 4,101 core checks across 101 seeds, plus catalog, localization and UI checks. See [consolidated validation](validation.md) for current counts. Automatically selected review seeds do not replace a human play session.

## Stage limits

The counterproof network is data-driven and integrated. Event builders and support operators still contain GDScript vocabulary/rules; this is not a complete simulation editor or a wholly data-authored proof system. Relations do not invent missing events.

Authored loan and medical-addendum cases are tested; default rotation does not select every family yet. No forensic tools, random medical errors, cast assets, progression or 3D hotel changes were added.

Medical definitions are legacy and absent from current generation. Timing relations use `time_record`, not an examination. Scene marks have potential counterproofs through an independent incident involving the same instance and causal origin. A mark's existence does not automatically confirm a hypothesis.

The [first interrogation slice](interrogation.md) moves the two porter accounts into conversations, adds NPC positions and clarifies the equipment record within the same evidence entry.

[Prose variations](prose-variations.md) are localized Resource alternatives selected by seed without changing facts or evaluation.
