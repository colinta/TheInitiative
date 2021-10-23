////
///  Creature.swift
//

struct Creature: Equatable, Codable {
    let name: String
    let initiative: Int
    let initiativeBonus: Int
    let armorClass: Int
    let speed: Int
    let maxHitPoints: Int
    let currentHitPoints: Int
    let attributes: [Attribute]
    let skills: [Note]
    let saves: [Note]
    let actions: [Note]

    func set(
        name: String? = nil,
        initiative: Int? = nil,
        initiativeBonus: Int? = nil,
        armorClass: Int? = nil,
        speed: Int? = nil,
        maxHitPoints: Int? = nil,
        currentHitPoints: Int? = nil,
        attributes: [Attribute]? = nil,
        skills: [Note]? = nil,
        saves: [Note]? = nil,
        actions: [Note]? = nil
    ) -> Self {
        Creature(
            name: name ?? self.name,
            initiative: initiative ?? self.initiative,
            initiativeBonus: initiativeBonus ?? self.initiativeBonus,
            armorClass: armorClass ?? self.armorClass,
            speed: speed ?? self.speed,
            maxHitPoints: maxHitPoints ?? self.maxHitPoints,
            currentHitPoints: currentHitPoints ?? self.currentHitPoints,
            attributes: attributes ?? self.attributes,
            skills: skills ?? self.skills,
            saves: saves ?? self.saves,
            actions: actions ?? self.actions
        )
    }

    struct Attribute: Equatable, Codable {
        let title: String
        let value: Int
        var mod: Int {
            let mod: Double = (Double(value) - 10) / 2
            if mod < 0 {
                return Int(mod - 0.5)
            } else {
                return Int(mod)
            }
        }
    }

    struct Note: Equatable, Codable {
        let title: String
        let content: String
    }
}
