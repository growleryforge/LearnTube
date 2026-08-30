import Foundation

// MARK: - Interactive lesson model
// Lessons are static content (not persisted), so they don't need Codable.

struct Choice: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let isCorrect: Bool
}

struct Question: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let options: [Choice]

    /// Convenience: give the correct answer and the wrong ones.
    init(_ prompt: String, correct: String, wrong: [String]) {
        self.prompt = prompt
        self.options = [Choice(label: correct, isCorrect: true)]
            + wrong.map { Choice(label: $0, isCorrect: false) }
    }
}

struct NumberProblem: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let answer: Int
    let visual: [String]     // optional objects to count on screen (empty = none)
    init(_ prompt: String, _ answer: Int, visual: [String] = []) {
        self.prompt = prompt; self.answer = answer; self.visual = visual
    }
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
        case .numberPad: return "Solve it"
        case .faceMatch: return "Tap to match"
        case .story: return "Story time"
        case .trace: return "Trace it"
        }
    }
}
