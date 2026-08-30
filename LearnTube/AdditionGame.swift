import SwiftUI

// MARK: - Anti-pattern helpers (Gabriel detects any pattern instantly)
//
// Two rules applied across every "pick the right one" game:
//  1) Targets come from a shuffled bag - no repeats until the whole set has been
//     shown, and never the same one twice in a row - so questions keep varying.
//  2) On a wrong-answer reshuffle the correct tile is forced to a NEW position,
//     so its location never sits still long enough to become a pattern.

extension Array where Element: Equatable {
    /// A shuffle in which `item` does not stay at `currentIndex` (when possible).
    func shuffledMoving(_ item: Element, from currentIndex: Int) -> [Element] {
        guard count > 1 else { return shuffled() }
        var out = shuffled()
        var tries = 0
        while out.firstIndex(of: item) == currentIndex && tries < 16 { out = shuffled(); tries += 1 }
        return out
    }
}

// MARK: - Addition-only math engine for Gabriel
//
// What we learned watching him play: he can't win by mashing. So the core
// counting action is now DIRECT - he taps each animal one at a time and it
// lights up and counts (1, 2, 3...). You cannot fake that by pressing buttons,
// and it teaches one-to-one correspondence (the real Kindergarten skill) with
// almost no reading. Two-group steps still let him DRAG the pets together
// first, then count them all.
//
// For the few multiple-choice questions, a WRONG tap reshuffles every choice -
// new positions AND new numbers - so process-of-elimination and "memorize the
// spot" both stop working. No punishment, he just keeps going until he really
// chooses the right one. Fresh numbers every play. Nothing above 10, never any
// subtraction.

enum AdditionConcept {
    case count, plusOne, countAll, countOn, numberBond, makeTen
    var isTwoGroup: Bool {
        switch self { case .countAll, .countOn, .numberBond: return true; default: return false }
    }
}

struct AdditionLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let concept: AdditionConcept
    let rounds: Int
}

struct AddChoice: Identifiable {
    let id = UUID()
    let label: String
    let correct: Bool
}

struct AddQuestion {
    let prompt: String
    let visual: [String]          // shown for multiple-choice questions
    let choices: [AddChoice]
    let answer: Int
    var countItems: [String] = [] // the animals he taps to count (count == answer)
    var groupA: [String] = []
    var groupB: [String] = []
    /// When there are animals to tap-count, use the direct counting mechanic.
    var useTapCount: Bool { !countItems.isEmpty }
}

// MARK: - Question generator

enum AdditionGen {
    private static let cat = "🐱"
    private static let dog = "🐶"

    /// Three choices for a given answer: the correct value plus two fresh near
    /// distractors, all shuffled. Called again after every wrong tap so the
    /// board never stays the same.
    static func choiceSet(answer: Int) -> [AddChoice] {
        var pool = Set<Int>(); var spread = 1
        while pool.count < 2 {
            for d in [-spread, spread] { let n = answer + d; if (0...10).contains(n) && n != answer { pool.insert(n) } }
            spread += 1; if spread > 10 { break }
        }
        let wrongs = Array(pool).shuffled().prefix(2)
        var r = [AddChoice(label: "\(answer)", correct: true)]
        for w in wrongs { r.append(AddChoice(label: "\(w)", correct: false)) }
        return r.shuffled()
    }

    static func make(_ concept: AdditionConcept) -> AddQuestion {
        switch concept {
        case .count:      return count()
        case .plusOne:    return plusOne()
        case .countAll:   return countAll()
        case .countOn:    return countOn()
        case .numberBond: return numberBond()
        case .makeTen:    return makeTen()
        }
    }

    private static func count() -> AddQuestion {
        let a = Int.random(in: 2...6)
        let animal = Bool.random() ? cat : dog
        let items = Array(repeating: animal, count: a)
        return AddQuestion(prompt: "Tap each one to count!", visual: items,
                           choices: choiceSet(answer: a), answer: a, countItems: items)
    }

    private static func plusOne() -> AddQuestion {
        let a = Int.random(in: 1...8)
        let animal = Bool.random() ? cat : dog
        let items = Array(repeating: animal, count: a + 1)
        return AddQuestion(prompt: "One more! Tap each one to count.", visual: items,
                           choices: choiceSet(answer: a + 1), answer: a + 1, countItems: items)
    }

    private static func countAll() -> AddQuestion {
        var a = Int.random(in: 1...3), b = Int.random(in: 1...3)
        while a + b < 2 || a + b > 6 { a = Int.random(in: 1...3); b = Int.random(in: 1...3) }
        return twoGroup(a, b)
    }

    private static func countOn() -> AddQuestion {
        var a = Int.random(in: 3...7), b = Int.random(in: 1...3)
        while a + b > 10 { a = Int.random(in: 3...7); b = Int.random(in: 1...3) }
        return twoGroup(a, b)
    }

    private static func numberBond() -> AddQuestion {
        var a = Int.random(in: 2...6), b = Int.random(in: 2...6)
        while a + b < 4 || a + b > 10 { a = Int.random(in: 2...6); b = Int.random(in: 2...6) }
        return twoGroup(a, b)
    }

    /// Two groups (cats + dogs): drag them together, then tap-count them all.
    private static func twoGroup(_ a: Int, _ b: Int) -> AddQuestion {
        let groupA = Array(repeating: cat, count: a)
        let groupB = Array(repeating: dog, count: b)
        let items = groupA + groupB
        return AddQuestion(prompt: "Count them all!", visual: items,
                           choices: choiceSet(answer: a + b), answer: a + b,
                           countItems: items, groupA: groupA, groupB: groupB)
    }

    private static func makeTen() -> AddQuestion {
        let a = Int.random(in: 5...9); let missing = 10 - a
        let prompt = ["How many more make 10?", "How many more?"].randomElement()!
        let v = Array(repeating: cat, count: a) + ["➕", "❓", "🟰", "🔟"]
        return AddQuestion(prompt: prompt, visual: v, choices: choiceSet(answer: missing), answer: missing)
    }
}

// MARK: - Confetti (shapes, works everywhere)

struct ConfettiView: View {
    @State private var go = false
    private let n = 22
    private let colors: [Color] = [Theme.red, .yellow, Theme.green, .blue, .pink, .orange, .purple]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<n, id: \.self) { i in
                    let x = CGFloat.random(in: 0...geo.size.width)
                    let size = CGFloat.random(in: 8...16)
                    let dur = Double.random(in: 1.0...1.7)
                    let delay = Double.random(in: 0...0.25)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors[i % colors.count])
                        .frame(width: size, height: size * 1.4)
                        .position(x: x, y: go ? geo.size.height + 40 : -40)
                        .rotationEffect(.degrees(go ? Double.random(in: 180...720) : 0))
                        .animation(.easeIn(duration: dur).delay(delay), value: go)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { go = true }
    }
}

// MARK: - Cheer overlay

struct CheerOverlay: View {
    var custom: String? = nil      // an optional teaching fact shown UNDER the praise
    @State private var pop = false
    private let cheers = ["🎉 Great job!", "⭐️ You did it!", "🙌 Awesome!", "💛 So smart!",
                          "🌟 Yes! Correct!", "🥳 Woohoo!", "🎈 Amazing!", "🎊 Superstar!",
                          "👏 Way to go!", "🦁 Roar! Nice!"]
    @State private var praise = ""
    var body: some View {
        ZStack {
            ConfettiView()
            BalloonsView()
            VStack(spacing: 16) {
                // Leo the cub, cheering.
                Mascot(mood: .cheer, size: 140)
                    .rotationEffect(.degrees(pop ? -5 : 5))
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: pop)
                // He always says good job...
                Text(praise)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30).padding(.vertical, 16)
                    .background(Theme.green).clipShape(RoundedRectangle(cornerRadius: 26))
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
                // ...then teaches the fact, if the game gave one.
                if let c = custom, !c.isEmpty {
                    Text(c)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(Theme.ink.opacity(0.75)).clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 20)
                }
            }
            .scaleEffect(pop ? 1 : 0.4).opacity(pop ? 1 : 0)
        }
        .onAppear {
            praise = cheers.randomElement() ?? "Great job!"
            withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) { pop = true }
        }
    }
}

// MARK: - Balloons (rise up on a win, for maximum festivity)

struct BalloonsView: View {
    @State private var go = false
    private let n = 14
    private let party = ["🎈", "🎉", "🎊", "🎈", "⭐️", "🌟", "🎈"]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<n, id: \.self) { i in
                    let x = CGFloat.random(in: 0...geo.size.width)
                    let size = CGFloat.random(in: 34...64)
                    let dur = Double.random(in: 2.2...3.6)
                    let delay = Double.random(in: 0...0.5)
                    Text(party[i % party.count])
                        .font(.system(size: size))
                        .position(x: x, y: go ? -90 : geo.size.height + 90)
                        .rotationEffect(.degrees(go ? Double.random(in: -14...14) : 0))
                        .animation(.easeOut(duration: dur).delay(delay), value: go)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { go = true }
    }
}

// MARK: - Tap each one to count (the direct, un-mashable counting mechanic)

struct TapCountView: View {
    let items: [String]
    let onDone: () -> Void

    @State private var tapped: [Int] = []      // indices in the order they were tapped
    @State private var order: [Int: Int] = [:] // index -> the number it was counted as
    @State private var bump = false

    private let cols = [GridItem(.adaptive(minimum: 76, maximum: 104), spacing: 12)]
    private var done: Bool { tapped.count == items.count }

    var body: some View {
        VStack(spacing: 16) {
            Text(done ? "That's \(items.count)!" : "👆 Tap each one to count")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundStyle(done ? Theme.green : .white)
                .multilineTextAlignment(.center)

            Text("\(tapped.count)")
                .font(.system(size: 76, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(bump ? 1.3 : 1)
                .frame(height: 84)

            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, a in
                    Button { tapOne(i) } label: { cell(i, a) }
                        .disabled(order[i] != nil || done)
                }
            }
            .padding(16).frame(maxWidth: .infinity)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.horizontal, 4)
    }

    private func cell(_ i: Int, _ a: String) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(order[i] != nil ? Theme.green.opacity(0.85) : Theme.surfaceHi)
            EmojiView(emoji: a, size: 54, tint: .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let n = order[i] {
                Text("\(n)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Theme.red))
                    .offset(x: 8, y: -8)
            }
        }
        .frame(height: 92)
        .scaleEffect(order[i] != nil ? 1.06 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: order[i] != nil)
    }

    private func tapOne(_ i: Int) {
        guard order[i] == nil else { return }
        tapped.append(i)
        order[i] = tapped.count
        SFX.tap()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { bump = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { bump = false }
        if tapped.count == items.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { SFX.win(); onDone() }
        }
    }
}

// MARK: - Drag the pets into the pen (two-group concepts)

struct DragCombineView: View {
    let groupA: [String]
    let groupB: [String]
    let onDone: () -> Void

    @State private var offA: CGSize = .zero
    @State private var offB: CGSize = .zero
    @State private var pennedA = false
    @State private var pennedB = false
    @State private var wiggle = false

    var body: some View {
        VStack(spacing: 16) {
            Text("🐾 Drag the pets together!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)

            HStack(spacing: 22) {
                if !pennedA { chip(groupA, off: $offA, penned: $pennedA, color: Color(red: 0.95, green: 0.45, blue: 0.45)) }
                if !pennedB { chip(groupB, off: $offB, penned: $pennedB, color: Color(red: 0.35, green: 0.62, blue: 0.92)) }
                if pennedA && pennedB {
                    Text("All in! 🎉").font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                }
            }
            .frame(height: 80)

            VStack(spacing: 8) {
                Text("The Pen").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                let inPen = (pennedA ? groupA : []) + (pennedB ? groupB : [])
                if inPen.isEmpty {
                    Text("⬇️ Drop the pets here")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity).frame(height: 110)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 46), spacing: 6)], spacing: 6) {
                        ForEach(Array(inPen.enumerated()), id: \.offset) { _, a in
                            EmojiView(emoji: a, size: 36, tint: .white).frame(height: 48)
                        }
                    }.padding(8).frame(maxWidth: .infinity)
                }
            }
            .padding(14).frame(maxWidth: .infinity)
            .background(Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
                    .foregroundStyle(Theme.green.opacity(pennedA && pennedB ? 0.9 : 0.4))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(wiggle ? 1.03 : 1)
        }
    }

    private func chip(_ animals: [String], off: Binding<CGSize>, penned: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(animals.enumerated()), id: \.offset) { _, a in EmojiView(emoji: a, size: 32, tint: .white) }
        }
        .padding(12).background(color.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .offset(off.wrappedValue)
        .highPriorityGesture(
            DragGesture()
                .onChanged { v in off.wrappedValue = v.translation }
                .onEnded { v in
                    if v.translation.height > 70 {
                        SFX.correct()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { penned.wrappedValue = true; wiggle = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { wiggle = false; check() }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { off.wrappedValue = .zero }
                    }
                }
        )
    }

    private func check() {
        if pennedA && pennedB { DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onDone() } }
    }
}

// MARK: - Animated count display (used for the makeTen multiple-choice screen)

struct AnimatedCount: View {
    let tokens: [String]
    @State private var shown = false
    private let cols = [GridItem(.adaptive(minimum: 64, maximum: 84), spacing: 10)]
    private func isOp(_ t: String) -> Bool { ["➕", "🟰", "=", "🔟", "❓"].contains(t) }
    var body: some View {
        LazyVGrid(columns: cols, spacing: 10) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { i, t in
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isOp(t) ? Color.clear : Theme.surfaceHi)
                    EmojiView(emoji: t, size: isOp(t) ? 34 : 48, tint: .white)
                }
                .frame(height: 74)
                .opacity(isOp(t) ? 0.7 : 1)
                .scaleEffect(shown ? 1 : 0.2)
                .opacity(shown ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(Double(i) * 0.06), value: shown)
            }
        }
        .padding(16).frame(maxWidth: .infinity)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onAppear { shown = true }
    }
}

// MARK: - Addition player (one level)

struct AdditionPlayer: View {
    let level: AdditionLevel
    let accent: Color
    let onComplete: () -> Void

    enum Phase { case drag, count, ask }
    @State private var round = 0
    @State private var phase: Phase = .count
    @State private var q = AdditionGen.make(.count)
    @State private var choices: [AddChoice] = []
    @State private var wrongId: UUID?
    @State private var cheer = false

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                ProgressDots(total: level.rounds, done: round, accent: Theme.red)

                switch phase {
                case .drag:
                    DragCombineView(groupA: q.groupA, groupB: q.groupB) {
                        withAnimation { phase = .count }
                    }
                    .id("drag\(round)")

                case .count:
                    TapCountView(items: q.countItems) { celebrate() }
                        .id("count\(round)")

                case .ask:
                    AnimatedCount(tokens: q.visual).id("ask\(round)")
                    Text(q.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    ForEach(choices) { choice in
                        Button { tap(choice) } label: { tile(choice) }
                            .wiggle(wrongId == choice.id)
                    }
                }
            }

            if cheer { CheerOverlay().transition(.opacity).id("cheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ c: AddChoice) -> some View {
        let bg: Color = wrongId == c.id ? Theme.red : Theme.surfaceHi
        return Text(c.label)
            .font(.system(size: 54, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 160)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        q = AdditionGen.make(level.concept)
        choices = q.choices
        wrongId = nil; cheer = false
        if q.useTapCount {
            phase = (!q.groupA.isEmpty) ? .drag : .count
        } else {
            phase = .ask
        }
    }

    /// Correct: confetti + cheering Gabriel, then the next round.
    private func celebrate() {
        withAnimation { cheer = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
        }
    }

    private func tap(_ c: AddChoice) {
        guard !cheer else { return }
        if c.correct {
            SFX.win(); celebrate()
        } else {
            // Reshuffle so mashing and elimination can't work: new positions AND
            // new numbers each time. No penalty - he just keeps trying.
            wrongId = c.id; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                let curCorrect = choices.firstIndex(where: { $0.correct })
                var fresh = AdditionGen.choiceSet(answer: q.answer)
                var tries = 0
                while fresh.firstIndex(where: { $0.correct }) == curCorrect && tries < 16 {
                    fresh = AdditionGen.choiceSet(answer: q.answer); tries += 1
                }
                withAnimation { choices = fresh }
            }
        }
    }
}

// MARK: - Sort & count game
//
// Sort the farm animals into their groups, then see how many are in each.
// Classification + counting each category (CA CCSS K.MD.B.3), built on the real
// farm: chickens (most), sheep, cats, and dogs (fewest). He works one group at a
// time - "Tap all the chickens!" - touching each matching animal, which lights
// up and counts. Tapping the wrong kind just wiggles, so it can't be mashed and
// he has to actually find each one.

struct SortKind: Identifiable, Hashable {
    let id: String
    let name: String
    let emojis: [String]          // several looks for the same animal (hen, rooster, chick...)
    var emoji: String { emojis[0] } // the one shown on the group's pen
}

struct SortItem: Identifiable, Hashable {
    let id = UUID()
    let kind: String
    let emoji: String
}

struct SortLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum SortGen {
    static let kinds: [SortKind] = [
        SortKind(id: "chicken", name: "chickens", emojis: ["🐔"]),
        SortKind(id: "sheep",   name: "sheep",    emojis: ["🐑"]),
        SortKind(id: "cat",     name: "cats",     emojis: ["🐱"]),
        SortKind(id: "dog",     name: "dogs",     emojis: ["🐶"])
    ]

    /// One round. Small counts so each group is easy to count, but the farm's
    /// real proportions show through: lots of chickens, only a dog or two. One
    /// consistent emoji per animal type so the groups stay clear and simple.
    static func make() -> [SortItem] {
        let counts = [Int.random(in: 4...6), Int.random(in: 3...4),
                      Int.random(in: 2...3), Int.random(in: 1...2)]
        var items: [SortItem] = []
        for (i, k) in kinds.enumerated() {
            for _ in 0..<counts[i] { items.append(SortItem(kind: k.id, emoji: k.emojis.randomElement()!)) }
        }
        return items.shuffled()
    }
}

struct SortCountPlayer: View {
    let level: SortLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var items: [SortItem] = []
    @State private var catIdx = 0
    @State private var collected: Set<UUID> = []
    @State private var counts: [Int] = [0, 0, 0, 0]
    @State private var wrongId: UUID?
    @State private var cheer = false
    @State private var showTally = false

    private var kinds: [SortKind] { SortGen.kinds }
    private var target: SortKind { kinds[catIdx] }
    private let cols = [GridItem(.adaptive(minimum: 74, maximum: 100), spacing: 10)]

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                if showTally {
                    tally
                } else {
                    Text("Count and sort all of the \(target.emoji) \(target.name)!")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    pens
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(items) { item in
                            Button { tap(item) } label: { tile(item) }
                                .disabled(collected.contains(item.id))
                                .wiggle(wrongId == item.id)
                        }
                    }
                    .padding(14).frame(maxWidth: .infinity)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }

            if cheer { CheerOverlay().transition(.opacity).id("scheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private var pens: some View {
        HStack(spacing: 10) {
            ForEach(Array(kinds.enumerated()), id: \.element.id) { i, k in
                let isTarget = i == catIdx && !showTally
                VStack(spacing: 4) {
                    EmojiView(emoji: k.emoji, size: 36, tint: .white)
                    Text("\(counts[i])")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(isTarget ? accent.opacity(0.55) : Theme.surfaceHi)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isTarget ? Theme.green : .clear, lineWidth: 4)
                )
            }
        }
    }

    private func tile(_ item: SortItem) -> some View {
        let isDone = collected.contains(item.id)
        return ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isDone ? Theme.green.opacity(0.85)
                      : (wrongId == item.id ? Theme.red : Theme.surfaceHi))
            EmojiView(emoji: item.emoji, size: 84, tint: .white)
        }
        .frame(height: 160)
        .opacity(isDone ? 0.6 : 1)
    }

    private var tally: some View {
        VStack(spacing: 14) {
            Text("Here's the whole farm! 🎉")
                .font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
            pens
            Text("You sorted them all!")
                .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(.white)
        }
    }

    private func newRound() {
        items = SortGen.make()
        catIdx = 0; collected = []; counts = [0, 0, 0, 0]
        wrongId = nil; cheer = false; showTally = false
    }

    private func tap(_ item: SortItem) {
        guard !showTally, !collected.contains(item.id) else { return }
        if item.kind == target.id {
            collected.insert(item.id)
            counts[catIdx] += 1
            SFX.tap()
            let total = items.filter { $0.kind == target.id }.count
            if counts[catIdx] == total {
                SFX.correct()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if catIdx + 1 < kinds.count { withAnimation { catIdx += 1 } }
                    else { finishRound() }
                }
            }
        } else {
            // Wrong kind: a gentle wiggle, no count, no penalty.
            wrongId = item.id; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { wrongId = nil }
        }
    }

    private func finishRound() {
        withAnimation { showTally = true }
        SFX.win()
        withAnimation { cheer = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
        }
    }
}

// MARK: - Shapes game (name & describe: circle, square, triangle, rectangle, hexagon)
//
// Names AND describes 2D shapes (CA CCSS K.G.2). Each round asks one short
// thing - "Find the triangle!" (name) or "Which has 3 sides?" / "Which one is
// round?" (describe) - and he taps the matching shape from three big colorful
// shapes. Every correct answer states the describing fact ("A hexagon has 6
// sides!"). A wrong tap reshuffles all three shapes (new shapes, new spots), so
// it can't be mashed or solved by elimination.

enum ShapeKind: String, CaseIterable, Identifiable {
    case circle, triangle, square, rectangle, hexagon
    var id: String { rawValue }
    var name: String { rawValue }
    var sides: Int {
        switch self {
        case .circle: return 0
        case .triangle: return 3
        case .square, .rectangle: return 4
        case .hexagon: return 6
        }
    }
    var color: Color {
        switch self {
        case .circle:    return Color(red: 0.95, green: 0.45, blue: 0.45)
        case .triangle:  return Color(red: 0.45, green: 0.78, blue: 0.45)
        case .square:    return Color(red: 0.35, green: 0.62, blue: 0.92)
        case .rectangle: return Color(red: 0.98, green: 0.72, blue: 0.30)
        case .hexagon:   return Color(red: 0.66, green: 0.46, blue: 0.86)
        }
    }
    /// The describing fact shown when he gets it right.
    var fact: String {
        switch self {
        case .circle:    return "A circle is round, like a turtle's shell! 🐢"
        case .triangle:  return "A triangle has 3 sides, like a cat's ear! 🐱"
        case .square:    return "A square has 4 equal sides, like a doghouse! 🐶"
        case .rectangle: return "A rectangle has 4 sides, like a fish tank! 🐟"
        case .hexagon:   return "A hexagon has 6 sides, like a honeycomb! 🐝"
        }
    }
}

/// Draws each shape with a filled path, centered in its space.
struct ShapeFigure: View {
    let kind: ShapeKind
    var color: Color

