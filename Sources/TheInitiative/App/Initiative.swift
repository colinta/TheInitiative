////
///  Initiative.swift
//

import Ashen

struct Initiative {
    struct Model {
        let creatures: [Creature]
        let selectedCreature: Creature?

        func set(creatures: [Creature]) -> Self {
            Model(creatures: creatures, selectedCreature: selectedCreature)
        }

        func update(_ fromCreature: Creature?, to toCreature: Creature) -> Self {
            let updatedCreatures = creatures.map { $0 == fromCreature ? toCreature : $0 }
            let newSelectedCreature =
                fromCreature == selectedCreature ? toCreature : selectedCreature
            return Model(
                creatures: updatedCreatures,
                selectedCreature: newSelectedCreature
            )
        }

        func set(selectedCreature: Creature?) -> Self {
            Model(
                creatures: creatures,
                selectedCreature: creatures.first { $0 == selectedCreature }
            )
        }
    }

    enum Message {
        case select(Creature)
        case addInitiative(Creature, Int)
        case addArmorClass(Creature, Int)
        case addSpeed(Creature, Int)
        case addHitPoints(Creature, Int)
        case addMaxHitPoints(Creature, Int)
        case quit
    }

    static func initial() -> Initial<Model, Message> {
        let creatures = [
            Creature(
                name: "Firbolg (Dannie Veneer)",
                initiative: 23,
                initiativeBonus: 0,
                armorClass: 18,
                speed: 20,
                maxHitPoints: 31,
                currentHitPoints: 31,
                attributes: [], skills: [], saves: [],
                actions: []
            ),
            Creature(
                name: "Yaryass",
                initiative: 18,
                initiativeBonus: 0,
                armorClass: 13,
                speed: 30,
                maxHitPoints: 39,
                currentHitPoints: 39,
                attributes: [], skills: [], saves: [],
                actions: []
            ),
            Creature(
                name: "Babbafragga",
                initiative: 17,
                initiativeBonus: 0,
                armorClass: 16,
                speed: 35,
                maxHitPoints: 44,
                currentHitPoints: 44,
                attributes: [], skills: [], saves: [],
                actions: []
            ),
            Creature(
                name: "Charlez Bronzon",
                initiative: 14,
                initiativeBonus: 0,
                armorClass: 10,
                speed: 30,
                maxHitPoints: 16,
                currentHitPoints: 16,
                attributes: [], skills: [], saves: [],
                actions: []
            ),
            Creature(
                name: "Moe Sizzlerack",
                initiative: 9,
                initiativeBonus: 0,
                armorClass: 9,
                speed: 30,
                maxHitPoints: 22,
                currentHitPoints: 22,
                attributes: [], skills: [], saves: [],
                actions: []
            ),
        ]
        return Initial(
            Model(creatures: creatures, selectedCreature: creatures.first),
            command: Command<Message>.none())
    }

    static func update(model: Model, message: Message) -> State<Model, Message> {
        switch message {
        case let .addInitiative(creature, amount):
            let updatedCreature = creature.set(initiative: creature.initiative + amount)
            return .model(
                model
                    .update(creature, to: updatedCreature)
            )
        case let .addArmorClass(creature, amount):
            let updatedCreature = creature.set(armorClass: creature.armorClass + amount)
            return .model(
                model
                    .update(creature, to: updatedCreature)
            )
        case let .addSpeed(creature, amount):
            let updatedCreature = creature.set(speed: creature.speed + amount)
            return .model(
                model
                    .update(creature, to: updatedCreature)
            )
        case let .addHitPoints(creature, amount):
            let updatedCreature = creature.set(currentHitPoints: creature.currentHitPoints + amount)
            return .model(
                model
                    .update(creature, to: updatedCreature)
            )
        case let .addMaxHitPoints(creature, amount):
            let updatedCreature = creature.set(maxHitPoints: creature.maxHitPoints + amount)
            return .model(
                model
                    .update(creature, to: updatedCreature)
            )
        case let .select(creature):
            if model.selectedCreature == creature {
                return .model(model.set(selectedCreature: nil))
            }
            return .model(model.set(selectedCreature: creature))
        case .quit:
            return .quit
        }
    }

