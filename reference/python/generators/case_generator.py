import random
from collections import defaultdict

from generators.clue_generator import ClueGenerator
from classes.case import Case
from generators.constants import LOCATIONS, TIMES


class CaseGenerator:

    def __init__(self, suspects, weapons, motives):
        self.suspects = suspects
        self.weapons = weapons
        self.motives = motives
        self.clue_generator = ClueGenerator()

    def generate_case(self):
        culprit = random.choice(self.suspects)
        weapon = random.choice(self.weapons)
        motive = random.choice(self.motives)

        rooms = random.sample(LOCATIONS, k=min(8, len(LOCATIONS)))

        context = {
            "murder_room": random.choice(rooms),
            "murder_time": random.choice(TIMES),
            "culprit": culprit,
            "suspects": self.suspects
        }

        clues = []

        clues += self.clue_generator.generate_clues(
            "weapon", weapon, self.weapons, context
        )

        clues += self.clue_generator.generate_clues(
            "suspect", culprit, self.suspects, context
        )

        clues += self.clue_generator.generate_clues(
            "motive", motive, self.motives, context
        )

        random.shuffle(clues)

        room_map = {room: [] for room in rooms}
        room_seen = {room: set() for room in rooms}

        by_category = {
            "weapon": [],
            "suspect": [],
            "motive": []
        }

        for clue in clues:
            by_category[clue.category].append(clue)

        MAX_CLUES_PER_ROOM = 3

        for clue in by_category["weapon"]:
            key = (clue.category, clue.target)

            possible_rooms = [
                r for r in rooms
                if len(room_map[r]) < MAX_CLUES_PER_ROOM
                and key not in room_seen[r]
            ]

            if not possible_rooms:
                possible_rooms = rooms

            room = random.choice(possible_rooms)

            room_map[room].append(clue)
            room_seen[room].add(key)

        for clue in by_category["suspect"]:
            key = (clue.category, clue.target)

            possible_rooms = [
                r for r in rooms
                if len(room_map[r]) < MAX_CLUES_PER_ROOM
                and key not in room_seen[r]
            ]

            if not possible_rooms:
                continue

            room = min(possible_rooms, key=lambda r: len(room_map[r]))

            room_map[room].append(clue)
            room_seen[room].add(key)

        for clue in by_category["motive"]:
            key = (clue.category, clue.target)

            possible_rooms = [
                r for r in rooms
                if len(room_map[r]) < MAX_CLUES_PER_ROOM
                and key not in room_seen[r]
            ]

            if not possible_rooms:
                continue

            room = random.choice(possible_rooms)

            if clue.__class__.__name__ == "DocumentClue":
                if any(c.__class__.__name__ == "DocumentClue" for c in room_map[room]):
                    continue

            room_map[room].append(clue)
            room_seen[room].add(key)

        solution = {
            "culprit": culprit,
            "weapon": weapon,
            "motive": motive
        }

        return Case(solution, context, clues, room_map)