    var body: some View {
        GeometryReader { geo in path(in: geo.size).fill(color) }
    }

    private func path(in size: CGSize) -> Path {
        let w = size.width, h = size.height
        let s = min(w, h)
        let cx = w / 2, cy = h / 2
        var p = Path()
        switch kind {
        case .circle:
            let d = s * 0.92
            p.addEllipse(in: CGRect(x: cx - d / 2, y: cy - d / 2, width: d, height: d))
        case .square:
            let a = s * 0.82
            p.addRoundedRect(in: CGRect(x: cx - a / 2, y: cy - a / 2, width: a, height: a),
                             cornerSize: CGSize(width: a * 0.08, height: a * 0.08))
        case .rectangle:
            let rw = w * 0.94, rh = s * 0.56
            p.addRoundedRect(in: CGRect(x: cx - rw / 2, y: cy - rh / 2, width: rw, height: rh),
                             cornerSize: CGSize(width: rh * 0.1, height: rh * 0.1))
        case .triangle:
            let a = s * 0.94
            p.move(to: CGPoint(x: cx, y: cy - a / 2))
            p.addLine(to: CGPoint(x: cx - a / 2, y: cy + a / 2))
            p.addLine(to: CGPoint(x: cx + a / 2, y: cy + a / 2))
            p.closeSubpath()
        case .hexagon:
            let r = s * 0.5
            for i in 0..<6 {
                let ang = (Double(i) * 60.0 - 90.0) * .pi / 180.0
                let pt = CGPoint(x: cx + r * CGFloat(cos(ang)), y: cy + r * CGFloat(sin(ang)))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
        return p
    }
}

struct ShapeLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

struct ShapeQ {
    let prompt: String
    let target: ShapeKind
    let bySides: Bool        // true = "which has N sides" (avoid same-side distractors)
    var options: [ShapeKind]
}

enum ShapeGen {
    /// Two distractor shapes that don't give the answer away.
    static func distractors(for target: ShapeKind, bySides: Bool) -> [ShapeKind] {
        var pool = ShapeKind.allCases.filter { $0 != target }
        if bySides && target != .circle { pool = pool.filter { $0.sides != target.sides } }
        return Array(pool.shuffled().prefix(2))
    }

    static var bag: [ShapeKind] = []
    static var lastId: String?
    static func nextTarget() -> ShapeKind {
        if bag.isEmpty {
            bag = ShapeKind.allCases.shuffled()
            if let last = lastId, bag.count > 1, bag[0].rawValue == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.rawValue; return t
    }

    static func make() -> ShapeQ {
        let target = nextTarget()
        let bySides = Bool.random()
        let prompt: String
        if bySides {
            prompt = target == .circle ? "Which one is round? ⭕" : "Which has \(target.sides) sides?"
        } else {
            prompt = "Find the \(target.name)!"
        }
        let options = ([target] + distractors(for: target, bySides: bySides)).shuffled()
        return ShapeQ(prompt: prompt, target: target, bySides: bySides, options: options)
    }
}

struct ShapesPlayer: View {
    let level: ShapeLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var q = ShapeGen.make()
    @State private var options: [ShapeKind] = []
    @State private var wrongIdx: Int?
    @State private var cheer = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                Text(q.prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(Array(options.enumerated()), id: \.offset) { i, kind in
                        Button { tap(i) } label: { tile(kind, i) }
                            .wiggle(wrongIdx == i)
                    }
                }
            }

            if cheer { CheerOverlay(custom: q.target.fact).transition(.opacity).id("shapecheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ kind: ShapeKind, _ i: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(wrongIdx == i ? Theme.red.opacity(0.45) : Theme.surfaceHi)
            ShapeFigure(kind: kind, color: kind.color)
                .frame(width: 92, height: 92)
                .padding(14)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        q = ShapeGen.make(); options = q.options; wrongIdx = nil; cheer = false
    }

    private func tap(_ i: Int) {
        guard !cheer else { return }
        if options[i] == q.target {
            SFX.win()
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            // Reshuffle: new shapes AND new positions, so mashing and
            // elimination can't work. No penalty.
            wrongIdx = i; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongIdx = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: q.target) ?? -1
                withAnimation {
                    options = ([q.target] + ShapeGen.distractors(for: q.target, bySides: q.bySides))
                        .shuffledMoving(q.target, from: cur)
                }
            }
        }
    }
}

// MARK: - Shape Spotter (name shapes regardless of size or orientation)
//
// "Tap all the triangles!" - but the triangles are big, small, and turned every
// which way, mixed in with other shapes. He learns a triangle is still a
// triangle no matter its size or which way it faces (CA CCSS K.G.2). Tap each
// matching shape; wrong taps wiggle. Clear them all for the describing fact.

struct ShapeSpotLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

struct ShapeSpotItem: Identifiable {
    let id = UUID()
    let kind: ShapeKind
    let scale: CGFloat
    let rotation: Double
}

enum ShapeSpotGen {
    private static func rotation(for k: ShapeKind) -> Double {
        k == .circle ? 0 : Double(Int.random(in: 0...11)) * 30.0
    }

    static var bag: [ShapeKind] = []
    static var lastId: String?
    static func nextTarget() -> ShapeKind {
        if bag.isEmpty {
            bag = ShapeKind.allCases.shuffled()
            if let last = lastId, bag.count > 1, bag[0].rawValue == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.rawValue; return t
    }

    static func make() -> (target: ShapeKind, items: [ShapeSpotItem]) {
        let target = nextTarget()
        var items: [ShapeSpotItem] = []
        for _ in 0..<Int.random(in: 3...4) {
            items.append(ShapeSpotItem(kind: target,
                                       scale: CGFloat.random(in: 0.55...1.0),
                                       rotation: rotation(for: target)))
        }
        let others = ShapeKind.allCases.filter { $0 != target }
        for _ in 0..<Int.random(in: 4...6) {
            let k = others.randomElement()!
            items.append(ShapeSpotItem(kind: k,
                                       scale: CGFloat.random(in: 0.55...1.0),
                                       rotation: rotation(for: k)))
        }
        return (target, items.shuffled())
    }
}

struct ShapeSpotPlayer: View {
    let level: ShapeSpotLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target: ShapeKind = .triangle
    @State private var items: [ShapeSpotItem] = []
    @State private var found: Set<UUID> = []
    @State private var wrongId: UUID?
    @State private var cheer = false

    private let cols = [GridItem(.adaptive(minimum: 82, maximum: 108), spacing: 12)]
    private var targetCount: Int { items.filter { $0.kind == target }.count }

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                Text("Tap all the \(target.name)s!")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(items) { item in
                        Button { tap(item) } label: { tile(item) }
                            .disabled(found.contains(item.id))
                            .wiggle(wrongId == item.id)
                    }
                }
                .padding(14).frame(maxWidth: .infinity)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("spotcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ item: ShapeSpotItem) -> some View {
        let done = found.contains(item.id)
        return ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(done ? Theme.green.opacity(0.85)
                      : (wrongId == item.id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
            ShapeFigure(kind: item.kind, color: item.kind.color)
                .frame(width: 80 * item.scale, height: 80 * item.scale)
                .rotationEffect(.degrees(item.rotation))
        }
        .frame(height: 160)
        .opacity(done ? 0.6 : 1)
    }

    private func newRound() {
        let made = ShapeSpotGen.make()
        target = made.target; items = made.items
        found = []; wrongId = nil; cheer = false
    }

    private func tap(_ item: ShapeSpotItem) {
        guard !cheer, !found.contains(item.id) else { return }
        if item.kind == target {
            found.insert(item.id); SFX.tap()
            if found.count == targetCount {
                SFX.win()
                withAnimation { cheer = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                    if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
                }
            }
        } else {
            wrongId = item.id; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { wrongId = nil }
        }
    }
}

// MARK: - Letter Detective (find letters by name or sound)
//
// "Find the B!" (name) or "Which one says /b/?" (sound). He taps the matching
// letter from three big letters; each correct answer gives the sound and a key
// word ("B says /b/, like ball!"). A wrong tap reshuffles the letters, so it
// can't be mashed. Builds letter recognition and letter sounds (CA CCSS RF.K).

struct LetterInfo: Identifiable, Hashable {
    let id: String          // the uppercase letter
    var upper: String { id }
    let lower: String
    let sound: String       // phoneme, e.g. "/b/"
    let word: String        // key word, e.g. "ball"
    let emoji: String
    var fact: String { "\(upper) says \(sound), like \(word)! \(emoji)" }
}

struct LetterLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

struct LetterQ {
    let target: LetterInfo
    var options: [LetterInfo]
}

enum LetterGen {
    // Only clearly recognizable pictures, so the puzzle is "what sound does this
    // start with?" - not reading a word. Each shows a real object he can name.
    static let letters: [LetterInfo] = [
        LetterInfo(id: "A", lower: "a", sound: "/a/", word: "apple",   emoji: "🍎"),
        LetterInfo(id: "B", lower: "b", sound: "/b/", word: "ball",    emoji: "⚽"),
        LetterInfo(id: "C", lower: "c", sound: "/k/", word: "cat",     emoji: "🐱"),
        LetterInfo(id: "D", lower: "d", sound: "/d/", word: "dog",     emoji: "🐶"),
        LetterInfo(id: "E", lower: "e", sound: "/e/", word: "egg",     emoji: "🥚"),
        LetterInfo(id: "F", lower: "f", sound: "/f/", word: "fish",    emoji: "🐟"),
        LetterInfo(id: "G", lower: "g", sound: "/g/", word: "goat",    emoji: "🐐"),
        LetterInfo(id: "H", lower: "h", sound: "/h/", word: "hat",     emoji: "🎩"),
        LetterInfo(id: "L", lower: "l", sound: "/l/", word: "lion",    emoji: "🦁"),
        LetterInfo(id: "M", lower: "m", sound: "/m/", word: "moon",    emoji: "🌙"),
        LetterInfo(id: "O", lower: "o", sound: "/o/", word: "octopus", emoji: "🐙"),
        LetterInfo(id: "P", lower: "p", sound: "/p/", word: "pig",     emoji: "🐷"),
        LetterInfo(id: "R", lower: "r", sound: "/r/", word: "rabbit",  emoji: "🐰"),
        LetterInfo(id: "S", lower: "s", sound: "/s/", word: "sun",     emoji: "☀️"),
        LetterInfo(id: "T", lower: "t", sound: "/t/", word: "tree",    emoji: "🌳"),
        LetterInfo(id: "W", lower: "w", sound: "/w/", word: "whale",   emoji: "🐳"),
        LetterInfo(id: "Z", lower: "z", sound: "/z/", word: "zebra",   emoji: "🦓")
    ]

    static func distractors(for t: LetterInfo) -> [LetterInfo] {
        Array(letters.filter { $0.id != t.id && $0.sound != t.sound }.shuffled().prefix(2))
    }

    static var bag: [LetterInfo] = []
    static var lastId: String?
    static func nextTarget() -> LetterInfo {
        if bag.isEmpty {
            bag = letters.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func make() -> LetterQ {
        let t = nextTarget()
        return LetterQ(target: t, options: ([t] + distractors(for: t)).shuffled())
    }
}

struct LetterDetectivePlayer: View {
    let level: LetterLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var q = LetterGen.make()
    @State private var options: [LetterInfo] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    private var startFact: String {
        "\(q.target.word.capitalized) starts with \(q.target.upper)! \(q.target.sound) \(q.target.emoji)"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                // The mystery object - he has to name it and hear its first sound.
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface)
                    EmojiView(emoji: q.target.emoji, size: 110, tint: .white)
                }
                .frame(height: 170)

                Text("Which letter does it start with? 🔍")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(options) { letter in
                        Button { tap(letter) } label: { tile(letter) }
                            .wiggle(wrongId == letter.id)
                    }
                }
            }

