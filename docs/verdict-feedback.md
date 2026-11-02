# Post-verdict diagnostics

Approved improvement to help investigation testing. The GDD and evaluation rules were not changed. Detailed analysis is exclusive to **Diagnostics after the verdict**, after permanently closing the run.

## What is shown

- Summary of gaps in partially submitted combinations.
- Authorship, motive and method: sufficient/insufficient support, with incorrect hypotheses identified separately.
- Accepted arguments, their evidence and the relation they support.
- Incomplete arguments and missing evidence in that combination.
- Causally applicable counterproofs with explanations and discovery/submission/clarification state.
- Other attachments that formed no additional argument for the accusation.
- Technical totals compared with actual policy minimums, plus the internal truth already exposed by the earlier diagnostic.

Missing evidence is labeled **not discovered** or **discovered, but not submitted**. This separates what the player found from what they attached. The summary does not declare a specific clue mandatory for every route; it describes gaps in arguments the player started presenting.

Analysis also explains that arguments about the same fact do not accumulate duplicate strength and a counterproof defeats only the affected inference. Existing, applicable counterproofs remain effective when undiscovered, following the owner's earlier decision. The diagnostic states this explicitly.

## Regression 258361

With the seven proofs reported by the player, authorship remains 2/3, motive 2/2 and method 2/2. The body-discovery timing record was discovered but not submitted. Without it, temporal arguments from testimony and the activity register are incomplete. The material link between fibres and garment records remains accepted.

Submitting the timing record too supports the case, preserving earlier thresholds and evaluation. The diagnostic now explains that relation instead of only stating insufficient authorship support.

## Contracts

`AccusationEvaluator.evaluate` produces a structured trace per argument: inference, required evidence, missing elements, counterproofs and independence group. It derives the trace from the same requirements/attacks used for the result, not a separate evaluation rule.

Previous fields (`scores`, `reasons`, supported/contested comparisons) are preserved. `minimum_by_claim` and `minimum_total` reflect actual policy rather than only fixed text values.

`Investigation.submit` returns only the normal result with diagnostics disabled. Explicitly enabled diagnostics add an observation index for naming/explaining evidence, including undiscovered entries. This index never becomes part of live investigation discoveries.

`Presentation.verdict_text` translates the trace in PT/EN. Inference-type explanations are localized. Testimony uses the location described in speech, not its legacy physical slot from before conversations existed.

Reading/translating diagnostics does not discover clues, clarify session evidence, change the board or reopen the accusation. Hidden explanations used in diagnostics are rendered on copies.

## Validation and limits

`tests/verdict_feedback_tests.gd`: 24 checks. Reproduces seed 258361, distinguishes undiscovered/unsubmitted evidence, confirms solution after supplying timing, checks undiscovered counterproofs, diagnostics disabled, incorrect hypotheses, invalid attachments, no duplicate scoring, immutability and the real scene.

`tests/results/verdict_feedback.png` shows the desk diagnostic with scrolling for the complete analysis. Long text does not change board size or the established aesthetic. Human review during play remains necessary.

Explanations correspond to currently encoded arguments, not natural-language analysis of player hypotheses. New inference types need their own localized explanation. A generic fallback covers types without specific text.
