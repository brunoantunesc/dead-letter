# Consolidated validation — 2026-11-01

Godot 4.6.2 installed on this computer. All checks below passed before this stage's commits. The GDD was not changed.

| Check | Result |
|---|---|
| `tests/run_tests.gd` | 4,101 checks, 101 seeds |
| `tests/network_tests.gd` | 468 checks |
| `tests/gameplay_feedback_tests.gd` | 1,095 checks, 102 seeds |
| `tests/prose_variation_tests.gd` | 8,360 checks, 100 seeds |
| `tests/conversation_tests.gd` | 3,760 checks, 100 seeds; also rendered |
| `tests/localization_tests.gd` | 2,048 checks, PT/EN |
| `tests/catalog_tests.gd` | 82 checks |
| `tests/board_tests.gd` | 30 checks |
| `tests/verdict_feedback_tests.gd` | 24 checks; also rendered |
| `tests/trace_title_tests.gd` | 583 checks, 100 seeds; also rendered |
| `tests/board_ui_smoke.gd` | 103 rendered checks |
| `tests/ui_smoke.gd` | Complete rendered desk workflow, zero failures |
| `tests/board_resize.gd` | Board resizing and desk readability, zero failures |
| `tools/validate_catalog.gd` | 37 models, 37 pending visuals, 73 relations; zero errors |
| `tools/characterize_legacy.py` | 100 Python seeds, reproducible snapshots |

Run Godot tests with `godot --headless --path . --script path/to/test.gd`. Omit `--headless` to generate screenshots and validate actual drawing/interaction. Run rendered tests one at a time to avoid window-focus and mouse interference.

Terminal inspection was also verified: seed 42 is solved by acquiring `sighting_0` through conversation with Amadeu alongside material, motive, method and timing evidence. The terminal accepts `--visit`, `--talk` and `--ask`; `--inspect` cannot acquire testimony.

## Consolidated delivery

- Five possible crime environments; unavailable autopsy and physical traces separate from timing records.
- Two concrete encounters with the victim, positioned NPCs and an initial conversation slice using clickable, unhighlighted speech.
- An initially ambiguous record clarified by its related participant, updating the same evidence.
- One card per object, grouped observations and one report entry.
- Board with pins, pile, a bin that stashes cards, expanded reading, short titles and resizing.
- 58 alternative bodies for 28 models, plus two record introductions, in PT/EN.
- Distinct observable trace names for 25 room/mechanism pairs.
- Post-verdict diagnostics with arguments, gaps, counterproofs and actual minimums.
- Enlarged desk/conversation/report/board text; accusation footer accessible in smaller windows.

## Evidence and limits

JSON reports and captures are in `tests/results`. Connected-board images use deliberate test arrangements; the game still starts with an empty board. Readability uses fixed seed 995009 to avoid screenshot changes caused only by random initialization.

Old 914368 and 708272 fixtures remain preserved for historical diagnostics. Do not overwrite them with current generation. `network_witnesses.json` contains partial relation examples, not complete worlds.

Captures were reviewed during implementation. Tests do not certify difficulty, narrative rhythm or investigative quality; those still require human review. The desk is not yet the 3D hotel, dialogues remain a small slice and catalog visuals are pending. Closing the game does not save session state.

The local asset ZIP remains outside the commits. No external assets were incorporated in this stage.
