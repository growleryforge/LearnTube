import SwiftUI

// MARK: - Math taught concrete-first: act it out, count, predict, then numbers
//
// Every generated number game climbs the same ladder. Before a number pad ever
// appears, the math is something Gabriel DOES to animals on the screen:
//
//   Stage 1  He acts it out.  "5 ducks on the pond. 2 go away. Drag them off!"
//            He DRAGS the two that leave to the path (or drags newcomers in
//            from the fence), then touches each animal left to count it.
//            Only then does the sentence appear, words first, symbols under:
//            "5 ducks, 2 went away, 3 are left.     5 - 2 = 3"
//            Nothing to type, nothing to get wrong.
//   Stage 2  He counts.  The animals move on their own; he counts what's
//            there by touching, then picks the number from three.
//   Stage 3  He predicts.  "5 ducks. 2 are going to go away. How many will be
//            left?" He picks, THEN the animals act it out and he sees it.
//            No buzzer: the animals are the check.
//   Stage 4+ The number pad (NumberPadPlayer), levels 1-3.
//
// Big numbers use crates of ten (a basket with a "10" on it) next to loose
// animals, so 23 is two crates and three chicks, and touching a crate counts
// "10, 20" before the ones count "21, 22, 23".
//
// One script everywhere: start with, some go away / more come, how many are
// left / how many in all. The symbol line sits under the words so it gets
// familiar by sight. The stage comes from `GameDifficulty.rung`.

struct ActOutPlayer: View {
    let game: NumberGame
    let stage: Int          // 1, 2 or 3
    let rounds: Int
    let accent: Color
    let onComplete: () -> Void

    // MARK: One round

    /// A thing on the scene: an animal (value 1), a crate of ten, or a group
    /// for skip counting (value 2 or 5).
    struct Token: Identifiable {
        let id: Int
        var value: Int = 1
        var emoji: String
        var place: Place = .scene
        var number: Int? = nil        // the running count he gave it
        var countable = true          // takes part in the count phase
        var tag: String? = nil        // small label ("10", or a position number)
        var row = 0                   // compare games line up two rows
        enum Place { case waiting, scene, gone }
    }

    struct Round {
        var emoji = "🦆"
        var name = "ducks"
        var place = "on the pond"
        var tokens: [Token] = []
        var leaving = 0                // how many to drag off (take-away)
        var arriving = 0               // how many to drag in (adding)
        var countFrom = 0              // count-on games start the count here
        var answer = 0
        var actLine = ""               // Stage 1 instruction
        var predictLine = ""           // Stage 3 question
        var countLine = "How many now? Touch each one to count! 👆"
        var words = ""                 // the sentence in words
        var equation: [(String, Color)] = []
        var compare = false            // two rows, count the extras
        var pick = false               // "touch the right one" (number before)
        var leaveValue = 1             // what leaves in a take-away: a loose animal, or a crate (10)
    }

    private enum Phase { case act, watch, count, choose, sentence }

    @State private var roundIndex = 0
    @State private var round = Round()
    @State private var phase: Phase = .act
    @State private var moved = 0
    @State private var counted = 0
    @State private var total = 0
    @State private var guess: Int? = nil
    @State private var choices: [Int] = []
    @State private var mood: MascotMood = .idle
    @State private var confetti = false
    @State private var seeded = false
    @State private var wiggleID: Int? = nil
    // Dragging
    @State private var dragID: Int? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var zoneFrames: [String: CGRect] = [:]

    private var hasAct: Bool { round.leaving > 0 || round.arriving > 0 }

    /// The one-line instruction inside the pond.
    private var caption: String {
        switch phase {
        case .act:
            let left = (round.leaving > 0 ? round.leaving : round.arriving) - moved
            return round.leaving > 0 ? "Drag \(left) to the path →" : "Drag \(left) in from the fence ↓"
        case .watch:    return "Watch! 👀"
        case .count:    return round.pick ? "Touch the right one 👆" : "Touch each one to count 👆"
        case .choose:   return "Tap the number below 👇"
        case .sentence: return "\(round.answer)!"
        }
    }

