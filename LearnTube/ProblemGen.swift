import Foundation

// MARK: - Generated number problems
//
// The count-and-type games used to ship four fixed problems each. By the third
// play Gabriel had seen every one three times, and the take-away games only
// drew the leftover group, so "5 ducks, 2 swim away" was a counting-to-3 game.
//
// `ProblemGen` makes a fresh problem per round for every `NumberGame`, reading
// `GameDifficulty.level` (1...3, set from how many times he has mastered the
// skill) so each game climbs: counting 6 -> 10 -> 15, adding toward 20. Every
// problem draws something concrete (see `NumberVisual`), because his math is
// counting what he can see, and the picture is what lets him discover the
// shortcut (counting on, ten and some more) on his own.

enum ProblemGen {

    // The farm, more or less.
    static let critters = ["🐤", "🐔", "🦆", "🐐", "🐑", "🐷", "🐮", "🐴", "🐰", "🐶", "🐱", "🐝", "🐸", "🐟"]

    /// What each critter does when it leaves. Keeps the take-away stories varied
    /// and readable ("2 hop away" beats "2 are subtracted").
    static func leaves(_ emoji: String, _ n: Int) -> String {
        let verb: String
        switch emoji {
        case "🦆", "🐟", "🐸": verb = n == 1 ? "swims away" : "swim away"
        case "🐰", "🐤", "🐔": verb = n == 1 ? "hops away" : "hop away"
        case "🐝": verb = n == 1 ? "flies off" : "fly off"
        case "🐴", "🐶", "🐐", "🐑": verb = n == 1 ? "runs off" : "run off"
        case "🐷", "🐮", "🐱": verb = n == 1 ? "wanders off" : "wander off"
        default: verb = n == 1 ? "goes away" : "go away"
        }
        return "\(n) \(verb)"
    }

    /// Pick by level: a for level 1, b for level 2, c for level 3.
    private static func lv(_ a: Int, _ b: Int, _ c: Int) -> Int {
        let l = GameDifficulty.level
        return l >= 3 ? c : (l == 2 ? b : a)
    }

    /// Anti-pattern: never serve the same answer twice in a row. Gabriel spots
    /// any pattern instantly and will ride it instead of counting.
    private static var lastAnswer: Int?
    static func problems(_ game: NumberGame, rounds: Int, boost: Int = 0) -> [NumberProblem] {
        // A boosted game opens higher on the ladder; the tile's level still
        // adds on top of it as he masters the skill.
        let base = GameDifficulty.level
        GameDifficulty.level = min(3, base + boost)
        defer { GameDifficulty.level = base }
        var out: [NumberProblem] = []
        var tries = 0
        while out.count < rounds && tries < 60 {
            tries += 1
            let p = make(game)
            if p.answer == lastAnswer { continue }
            if let last = out.last, last.answer == p.answer { continue }
            out.append(p)
        }
        if out.isEmpty { out.append(make(game)) }   // never hand the player an empty deck
        lastAnswer = out.last?.answer
        return out
    }

