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

// MARK: - Tracing with animals

/// The shape a finger traces. Pre-writing strokes come first in handwriting
/// (top-to-bottom line, left-to-right line, circle, cross, diagonals, then
/// curves and zigzags for fluency); letters are built out of them. All shapes
/// are described in a unit square (0...1, y down) and scaled to the canvas.
enum TraceStroke: Hashable {
    case down           // vertical line, top to bottom (l, t, i)
    case across         // horizontal line, left to right
    case circle         // counter-clockwise from the top, the c/o/a/d start
    case arc            // a hump, left to right (h, m, n)
    case wave           // gentle waves, left to right
    case zigzag         // sharp diagonals, left to right (v, w, z)
    case loops          // three loops, left to right (e, l in cursive)
    case spiral         // outside in
    case cross          // a plus: down, then across
    case square
    case triangle
    case diagonalDown   // top-left to bottom-right (\)
    case diagonalUp     // bottom-left to top-right (/)
    case xMark
    case glyph(String)  // a letter or digit, exactly as written (case kept)
    /// A free polyline in unit coordinates, for one-off shapes.
    case points([UnitPoint])

    struct UnitPoint: Hashable { let x: Double; let y: Double
        init(_ x: Double, _ y: Double) { self.x = x; self.y = y } }
}

/// One tracing round: who is at the start, where they are going, the stroke
/// between, and the one line Leo says about it.
struct TraceStep: Hashable {
    let say: String        // "Help the duck swim to the pond"
    let stroke: TraceStroke
    let from: String       // emoji at the start of the stroke ("🦆")
    let to: String         // emoji at the end ("🏞️"); empty for none
    /// A word shown under the canvas ("duck"), so the letter he traces is
    /// tied to the animal it starts. Empty for none.
    var word: String = ""
    init(_ say: String, _ stroke: TraceStroke, from: String, to: String = "", word: String = "") {
        self.say = say; self.stroke = stroke; self.from = from; self.to = to; self.word = word
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
    /// `ProblemGen`, `rounds` per game, at the current difficulty level.
    /// `boost` starts a game higher up the ladder (a First Grade "add within
    /// 20" should not open at sums to 8 just because it's never been mastered).
    case numberGen(NumberGame, rounds: Int, boost: Int = 0)
    /// Drag expressive faces onto matching words, in rounds of `perRound`.
    case faceMatch(exprs: [FaceExpr], perRound: Int)
    /// A multi-part story reader + reading-skill games (content looked up by id).
    case story(id: String)
    /// Drag each thing into the pen it belongs in. The science games are really
    /// sorting tasks, and sorting is something he DOES rather than something he
    /// reads and taps. `perRound` is how many items one play asks for.
    case sort(prompt: String, bins: [SortBin], items: [SortThing], perRound: Int = 8)
    /// Finish a sentence by DRAGGING the missing word into the gap, rather than
    /// tapping one of three tiles. The sentence stays on screen throughout and
    /// Leo reads it back once the word is in.
    case buildSentence(prompt: String, lines: [SentenceLine])
    /// Trace each letter/word with a finger — real on-screen writing practice.
    case trace(prompt: String, items: [String])
    /// Tracing with a story: an animal at the start of every stroke, somewhere
    /// to get to at the end, and the stroke itself can be a pre-writing shape
    /// (line, wave, zigzag, circle, loop) or a letter in either case. This is
    /// the writing-mechanics ladder, dressed as animals on the farm.
    case traceScene(prompt: String, steps: [TraceStep])

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
        case .traceScene(_, let s): return s.count
        case .sort(_, _, let items, let per): return min(items.count, per) + 1
        case .buildSentence(_, let l): return l.count + 1
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
        case .trace, .traceScene: return "Trace it"
        case .sort: return "Sort them out"
        case .buildSentence: return "Finish the sentence"
        }
    }
}

/// One pen to sort into: a key the items refer to, plus what he sees on it.
struct SortBin: Hashable {
    let key: String
    let label: String
    let emoji: String
    init(_ key: String, _ label: String, _ emoji: String) {
        self.key = key; self.label = label; self.emoji = emoji
    }
    /// What Leo calls this pen. A pen can hide its printed word (the blending
    /// games show only the picture, so he cannot match letters to letters);
    /// Leo still names it by its key.
    var spoken: String { label.isEmpty ? key : label }
}

/// One sentence with a hole in it: the words either side of the gap, the word
/// that belongs there, and the wrong words offered alongside it.
struct SentenceLine: Hashable {
    let picture: String
    let before: String
    let after: String
    let answer: String
    let distractors: [String]
    init(_ picture: String, _ before: String, _ after: String, answer: String, distractors: [String]) {
        self.picture = picture; self.before = before; self.after = after
        self.answer = answer; self.distractors = distractors
    }
}

/// One thing to be sorted, and the bin key it belongs in.
struct SortThing: Hashable {
    let emoji: String
    let name: String
    let bin: String
    init(_ emoji: String, _ name: String, _ bin: String) {
        self.emoji = emoji; self.name = name; self.bin = bin
    }
}
