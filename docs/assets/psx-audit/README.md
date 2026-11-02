# PSX pack audit — first delivery

**Date:** 2026-10-30 · **Issue:** [#3](https://github.com/brunoantunesc/dead-letter/issues/3) · **Godot:** 4.6.2.

The package offers a useful base of interiors, furniture and objects. The most consequential gaps are **a Brazilian luxury hotel's identity, readable investigation supports and body/clothing representation**. Much of the current appearance suggests worn residential or industrial spaces; adaptation should retain luxury with localized decay.

All files and 489 GLBs were inventoried. **73 samples were imported and rendered in Godot**, using original materials, without import failures. Work used a temporary project without adding assets to the game, changing the GDD or building the hotel.

The license applicable to the Mega Pack purchase remains unconfirmed. This is a local technical/artistic assessment, not approval to integrate or publish source files.

## 1. Actual contents

Analyzed archive: `Texturas PSX.zip`, 276,777,183 bytes (~264 MiB).

SHA256: `f6f464da268b7831bd649f77c39f0b512b0877726c1bfead0ead7318ba1e3a0c`.

| Content | Count | Note |
|---|---:|---|
| Mega Pack GLBs | 489 | Main model inventory |
| FBX / OBJ / DAE | 489 each | Corresponding exports, not another 1,467 distinct models |
| Geometry-signature groups | 387 | Conservative attribute/index/transform grouping, not artistic-family count |
| Texture images | 389 paths / 363 unique hashes | Identical files exist; do not remove variants based on names alone |
| Supplied previews | 10 | Separate from inventory textures |
| Paper set | 1 glTF + buffer + 3 maps | One mesh combines sheets and stacks |
| Blender file | 1 | Not opened during this audit |
| GLBs with animations / skins | 0 / 0 | No rig or animation in the analyzed exports |

Internal previews mention versions 2.9 and 3.1, but no manifest establishes one ZIP version. The candidate public page already offers another version. The hash identifies the content actually tested; results must not be extrapolated to the seller's current pack.

### GLB categories

| Category | Files |
|---|---:|
| Furniture | 123 |
| Items & Weapons | 116 |
| Modular Structures | 96 |
| Small Props | 44 |
| Electronics & Misc | 38 |
| Lighting | 36 |
| Large Props | 32 |
| Decals | 4 |

Median triangle count is 216 per GLB; the largest is `tunnel_1` at 18,074. Geometry is generally light, but **this is not an FPS or memory benchmark**. Structural analysis found no GLB primitive missing UV0. The inventory includes 31 BLEND and three MASK materials; transparency needs contextual review.

Full details: [inventory](inventory.json), [sample manifest](sample_manifest.json), [individual assessment of 73 samples](sample_assessment.json).

## 2. Observed visual selection

Each sheet shows file ID and imported dimensions. Framing is normalized for comparison: a key appears large in its thumbnail, but its actual measurement is still shown. Units are those imported by glTF/Godot, treated as meters in this assessment; production scale must not be normalized from thumbnails.

| Sheet | Examples and assessment |
|---|---|
| [Furniture](previews/furniture.png) | Usable sofas, chairs, tables, display cabinets and cupboards. Beds and prevailing finishes are simpler than the intended hotel. |
| [Structures](previews/structures.png) | Walls, doors, floors, arches and an elevator provide a modular base; finishes and transitions still require dedicated direction. |
| [Investigation props](previews/investigation_props.png) | Key, knife, notebook, tape, clock and bottles are recognizable. Printed book lettering does not supply playable evidence content. |
| [Electronics](previews/electronics.png) | CRT, radio and buttons have adaptation potential. Computer interfaces, phones and recognizable signs suggest a specific period. |
| [Lighting and materials](previews/lighting_materials.png) | Lamps, carpet, picture and curtain rod are present. The rod has no curtain; painted highlights do not illuminate a scene. |
| [Service](previews/service.png) | Boxes, pipes, packaging and tools support maintenance spaces. Very dirty toilets do not automatically represent guest bathrooms. |
| [Papers](previews/paper_set.png) | Sheet/stack forms exist, but presentation and scale need preparation; the atlas has decorative printed text. |

“Reuse as a base,” “adapt” and “avoid in this slice” are suitability judgments conditional on licensing, not final art approval. Avoiding an object in this slice does not mean it can never exist in the game's world.

## 3. Godot technical results

- **73/73 samples loaded and rendered:** 72 GLBs and the paper glTF. See [godot_report.json](previews/godot_report.json).
- **Scale:** `sofa_1` is 2.60 m wide; `chair_mp_3` is ~1 m tall; `key_mp_1` is ~7.35 cm long. These are usable base proportions. Modules have different outer dimensions: wall ~4.09 m, floor ~4.04 m, selected arches 3 m. This does not prove faulty joins, but prevents treating every AABB as one grid without an assembly test.
- **Orientation:** samples were recognizable without a global axis correction. Tested doors/cabinets include separate child parts. Not all opening pivots or module combinations were tested.
- **Materials:** 144 sample material references use nearest filtering with mipmaps; five use linear with mipmaps. Much of Mega Pack already preserves pixels. Resizing everything to 64×64 is not a general solution.
- **Textures:** Mega Pack images reach 930 pixels on one axis; all three paper maps are 2048×2048. Non-power-of-two dimensions and different atlases exist. Paper PBR materials need harmonization, especially under strong light.
- **Lights:** none of the 73 models supplied Light3D nodes. Some materials emit and some geometry fakes lights. Ambient/source lighting, contrast and possible shadows are integration/rendering work.
- **Collisions:** no CollisionObject3D appeared in samples loaded by GLTFDocument. Colliders, click areas and interaction rules need pipeline preparation; they are not missing visual assets.
- **Readability:** notebooks/books use writing as texture; the paper atlas has no localized game content. Names, times, signatures and evidentiary numbers must separate object appearance from text generated using IDs and selected language.
- **Papers:** the set spans ~24.02 × 1.89 × 22.58 units and arrives as one mesh. It is not a ready A4 sheet. Separation and scale calibration are required. Framing the set does not establish readability of individual documents.

This test has no game PSX shader, benchmark, navigation, interaction or assembled hotel. Standardized rendering assesses assets, not final gameplay atmosphere.

## 4. Coverage for the first hotel slice

| Need | Observed coverage | Reuse and gap |
|---|---|---|
| Reception | Partial | Desks, chairs, clocks, keys and buttons exist. No reception counter, key rack, bell or specific administrative furniture was found in exports. |
| Lounge and guest room | Partial | Sofas, tables, cupboards and beds. A coherent finish/textile set communicating sophistication is missing. |
| Circulation | Good geometry base | Doors, arches, stairs, elevator, windows and walls. Confirm joins, openings, materials and lighting before a complete layout. |
| Kitchen and service | Partial | Boxes, knife, plates and individual utensils. No sink, stove, pantry equipment or complete kitchen furniture was found. |
| Documents/records | Partial forms; no content | Notebook, books and papers need forms, hotel identity and readable localized text. |
| Current evidence supports | Partial | Knife, pistol and keys exist. No rope, coats, blood/fingerprint/fibre traces or ready evidentiary states were found. Generic vials need functional adaptation. |
| Body and people | Absent from exported set | No identified characters/corpses, rigs or animations. NPC visibility/behavior remained an open GDD decision at audit time; do not assume a complete 3D cast is immediately required. |
| Analog equipment | Partial | Radio, tape, clocks and CRTs. No desk phone, typewriter or specific analog investigation equipment was found. |
| Brazilian identity | Very limited | Samples include “ELEVATOR,” dollar bills, packaging and interfaces outside the context. Signs, records and objects with local history are needed. Dollars can exist contextually, but must not be the only financial vocabulary. |
| Luxury and decay | Selection/adaptation needed | Carpet, display cabinets and wood help. Ordinary/worn finishes prevail; signature pieces and maintained/used/damaged states are missing. |
| Exterior/garden | No relevant coverage identified | No vegetation, landscaping or hotel facade was found. Defer if the first slice is indoors. |

“Absent/not found” refers to the GLB inventory, paper glTF and visual selection. Corresponding formats and the Blender file were not examined for additional content. Do not infer absence solely from file counts or newer-version advertisements.

## 5. Largest gaps and priorities

Effort is comparative, not an hourly estimate: **low** = selection/simple material/text work; **medium** = small original pieces, composition or state preparation; **high** = characters/rigs or a broad architectural set.

| Priority | Gap | Impact | Proposed action | Effort |
|---|---|---|---|---|
| P0 — first 3D slice | Readable documents and traces | Investigation requires distinguishing observations; a blurry texture cannot carry a decisive time/signature. | Prepare a document, record and object with observable states using existing IDs/localization; reuse only paper/notebook physical forms. | Medium |
| P0 — first 3D slice | Reference body/clothing for the crime | The pack does not supply the human/material comparison elements used by the core. | Define a static visual-test proxy and actual inspectable body/clothing needs before commissioning a cast. | Medium; animated cast is high |
| P0 — environment identity | Reception recognizable as a Brazilian hotel | Generic furniture suggests an apartment or storage room. | Reuse desks/cupboards and add a small counter, register, key-rack and signage kit; submit the visual language to the owner. | Medium |
| P1 | Luxury finishes with localized wear | Without maintenance hierarchy everything looks equally abandoned. | Select wood, metal, floor and upholstery; make a few coherent states and a signature piece rather than replace the whole pack. | Low to medium |
| P1 | Analog equipment and graphic identity | Modern phones/desktops and English signs weaken the established material language. | Prioritize desk phone, physical records and panels; adapt existing screens/signs. Final tool selection requires a design decision. | Medium |
| P1/P2 depending on room | Pantry/kitchen and service utensils | Few elements communicate a functioning hotel. | Complete only the selected room; do not build a whole kitchen for a reception/lounge test. | Medium |
| P2 | Facade, garden, vegetation and large cast | These do not block an initial interior sample. | Plan after approving an indoor composition and deciding NPC presence/behavior. | High |

Before another pack purchase, test a **single reception or lounge composition** using the available base, one signature piece and an inspectable document. This allows material language/readability approval. It is a next-step recommendation, not a scene created by this audit.

## 6. Provenance and permissions

### Papers

The glTF's `license.txt` and `asset.extras` identify **Marim_Studio**, the [source model](https://sketchfab.com/3d-models/low-poly-papers-set-2edf57ce2e6c4475bd4897b9c91b0a77) and **CC BY 4.0**. Attribution must retain author, source/license and indicate changes, following the [official summary](https://creativecommons.org/licenses/by/4.0/). Web access to the model returned 403, but both local records agree. Do not extend this license to Mega Pack.

Supplied base credit: Low-poly Papers Set, by Marim_Studio, via Sketchfab, CC BY 4.0. Add the actual adaptations when made.

### Mega Pack

The [Pizza Doggy page](https://pizzadoggy.itch.io/psx-mega-pack) matches supplied previews/categories; purchase provenance remains unconfirmed by receipt/link. The user reported purchasing it on itch.io.

The public agreement retrieved on 2026-10-30, dated 2026-09-01, allows commercial games and adaptations under conditions; it restricts reusable source redistribution and AI-related uses. Section 12 ties the license to acquisition date. **Confirm the version applicable to the purchase before integration or AI-assisted asset creation/adaptation.** Purchase does not imply unrestricted licensing.

Consulted PDF: `License Agreement.pdf` in Downloads; SHA256 `22e90e1ca9e2f01d0a6917eb867ba74613dd958ed7ff6405ef5c5ea6337d27f4`. Evidence and outstanding questions are in [license_review.json](license_review.json). The ZIP and pack source files were not published.

## 7. Reproduction and delivery state

From the project root with the local ZIP available:

```sh
python3 tools/asset_inventory.py
cp tools/asset_audit_project.godot /tmp/dead-letter-asset-audit/project.godot
```

Run installed Godot using the temporary project:

```sh
godot --path /tmp/dead-letter-asset-audit --script "$PWD/tools/render_asset_audit.gd" -- "$PWD/docs/assets/psx-audit/sample_manifest.json" "$PWD/docs/assets/psx-audit/previews"
```

Inventory uses standard Python without installing dependencies. Rendering uses installed Godot. Extracted models stay in `/tmp/dead-letter-asset-audit/source`, outside production. Documentation retains ZIP paths, hashes and reports; it does not copy third-party sources into the game.

**Delivered:** inventory, conservative deduplication, 73 renders grouped into seven sheets, technical results, sample assessments, coverage matrix and priorities. **Pending:** applicable Mega Pack purchase license/version and owner review of artistic choices. At audit delivery, gameplay, GDD and production assets were unchanged; no commit or issue closure had been performed by that audit task.
