class Clue:
    def __init__(self, name, description, category=None, target=None, is_true=None):
        self.name = name
        self.description = description

        self.category = category
        self.target = target
        self.is_true = is_true
        self.type = "generic"


class ObjectClue(Clue):
    def __init__(self, name, description, category=None, target=None, is_true=None):
        super().__init__(name, description, category, target, is_true)
        self.type = "object"


class GossipClue(Clue):
    def __init__(self, description, category=None, target=None, is_true=None):
        super().__init__("Gossip", description, category, target, is_true)
        self.type = "gossip"


class DocumentClue(Clue):
    def __init__(self, title, description, category=None, target=None, is_true=None):
        super().__init__(title, description, category, target, is_true)
        self.type = "document"