    private var bubble: String {
        switch phase {
        case .act:      return round.actLine
        case .watch:    return round.leaving > 0 ? "Watch... \(round.leaving) go away!" : "Here they come! \(round.arriving) more!"
        case .count:    return round.countLine
        case .choose:   return stage == 3 ? round.predictLine : "So what's the number? Tap it!"
        case .sentence:
            if stage == 3, let g = guess {
                return g == round.answer ? "You said \(g), and \(g) it is! 🎉" : "You said \(g). Let's see... it's \(round.answer)!"
            }
            return "\(round.answer)! 🎉"
        }
    }

    var body: some View {
        GameStage(mood: mood, prompt: bubble, confetti: confetti) {
            VStack(spacing: 12) {
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

    // MARK: The scene: pond, the path away, the fence where newcomers wait

    private var scene: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                pond
                    .zIndex(dragID != nil ? 5 : 0)
                if round.leaving > 0 {
                    zone("away", label: "🛤️", caption: "away")
                }
            }
            if round.arriving > 0 {
                fence
            }
        }
        .coordinateSpace(name: "scene")
        .onPreferenceChange(ZoneKey.self) { zoneFrames = $0 }
        .padding(.horizontal, 6)
    }

    /// Canva art for the scene pieces (see tools/thumbs/scene.json). Each one
    /// is optional: the drawn version stands in until the image lands.
    private static func art(_ name: String) -> Image? { UIImage(named: name) != nil ? Image(name) : nil }

