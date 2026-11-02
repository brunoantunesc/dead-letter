# Original Python reference

Sources in `python/` were extracted unchanged from `unnamed-investigation-game.zip`. macOS metadata, caches and the nested Git repository were excluded from the reference tree.

ZIP SHA256: `72a7e7b9a7bfe9d961656d30c74e85bf7c12a8713720bb00540a6b17cf99b302`.

Run `python3 reference/python/main.py` to play the original terminal version. Its behavior, including limitations, is preserved.

`python3 tools/characterize_legacy.py` verifies snapshots recorded in `characterization.json`; `--record` intentionally regenerates characterization. The file records Python version, seeds 0–99, seeds with discarded clues and complete cases for seeds 0 and 42. Matching Python and Godot PRNG sequences is not required.

## Assessment and migration

| Original | Retained concept | Core change |
|---|---|---|
| Case / solution | Case/answer separation | Structured snapshot with victim and events |
| ObjectClue, GossipClue, DocumentClue | Observation forms | Data separated from facts and evaluation |
| Suspect | Identities and relationships | Characters participate in events |
| Alternative clue + explanation | Knife/accident/record example | Consequences share a causal origin |
| Weapon and motive catalogs | Knife, rope and three motives | Consistent IDs; small, reviewable content set |
| CaseGenerator / ClueGenerator | Generation/presentation separation | Events precede consequences |
| Terminal | Simple consumer | New consumer without core rules |

The previous generator selects answers and descriptions without chronology or causal origin. Suspect and Solution are not used by generation. The victim has no separate identity. Motive explanations select people independently of the clue they should contextualize. Accounts have no identifiable observer. `poison` does not match the catalog key `poison vial`. `is_true` conflates relevance and factual truth.

In 82 of the 100 characterized seeds, some generated clues never reached rooms. Seed 0 loses a contextual document about a settled conflict. Random distribution and its discarded clues were replaced by causal placement and sufficiency validation. These defects must not become parity requirements.

The original terminal discovers every clue in a room and checks three answers to win, without evidence. That experience was not migrated: the new consumer inspects individual items and requires evidence selection, following the GDD.

## Recovering the experience after the first review

The first migration made investigation too explicit: an eyewitness, authorship identified on the weapon and a single parallel accident. The project owner rejected this. Version 0.2.0 recovered aspects that worked in the reference:

- Proximity creates suspicion rather than declaring guilt; all four suspects had accounts.
- The default `false_count=3` reappeared as three alternative objects with their own contextual incidents.
- Objects show the same generic trace types regardless of their relationship to the crime.
- Multiple people's conflicts and subsequent documents require distinguishing persistent problems from settled matters.
- Alibis and explanations are separate discoveries with compatible events and people, correcting the original's random pairing.

Material comparisons and evaluation requiring submission of the cross-referenced information were added. There is no attempt to reproduce the Python generator, contradictions or discarded clues bit for bit. The reference sources remain unchanged; migration should preserve competing suspicions, not just class names.
