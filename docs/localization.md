# Evidence IDs and localization

Each finding has an **instance ID** (`id`) and a **definition ID** (`definition_id`). For example, `object_0` is an instance of `object.knife`. IDs are not text and do not change with language. Instances are unique only within a case; global identification must include case identity and version.

Events, origins, arguments, discoveries and accusations use IDs and structured properties. The current snapshot does not store Portuguese titles or descriptions. Brazilian proper names remain identities; generic names, locations and roles are translated.

## Authoring files

- `data/catalog/catalog.tres` and `data/catalog/definitions/*.tres`: 37 possible Resource definitions, with selector, title/description keys, parameters and `visual_id`. Short cases contain 15–16 instances. See [authoring and visual references](evidence-resources.md).
- `localization/messages.csv`: keys in `key`, `pt_BR` and `en` columns, covering evidence, terms, locations, interface and verdicts.
- `localization/languages.json`: language names offered by the selector.
- `ui/localization.gd`: registers messages with Godot's native `TranslationServer` and applies named parameters.
- `ui/presentation.gd`: renders catalog parameters and rows without access to factual truth.

An instance with `definition_id: object.knife` resolves the catalog key `evidence.object.knife.body`. The selected language determines that key's text. Do not compare titles to recognize a knife.

## Translation and content

To add a language, add a Godot locale-code column to the CSV, translate every row and add its name to `languages.json`. Preserve parameters such as `{person}`, `{time}` and `{entries}`; their positions may change. UI code changes are not required. Tests automatically traverse declared languages and verify keys and parameters.

For a variant within the existing vocabulary, create a Resource with a stable ID and non-overlapping selector, add it to the index, declare `title_key`, `text_key`, parameters and `visual_id`, and add messages in every language. Available formats are `person`, `term`, `location`, `time` and `value`; multiline records use `rows`. The visual can remain pending.

Translate complete sentences. Do not concatenate translated words to build sentences. Dedicated record-row templates allow grammatical reordering. Player-authored notes are not translated or rewritten.

A new event type still needs causal rules; writing text does not create an investigative mechanic.

## Behavior and distribution

The selector changes language during investigation and after the verdict. It preserves seed, session, discoveries, notes, accused/motive/method, selected evidence and closure. It does not generate another case. The preference lasts for the current execution; persistence between executions is not implemented.

The terminal accepts `--language=en`. Observation data retains canonical IDs and properties independent of language.

When creating an export preset, include `localization/*.csv` and `localization/*.json` in `include_filter`, because they are read through `FileAccess`. The `.tres` catalog is an explicit dependency and references native Resources. Future visual assets referenced through string paths will need explicit export inclusion and build testing. The repository does not yet have a distributable preset. Editor-imported `.translation` resources are not required by the current loader.

## Scope and counterproofs

The catalog and counterproof network are data-driven Resources. Potential counterproof coverage per type is validated across 37 definitions and 73 relations. Conditions use canonical IDs/properties, never translated titles. See [network and limits](evidence-network.md).

Event builders and support operators still use GDScript. Text or a relation does not automatically generate a new cause. The network stays hidden in normal presentation.

## Verification

`tests/localization_tests.gd` checks keys, parameters, resolution of all 37 definitions, titles/descriptions without unresolved tokens and generation invariance under language changes. `tests/ui_smoke.gd` changes language during investigation and after the verdict, checking state preservation and capturing English screens. Visual review covered Portuguese and English; other languages have not been reviewed.

## Investigation board

`board.*` keys translate controls and card types. Known content still uses evidence, person and location IDs. Note text and connection labels are player-authored and remain untranslated. Language changes preserve board and accusation state. See [controls and limits](investigation-board.md).