    private var pond: some View {
        ZStack(alignment: .topTrailing) {
            if let img = Self.art("act-pond") {
                img.resizable().scaledToFill()
                    .frame(minHeight: 200).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.35), lineWidth: 2))
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.55, green: 0.82, blue: 0.98), Color(red: 0.36, green: 0.68, blue: 0.94)],
                                         startPoint: .top, endPoint: .bottom))
            }
            VStack(spacing: 8) {
                Spacer(minLength: 0)
                if round.compare {
                    VStack(alignment: .leading, spacing: 10) {
                        row(0); row(1)
                    }
                } else {
                    // A fixed column count so the animals cluster in the middle
                    // of the pond instead of hugging the top-left corner.
                    let onScene = round.tokens.filter { $0.place != .waiting }
                    let cols = max(1, min(onScene.count, 5))
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(84), spacing: 6), count: cols), spacing: 8) {
                        ForEach(onScene) { t in tokenView(t) }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Spacer(minLength: 0)
                // What to do, right where he's looking.
                Text(caption)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Capsule().fill(.black.opacity(0.45)))
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 200)
            // Running count, big, while he's counting.
            if phase == .count || phase == .sentence {
                Text("\(total)")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(Capsule().fill(Theme.green))
                    .padding(10)
                    .transition(.scale)
            }
        }
        .frame(minHeight: 200)
        .background(GeometryReader { g in Color.clear.preference(key: ZoneKey.self, value: ["pond": g.frame(in: .named("scene"))]) })
    }

    private func row(_ r: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(round.tokens.filter { $0.row == r && $0.place != .waiting }) { t in tokenView(t) }
            Spacer(minLength: 0)
        }
    }

    private func zone(_ key: String, label: String, caption: String) -> some View {
        VStack(spacing: 4) {
            if let img = Self.art("act-gate") {
                img.resizable().scaledToFit().frame(width: 84)
            } else {
                Text(label).font(.system(size: 44))
            }
            Text(caption).font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: 96)
        .frame(maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(red: 0.62, green: 0.45, blue: 0.28).opacity(dragID != nil ? 1 : 0.75)))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(dragID != nil ? 0.9 : 0), lineWidth: 3))
        .background(GeometryReader { g in Color.clear.preference(key: ZoneKey.self, value: [key: g.frame(in: .named("scene"))]) })
    }

    private var fence: some View {
        HStack(spacing: 6) {
            Text("🌾").font(.system(size: 30))
            ForEach(round.tokens.filter { $0.place == .waiting }) { t in tokenView(t) }
            Spacer(minLength: 0)
            Text("drag them in ↑").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(.white.opacity(0.85))
        }
        .padding(10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(red: 0.45, green: 0.68, blue: 0.30))
                if let img = Self.art("act-fence") {
                    img.resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
        )
    }

    // MARK: A token

    private func tokenView(_ t: Token) -> some View {
        let canDrag = phase == .act && ((round.leaving > 0 && t.place == .scene && t.value == round.leaveValue)
                                        || (round.arriving > 0 && t.place == .waiting))
        let canCount = phase == .count && t.countable && t.place == .scene && t.number == nil
        let crate = t.value > 1
        return ZStack(alignment: .topTrailing) {
            ZStack {
                if crate {
                    if t.value == 10, let img = Self.art("act-crate") {
                        img.resizable().scaledToFit()
                        Text("10").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 2)
                            .offset(y: 18)
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 0.85, green: 0.62, blue: 0.32))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.7), lineWidth: 2))
                        VStack(spacing: 0) {
                            Text(t.emoji).font(.system(size: 30))
                            Text("\(t.value)").font(.system(size: 18, weight: .black, design: .rounded)).foregroundStyle(.white)
                        }
                    }
                } else {
                    Circle().fill(.white.opacity(t.number != nil ? 0.6 : 0.25))
                    Text(t.emoji).font(.system(size: 58))
                }
                if let tag = t.tag, !crate {
                    Text(tag).font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(.black.opacity(0.45)))
                        .offset(y: 30)
                }
            }
            .frame(width: 78, height: 78)
            .overlay(
                Circle().strokeBorder(Theme.gold, lineWidth: 4)
                    .opacity(canDrag || canCount ? 1 : 0)
            )
            .frame(width: 78, height: 78)
            .opacity(t.place == .gone ? 0 : 1)
            .scaleEffect(t.place == .gone ? 0.3 : (canDrag ? 1.04 : 1))
            .shadow(color: .black.opacity(canDrag ? 0.25 : 0), radius: 6, y: 3)
            .offset(x: t.place == .gone ? 220 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.75), value: t.place)
            if let n = t.number {
                Text("\(n)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.green))
                    .offset(x: 4, y: -4)
                    .transition(.scale)
            }
        }
        .offset(dragID == t.id ? dragOffset : .zero)
        .zIndex(dragID == t.id ? 10 : 0)
        .wiggle(wiggleID == t.id)
        .contentShape(Rectangle())
        // One gesture does both tap and drag, and it takes priority over the
        // scroll view every game sits in (otherwise the scroll view eats the
        // finger and the animal never moves).
        .highPriorityGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("scene"))
                .onChanged { v in
                    guard canDrag else { return }
                    if abs(v.translation.width) > 4 || abs(v.translation.height) > 4 {
                        dragID = t.id; dragOffset = v.translation
                    }
                }
                .onEnded { v in
                    let moved = abs(v.translation.width) > 8 || abs(v.translation.height) > 8
                    if !moved {
                        // A tap.
                        withAnimation(.spring(response: 0.3)) { dragID = nil; dragOffset = .zero }
                        if canCount { count(t) } else if phase == .count { nudge(t) }
                        return
                    }
                    guard dragID == t.id else { return }
                    let ok: Bool
                    if t.place == .waiting {
                        ok = (zoneFrames["pond"]?.contains(v.location) ?? false) || v.translation.height < -70
                    } else {
                        ok = (zoneFrames["away"]?.contains(v.location) ?? false) || v.translation.width > 110
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { dragID = nil; dragOffset = .zero }
                    if ok { move(t) }
                }
        )
    }

    private var sentence: some View {
        VStack(spacing: 6) {
            Text(round.words)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                ForEach(Array(round.equation.enumerated()), id: \.offset) { _, part in
                    Text(part.0).font(.system(size: part.0.count > 2 ? 30 : 44, weight: .black, design: .rounded)).foregroundStyle(part.1)
                }
            }
        }
        .padding(.vertical, 6)
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
        round = ActScripts.round(for: game)
        moved = 0; counted = 0; total = round.countFrom; guess = nil; confetti = false; mood = .idle
        choices = Self.choices(for: round.answer)
        switch stage {
        case 1:
            phase = hasAct ? .act : .count
        case 2:
            if hasAct { phase = .watch; DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { autoMove() } }
            else { phase = .count }
        default:
            phase = .choose
        }
    }

    /// Stage 1: a dragged animal leaves the pond, or a newcomer lands on it.
    private func move(_ t: Token) {
        guard let i = round.tokens.firstIndex(where: { $0.id == t.id }) else { return }
        if t.place == .waiting { round.tokens[i].place = .scene } else { round.tokens[i].place = .gone }
        moved += 1
        SFX.tap()
        let need = round.leaving > 0 ? round.leaving : round.arriving
        if moved >= need {
            mood = .happy
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { phase = .count }
        }
    }

    private func count(_ t: Token) {
        guard let i = round.tokens.firstIndex(where: { $0.id == t.id }) else { return }
        counted += 1
        total += t.value
        withAnimation(.spring()) { round.tokens[i].number = total }
        SFX.tap()
        let need = round.tokens.filter { $0.countable && $0.place == .scene }.count
        if counted >= need {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if stage == 2 { phase = .choose } else { land() }
            }
        }
    }

    /// Touched something that isn't part of this count (a "pick the right one"
    /// game): a wiggle, and past stage 1 it counts as a miss.
    private func nudge(_ t: Token) {
        wiggleID = t.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wiggleID = nil }
        if stage > 1 { SFX.wrong() } else { SFX.tap() }
    }

    /// Stages 2 and 3: the animals move on their own, one at a time.
    private func autoMove() {
        let need = round.leaving > 0 ? round.leaving : round.arriving
        for k in 0..<need {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65 * Double(k + 1)) {
                if round.leaving > 0 {
                    let v = round.leaveValue
                    if let i = round.tokens.lastIndex(where: { $0.place == .scene && $0.value == v }) { round.tokens[i].place = .gone }
                } else {
                    if let i = round.tokens.firstIndex(where: { $0.place == .waiting }) { round.tokens[i].place = .scene }
                }
                SFX.tap()
                if k == need - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        if stage == 3 { autoCount() } else { phase = .count }
                    }
                }
            }
        }
    }

    /// Stage 3: after the prediction the count runs itself so he can check.
    private func autoCount() {
        phase = .count
        let ids = round.tokens.filter { $0.countable && $0.place == .scene }.map(\.id)
        guard !ids.isEmpty else { land(); return }
        for (k, id) in ids.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45 * Double(k + 1)) {
                if let i = round.tokens.firstIndex(where: { $0.id == id }) {
                    total += round.tokens[i].value
                    withAnimation(.spring()) { round.tokens[i].number = total }
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
            if hasAct { phase = .watch; DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { autoMove() } }
            else { autoCount() }
        } else {
            if n == round.answer { land() }
            else { SFX.wrong(); mood = .oops; DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { mood = .idle } }
        }
    }

    private func land() {
        total = round.answer
        withAnimation(.spring()) { phase = .sentence }
        let right = guess == nil || guess == round.answer
        mood = right ? .cheer : .happy
        confetti = right
        SFX.correct()
    }

    private func nextRound() {
        if roundIndex + 1 < rounds { roundIndex += 1; newRound() }
        else { SFX.win(); onComplete() }
    }

    private static func choices(for a: Int) -> [Int] {
        var set: Set<Int> = [a]
        var tries = 0
        while set.count < 3 && tries < 30 {
            tries += 1
            let d = [-2, -1, 1, 2, 10, -10].randomElement()!
            if a + d >= 0 && (abs(d) < 10 || a >= 20) { set.insert(a + d) }
        }
        while set.count < 3 { set.insert(a + set.count) }
        return Array(set).shuffled()
    }
}