            if cheer { CheerOverlay(custom: startFact).transition(.opacity).id("lettercheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ letter: LetterInfo) -> some View {
        VStack(spacing: 2) {
            Text(letter.upper)
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(letter.lower)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
        .background(revealed && letter.id == q.target.id ? Theme.green
                    : (wrongId == letter.id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        q = LetterGen.make(); options = q.options; wrongId = nil; cheer = false
        missed = 0; revealed = false
    }

    private func tap(_ letter: LetterInfo) {
        guard !cheer else { return }
        if letter.id == q.target.id {
            SFX.win()
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1
            wrongId = letter.id; SFX.wrong()
            if missed >= 2 { withAnimation { revealed = true } }   // teach: show and hold the answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if revealed { return }        // stop reshuffling — the answer stays put and green
                let cur = options.firstIndex(of: q.target) ?? -1
                withAnimation {
                    options = ([q.target] + LetterGen.distractors(for: q.target))
                        .shuffledMoving(q.target, from: cur)
                }
            }
        }
    }
}

// MARK: - Weather Detective (observe & describe weather)
//
// "Which one is sunny?" (name) or "Which one has thunder?" (describe). He taps
// the matching weather; each correct answer describes it and what to do ("Rainy!
// Grab an umbrella."). Wrong taps reshuffle. Observes and describes weather
// (CA NGSS K-ESS2-1). Weather emojis render as clean weather symbols.

struct WeatherKind: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let describe: String
    let fact: String
}

struct WeatherLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum WeatherGen {
    static let kinds: [WeatherKind] = [
        WeatherKind(id: "sun",   emoji: "☀️",  name: "sunny",  describe: "Which one is hot and bright?", fact: "Sunny! Wear a sun hat. ☀️"),
        WeatherKind(id: "rain",  emoji: "🌧️", name: "rainy",  describe: "Which one has rain?",          fact: "Rainy! Grab an umbrella. ☔"),
        WeatherKind(id: "cloud", emoji: "☁️",  name: "cloudy", describe: "Which one is gray and cloudy?", fact: "Cloudy! The sky is gray. ☁️"),
        WeatherKind(id: "snow",  emoji: "❄️",  name: "snowy",  describe: "Which one is cold and white?",  fact: "Snowy! Wear mittens. ❄️"),
        WeatherKind(id: "wind",  emoji: "💨",  name: "windy",  describe: "Which one is windy?",           fact: "Windy! Hold onto your hat. 💨"),
        WeatherKind(id: "storm", emoji: "⛈️", name: "stormy", describe: "Which one has thunder?",        fact: "Stormy! Thunder and lightning. ⛈️")
    ]

    static func distractors(for t: WeatherKind) -> [WeatherKind] {
        Array(kinds.filter { $0.id != t.id }.shuffled().prefix(2))
    }

    static var bag: [WeatherKind] = []
    static var lastId: String?
    static func nextTarget() -> WeatherKind {
        if bag.isEmpty {
            bag = kinds.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func make() -> (target: WeatherKind, prompt: String, options: [WeatherKind]) {
        let t = nextTarget()
        let prompt = Bool.random() ? "Which one is \(t.name)?" : t.describe
        return (t, prompt, ([t] + distractors(for: t)).shuffled())
    }
}

struct WeatherPlayer: View {
    let level: WeatherLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = WeatherGen.kinds[0]
    @State private var prompt = ""
    @State private var options: [WeatherKind] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                Text(prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(options) { w in
                        Button { tap(w) } label: { tile(w) }
                            .wiggle(wrongId == w.id)
                    }
                }
            }

            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("weathercheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ w: WeatherKind) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && w.id == target.id ? Theme.green : wrongId == w.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: w.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
    }

    private func newRound() {
        let made = WeatherGen.make()
        target = made.target; prompt = made.prompt; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ w: WeatherKind) {
        guard !cheer else { return }
        if w.id == target.id {
            SFX.win()
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = w.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + WeatherGen.distractors(for: target)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - Number Detective (match a numeral to a quantity)
//
// Two ways each round, both needing real counting: see a group of dots and tap
// the number that says how many, OR see a number and tap the group that shows
// that many. The answer is never written next to the picture, so he has to
// count. Wrong taps reshuffle. Number-quantity matching (CA CCSS K.CC.4/5).

struct DotGroup: View {
    let count: Int
    var color: Color = .white
    private let cols = [GridItem(.adaptive(minimum: 18, maximum: 26), spacing: 6)]
    var body: some View {
        LazyVGrid(columns: cols, spacing: 6) {
            ForEach(0..<max(count, 0), id: \.self) { _ in
                Circle().fill(color).frame(width: 20, height: 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

enum NumberMode { case countGroup, findGroup }

struct NumberQ {
    let mode: NumberMode
    let answer: Int
    let prompt: String
}

struct NumberLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum NumberGen {
    static func distractors(_ answer: Int) -> [Int] {
        var pool = Set<Int>(); var spread = 1
        while pool.count < 2 {
            for d in [-spread, spread] { let n = answer + d; if (1...10).contains(n) && n != answer { pool.insert(n) } }
            spread += 1; if spread > 10 { break }
        }
        return Array(pool.shuffled().prefix(2))
    }

    static var bag: [Int] = []
    static var lastId: Int?
    static func nextAnswer() -> Int {
        if bag.isEmpty {
            bag = Array(1...10).shuffled()
            if let last = lastId, bag.count > 1, bag[0] == last { bag.swapAt(0, bag.count - 1) }
        }
        let a = bag.removeFirst(); lastId = a; return a
    }

    static func make() -> (q: NumberQ, options: [Int]) {
        let answer = nextAnswer()
        let mode: NumberMode = Bool.random() ? .countGroup : .findGroup
        let prompt = mode == .countGroup ? "How many? Tap the number." : "Which group shows \(answer)?"
        return (NumberQ(mode: mode, answer: answer, prompt: prompt),
                ([answer] + distractors(answer)).shuffled())
    }
}

struct NumberDetectivePlayer: View {
    let level: NumberLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var q = NumberQ(mode: .countGroup, answer: 1, prompt: "")
    @State private var options: [Int] = []
    @State private var wrongVal: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                // The thing to read: a group of dots, or a big numeral.
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface)
                    if q.mode == .countGroup {
                        DotGroup(count: q.answer).padding(22)
                    } else {
                        Text("\(q.answer)")
                            .font(.system(size: 96, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 180)

                Text(q.prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(options, id: \.self) { v in
                        Button { tap(v) } label: { tile(v) }
                            .wiggle(wrongVal == v)
                    }
                }
            }

            if cheer { CheerOverlay(custom: "Yes! That's \(q.answer)! 🔢").transition(.opacity).id("numcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ v: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(revealed && v == q.answer ? Theme.green : wrongVal == v ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            if q.mode == .countGroup {
                Text("\(v)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                DotGroup(count: v).padding(12)
            }
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = NumberGen.make()
        q = made.q; options = made.options
        wrongVal = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ v: Int) {
        guard !cheer else { return }
        if v == q.answer {
            SFX.win()
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongVal = v; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongVal = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: q.answer) ?? -1
                withAnimation { options = ([q.answer] + NumberGen.distractors(q.answer)).shuffledMoving(q.answer, from: cur) }
            }
        }
    }
}

// MARK: - American Symbols (identify national symbols like the U.S. flag)
//
// "Which one is the U.S. flag?" He taps the matching national symbol; each
// correct answer tells him about it. The flag is drawn in code (stars and
// stripes) so it's unmistakable. Wrong taps reshuffle. Identifies major
// national symbols (CA HSS K.2).

struct USFlagView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<13, id: \.self) { i in
                        Rectangle().fill(i % 2 == 0 ? Color(red: 0.70, green: 0.12, blue: 0.20) : .white)
                    }
                }
                Rectangle().fill(Color(red: 0.20, green: 0.24, blue: 0.52))
                    .frame(width: w * 0.42, height: h * 7.0 / 13.0)
                    .overlay(stars(w: w * 0.42, h: h * 7.0 / 13.0))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private func stars(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: h * 0.05) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: w * 0.05) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill").resizable().scaledToFit()
                            .frame(width: w * 0.11).foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(w * 0.06)
    }
}

struct NatSymbol: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String     // ignored when isFlag is true
    let isFlag: Bool
    let fact: String
}

struct SymbolLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum SymbolGen {
    static let symbols: [NatSymbol] = [
        NatSymbol(id: "flag",  name: "U.S. flag",          emoji: "",    isFlag: true,  fact: "The U.S. flag has stars and stripes! 🇺🇸"),
        NatSymbol(id: "statue", name: "Statue of Liberty", emoji: "🗽",  isFlag: false, fact: "The Statue of Liberty holds a torch. 🗽"),
        NatSymbol(id: "eagle", name: "bald eagle",         emoji: "🦅",  isFlag: false, fact: "The bald eagle is our national bird! 🦅"),
        NatSymbol(id: "bell",  name: "Liberty Bell",       emoji: "🔔",  isFlag: false, fact: "The Liberty Bell is a sign of freedom. 🔔"),
        NatSymbol(id: "house", name: "White House",        emoji: "🏛️", isFlag: false, fact: "The White House is where the President works. 🏛️")
    ]

    static func distractors(for t: NatSymbol) -> [NatSymbol] {
        Array(symbols.filter { $0.id != t.id }.shuffled().prefix(2))
    }

    static var bag: [NatSymbol] = []
    static var lastId: String?
    static func nextTarget() -> NatSymbol {
        if bag.isEmpty {
            bag = symbols.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func make() -> (target: NatSymbol, prompt: String, options: [NatSymbol]) {
        let t = nextTarget()
        let prompt = Bool.random() ? "Which one is the \(t.name)?" : "Find the \(t.name)!"
        return (t, prompt, ([t] + distractors(for: t)).shuffled())
    }
}

struct SymbolPlayer: View {
    let level: SymbolLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = SymbolGen.symbols[0]
    @State private var prompt = ""
    @State private var options: [NatSymbol] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                Text(prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(options) { sym in
                        Button { tap(sym) } label: { tile(sym) }
                            .wiggle(wrongId == sym.id)
                    }
                }
            }

            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("symcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ sym: NatSymbol) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && sym.id == target.id ? Theme.green : (wrongId == sym.id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
            if sym.isFlag {
                USFlagView().frame(height: 70).padding(.horizontal, 12)
            } else {
                EmojiView(emoji: sym.emoji, size: 84, tint: .white)
            }
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = SymbolGen.make()
        target = made.target; prompt = made.prompt; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ sym: NatSymbol) {
        guard !cheer else { return }
        if sym.id == target.id {
            SFX.win()
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = sym.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + SymbolGen.distractors(for: target)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - Community Helpers (identify helpers in school and community)
//
// "Who puts out fires?" or "Which one is a doctor?" He taps the helper; each
// correct answer says what that helper does. Wrong taps reshuffle. Identifies
// helpers in the school and wider community (CA HSS K.3).

struct HelperKind: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let describe: String
    let fact: String
}

struct HelperLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum HelperGen {
    static let kinds: [HelperKind] = [
        HelperKind(id: "fire",    emoji: "🚒", name: "firefighter",         describe: "Who puts out fires?",            fact: "A firefighter puts out fires and keeps us safe. 🚒"),
        HelperKind(id: "police",  emoji: "🚓", name: "police officer",       describe: "Who helps keep everyone safe?",  fact: "A police officer helps keep us safe. 👮"),
        HelperKind(id: "doctor",  emoji: "🩺", name: "doctor",              describe: "Who helps you when you're sick?", fact: "A doctor helps us feel better. 🩺"),
        HelperKind(id: "teacher", emoji: "🏫", name: "teacher",             describe: "Who helps you learn at school?", fact: "A teacher helps us learn new things. 🍎"),
        HelperKind(id: "farmer",  emoji: "🚜", name: "farmer",              describe: "Who grows our food?",            fact: "A farmer grows the food we eat. 🌽"),
        HelperKind(id: "chef",    emoji: "🍳", name: "chef",                describe: "Who cooks food for us?",         fact: "A chef cooks yummy food. 🍳"),
        HelperKind(id: "builder", emoji: "🏗️", name: "construction worker", describe: "Who builds houses and roads?",   fact: "A construction worker builds things. 🏗️")
    ]

    static func distractors(for t: HelperKind) -> [HelperKind] {
        Array(kinds.filter { $0.id != t.id }.shuffled().prefix(2))
    }

    static var bag: [HelperKind] = []
    static var lastId: String?
    static func nextTarget() -> HelperKind {
        if bag.isEmpty {
            bag = kinds.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func make() -> (target: HelperKind, prompt: String, options: [HelperKind]) {
        let t = nextTarget()
        let prompt = Bool.random() ? "Which one is a \(t.name)?" : t.describe
        return (t, prompt, ([t] + distractors(for: t)).shuffled())
    }
}

struct HelperPlayer: View {
    let level: HelperLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = HelperGen.kinds[0]
    @State private var prompt = ""
    @State private var options: [HelperKind] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text(prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                HStack(spacing: 14) {
                    ForEach(options) { h in
                        Button { tap(h) } label: { tile(h.emoji, h.id) }
                            .wiggle(wrongId == h.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("helpcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ emoji: String, _ id: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && id == target.id ? Theme.green : (wrongId == id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
            EmojiView(emoji: emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = HelperGen.make()
        target = made.target; prompt = made.prompt; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ h: HelperKind) {
        guard !cheer else { return }
        if h.id == target.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = h.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + HelperGen.distractors(for: target)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - Holidays (know what major holidays celebrate)
//
// "Which holiday do we give thanks?" He taps the holiday symbol; each correct
// answer says what the holiday celebrates. Wrong taps reshuffle. Knows what
// major holidays celebrate: MLK Day, Thanksgiving, the Fourth of July, etc.
// (CA HSS K.1).

struct HolidayKind: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let meaning: String   // short intro shown when meeting the holidays
    let describe: String
    let fact: String
}

struct HolidayLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum HolidayGen {
    // In order through the year, so the intro makes sense.
    static let kinds: [HolidayKind] = [
        HolidayKind(id: "newyear", emoji: "🎉", name: "New Year's Day", meaning: "A brand-new year begins! We celebrate at midnight.",
                    describe: "Which holiday starts a brand new year?", fact: "New Year's Day starts a fresh new year! 🎉"),
        HolidayKind(id: "valentine", emoji: "💝", name: "Valentine's Day", meaning: "A day to share love and hearts with people we care about.",
                    describe: "Which holiday is about love and hearts?", fact: "Valentine's Day is about love. 💝"),
        HolidayKind(id: "mlk", emoji: "🕊️", name: "MLK Day", meaning: "We honor Dr. Martin Luther King Jr., who worked for fairness for everyone.",
                    describe: "Which day honors Dr. Martin Luther King Jr.?", fact: "MLK Day honors Dr. King, who worked for fairness for all. 🕊️"),
        HolidayKind(id: "july4", emoji: "🎆", name: "the Fourth of July", meaning: "America's birthday! We watch fireworks.",
                    describe: "Which holiday is America's birthday?", fact: "The Fourth of July is America's birthday. 🎆"),
        HolidayKind(id: "halloween", emoji: "🎃", name: "Halloween", meaning: "We wear costumes and have spooky fun.",
                    describe: "Which holiday do we wear costumes?", fact: "Halloween is for costumes and fun. 🎃"),
        HolidayKind(id: "thanks", emoji: "🦃", name: "Thanksgiving", meaning: "We give thanks and share a big meal together.",
                    describe: "Which holiday do we give thanks and eat turkey?", fact: "Thanksgiving is when we give thanks. 🦃")
    ]

    static func distractors(for t: HolidayKind) -> [HolidayKind] {
        Array(kinds.filter { $0.id != t.id }.shuffled().prefix(2))
    }

    static var bag: [HolidayKind] = []
    static var lastId: String?
    static func nextTarget() -> HolidayKind {
        if bag.isEmpty {
            bag = kinds.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func make() -> (target: HolidayKind, prompt: String, options: [HolidayKind]) {
        let t = nextTarget()
        let prompt = Bool.random() ? "Which one is \(t.name)?" : t.describe
        return (t, prompt, ([t] + distractors(for: t)).shuffled())
    }
}

struct HolidayPlayer: View {
    let level: HolidayLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = HolidayGen.kinds[0]
    @State private var prompt = ""
    @State private var options: [HolidayKind] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: Phase = .teach
    @State private var teachIndex = 0
    enum Phase { case teach, play }

    private var kinds: [HolidayKind] { HolidayGen.kinds }

    var body: some View {
        ZStack {
            if phase == .teach {
                teachView
            } else {
                VStack(spacing: 26) {
                    if level.rounds > 1 {
                        ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                    }
                    Text(prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(options) { h in
                            Button { tap(h) } label: { tile(h.emoji, h.id) }
                                .wiggle(wrongId == h.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("holcheer\(round)") }
        }
        .onAppear { phase = .teach; teachIndex = 0; round = 0; newRound() }
    }

    // Meet each holiday one at a time before the quiz.
    private var teachView: some View {
        let h = kinds[teachIndex]
        return VStack(spacing: 18) {
            Text("Let's meet the holidays!")
                .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface)
                VStack(spacing: 12) {
                    EmojiView(emoji: h.emoji, size: 90, tint: .white)
                    Text(h.name.hasPrefix("the ") ? String(h.name.dropFirst(4)).capitalized : h.name)
                        .font(.system(size: 26, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    Text(h.meaning)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                }
            }
            .frame(height: 260)
            HStack(spacing: 7) {
                ForEach(kinds.indices, id: \.self) { i in
                    Circle().fill(i == teachIndex ? accent : Theme.surfaceHi).frame(width: 8, height: 8)
                }
            }
            Button {
                if teachIndex < kinds.count - 1 { withAnimation { teachIndex += 1 } }
                else { withAnimation { phase = .play } }
            } label: {
                Text(teachIndex < kinds.count - 1 ? "Next →" : "Let's play! 🎮")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Theme.green).clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 4)
    }

    private func tile(_ emoji: String, _ id: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && id == target.id ? Theme.green : (wrongId == id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
            EmojiView(emoji: emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = HolidayGen.make()
        target = made.target; prompt = made.prompt; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ h: HolidayKind) {
        guard !cheer else { return }
        if h.id == target.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = h.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + HolidayGen.distractors(for: target)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - My Family (name family members and describe their roles at home)
//
// Families come in all kinds; this one is Gabriel's: his two moms, Mommy and
// Maddy, plus the cats and dogs. He matches each family member to what they do
// at home ("Who teaches you at home?"). Names + roles (CA HSS K.3 / SEL). Moms
// are friendly drawn avatars for now (real photos can be swapped in later).

/// A cute drawn lion. The family are lions: Maddy the Lion (mane), Mommy the
/// Lioness (glasses), and Gabriel the Lion Cub (smaller, lighter, with a tuft).
struct LionView: View {
    var mane: Bool = false
    var glasses: Bool = false
    var cub: Bool = false
    var body: some View {
        GeometryReader { g in
            let s = min(g.size.width, g.size.height)
            let coat = cub ? Color(red: 0.98, green: 0.83, blue: 0.56) : Color(red: 0.93, green: 0.72, blue: 0.40)
            let maneC = Color(red: 0.70, green: 0.43, blue: 0.18)
            let muzzle = Color(red: 0.99, green: 0.94, blue: 0.84)
            let nose = Color(red: 0.45, green: 0.27, blue: 0.22)
            ZStack {
                Circle().fill(Color(white: 0.22))
                // mane (ring of tufts) for the Lion
                if mane {
                    ForEach(0..<12, id: \.self) { i in
                        let a = Double(i) / 12.0 * 2.0 * .pi
                        Circle().fill(maneC)
                            .frame(width: s * 0.30, height: s * 0.30)
                            .offset(x: CGFloat(cos(a)) * s * 0.33, y: CGFloat(sin(a)) * s * 0.33)
                    }
                }
                // ears
                Circle().fill(coat).frame(width: s * 0.24, height: s * 0.24).offset(x: -s * 0.22, y: -s * 0.25)
                Circle().fill(coat).frame(width: s * 0.24, height: s * 0.24).offset(x: s * 0.22, y: -s * 0.25)
                Circle().fill(maneC.opacity(0.55)).frame(width: s * 0.11, height: s * 0.11).offset(x: -s * 0.22, y: -s * 0.25)
                Circle().fill(maneC.opacity(0.55)).frame(width: s * 0.11, height: s * 0.11).offset(x: s * 0.22, y: -s * 0.25)
                // cub head tuft
                if cub {
                    Capsule().fill(maneC).frame(width: s * 0.06, height: s * 0.15).offset(y: -s * 0.33)
                }
                // face
                Circle().fill(coat).frame(width: s * 0.62, height: s * 0.62)
                // muzzle + nose + mouth
                Ellipse().fill(muzzle).frame(width: s * 0.38, height: s * 0.30).offset(y: s * 0.13)
                Ellipse().fill(nose).frame(width: s * 0.11, height: s * 0.08).offset(y: s * 0.04)
                Capsule().fill(nose.opacity(0.7)).frame(width: s * 0.02, height: s * 0.08).offset(y: s * 0.12)
                // eyes
                HStack(spacing: s * 0.18) {
                    Circle().fill(.black.opacity(0.82)).frame(width: s * 0.07, height: s * 0.07)
                    Circle().fill(.black.opacity(0.82)).frame(width: s * 0.07, height: s * 0.07)
                }.offset(y: -s * 0.05)
                // glasses for the Lioness
                if glasses {
                    HStack(spacing: s * 0.04) {
                        Circle().strokeBorder(.black.opacity(0.7), lineWidth: s * 0.024).frame(width: s * 0.19, height: s * 0.19)
                        Circle().strokeBorder(.black.opacity(0.7), lineWidth: s * 0.024).frame(width: s * 0.19, height: s * 0.19)
                    }.offset(y: -s * 0.05)
                }
            }
            .frame(width: s, height: s)
            .clipShape(Circle())
        }
    }
}

enum FamilyFace: Hashable {
    case photo(String)
    case lion(mane: Bool, glasses: Bool, cub: Bool)
}

@ViewBuilder
func familyFaceView(_ face: FamilyFace, size: CGFloat) -> some View {
    switch face {
    case .photo(let name):
        PetAvatar(imageName: name, size: size)
    case .lion(let mane, let glasses, let cub):
        LionView(mane: mane, glasses: glasses, cub: cub).frame(width: size, height: size)
    }
}

struct FamilyMember: Identifiable, Hashable {
    let id: String
    let name: String
    let face: FamilyFace
    let role: String          // the "Who ...?" question
    let fact: String
    var nickname: String = ""  // lion-family nickname for the people
    var concept: [String] = [] // emoji that picture what the question is about
}

struct FamilyMemberLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum FamilyGen {
    static let members: [FamilyMember] = [
        FamilyMember(id: "gabe",  name: "Gabriel",
                     face: .lion(mane: false, glasses: false, cub: true),
                     role: "Who learns and plays every day?",
                     fact: "That's you, Gabriel, our Lion Cub! You learn and play. 🦁🐾",
                     nickname: "Lion Cub",
                     concept: ["📚", "🎲"]),
        FamilyMember(id: "mommy", name: "Mommy",
                     face: .lion(mane: false, glasses: true, cub: false),
                     role: "Who teaches you at home?",
                     fact: "Mommy the Lioness teaches you at home! 🦁📚",
                     nickname: "Lioness",
                     concept: ["📖", "🍎"]),
        FamilyMember(id: "maddy", name: "Maddy",
                     face: .lion(mane: true, glasses: false, cub: false),
                     role: "Who works on computers to help people get healthcare?",
                     fact: "Maddy the Lion works on computers to help people get healthcare! 🦁💻",
                     nickname: "Lion",
                     concept: ["💻", "🩺"]),
        FamilyMember(id: "cats",  name: "the cats",
                     face: .photo("EllieCat"),
                     role: "Who cuddles and purrs?",
                     fact: "The cats cuddle and purr! 🐱",
                     concept: ["🐱", "💤"]),
        FamilyMember(id: "dogs",  name: "the dogs",
                     face: .photo("Bodhi"),
                     role: "Who guards the farm and plays?",
                     fact: "The dogs guard the farm and love to play! 🐶",
                     concept: ["🐕", "🏡"])
    ]

    static var bag: [FamilyMember] = []
    static var lastId: String?
    static func nextTarget() -> FamilyMember {
        if bag.isEmpty {
            bag = members.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func distractors(for t: FamilyMember) -> [FamilyMember] {
        Array(members.filter { $0.id != t.id }.shuffled().prefix(2))
    }

    static func make() -> (target: FamilyMember, options: [FamilyMember]) {
        let t = nextTarget()
        return (t, ([t] + distractors(for: t)).shuffled())
    }
}

struct FamilyMemberPlayer: View {
    let level: FamilyMemberLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = FamilyGen.members[0]
    @State private var options: [FamilyMember] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                // A picture of what the question is about (teaching, computers...).
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.surface)
                    HStack(spacing: 18) {
                        ForEach(target.concept, id: \.self) { e in
                            EmojiView(emoji: e, size: 58, tint: .white)
                        }
                    }
                }
                .frame(height: 120)

                Text(target.role)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    ForEach(options) { m in
                        Button { tap(m) } label: { tile(m) }
                            .wiggle(wrongId == m.id)
                    }
                }
            }

            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("famcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ m: FamilyMember) -> some View {
        VStack(spacing: 6) {
            familyFaceView(m.face, size: 74)
            Text(m.name)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).lineLimit(1)
            Text(m.nickname.isEmpty ? " " : "🦁 \(m.nickname)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(revealed && m.id == target.id ? Theme.green : wrongId == m.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        let made = FamilyGen.make()
        target = made.target; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ m: FamilyMember) {
        guard !cheer else { return }
        if m.id == target.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = m.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + FamilyGen.distractors(for: target)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - What Comes Next? (patterns)
//
// A repeating color pattern with a "?" at the end; he taps the color that comes
// next. The "?" falls at different points each round so the answer is never in a
// fixed spot, and a wrong tap reshuffles. Recognizes and extends patterns (CA K).

struct PatColor: Identifiable, Hashable {
    let id: String
    let color: Color
    var emoji: String = ""
}

struct PatternLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

struct PatternQ {
    let shown: [PatColor]
    let answer: PatColor
}

enum PatternGen {
    // Animal patterns instead of plain colors - far more fun, same skill.
    static let palette: [PatColor] = [
        PatColor(id: "dog",    color: Color(red: 0.85, green: 0.55, blue: 0.35), emoji: "🐶"),
        PatColor(id: "cat",    color: Color(red: 0.95, green: 0.65, blue: 0.35), emoji: "🐱"),
        PatColor(id: "rabbit", color: Color(red: 0.72, green: 0.72, blue: 0.76), emoji: "🐰"),
        PatColor(id: "frog",   color: Color(red: 0.40, green: 0.78, blue: 0.45), emoji: "🐸"),
        PatColor(id: "chick",  color: Color(red: 0.98, green: 0.80, blue: 0.30), emoji: "🐥")
    ]

    static func distractors(_ answer: PatColor) -> [PatColor] {
        Array(palette.filter { $0.id != answer.id }.shuffled().prefix(2))
    }

    static func make() -> (q: PatternQ, options: [PatColor]) {
        let types = [["A", "B"], ["A", "B", "C"], ["A", "A", "B"], ["A", "B", "B"]]
        let type = types.randomElement()!
        let letters = Array(Set(type)).sorted()
        let colors = Array(palette.shuffled().prefix(letters.count))
        var map: [String: PatColor] = [:]
        for (i, l) in letters.enumerated() { map[l] = colors[i] }
        let unit = type.map { map[$0]! }
        let count = unit.count * 2 + Int.random(in: 0..<unit.count)
        let shown = (0..<count).map { unit[$0 % unit.count] }
        let answer = unit[count % unit.count]
        let options = ([answer] + distractors(answer)).shuffled()
        return (PatternQ(shown: shown, answer: answer), options)
    }
}

struct PatternPlayer: View {
    let level: PatternLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var q = PatternQ(shown: [], answer: PatternGen.palette[0])
    @State private var options: [PatColor] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    private let cols = [GridItem(.adaptive(minimum: 46, maximum: 60), spacing: 8)]

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text("What comes next?")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                // the pattern, ending in a "?"
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(Array(q.shown.enumerated()), id: \.offset) { _, c in
                        EmojiView(emoji: c.emoji, size: 42, tint: .white).frame(height: 48)
                    }
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [5, 4]))
                        .foregroundStyle(.white.opacity(0.6))
                        .overlay(Text("?").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white))
                        .frame(height: 48)
                }
                .padding(14).frame(maxWidth: .infinity)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))

                HStack(spacing: 16) {
                    ForEach(options) { c in
                        Button { tap(c) } label: {
                            EmojiView(emoji: c.emoji, size: 84, tint: .white)
                                .frame(width: 160, height: 160)
                                .background(revealed && c.id == q.answer.id ? Theme.green : wrongId == c.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .wiggle(wrongId == c.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: "Yes! You found the pattern! 🎉").transition(.opacity).id("patcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func newRound() {
        let made = PatternGen.make()
        q = made.q; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ c: PatColor) {
        guard !cheer else { return }
        if c.id == q.answer.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = c.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: q.answer) ?? -1
                withAnimation { options = ([q.answer] + PatternGen.distractors(q.answer)).shuffledMoving(q.answer, from: cur) }
            }
        }
    }
}

// MARK: - Rhyme Time (words that rhyme)
//
// "Which one rhymes with cat?" Shows a picture word, then picture-word choices;
// he taps the one that rhymes. Builds rhyming, a key reading sound skill
// (CA CCSS RF.K.2a). No-repeat targets, wrong taps reshuffle.

struct RhymeItem: Identifiable, Hashable {
    let id: String
    let word: String
    let emoji: String
    let group: String
}

struct RhymeLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum RhymeGen {
    static let items: [RhymeItem] = [
        RhymeItem(id: "cat",   word: "cat",   emoji: "🐱", group: "at"),
        RhymeItem(id: "hat",   word: "hat",   emoji: "🎩", group: "at"),
        RhymeItem(id: "bat",   word: "bat",   emoji: "🦇", group: "at"),
        RhymeItem(id: "dog",   word: "dog",   emoji: "🐶", group: "og"),
        RhymeItem(id: "frog",  word: "frog",  emoji: "🐸", group: "og"),
        RhymeItem(id: "bee",   word: "bee",   emoji: "🐝", group: "ee"),
        RhymeItem(id: "tree",  word: "tree",  emoji: "🌳", group: "ee"),
        RhymeItem(id: "key",   word: "key",   emoji: "🔑", group: "ee"),
        RhymeItem(id: "star",  word: "star",  emoji: "⭐", group: "ar"),
        RhymeItem(id: "car",   word: "car",   emoji: "🚗", group: "ar"),
        RhymeItem(id: "fox",   word: "fox",   emoji: "🦊", group: "ox"),
        RhymeItem(id: "box",   word: "box",   emoji: "📦", group: "ox"),
        RhymeItem(id: "socks", word: "socks", emoji: "🧦", group: "ox"),
        RhymeItem(id: "cake",  word: "cake",  emoji: "🍰", group: "ake"),
        RhymeItem(id: "snake", word: "snake", emoji: "🐍", group: "ake"),
        RhymeItem(id: "moon",  word: "moon",  emoji: "🌙", group: "oon"),
        RhymeItem(id: "spoon", word: "spoon", emoji: "🥄", group: "oon")
    ]

    static var bag: [RhymeItem] = []
    static var lastId: String?
    static func nextTarget() -> RhymeItem {
        if bag.isEmpty {
            bag = items.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let t = bag.removeFirst(); lastId = t.id; return t
    }

    static func distractors(for t: RhymeItem) -> [RhymeItem] {
        Array(items.filter { $0.group != t.group }.shuffled().prefix(2))
    }

    static func make() -> (target: RhymeItem, correct: RhymeItem, options: [RhymeItem]) {
        let t = nextTarget()
        let correct = items.filter { $0.group == t.group && $0.id != t.id }.randomElement()!
        let options = ([correct] + distractors(for: t)).shuffled()
        return (t, correct, options)
    }
}

struct RhymePlayer: View {
    let level: RhymeLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = RhymeGen.items[0]
    @State private var correct = RhymeGen.items[1]
    @State private var options: [RhymeItem] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.surface)
                    VStack(spacing: 4) {
                        EmojiView(emoji: target.emoji, size: 80, tint: .white)
                        Text(target.word).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    }
                }
                .frame(height: 160)

                Text("Which one rhymes with \(target.word)?")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    ForEach(options) { item in
                        Button { tap(item) } label: { tile(item) }
                            .wiggle(wrongId == item.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: "\(correct.word.capitalized) rhymes with \(target.word)! 🎵").transition(.opacity).id("rhymecheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ item: RhymeItem) -> some View {
        VStack(spacing: 6) {
            EmojiView(emoji: item.emoji, size: 84, tint: .white)
            Text(item.word).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
        .background(revealed && item.id == correct.id ? Theme.green
                    : (wrongId == item.id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func newRound() {
        let made = RhymeGen.make()
        target = made.target; correct = made.correct; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ item: RhymeItem) {
        guard !cheer else { return }
        if item.id == correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1
            wrongId = item.id; SFX.wrong()
            if missed >= 2 { withAnimation { revealed = true } }   // teach: show and hold the answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if revealed { return }        // stop reshuffling — the answer stays put and green
                let cur = options.firstIndex(of: correct) ?? -1
                withAnimation { options = ([correct] + RhymeGen.distractors(for: target)).shuffledMoving(correct, from: cur) }
            }
        }
    }
}

// MARK: - Flat or Solid (2D vs 3D shapes)
//
// Identifies shapes as flat (2D) or solid (3D) - CA CCSS K.G.3. "Which one is
// flat?" / "Which one is solid?" with drawn flat shapes and drawn 3D solids
// mixed together. Wrong taps reshuffle.

enum SolidKind: Hashable { case sphere, cube, cylinder, cone }

struct Solid3DView: View {
    let kind: SolidKind
    var color: Color
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let s = min(w, h)
            let cx = w / 2, cy = h / 2
            ZStack {
                switch kind {
                case .sphere:
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.white.opacity(0.95), color]),
                                             center: UnitPoint(x: 0.35, y: 0.30), startRadius: s * 0.02, endRadius: s * 0.55))
                        .frame(width: s * 0.86, height: s * 0.86).position(x: cx, y: cy)
                case .cube:
                    Path { p in
                        p.move(to: CGPoint(x: cx - s * 0.28, y: cy - s * 0.16)); p.addLine(to: CGPoint(x: cx, y: cy - s * 0.32))
                        p.addLine(to: CGPoint(x: cx + s * 0.28, y: cy - s * 0.16)); p.addLine(to: CGPoint(x: cx, y: cy)); p.closeSubpath()
                    }.fill(color.opacity(0.78))
                    Path { p in
                        p.move(to: CGPoint(x: cx - s * 0.28, y: cy - s * 0.16)); p.addLine(to: CGPoint(x: cx, y: cy))
                        p.addLine(to: CGPoint(x: cx, y: cy + s * 0.30)); p.addLine(to: CGPoint(x: cx - s * 0.28, y: cy + s * 0.14)); p.closeSubpath()
                    }.fill(color)
                    Path { p in
                        p.move(to: CGPoint(x: cx + s * 0.28, y: cy - s * 0.16)); p.addLine(to: CGPoint(x: cx, y: cy))
                        p.addLine(to: CGPoint(x: cx, y: cy + s * 0.30)); p.addLine(to: CGPoint(x: cx + s * 0.28, y: cy + s * 0.14)); p.closeSubpath()
                    }.fill(color.opacity(0.55))
                case .cylinder:
                    let bh = s * 0.58, ew = s * 0.5, eh = s * 0.16
                    Rectangle().fill(color).frame(width: ew, height: bh).position(x: cx, y: cy)
                    Ellipse().fill(color.opacity(0.7)).frame(width: ew, height: eh).position(x: cx, y: cy + bh / 2)
                    Ellipse().fill(color).frame(width: ew, height: eh).position(x: cx, y: cy - bh / 2)
                    Ellipse().fill(.white.opacity(0.3)).frame(width: ew, height: eh).position(x: cx, y: cy - bh / 2)
                case .cone:
                    let baseW = s * 0.56, baseH = s * 0.16
                    Path { p in
                        p.move(to: CGPoint(x: cx, y: cy - s * 0.34)); p.addLine(to: CGPoint(x: cx - baseW / 2, y: cy + s * 0.22))
                        p.addLine(to: CGPoint(x: cx + baseW / 2, y: cy + s * 0.22)); p.closeSubpath()
                    }.fill(color)
                    Ellipse().fill(color.opacity(0.7)).frame(width: baseW, height: baseH).position(x: cx, y: cy + s * 0.22)
                }
            }
        }
    }
}

enum GeoFigure: Hashable { case flat(ShapeKind); case solid(SolidKind) }

struct GeoItem: Identifiable, Hashable {
    let id: String
    let name: String
    let fact: String
    let figure: GeoFigure
    var isFlat: Bool { if case .flat = figure { return true } else { return false } }
}

struct GeoLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum GeoGen {
    static let items: [GeoItem] = [
        GeoItem(id: "circle",    name: "circle",    fact: "A circle is flat. You can draw it! ⭕",   figure: .flat(.circle)),
        GeoItem(id: "square",    name: "square",    fact: "A square is flat. You can draw it! ◻️",   figure: .flat(.square)),
        GeoItem(id: "triangle",  name: "triangle",  fact: "A triangle is flat. You can draw it! 🔺", figure: .flat(.triangle)),
        GeoItem(id: "rectangle", name: "rectangle", fact: "A rectangle is flat. You can draw it!",   figure: .flat(.rectangle)),
        GeoItem(id: "sphere",   name: "sphere",   fact: "A sphere is solid, like a ball! ⚽",        figure: .solid(.sphere)),
        GeoItem(id: "cube",     name: "cube",     fact: "A cube is solid, like a box! 📦",          figure: .solid(.cube)),
        GeoItem(id: "cylinder", name: "cylinder", fact: "A cylinder is solid, like a can! 🥫",      figure: .solid(.cylinder)),
        GeoItem(id: "cone",     name: "cone",     fact: "A cone is solid, like an ice cream cone! 🍦", figure: .solid(.cone))
    ]

    static func distractors(flat: Bool) -> [GeoItem] {
        Array(items.filter { $0.isFlat != flat }.shuffled().prefix(2))
    }

    static func make() -> (target: GeoItem, prompt: String, options: [GeoItem]) {
        let wantFlat = Bool.random()
        let correct = items.filter { $0.isFlat == wantFlat }.randomElement()!
        let prompt = wantFlat ? "Which one is flat?" : "Which one is solid?"
        let options = ([correct] + distractors(flat: wantFlat)).shuffled()
        return (correct, prompt, options)
    }
}

struct FlatSolidPlayer: View {
    let level: GeoLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var target = GeoGen.items[0]
    @State private var prompt = ""
    @State private var options: [GeoItem] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: Phase = .teach
    enum Phase { case teach, play }

    var body: some View {
        ZStack {
            if phase == .teach {
                teachView
            } else {
                VStack(spacing: 20) {
                    // The definition stays on top of every question as a reminder.
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            ShapeFigure(kind: .circle, color: ShapeKind.circle.color).frame(width: 24, height: 24)
                            Text("FLAT = draw it").font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        HStack(spacing: 6) {
                            Solid3DView(kind: .sphere, color: accent).frame(width: 26, height: 26)
                            Text("SOLID = hold it").font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(Theme.surface).clipShape(Capsule())

                    if level.rounds > 1 {
                        ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                    }
                    Text(prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(options) { item in
                            Button { tap(item) } label: { tile(item) }
                                .wiggle(wrongId == item.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: target.fact).transition(.opacity).id("geocheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    // Shown once before the questions: what "flat" and "solid" mean, with examples.
    private var teachView: some View {
        VStack(spacing: 22) {
            Text("Some shapes are flat.\nSome are solid.")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
            HStack(spacing: 16) {
                VStack(spacing: 10) {
                    ShapeFigure(kind: .circle, color: ShapeKind.circle.color).frame(width: 78, height: 78)
                    Text("FLAT").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    Text("you can draw it ✏️").font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
                VStack(spacing: 10) {
                    Solid3DView(kind: .sphere, color: accent).frame(width: 86, height: 86)
                    Text("SOLID").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    Text("you can hold it ✋").font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
            }
            Button { withAnimation { phase = .play } } label: {
                Text("Let's play! 🎮")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Theme.green).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder private func figure(_ item: GeoItem) -> some View {
        switch item.figure {
        case .flat(let s):  ShapeFigure(kind: s, color: s.color).frame(width: 78, height: 78)
        case .solid(let s): Solid3DView(kind: s, color: accent).frame(width: 86, height: 86)
        }
    }

    private func tile(_ item: GeoItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && item.id == target.id ? Theme.green : wrongId == item.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            figure(item)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = GeoGen.make()
        target = made.target; prompt = made.prompt; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ item: GeoItem) {
        guard !cheer else { return }
        if item.id == target.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = item.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: target) ?? -1
                withAnimation { options = ([target] + GeoGen.distractors(flat: target.isFlat)).shuffledMoving(target, from: cur) }
            }
        }
    }
}

// MARK: - Plant or Animal? (sort living things by observable characteristics)
//
// "Which one is a plant?", "Which one can fly?", "Which one lives in water?".
// He sorts living things by what he can observe (CA NGSS K life science). Wrong
// taps reshuffle; the question kind doesn't repeat back-to-back.

enum LivingTrait { case plant, animal, fly, water }

struct LivingThing: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let isPlant: Bool
    let canFly: Bool
    let inWater: Bool
}

struct LivingLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum LivingGen {
    static let things: [LivingThing] = [
        LivingThing(id: "tree",      name: "tree",      emoji: "🌳", isPlant: true,  canFly: false, inWater: false),
        LivingThing(id: "sunflower", name: "sunflower", emoji: "🌻", isPlant: true,  canFly: false, inWater: false),
        LivingThing(id: "cactus",    name: "cactus",    emoji: "🌵", isPlant: true,  canFly: false, inWater: false),
        LivingThing(id: "flower",    name: "flower",    emoji: "🌷", isPlant: true,  canFly: false, inWater: false),
        LivingThing(id: "fern",      name: "fern",      emoji: "🌿", isPlant: true,  canFly: false, inWater: false),
        LivingThing(id: "dog",       name: "dog",       emoji: "🐶", isPlant: false, canFly: false, inWater: false),
        LivingThing(id: "cat",       name: "cat",       emoji: "🐱", isPlant: false, canFly: false, inWater: false),
        LivingThing(id: "rabbit",    name: "rabbit",    emoji: "🐰", isPlant: false, canFly: false, inWater: false),
        LivingThing(id: "elephant",  name: "elephant",  emoji: "🐘", isPlant: false, canFly: false, inWater: false),
        LivingThing(id: "bird",      name: "bird",      emoji: "🐦", isPlant: false, canFly: true,  inWater: false),
        LivingThing(id: "butterfly", name: "butterfly", emoji: "🦋", isPlant: false, canFly: true,  inWater: false),
        LivingThing(id: "bee",       name: "bee",       emoji: "🐝", isPlant: false, canFly: true,  inWater: false),
        LivingThing(id: "fish",      name: "fish",      emoji: "🐟", isPlant: false, canFly: false, inWater: true),
        LivingThing(id: "frog",      name: "frog",      emoji: "🐸", isPlant: false, canFly: false, inWater: true)
    ]

    static var lastType: LivingTrait?

    static func correctPool(_ t: LivingTrait) -> [LivingThing] {
        switch t {
        case .plant:  return things.filter { $0.isPlant }
        case .animal: return things.filter { !$0.isPlant }
        case .fly:    return things.filter { $0.canFly }
        case .water:  return things.filter { $0.inWater }
        }
    }

    static func distractors(for t: LivingTrait) -> [LivingThing] {
        let pool: [LivingThing]
        switch t {
        case .plant:  pool = things.filter { !$0.isPlant }
        case .animal: pool = things.filter { $0.isPlant }
        case .fly:    pool = things.filter { !$0.canFly }
        case .water:  pool = things.filter { !$0.inWater }
        }
        return Array(pool.shuffled().prefix(2))
    }

    static func prompt(_ t: LivingTrait) -> String {
        switch t {
        case .plant:  return "Which one is a plant? 🌱"
        case .animal: return "Which one is an animal? 🐾"
        case .fly:    return "Which one can fly?"
        case .water:  return "Which one lives in water? 💧"
        }
    }

    static func fact(_ t: LivingTrait, _ c: LivingThing) -> String {
        switch t {
        case .plant:  return "A \(c.name) is a plant. It grows in the ground! 🌱"
        case .animal: return "A \(c.name) is an animal. It moves and eats! 🐾"
        case .fly:    return "A \(c.name) can fly! 🦋"
        case .water:  return "A \(c.name) lives in the water! 💧"
        }
    }

    static func make() -> (type: LivingTrait, prompt: String, correct: LivingThing, fact: String, options: [LivingThing]) {
        let all: [LivingTrait] = [.plant, .animal, .fly, .water]
        var t = all.randomElement()!
        if let last = lastType, t == last { t = all.filter { $0 != last }.randomElement()! }
        lastType = t
        let correct = correctPool(t).randomElement()!
        let options = ([correct] + distractors(for: t)).shuffled()
        return (t, prompt(t), correct, fact(t, correct), options)
    }
}

struct LivingThingsPlayer: View {
    let level: LivingLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var type: LivingTrait = .plant
    @State private var prompt = ""
    @State private var correct = LivingGen.things[0]
    @State private var fact = ""
    @State private var options: [LivingThing] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text(prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                HStack(spacing: 14) {
                    ForEach(options) { thing in
                        Button { tap(thing) } label: { tile(thing) }
                            .wiggle(wrongId == thing.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: fact).transition(.opacity).id("livingcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ thing: LivingThing) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && thing.id == correct.id ? Theme.green : wrongId == thing.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: thing.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = LivingGen.make()
        type = made.type; prompt = made.prompt; correct = made.correct; fact = made.fact; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ thing: LivingThing) {
        guard !cheer else { return }
        if thing.id == correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = thing.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: correct) ?? -1
                withAnimation { options = ([correct] + LivingGen.distractors(for: type)).shuffledMoving(correct, from: cur) }
            }
        }
    }
}

// MARK: - Bigger or Smaller? (compare objects by size, height, weight)
//
// Two objects; "Which is bigger?", "Which is taller?", "Which is heavier?" He
// taps the right one. Describes and compares measurable attributes (CA CCSS
// K.MD.1-2). A wrong tap swaps their spots so position can't be a pattern.

enum CompAttr { case size, height, weight }

struct CompObject: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let size: Int
    let height: Int
    let weight: Int
    func value(_ a: CompAttr) -> Int {
        switch a { case .size: return size; case .height: return height; case .weight: return weight }
    }
}

struct CompareLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum CompareGen {
    static let objects: [CompObject] = [
        CompObject(id: "ant",      emoji: "🐜", name: "ant",      size: 1,  height: 1,  weight: 1),
        CompObject(id: "mouse",    emoji: "🐭", name: "mouse",    size: 2,  height: 2,  weight: 2),
        CompObject(id: "feather",  emoji: "🪶", name: "feather",  size: 2,  height: 1,  weight: 1),
        CompObject(id: "flower",   emoji: "🌷", name: "flower",   size: 3,  height: 3,  weight: 2),
        CompObject(id: "ball",     emoji: "⚽", name: "ball",     size: 3,  height: 3,  weight: 3),
        CompObject(id: "cat",      emoji: "🐱", name: "cat",      size: 4,  height: 4,  weight: 4),
        CompObject(id: "dog",      emoji: "🐶", name: "dog",      size: 5,  height: 5,  weight: 5),
        CompObject(id: "rock",     emoji: "🪨", name: "rock",     size: 4,  height: 3,  weight: 8),
        CompObject(id: "car",      emoji: "🚗", name: "car",      size: 7,  height: 5,  weight: 9),
        CompObject(id: "tree",     emoji: "🌳", name: "tree",     size: 8,  height: 9,  weight: 8),
        CompObject(id: "giraffe",  emoji: "🦒", name: "giraffe",  size: 8,  height: 10, weight: 8),
        CompObject(id: "house",    emoji: "🏠", name: "house",    size: 9,  height: 8,  weight: 10),
        CompObject(id: "elephant", emoji: "🐘", name: "elephant", size: 9,  height: 8,  weight: 10),
        CompObject(id: "whale",    emoji: "🐋", name: "whale",    size: 10, height: 7,  weight: 10),
        CompObject(id: "mountain", emoji: "🏔️", name: "mountain", size: 10, height: 10, weight: 10)
    ]

    static var lastKey: String?

    static func prompt(_ a: CompAttr, more: Bool) -> String {
        switch a {
        case .size:   return more ? "Which one is bigger?"  : "Which one is smaller?"
        case .height: return more ? "Which one is taller?"  : "Which one is shorter?"
        case .weight: return more ? "Which one is heavier?" : "Which one is lighter?"
        }
    }

    static func word(_ a: CompAttr, more: Bool) -> String {
        switch a {
        case .size:   return more ? "bigger"  : "smaller"
        case .height: return more ? "taller"  : "shorter"
        case .weight: return more ? "heavier" : "lighter"
        }
    }

    static func make() -> (prompt: String, correct: CompObject, fact: String, options: [CompObject]) {
        let attrs: [CompAttr] = [.size, .height, .weight]
        var attr = attrs.randomElement()!
        let more = Bool.random()
        var key = "\(attr)-\(more)"
        if key == lastKey { attr = attrs.randomElement()!; key = "\(attr)-\(more)" }
        lastKey = key

        var a = objects.randomElement()!, b = objects.randomElement()!
        var tries = 0
        while (a.id == b.id || abs(a.value(attr) - b.value(attr)) < 3) && tries < 80 {
            a = objects.randomElement()!; b = objects.randomElement()!; tries += 1
        }
        let correct = more
            ? (a.value(attr) >= b.value(attr) ? a : b)
            : (a.value(attr) <= b.value(attr) ? a : b)
        let fact = "The \(correct.name) is \(word(attr, more: more))! 🎉"
        return (prompt(attr, more: more), correct, fact, [a, b].shuffled())
    }
}

struct CompareObjectsPlayer: View {
    let level: CompareLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var prompt = ""
    @State private var correct = CompareGen.objects[0]
    @State private var fact = ""
    @State private var options: [CompObject] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 26) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text(prompt)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                HStack(spacing: 16) {
                    ForEach(options) { obj in
                        Button { tap(obj) } label: { tile(obj) }
                            .wiggle(wrongId == obj.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: fact).transition(.opacity).id("compcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ obj: CompObject) -> some View {
        VStack(spacing: 8) {
            EmojiView(emoji: obj.emoji, size: 76, tint: .white)
            Text(obj.name).font(.system(size: 17, weight: .heavy, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
        .background(revealed && obj.id == correct.id ? Theme.green : wrongId == obj.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        let made = CompareGen.make()
        prompt = made.prompt; correct = made.correct; fact = made.fact; options = made.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ obj: CompObject) {
        guard !cheer else { return }
        if obj.id == correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongId = obj.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongId = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: correct) ?? -1
                withAnimation { options = options.shuffledMoving(correct, from: cur) }
            }
        }
    }
}

// MARK: - Build the Shape (compose simple shapes into a bigger picture)
//
// CA CCSS K.G.6: compose simple shapes to form a larger shape. He sees a
// picture built from simple shapes (a house, a tree, a rocket...) with ONE
// piece missing, shown as a dashed outline. He taps the simple shape that
// fills the gap. Which piece is missing is random each round, the builds come
// from a no-repeat bag, and a wrong tap reshuffles the choices - so there is
// no pattern to memorize.

/// A triangle that FILLS its frame (apex at top). Unlike ShapeFigure's
/// aspect-locked icon, this stretches, so pieces can be tall or wide.
struct BuildTriangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// Draws one build piece so it FILLS its frame (a rectangle can be tall, a
/// circle can be a wheel). `outline` draws the dashed empty gap to fill.
struct BuildPieceView: View {
    let kind: ShapeKind
    let color: Color
    var outline: Bool = false

    private var shape: AnyShape {
        switch kind {
        case .circle:             return AnyShape(Circle())
        case .triangle:           return AnyShape(BuildTriangle())
        case .square, .rectangle: return AnyShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        case .hexagon:            return AnyShape(RoundedRectangle(cornerRadius: 10, style: .continuous)) // unused in builds
        }
    }

    var body: some View {
        if outline {
            ZStack {
                shape.fill(Color.white.opacity(0.10))
                shape.stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, dash: [7, 5]))
            }
        } else {
            shape.fill(color)
        }
    }
}

struct BuildPiece: Hashable {
    let kind: ShapeKind
    let color: Color
    let cx: CGFloat        // center x, 0...1 of canvas
    let cy: CGFloat        // center y, 0...1 of canvas
    let w: CGFloat         // width,  fraction of canvas
    let h: CGFloat         // height, fraction of canvas
    var rotation: Double = 0
}

struct ShapeBuild: Identifiable, Hashable {
    let id: String
    let name: String       // "house", "tree", ...
    let pieces: [BuildPiece]
}

struct BuildLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

/// Renders a build. If `missingIndex` is a valid piece index, that piece is
/// drawn as a dashed empty gap; pass -1 to draw the whole, finished picture.
struct BuildCanvas: View {
    let build: ShapeBuild
    var missingIndex: Int = -1
    var canvas: CGFloat = 220

    var body: some View {
        ZStack {
            ForEach(Array(build.pieces.enumerated()), id: \.offset) { idx, piece in
                BuildPieceView(kind: piece.kind, color: piece.color, outline: idx == missingIndex)
                    .frame(width: piece.w * canvas, height: piece.h * canvas)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(x: piece.cx * canvas, y: piece.cy * canvas)
            }
        }
        .frame(width: canvas, height: canvas)
    }
}

struct BuildRound {
    let build: ShapeBuild
    let missingIndex: Int
    let answer: ShapeKind
    let prompt: String
    let fact: String
    var options: [ShapeKind]
}

enum BuildGen {
    static let brown = Color(red: 0.55, green: 0.38, blue: 0.22)
    static let gray  = Color(red: 0.40, green: 0.43, blue: 0.48)

    static let builds: [ShapeBuild] = [
        ShapeBuild(id: "house", name: "house", pieces: [
            BuildPiece(kind: .square,   color: ShapeKind.square.color,   cx: 0.5, cy: 0.66, w: 0.48, h: 0.48),
            BuildPiece(kind: .triangle, color: ShapeKind.triangle.color, cx: 0.5, cy: 0.33, w: 0.74, h: 0.40)
        ]),
        ShapeBuild(id: "tree", name: "tree", pieces: [
            BuildPiece(kind: .rectangle, color: brown,                    cx: 0.5, cy: 0.80, w: 0.16, h: 0.34),
            BuildPiece(kind: .triangle,  color: ShapeKind.triangle.color, cx: 0.5, cy: 0.40, w: 0.66, h: 0.58)
        ]),
        ShapeBuild(id: "rocket", name: "rocket", pieces: [
            BuildPiece(kind: .rectangle, color: ShapeKind.square.color,  cx: 0.5, cy: 0.56, w: 0.30, h: 0.54),
            BuildPiece(kind: .triangle,  color: ShapeKind.circle.color,  cx: 0.5, cy: 0.20, w: 0.30, h: 0.30)
        ]),
        ShapeBuild(id: "ice cream", name: "ice cream", pieces: [
            BuildPiece(kind: .triangle, color: brown,                   cx: 0.5, cy: 0.66, w: 0.40, h: 0.46, rotation: 180),
            BuildPiece(kind: .circle,   color: ShapeKind.circle.color,  cx: 0.5, cy: 0.34, w: 0.46, h: 0.46)
        ]),
        ShapeBuild(id: "truck", name: "truck", pieces: [
            BuildPiece(kind: .rectangle, color: ShapeKind.rectangle.color, cx: 0.5,  cy: 0.50, w: 0.70, h: 0.34),
            BuildPiece(kind: .circle,    color: gray,                      cx: 0.34, cy: 0.74, w: 0.20, h: 0.20),
            BuildPiece(kind: .circle,    color: gray,                      cx: 0.66, cy: 0.74, w: 0.20, h: 0.20)
        ]),
        ShapeBuild(id: "boat", name: "boat", pieces: [
            BuildPiece(kind: .rectangle, color: brown,                  cx: 0.5, cy: 0.72, w: 0.66, h: 0.18),
            BuildPiece(kind: .triangle,  color: ShapeKind.circle.color, cx: 0.5, cy: 0.42, w: 0.44, h: 0.50)
        ]),
        ShapeBuild(id: "robot", name: "robot", pieces: [
            BuildPiece(kind: .rectangle, color: ShapeKind.square.color, cx: 0.5, cy: 0.70, w: 0.50, h: 0.40),
            BuildPiece(kind: .square,    color: gray,                   cx: 0.5, cy: 0.30, w: 0.40, h: 0.36)
        ]),
        // Animals built from simple shapes - same skill, lots more fun.
        ShapeBuild(id: "fish", name: "fish", pieces: [
            BuildPiece(kind: .triangle, color: ShapeKind.rectangle.color, cx: 0.80, cy: 0.50, w: 0.30, h: 0.42, rotation: 270),
            BuildPiece(kind: .circle,   color: ShapeKind.rectangle.color, cx: 0.42, cy: 0.50, w: 0.54, h: 0.54)
        ]),
        ShapeBuild(id: "cat", name: "cat", pieces: [
            BuildPiece(kind: .triangle, color: gray, cx: 0.34, cy: 0.28, w: 0.22, h: 0.26),
            BuildPiece(kind: .triangle, color: gray, cx: 0.66, cy: 0.28, w: 0.22, h: 0.26),
            BuildPiece(kind: .circle,   color: gray, cx: 0.50, cy: 0.58, w: 0.56, h: 0.56)
        ]),
        ShapeBuild(id: "caterpillar", name: "caterpillar", pieces: [
            BuildPiece(kind: .circle, color: ShapeKind.triangle.color, cx: 0.22, cy: 0.5, w: 0.26, h: 0.26),
            BuildPiece(kind: .circle, color: ShapeKind.triangle.color, cx: 0.42, cy: 0.5, w: 0.26, h: 0.26),
            BuildPiece(kind: .circle, color: ShapeKind.triangle.color, cx: 0.62, cy: 0.5, w: 0.26, h: 0.26),
            BuildPiece(kind: .circle, color: ShapeKind.triangle.color, cx: 0.82, cy: 0.5, w: 0.26, h: 0.26)
        ]),
        ShapeBuild(id: "snail", name: "snail", pieces: [
            BuildPiece(kind: .rectangle, color: Color(red: 0.62, green: 0.74, blue: 0.45), cx: 0.45, cy: 0.66, w: 0.66, h: 0.20),
            BuildPiece(kind: .circle,    color: brown, cx: 0.56, cy: 0.44, w: 0.46, h: 0.46)
        ])
    ]

    static var teachBuild: ShapeBuild { builds[0] } // house

    static var bag: [ShapeBuild] = []
    static var lastId: String?
    static func nextBuild() -> ShapeBuild {
        if bag.isEmpty {
            bag = builds.shuffled()
            if let last = lastId, bag.count > 1, bag[0].id == last { bag.swapAt(0, bag.count - 1) }
        }
        let b = bag.removeFirst(); lastId = b.id; return b
    }

    static func distractors(for k: ShapeKind) -> [ShapeKind] {
        Array(ShapeKind.allCases.filter { $0 != k }.shuffled().prefix(2))
    }

    static func fact(_ build: ShapeBuild, _ k: ShapeKind) -> String {
        "You built the \(build.name)! That piece was a \(k.name). 🎉"
    }

    static func make() -> BuildRound {
        let b = nextBuild()
        let mi = Int.random(in: 0..<b.pieces.count)
        let ans = b.pieces[mi].kind
        let options = ([ans] + distractors(for: ans)).shuffled()
        return BuildRound(build: b, missingIndex: mi, answer: ans,
                          prompt: "Which shape finishes the \(b.name)?",
                          fact: fact(b, ans), options: options)
    }
}

struct ShapeBuilderPlayer: View {
    let level: BuildLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = BuildGen.make()
    @State private var wrongKind: ShapeKind?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: Phase = .teach
    enum Phase { case teach, play }

    var body: some View {
        ZStack {
            if phase == .teach {
                teachView
            } else {
                VStack(spacing: 16) {
                    if level.rounds > 1 {
                        ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                    }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    BuildCanvas(build: data.build, missingIndex: data.missingIndex, canvas: 220)
                        .frame(width: 220, height: 220)
                        .padding(.vertical, 4)
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { k in
                            Button { tap(k) } label: { tile(k) }
                                .wiggle(wrongKind == k)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("buildcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    // Shown once: simple shapes join together to make a picture.
    private var teachView: some View {
        VStack(spacing: 22) {
            Text("Shapes join together\nto build pictures!")
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
            HStack(spacing: 10) {
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 52, height: 52)
                Text("+").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                ShapeFigure(kind: .square, color: ShapeKind.square.color).frame(width: 48, height: 48)
                Text("=").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                BuildCanvas(build: BuildGen.teachBuild, missingIndex: -1, canvas: 92)
                    .frame(width: 92, height: 92)
            }
            .padding(.vertical, 16).padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
            Text("A triangle and a square make a house.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
            Button { withAnimation { phase = .play } } label: {
                Text("Let's play! 🎮")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Theme.green).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 4)
    }

    private func tile(_ k: ShapeKind) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && k == data.answer ? Theme.green : wrongKind == k ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            ShapeFigure(kind: k, color: k.color).frame(width: 64, height: 64)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        data = BuildGen.make()
        wrongKind = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ k: ShapeKind) {
        guard !cheer else { return }
        if k == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrongKind = k; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrongKind = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation {
                    data.options = ([data.answer] + BuildGen.distractors(for: data.answer)).shuffledMoving(data.answer, from: cur)
                }
            }
        }
    }
}

// MARK: - Counting Critters: "How many?" (K.CC cardinality)
//
// Reworked to match Shape Detective's clarity: one short prompt ("How many?"),
// a group of big vector critters, and three big number tiles. He counts the
// critters and taps the number. No reading, no abstract numeral comparison.
// Counts come from a no-repeat bag; a wrong tap reshuffles (correct moves).

struct CritterCountLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum CritterCountGen {
    static let palette: [Color] = [
        Color(red: 0.95, green: 0.45, blue: 0.45),
        Color(red: 0.35, green: 0.62, blue: 0.92),
        Color(red: 0.45, green: 0.78, blue: 0.45),
        Color(red: 0.95, green: 0.70, blue: 0.30),
        Color(red: 0.66, green: 0.46, blue: 0.86),
        Color(red: 0.30, green: 0.74, blue: 0.72)
    ]

    static var bag: [Int] = []
    static var lastN: Int?
    static func nextCount() -> Int {
        if bag.isEmpty {
            bag = Array(2...max(6, GameDifficulty.countMax)).shuffled()
            if let last = lastN, bag.count > 1, bag[0] == last { bag.swapAt(0, bag.count - 1) }
        }
        let n = bag.removeFirst(); lastN = n; return n
    }

    static func distractors(for n: Int) -> [Int] {
        var out: [Int] = []
        let near = [n - 1, n + 1, n - 2, n + 2].filter { $0 >= 1 && $0 <= max(9, GameDifficulty.countMax) && $0 != n }
        for c in near.shuffled() where out.count < 2 { if !out.contains(c) { out.append(c) } }
        var x = 1
        while out.count < 2 { if x != n && !out.contains(x) { out.append(x) }; x += 1 }
        return out
    }

    static func make() -> (count: Int, colors: [Color], options: [Int], fact: String) {
        let n = nextCount()
        let colors = (0..<n).map { _ in palette.randomElement()! }
        let options = ([n] + distractors(for: n)).shuffled()
        return (n, colors, options, "There are \(n)! 🎉")
    }
}

struct CritterCountPlayer: View {
    let level: CritterCountLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var count = 3
    @State private var colors: [Color] = []
    @State private var options: [Int] = []
    @State private var fact = ""
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text("How many?")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                crittersView
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                HStack(spacing: 14) {
                    ForEach(options, id: \.self) { n in
                        Button { tap(n) } label: { tile(n) }
                            .wiggle(wrong == n)
                    }
                }
            }
            if cheer { CheerOverlay(custom: fact).transition(.opacity).id("crittercheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private var crittersView: some View {
        let rows = stride(from: 0, to: colors.count, by: 3).map { Array(colors[$0..<min($0 + 3, colors.count)]) }
        return VStack(spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 14) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, c in
                        CountPal(color: c, size: 60)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == count ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = CritterCountGen.make()
        count = made.count; colors = made.colors; options = made.options; fact = made.fact
        wrong = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == count {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: count) ?? -1
                withAnimation { options = options.shuffledMoving(count, from: cur) }
            }
        }
    }
}

// MARK: - Gabriel's Family of 10: "How many in all?" (K.OA addition to 10)
//
// Reworked to Shape Detective clarity. Two groups of his pets (cats + dogs)
// appear; he taps the total from three big number tiles. One short prompt, big
// visuals, one tap. Sums stay small and readable; the pair never repeats
// back-to-back; a wrong tap reshuffles (correct moves).

struct FamilyAddLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

enum FamilyAddGen {
    static var lastKey: String?

    static func distractors(_ s: Int) -> [Int] {
        var out: [Int] = []
        let near = [s - 1, s + 1, s - 2, s + 2].filter { $0 >= 1 && $0 <= max(10, GameDifficulty.sumMax) && $0 != s }
        for c in near.shuffled() where out.count < 2 { if !out.contains(c) { out.append(c) } }
        var x = 1
        while out.count < 2 { if x != s && !out.contains(x) { out.append(x) }; x += 1 }
        return out
    }

    static func make() -> (a: Int, b: Int, emojiA: String, emojiB: String, options: [Int], fact: String) {
        var a = 1, b = 1
        repeat {
            a = Int.random(in: 1...GameDifficulty.addendMax); b = Int.random(in: 1...GameDifficulty.addendMax)
        } while (a + b < 2 || a + b > GameDifficulty.sumMax || "\(a)-\(b)" == lastKey)
        lastKey = "\(a)-\(b)"
        let sum = a + b
        // Cats and dogs, order varied so the left group isn't always the same.
        let (eA, eB) = Bool.random() ? ("🐱", "🐶") : ("🐶", "🐱")
        let options = ([sum] + distractors(sum)).shuffled()
        return (a, b, eA, eB, options, "\(a) and \(b) makes \(sum)! 🎉")
    }
}

struct FamilyAddPlayer: View {
    let level: FamilyAddLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var a = 1
    @State private var b = 1
    @State private var emojiA = "🐱"
    @State private var emojiB = "🐶"
    @State private var sum = 2
    @State private var options: [Int] = []
    @State private var fact = ""
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if level.rounds > 1 {
                    ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                }
                Text("How many in all?")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                HStack(alignment: .center, spacing: 12) {
                    cluster(emojiA, a)
                    Text("+").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    cluster(emojiB, b)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                HStack(spacing: 14) {
                    ForEach(options, id: \.self) { n in
                        Button { tap(n) } label: { tile(n) }
                            .wiggle(wrong == n)
                    }
                }
            }
            if cheer { CheerOverlay(custom: fact).transition(.opacity).id("familyaddcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func cluster(_ emoji: String, _ n: Int) -> some View {
        let rowSizes = stride(from: 0, to: n, by: 2).map { min(2, n - $0) }
        return VStack(spacing: 8) {
            ForEach(Array(rowSizes.enumerated()), id: \.offset) { _, size in
                HStack(spacing: 8) {
                    ForEach(0..<size, id: \.self) { _ in
                        EmojiView(emoji: emoji, size: 46, tint: .white)
                    }
                }
            }
        }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == sum ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        let made = FamilyAddGen.make()
        a = made.a; b = made.b; emojiA = made.emojiA; emojiB = made.emojiB
        sum = made.a + made.b; options = made.options; fact = made.fact
        wrong = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == sum {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = options.firstIndex(of: sum) ?? -1
                withAnimation { options = options.shuffledMoving(sum, from: cur) }
            }
        }
    }
}

// MARK: - Story Problems: visual add/subtract word problems within 20 (1.OA.1)
//
// A word problem he can SEE instead of read. Addition shows one group plus
// another group arriving ("How many now?"). Subtraction shows a group with
// some crossed out ("How many are left?"). One short question, the picture
// acts out the story, big number tiles. Numbers stay within 20; the situation
// and items vary; a wrong tap reshuffles (correct moves).

struct WordProblemLevel: Identifiable, Hashable {
    let id = UUID()
    let skill: String
    let rounds: Int
}

struct WordProblem {
    let isAdd: Bool
    let start: Int
    let change: Int
    let emoji: String
    let answer: Int
    let prompt: String
    let fact: String
    var options: [Int]
}

enum WordProblemGen {
    static let items = ["🐔", "🐤", "🐸", "🐟", "🍎", "🍪", "🐶", "🐱", "🌸", "🐞", "🦆", "🐢"]
    static var lastKey: String?

    static func distractors(_ a: Int) -> [Int] {
        var out: [Int] = []
        let near = [a - 1, a + 1, a - 2, a + 2].filter { $0 >= 0 && $0 <= 20 && $0 != a }
        for c in near.shuffled() where out.count < 2 { if !out.contains(c) { out.append(c) } }
        var x = 0
        while out.count < 2 { if x != a && !out.contains(x) { out.append(x) }; x += 1 }
        return out
    }

    static func make() -> WordProblem {
        let emoji = items.randomElement()!
        let isAdd = Bool.random()
        var start = 0, change = 0, answer = 0
        repeat {
            if isAdd {
                start = Int.random(in: 2...8)
                change = Int.random(in: 1...6)
                answer = start + change
            } else {
                start = Int.random(in: 4...12)
                change = Int.random(in: 1...(start - 2))
                answer = start - change
            }
        } while "\(isAdd)-\(start)-\(change)" == lastKey || (isAdd && answer > 14)
        lastKey = "\(isAdd)-\(start)-\(change)"
        let prompt = isAdd ? "How many in all?" : "How many are left?"
        let fact = isAdd ? "\(start) and \(change) makes \(answer)! 🎉"
                         : "\(start) take away \(change) is \(answer)! 🎉"
        let options = ([answer] + distractors(answer)).shuffled()
        return WordProblem(isAdd: isAdd, start: start, change: change, emoji: emoji,
                           answer: answer, prompt: prompt, fact: fact, options: options)
    }
}

struct WordProblemPlayer: View {
    let level: WordProblemLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = WordProblemGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Add them up, or take some away.",
                            subtitle: "Some come together (add). Some go away, crossed out (take away).") {
                    HStack(spacing: 26) {
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                EmojiView(emoji: "🐤", size: 26, tint: .white)
                                EmojiView(emoji: "🐤", size: 26, tint: .white)
                                Text("+").font(.system(size: 18, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                                EmojiView(emoji: "🐤", size: 26, tint: .white)
                            }
                            Text("add").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                        }
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                ZStack {
                                    EmojiView(emoji: "🍪", size: 26, tint: .white).opacity(0.35)
                                    Image(systemName: "xmark").font(.system(size: 16, weight: .heavy)).foregroundStyle(Theme.red)
                                }
                                EmojiView(emoji: "🍪", size: 26, tint: .white)
                                EmojiView(emoji: "🍪", size: 26, tint: .white)
                            }
                            Text("take away").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 16) {
                    if level.rounds > 1 {
                        ProgressDots(total: level.rounds, done: round, accent: Theme.red)
                    }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    picture
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }
                                .wiggle(wrong == n)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("wpcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    @ViewBuilder private var picture: some View {
        if data.isAdd {
            HStack(alignment: .center, spacing: 10) {
                grid(count: data.start, perRow: 3, crossed: 0, size: 36)
                Text("+").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                grid(count: data.change, perRow: 3, crossed: 0, size: 36)
            }
        } else {
            grid(count: data.start, perRow: 5, crossed: data.change, size: 38)
        }
    }

    private func grid(count: Int, perRow: Int, crossed: Int, size: CGFloat) -> some View {
        let rows = stride(from: 0, to: count, by: perRow).map { Array($0..<min($0 + perRow, count)) }
        return VStack(spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { idx in
                        ZStack {
                            EmojiView(emoji: data.emoji, size: size, tint: .white)
                                .opacity(idx < crossed ? 0.35 : 1)
                            if idx < crossed {
                                Image(systemName: "xmark")
                                    .font(.system(size: size * 0.66, weight: .heavy))
                                    .foregroundStyle(Theme.red)
                            }
                        }
                    }
                }
            }
        }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() {
        data = WordProblemGen.make()
        wrong = nil; cheer = false; missed = 0; revealed = false
    }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Push or Pull? (K-PS2-1: pushes and pulls make things move)
//
// A real thing he knows appears big; he taps PUSH or PULL. Objects come from a
// no-repeat bag and the two tiles swap sides each round, so the answer is never
// in the same spot. A fact pays off every correct tap.

struct PushPullLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct PushPullItem { let emoji: String; let isPush: Bool; let fact: String }

enum PushPullGen {
    static let items: [PushPullItem] = [
        PushPullItem(emoji: "🛒", isPush: true,  fact: "You push a shopping cart! 🛒"),
        PushPullItem(emoji: "🧹", isPush: true,  fact: "You push a broom to sweep! 🧹"),
        PushPullItem(emoji: "🛴", isPush: true,  fact: "You push a scooter with your foot! 🛴"),
        PushPullItem(emoji: "⚽", isPush: true,  fact: "You push a ball when you kick it! ⚽"),
        PushPullItem(emoji: "🛹", isPush: true,  fact: "You push a skateboard to go! 🛹"),
        PushPullItem(emoji: "🛷", isPush: false, fact: "You pull a sled up the hill! 🛷"),
        PushPullItem(emoji: "🪢", isPush: false, fact: "You pull the rope in tug-of-war! 🪢"),
        PushPullItem(emoji: "🧦", isPush: false, fact: "You pull your sock on! 🧦"),
        PushPullItem(emoji: "🪁", isPush: false, fact: "You pull the kite string! 🪁"),
        PushPullItem(emoji: "🎣", isPush: false, fact: "You pull the fish in! 🎣")
    ]
    static var bag: [Int] = []
    static var last: Int?
    static func next() -> PushPullItem {
        if bag.isEmpty {
            bag = Array(items.indices).shuffled()
            if let l = last, bag.count > 1, bag[0] == l { bag.swapAt(0, bag.count - 1) }
        }
        let i = bag.removeFirst(); last = i; return items[i]
    }
}

struct PushPullPlayer: View {
    let level: PushPullLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var item = PushPullGen.items[0]
    @State private var pushLeft = true
    @State private var wrong: String?
    @State private var cheer = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Push moves it away.\nPull brings it close.",
                            subtitle: "Look at each thing and pick how it moves.") {
                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("👋➡️").font(.system(size: 32))
                            Text("PUSH").font(.system(size: 19, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                            EmojiView(emoji: "🛒", size: 40, tint: .white)
                        }
                        VStack(spacing: 8) {
                            Text("⬅️✊").font(.system(size: 32))
                            Text("PULL").font(.system(size: 19, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                            EmojiView(emoji: "🛷", size: 40, tint: .white)
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 24) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Push or pull?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    EmojiView(emoji: item.emoji, size: 116, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 170)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(pushLeft ? ["push", "pull"] : ["pull", "push"], id: \.self) { kind in
                            Button { tap(kind) } label: { tile(kind) }.wiggle(wrong == kind)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: item.fact).transition(.opacity).id("ppcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ kind: String) -> some View {
        VStack(spacing: 8) {
            Text(kind == "push" ? "👋➡️" : "⬅️✊").font(.system(size: 30))
            Text(kind.uppercased()).font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
        .background(wrong == kind ? Theme.red.opacity(0.5) : Theme.surfaceHi)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() { item = PushPullGen.next(); pushLeft = Bool.random(); wrong = nil; cheer = false }

    private func tap(_ kind: String) {
        guard !cheer else { return }
        if kind == (item.isPush ? "push" : "pull") {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            wrong = kind; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrong = nil }
        }
    }
}

// MARK: - What They Need (K-LS1-1: living things need food, water, light)
//
// A plant or animal appears; he taps the thing it needs (sun, water, food) from
// three choices where the other two are just toys. Subjects don't repeat
// back-to-back; a wrong tap reshuffles the choices (correct moves).

struct NeedsLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct NeedsQ { let living: String; let need: String; let prompt: String; let fact: String; var options: [String] }

enum NeedsGen {
    struct Living { let emoji: String; let name: String; let needs: [(String, String)] }
    static let things: [Living] = [
        Living(emoji: "🌻", name: "sunflower", needs: [("☀️", "sunlight"), ("💧", "water")]),
        Living(emoji: "🌳", name: "tree",      needs: [("☀️", "sunlight"), ("💧", "water")]),
        Living(emoji: "🌷", name: "flower",    needs: [("💧", "water"), ("☀️", "sunlight")]),
        Living(emoji: "🐶", name: "dog",       needs: [("🍖", "food"), ("💧", "water")]),
        Living(emoji: "🐰", name: "rabbit",    needs: [("🥕", "food"), ("💧", "water")]),
        Living(emoji: "🐱", name: "cat",       needs: [("🐟", "food"), ("💧", "water")]),
        Living(emoji: "🐔", name: "chicken",   needs: [("🌽", "food"), ("💧", "water")])
    ]
    static let toys = ["🧸", "📺", "🚗", "🎈", "🪀", "🎁", "🎮", "📱"]
    static var lastName: String?

    static func make() -> NeedsQ {
        var l = things.randomElement()!
        if let last = lastName, things.count > 1 { while l.name == last { l = things.randomElement()! } }
        lastName = l.name
        let need = l.needs.randomElement()!
        let options = ([need.0] + Array(toys.shuffled().prefix(2))).shuffled()
        return NeedsQ(living: l.emoji, need: need.0,
                      prompt: "What does the \(l.name) need?",
                      fact: "A \(l.name) needs \(need.1)! \(need.0)", options: options)
    }
}

struct NeedsPlayer: View {
    let level: NeedsLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = NeedsGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Living things need\nfood, water, and sunlight.",
                            subtitle: "Pick the thing each plant or animal needs to live.") {
                    HStack(spacing: 22) {
                        EmojiView(emoji: "☀️", size: 50, tint: .white)
                        EmojiView(emoji: "💧", size: 50, tint: .white)
                        EmojiView(emoji: "🍖", size: 50, tint: .white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.living, size: 96, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 140)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { opt in
                            Button { tap(opt) } label: { tile(opt) }.wiggle(wrong == opt)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("needcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ opt: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && opt == data.need ? Theme.green : wrong == opt ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: opt, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = NeedsGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ opt: String) {
        guard !cheer else { return }
        if opt == data.need {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = opt; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.need) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.need, from: cur) }
            }
        }
    }
}

// MARK: - Position Words (K.G.1: on top, under, next to)
//
// A little scene in each tile: a box and an animal placed on top of, under, or
// next to it. He taps the one that matches the question. All three positions
// always appear (so it's unambiguous); a wrong tap reshuffles them.

enum PosWord: String, CaseIterable { case onTop = "on top", under = "under", nextTo = "next to" }

struct PosLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct PosQ { let subject: String; let ref: String; let target: PosWord; let prompt: String; let fact: String; var options: [PosWord] }

enum PositionGen {
    static let subjects = ["🐱", "🐶", "🐦", "🐸", "🐰", "🐥"]
    static let refs = ["📦", "🪑"]
    static var last: String?
    static func make() -> PosQ {
        let s = subjects.randomElement()!
        let r = refs.randomElement()!
        var t = PosWord.allCases.randomElement()!
        if let l = last { while t.rawValue == l { t = PosWord.allCases.randomElement()! } }
        last = t.rawValue
        return PosQ(subject: s, ref: r, target: t,
                    prompt: "Which one is \(t.rawValue)?",
                    fact: "Yes! It is \(t.rawValue)! 🎉",
                    options: PosWord.allCases.shuffled())
    }
}

struct PositionPlayer: View {
    let level: PosLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = PositionGen.make()
    @State private var wrong: PosWord?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "On top, under, or next to?",
                            subtitle: "Find the picture that matches the words.") {
                    HStack(spacing: 16) {
                        ForEach(PosWord.allCases, id: \.self) { p in
                            VStack(spacing: 8) {
                                ZStack {
                                    EmojiView(emoji: "📦", size: 40, tint: .white)
                                    EmojiView(emoji: "🐱", size: 30, tint: .white)
                                        .offset(x: p == .nextTo ? 26 : 0,
                                                y: p == .onTop ? -24 : (p == .under ? 24 : 0))
                                }
                                .frame(width: 72, height: 72)
                                Text(p.rawValue)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                            }
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 22) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 12) {
                        ForEach(data.options, id: \.self) { pos in
                            Button { tap(pos) } label: { tile(pos) }.wiggle(wrong == pos)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("poscheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ pos: PosWord) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && pos == data.target ? Theme.green : wrong == pos ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            ZStack {
                EmojiView(emoji: data.ref, size: 44, tint: .white)
                EmojiView(emoji: data.subject, size: 32, tint: .white)
                    .offset(x: pos == .nextTo ? 30 : 0,
                            y: pos == .onTop ? -28 : (pos == .under ? 28 : 0))
            }
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = PositionGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ pos: PosWord) {
        guard !cheer else { return }
        if pos == data.target {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = pos; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.target) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.target, from: cur) }
            }
        }
    }
}

// MARK: - Star Words (RF.K.3c: high-frequency sight words)
//
// The target word shows big; he taps the matching word among look-alikes
// (the/then/they, see/sea/set). Builds whole-word recognition. No-repeat bag,
// reshuffle on wrong.

struct SightLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct SightQ { let word: String; var options: [String]; let fact: String }

enum SightGen {
    static let words = ["the", "and", "I", "see", "my", "like", "go", "to", "is", "a",
                        "we", "look", "can", "come", "you", "me", "he", "up", "it", "in"]
    static let confuse: [String: [String]] = [
        "the": ["then", "they"], "see": ["sea", "set"], "we": ["me", "be"], "my": ["may", "by"],
        "go": ["got", "do"], "look": ["book", "cook"], "can": ["man", "cap"], "come": ["came", "some"],
        "he": ["she", "be"], "and": ["any", "end"], "like": ["lake", "line"], "you": ["your", "yum"],
        "to": ["too", "top"], "is": ["it", "in"], "up": ["us", "pup"], "me": ["my", "we"]
    ]
    static var bag: [Int] = []
    static var last: Int?
    static func next() -> String {
        if bag.isEmpty {
            bag = Array(words.indices).shuffled()
            if let l = last, bag.count > 1, bag[0] == l { bag.swapAt(0, bag.count - 1) }
        }
        let i = bag.removeFirst(); last = i; return words[i]
    }
    static func make() -> SightQ {
        let w = next()
        var distract = Array((confuse[w] ?? []).shuffled().prefix(2))
        if distract.count < 2 {
            let others = words.filter { $0 != w && !distract.contains($0) }.shuffled()
            distract += Array(others.prefix(2 - distract.count))
        }
        return SightQ(word: w, options: ([w] + distract).shuffled(), fact: "You found \"\(w)\"! ⭐")
    }
}

struct SightWordsPlayer: View {
    let level: SightLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = SightGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                Text("Find this word:")
                    .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                Text(data.word)
                    .font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 120)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                VStack(spacing: 12) {
                    ForEach(data.options, id: \.self) { w in
                        Button { tap(w) } label: { tile(w) }.wiggle(wrong == w)
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("sightcheer\(round)") }
        }
        .onAppear(perform: newRound)
    }

    private func tile(_ w: String) -> some View {
        Text(w)
            .font(.system(size: 58, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 160)
            .background(revealed && w == data.word ? Theme.green : wrong == w ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func newRound() { data = SightGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ w: String) {
        guard !cheer else { return }
        if w == data.word {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = w; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.word) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.word, from: cur) }
            }
        }
    }
}

// MARK: - Number Order (K.CC.4-6: count order and compare numbers)
//
// Mixes "what comes after N?", "which is more?", and "which is less?" on big
// number tiles. The question type never repeats back-to-back; a wrong tap
// reshuffles.

struct NumOrderLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct NumOrderQ { let prompt: String; let answer: Int; let fact: String; var options: [Int] }

enum NumOrderGen {
    enum Kind: CaseIterable { case next, more, less }
    static var lastKind: Kind?

    static func nearDistractors(_ a: Int, count: Int) -> [Int] {
        var out: [Int] = []
        let near = [a - 1, a + 1, a - 2, a + 2, a + 3].filter { $0 >= 0 && $0 <= 20 && $0 != a }
        for c in near.shuffled() where out.count < count { if !out.contains(c) { out.append(c) } }
        var x = 0
        while out.count < count { if x != a && !out.contains(x) { out.append(x) }; x += 1 }
        return out
    }

    static func make() -> NumOrderQ {
        var k = Kind.allCases.randomElement()!
        if let l = lastKind { while k == l { k = Kind.allCases.randomElement()! } }
        lastKind = k
        switch k {
        case .next:
            let a = Int.random(in: 0...9)
            let ans = a + 1
            return NumOrderQ(prompt: "What comes after \(a)?", answer: ans,
                             fact: "After \(a) comes \(ans)! 🎉",
                             options: ([ans] + nearDistractors(ans, count: 2)).shuffled())
        case .more:
            let x = Int.random(in: 1...10); var y = Int.random(in: 1...10)
            while x == y { y = Int.random(in: 1...10) }
            return NumOrderQ(prompt: "Which is more?", answer: max(x, y),
                             fact: "\(max(x, y)) is more than \(min(x, y))! 🎉",
                             options: [x, y].shuffled())
        case .less:
            let x = Int.random(in: 1...10); var y = Int.random(in: 1...10)
            while x == y { y = Int.random(in: 1...10) }
            return NumOrderQ(prompt: "Which is less?", answer: min(x, y),
                             fact: "\(min(x, y)) is less than \(max(x, y))! 🎉",
                             options: [x, y].shuffled())
        }
    }
}

struct NumberOrderPlayer: View {
    let level: NumOrderLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = NumOrderGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "More is bigger.\nLess is smaller.",
                            subtitle: "When we count up, the later number is more.") {
                    HStack(spacing: 28) {
                        VStack(spacing: 6) {
                            Text("7").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
                            Text("more").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                        }
                        VStack(spacing: 6) {
                            Text("3").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
                            Text("less").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 24) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("numcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = NumOrderGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Reusable teaching screen
//
// Every game shows this once before the questions: it states the idea simply,
// shows a picture of it, then a big "Let's play!" button. Teaching first, then
// practice - not just quizzing.

enum LessonPhase { case teach, play }

struct TeachScreen<Visual: View>: View {
    let title: String
    let subtitle: String
    let visual: Visual
    let onStart: () -> Void

    init(title: String, subtitle: String = "", @ViewBuilder visual: () -> Visual, onStart: @escaping () -> Void) {
        self.title = title; self.subtitle = subtitle; self.visual = visual(); self.onStart = onStart
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            visual
                .frame(maxWidth: .infinity).padding(.vertical, 44)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 28))
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button { onStart() } label: {
                Text("Let's play! 🎮")
                    .font(.system(size: 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 74)
                    .background(Theme.green).clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24).padding(.vertical, 20)
    }
}


// MARK: - Animal Homes (K-ESS3-1: animals and where they live)
//
// "Which one lives on a farm / in the ocean / where it's cold / in the jungle?"
// He sorts animals by habitat. Teaches first, then asks. No-repeat habitat,
// reshuffle on wrong, a fact each time.

struct AnimalHome: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let habitat: String
}

struct AnimalHomeLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct HomeQ { let correct: AnimalHome; let prompt: String; let fact: String; var options: [AnimalHome] }

enum AnimalHomesGen {
    static let animals: [AnimalHome] = [
        AnimalHome(id: "cow",      emoji: "🐮", name: "cow",      habitat: "farm"),
        AnimalHome(id: "pig",      emoji: "🐷", name: "pig",      habitat: "farm"),
        AnimalHome(id: "hen",      emoji: "🐔", name: "hen",      habitat: "farm"),
        AnimalHome(id: "sheep",    emoji: "🐑", name: "sheep",    habitat: "farm"),
        AnimalHome(id: "horse",    emoji: "🐴", name: "horse",    habitat: "farm"),
        AnimalHome(id: "fish",     emoji: "🐠", name: "fish",     habitat: "ocean"),
        AnimalHome(id: "octopus",  emoji: "🐙", name: "octopus",  habitat: "ocean"),
        AnimalHome(id: "whale",    emoji: "🐳", name: "whale",    habitat: "ocean"),
        AnimalHome(id: "crab",     emoji: "🦀", name: "crab",     habitat: "ocean"),
        AnimalHome(id: "dolphin",  emoji: "🐬", name: "dolphin",  habitat: "ocean"),
        AnimalHome(id: "penguin",  emoji: "🐧", name: "penguin",  habitat: "cold"),
        AnimalHome(id: "polarbear",emoji: "🐻‍❄️", name: "polar bear", habitat: "cold"),
        AnimalHome(id: "seal",     emoji: "🦭", name: "seal",     habitat: "cold"),
        AnimalHome(id: "tiger",    emoji: "🐯", name: "tiger",    habitat: "jungle"),
        AnimalHome(id: "monkey",   emoji: "🐵", name: "monkey",   habitat: "jungle"),
        AnimalHome(id: "elephant", emoji: "🐘", name: "elephant", habitat: "jungle"),
        AnimalHome(id: "lion",     emoji: "🦁", name: "lion",     habitat: "jungle"),
        AnimalHome(id: "parrot",   emoji: "🦜", name: "parrot",   habitat: "jungle")
    ]
    static let habitats = ["farm", "ocean", "cold", "jungle"]
    static func prompt(_ h: String) -> String {
        switch h {
        case "farm":   return "Which one lives on a farm? 🚜"
        case "ocean":  return "Which one lives in the ocean? 🌊"
        case "cold":   return "Which one lives where it's cold? ❄️"
        default:       return "Which one lives in the jungle? 🌴"
        }
    }
    static func phrase(_ h: String) -> String {
        switch h {
        case "farm":   return "on a farm! 🚜"
        case "ocean":  return "in the ocean! 🌊"
        case "cold":   return "where it's cold! ❄️"
        default:       return "in the jungle! 🌴"
        }
    }
    static var lastH: String?
    static func make() -> HomeQ {
        var h = habitats.randomElement()!
        if let l = lastH { while h == l { h = habitats.randomElement()! } }
        lastH = h
        let correct = animals.filter { $0.habitat == h }.randomElement()!
        let distract = Array(animals.filter { $0.habitat != h }.shuffled().prefix(2))
        return HomeQ(correct: correct, prompt: prompt(h),
                     fact: "A \(correct.name) lives \(phrase(h))",
                     options: ([correct] + distract).shuffled())
    }
}

struct AnimalHomesPlayer: View {
    let level: AnimalHomeLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = AnimalHomesGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Animals live in different places.",
                            subtitle: "Pick the animal that lives in each place.") {
                    HStack(spacing: 18) {
                        homePair("🚜", "Farm", "🐮", "Cow")
                        homePair("🌊", "Ocean", "🐠", "Fish")
                        homePair("❄️", "Cold", "🐧", "Penguin")
                        homePair("🌴", "Jungle", "🐯", "Tiger")
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 20) {
                        ForEach(data.options) { a in
                            Button { tap(a) } label: { tile(a) }.wiggle(wrong == a.id)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("homecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func homePair(_ place: String, _ placeWord: String,
                          _ animal: String, _ animalWord: String) -> some View {
        VStack(spacing: 8) {
            EmojiView(emoji: place, size: 60, tint: .white)
            Text(placeWord).font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Image(systemName: "arrow.down").font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.green)
            EmojiView(emoji: animal, size: 60, tint: .white)
            Text(animalWord).font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private func tile(_ a: AnimalHome) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && a.id == data.correct.id ? Theme.green : wrong == a.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: a.emoji, size: 88, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 170)
    }

    private func newRound() { data = AnimalHomesGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ a: AnimalHome) {
        guard !cheer else { return }
        if a.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = a.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}

// MARK: - How Many Legs? (K.CC.4: count to tell how many)
//
// A big animal appears; he counts its legs and taps the number. Birds 2, dogs
// 4, bugs 6, spiders 8, fish 0. Teaches first; no-repeat animal; reshuffle.

struct LegAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let legs: Int }

struct LegsLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct LegsQ { let animal: LegAnimal; var options: [Int]; let fact: String }

enum LegsGen {
    static let animals: [LegAnimal] = [
        LegAnimal(id: "hen",    emoji: "🐔", name: "hen",    legs: 2),
        LegAnimal(id: "bird",   emoji: "🐦", name: "bird",   legs: 2),
        LegAnimal(id: "duck",   emoji: "🦆", name: "duck",   legs: 2),
        LegAnimal(id: "penguin",emoji: "🐧", name: "penguin",legs: 2),
        LegAnimal(id: "dog",    emoji: "🐶", name: "dog",    legs: 4),
        LegAnimal(id: "cat",    emoji: "🐱", name: "cat",    legs: 4),
        LegAnimal(id: "cow",    emoji: "🐮", name: "cow",    legs: 4),
        LegAnimal(id: "horse",  emoji: "🐴", name: "horse",  legs: 4),
        LegAnimal(id: "pig",    emoji: "🐷", name: "pig",    legs: 4),
        LegAnimal(id: "bee",    emoji: "🐝", name: "bee",    legs: 6),
        LegAnimal(id: "ant",    emoji: "🐜", name: "ant",    legs: 6),
        LegAnimal(id: "ladybug",emoji: "🐞", name: "ladybug",legs: 6),
        LegAnimal(id: "spider", emoji: "🕷️", name: "spider", legs: 8),
        LegAnimal(id: "octopus",emoji: "🐙", name: "octopus",legs: 8),
        LegAnimal(id: "fish",   emoji: "🐠", name: "fish",   legs: 0),
        LegAnimal(id: "snake",  emoji: "🐍", name: "snake",  legs: 0)
    ]
    static func distractors(_ n: Int) -> [Int] {
        Array([0, 2, 4, 6, 8].filter { $0 != n }.shuffled().prefix(2))
    }
    static var lastId: String?
    static func make() -> LegsQ {
        var a = animals.randomElement()!
        if let l = lastId, animals.count > 1 { while a.id == l { a = animals.randomElement()! } }
        lastId = a.id
        let legWord = a.legs == 1 ? "leg" : "legs"
        return LegsQ(animal: a, options: ([a.legs] + distractors(a.legs)).shuffled(),
                     fact: "A \(a.name) has \(a.legs) \(legWord)!")
    }
}

struct LegsPlayer: View {
    let level: LegsLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = LegsGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Count the legs!",
                            subtitle: "Some animals have 2 legs, some 4, some more.") {
                    HStack(spacing: 26) {
                        VStack(spacing: 6) { EmojiView(emoji: "🐔", size: 56, tint: .white); Text("2 legs").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 6) { EmojiView(emoji: "🐶", size: 56, tint: .white); Text("4 legs").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 22) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("How many legs?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    EmojiView(emoji: data.animal.emoji, size: 130, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 190)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("legscheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == data.animal.legs ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
    }

    private func newRound() { data = LegsGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.animal.legs {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.animal.legs) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.animal.legs, from: cur) }
            }
        }
    }
}


// MARK: - Animal Coverings (NGSS 1-LS1-1: animal body parts)
//
// "Which one has feathers / fur / scales?" He sorts animals by their body
// covering. Teaches first; no-repeat covering; reshuffle on wrong; a fact each
// time.

struct CoverAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let cover: String }

struct CoverLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct CoverQ { let correct: CoverAnimal; let prompt: String; let fact: String; var options: [CoverAnimal] }

enum CoverGen {
    static let animals: [CoverAnimal] = [
        CoverAnimal(id: "hen",    emoji: "🐔", name: "hen",    cover: "feathers"),
        CoverAnimal(id: "bird",   emoji: "🐦", name: "bird",   cover: "feathers"),
        CoverAnimal(id: "duck",   emoji: "🦆", name: "duck",   cover: "feathers"),
        CoverAnimal(id: "owl",    emoji: "🦉", name: "owl",    cover: "feathers"),
        CoverAnimal(id: "parrot", emoji: "🦜", name: "parrot", cover: "feathers"),
        CoverAnimal(id: "dog",    emoji: "🐶", name: "dog",    cover: "fur"),
        CoverAnimal(id: "cat",    emoji: "🐱", name: "cat",    cover: "fur"),
        CoverAnimal(id: "rabbit", emoji: "🐰", name: "rabbit", cover: "fur"),
        CoverAnimal(id: "bear",   emoji: "🐻", name: "bear",   cover: "fur"),
        CoverAnimal(id: "fox",    emoji: "🦊", name: "fox",    cover: "fur"),
        CoverAnimal(id: "horse",  emoji: "🐴", name: "horse",  cover: "fur"),
        CoverAnimal(id: "fish",   emoji: "🐟", name: "fish",   cover: "scales"),
        CoverAnimal(id: "snake",  emoji: "🐍", name: "snake",  cover: "scales"),
        CoverAnimal(id: "lizard", emoji: "🦎", name: "lizard", cover: "scales"),
        CoverAnimal(id: "croc",   emoji: "🐊", name: "crocodile", cover: "scales")
    ]
    static let covers = ["feathers", "fur", "scales"]
    static func prompt(_ c: String) -> String {
        switch c {
        case "feathers": return "Which one has feathers? 🪶"
        case "fur":      return "Which one has fur?"
        default:         return "Which one has scales? 🐟"
        }
    }
    static var lastC: String?
    static func make() -> CoverQ {
        var c = covers.randomElement()!
        if let l = lastC { while c == l { c = covers.randomElement()! } }
        lastC = c
        let correct = animals.filter { $0.cover == c }.randomElement()!
        let distract = Array(animals.filter { $0.cover != c }.shuffled().prefix(2))
        return CoverQ(correct: correct, prompt: prompt(c),
                      fact: "A \(correct.name) has \(c)!",
                      options: ([correct] + distract).shuffled())
    }
}

struct CoveringsPlayer: View {
    let level: CoverLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = CoverGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Animals have fur, feathers,\nor scales.",
                            subtitle: "Pick the animal with each kind of covering.") {
                    HStack(spacing: 18) {
                        coverPair("🐶", "fur"); coverPair("🐔", "feathers"); coverPair("🐟", "scales")
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options) { a in
                            Button { tap(a) } label: { tile(a) }.wiggle(wrong == a.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("covcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func coverPair(_ animal: String, _ label: String) -> some View {
        VStack(spacing: 6) {
            EmojiView(emoji: animal, size: 48, tint: .white)
            Text(label).font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
        }
    }

    private func tile(_ a: CoverAnimal) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && a.id == data.correct.id ? Theme.green : wrong == a.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: a.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = CoverGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ a: CoverAnimal) {
        guard !cheer else { return }
        if a.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = a.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}

// MARK: - What Do Animals Eat? (NGSS K-LS1: animals need food)
//
// An animal appears; he taps the food it eats from three choices. Teaches
// first; no-repeat animal; reshuffle on wrong; a fact each time.

struct EatAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let food: String; let foodName: String }

struct EatLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct EatQ { let animal: EatAnimal; let prompt: String; let fact: String; var options: [String] }

enum EatGen {
    static let animals: [EatAnimal] = [
        EatAnimal(id: "rabbit", emoji: "🐰", name: "rabbit", food: "🥕", foodName: "carrots"),
        EatAnimal(id: "dog",    emoji: "🐶", name: "dog",    food: "🦴", foodName: "a bone"),
        EatAnimal(id: "cat",    emoji: "🐱", name: "cat",    food: "🐟", foodName: "fish"),
        EatAnimal(id: "cow",    emoji: "🐮", name: "cow",    food: "🌿", foodName: "grass"),
        EatAnimal(id: "monkey", emoji: "🐵", name: "monkey", food: "🍌", foodName: "bananas"),
        EatAnimal(id: "hen",    emoji: "🐔", name: "hen",    food: "🌽", foodName: "corn"),
        EatAnimal(id: "bear",   emoji: "🐻", name: "bear",   food: "🍯", foodName: "honey"),
        EatAnimal(id: "panda",  emoji: "🐼", name: "panda",  food: "🎋", foodName: "bamboo"),
        EatAnimal(id: "mouse",  emoji: "🐭", name: "mouse",  food: "🧀", foodName: "cheese")
    ]
    static let nonFood = ["🧸", "🚗", "👟", "⚽", "📱", "🎈", "🪀"]
    static var lastId: String?
    static func make() -> EatQ {
        var a = animals.randomElement()!
        if let l = lastId, animals.count > 1 { while a.id == l { a = animals.randomElement()! } }
        lastId = a.id
        // One wrong food from another animal, one non-food, so the answer is clear.
        let otherFood = animals.filter { $0.id != a.id && $0.food != a.food }.randomElement()!.food
        let toy = nonFood.randomElement()!
        return EatQ(animal: a, prompt: "What does the \(a.name) eat?",
                    fact: "A \(a.name) eats \(a.foodName)! \(a.food)",
                    options: [a.food, otherFood, toy].shuffled())
    }
}

struct EatPlayer: View {
    let level: EatLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = EatGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Animals eat different foods.",
                            subtitle: "Pick the food each animal eats.") {
                    HStack(spacing: 22) {
                        eatPair("🐰", "🥕"); eatPair("🐶", "🦴"); eatPair("🐵", "🍌")
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.animal.emoji, size: 96, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 140)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { f in
                            Button { tap(f) } label: { tile(f) }.wiggle(wrong == f)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("eatcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func eatPair(_ animal: String, _ food: String) -> some View {
        HStack(spacing: 4) {
            EmojiView(emoji: animal, size: 40, tint: .white)
            Text("→").font(.system(size: 18, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
            EmojiView(emoji: food, size: 36, tint: .white)
        }
    }

    private func tile(_ f: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && f == data.animal.food ? Theme.green : wrong == f ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: f, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = EatGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ f: String) {
        guard !cheer else { return }
        if f == data.animal.food {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = f; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.animal.food) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.animal.food, from: cur) }
            }
        }
    }
}


// MARK: - Teen Numbers (K.NBT.1: 11-19 is ten and some more)
//
// Ten animals in a group, plus a few more, and he taps the teen number. Teaches
// "ten and some more" first. No-repeat count; reshuffle on wrong.

struct TeenLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct TeenQ { let emoji: String; let extra: Int; let answer: Int; var options: [Int]; let fact: String }

enum TeenGen {
    static let critters = ["🐥", "🐰", "🐱", "🐶", "🐸", "🐠", "🐝", "🐞"]
    static var lastExtra: Int?
    static func make() -> TeenQ {
        var extra = Int.random(in: 1...9)
        if let l = lastExtra { while extra == l { extra = Int.random(in: 1...9) } }
        lastExtra = extra
        let answer = 10 + extra
        var opts: Set<Int> = [answer]
        while opts.count < 3 {
            let d = answer + [-2, -1, 1, 2].randomElement()!
            if d >= 10 && d <= 19 { opts.insert(d) }
        }
        return TeenQ(emoji: critters.randomElement()!, extra: extra, answer: answer,
                     options: Array(opts).shuffled(),
                     fact: "Ten and \(extra) makes \(answer)! 🔢")
    }
}

struct TeenPlayer: View {
    let level: TeenLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = TeenGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Teen numbers are\nten and some more.",
                            subtitle: "Count the ten, then count the extra ones.") {
                    HStack(spacing: 14) {
                        VStack(spacing: 4) {
                            grid("🐥", 10, per: 5, size: 18)
                            Text("ten").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                        }
                        Text("+ 3 = 13").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 16) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("How many in all?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    HStack(alignment: .center, spacing: 10) {
                        grid(data.emoji, 10, per: 5, size: 22)
                        Text("+").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        grid(data.emoji, data.extra, per: 3, size: 22)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 20))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("teencheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func grid(_ emoji: String, _ count: Int, per: Int, size: CGFloat) -> some View {
        let rows = stride(from: 0, to: count, by: per).map { Array($0..<min($0 + per, count)) }
        return VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) { ForEach(row, id: \.self) { _ in EmojiView(emoji: emoji, size: size, tint: .white) } }
            }
        }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = TeenGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Baby Animals (NGSS 1-LS3-1: young animals look like their parents)
//
// A parent animal appears; he taps its baby (the same animal, smaller) from
// three little ones. Teaches that babies resemble their parents. No-repeat
// parent; reshuffle on wrong.

struct BabyLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct BabyQ { let parent: String; let name: String; var options: [String]; let fact: String }

enum BabyGen {
    static let species: [(emoji: String, name: String)] = [
        ("🐔", "hen"), ("🐶", "dog"), ("🐱", "cat"), ("🐮", "cow"), ("🐷", "pig"),
        ("🐑", "sheep"), ("🐰", "rabbit"), ("🐴", "horse"), ("🐸", "frog"), ("🐧", "penguin")
    ]
    static var lastName: String?
    static func make() -> BabyQ {
        var p = species.randomElement()!
        if let l = lastName { while p.name == l { p = species.randomElement()! } }
        lastName = p.name
        let others = species.filter { $0.emoji != p.emoji }.shuffled().prefix(2).map { $0.emoji }
        return BabyQ(parent: p.emoji, name: p.name,
                     options: ([p.emoji] + others).shuffled(),
                     fact: "A baby \(p.name) looks just like its parent! 💛")
    }
}

struct BabyPlayer: View {
    let level: BabyLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = BabyGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var phase: LessonPhase = .teach
    @State private var missed = 0
    @State private var revealed = false

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Baby animals look like\ntheir parents.",
                            subtitle: "Find the baby that matches each parent.") {
                    HStack(spacing: 16) {
                        EmojiView(emoji: "🐶", size: 64, tint: .white)
                        Text("→").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "🐶", size: 38, tint: .white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 16) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Which baby is the \(data.name)'s?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.parent, size: 92, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 130)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("babycheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && e == data.parent ? Theme.green
                      : (wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi))
            EmojiView(emoji: e, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = BabyGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.parent {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1
            wrong = e; SFX.wrong()
            if missed >= 2 { withAnimation { revealed = true } }   // teach: show and hold the answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if revealed { return }        // stop reshuffling — the answer stays put and green
                let cur = data.options.firstIndex(of: data.parent) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.parent, from: cur) }
            }
        }
    }
}


// MARK: - Living or Not Living (NGSS K: characteristics of living things)
//
// "Which one is alive?" / "Which one is NOT alive?" He tells living things
// (animals, plants) from objects (toys, rocks). Teaches first; reshuffle on
// wrong; a fact each time.

struct LiveThing: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let alive: Bool }

struct LiveLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct LiveQ { let correct: LiveThing; let prompt: String; let fact: String; var options: [LiveThing] }

enum LiveGen {
    static let things: [LiveThing] = [
        LiveThing(id: "dog",    emoji: "🐶", name: "dog",       alive: true),
        LiveThing(id: "cat",    emoji: "🐱", name: "cat",       alive: true),
        LiveThing(id: "rabbit", emoji: "🐰", name: "rabbit",    alive: true),
        LiveThing(id: "bird",   emoji: "🐦", name: "bird",      alive: true),
        LiveThing(id: "fish",   emoji: "🐠", name: "fish",      alive: true),
        LiveThing(id: "bee",    emoji: "🐝", name: "bee",       alive: true),
        LiveThing(id: "flower", emoji: "🌻", name: "flower",    alive: true),
        LiveThing(id: "tree",   emoji: "🌳", name: "tree",      alive: true),
        LiveThing(id: "teddy",  emoji: "🧸", name: "teddy bear", alive: false),
        LiveThing(id: "car",    emoji: "🚗", name: "toy car",   alive: false),
        LiveThing(id: "ball",   emoji: "⚽", name: "ball",      alive: false),
        LiveThing(id: "rock",   emoji: "🪨", name: "rock",      alive: false),
        LiveThing(id: "shoe",   emoji: "👟", name: "shoe",      alive: false),
        LiveThing(id: "balloon",emoji: "🎈", name: "balloon",   alive: false)
    ]
    static var lastAlive: Bool?
    static func make() -> LiveQ {
        var askAlive = Bool.random()
        if let l = lastAlive { askAlive = !l }   // alternate alive / not-alive
        lastAlive = askAlive
        let correct = things.filter { $0.alive == askAlive }.randomElement()!
        let distract = Array(things.filter { $0.alive != askAlive }.shuffled().prefix(2))
        let prompt = askAlive ? "Which one is alive? 🌱" : "Which one is NOT alive?"
        let fact = askAlive ? "A \(correct.name) is alive! It grows and eats. 🌱"
                            : "A \(correct.name) is not alive. It can't grow. 🚫"
        return LiveQ(correct: correct, prompt: prompt, fact: fact, options: ([correct] + distract).shuffled())
    }
}

struct LivingNotPlayer: View {
    let level: LiveLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = LiveGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Living things grow, eat,\nand move.",
                            subtitle: "Animals and plants are alive. Toys and rocks are not.") {
                    HStack(spacing: 24) {
                        VStack(spacing: 6) { EmojiView(emoji: "🐶", size: 54, tint: .white); Text("alive").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 6) { EmojiView(emoji: "🧸", size: 54, tint: .white); Text("not alive").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options) { t in
                            Button { tap(t) } label: { tile(t) }.wiggle(wrong == t.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("livecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ t: LiveThing) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && t.id == data.correct.id ? Theme.green : wrong == t.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: t.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = LiveGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ t: LiveThing) {
        guard !cheer else { return }
        if t.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = t.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}

// MARK: - Day or Night Animals (animal behavior / day-night patterns)
//
// "Which one is awake at night?" / "Which one is awake in the day?" Owls and
// bats are awake at night; bees and roosters in the day. Teaches first;
// reshuffle on wrong; a fact each time.

struct DNAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let night: Bool }

struct DNLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct DNQ { let correct: DNAnimal; let prompt: String; let fact: String; var options: [DNAnimal] }

enum DayNightGen {
    static let animals: [DNAnimal] = [
        DNAnimal(id: "owl",      emoji: "🦉", name: "owl",      night: true),
        DNAnimal(id: "bat",      emoji: "🦇", name: "bat",      night: true),
        DNAnimal(id: "raccoon",  emoji: "🦝", name: "raccoon",  night: true),
        DNAnimal(id: "wolf",     emoji: "🐺", name: "wolf",     night: true),
        DNAnimal(id: "hedgehog", emoji: "🦔", name: "hedgehog", night: true),
        DNAnimal(id: "bee",      emoji: "🐝", name: "bee",      night: false),
        DNAnimal(id: "butterfly",emoji: "🦋", name: "butterfly",night: false),
        DNAnimal(id: "rooster",  emoji: "🐓", name: "rooster",  night: false),
        DNAnimal(id: "squirrel", emoji: "🐿️", name: "squirrel", night: false),
        DNAnimal(id: "dog",      emoji: "🐶", name: "dog",      night: false),
        DNAnimal(id: "bird",     emoji: "🐦", name: "bird",     night: false)
    ]
    static var lastNight: Bool?
    static func make() -> DNQ {
        var askNight = Bool.random()
        if let l = lastNight { askNight = !l }
        lastNight = askNight
        let correct = animals.filter { $0.night == askNight }.randomElement()!
        let distract = Array(animals.filter { $0.night != askNight }.shuffled().prefix(2))
        let prompt = askNight ? "Which one is awake at night? 🌙" : "Which one is awake in the day? ☀️"
        let fact = askNight ? "An \(correct.name) is awake at night! 🌙"
                            : "A \(correct.name) is awake in the day! ☀️"
        return DNQ(correct: correct, prompt: prompt, fact: fact, options: ([correct] + distract).shuffled())
    }
}

struct DayNightPlayer: View {
    let level: DNLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = DayNightGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Some animals are awake\nat night, some in the day.",
                            subtitle: "Owls and bats come out at night. Bees buzz in the day.") {
                    HStack(spacing: 24) {
                        VStack(spacing: 6) { EmojiView(emoji: "🦉", size: 54, tint: .white); Text("night 🌙").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 6) { EmojiView(emoji: "🐝", size: 54, tint: .white); Text("day ☀️").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options) { a in
                            Button { tap(a) } label: { tile(a) }.wiggle(wrong == a.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("dncheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ a: DNAnimal) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && a.id == data.correct.id ? Theme.green : wrong == a.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: a.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = DayNightGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ a: DNAnimal) {
        guard !cheer else { return }
        if a.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = a.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}


// MARK: - Make 5 (K.OA.4: make a ten/five with a missing part)
//
// Some animals are here; he taps how many MORE make 5. Short teach, then play.

struct Make5Level: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct Make5Q { let emoji: String; let have: Int; let answer: Int; var options: [Int]; let fact: String }

enum Make5Gen {
    static let critters = ["🐥", "🐰", "🐶", "🐱", "🐸", "🦆"]
    static var lastHave: Int?
    static func make() -> Make5Q {
        var have = Int.random(in: 1...4)
        if let l = lastHave { while have == l { have = Int.random(in: 1...4) } }
        lastHave = have
        let answer = 5 - have
        var opts: Set<Int> = [answer]
        while opts.count < 3 { opts.insert(Int.random(in: 1...5)) }
        return Make5Q(emoji: critters.randomElement()!, have: have, answer: answer,
                      options: Array(opts).shuffled(),
                      fact: "\(have) and \(answer) makes 5! 🎉")
    }
}

struct Make5Player: View {
    let level: Make5Level
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = Make5Gen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Make 5!",
                            subtitle: "Count what's here, then find how many more make 5.") {
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { _ in EmojiView(emoji: "🐥", size: 30, tint: .white) }
                        Text("and").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        ForEach(0..<2, id: \.self) { _ in EmojiView(emoji: "🐥", size: 30, tint: .white) }
                        Text("= 5").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 18) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("How many more make 5?")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 8) {
                        ForEach(0..<data.have, id: \.self) { _ in EmojiView(emoji: data.emoji, size: 40, tint: .white) }
                        Text("+ ?").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("make5cheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 52, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 110)
    }

    private func newRound() { data = Make5Gen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Difficulty (games get harder as he masters them)
//
// Set before a game opens (see the home tile). Number games read these ceilings
// so counting climbs 6 -> 10 -> 15 and adding/subtracting climbs toward 20.
enum GameDifficulty {
    static var level = 1
    private static func pick(_ a: Int, _ b: Int, _ c: Int) -> Int { level >= 3 ? c : (level == 2 ? b : a) }
    static var countMax: Int { pick(6, 10, 15) }
    static var addendMax: Int { pick(4, 6, 8) }
    static var sumMax: Int { pick(8, 12, 16) }
    static var takeMax: Int { pick(6, 9, 12) }
}

// MARK: - Make 10 (K.OA.4: make ten with a missing part)

struct Make10Level: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct Make10Q { let emoji: String; let have: Int; let answer: Int; var options: [Int]; let fact: String }

enum Make10Gen {
    static let critters = ["🐥", "🐰", "🐶", "🐱", "🐸", "🦆"]
    static var lastHave: Int?
    static func make() -> Make10Q {
        var have = Int.random(in: 1...9)
        if let l = lastHave { while have == l { have = Int.random(in: 1...9) } }
        lastHave = have
        let answer = 10 - have
        var opts: Set<Int> = [answer]
        while opts.count < 3 { opts.insert(Int.random(in: 1...10)) }
        return Make10Q(emoji: critters.randomElement()!, have: have, answer: answer,
                       options: Array(opts).shuffled(),
                       fact: "\(have) and \(answer) makes 10! 🎉")
    }
}

struct Make10Player: View {
    let level: Make10Level
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = Make10Gen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Make 10!",
                            subtitle: "Count what's here, then find how many more make 10.") {
                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \.self) { _ in EmojiView(emoji: "🐥", size: 26, tint: .white) }
                        Text("and").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        ForEach(0..<3, id: \.self) { _ in EmojiView(emoji: "🐥", size: 26, tint: .white) }
                        Text("= 10").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("How many more make 10?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 6) {
                        ForEach(0..<data.have, id: \.self) { _ in EmojiView(emoji: data.emoji, size: 34, tint: .white) }
                        Text("+ ?").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 20) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("make10cheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = Make10Gen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Take Away (K.OA.1: subtraction within 10)

struct TakeAwayLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct TakeAwayQ { let emoji: String; let start: Int; let gone: Int; let answer: Int; var options: [Int]; let fact: String }

enum TakeAwayGen {
    static let critters = ["🐤", "🐰", "🐶", "🐱", "🐸", "🐥"]
    static var lastKey: String?
    static func make() -> TakeAwayQ {
        var start = Int.random(in: 2...GameDifficulty.takeMax)
        var gone = Int.random(in: 1..<start)
        if "\(start)-\(gone)" == lastKey { start = Int.random(in: 2...GameDifficulty.takeMax); gone = Int.random(in: 1..<start) }
        lastKey = "\(start)-\(gone)"
        let answer = start - gone
        var opts: Set<Int> = [answer]
        while opts.count < 3 { opts.insert(Int.random(in: 0...9)) }
        return TakeAwayQ(emoji: critters.randomElement()!, start: start, gone: gone, answer: answer,
                         options: Array(opts).shuffled(),
                         fact: "\(start) take away \(gone) leaves \(answer)! 🎉")
    }
}

struct TakeAwayPlayer: View {
    let level: TakeAwayLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = TakeAwayGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Take away!",
                            subtitle: "Some hop away. Count how many are LEFT.") {
                    HStack(spacing: 8) {
                        EmojiView(emoji: "🐤", size: 34, tint: .white)
                        EmojiView(emoji: "🐤", size: 34, tint: .white)
                        EmojiView(emoji: "🐤", size: 34, tint: .white).opacity(0.2)
                        Text("= 2 left").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("How many are left?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 6) {
                        ForEach(0..<data.start, id: \.self) { i in
                            EmojiView(emoji: data.emoji, size: 34, tint: .white)
                                .opacity(i >= data.start - data.gone ? 0.18 : 1)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 20) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("takeawaycheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = TakeAwayGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Doubles (1.OA.6: doubles facts)

struct DoublesLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct DoublesQ { let emoji: String; let n: Int; let answer: Int; var options: [Int]; let fact: String }

enum DoublesGen {
    static let critters = ["🐶", "🐱", "🐰", "🐥", "🐸", "🐻"]
    static var lastN: Int?
    static func make() -> DoublesQ {
        var n = Int.random(in: 1...5)
        if let l = lastN { while n == l { n = Int.random(in: 1...5) } }
        lastN = n
        let answer = n * 2
        var opts: Set<Int> = [answer]
        while opts.count < 3 { let d = Int.random(in: 2...12); if d != answer { opts.insert(d) } }
        return DoublesQ(emoji: critters.randomElement()!, n: n, answer: answer,
                        options: Array(opts).shuffled(),
                        fact: "\(n) and \(n) makes \(answer)! 🎉")
    }
}

struct DoublesPlayer: View {
    let level: DoublesLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = DoublesGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Doubles!",
                            subtitle: "A double is a number and itself. 2 and 2 makes 4.") {
                    HStack(spacing: 8) {
                        EmojiView(emoji: "🐶", size: 34, tint: .white)
                        EmojiView(emoji: "🐶", size: 34, tint: .white)
                        Text("and").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "🐶", size: 34, tint: .white)
                        EmojiView(emoji: "🐶", size: 34, tint: .white)
                        Text("= 4").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Double it! How many in all?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 6) {
                        ForEach(0..<data.n, id: \.self) { _ in EmojiView(emoji: data.emoji, size: 34, tint: .white) }
                        Text("+").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        ForEach(0..<data.n, id: \.self) { _ in EmojiView(emoji: data.emoji, size: 34, tint: .white) }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 20) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("doublescheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = DoublesGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Ordinal Numbers (K/1st: first, second, third)

struct OrdinalLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct OrdinalQ { let row: [String]; let word: String; let answer: String; var options: [String]; let fact: String }

enum OrdinalGen {
    static let pool = ["🐶", "🐱", "🐰", "🐥", "🐸", "🐻", "🦆", "🐷", "🐮", "🐔"]
    static let words = ["1st", "2nd", "3rd", "4th"]
    static var lastWord: String?
    static func make() -> OrdinalQ {
        let row = Array(pool.shuffled().prefix(4))
        var i = Int.random(in: 0..<4)
        if let l = lastWord { while words[i] == l { i = Int.random(in: 0..<4) } }
        lastWord = words[i]
        return OrdinalQ(row: row, word: words[i], answer: row[i], options: row.shuffled(),
                        fact: "Yes, the \(words[i]) one! 🎉")
    }
}

struct OrdinalPlayer: View {
    let level: OrdinalLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = OrdinalGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "First, second, third!",
                            subtitle: "Count from the front to find each place.") {
                    HStack(spacing: 16) {
                        VStack(spacing: 4) { EmojiView(emoji: "🐶", size: 40, tint: .white)
                            Text("1st").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 4) { EmojiView(emoji: "🐱", size: 40, tint: .white)
                            Text("2nd").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                        VStack(spacing: 4) { EmojiView(emoji: "🐰", size: 40, tint: .white)
                            Text("3rd").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Which one is \(data.word)?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 10) {
                        Text("➡️").font(.system(size: 24))
                        ForEach(Array(data.row.enumerated()), id: \.offset) { _, e in
                            EmojiView(emoji: e, size: 40, tint: .white)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("ordcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && e == data.answer ? Theme.green : wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: e, size: 80, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
    }
    private func newRound() { data = OrdinalGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = e; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Beginning Sounds (RF.K.3: letter-sound match)

struct SoundLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct SoundQ { let letter: String; let answer: String; var options: [String]; let fact: String }

enum SoundGen {
    static let animals: [(e: String, name: String, l: String)] = [
        ("🐻", "Bear", "B"), ("🐝", "Bee", "B"), ("🐰", "Rabbit", "R"), ("🐶", "Dog", "D"),
        ("🐱", "Cat", "C"), ("🐸", "Frog", "F"), ("🐷", "Pig", "P"), ("🐟", "Fish", "F"),
        ("🦆", "Duck", "D"), ("🐢", "Turtle", "T"), ("🦁", "Lion", "L"), ("🐘", "Elephant", "E"),
        ("🐧", "Penguin", "P"), ("🐴", "Horse", "H"), ("🐐", "Goat", "G"), ("🦉", "Owl", "O"),
        ("🐺", "Wolf", "W"), ("🐍", "Snake", "S"), ("🐮", "Cow", "C"), ("🐔", "Hen", "H")
    ]
    static var lastL: String?
    static func make() -> SoundQ {
        var correct = animals.randomElement()!
        if let l = lastL { while correct.l == l { correct = animals.randomElement()! } }
        lastL = correct.l
        let distractors = Array(animals.filter { $0.l != correct.l }.shuffled().prefix(2).map { $0.e })
        return SoundQ(letter: correct.l, answer: correct.e, options: ([correct.e] + distractors).shuffled(),
                      fact: "\(correct.name) starts with \(correct.l)! 🎉")
    }
}

struct BeginningSoundPlayer: View {
    let level: SoundLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = SoundGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Beginning sounds!",
                            subtitle: "Every word starts with a sound. Bear starts with B.") {
                    HStack(spacing: 14) {
                        Text("B").font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                        Image(systemName: "arrow.right").font(.system(size: 22, weight: .black)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "🐻", size: 56, tint: .white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Which one starts with \(data.letter)?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    Text(data.letter)
                        .font(.system(size: 96, weight: .black, design: .rounded)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("soundcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && e == data.answer ? Theme.green : wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: e, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = SoundGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = e; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Life Cycle (1-LS1: living things grow and change)

struct CycleLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct CycleQ { let shown: [String]; let answer: String; var options: [String]; let fact: String }

enum CycleGen {
    static let cycles: [(stages: [String], name: String)] = [
        (["🥚", "🐛", "🦋"], "butterfly"),
        (["🥚", "🐣", "🐔"], "chicken"),
        (["🌱", "🌿", "🌸"], "flower")
    ]
    static var lastName: String?
    static func make() -> CycleQ {
        var c = cycles.randomElement()!
        if let l = lastName { while c.name == l { c = cycles.randomElement()! } }
        lastName = c.name
        let distractors = Array(cycles.filter { $0.name != c.name }.map { $0.stages.last! }.shuffled().prefix(2))
        return CycleQ(shown: Array(c.stages.prefix(2)), answer: c.stages[2],
                      options: ([c.stages[2]] + distractors).shuffled(),
                      fact: "The \(c.name) grew up! 🎉")
    }
}

struct LifeCyclePlayer: View {
    let level: CycleLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = CycleGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Growing up!",
                            subtitle: "Living things grow and change into something new.") {
                    HStack(spacing: 10) {
                        EmojiView(emoji: "🥚", size: 44, tint: .white)
                        Image(systemName: "arrow.right").font(.system(size: 18, weight: .black)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "🐛", size: 44, tint: .white)
                        Image(systemName: "arrow.right").font(.system(size: 18, weight: .black)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "🦋", size: 44, tint: .white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("What comes next?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 10) {
                        ForEach(Array(data.shown.enumerated()), id: \.offset) { _, e in
                            EmojiView(emoji: e, size: 48, tint: .white)
                            Image(systemName: "arrow.right").font(.system(size: 18, weight: .black)).foregroundStyle(Theme.textSecondary)
                        }
                        Text("?").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("cyclecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && e == data.answer ? Theme.green : wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: e, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = CycleGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = e; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Count by 10s (K.CC.1: skip counting by tens)

struct TensLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct TensQ { let seq: [Int]; let answer: Int; var options: [Int]; let fact: String }

enum TensGen {
    static var lastS: Int?
    static func make() -> TensQ {
        var s = Int.random(in: 1...6)
        if let l = lastS { while s == l { s = Int.random(in: 1...6) } }
        lastS = s
        let seq = [s * 10, (s + 1) * 10, (s + 2) * 10]
        let answer = (s + 3) * 10
        var opts: Set<Int> = [answer]
        while opts.count < 3 {
            let d = [answer - 10, answer + 10, answer + 20, answer - 20].randomElement()!
            if d > 0 && d != answer { opts.insert(d) }
        }
        return TensQ(seq: seq, answer: answer, options: Array(opts).shuffled(), fact: "Count by tens: \(answer)! 🎉")
    }
}

struct TensPlayer: View {
    let level: TensLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = TensGen.make()
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Count by 10s!",
                            subtitle: "Ten, twenty, thirty — jump by ten each time.") {
                    HStack(spacing: 12) {
                        ForEach([10, 20, 30], id: \.self) { n in
                            Text("\(n)").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
                            if n != 30 { Image(systemName: "arrow.right").font(.system(size: 18, weight: .black)).foregroundStyle(Theme.green) }
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("What comes next?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 10) {
                        ForEach(data.seq, id: \.self) { n in
                            Text("\(n)").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
                            Image(systemName: "arrow.right").font(.system(size: 16, weight: .black)).foregroundStyle(Theme.textSecondary)
                        }
                        Text("?").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 22)
                    .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 20) {
                        ForEach(data.options, id: \.self) { n in
                            Button { tap(n) } label: { tile(n) }.wiggle(wrong == n)
                        }
                    }
                    .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("tenscheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ n: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && n == data.answer ? Theme.green : wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text("\(n)").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = TensGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ n: Int) {
        guard !cheer else { return }
        if n == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = n; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Fast or Slow (comparing animals by how they move)

struct SpeedLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct SpeedQ { let emoji: String; let fast: Bool; let fact: String }

enum SpeedGen {
    static let fast = ["🐆", "🐇", "🐎", "🦅", "🐬", "🦈", "🐩"]
    static let slow = ["🐢", "🐌", "🦥", "🐛", "🐨", "🦦"]
    static var last: String?
    static func make() -> SpeedQ {
        let isFast = Bool.random()
        var e = (isFast ? fast : slow).randomElement()!
        if let l = last { while e == l { e = (isFast ? fast : slow).randomElement()! } }
        last = e
        return SpeedQ(emoji: e, fast: isFast, fact: isFast ? "Zoom! That one is fast! 🎉" : "Slow and steady! 🎉")
    }
}

struct FastSlowPlayer: View {
    let level: SpeedLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = SpeedGen.make()
    @State private var wrong: Bool?
    @State private var cheer = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Fast or slow?",
                            subtitle: "Some animals zoom fast. Some go nice and slow.") {
                    HStack(spacing: 18) {
                        VStack(spacing: 4) { EmojiView(emoji: "🐆", size: 48, tint: .white)
                            Text("fast").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 4) { EmojiView(emoji: "🐢", size: 48, tint: .white)
                            Text("slow").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Color.blue) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Is it fast or slow?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.emoji, size: 120, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 180)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 18) {
                        Button { tap(true) } label: { cat("🏃", "Fast", Theme.green) }.wiggle(wrong == true)
                        Button { tap(false) } label: { cat("🐢", "Slow", Color.blue) }.wiggle(wrong == false)
                    }
                    .frame(maxWidth: 640)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("fastcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func cat(_ emoji: String, _ label: String, _ color: Color) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 30))
            Text(label).font(.system(size: 24, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(.white).padding(.vertical, 20).frame(maxWidth: .infinity)
        .background(color).clipShape(RoundedRectangle(cornerRadius: 20))
    }
    private func newRound() { data = SpeedGen.make(); wrong = nil; cheer = false }
    private func tap(_ v: Bool) {
        guard !cheer else { return }
        if v == data.fast {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            wrong = v; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrong = nil }
        }
    }
}

// MARK: - Sink or Float (K-2 science: does it sink or float?)

struct FloatLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct FloatQ { let emoji: String; let floats: Bool; let fact: String }

enum FloatGen {
    static let floaters = ["🦆", "🛟", "🍃", "🐟", "🦢", "⛵️", "🪵"]
    static let sinkers = ["🪨", "🔑", "🥄", "⚓️", "🧱", "🪙"]
    static var last: String?
    static func make() -> FloatQ {
        let doesFloat = Bool.random()
        var e = (doesFloat ? floaters : sinkers).randomElement()!
        if let l = last { while e == l { e = (doesFloat ? floaters : sinkers).randomElement()! } }
        last = e
        return FloatQ(emoji: e, floats: doesFloat, fact: doesFloat ? "It floats on top! 🎉" : "It sinks down! 🎉")
    }
}

struct SinkFloatPlayer: View {
    let level: FloatLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = FloatGen.make()
    @State private var wrong: Bool?
    @State private var cheer = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Sink or float?",
                            subtitle: "Some things float on top of the water. Some sink down.") {
                    HStack(spacing: 18) {
                        VStack(spacing: 4) { EmojiView(emoji: "🦆", size: 48, tint: .white)
                            Text("floats").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Color.blue) }
                        VStack(spacing: 4) { EmojiView(emoji: "🪨", size: 48, tint: .white)
                            Text("sinks").font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Does it sink or float?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.emoji, size: 120, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 180)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 18) {
                        Button { tap(true) } label: { cat("🛟", "Floats", Color.blue) }.wiggle(wrong == true)
                        Button { tap(false) } label: { cat("🪨", "Sinks", Theme.surfaceHi) }.wiggle(wrong == false)
                    }
                    .frame(maxWidth: 640)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("floatcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func cat(_ emoji: String, _ label: String, _ color: Color) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 30))
            Text(label).font(.system(size: 24, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(.white).padding(.vertical, 20).frame(maxWidth: .infinity)
        .background(color).clipShape(RoundedRectangle(cornerRadius: 20))
    }
    private func newRound() { data = FloatGen.make(); wrong = nil; cheer = false }
    private func tap(_ v: Bool) {
        guard !cheer else { return }
        if v == data.floats {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            wrong = v; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrong = nil }
        }
    }
}

// MARK: - Big & Little Letters (RF.K.1d: match uppercase to lowercase)

struct CaseLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct CaseQ { let big: String; let answer: String; var options: [String]; let fact: String }

enum CaseGen {
    static let letters = Array("ABDEFGHKMNRT")
    static var last: Character?
    static func make() -> CaseQ {
        var c = letters.randomElement()!
        if let l = last { while c == l { c = letters.randomElement()! } }
        last = c
        let answer = String(c).lowercased()
        var opts: Set<String> = [answer]
        while opts.count < 3 {
            let d = String(letters.randomElement()!).lowercased()
            if d != answer { opts.insert(d) }
        }
        return CaseQ(big: String(c), answer: answer, options: Array(opts).shuffled(),
                     fact: "\(c) and \(answer) are the same letter! 🎉")
    }
}

struct LetterCasePlayer: View {
    let level: CaseLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = CaseGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Big and little letters!",
                            subtitle: "Every letter has a big one and a little one.") {
                    HStack(spacing: 10) {
                        Text("B").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
                        Text("b").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(Theme.green)
                        Text("same letter!").font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("Find the little \(data.big.lowercased())")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    Text(data.big)
                        .font(.system(size: 100, weight: .black, design: .rounded)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { s in
                            Button { tap(s) } label: { tile(s) }.wiggle(wrong == s)
                        }
                    }
                    .frame(maxWidth: 700)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("casecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ s: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && s == data.answer ? Theme.green : wrong == s ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            Text(s).font(.system(size: 62, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
    }
    private func newRound() { data = CaseGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ s: String) {
        guard !cheer else { return }
        if s == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = s; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Five Senses (K science: see, hear, smell, taste, touch)

struct SenseLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct SenseQ { let verb: String; let answer: String; var options: [String]; let fact: String }

enum SenseGen {
    static let senses: [(verb: String, part: String, name: String)] = [
        ("see", "👀", "eyes"), ("hear", "👂", "ears"), ("smell", "👃", "nose"),
        ("taste", "👅", "tongue"), ("touch", "✋", "hands")
    ]
    static var last: String?
    static func make() -> SenseQ {
        var s = senses.randomElement()!
        if let l = last { while s.verb == l { s = senses.randomElement()! } }
        last = s.verb
        let distractors = Array(senses.filter { $0.part != s.part }.shuffled().prefix(2).map { $0.part })
        return SenseQ(verb: s.verb, answer: s.part, options: ([s.part] + distractors).shuffled(),
                      fact: "You \(s.verb) with your \(s.name)! 🎉")
    }
}

struct FiveSensesPlayer: View {
    let level: SenseLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = SenseGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Your 5 senses!",
                            subtitle: "See, hear, smell, taste, and touch.") {
                    HStack(spacing: 16) {
                        ForEach(["👀", "👂", "👃", "👅", "✋"], id: \.self) { e in
                            EmojiView(emoji: e, size: 40, tint: .white)
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("What do you \(data.verb) with?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                    .frame(maxWidth: 700)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("sensecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && e == data.answer ? Theme.green : wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: e, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = SenseGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = e; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Opposites (L.K.5b: word opposites)

struct OppLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }
struct OppQ { let word: String; let cue: String; let answer: String; var options: [String]; let fact: String }

enum OppGen {
    static let pairs: [(word: String, cue: String, opp: String, oppWord: String)] = [
        ("big", "🐘", "🐭", "little"), ("hot", "🔥", "❄️", "cold"),
        ("happy", "😀", "😢", "sad"), ("up", "⬆️", "⬇️", "down"),
        ("day", "☀️", "🌙", "night"), ("fast", "🐆", "🐌", "slow")
    ]
    static var last: String?
    static func make() -> OppQ {
        var p = pairs.randomElement()!
        if let l = last { while p.word == l { p = pairs.randomElement()! } }
        last = p.word
        let distractors = Array(pairs.filter { $0.opp != p.opp }.shuffled().prefix(2).map { $0.opp })
        return OppQ(word: p.word, cue: p.cue, answer: p.opp, options: ([p.opp] + distractors).shuffled(),
                    fact: "The opposite of \(p.word) is \(p.oppWord)! 🎉")
    }
}

struct OppositesPlayer: View {
    let level: OppLevel
    let accent: Color
    let onComplete: () -> Void
    @State private var round = 0
    @State private var data = OppGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Opposites!",
                            subtitle: "Opposites are totally different — like hot and cold.") {
                    HStack(spacing: 12) {
                        EmojiView(emoji: "🔥", size: 44, tint: .white)
                        Text("vs").font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        EmojiView(emoji: "❄️", size: 44, tint: .white)
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 30) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text("What's the opposite of \(data.word)?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    EmojiView(emoji: data.cue, size: 110, tint: .white)
                        .frame(maxWidth: .infinity).frame(height: 170)
                        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22))
                    HStack(spacing: 14) {
                        ForEach(data.options, id: \.self) { e in
                            Button { tap(e) } label: { tile(e) }.wiggle(wrong == e)
                        }
                    }
                    .frame(maxWidth: 700)
                }
                .frame(maxWidth: .infinity)
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("oppcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }
    private func tile(_ e: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(revealed && e == data.answer ? Theme.green : wrong == e ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: e, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }
    private func newRound() { data = OppGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }
    private func tap(_ e: String) {
        guard !cheer else { return }
        if e == data.answer {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = e; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.answer) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.answer, from: cur) }
            }
        }
    }
}

// MARK: - Which Has More? (K.CC.6: compare two groups)
//
// Two groups of animals; he taps the one with more (or fewer). Short teach.

struct MoreLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct MoreQ { let emoji: String; let left: Int; let right: Int; let askMore: Bool; let fact: String }

enum MoreGen {
    static let critters = ["🐶", "🐱", "🐰", "🐥", "🐸", "🐝", "🐠"]
    static var lastAsk: Bool?
    static func make() -> MoreQ {
        let a = Int.random(in: 1...6); var b = Int.random(in: 1...6)
        while b == a { b = Int.random(in: 1...6) }
        var askMore = Bool.random()
        if let l = lastAsk { askMore = !l }
        lastAsk = askMore
        let hi = max(a, b), lo = min(a, b)
        let fact = askMore ? "\(hi) is more than \(lo)! 🎉" : "\(lo) is fewer than \(hi)! 🎉"
        return MoreQ(emoji: critters.randomElement()!, left: a, right: b, askMore: askMore, fact: fact)
    }
}

struct WhichMorePlayer: View {
    let level: MoreLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = MoreGen.make()
    @State private var wrong: String?      // "left" / "right"
    @State private var cheer = false
    @State private var phase: LessonPhase = .teach

    private var correctSide: String {
        let leftWins = data.askMore ? (data.left > data.right) : (data.left < data.right)
        return leftWins ? "left" : "right"
    }

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Which has more?",
                            subtitle: "Count both groups. More means the bigger group.") {
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            HStack(spacing: 3) { ForEach(0..<3, id: \.self) { _ in EmojiView(emoji: "🐶", size: 26, tint: .white) } }
                            Text("more").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                        }
                        VStack(spacing: 4) {
                            EmojiView(emoji: "🐶", size: 26, tint: .white)
                            Text("fewer").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.askMore ? "Which has more?" : "Which has fewer?")
                        .font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    HStack(spacing: 14) {
                        Button { tap("left") } label: { groupTile(data.left) }.wiggle(wrong == "left")
                        Button { tap("right") } label: { groupTile(data.right) }.wiggle(wrong == "right")
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("morecheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func groupTile(_ n: Int) -> some View {
        let rows = stride(from: 0, to: n, by: 3).map { min(3, n - $0) }
        return VStack(spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, c in
                HStack(spacing: 6) { ForEach(0..<c, id: \.self) { _ in EmojiView(emoji: data.emoji, size: 38, tint: .white) } }
            }
        }
        .frame(maxWidth: .infinity).frame(height: 150)
        .background((wrong != nil) ? Theme.surfaceHi : Theme.surfaceHi)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() { data = MoreGen.make(); wrong = nil; cheer = false }

    private func tap(_ side: String) {
        guard !cheer else { return }
        if side == correctSide {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            wrong = side; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrong = nil }
        }
    }
}


// MARK: - Egg or Not? (NGSS K life science: how animals have young)
//
// "Which one hatches from an egg?" / "Which one does NOT?" Short teach, then
// sort animals by whether they lay eggs.

struct EggAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let egg: Bool }

struct EggLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct EggQ { let correct: EggAnimal; let prompt: String; let fact: String; var options: [EggAnimal] }

enum EggGen {
    static let animals: [EggAnimal] = [
        EggAnimal(id: "hen",     emoji: "🐔", name: "hen",     egg: true),
        EggAnimal(id: "bird",    emoji: "🐦", name: "bird",    egg: true),
        EggAnimal(id: "turtle",  emoji: "🐢", name: "turtle",  egg: true),
        EggAnimal(id: "snake",   emoji: "🐍", name: "snake",   egg: true),
        EggAnimal(id: "fish",    emoji: "🐠", name: "fish",    egg: true),
        EggAnimal(id: "frog",    emoji: "🐸", name: "frog",    egg: true),
        EggAnimal(id: "duck",    emoji: "🦆", name: "duck",    egg: true),
        EggAnimal(id: "lizard",  emoji: "🦎", name: "lizard",  egg: true),
        EggAnimal(id: "dog",     emoji: "🐶", name: "dog",     egg: false),
        EggAnimal(id: "cat",     emoji: "🐱", name: "cat",     egg: false),
        EggAnimal(id: "cow",     emoji: "🐮", name: "cow",     egg: false),
        EggAnimal(id: "rabbit",  emoji: "🐰", name: "rabbit",  egg: false),
        EggAnimal(id: "horse",   emoji: "🐴", name: "horse",   egg: false),
        EggAnimal(id: "pig",     emoji: "🐷", name: "pig",     egg: false)
    ]
    static var lastEgg: Bool?
    static func make() -> EggQ {
        var askEgg = Bool.random()
        if let l = lastEgg { askEgg = !l }
        lastEgg = askEgg
        let correct = animals.filter { $0.egg == askEgg }.randomElement()!
        let distract = Array(animals.filter { $0.egg != askEgg }.shuffled().prefix(2))
        let prompt = askEgg ? "Which hatches from an egg? 🥚" : "Which does NOT hatch from an egg?"
        let fact = askEgg ? "A \(correct.name) hatches from an egg! 🥚"
                          : "A \(correct.name) is born, not from an egg! 🍼"
        return EggQ(correct: correct, prompt: prompt, fact: fact, options: ([correct] + distract).shuffled())
    }
}

struct EggPlayer: View {
    let level: EggLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = EggGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Some animals hatch\nfrom eggs.",
                            subtitle: "Hens and turtles lay eggs. Puppies are born.") {
                    HStack(spacing: 24) {
                        VStack(spacing: 6) { EmojiView(emoji: "🥚", size: 50, tint: .white); Text("egg").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 6) { EmojiView(emoji: "🐶", size: 50, tint: .white); Text("born").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options) { a in
                            Button { tap(a) } label: { tile(a) }.wiggle(wrong == a.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("eggcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ a: EggAnimal) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && a.id == data.correct.id ? Theme.green : wrong == a.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: a.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = EggGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ a: EggAnimal) {
        guard !cheer else { return }
        if a.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = a.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}

// MARK: - Wild or Pet? (classifying animals)
//
// "Which one is a pet?" / "Which one is wild?" Short teach, then sort.

struct WildAnimal: Identifiable, Hashable { let id: String; let emoji: String; let name: String; let pet: Bool }

struct WildLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct WildQ { let correct: WildAnimal; let prompt: String; let fact: String; var options: [WildAnimal] }

enum WildGen {
    static let animals: [WildAnimal] = [
        WildAnimal(id: "dog",     emoji: "🐶", name: "dog",     pet: true),
        WildAnimal(id: "cat",     emoji: "🐱", name: "cat",     pet: true),
        WildAnimal(id: "rabbit",  emoji: "🐰", name: "rabbit",  pet: true),
        WildAnimal(id: "fish",    emoji: "🐠", name: "fish",    pet: true),
        WildAnimal(id: "hamster", emoji: "🐹", name: "hamster", pet: true),
        WildAnimal(id: "bird",    emoji: "🐦", name: "bird",    pet: true),
        WildAnimal(id: "lion",    emoji: "🦁", name: "lion",    pet: false),
        WildAnimal(id: "tiger",   emoji: "🐯", name: "tiger",   pet: false),
        WildAnimal(id: "elephant",emoji: "🐘", name: "elephant",pet: false),
        WildAnimal(id: "bear",    emoji: "🐻", name: "bear",    pet: false),
        WildAnimal(id: "zebra",   emoji: "🦓", name: "zebra",   pet: false),
        WildAnimal(id: "giraffe", emoji: "🦒", name: "giraffe", pet: false),
        WildAnimal(id: "monkey",  emoji: "🐵", name: "monkey",  pet: false)
    ]
    static var lastPet: Bool?
    static func make() -> WildQ {
        var askPet = Bool.random()
        if let l = lastPet { askPet = !l }
        lastPet = askPet
        let correct = animals.filter { $0.pet == askPet }.randomElement()!
        let distract = Array(animals.filter { $0.pet != askPet }.shuffled().prefix(2))
        let prompt = askPet ? "Which one is a pet? 🏠" : "Which one is wild? 🌴"
        let fact = askPet ? "A \(correct.name) can be a pet! 🏠"
                          : "A \(correct.name) is a wild animal! 🌴"
        return WildQ(correct: correct, prompt: prompt, fact: fact, options: ([correct] + distract).shuffled())
    }
}

struct WildPetPlayer: View {
    let level: WildLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var data = WildGen.make()
    @State private var wrong: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var phase: LessonPhase = .teach

    var body: some View {
        ZStack {
            if phase == .teach {
                TeachScreen(title: "Pets live with people.\nWild animals don't.",
                            subtitle: "Dogs and cats are pets. Lions live in the wild.") {
                    HStack(spacing: 24) {
                        VStack(spacing: 6) { EmojiView(emoji: "🐶", size: 50, tint: .white); Text("pet 🏠").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                        VStack(spacing: 6) { EmojiView(emoji: "🦁", size: 50, tint: .white); Text("wild 🌴").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green) }
                    }
                } onStart: { withAnimation { phase = .play } }
            } else {
                VStack(spacing: 20) {
                    if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }
                    Text(data.prompt)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    HStack(spacing: 14) {
                        ForEach(data.options) { a in
                            Button { tap(a) } label: { tile(a) }.wiggle(wrong == a.id)
                        }
                    }
                }
            }
            if cheer { CheerOverlay(custom: data.fact).transition(.opacity).id("wildcheer\(round)") }
        }
        .onAppear { phase = .teach; round = 0; newRound() }
    }

    private func tile(_ a: WildAnimal) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(revealed && a.id == data.correct.id ? Theme.green : wrong == a.id ? Theme.red.opacity(0.5) : Theme.surfaceHi)
            EmojiView(emoji: a.emoji, size: 84, tint: .white)
        }
        .frame(maxWidth: .infinity).frame(height: 160)
    }

    private func newRound() { data = WildGen.make(); wrong = nil; cheer = false; missed = 0; revealed = false }

    private func tap(_ a: WildAnimal) {
        guard !cheer else { return }
        if a.id == data.correct.id {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1; wrong = a.id; SFX.wrong(); if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                wrong = nil
                if GameStats.wrongThisGame >= 2 { return }   // struggling: hold the answer still
                let cur = data.options.firstIndex(of: data.correct) ?? -1
                withAnimation { data.options = data.options.shuffledMoving(data.correct, from: cur) }
            }
        }
    }
}
