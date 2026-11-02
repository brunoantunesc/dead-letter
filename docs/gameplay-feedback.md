# Gameplay review — 2026-10-31

Direction approved by the owner after playing seed **708272**: notes only on the board; concrete accounts instead of generic proximity; unavailable autopsy; information distributed around the scene; variable crime location within the fixed floor plan.

## Preserved regression

`tests/fixtures/seed_708272_v0_5_0.json` stores the previous case. The five reported proofs were the activity register, shirt traces, preliminary examination, letter and garment records. They reproduce authorship 2, motive 2 and method 0.

The old method rule required the examination together with an object. Authorship still needed an additional account. Automatically accepting convergence without an account was not adopted: the owner preferred genuinely informative accounts. Thresholds remain authorship 3, motive 2, method 2 and total 7.

In the previous reproduction, the morning incident explains the **rope**. A separate checkout record concerns Ana's **pistol**. New generation removes routine use of the actual weapon and gives incidents more specific titles to reduce confusion.

## Pending autopsy

The case starts with public information about where Vicente was found. The body has been removed and the autopsy is not yet available. Generated cases have no examination-report card, completed-examination event or public medical diagnosis.

Earlier medical definitions remain in the catalog and authored network tests; they are not selected in this phase. This does not enable an in-game autopsy.

Functions formerly concentrated in the examination were separated:

- **Body discovery record:** times of a service visit when Vicente responded and of the discovery of his body. Its source is a service record, not a medical estimate. Events and sources are validated.
- **Environmental traces:** observable marks and room-specific physical consequences. They support interpreting a compatible mechanism, not identifying an individual weapon or presenting a medical conclusion.

Relevant physical evidence can support the method without mandatorily attaching the actual weapon. Everyday accounts do not establish opportunity on their own.

## Accounts and authorship

Two public accounts describe concrete contact with Vicente near the window established by the record. One involves the culprit and another an innocent person; actions are assigned independently of guilt. There is no murder eyewitness.

The porter witnessed a conversation and a handover in a shared event. Participants, times, location and source knowledge are traceable. Other everyday events may exist without generating redundant accounts.

To support opportunity, an account needs explicit contact with the victim and configured temporal proximity in minutes. Applicable alibis may contest the interpretation. Material identification, motive and method still require their own support; an account alone does not solve the case.

## Five crime environments

The floor plan and routes do not change. A separate seed stream chooses lounge, kitchen, garden, storage or laundry, respecting accessibility and profile method coverage.

`core/catalog/crime_scene_profile.gd` and `data/catalog/scenes/*.tres` store room-specific content. `core/crime_scenes.gd` selects profiles and resolves signatures. Each environment has five specific consequences: 25 observable descriptions, not just room-name substitutions. Examples include a puncture in a garden clay pot, a kitchen serving-hatch panel or a storage partition.

Consequences are recorded in event effects rather than placed arbitrarily. Traces stay at their origin. Innocent activities avoid the crime location without impossible travel or overlaps. Post-crime weapon disposal also respects routes.

An independent incident can leave a mark in another environment or in the crime room itself. Its explanation shares the causal origin and object instance, contesting interpretation of that mark as the murder mechanism.

Current independent-use explanations concern only the decoy, never the actual weapon. This validated slice restriction does not mean legitimate uses are impossible in the world in general.

## Quantity and validation

Cases have **15–16 observations**, within the approved 14–18 budget. Removing two redundant accounts and the actual weapon's routine-use record made room to separate timing and scene evidence.

A sufficient route has **five proofs**, without requiring every discovery or the weapon: recent contact, timing, scene mechanism, motive and reconstructed alibis. The material-identification route uses six. Text and relations are not labeled relevant in the interface; the evaluator does not read board connections.

This review introduced snapshot schema 5, generator **0.6.0**, content **hotel_feedback_1**. Seed 708272 retained Diana/jealousy/gunshot as factual truth while observations changed. The current validator does not silently accept old content; the historical file reproduces the previous diagnostic. See [architecture](architecture.md) for subsequent version changes.

Tests:

```sh
godot --headless --path . --script tests/gameplay_feedback_tests.gd
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/network_tests.gd
godot --headless --path . --script tests/localization_tests.gd
godot --path . --script tests/ui_smoke.gd
godot --path . --script tests/board_ui_smoke.gd
```

`tests/results/gameplay_feedback.json` records 102 seeds and review examples: **0 lounge, 1 laundry, 4 storage, 9 kitchen, 14 garden**. Consulting truth before playing is unnecessary.

## Limits

This is logical/textual variety in the testing desk; furniture, 3D traces and tools have not been materialized. Profiles are still authored and the signature vocabulary is limited. Ambiguous signals for new methods require other proof combinations; the resolver does not silently select a method when a signature has several matches.

Automated validation checks explicit properties, not human deduction difficulty or fairness. Gameplay review is still required. No threshold was reduced, no automatic connection was introduced and the GDD was not rewritten.

Validation passed 1,095 targeted checks across 102 seeds, 4,101 core checks across 101 seeds and 468 network checks, alongside catalog/localization tests. Desk and board rendered workflows passed. See [consolidated validation](validation.md) for current totals. Human review of the revised cases remains necessary.