private struct ZoneKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - What each game acts out

enum ActScripts {
    typealias Round = ActOutPlayer.Round
    typealias Token = ActOutPlayer.Token

    static let blue = Color(red: 0.40, green: 0.70, blue: 1.0)
    static let orange = Color(red: 1.0, green: 0.62, blue: 0.25)
    static let green = Theme.green
    static let white = Color.white.opacity(0.85)

    private static let scenes: [(String, String, String)] = [
        ("🦆", "ducks", "on the pond"), ("🐔", "hens", "in the yard"), ("🐷", "pigs", "in the mud"),
        ("🐐", "goats", "on the hill"), ("🐸", "frogs", "on the log"), ("🐝", "bees", "at the hive"),
        ("🐑", "sheep", "in the field"), ("🐰", "bunnies", "in the garden"), ("🐥", "chicks", "by the barn"),
        ("🐄", "cows", "in the barn"), ("🐴", "horses", "by the fence"), ("🐟", "fish", "in the pond")
    ]
    private static var lastAnswer = -1

    private static func tokens(_ n: Int, _ emoji: String, value: Int = 1, place: Token.Place = .scene,
                               startID: Int = 0, countable: Bool = true, row: Int = 0) -> [Token] {
        (0..<max(0, n)).map { Token(id: startID + $0, value: value, emoji: emoji, place: place, countable: countable,
                                    tag: value > 1 ? "\(value)" : nil, row: row) }
    }

