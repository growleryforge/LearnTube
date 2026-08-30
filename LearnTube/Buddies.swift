import SwiftUI

/// A collectible animal character. Earned by finishing a lesson; they join the
/// farm collection and stick around day to day for long-term motivation.
struct Buddy: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String   // SF Symbol (renders reliably, unlike emoji)
    let color: Color
}

enum Buddies {

    static let all: [Buddy] = [
        Buddy(id: "rusty",  name: "Rusty",   symbol: "dog.fill",       color: Color(red: 0.85, green: 0.45, blue: 0.20)),
        Buddy(id: "mittens",name: "Mittens", symbol: "cat.fill",       color: Color(red: 0.55, green: 0.42, blue: 0.78)),
        Buddy(id: "pip",    name: "Pip",     symbol: "bird.fill",      color: Color(red: 0.30, green: 0.62, blue: 0.90)),
        Buddy(id: "bubbles",name: "Bubbles", symbol: "fish.fill",      color: Color(red: 0.20, green: 0.68, blue: 0.70)),
        Buddy(id: "hopper", name: "Hopper",  symbol: "hare.fill",      color: Color(red: 0.78, green: 0.55, blue: 0.40)),
        Buddy(id: "shelly", name: "Shelly",  symbol: "tortoise.fill",  color: Color(red: 0.30, green: 0.66, blue: 0.42)),
        Buddy(id: "dot",    name: "Dot",     symbol: "ladybug.fill",   color: Color(red: 0.86, green: 0.30, blue: 0.32)),
        Buddy(id: "andy",   name: "Andy",    symbol: "ant.fill",       color: Color(red: 0.42, green: 0.42, blue: 0.46)),
        Buddy(id: "ziggy",  name: "Ziggy",   symbol: "lizard.fill",    color: Color(red: 0.40, green: 0.72, blue: 0.36)),
        Buddy(id: "honey",  name: "Honey",   symbol: "teddybear.fill", color: Color(red: 0.80, green: 0.52, blue: 0.30)),
        Buddy(id: "tracks", name: "Tracks",  symbol: "pawprint.fill",  color: Color(red: 0.62, green: 0.46, blue: 0.82)),
        Buddy(id: "sunny",  name: "Sunny",   symbol: "tortoise.fill",  color: Color(red: 0.95, green: 0.70, blue: 0.20)),
        Buddy(id: "scout",   name: "Scout",   symbol: "dog.fill",      color: Color(red: 0.36, green: 0.30, blue: 0.26)),
        Buddy(id: "patches", name: "Patches", symbol: "cat.fill",      color: Color(red: 0.95, green: 0.58, blue: 0.25)),
        Buddy(id: "waddles", name: "Waddles", symbol: "bird.fill",     color: Color(red: 0.22, green: 0.70, blue: 0.62)),
        Buddy(id: "splash",  name: "Splash",  symbol: "fish.fill",     color: Color(red: 0.30, green: 0.50, blue: 0.85)),
        Buddy(id: "nibbles", name: "Nibbles", symbol: "hare.fill",     color: Color(red: 0.60, green: 0.62, blue: 0.66)),
        Buddy(id: "flutter", name: "Flutter", symbol: "ladybug.fill",  color: Color(red: 0.90, green: 0.40, blue: 0.55)),
        Buddy(id: "speckle", name: "Speckle", symbol: "lizard.fill",   color: Color(red: 0.30, green: 0.58, blue: 0.30)),
        Buddy(id: "cuddles", name: "Cuddles", symbol: "teddybear.fill",color: Color(red: 0.74, green: 0.44, blue: 0.30))
    ]

    static func buddy(id: String) -> Buddy? { all.first { $0.id == id } }

    /// Stable mapping from a skill to a buddy (deterministic across launches,
    /// unlike String.hashValue which is randomized per process).
    static func forSkill(_ skill: Skill) -> Buddy {
        let seed = skill.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return all[seed % all.count]
    }
}
