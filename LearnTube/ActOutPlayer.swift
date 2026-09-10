import SwiftUI

// MARK: - Subtraction and addition, taught concrete-first
//
// Before a number pad ever appears, the operation is something Gabriel DOES
// to animals on the screen, in three stages that climb with mastery:
//
//   1. He acts it out.   "5 ducks. 2 swim away. YOU send them!" He taps the
//                        two that leave, then touches each one that's left to
//                        count it. Only then does the sentence appear:
//                        "5 ducks, 2 swam away, 3 are left.  5 - 2 = 3"
//                        Nothing to get wrong, nothing to type.
//   2. He counts.        The animals leave on their own; he counts what's
//                        left by touching, then picks the number from three.
//   3. He predicts.      "5 ducks. 2 are going to swim away. How many will be
//                        left?" He picks, THEN the ducks act it out and he
//                        sees the answer. No buzzer: the ducks are the check.
//   4. Number pad        (the existing NumberPadPlayer, with the visual).
//
// Adding is the mirror: "3 ducks. 2 more come. Bring them over!", count them
// all, "3 ducks and 2 more. 5 ducks in all.  3 + 2 = 5".
//
// One script everywhere: start with, some go away / more come, how many are
// left / how many in all. Never "minus", never "subtract", never "plus" in the
// words (the symbol sits under the words so it gets familiar by sight).
// The stage is chosen by `GameDifficulty.rung` (see AppState.currentRung).

struct ActOutPlayer: View {
    let game: NumberGame
    let stage: Int          // 1, 2 or 3
    let rounds: Int
    let accent: Color
    let onComplete: () -> Void

    private var takeAway: Bool { game == .takeAway || game == .oneLess }

    // One round's story.
    private struct Round {
        let emoji: String
        let name: String       // "ducks"
        let place: String      // "on the pond"
        let start: Int         // animals at the beginning
        let change: Int        // how many leave / arrive
        var answer: Int
    }
    private struct Critter: Identifiable {
        let id: Int
        var gone = false       // left the scene (take-away)
        var arrived = true     // on the scene (adding: newcomers start false)
        var number: Int? = nil // the count he gave it
    }

    private enum Phase { case act, watch, count, choose, sentence }

    @State private var roundIndex = 0
    @State private var round = Round(emoji: "🦆", name: "ducks", place: "on the pond", start: 5, change: 2, answer: 3)
    @State private var critters: [Critter] = []
    @State private var phase: Phase = .act
    @State private var moved = 0            // sent away / brought over so far
    @State private var counted = 0          // numbered so far
    @State private var guess: Int? = nil    // stage 3's prediction
    @State private var choices: [Int] = []
    @State private var mood: MascotMood = .idle
    @State private var confetti = false
    @State private var seeded = false

    // MARK: Words

    private var bubble: String {
        let n = round.name, e = round.emoji, s = round.start, c = round.change
        switch phase {
        case .act:
            return takeAway
                ? "\(s) \(n) \(round.place). \(c) go away. Tap the \(c) that leave! \(e)"
                : "\(s) \(n) \(round.place). \(c) more come! Tap each one to bring it over. \(e)"
        case .watch:
            return takeAway ? "Watch... \(c) \(n) go away!" : "Here they come! \(c) more \(n)!"
        case .count:
            return takeAway ? "How many are left? Touch each one to count! 👆"
                            : "How many in all now? Touch each one to count! 👆"
        case .choose:
            if stage == 3 {
                return takeAway
                    ? "\(s) \(n). \(c) are going to go away. How many will be left?"
                    : "\(s) \(n). \(c) more are coming. How many will there be in all?"
            }
            return takeAway ? "So how many are left? Tap the number!" : "So how many in all? Tap the number!"
        case .sentence:
            if stage == 3, let g = guess {
                return g == round.answer ? "You said \(g), and \(g) it is! 🎉" : "You said \(g). Let's see... \(round.answer)!"
            }
            return takeAway ? "\(round.answer) are left!" : "\(round.answer) in all!"
        }
    }

