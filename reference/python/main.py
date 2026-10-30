from generators.case_generator import CaseGenerator


def normalize(text):
    return text.strip().lower()


def choose_option(options, label):
    print(f"\n{label}:")
    for i, opt in enumerate(options):
        print(f"{i+1}. {opt}")

    while True:
        choice = input("Choose a number: ").strip()

        if choice.isdigit():
            idx = int(choice) - 1
            if 0 <= idx < len(options):
                return options[idx]

        print("Invalid choice. Try again.")


def run():
    suspects = ["Ana", "Bruno", "Carlos", "Diana"]
    weapons = ["knife", "rope", "pistol", "bat", "poison"]
    motives = ["jealousy", "money", "revenge"]

    generator = CaseGenerator(suspects, weapons, motives)
    case = generator.generate_case()

    visited_rooms = set()
    discovered_clues = []
    rooms = list(case.rooms.keys())

    print("\n=== CASE ===\n")

    # INTRO
    print(
        f"A murder happened in the {case.context['murder_room']} "
        f"{case.context['murder_time']}.\n"
    )

    # MAIN LOOP
    while True:
        print("\n--- ACTIONS ---")
        print("1. Investigate a location")
        print("2. Show discovered clues")
        print("3. Make an accusation")

        choice = input("Choose an action: ").strip()

        # INVESTIGATE
        if choice == "1":
            print("\nLocations:\n")
            for i, room in enumerate(rooms):
                visited = " (visited)" if room in visited_rooms else ""
                print(f"{i+1}. {room}{visited}")

            selection = input("Choose a location: ").strip()

            if selection.isdigit():
                idx = int(selection) - 1

                if 0 <= idx < len(rooms):
                    selected_room = rooms[idx]

                    if selected_room in visited_rooms:
                        print("You already investigated this location.")
                    else:
                        visited_rooms.add(selected_room)

                        clues = case.rooms[selected_room]
                        for clue in clues:
                            discovered_clues.append((clue, selected_room))

                        print(f"\nInvestigating {selected_room}...\n")

                        if not clues:
                            print("Nothing found.")
                        else:
                            for clue in clues:
                                print(f"- {clue.description}")
                else:
                    print("Invalid location.")
            else:
                print("Invalid input.")

        # SHOW CLUES
        elif choice == "2":
            print("\n--- DISCOVERED CLUES ---\n")

            print(
                f"Crime location: {case.context['murder_room']} | "
                f"Time: {case.context['murder_time']}\n"
            )

            if not discovered_clues:
                print("No clues found yet.")
            else:
                for clue, room in discovered_clues:
                    print(f"[{room}] {clue.description}")

        # ACCUSE
        elif choice == "3":
            break

        else:
            print("Invalid option.")

    # GUESS PHASE
    print("\n--- YOUR GUESS ---")

    guess_suspect = choose_option(suspects, "Who is the culprit?")
    guess_weapon = choose_option(weapons, "What is the weapon?")
    guess_motive = choose_option(motives, "What is the motive?")

    print("\n--- RESULT ---")

    solution = case.solution

    correct = (
        normalize(guess_suspect) == normalize(solution["culprit"]) and
        normalize(guess_weapon) == normalize(solution["weapon"]) and
        normalize(guess_motive) == normalize(solution["motive"])
    )

    if correct:
        print("Correct! You solved the case.")
    else:
        print("Wrong solution.")
        print(f"Correct answer: {solution}")


if __name__ == "__main__":
    run()