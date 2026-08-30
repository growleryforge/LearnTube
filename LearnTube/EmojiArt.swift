import SwiftUI

/// Maps words in a question or answer to a big friendly emoji "picture".
/// Gabriel loves emojis, so games show them wherever a word has a match.
enum EmojiArt {

    static let map: [String: String] = [
        // animals
        "cow": "🐄", "cows": "🐄", "pig": "🐷", "pigs": "🐷",
        "hen": "🐔", "hens": "🐔", "chicken": "🐔", "chickens": "🐔", "chick": "🐤",
        "dog": "🐶", "dogs": "🐶", "cat": "🐱", "cats": "🐱",
        "goat": "🐐", "goats": "🐐", "sheep": "🐑", "horse": "🐴", "horses": "🐴",
        "duck": "🦆", "bunny": "🐰", "rabbit": "🐰", "fish": "🐟",
        "bird": "🐦", "frog": "🐸", "ant": "🐜", "ladybug": "🐞", "bee": "🐝",
        "wings": "🪽", "paw": "🐾",
        // nature / sky / weather
        "sun": "☀️", "sunny": "☀️", "moon": "🌙", "star": "⭐️", "stars": "⭐️",
        "rain": "🌧️", "raining": "🌧️", "raincoat": "🧥", "snow": "❄️", "snowing": "❄️",
        "cloud": "☁️", "cloudy": "☁️", "sky": "🌤️", "water": "💧", "light": "💡",
        "shadow": "🌑", "wind": "🌬️",
        // plants / food
        "plant": "🌱", "plants": "🌱", "seed": "🌱", "seeds": "🌱", "roots": "🌿",
        "leaf": "🍃", "leaves": "🍃", "flower": "🌼", "tree": "🌳", "grass": "🌾",
        "apple": "🍎", "apples": "🍎", "egg": "🥚", "eggs": "🥚", "carrot": "🥕",
        "carrots": "🥕", "hay": "🌾", "cake": "🍰", "banana": "🍌",
        // objects
        "ball": "⚽️", "box": "📦", "can": "🥫", "clock": "🕐", "book": "📖",
        "books": "📖", "sock": "🧦", "hat": "🎩", "map": "🗺️", "bike": "🚲",
        "bikes": "🚲", "wagon": "🛒", "swing": "🌳", "door": "🚪",
        "penny": "🪙", "nickel": "🪙", "dime": "🪙", "quarter": "🪙", "coin": "🪙",
        // shapes
        "circle": "🔵", "square": "🟦", "triangle": "🔺",
        // feelings
        "happy": "😄", "sad": "😢", "calm": "😌", "angry": "😠", "mad": "😠",
        "scared": "😨", "excited": "🤩", "sleepy": "😴",
        // misc
        "summer": "🌞", "winter": "⛄️", "ship": "🚢", "frog/": "🐸"
    ]

    /// Returns an emoji for the first word in `text` that has a match.
    static func emoji(for text: String) -> String? {
        let words = text.lowercased().split { !($0.isLetter) }.map(String.init)
        for w in words { if let e = map[w] { return e } }
        return nil
    }

    /// SF Symbol stand-in used ONLY in the simulator (which can't render emoji).
    static func sfFallback(_ emoji: String) -> String {
        switch emoji {
        case "🐶": return "dog.fill"
        case "🐱": return "cat.fill"
        case "🐦": return "bird.fill"
        case "🐟": return "fish.fill"
        case "🐰": return "hare.fill"
        case "🐜": return "ant.fill"
        case "🐞": return "ladybug.fill"
        case "🐸", "🐄", "🐷", "🐔", "🐐", "🐑", "🐴", "🦆", "🐤", "🐝": return "pawprint.fill"
        case "☀️", "🌞": return "sun.max.fill"
        case "🌙", "🌑": return "moon.fill"
        case "⭐️": return "star.fill"
        case "🌧️": return "cloud.rain.fill"
        case "❄️", "⛄️": return "snowflake"
        case "☁️": return "cloud.fill"
        case "💧": return "drop.fill"
        case "💡": return "lightbulb.fill"
        case "🌬️": return "wind"
        case "🌱", "🌿", "🍃", "🌳", "🌼", "🌾": return "leaf.fill"
        case "🍎", "🍌", "🥕", "🍰": return "fork.knife"
        case "🥚": return "oval.fill"
        case "⚽️": return "soccerball"
        case "📦": return "shippingbox.fill"
        case "🥫": return "cylinder.fill"
        case "🕐": return "clock.fill"
        case "📖": return "book.fill"
        case "🧦", "🎩", "🧥": return "tshirt.fill"
        case "🗺️": return "map.fill"
        case "🚲": return "bicycle"
        case "🛒": return "cart.fill"
        case "🚪": return "door.left.hand.closed"
        case "🪙": return "centsign.circle.fill"
        case "🔵": return "circle.fill"
        case "🟦": return "square.fill"
        case "🔺": return "triangle.fill"
        case "😄", "🤩": return "face.smiling.fill"
        case "😢", "😨", "😠": return "face.dashed.fill"
        case "😌": return "face.smiling"
        case "😴": return "moon.zzz.fill"
        case "🚢": return "ferry.fill"
        default: return "sparkles"
        }
    }
}

/// Shows a real emoji on device; a vector/SF-Symbol stand-in in the simulator
/// (whose runtime ships only a partial emoji font and would show empty boxes).
struct EmojiView: View {
    let emoji: String
    var size: CGFloat = 44
    var tint: Color = .white

    var body: some View {
        #if targetEnvironment(simulator)
        Group {
            switch emoji {
            case "🥚": Egg().frame(width: size, height: size * 1.08)
            case "🐣", "🐤": ChickFace().frame(width: size, height: size)
            case "🍎": AppleArt().frame(width: size, height: size)
            case "⭐️": StarArt().frame(width: size, height: size)
            default:
                Image(systemName: EmojiArt.sfFallback(emoji))
                    .font(.system(size: size * 0.82, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        #else
        Text(emoji).font(.system(size: size))
        #endif
    }
}
