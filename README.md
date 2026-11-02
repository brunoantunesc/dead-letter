# Dead Letter

A PSX-style murder mystery roguelite set in a hotel in São Paulo, Brazil.

Every run presents a new murder case with procedurally generated suspects, evidence, motives, and relationships. Investigate the hotel and build an accusation supported by evidence of authorship, motive and method.

## Core pillars

- Procedurally generated murder mysteries
- Deduction-driven gameplay
- Interconnected suspects, motives, and evidence
- Atmospheric hotel setting
- Retro PSX visual style
- High replayability

## Status

Early development / pre-production.

The first logic prototype runs on **Godot 4.6.2**. Its GDScript core is independent of scenes and UI. No 3D hotel or final investigation interface is included yet.

## Try the investigation

Open `project.godot` in Godot and press **F5**. The main scene is already configured; no terminal is required.

1. Choose a room and examine objects and documents. For testimony, talk to the NPCs present and click phrases in their speech to follow up. Presenting evidence can introduce another subject.
2. Open the board to organize cards, connections and notes. Return to discoveries whenever needed.
3. In the report on the right, choose the accused, motive and method. Check the discoveries you want to submit as evidence.
4. Click **Close case and submit accusation**. With **Diagnostics after the verdict** enabled, the result explains accepted arguments, gaps and counterproofs, along with the truth and calculations used for development.
5. Use **New case** for a random seed or **Open seed** to repeat a case. Starting a case clears discoveries and notes from the previous session.

This is a logic-testing desk in Portuguese and English. Trace observations are available when examining items; forensic tools and 3D exploration will be integrated later. The screen does not reveal relevance or scores during the investigation.

A short case contains 15–16 observations and recovers alternatives from the Python reference: two concrete accounts of encounters with the victim, two apparently incriminating objects, and financial, personal and professional histories involving different people. Clues do not name the murderer. Accusations require cross-referencing information and can use material traces or reconstructed alibis. The small catalog still has recurring patterns; difficulty requires human playtesting.

## Run the logic tests

Use the installed Godot executable (on this computer, `/Users/brunocosta/Downloads/Godot.app/Contents/MacOS/Godot`):

```sh
godot --headless --path . --script tests/run_tests.gd
python3 tools/characterize_legacy.py
```

The Godot suite writes `tests/results/latest.json`, covering seeds 0–99 plus regression seed 914368 and negative causal/proof cases. Python checks the preserved reference, not the production core.

`godot --path . --script tests/ui_smoke.gd` exercises the actual scene controls, all three verdicts, resetting and invalid seed handling. Without `--headless` it also captures rendered screens in `tests/results/desk_*.png` for visual review.

## Inspect and accuse through the development terminal

```sh
godot --headless --path . --script tools/investigate.gd -- --seed=42
godot --headless --path . --script tools/investigate.gd -- --seed=42 --inspect=contact,wardrobe,time_record --visit=lobby --talk=porter --ask=sighting_0
```

Each command starts a fresh session. Inspection is explicit and selected proof must have been discovered in that session. Omit `--debug` to hide internal scores and truth; debug feedback appears only after the verdict. This terminal lists inspectable items for development and is not the final player interface.

Use `--visit=lobby --talk=porter --ask=sighting_0` to acquire a witness account through conversation. `--inspect` does not acquire testimony.

To accuse, add `--culprit=person_0 --motive=money --method=stabbing --evidence=id,id` with your hypothesis and selected discovery IDs. Add `--debug` for post-verdict diagnostics. A complete accusation can be supported with five or six observations through different arguments; the case contains 15–16 observations total. Duplicate documents are not required.

See [architecture and scope](docs/architecture.md), [original prototype analysis](reference/README.md), and [GDD](GDD.md). Numerical weights are experimental test configuration, not final balancing.

Seed 914368 was preserved before the reduction in `tests/fixtures/`. To compare the revised case in the UI, enter **914368** and click **Open seed**. Its factual truth was retained; distribution and documents were revised. The current version includes routine-use context and contains 15 observations for this seed.

## Localization and text authoring

The header selector switches between **Português (BR)** and **English**, including during a case, preserving discoveries, notes and the report. Each clue has an instance ID and a definition ID; titles and descriptions are resolved in the selected language and are not stored in the core snapshot.

The catalog is in `data/catalog/catalog.tres`, with definitions and visual references in individual Resources; translations are in `localization/messages.csv`. See [Godot authoring](docs/evidence-resources.md). To add a language, add its column and its name in `localization/languages.json`. See [the ID and localization contract](docs/localization.md). The [counterproof network and placement categories](docs/evidence-network.md) already participate in generation and evaluation; human review of investigative quality is still pending.

```sh
godot --headless --path . --script tests/localization_tests.gd
godot --headless --path . --script tools/investigate.gd -- --seed=914368 --language=en
```

## PSX pack audit

The [initial asset assessment](docs/assets/psx-audit/README.md) records the local ZIP inventory, 73 samples rendered in Godot, hotel coverage, priority gaps and outstanding provenance/license questions. Source models have not been integrated into the game.

## Development organization

The [free investigation board](docs/investigation-board.md) is available in the testing desk: **Open board**, choose cards from the pile and **Place on board**, then drag, connect and mark them with **?** or **X**. Rooms become available after a visit; people after a mention or conversation. Closing/reopening preserves session state; a new run clears the board.

The [development workflow](docs/development-flow.md) documents the first playable investigation slice, issues, dependencies, execution order and review criteria. Deliverables are grouped in the [GitHub milestone](https://github.com/brunoantunesc/dead-letter/milestone/1).

## Gameplay review

The [seed 708272 review](docs/gameplay-feedback.md) removed the available autopsy and separate desk notes, refined witness accounts and distributed evidence across five possible crime environments within the fixed floor plan. To compare rooms, use seeds 0, 1, 4, 9 and 14.

- [NPC conversations and clue clarification](docs/interrogation.md): flow and limits.
- [Evidence prose variations](docs/prose-variations.md): alternative wording reproducible by seed in Portuguese and English.
- [Post-verdict diagnostics](docs/verdict-feedback.md): accepted arguments, gaps and counterproofs for case testing.
- [Consolidated validation](docs/validation.md): executed tests, screenshots and current limitations.

## Documentation language

Technical documentation and READMEs are maintained in English. Player-facing text uses the localization system. Original design and agent-instruction documents retain their source language.
