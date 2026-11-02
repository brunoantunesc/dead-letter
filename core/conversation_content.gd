extends RefCounted
## Authored conversation hooks. Fragment text is localized; actions expose no scores.
const NO_RESPONSE_KEYS = ["conversation.no_response", "conversation.no_response.1", "conversation.no_response.2", "conversation.no_response.3"]
const DEFAULT_OPENING = {"text_key": "conversation.opening.default", "fragments": {}}
const OPENINGS = {
 "person_0": {"text_key": "conversation.opening.manager", "fragments": {}},
 "person_1": {"text_key": "conversation.opening.reserved", "fragments": {}},
 "person_2": {"text_key": "conversation.opening.cook", "fragments": {}},
 "person_3": {"text_key": "conversation.opening.guest", "fragments": {}},
 "examiner": {"text_key": "conversation.opening.examiner", "fragments": {}},
 "porter": {"text_key": "conversation.porter_opening", "fragments": {
  "conversation": {"text_key": "conversation.fragment.conversation", "definition_id": "sighting.0"},
  "handover": {"text_key": "conversation.fragment.handover", "definition_id": "sighting.1"}
 }}
}
const INCIDENT_RESPONSE = {"text_key": "conversation.incident_response", "fragments": {
 "task": {"text_key": "conversation.fragment.task", "action": "clarify"}
}}
