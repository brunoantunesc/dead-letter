import random
from classes.clue import ObjectClue, GossipClue, DocumentClue
from generators.constants import LOCATIONS, TIMES, WEAPON_DETAILS, MOTIVE_TEXT, GOSSIP_FORMATS, DOCUMENT_INTROS, WEAPON_EXPLANATION_DETAILS



class ClueGenerator:

    def _format_gossip(self, text):
        return random.choice(GOSSIP_FORMATS).format(text=text)

    def _random_other_location(self, context):
        return random.choice([
            loc for loc in LOCATIONS if loc != context["murder_room"]
        ])

    def _dedupe(self, clues):
        seen = set()
        result = []
        for c in clues:
            if c.description not in seen:
                seen.add(c.description)
                result.append(c)
        return result

    def generate_clues(self, category, real_value, all_values, context, false_count=3):
        clues = []

        candidates = [v for v in all_values if v != real_value]
        false_values = random.sample(candidates, min(false_count, len(candidates)))

        # TRUE (only one)
        clues.append(self._generate_true_clue(category, real_value, context))

        # FALSE + explanation
        for value in false_values:
            clues.append(self._generate_false_clue(category, value, context))
            clues.append(self._generate_explanation_clue(category, value, context))

        return self._dedupe(clues)

    # =========================

    def _generate_true_clue(self, category, value, context):
        if category == "weapon":
            detail = random.choice(
                WEAPON_DETAILS.get(value, ["there are unusual traces"])
            )
            return ObjectClue(
                name=value.capitalize(),
                description=f"You found a {value}. {detail}.",
                category=category,
                target=value,
                is_true=True
            )

        if category == "suspect":
            text = f"{value} was near the {context['murder_room']} {context['murder_time']}"
            return GossipClue(
                description=self._format_gossip(text),
                category=category,
                target=value,
                is_true=True
            )

        if category == "motive":
            culprit = context["culprit"]
            text = f"{culprit} {MOTIVE_TEXT[value]}"
            return GossipClue(
                description=self._format_gossip(text),
                category=category,
                target=value,
                is_true=True
            )

    # =========================

    def _generate_false_clue(self, category, value, context):
        if category == "weapon":
            detail = random.choice(
                WEAPON_DETAILS.get(value, ["there are unusual traces"])
            )
            return ObjectClue(
                name=value.capitalize(),
                description=f"You found a {value}. {detail}.",
                category=category,
                target=value,
                is_true=False
            )

        if category == "suspect":
            options = [
                f"{value} was seen nearby {random.choice(TIMES)}",
                f"{value} was acting suspicious {random.choice(TIMES)}",
            ]
            text = random.choice(options)

            return GossipClue(
                description=self._format_gossip(text),
                category=category,
                target=value,
                is_true=False
            )

        if category == "motive":
            suspect = random.choice(context["suspects"])
            text = f"{suspect} {MOTIVE_TEXT[value]}"

            return GossipClue(
                description=self._format_gossip(text),
                category=category,
                target=value,
                is_true=False
            )

    def _generate_explanation_clue(self, category, value, context):
        if category == "weapon":
            detail = random.choice(
                WEAPON_EXPLANATION_DETAILS.get(value, ["the item was used earlier"])
            )

            text = detail
            description = random.choice(DOCUMENT_INTROS).format(text=text)

            return DocumentClue(
                title="Report",
                description=description,
                category=category,
                target=value,
                is_true=True
            )

        if category == "suspect":
            other_location = self._random_other_location(context)

            return DocumentClue(
                title="Statement Record",
                description=f"Record shows {value} was in the {other_location} during {context['murder_time']}.",
                category=category,
                target=value,
                is_true=True
            )

        if category == "motive":
            culprit = context["culprit"]
            candidates = [s for s in context["suspects"] if s != culprit]
            suspect = random.choice(candidates)

            return DocumentClue(
                title="Record",
                description=f"Records show {suspect}'s issue with the victim had already been resolved.",
                category=category,
                target=value,
                is_true=True
            )