    var body: some View {
        GameStage(mood: mood, prompt: bubble, confetti: confetti) {
            VStack(spacing: 14) {
                ProgressDots(total: max(rounds, 1), done: roundIndex, accent: accent)
                scene
                if phase == .sentence { sentence.transition(.scale.combined(with: .opacity)) }
                if phase == .choose { choiceRow }
                if phase == .sentence {
                    Button { nextRound() } label: {
                        Text(roundIndex + 1 < rounds ? "Next  ▶" : "Done!  🎉")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 26).padding(.vertical, 12)
                            .background(accent).clipShape(Capsule())
                    }
                }
            }
            .onAppear { if !seeded { seeded = true; newRound() } }
        }
    }

    // MARK: The scene

    private var scene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.55, green: 0.82, blue: 0.98), Color(red: 0.36, green: 0.68, blue: 0.94)],
                                     startPoint: .top, endPoint: .bottom))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 84, maximum: 96), spacing: 6)], spacing: 8) {
                ForEach(critters) { c in
                    critterView(c)
                }
            }
            .padding(14)
        }
        .frame(minHeight: 250)
        .padding(.horizontal, 6)
    }

    private func critterView(_ c: Critter) -> some View {
        let tappable = (phase == .act && !c.gone && c.arrived == takeAway) || (phase == .count && c.number == nil && !c.gone && c.arrived)
        return ZStack(alignment: .topTrailing) {
            // Where a newcomer will land, before it arrives (adding).
            Circle().strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [7, 6]))
                .foregroundStyle(.white.opacity(c.arrived ? 0 : 0.8))
                .frame(width: 84, height: 84)
            Text(round.emoji)
                .font(.system(size: 60))
                .frame(width: 84, height: 84)
                .background(
                    Circle().fill(.white.opacity(c.number != nil ? 0.55 : 0.22))
                )
                .scaleEffect(c.arrived ? 1 : 0.2)
                .opacity(c.gone || !c.arrived ? 0 : 1)
                .offset(x: c.gone ? 260 : 0, y: c.gone ? -40 : 0)
                .animation(.spring(response: 0.7, dampingFraction: 0.7), value: c.gone)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: c.arrived)
            if let n = c.number {
                Text("\(n)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.green))
                    .offset(x: 4, y: -4)
                    .transition(.scale)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { tapped(c) }
        .scaleEffect(tappable ? 1.0 : 0.96)
    }

    private var sentence: some View {
        let s = round.start, c = round.change, a = round.answer, n = round.name
        let words = takeAway ? "\(s) \(n), \(c) went away, \(a) are left."
                             : "\(s) \(n) and \(c) more. \(a) \(n) in all."
        return VStack(spacing: 6) {
            Text(words)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            HStack(spacing: 14) {
                big("\(s)", Color(red: 0.40, green: 0.70, blue: 1.0))
                big(takeAway ? "−" : "+", .white.opacity(0.8))
                big("\(c)", Color(red: 1.0, green: 0.62, blue: 0.25))
                big("=", .white.opacity(0.8))
                big("\(a)", Theme.green)
            }
        }
        .padding(.vertical, 8)
    }

    private func big(_ t: String, _ color: Color) -> some View {
        Text(t).font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(color)
    }

    private var choiceRow: some View {
        HStack(spacing: 16) {
            ForEach(choices, id: \.self) { n in
                Button { choose(n) } label: {
                    Text("\(n)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 84, height: 84)
                        .background(Circle().fill(accent))
                }
            }
        }
    }

    // MARK: Flow

    private func newRound() {
        round = Self.makeRound(takeAway: takeAway, one: game == .oneMore || game == .oneLess)
        moved = 0; counted = 0; guess = nil; confetti = false; mood = .idle
        let total = takeAway ? round.start : round.start + round.change
        critters = (0..<total).map { i in
            Critter(id: i, gone: false, arrived: takeAway ? true : i < round.start, number: nil)
        }
        choices = Self.choices(for: round.answer)
        switch stage {
        case 1: phase = .act
        case 2: phase = .watch; DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { autoMove() }
        default: phase = .choose
        }
    }

    private func tapped(_ c: Critter) {
        guard let i = critters.firstIndex(where: { $0.id == c.id }) else { return }
        switch phase {
        case .act:
            if takeAway {
                guard !critters[i].gone, moved < round.change else { return }
                critters[i].gone = true
            } else {
                guard !critters[i].arrived, moved < round.change else { return }
                critters[i].arrived = true
            }
            moved += 1
            SFX.tap()
            if moved >= round.change {
                mood = .happy
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { phase = .count }
            }
        case .count:
            guard critters[i].number == nil, !critters[i].gone, critters[i].arrived else { return }
            counted += 1
            withAnimation(.spring()) { critters[i].number = counted }
            SFX.tap()
            if counted >= round.answer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if stage == 2 { phase = .choose } else { land() }
                }
            }
        default: break
        }
    }

    /// Stage 2 and 3: the animals move on their own, one at a time.
    private func autoMove() {
        var delay = 0.0
        for k in 0..<round.change {
            delay += 0.65
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if takeAway {
                    if let i = critters.lastIndex(where: { !$0.gone }) { critters[i].gone = true }
                } else {
                    if let i = critters.firstIndex(where: { !$0.arrived }) { critters[i].arrived = true }
                }
                SFX.tap()
                if k == round.change - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        if stage == 3 { autoCount() } else { phase = .count }
                    }
                }
            }
        }
    }

    /// Stage 3: after the prediction, the count runs itself so he can check.
    private func autoCount() {
        phase = .count
        let ids = critters.filter { !$0.gone && $0.arrived }.map(\.id)
        for (k, id) in ids.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45 * Double(k + 1)) {
                if let i = critters.firstIndex(where: { $0.id == id }) {
                    withAnimation(.spring()) { critters[i].number = k + 1 }
                    SFX.tap()
                }
                if k == ids.count - 1 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { land() } }
            }
        }
    }

    private func choose(_ n: Int) {
        if stage == 3 {
            guess = n
            // No buzzer: the animals show him. A miss is still recorded so the
            // dashboard can see where he's guessing.
            if n != round.answer { GameStats.markWrong() }
            phase = .watch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { autoMove() }
        } else {
            if n == round.answer { land() }
            else { SFX.wrong(); mood = .oops; DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { mood = .idle } }
        }
    }

    private func land() {
        withAnimation(.spring()) { phase = .sentence }
        let right = guess == nil || guess == round.answer
        mood = right ? .cheer : .happy
        confetti = right
        SFX.correct()
    }

    private func nextRound() {
        if roundIndex + 1 < rounds {
            roundIndex += 1
            newRound()
        } else {
            SFX.win(); onComplete()
        }
    }

    // MARK: Problems

    private static let scenes: [(String, String, String)] = [
        ("🦆", "ducks", "on the pond"), ("🐔", "hens", "in the yard"), ("🐷", "pigs", "in the mud"),
        ("🐐", "goats", "on the hill"), ("🐸", "frogs", "on the log"), ("🐝", "bees", "at the hive"),
        ("🐑", "sheep", "in the field"), ("🐰", "bunnies", "in the garden"), ("🐥", "chicks", "by the barn"),
        ("🐄", "cows", "in the barn"), ("🐴", "horses", "by the fence"), ("🐟", "fish", "in the pond")
    ]
    private static var lastAnswer = -1

    private static func makeRound(takeAway: Bool, one: Bool) -> Round {
        let (e, n, p) = scenes.randomElement()!
        // Small on purpose: this is where the idea lands, not where it stretches.
        for _ in 0..<20 {
            var start: Int, change: Int
            if takeAway {
                start = Int.random(in: 3...7)
                change = one ? 1 : Int.random(in: 1...(start - 1))
            } else {
                start = Int.random(in: 1...5)
                change = one ? 1 : Int.random(in: 1...4)
            }
            let ans = takeAway ? start - change : start + change
            if ans != lastAnswer { lastAnswer = ans; return Round(emoji: e, name: n, place: p, start: start, change: change, answer: ans) }
        }
        return Round(emoji: e, name: n, place: p, start: 5, change: 2, answer: takeAway ? 3 : 7)
    }

    private static func choices(for a: Int) -> [Int] {
        var set: Set<Int> = [a]
        var tries = 0
        while set.count < 3 && tries < 30 {
            tries += 1
            let d = [-2, -1, 1, 2].randomElement()!
            if a + d >= 0 { set.insert(a + d) }
        }
        return Array(set).shuffled()
    }
}