    static func round(for game: NumberGame) -> Round {
        for _ in 0..<12 {
            let r = make(game)
            if r.answer != lastAnswer { lastAnswer = r.answer; return r }
        }
        return make(game)
    }

    private static func make(_ game: NumberGame) -> Round {
        let (e, n, p) = scenes.randomElement()!
        var r = Round(); r.emoji = e; r.name = n; r.place = p

        func takeAway(start: Int, gone: Int) {
            r.tokens = tokens(start, e)
            r.leaving = gone; r.answer = start - gone
            r.actLine = "\(start) \(n) \(p). \(gone) go away. Drag the \(gone) that leave to the path! \(e)"
            r.predictLine = "\(start) \(n). \(gone) are going to go away. How many will be left?"
            r.countLine = "How many are left? Touch each one to count! 👆"
            r.words = "\(start) \(n), \(gone) went away, \(start - gone) are left."
            r.equation = [("\(start)", blue), ("−", white), ("\(gone)", orange), ("=", white), ("\(start - gone)", green)]
        }
        func add(start: Int, more: Int, countOn: Bool = false) {
            r.tokens = tokens(start, e, countable: !countOn) + tokens(more, e, place: .waiting, startID: start)
            if countOn { r.tokens[start - 1].tag = "\(start)"; r.countFrom = start }
            r.arriving = more; r.answer = start + more
            r.actLine = "\(start) \(n) \(p). \(more) more come! Drag each one in from the fence. \(e)"
            r.predictLine = "\(start) \(n). \(more) more are coming. How many will there be in all?"
            r.countLine = countOn ? "We already have \(start). Count ON from \(start): touch each new one! 👆"
                                  : "How many in all now? Touch each one to count! 👆"
            r.words = "\(start) \(n) and \(more) more. \(start + more) \(n) in all."
            r.equation = [("\(start)", blue), ("+", white), ("\(more)", orange), ("=", white), ("\(start + more)", green)]
        }
        func fillTo(start: Int, target: Int, subtractionSentence: Bool = false) {
            let more = target - start
            r.tokens = tokens(start, e, countable: false) + tokens(more, e, place: .waiting, startID: start)
            r.arriving = more; r.answer = more
            r.actLine = "\(start) \(n) \(p). More come until there are \(target)! Drag them in. \(e)"
            r.predictLine = "\(start) \(n). More are coming until there are \(target). How many will come?"
            r.countLine = "How many came? Touch each new one to count! 👆"
            if subtractionSentence {
                r.words = "\(target) take away \(start) is \(more), because \(start) and \(more) make \(target)."
                r.equation = [("\(target)", blue), ("−", white), ("\(start)", orange), ("=", white), ("\(more)", green)]
            } else {
                r.words = "\(start) \(n) and \(more) more make \(target)."
                r.equation = [("\(start)", blue), ("+", white), ("\(more)", green), ("=", white), ("\(target)", blue)]
            }
        }
        func countAll(_ toks: [Token], answer: Int, words: String, equation: [(String, Color)]) {
            r.tokens = toks; r.answer = answer
            r.predictLine = "How many \(n) do you think are here? Take a guess!"
            r.countLine = "Touch each one to count! 👆"
            r.words = words; r.equation = equation
        }

        switch game {
        case .count:
            let c = Int.random(in: 3...10)
            countAll(tokens(c, e), answer: c, words: "\(c) \(n) \(p)!", equation: [("\(c)", green)])
        case .add:
            add(start: Int.random(in: 1...5), more: Int.random(in: 1...4))
        case .oneMore:
            add(start: Int.random(in: 2...8), more: 1)
        case .doubles:
            let a = Int.random(in: 1...5); add(start: a, more: a)
            r.words = "\(a) \(n) and \(a) more. Double \(a) is \(2 * a)!"
        case .doublesPlusOne:
            let a = Int.random(in: 1...4); add(start: a, more: a + 1)
        case .countOn:
            add(start: Int.random(in: 5...9), more: Int.random(in: 1...4), countOn: true)
        case .teen:
            let ones = Int.random(in: 1...9)
            r.tokens = tokens(1, "🧺", value: 10) + tokens(ones, e, place: .waiting, startID: 1)
            r.arriving = ones; r.answer = 10 + ones
            r.actLine = "A crate of 10 \(n), and \(ones) more come! Drag them in. \(e)"
            r.predictLine = "A crate of 10 and \(ones) more. How many in all?"
            r.countLine = "Touch the crate first (that's 10!), then count on. 👆"
            r.words = "10 and \(ones) more is \(10 + ones)."
            r.equation = [("10", blue), ("+", white), ("\(ones)", orange), ("=", white), ("\(10 + ones)", green)]
        case .turnAround:
            let a = Int.random(in: 1...5), b = Int.random(in: 1...5); add(start: a, more: b)
            r.words = "\(a) and \(b) is \(a + b). Turn it around: \(b) and \(a) is \(a + b) too!"
            r.equation = [("\(a)+\(b)", blue), ("=", white), ("\(b)+\(a)", orange), ("=", white), ("\(a + b)", green)]
        case .addThree:
            let a = Int.random(in: 1...3), b = Int.random(in: 1...3), c = Int.random(in: 1...3)
            add(start: a, more: b + c)
            r.actLine = "\(a) \(n) \(p). \(b) come, then \(c) more! Drag them all in. \(e)"
            r.words = "\(a) and \(b) and \(c) more. \(a + b + c) in all."
            r.equation = [("\(a)", blue), ("+", white), ("\(b)", orange), ("+", white), ("\(c)", orange), ("=", white), ("\(a + b + c)", green)]
        case .takeAway:
            let s = Int.random(in: 3...7); takeAway(start: s, gone: Int.random(in: 1...(s - 1)))
        case .oneLess:
            takeAway(start: Int.random(in: 2...8), gone: 1)
        case .makeTen:
            fillTo(start: Int.random(in: 3...9), target: 10)
            r.words = "\(10 - r.answer) and \(r.answer) make 10!"
        case .missingAddend:
            let a = Int.random(in: 2...6); fillTo(start: a, target: a + Int.random(in: 1...4))
        case .thinkAddition:
            let a = Int.random(in: 5...9); fillTo(start: a, target: a + Int.random(in: 1...4), subtractionSentence: true)
        case .howManyMore:
            let top = Int.random(in: 3...7), bottom = Int.random(in: 1...(top - 1))
            let (e2, n2, _) = scenes.filter { $0.0 != e }.randomElement()!
            var toks = tokens(top, e, row: 0) + tokens(bottom, e2, startID: top, countable: false, row: 1)
            for i in 0..<bottom { toks[i].countable = false }      // the matched ones
            r.tokens = toks; r.compare = true; r.answer = top - bottom
            r.predictLine = "\(top) \(n) and \(bottom) \(n2). How many more \(n) than \(n2)?"
            r.countLine = "Every \(n2) has a \(n) partner above it. Touch the \(n) with NO partner! 👆"
            r.words = "\(top) \(n), \(bottom) \(n2). \(top - bottom) more \(n)."
            r.equation = [("\(top)", blue), ("−", white), ("\(bottom)", orange), ("=", white), ("\(top - bottom)", green)]
        case .skipTwos, .skipFives, .skipTens:
            let k = game == .skipTwos ? 2 : (game == .skipFives ? 5 : 10)
            let g = Int.random(in: 2...(k == 2 ? 6 : 5))
            let icon = k == 10 ? "🧺" : (k == 5 ? "🖐️" : "👟")
            let seq = (1...g).map { "\($0 * k)" }.joined(separator: ", ")
            countAll(tokens(g, icon, value: k), answer: g * k, words: "Count by \(k)s: \(seq)!",
                     equation: [("\(g)", blue), ("×", white), ("\(k)", orange), ("=", white), ("\(g * k)", green)])
            r.name = k == 10 ? "crates" : (k == 5 ? "hands" : "pairs")
            r.countLine = "Each one is \(k). Touch them and count by \(k)s! 👆"
            r.predictLine = "\(g) groups of \(k). How many is that?"
        case .pennies:
            let c = Int.random(in: 3...10)
            countAll(tokens(c, "🪙"), answer: c, words: "\(c) pennies is \(c) cents!", equation: [("\(c)¢", green)])
            r.name = "pennies"
        case .tensAndOnes:
            let t = Int.random(in: 1...4), o = Int.random(in: 1...9)
            countAll(tokens(t, "🧺", value: 10) + tokens(o, e, startID: t), answer: t * 10 + o,
                     words: "\(t) crates of 10 and \(o) more \(n). \(t * 10 + o)!",
                     equation: [("\(t * 10)", blue), ("+", white), ("\(o)", orange), ("=", white), ("\(t * 10 + o)", green)])
            r.countLine = "Crates first: 10, 20... then the loose ones. Touch each! 👆"
        case .addTensOnes:
            let t = Int.random(in: 1...3), o = Int.random(in: 1...4), b = Int.random(in: 1...4)
            let start = t * 10 + o
            r.tokens = tokens(t, "🧺", value: 10) + tokens(o, e, startID: t) + tokens(b, e, place: .waiting, startID: t + o)
            r.arriving = b; r.answer = start + b
            r.actLine = "\(start) \(n): \(t) crates and \(o) loose. \(b) more come! Drag them in. \(e)"
            r.predictLine = "\(start) \(n) and \(b) more. How many in all?"
            r.countLine = "Crates first: 10, 20... then every loose one. Touch each! 👆"
            r.words = "\(start) and \(b) more is \(start + b)."
            r.equation = [("\(start)", blue), ("+", white), ("\(b)", orange), ("=", white), ("\(start + b)", green)]
        case .tenMoreLess:
            let t = Int.random(in: 1...3), o = Int.random(in: 1...6), start = t * 10 + o
            if Bool.random() {
                r.tokens = tokens(t, "🧺", value: 10) + tokens(o, e, startID: t) + tokens(1, "🧺", value: 10, place: .waiting, startID: t + o)
                r.arriving = 1; r.answer = start + 10
                r.actLine = "\(start) \(n). A whole crate of 10 more comes! Drag it in. 🧺"
                r.predictLine = "\(start) \(n) and 10 more. How many?"
                r.words = "\(start) and 10 more is \(start + 10)."
                r.equation = [("\(start)", blue), ("+", white), ("10", orange), ("=", white), ("\(start + 10)", green)]
            } else {
                r.tokens = tokens(t, "🧺", value: 10) + tokens(o, e, startID: t)
                r.leaving = 1; r.leaveValue = 10; r.answer = start - 10
                r.actLine = "\(start) \(n). A whole crate of 10 goes away! Drag a crate to the path. 🧺"
                r.predictLine = "\(start) \(n), and 10 go away. How many are left?"
                r.words = "\(start) take away 10 is \(start - 10)."
                r.equation = [("\(start)", blue), ("−", white), ("10", orange), ("=", white), ("\(start - 10)", green)]
            }
            r.countLine = "Crates first: 10, 20... then the loose ones. Touch each! 👆"
        case .numberBefore:
            let top = Int.random(in: 5...10), target = Int.random(in: 2...top)
            var toks = tokens(top, e, countable: false)
            for i in 0..<top { toks[i].tag = "\(i + 1)" }
            toks[target - 2].countable = true; toks[target - 2].value = target - 1
            r.tokens = toks; r.pick = true; r.answer = target - 1
            r.predictLine = "The \(n) are in a line, 1 to \(top). What number comes just before \(target)?"
            r.countLine = "Find number \(target). Touch the one just BEFORE it! 👆"
            r.words = "\(target - 1) comes just before \(target)."
            r.equation = [("\(target - 1)", green), ("then", white), ("\(target)", blue)]
        }
        return r
    }
}
