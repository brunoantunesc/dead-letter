"""Record original behavior without fixing it or modifying preserved sources."""
import hashlib
import json
from pathlib import Path
import random
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference/python"))
from generators.case_generator import CaseGenerator


def snapshot(case):
    def clue(item):
        return {key: getattr(item, key) for key in
                ("name", "description", "category", "target", "is_true", "type")}
    return {"solution": case.solution, "context": case.context,
            "clues": [clue(item) for item in case.clues],
            "rooms": {room: [clue(item) for item in clues]
                      for room, clues in case.rooms.items()}}


def generate(seed):
    random.seed(seed)
    return CaseGenerator(["Ana", "Bruno", "Carlos", "Diana"],
                         ["knife", "rope", "pistol", "bat", "poison"],
                         ["jealousy", "money", "revenge"]).generate_case()


report = {"python": sys.version.split()[0], "seeds": list(range(100)),
          "archive_sha256": hashlib.sha256(
              (ROOT / "unnamed-investigation-game.zip").read_bytes()).hexdigest(),
          "seeds_with_discarded_clues": [], "examples": {}}
for seed in report["seeds"]:
    case = generate(seed)
    placed = [item for clues in case.rooms.values() for item in clues]
    if any(item not in placed for item in case.clues):
        report["seeds_with_discarded_clues"].append(seed)
    if seed in (0, 42):
        report["examples"][str(seed)] = snapshot(case)
assert snapshot(generate(0)) == snapshot(generate(0))
destination = ROOT / "reference/characterization.json"
if "--record" in sys.argv:
    destination.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
else:
    recorded = json.loads(destination.read_text())
    assert recorded["archive_sha256"] == report["archive_sha256"]
    assert recorded["examples"] == report["examples"], "Legacy output changed (check Python version)"
    assert recorded["seeds_with_discarded_clues"] == report["seeds_with_discarded_clues"]
print(f"Legacy: 100 seeds; {len(report['seeds_with_discarded_clues'])} with discarded clues; reproducible snapshots OK")