    static func render(model: Model) -> [View<Message>] {
        [
            Columns([
                Flow(
                    .leftToRight,
                    [
                        (
                            .fixed,
                            Scroll(
                                Stack(
                                    .topToBottom,
                                    model.creatures.sorted { $0.initiative > $1.initiative }.map {
                                        InitiativeCell(
                                            creature: $0, selected: model.selectedCreature == $0)
                                    }),
                                .matchWidth
                            ).maxWidth(40)
                        ),
                        (.fixed, Repeating(Text("|")).matchContainer(dimension: .height).width(1)),
                        (
                            .flex1,
                            model.selectedCreature.map(CreatureDetails)
                                ?? Text("Select a creature").foreground(color: .gray).aligned(
                                    .middleCenter)
                        ),
                    ])
            ])
        ]
    }

    static func CreatureDetails(creature: Creature) -> View<Message> {
        Overflow(
            Stack(
                .topToBottom,
                [
                    Stack(
                        .leftToRight,
                        [
                            Text("Name  | "), Text(creature.name).bold(),
                        ]
                    )
                    .background(view: Text(" "))
                    .matchContainer(dimension: .width)
                    .underlined(),
                    PlusMinusRow("HP", creature.currentHitPoints) { .addHitPoints(creature, $0) },
                    PlusMinusRow("Max HP", creature.maxHitPoints) {
                        .addMaxHitPoints(creature, $0)
                    },
                    PlusMinusRow("Init.", creature.initiative) { .addInitiative(creature, $0) },
                    PlusMinusRow("AC", creature.armorClass) { .addArmorClass(creature, $0) },
                    PlusMinusRow("Speed", creature.speed) { .addSpeed(creature, $0) },
                ])
        )
    }

    static func PlusMinusRow(_ title: String, _ value: Int, message: @escaping (_: Int) -> Message)
        -> View<Message>
    {
        PlusMinusRow(title, "\(value)", message: message)
    }

    static func PlusMinusRow(
        _ title: String, _ value: String, message: @escaping (_: Int) -> Message
    ) -> View<Message> {
        Stack(
            .leftToRight,
            [
                Text(title).width(6),
                Text("| "),
                OnLeftClick(
                    Text(" - ")
                        .aligned(.topCenter)
                        .foreground(color: .black)
                        .background(color: .red),
                    message(-1)),
                OnLeftClick(
                    Text(" + ")
                        .aligned(.topCenter)
                        .foreground(color: .black)
                        .background(color: .green),
                    message(+1)),
                Text(" \(value)"),
            ])
    }

    static func InitiativeCell(creature: Creature, selected: Bool) -> View<Message> {
        Stack(
            .bottomToTop,
            [
                Repeating(Text("-")).matchContainer(dimension: .width).height(1),
                OnLeftClick(
                    Flow(
                        .leftToRight,
                        [
                            (
                                .fixed,
                                Stack(
                                    .topToBottom,
                                    [
                                        Text("Init".underlined()),
                                        Text("\(creature.initiative)").aligned(.middleCenter),
                                    ]
                                )
                                .padding(left: 1, right: 1)
                                .aligned(.middleLeft)
                                .matchContainer(dimension: .height)
                            ),
                            (
                                .flex1,
                                Stack(
                                    .topToBottom,
                                    [
                                        Text(
                                            creature.name.isEmpty
                                                ? "(name)".foreground(.gray)
                                                : creature.name.bold()
                                        ),
                                        Stack(
                                            .leftToRight,
                                            [
                                                Text("AC \(creature.armorClass)".underlined()),
                                                Space(width: 2),
                                                Text("Speed \(creature.speed)'".underlined()),
                                                Space(width: 2),
                                            ]),
                                    ]
                                )
                                .padding(left: 1, right: 1)
                                .aligned(.middleLeft)
                                .matchContainer(dimension: .height)
                            ),
                            (
                                .fixed,
                                Stack(
                                    .topToBottom,
                                    [
                                        OnLeftClick(
                                            Text("↑").aligned(.topCenter).foreground(
                                                color: selected ? .black : .white
                                            ).background(color: .green), .addHitPoints(creature, 1)),
                                        Text("HP".underlined()).aligned(.topCenter),
                                        Text("\(creature.currentHitPoints)").aligned(.topCenter),
                                        OnLeftClick(
                                            Text("↓").aligned(.topCenter).foreground(
                                                color: selected ? .black : .white
                                            ).background(color: .red), .addHitPoints(creature, -1)),
                                    ]
                                ).width(5)
                            ),
                        ]
                    )
                    .foreground(color: selected ? .black : .white)
                    .defaultBackground(color: selected ? .white : .none),
                    .select(creature)
                ),
            ]
        ).height(5)
    }
}
