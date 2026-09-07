import Foundation

// MARK: - Interactive lesson model
// Lessons are static content (not persisted), so they don't need Codable.

struct Choice: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let isCorrect: Bool
    /// A wrong answer written to be funny ("Blame the dog"). Tapping one gets
    /// a laugh, not a miss: it is never a struggle signal, because he picks
    /// these on purpose and the joke is the point.
    var isJoke: Bool = false
}

struct Question: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let options: [Choice]

    /// Convenience: give the correct answer and the wrong ones. `jokes` are
    /// wrong answers that are jokes on purpose and don't count against him.
    init(_ prompt: String, correct: String, wrong: [String], jokes: [String] = []) {
        self.prompt = prompt
        self.options = [Choice(label: correct, isCorrect: true)]
            + wrong.map { Choice(label: $0, isCorrect: false) }
            + jokes.map { Choice(label: $0, isCorrect: false, isJoke: true) }
    }
}

/// What a number problem draws on screen. Every problem should draw
/// SOMETHING: Gabriel's math is concrete, and a bare "15 - 6" with nothing to
/// count is the cliff the old First Grade set fell off.
enum NumberVisual: Hashable {
    /// Nothing drawn. Only for the rare pure-symbol drill.
    case none
    /// A row of tokens to count. "➕" between groups is drawn as an operator.
    case tokens([String])
    /// The WHOLE starting group, with the last `gone` fading out and crossed
    /// off after a beat. He sees the 5 ducks, watches 2 leave, counts 3. This
    /// is what makes take-away a subtraction game instead of a counting game.
    case takeAway(emoji: String, start: Int, gone: Int)
    /// Ten-frames: `tens` full frames plus `ones` loose tokens. Teen numbers,
    /// tens-and-ones, ten more / ten less, counting by tens.
    case tens(emoji: String, tens: Int, ones: Int)
    /// One ten-frame with `filled` cells; the empties are the thing to count
    /// (make ten, fill the ten).
    case frame(emoji: String, filled: Int)
    /// Two groups lined up in matching columns so the extras stick out
    /// (how many more?, more or less).
    case compare(top: String, topCount: Int, bottom: String, bottomCount: Int)
    /// Groups of equal size — pairs for counting by 2s, hands for 5s.
    case groups(emoji: String, size: Int, count: Int)

    var isEmpty: Bool { if case .none = self { return true } else { return false } }
}

struct NumberProblem: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let answer: Int
    let visual: NumberVisual
    init(_ prompt: String, _ answer: Int, visual: [String] = []) {
        self.prompt = prompt; self.answer = answer
        self.visual = visual.isEmpty ? .none : .tokens(visual)
    }
    init(_ prompt: String, _ answer: Int, draw: NumberVisual) {
        self.prompt = prompt; self.answer = answer; self.visual = draw
    }
}

/// The number games that generate a fresh problem every round instead of
/// replaying four fixed ones. Each kind reads `GameDifficulty` for its ceiling,
/// so a game climbs as he masters it (see `AppState.levelableSkills`).
enum NumberGame: Hashable {
    case count            // how many? (count the critters)
    case add              // two groups, count them all
    case addThree         // three groups
    case takeAway         // some leave, count what's left
    case oneMore, oneLess
    case teen             // ten and some more (11-19)
    case doubles          // n + n
    case doublesPlusOne   // n + (n+1)
    case makeTen          // how many more to fill the frame
    case tensAndOnes      // 20 and 3 more
    case tenMoreLess      // ten more / ten less
    case countOn          // start at the big number, count on the small one
    case howManyMore      // compare two groups
    case skipTens, skipFives, skipTwos
    case pennies          // count the pennies (1¢ each)
    case numberBefore
    case missingAddend    // 5 + ? = 9
    case turnAround       // 3 + 8 when you know 8 + 3
    case thinkAddition    // 12 - 9 as 9 + ? = 12
    case addTensOnes      // 23 + 5, 40 + 30
}

/// The kinds of interactive lessons. Each renders its own mini-game and
/// reports back when the child has completed it.
enum Lesson: Hashable {
    /// Tap the correct answer. One or more questions.
    case quiz([Question])
    /// Tap each object once to count up to `target`.
    case count(target: Int, symbol: String, prompt: String)
    /// Tap the chips in the correct order. `items` are given in order.
    case order(prompt: String, items: [String])
    /// Tap a left item, then its partner on the right.
    case match(prompt: String, pairs: [Pair])
    /// Solve with the on-screen number pad.
    case numberPad([NumberProblem])
    /// Number pad again, but the problems are generated fresh each play by
    /// `NumberGen`, `rounds` per game, at the current difficulty level.
    /// `boost` starts a game higher up the ladder (a First Grade "add within
    /// 20" should not open at sums to 8 just because it's never been mastered).
    case numberGen(NumberGame, rounds: Int, boost: Int = 0)
    /// Drag expressive faces onto matching words, in rounds of `perRound`.
    case faceMatch(exprs: [FaceExpr], perRound: Int)
    /// A multi-part story reader + reading-skill games (content looked up by id).
    case story(id: String)
    /// Trace each letter/word with a finger — real on-screen writing practice.
    case trace(prompt: String, items: [String])

    struct Pair: Hashable { let left: String; let right: String
        init(_ l: String, _ r: String) { left = l; right = r } }

    /// Used for the duration badge.
    var stepCount: Int {
        switch self {
        case .quiz(let q): return q.count + 1
        case .count(let t, _, _): return max(2, t / 5 + 1)
        case .order(_, let i): return i.count
        case .match(_, let p): return p.count + 1
        case .numberPad(let n): return n.count + 1
        case .numberGen(_, let r, _): return r + 1
        case .faceMatch(let e, _): return e.count
        case .story: return 9
        case .trace(_, let i): return i.count
        }
    }

    var kindLabel: String {
        switch self {
        case .quiz: return "Tap the answer"
        case .count: return "Tap to count"
        case .order: return "Put in order"
        case .match: return "Match them up"
        case .numberPad, .numberGen: return "Solve it"
        case .faceMatch: return "Tap to match"
        case .story: return "Story time"
        case .trace: return "Trace it"
        }
    }
}
