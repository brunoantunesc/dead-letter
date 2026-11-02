# Free investigation board

First version of [issue #9](https://github.com/brunoantunesc/dead-letter/issues/9), brought forward with the owner's approval to test evidence in the current desk. Issue #7's 3D exploration is not a prerequisite. The GDD was not changed.

## Usage

Run the main scene, open a seed, examine items and click **Open board**. The canvas starts empty; known cards stay in the side pile. Select a card and choose **Place on board** to position it manually.

- Drag a card to move it; overlap is allowed.
- Drag the background or use the middle button to pan; the wheel zooms around the cursor.
- **Show all** fits the set within zoom limits without rearranging cards. Widely spread boards may require additional navigation.
- Selecting a card shows its full content in the side panel. The picker also locates and centers it at a readable zoom.
- **Connect cards** starts manual endpoint selection. Click again or press Escape to cancel.
- Select a connection by line or picker to edit its mark/text or remove it.
- Marks: no symbol, **?** (uncertain), **X** (dismissed by the player). Canvas labels may be abbreviated; full text stays in the panel.
- **New note** creates a card at the view center. Edit, move and connect it like other cards. Deleting a note removes its connections.
- **Back to investigation** or Escape closes the board; reopening preserves organization.

There is one undirected connection per pair; selecting the pair again opens it. Cards cannot connect to themselves. **Return to pile** removes a card from the canvas while preserving position, note and links. Links are hidden while either endpoint is in the pile and return when the cards are placed again. Deleting a note instead removes its links.

## Identity and knowledge

| Card | Entry condition | Reference |
|---|---|---|
| Person | Recorded mention or conversation | Person ID |
| Room | Recorded visit | Location ID |
| Evidence | Discovered observation | Observation ID |
| Object | Examined physical object | Object-instance ID |
| Note | Player creation | Board-specific ID |

The development desk's map and suspect roster do not automatically populate the board. Only visited rooms and characters named in discoveries/testimony or recorded conversations enter. The investigation entry counts as visited; the victim named in the briefing counts as mentioned. Initially only reception and Vicente cards are in the pile, with none on the canvas.

Inspecting an item records its location visit and people explicitly named in properties/rows. A testimony/report source also counts as a mention. This does not create conversations by itself; `record_conversation` records that separate action.

An examined object has a single card collecting its discovered observations. New physical findings about the same `object_id` update that card and its expanded reading view. The accusation has one object entry grouping discovered findings. Documents and accounts remain separate sources; mentioning a knife in a document does not discover the physical knife.

The **OBJECT** label does not identify the actual weapon. New cards remain in the pile until placed; knowledge synchronization does not move/place cards. Connections are never created automatically.

## State and architecture

- `core/investigation_board.gd`: cards, positions, notes and connections; imports no generator, evaluator, catalog or causal network.
- `core/investigation.gd`: owns the session board separately from the factual snapshot and discoveries.
- `ui/investigation_board.gd`: receives public API copies, resolves translations and edits player state.
- `ui/board_canvas.gd`: dragging, navigation, zoom and drawing.
- `ui/main.gd`: integrates the desk and board; creates another session for each run.

IDs use `person:`, `room:`, `evidence:`, `object:` and `note:` namespaces. Rediscovery does not duplicate entities. State belongs to the session and can be reused by another presentation.

The evaluator does not read notes or connections. An X does not invalidate proof, a link does not demonstrate authorship and the board does not select report attachments. Accusations still use explicit desk selection. Incorrect hypotheses are accepted without correction.

## Language and aesthetics

Controls and known content are translated in PT/EN. Positions, IDs, marks and player text remain unchanged when switching languages. Notes exist only on the board; the separate desk field was removed.

The owner reaffirmed PSX direction: restrained palette, physical cards, hard edges, unsmoothed lines and raster-like lettering. The support texture is drawn in code without a new external asset. System monospace fonts have platform fallbacks.

Default readability uses 20 px controls/side text and 22 px card titles. The board starts at 1:1 zoom; locating a card through the picker restores at least that zoom. Categories use 14 px on cards and 16 px in the panel. The side panel has a 360 px minimum width; instructions occupy a separate row. Cards can become small when zoomed out; full content remains fixed-size in the panel. Catalog visual references remain pending; evidence artwork has not been invented.

## Validation and limits

Every placed card has the same decorative red pushpin with metal shaft and pixel shadow. It has no hit area or investigative meaning.

The UI uses actual window size rather than stretching a fixed logical canvas. Enlarging/maximizing increases usable board area; shrinking reduces it. Cards retain positions and chosen zoom. The side panel keeps a readable width. `tests/board_resize.gd` checks/renders 1280×820 → 1600×1000 → 1280×820.

```sh
godot --headless --path . --script tests/board_tests.gd
godot --headless --path . --script tests/board_ui_smoke.gd
godot --path . --script tests/board_ui_smoke.gd
```

The rendered test generates `tests/results/board_pile.png` (empty start), `board_evidence.png` and `board_connection.png`. Their arrangement is deliberately authored by the test as an example of player actions, not automatically applied by the game.

Checks cover identities, unknown content, mentions without discovery, observations grouped by object, actual mouse dragging with zoom, marks, notes, removal, language, reopening, restart and unchanged verdicts despite incorrect hypotheses. Human gameplay/ergonomic review is still required; the issue stays open.

On installed Godot 4.6.2, 30 board-state checks, 103 rendered-scene checks, 2,048 localization checks and 4,101 core checks across 101 seeds passed, as did the desk smoke test. PT/EN captures were visually inspected. No complete human investigation session was performed.

Closing/reopening preserves the current session; repeating the seed as a new run creates another board. No disk saving, undo/redo, world photos, filters, causal-network editor or automatic overlap resolution is included. Position and interpretation are logical state; camera and zoom belong to presentation.

## Card-entry revision

The pile is separate from manual placement (`placed`/`was_placed`). The session exposes `visited_locations` and `known_characters`; opening the board synchronizes these lists, not the full generator roster. Visual organization remains independent of truth, probative strength and accusation.

The [gameplay review](gameplay-feedback.md) removed the autopsy from discoveries and added room-specific traces and timing records while retaining progressive card availability.

## Clue identification and expanded reading

Evidence/object cards show discovery location and a short translated name, such as **Lounge — Fibres**. If a clue's dedicated person field names someone, the name appears on a second line to distinguish similar records. Short names are localized separately from full titles; the 37 models are checked against card width in PT/EN.

The **+** icon opens a scrollable reading window with location, full title and complete description. Closing returns to the same board without changing organization, discoveries or hypotheses. It receives only already-discovered public content.

The bin is icon-only and fixed at the canvas's bottom-right corner, independent of pan/zoom. Dropping a card over it returns the card to the pile; the target lights up while dragging. It does not delete discoveries, notes or links. Replacing the card restores its pre-drag position. Dropping elsewhere moves it normally.

Scene traces use short observable-detail names, such as **Garden — Grooves** or **Garden — Splinters**, authored in catalog `observable_titles`. The same detail identifies the evidence on other screens.