    static func make(_ game: NumberGame) -> NumberProblem {
        let c = critters.randomElement()!
        switch game {

        case .count:
            let n = Int.random(in: 3...lv(6, 10, 15))
            return NumberProblem("Count the \(c)! How many?", n, visual: Array(repeating: c, count: n))

        case .add:
            let cap = lv(4, 6, 8), sum = lv(8, 12, 16)
            var a = Int.random(in: 1...cap), b = Int.random(in: 1...cap)
            while a + b > sum { a = Int.random(in: 1...cap); b = Int.random(in: 1...cap) }
            let story = Bool.random() ? "\(a) \(c) and \(b) more come. How many now?"
                                      : "\(a) \(c) and \(b) \(c). How many in all?"
            return NumberProblem(story, a + b, visual: tokens(c, a) + ["➕"] + tokens(c, b))

        case .addThree:
            let cap = lv(3, 4, 5)
            let a = Int.random(in: 1...cap), b = Int.random(in: 1...cap), d = Int.random(in: 1...cap)
            return NumberProblem("\(a) \(c) and \(b) \(c) and \(d) \(c). How many?", a + b + d,
                                 visual: tokens(c, a) + ["➕"] + tokens(c, b) + ["➕"] + tokens(c, d))

        case .takeAway:
            let start = Int.random(in: 3...lv(6, 9, 12))
            let gone = Int.random(in: 1..<start)
            return NumberProblem("\(start) \(c). \(leaves(c, gone)). How many are left?", start - gone,
                                 draw: .takeAway(emoji: c, start: start, gone: gone))

        case .oneMore:
            let n = Int.random(in: lv(3, 6, 10)...lv(8, 14, 19))
            return NumberProblem("\(n) \(c) and 1 more hops in. How many now?", n + 1,
                                 visual: tokens(c, n) + ["➕", c])

        case .oneLess:
            let n = Int.random(in: lv(3, 6, 10)...lv(8, 14, 19))
            return NumberProblem("\(n) \(c). \(leaves(c, 1)). How many are left?", n - 1,
                                 draw: .takeAway(emoji: c, start: n, gone: 1))

        case .teen:
            let ones = Int.random(in: 1...lv(5, 9, 9))
            return NumberProblem("10 and \(ones) more. How many?", 10 + ones,
                                 draw: .tens(emoji: c, tens: 1, ones: ones))

        case .doubles:
            let n = Int.random(in: 1...lv(5, 7, 10))
            return NumberProblem("\(n) \(c) and \(n) \(c). How many in all?", n + n,
                                 visual: tokens(c, n) + ["➕"] + tokens(c, n))

        case .doublesPlusOne:
            let n = Int.random(in: 2...lv(4, 6, 9))
            return NumberProblem("\(n) + \(n + 1)   (that's \(n) + \(n), and one more)", n + n + 1,
                                 visual: tokens(c, n) + ["➕"] + tokens(c, n + 1))

        case .makeTen:
            let have = Int.random(in: lv(5, 2, 1)...9)
            return NumberProblem("\(have) in the ten-frame. How many more make 10?", 10 - have,
                                 draw: .frame(emoji: c, filled: have))

        case .tensAndOnes:
            let tens = Int.random(in: lv(1, 2, 2)...lv(2, 4, 5))
            let ones = Int.random(in: 1...9)
            return NumberProblem("\(tens * 10) and \(ones) more. How many?", tens * 10 + ones,
                                 draw: .tens(emoji: c, tens: tens, ones: ones))

        case .tenMoreLess:
            let n = Int.random(in: 11...lv(29, 49, 79))
            let more = Bool.random()
            return NumberProblem(more ? "Ten MORE than \(n)?" : "Ten LESS than \(n)?", more ? n + 10 : n - 10,
                                 draw: .tens(emoji: c, tens: n / 10, ones: n % 10))

        case .countOn:
            let big = Int.random(in: lv(6, 9, 12)...lv(10, 14, 17))
            let small = Int.random(in: 1...lv(3, 4, 4))
            return NumberProblem("Start at \(big), count on \(small). How many?", big + small,
                                 visual: tokens(c, big) + ["➕"] + tokens(c, small))

        case .howManyMore:
            let other = critters.filter { $0 != c }.randomElement()!
            let a = Int.random(in: 3...lv(6, 8, 10))
            let b = Int.random(in: 1..<a)
            return NumberProblem("\(a) \(c) and \(b) \(other). How many MORE \(c)?", a - b,
                                 draw: .compare(top: c, topCount: a, bottom: other, bottomCount: b))

        case .skipTens:
            let k = Int.random(in: 2...lv(4, 6, 9))
            return NumberProblem("Count by tens: \(k) full ten-frames. How many \(c)?", k * 10,
                                 draw: .tens(emoji: c, tens: k, ones: 0))

        case .skipFives:
            let k = Int.random(in: 2...lv(4, 6, 8))
            return NumberProblem("Count by fives: \(k) hands. How many fingers?", k * 5,
                                 draw: .groups(emoji: "✋", size: 5, count: k))

        case .skipTwos:
            let k = Int.random(in: 2...lv(5, 7, 10))
            return NumberProblem("Count by twos: \(k) pairs of boots. How many boots?", k * 2,
                                 draw: .groups(emoji: "🥾", size: 2, count: k))

        case .pennies:
            let n = Int.random(in: 3...lv(8, 12, 18))
            return NumberProblem("Count the pennies. How many cents?", n, visual: Array(repeating: "🪙", count: n))

        case .numberBefore:
            let n = Int.random(in: lv(3, 8, 11)...lv(10, 15, 20))
            return NumberProblem("What number comes right before \(n)?", n - 1,
                                 draw: .takeAway(emoji: c, start: n, gone: 1))

        case .missingAddend:
            let a = Int.random(in: 1...lv(4, 6, 8))
            let total = a + Int.random(in: 1...lv(4, 6, 8))
            return NumberProblem("\(a) + ? = \(total)   (count up from \(a))", total - a,
                                 draw: .compare(top: c, topCount: total, bottom: c, bottomCount: a))

        case .turnAround:
            let a = Int.random(in: 1...lv(4, 6, 9)), b = Int.random(in: 1...lv(4, 6, 9))
            return NumberProblem("\(a) + \(b) = \(a + b).  So \(b) + \(a) = ?", a + b,
                                 visual: tokens(c, b) + ["➕"] + tokens(c, a))

        case .thinkAddition:
            let total = Int.random(in: lv(7, 9, 11)...lv(10, 14, 18))
            let sub = Int.random(in: max(1, total - lv(5, 7, 9))..<total)
            return NumberProblem("\(total) - \(sub)   (\(sub) + ? = \(total))", total - sub,
                                 draw: .compare(top: c, topCount: total, bottom: c, bottomCount: sub))

        case .addTensOnes:
            // Level 1: two-digit + ones, no carry. Level 2: tens + tens.
            // Level 3: either. The picture is the SUM as ten-frames and ones, so
            // he can read it as tens and ones instead of counting to 47.
            let tensOnly = GameDifficulty.level == 2 || (GameDifficulty.level == 3 && Bool.random())
            if tensOnly {
                let a = Int.random(in: 1...5) * 10, b = Int.random(in: 1...(9 - a / 10)) * 10
                return NumberProblem("\(a) + \(b)   (\(a / 10) tens and \(b / 10) tens)", a + b,
                                     draw: .tens(emoji: c, tens: (a + b) / 10, ones: 0))
            }
            let t = Int.random(in: 1...lv(3, 5, 8)), o = Int.random(in: 1...5), add = Int.random(in: 1...(9 - o))
            let a = t * 10 + o
            return NumberProblem("\(a) + \(add)   (the tens stay put)", a + add,
                                 draw: .tens(emoji: c, tens: t, ones: o + add))
        }
    }

    private static func tokens(_ e: String, _ n: Int) -> [String] { Array(repeating: e, count: max(0, n)) }
}
