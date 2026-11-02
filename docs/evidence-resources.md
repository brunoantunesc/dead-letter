# Catalog authoring with Resources

Implementation of [#11](https://github.com/brunoantunesc/dead-letter/issues/11), extended by the causal network in [#2](https://github.com/brunoantunesc/dead-letter/issues/2). Authoring keeps IDs and text separate from logic. Later network integration is described in [network and placement](evidence-network.md).

## Where to edit

Open the project in Godot 4.6.2. Open a file under `data/catalog/definitions/` in the FileSystem panel to edit its Inspector fields. Types such as EvidenceDefinition, EvidenceVisual, EvidenceRelation and EvidenceCatalogData are also available through **New Resource**.

- `data/catalog/catalog.tres`: explicit index of included definitions, visuals and relations. Adding a file to a folder does not include it automatically.
- `definitions/*.tres`: one model per file, with stable ID, selector, translation keys, parameters and `visual_id`.
- `visuals/*.tres`: independent visual entries. All 37 current entries are pending.
- Relations: save EvidenceRelation Resources and add them to the index. The current index includes 73 production relations with scope and condition examples.
- `localization/messages.csv`: text by language.

The previous JSON was moved to `tests/fixtures/evidence_catalog_v1.json` as a migration reference only. The game does not read it; do not add production content there.

## Register a definition

1. Create an EvidenceDefinition and save it under `definitions/`.
2. Assign a unique, permanent `id`. Titles and filenames do not identify evidence.
3. Fill `selector` with canonical properties. Selectors cannot overlap: each finding must resolve to exactly one model.
4. Set `title_key`, `text_key` and parameters. Each parameter has `field` and `format`: person, term, location, time or value. Row formatting follows the existing localization contract.
5. Create an EvidenceVisual with its own ID and assign it to `visual_id`.
6. Add both entries to the index, create translations, then run validation and tests.

A model does not create an event: new causal vocabulary and rules still require implementation and tests. Also fill `category_id`, `claim_ids`, `causal_kinds` and `observation_fields`; validation requires categories and counterproof coverage. Parameters are still Inspector-editable Dictionaries; this delivery has no specialized form or graphical network editor.

## Visual reference without artwork

A definition always has a `visual_id` pointing to an existing entry. Several definitions may share an entry when visually justified.

- `pending`: empty `asset_path`. The representation has yet to be produced or selected. This is valid and does not automatically generate an object.
- `ready`: existing `res://` path to a Texture2D, Mesh or PackedScene. The field accepts images, resources and scenes/models; authoring validation checks the loaded type.

`author_note` is a production note, not player text. Assigning an asset does not certify its license or readability; those reviews remain part of asset/presentation issues.

`EvidenceCatalog.visual_for(definition_id)` returns a copy of ID, state and path. Definition resolution and runtime metadata validation do not load artwork. The future visual layer decides when to load the path. The reference identifies a presentation representation, not additional proof, relevance, a guilt variant or an accusation rule.

Procedural object appearance and text are not yet materialized on 3D objects. Do not use “guilty/innocent” asset versions to reveal the solution.

## Relations

The contract includes source claim, contested claim, record rows, additional context and finite predicates. Relations use IDs without file-loading cycles. See [network, conditions and examples](evidence-network.md).

The catalog checks structure; generation and case validation check origins, applicability, chains and sufficiency. A new relation needs a realizable example; valid references alone do not establish investigative quality.

## Verification

Using the installed Godot executable:

```sh
godot --headless --path . --script tools/validate_catalog.gd
godot --headless --path . --script tests/catalog_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/ui_smoke.gd
```

Authoring validation loads assigned assets to check types, without instantiating scenes. Core validation checks metadata and path existence without loading artwork. Run full validation before integrating content.

Tests compare the 25 original presentations with the previous catalog and check independent copies, relation cycles, ResourceSaver/load, broken references, ambiguous selectors, invalid parameters, pending visuals and assigned assets. An original BoxMesh fixture tests a populated reference; it is not production artwork.

The catalog is cached during a run. Restart the test/game after editing content; dynamic reload is not implemented. IDs were retained during migration, but reproduction across future content versions is not guaranteed.

## Current state

Resource authoring now includes 37 models, 73 relations and recursive categories. Results are in `tests/results/catalog.json`, `network.json`, `localization.json` and `latest.json`. The editor recognizes native types; Inspector ergonomics and case quality still need human review. No third-party artwork or GDD changes were introduced.

New trace/room-profile authoring is described in [gameplay-feedback.md](gameplay-feedback.md). The catalog retains medical models for tests and future development but does not distribute them in current cases.

Models can register localized alternatives in `text_variants` and `initial_text_variants`. See [prose authoring and validation](prose-variations.md).

## Physical trace names

`EvidenceDefinition.observable_titles` maps an observable detail token to `title_key` and `short_key`. The five scene-trace models have 25 PT/EN name pairs corresponding to existing physical details. Identification uses the observed detail without consulting guilt or relevance: for example, cut fabric, gravel grooves, a punctured pot, bench splinters and residue in a glass in the garden.

`Presentation.title` and `short_title` resolve names for room lists, inspection, evidence selection, conversations, diagnostics and the board. `Investigation.objects_at` provides `title_token` for initial identification without discovering the evidence or exposing its causal origin. Descriptions and proof rules are unchanged. The board retains the room above the short name.

`tests/trace_title_tests.gd`: 583 checks covering 25 details in both languages, unique full/short names per room, card fit, list/inspection consistency and 100 seeds. Seed 83 reproduces two distinct traces in the garden; `tests/results/trace_titles.png` was inspected. If future generation allows two traces of the same type in the same room, they will need distinct physical supports/positions; the current slice generates different methods.
