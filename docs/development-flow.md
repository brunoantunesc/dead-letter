# Development workflow — first playable investigation slice

Planning approved on 2026-10-30. This document organizes delivery; it does not change the GDD or approve unresolved design decisions.

## Milestone objective

In the [first playable investigation slice milestone](https://github.com/brunoantunesc/dead-letter/milestone/1), a player should be able to investigate two distinct cases in a small hotel section, examine evidence, organize hypotheses and submit a supported accusation. Human review must assess the investigation as well as consistency tests.

## Deliverables and dependencies

| Issue | Deliverable | Completion dependencies |
|---|---|---|
| [#11](https://github.com/brunoantunesc/dead-letter/issues/11) | Resource catalog, relation contract and pending visual references | Technical preparation for #2; does not implement counterproof policy |
| [#2](https://github.com/brunoantunesc/dead-letter/issues/2) | Data-driven evidence and counterproof catalog | Approve counterproof policy before changing accusation outcomes |
| [#3](https://github.com/brunoantunesc/dead-letter/issues/3) | Asset audit and gap assessment | Consolidate report, review and provenance/license questions |
| [#4](https://github.com/brunoantunesc/dead-letter/issues/4) | Investigative quality of short cases | #2; protocol can be prepared beforehand |
| [#5](https://github.com/brunoantunesc/dead-letter/issues/5) | Define the first hotel slice | #3 findings and scope approval |
| [#6](https://github.com/brunoantunesc/dead-letter/issues/6) | Prepare selected assets | #3, #5 and permissions for assets used |
| [#7](https://github.com/brunoantunesc/dead-letter/issues/7) | Procedural case in 3D exploration | #2, #5 and #6; #4 guides case selection |
| [#8](https://github.com/brunoantunesc/dead-letter/issues/8) | Readable, localizable evidence | #7; visual preparation can accompany #6 |
| [#9](https://github.com/brunoantunesc/dead-letter/issues/9) | Board with cards, connections and marks | Brought forward for the current desk; #7 does not block the first version |
| [#10](https://github.com/brunoantunesc/dead-letter/issues/10) | Complete-cycle validation | #4, #7, #8 and #9 |

Dependencies are described in issue bodies; they are not registered as native GitHub blocking relationships.

## Execution order

1. Prepare Resource authoring in #11, prioritize #2 and consolidate audit #3. Prepare the #4 protocol and #5 proposal alongside this work where pending decisions do not block them.
2. Review case quality in #4 using the early #9 board, and approve the #5 slice. Do not expand content to disguise logic or presentation problems.
3. Prepare only the selected assets in #6; integrate data and exploration in #7.
4. Complete evidence readability in #8 and integrate the #9 board with 3D discoveries.
5. Run integrated review in #10; record failures before closing the milestone.

This order allows independent technical work but does not authorize unresolved creative decisions.

## Task tracking

Use the conceptual states **upcoming → ready → in progress → in review → done**. These define the tracking protocol; a GitHub Project with these columns has not been created.

- **Upcoming:** defined scope with remaining dependencies or decisions.
- **Ready:** dependencies satisfied, documentation consulted and verifiable criteria available.
- **In progress:** work started; record findings, blockers and scope changes in the issue.
- **In review:** concrete delivery, completed validation and documented limits; human review pending where applicable.
- **Done:** acceptance criteria verified, documentation updated and relevant outstanding items resolved or explicitly moved to another issue.

Issue open/closed state is authoritative for completion. Until a project board exists, record meaningful stage changes in issue discussions. Avoid unnecessary simultaneous implementations.

## Decisions and validation

Before implementation, read the issue, GDD, AGENTS.md and existing contracts. Record questions that affect experience, difficulty or rules.

Important decisions should record the problem, options, proposal, owner's decision and approval link. Approval to create an issue does not automatically approve its design alternatives.

Identified approval points:

- #2: approved policy for this stage — consider all existing/applicable counterproofs, removing only contested arguments, even without discovery/submission. Future changes require another decision.
- #5: rooms, camera/navigation, character/body presence and possible tool use.
- #4 and #10: significant difficulty, clue-budget or victory-rule changes.
- #6: check applicable terms before incorporating assets; purchases still need separate authorization.

Before closing a task, record changes, tests actually executed, affected documentation, limits and human review where relevant. Preserve seed, version and reproduction data for procedural failures. A valid seed batch is not the same as an interesting investigation.

## Starting state and maintenance

Issue #1 contains the initial core delivery and implementation comment. It stays open pending criteria review; this plan does not close it or assume approval of the entire original scope.

Audit #3 has a local report in [docs/assets/psx-audit/README.md](assets/psx-audit/README.md), including outstanding questions. The [other-pack research](assets/psx-audit/author-packs.md) is a recommendation, not a purchase or integration.

This document describes the sequence, not daily status. Consult issues for current progress. Update dependencies here and in issues when planning changes.

The full hotel, roguelite progression, animated cast, advanced dialogue and complete forensic tools are outside this milestone. Create specific tasks after demonstrating the first investigative cycle.

The current network and logical distribution are described in [evidence-network.md](evidence-network.md). Issue #2 still requires full acceptance review: support operators are not entirely data-driven, and human case review remains pending.
