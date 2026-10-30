class Case:
    def __init__(self, solution, context, clues, rooms):
        self.solution = solution
        self.context = context
        self.clues = clues
        self.rooms = rooms

class Solution:
    def __init__(self, culprit, weapon, motive):
        self.culprit = culprit
        self.weapon = weapon
        self.motive = motive