# Conversations and clue clarification — first slice

Owner-approved direction: move clues into interrogations, place characters in coherent rooms and let conversations clarify ambiguous findings. The GDD is unchanged. Implementation uses text in the current desk, without 3D NPCs, psychological pressure or dynamic lying.

## Flow

Entering a room lists its present characters. Encountering them makes their cards available in the pile; conversations do not automatically place cards. **Talk to…** opens initial speech. Phrases in the speech are clickable, using the same color and no underline. The player follows up on a mentioned subject instead of choosing a question that already announces the clue. General instructions explain the gesture without marking relevant phrases.

Amadeu's two accounts of encounters with Vicente were removed from room-object lists. Only asking the porter acquires the testimony. Repeating a question does not duplicate evidence. Direct inspection of testimony IDs is rejected.

The **Equipment record** initially shows checkout, responsible person, time and signs of use without explaining their origin. After discovering it, finding the responsible person and showing the record makes them mention an earlier activity. Following up on that phrase reveals the explanation already established in the causal event. Showing the evidence alone does not complete clarification. The explanation is appended to the same evidence, updating reading, card and accusation entry. It creates no extra proof, changes no facts and awards no extra conversation points. The initial title also avoids revealing the explanatory activity.

Clarification resolves the question of how marks originated; the UI does not confirm guilt, innocence or relevance. The explanation is not invented during conversation. The approved policy of considering existing counterproofs even when undiscovered remains: conversation changes knowledge, not factual argument validity.

## Current positions

The post-removal snapshot uses 20:30 (`investigation_time`), separate from earlier chronology: manager Ana coordinates service at reception; Amadeu is at his reception post; Carlos is in the kitchen; guests Bruno and Diana occupy common areas (lounge, restaurant or garden) chosen by a deterministic stream independent of guilt. The removal officer finishes paperwork at reception; Vicente is absent. The autopsy remains unavailable.

Every living character has an accessible location. Validation checks accessibility and enough travel time from previous events. There is no real-time movement. Current position does not prove a past alibi.

## Contracts

`Investigation.characters_at`, `begin_conversation`, `conversation_topics`, `ask`, `related_proofs` and `present_proof` limit access to the current room and the speaker's factual knowledge. `dialogue` supplies speech fragments with authorized targets; `introduce_proof` introduces a subject from discovered evidence. Opening fragments and keys are in `core/conversation_content.gd`. The presentation picker offers all discovered proofs without filtering by relevance to that NPC. Where no response is authored, the reply is neutral and does not judge guilt or validity. A testimony source can answer only about an event they know. Only the associated participant can clarify the equipment record. Undiscovered evidence cannot be presented, and remote conversation after leaving is rejected.

The session records clarified entries separately from factual snapshots. Public presentation receives `needs_clarification` and `clarified`; truth and weights are not sent to the UI. Text uses PT/EN localization keys. New runs discard previous conversations and clarifications.

Snapshot schema 6, generator 0.7.0, content `hotel_prose_1`. The same seed preserves the previous slice's solution and observations; acquisition changes and current positions are added.

## Limits and validation

Only the two porter accounts and equipment-record clarification are authored in this slice. Other NPCs can be approached and deliver opening speech but have no additional authored branches yet. There are no full dialogues for everyone, photographs, specific responses to every presented clue or new proof arguments derived from speech. Clarification is still limited to this record type; this is not a generic dialogue editor.

`tests/conversation_tests.gd` covers 100 seeds, local access, knowledge, repetition, initial ambiguity, clarification without duplication, factual preservation and clickable speech. Rendered mode generates `tests/results/conversation.png`. Human clarity/gameplay review is still needed.

This version passed 3,760 conversation checks across 100 seeds, 4,101 core checks across 101 seeds, 468 network checks, 1,095 gameplay-regression checks and 103 board UI checks, plus localization and rendered desk workflows. Opening speech, evidence-introduced subjects and clarifications were visually inspected. See [consolidated validation](validation.md) for current localization totals.

The legacy clinical test uses a later snapshot at 21:40 so examination/addendum events and travel precede investigation. This does not enable an autopsy in current generation. Rendered board-drag tests can be affected by desktop mouse events; the final isolated run passed.

Neutral responses have four short PT/EN variants. Selection is reproducible by seed, speaker and evidence, independent of guilt and without consuming generator randomness. Repeating the same presentation keeps the response. No variant introduces a subject or judges relevance.

## Character opening speech

Every approachable NPC has a localized first-person opening instead of a position description. Openings are authored per character independently of crime truth. Ana continues service, Carlos refers to kitchen work, Diana waits in a common area and the removal officer explains that the report is unavailable. Bruno prefers not to comment and explicitly accepts a presented record/object. This reserve does not indicate guilt or alter proof rules; the same opening applies whether he is guilty or innocent. Amadeu retains his opening with follow-up subjects embedded in speech. A neutral default covers future speakers without a specific opening.

[Prose variations](prose-variations.md): localized Resource alternatives selected by seed without changing facts or evaluation.
