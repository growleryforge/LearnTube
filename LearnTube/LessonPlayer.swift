import SwiftUI
import UIKit

/// Hosts whichever interactive engine a lesson needs and reports completion.
/// Every game opens with a short teaching card so it TEACHES the idea first,
/// then lets Gabriel practice it, instead of jumping straight to questions.
struct LessonPlayerView: View {
    let skill: Skill
    let onComplete: () -> Void
    @State private var showIntro = true
    var body: some View {
        if showIntro {
            LessonIntroCard(skill: skill) {
                withAnimation(.easeInOut(duration: 0.2)) { showIntro = false }
            }
        } else {
            LessonRunner(lesson: skill.lesson, accent: skill.subject.color, onComplete: onComplete)
        }
    }
}

/// A friendly "here's the idea" screen shown before each game.
struct LessonIntroCard: View {
    let skill: Skill
    let onStart: () -> Void

    private var teach: String { Curriculum.teachNotes[skill.id] ?? skill.activity }

    var body: some View {
        ZStack {
            LinearGradient(colors: [skill.subject.color, skill.subject.color.opacity(0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 18) {
                Mascot(mood: .happy, size: 92).padding(.top, 26)
                Text(skill.title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Text(teach)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 16).padding(.horizontal, 18)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    .padding(.horizontal, 18)
                Spacer(minLength: 10)
                Button(action: onStart) {
                    Text("Let's play!  ▶")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Theme.green)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Theme.green.opacity(0.4), radius: 6, y: 3)
                }
                .padding(.horizontal, 18).padding(.bottom, 22)
            }
        }
        .frame(minHeight: 540)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

/// Plays any Lesson value with a given accent color. Reusable from Story Mode.
struct LessonRunner: View {
    let lesson: Lesson
    let accent: Color
    let onComplete: () -> Void

    var body: some View {
        Group {
            switch lesson {
            case .quiz(let qs):
                QuizPlayer(questions: qs, accent: accent, onComplete: onComplete)
            case .count(let target, let symbol, let prompt):
                CountPlayer(target: target, symbol: symbol, prompt: prompt, accent: accent, onComplete: onComplete)
            case .order(let prompt, let items):
                OrderPlayer(prompt: prompt, items: items, accent: accent, onComplete: onComplete)
            case .match(let prompt, let pairs):
                MatchPlayer(prompt: prompt, pairs: pairs, accent: accent, onComplete: onComplete)
            case .numberPad(let problems):
                NumberPadPlayer(problems: problems, accent: accent, onComplete: onComplete)
            case .faceMatch(let exprs, let perRound):
                DragMatchPlayer(exprs: exprs, perRound: perRound, accent: accent, onComplete: onComplete)
            case .story(let id):
                StoryPlayer(storyId: id, accent: accent, onComplete: onComplete)
            case .trace(let prompt, let items):
                TracePlayer(prompt: prompt, items: items, accent: accent, onComplete: onComplete)
            }
        }
    }
}

// MARK: - Shared building blocks

let tileColors: [Color] = [
    Color(red: 0.30, green: 0.58, blue: 0.92),
    Color(red: 0.95, green: 0.55, blue: 0.20),
    Color(red: 0.62, green: 0.40, blue: 0.85),
    Color(red: 0.18, green: 0.70, blue: 0.64),
    Color(red: 0.92, green: 0.40, blue: 0.55)
]
func tileColor(_ i: Int) -> Color { tileColors[i % tileColors.count] }

let shapeWords: Set<String> = ["circle","square","triangle","rectangle","sphere","cube","cylinder","cone"]
func isShape(_ s: String) -> Bool { shapeWords.contains(s.lowercased()) }

struct Wiggle: ViewModifier {
    var active: Bool
    func body(content: Content) -> some View {
        content.offset(x: active ? -7 : 0)
            .animation(active ? .default.repeatCount(3, autoreverses: true).speed(7) : .default, value: active)
    }
}
extension View { func wiggle(_ a: Bool) -> some View { modifier(Wiggle(active: a)) } }

/// The bright "stage" every game plays on: scene + mascot host + speech bubble.
struct GameStage<Content: View>: View {
    var mood: MascotMood
    var prompt: String
    var confetti: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            PlayScene {
                VStack(spacing: 14) {
                    Mascot(mood: mood, size: 92).padding(.top, 16)
                    // Leo cheers out loud the moment he gets one right.
                    SpeechBubble(text: mood == .cheer ? "🎉 Great job!" : prompt)
                    content
                    Spacer(minLength: 18)
                }
                .padding(.horizontal, 14)
            }
            if confetti { Confetti() }
        }
        .frame(minHeight: 540)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct SpeechBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(.center)
            .padding(.vertical, 12).padding(.horizontal, 18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            .padding(.horizontal, 10)
    }
}

extension Theme { static let ink = Color(red: 0.16, green: 0.20, blue: 0.22) }

// MARK: - Quiz

struct QuizPlayer: View {
    let questions: [Question]
    let accent: Color
    let onComplete: () -> Void

    @State private var index = 0
    @State private var options: [Choice] = []
    @State private var wrongId: UUID?
    @State private var correctId: UUID?
    @State private var mood: MascotMood = .idle
    // Slow-down: hold answers back so he reads first, and pause after a miss.
    @State private var ready = false
    @State private var locked = false
    @State private var hint = ""
    // Anti-mash: a wrong tile is disabled once tapped (can't be re-tapped), and
    // after the 2nd miss on a question the answer is revealed and taught, so
    // guessing your way through stops working — gently, with no scolding.
    @State private var disabled: Set<UUID> = []
    @State private var revealed = false
    @State private var missCount = 0

    /// An illustration for the question — but NEVER one that is itself an answer
    /// choice, or we'd be handing him the answer (e.g. "Which face is SAD?" must
    /// not show the sad face above the choices).
    private var promptPic: String? {
        let q = questions[index]
        // If the ANSWERS are pictures (emoji or shapes), never illustrate the
        // question — any picture up top would be the answer or a decoy. Only
        // show a scene-setting picture when the choices are words/letters/numbers
        // (e.g. "🐶 Dog starts with... D / B / M").
        let answersArePictures = q.options.contains { opt in
            isShape(opt.label) || !opt.label.contains { $0.isLetter || $0.isNumber }
        }
        if answersArePictures { return nil }
        guard let pic = EmojiArt.emoji(for: q.prompt) else { return nil }
        for opt in q.options {
            if opt.label == pic { return nil }
            if EmojiArt.emoji(for: opt.label) == pic { return nil }
        }
        return pic
    }

    var body: some View {
        GameStage(mood: mood, prompt: questions[index].prompt, confetti: correctId != nil) {
            VStack(spacing: 12) {
                if let pic = promptPic {
                    EmojiView(emoji: pic, size: 80, tint: Theme.green)
                        .frame(height: 84)
                        .scaleEffect(correctId != nil ? 1.15 : (ready ? 1 : 1.12))
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: ready)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: correctId)
                }
                ProgressDots(total: questions.count, done: index, accent: accent)
                Text(hint.isEmpty ? (ready ? " " : "👀 Read the question…") : hint)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(hint.isEmpty ? .white.opacity(0.7) : Theme.gold)
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { i, choice in
                        Button { tap(choice) } label: { tile(choice, i) }
                            .wiggle(wrongId == choice.id)
                    }
                }
                .opacity(ready ? 1 : 0.3)
                .allowsHitTesting(ready && !locked)
                .animation(.easeOut(duration: 0.25), value: ready)
            }
        }
        .onAppear(perform: load)
    }

    @ViewBuilder private func tile(_ c: Choice, _ i: Int) -> some View {
        let base = tileColor(i)
        let showCorrect = correctId == c.id || (revealed && c.isCorrect)
        let isOut = disabled.contains(c.id) && !showCorrect
        let bg: Color = showCorrect ? Theme.green : (wrongId == c.id ? Theme.red : (isOut ? Color.gray.opacity(0.45) : base))
        // A tile is a shape, an emoji answer, OR a word — never a word wearing
        // its own picture. Illustrating "cat" with a 🐱 lets him pick the picture
        // instead of blending c-a-t; naming a "circle" hands him the shape. So:
        // words show as words (he must read), emoji answers show as the emoji.
        let isWord = c.label.contains { $0.isLetter || $0.isNumber }
        let showGlyph = isShape(c.label)
        let showEmoji = !isWord && !showGlyph
        let hasArt = showGlyph || showEmoji
        VStack(spacing: 6) {
            if showGlyph {
                ShapeGlyph(name: c.label, color: .white).frame(width: 64, height: 64).padding(.vertical, 8)
            } else if showEmoji {
                EmojiView(emoji: c.label, size: 48, tint: .white).frame(height: 52).padding(.vertical, 6)
            } else {
                Text(c.label)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity).padding(.vertical, hasArt ? 14 : 18)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: bg.opacity(0.4), radius: 5, y: 3)
        .opacity(isOut ? 0.5 : 1)
        .scaleEffect(revealed && c.isCorrect ? 1.06 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: revealed)
    }

    private func load() {
        options = questions[index].options.shuffled()
        ready = false; locked = false; hint = ""
        disabled = []; revealed = false; missCount = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { ready = true }
    }

    private func tap(_ c: Choice) {
        // Ignore taps on the initial read-pause, mid-animation, or on a tile
        // that's already been ruled out.
        guard ready, !locked, correctId == nil, !disabled.contains(c.id) else { return }
        if c.isCorrect {
            correctId = c.id; mood = .cheer; SFX.correct()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if index + 1 < questions.count {
                    index += 1; correctId = nil; wrongId = nil; mood = .idle; load()
                } else { SFX.win(); onComplete() }
            }
        } else {
            // Rule this wrong choice out for good, so re-tapping it does nothing.
            wrongId = c.id; disabled.insert(c.id); missCount += 1
            mood = .oops; SFX.wrong()   // SFX.wrong also arms the app-wide pause
            GameStats.recordMiss(prompt: questions[index].prompt, tapped: c.label,
                                 correct: questions[index].options.first(where: { $0.isCorrect })?.label ?? "")
            locked = true
            if missCount >= 2 {
                // Second miss: stop testing, start teaching. Reveal the answer,
                // grey out the rest, and invite him to tap the green one himself.
                revealed = true
                for opt in options where !opt.isCorrect { disabled.insert(opt.id) }
                hint = "Here it is! Tap the green one 💚"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    wrongId = nil; mood = .happy; locked = false
                }
            } else {
                hint = ["Look again 👀", "Read it and try 👀"].randomElement()!
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    wrongId = nil; mood = .idle; locked = false
                }
            }
        }
    }
}

// MARK: - Count (tap eggs, they hatch)

struct CountPlayer: View {
    let target: Int
    let symbol: String
    let prompt: String
    let accent: Color
    let onComplete: () -> Void

    // Objects tapped, IN COUNT ORDER — so each gets its number (1, 2, 3...) as
    // he touches it. That one-object-per-number touch is the actual skill.
    @State private var order: [Int] = []
    @State private var round = 0
    @State private var mood: MascotMood = .idle
    @State private var showTotal = false          // brief "That's 3!" naming the total
    private let cols = [GridItem(.adaptive(minimum: 62), spacing: 12)]

    // One board per game — short and finishable. The teaching comes from the
    // numbered objects, the number line, and naming the total, not from length.
    private var targets: [Int] { [max(1, target)] }
    private var current: Int { targets[min(round, targets.count - 1)] }
    private var count: Int { order.count }

    var body: some View {
        GameStage(mood: mood,
                  prompt: showTotal
                    ? "That's \(current)!  \(Self.word(current).capitalized) \(symbol)"
                    : "Tap and count each \(symbol) — say the number out loud!",
                  confetti: showTotal) {
            VStack(spacing: 16) {
                // The running count, big.
                Text("\(count)")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: accent, radius: 0, x: 2, y: 2)
                    .contentTransition(.numericText())
                // Number line: numerals light up as he counts, tying the amount
                // to the written number.
                if current <= 10 {
                    HStack(spacing: 7) {
                        ForEach(1...current, id: \.self) { n in
                            Text("\(n)")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .frame(width: 32, height: 32)
                                .background(count >= n ? Theme.green : Theme.surfaceHi)
                                .foregroundStyle(.white).clipShape(Circle())
                        }
                    }
                }
                // The objects — each shows ITS number the moment he taps it.
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(0..<current, id: \.self) { i in
                        let pos = order.firstIndex(of: i)
                        Button { tap(i) } label: {
                            ZStack(alignment: .topTrailing) {
                                EmojiView(emoji: symbol, size: 42)
                                    .frame(width: 58, height: 60)
                                    .scaleEffect(pos != nil ? 1.12 : 1)
                                    .opacity(pos != nil ? 1 : 0.85)
                                if let p = pos {
                                    Text("\(p + 1)")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(.white).frame(width: 24, height: 24)
                                        .background(Theme.green).clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .disabled(showTotal)
                    }
                }
            }
        }
        .onAppear(perform: newRound)
    }

    private func newRound() { order = []; showTotal = false; mood = .idle }

    private func tap(_ i: Int) {
        guard !showTotal, !order.contains(i) else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { order.append(i) }
        mood = .happy; SFX.tap()
        if order.count == current {
            mood = .cheer; showTotal = true; SFX.win()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if round + 1 < targets.count { round += 1; newRound() } else { onComplete() }
            }
        }
    }

    static func word(_ n: Int) -> String {
        let w = ["zero","one","two","three","four","five","six","seven","eight","nine","ten",
                 "eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen","twenty"]
        return (0..<w.count).contains(n) ? w[n] : "\(n)"
    }
}

// MARK: - Order

struct OrderPlayer: View {
    let prompt: String
    let items: [String]
    let accent: Color
    let onComplete: () -> Void

    @State private var pool: [String] = []
    @State private var placed: [String] = []
    @State private var wrong: String?
    @State private var mood: MascotMood = .idle
    private let cols = [GridItem(.adaptive(minimum: 92), spacing: 10)]

    var body: some View {
        GameStage(mood: mood, prompt: prompt, confetti: placed.count == items.count) {
            VStack(spacing: 12) {
                FlowChips(items: placed, accent: Theme.green, filled: true).frame(minHeight: 40)
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(Array(pool.enumerated()), id: \.offset) { i, item in
                        Button { tap(item) } label: {
                            Text(item)
                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(wrong == item ? Theme.red : tileColor(i))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .wiggle(wrong == item)
                    }
                }
            }
        }
        .onAppear { pool = items.shuffled() }
    }

    private func tap(_ item: String) {
        let next = items[placed.count]
        if item == next {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                placed.append(item); pool.removeAll { $0 == item }
            }
            mood = .happy; SFX.tap()
            if placed.count == items.count {
                mood = .cheer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { SFX.win(); onComplete() }
            }
        } else {
            wrong = item; mood = .oops; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrong = nil; mood = .idle }
        }
    }
}

struct FlowChips: View {
    let items: [String]
    let accent: Color
    var filled: Bool = false
    private let cols = [GridItem(.adaptive(minimum: 84), spacing: 8)]
    var body: some View {
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, t in
                Text(t)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(filled ? accent : .white.opacity(0.7))
                    .foregroundStyle(.white).clipShape(Capsule())
            }
        }
    }
}

// MARK: - Match

struct MatchPlayer: View {
    let prompt: String
    let pairs: [Lesson.Pair]
    let accent: Color
    let onComplete: () -> Void

    @State private var lefts: [String] = []
    @State private var rights: [String] = []
    @State private var selectedLeft: String?
    @State private var matched: Set<String> = []
    @State private var wrongRight: String?
    @State private var mood: MascotMood = .idle
    // Teach after the 2nd wrong try on the SAME picked item: glow its correct
    // partner green so he learns the pairing instead of guessing down the list.
    @State private var wrongForLeft: [String: Int] = [:]
    @State private var hintRight: String?

    var body: some View {
        GameStage(mood: mood, prompt: prompt, confetti: matched.count == pairs.count * 2) {
            HStack(alignment: .top, spacing: 14) {
                column(lefts, isLeft: true)
                column(rights, isLeft: false)
            }
        }
        .onAppear {
            // Shuffle both columns, then keep re-rolling the answers until NONE
            // of them sits on the same row as its own animal. Otherwise the pairs
            // line up straight across (and share a row color) and there's nothing
            // left to actually solve — he just matches top-to-top.
            let L = pairs.map { $0.left }.shuffled()
            let partners = L.map { l in pairs.first { $0.left == l }?.right ?? "" }
            var R = pairs.map { $0.right }.shuffled()
            var tries = 0
            while tries < 40 && zip(R, partners).contains(where: { $0 == $1 }) {
                R.shuffle(); tries += 1
            }
            lefts = L
            rights = R
        }
    }

    private func column(_ items: [String], isLeft: Bool) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.element) { i, item in
                let isMatched = matched.contains(item)
                let isSel = isLeft && selectedLeft == item
                Button { tap(item, isLeft: isLeft) } label: {
                    Text(item)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 38).padding(.vertical, 10)
                        .background(bg(isMatched: isMatched, isSel: isSel, item: item, i: i, isLeft: isLeft))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.green, lineWidth: (!isLeft && hintRight == item && !isMatched) ? 4 : 0)
                    .allowsHitTesting(false))   // ring must never swallow taps
                .opacity(isMatched ? 0.5 : 1)
                .wiggle(wrongRight == item)
                .disabled(isMatched)
            }
        }
    }

    private func bg(isMatched: Bool, isSel: Bool, item: String, i: Int, isLeft: Bool) -> Color {
        if isMatched { return Theme.green }
        if isSel { return Theme.ink }
        if wrongRight == item { return Theme.red }
        // Left side stays colorful so he can track the animal he picked; the
        // answers are all one neutral color, so matching colors can't stand in
        // for reading the word.
        return isLeft ? tileColor(i) : Theme.surfaceHi
    }

    private func tap(_ item: String, isLeft: Bool) {
        if isLeft { selectedLeft = item; hintRight = nil; SFX.tap(); return }
        guard let l = selectedLeft else { return }
        let partner = pairs.first { $0.left == l }?.right
        if partner == item {
            withAnimation { matched.insert(l); matched.insert(item) }
            selectedLeft = nil; hintRight = nil; wrongForLeft[l] = 0; mood = .happy; SFX.correct()
            if matched.count == pairs.count * 2 {
                mood = .cheer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { SFX.win(); onComplete() }
            }
        } else {
            wrongRight = item; mood = .oops; SFX.wrong()
            // Second miss on this pick: glow the correct home so he learns it.
            wrongForLeft[l, default: 0] += 1
            if wrongForLeft[l, default: 0] >= 2 { withAnimation { hintRight = partner } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongRight = nil; mood = .idle }
        }
    }
}

// MARK: - Number pad

struct NumberPadPlayer: View {
    let problems: [NumberProblem]
    let accent: Color
    let onComplete: () -> Void

    @State private var index = 0
    @State private var entry = ""
    @State private var state: AnswerState = .typing
    @State private var mood: MascotMood = .idle
    // Anti-mash: after the 2nd wrong entry on a problem, we stop testing and
    // teach — show the answer so he types it and learns, instead of punching
    // numbers forever.
    @State private var wrongThisQ = 0
    @State private var revealed = false
    // Shuffle the problems each play so counting games can't be ridden as a
    // pattern (2, 3, 4, 5...) — he has to actually count each group.
    @State private var deck: [NumberProblem] = []
    private var items: [NumberProblem] { deck.isEmpty ? problems : deck }
    enum AnswerState { case typing, right, wrong }

    var body: some View {
        GameStage(mood: mood, prompt: items[index].prompt, confetti: state == .right) {
            VStack(spacing: 12) {
                ProgressDots(total: items.count, done: index, accent: accent)
                // Objects to count for the answer (he can't guess a number pad).
                if !items[index].visual.isEmpty {
                    EmojiCountView(tokens: items[index].visual)
                }
                Text(entry.isEmpty ? "?" : entry)
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundStyle(.white).frame(height: 60)
                    .shadow(color: color, radius: 0, x: 2, y: 2)
                    .wiggle(state == .wrong)
                // Teach after the 2nd miss: show the answer so he types it.
                if revealed {
                    Text("The answer is \(items[index].answer) — tap it! 💚")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.green)
                        .multilineTextAlignment(.center)
                }
                pad
            }
        }
        .onAppear { if deck.isEmpty { deck = problems.shuffled() } }
    }

    private var color: Color {
        switch state { case .right: return Theme.green; case .wrong: return Theme.red; default: return accent }
    }

    private var pad: some View {
        VStack(spacing: 10) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 10) { ForEach(row, id: \.self) { n in key("\(n)") { press("\(n)") } } }
            }
            HStack(spacing: 10) {
                key("Clear") { entry = "" }
                key("0") { press("0") }
                key("Go", accentBtn: true) { submit() }
            }
        }
    }

    private func key(_ label: String, accentBtn: Bool = false, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: label.count > 1 ? 18 : 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(accentBtn ? Theme.green : tileColor(0).opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func press(_ d: String) {
        guard state == .typing, entry.count < 3 else { return }
        entry += d; SFX.tap()
    }

    private func submit() {
        guard let v = Int(entry) else { return }
        if v == items[index].answer {
            state = .right; mood = .cheer; SFX.correct()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if index + 1 < items.count {
                    index += 1; entry = ""; state = .typing; mood = .idle
                    wrongThisQ = 0; revealed = false      // fresh problem
                } else { SFX.win(); onComplete() }
            }
        } else {
            wrongThisQ += 1
            state = .wrong; mood = .oops; SFX.wrong()
            // Second miss: reveal and teach the answer so he stops guessing.
            if wrongThisQ >= 2 { revealed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { entry = ""; state = .typing; mood = .idle }
        }
    }
}

// MARK: - Drag-to-match (faces -> feeling words)

struct DragMatchPlayer: View {
    let exprs: [FaceExpr]
    let perRound: Int
    let accent: Color
    let onComplete: () -> Void

    @State private var pool: [FaceExpr] = []
    private var rounds: [[FaceExpr]] {
        stride(from: 0, to: pool.count, by: perRound).map {
            Array(pool[$0..<min($0 + perRound, pool.count)])
        }
    }

    @State private var roundIndex = 0
    @State private var faces: [FaceExpr] = []
    @State private var words: [FaceExpr] = []
    @State private var matched: Set<FaceExpr> = []
    @State private var wrongWord: FaceExpr?
    @State private var selectedFace: FaceExpr?
    @State private var mood: MascotMood = .idle
    // Teach after the 2nd wrong try on the picked face: glow the right feeling.
    @State private var wrongForFace: [FaceExpr: Int] = [:]
    @State private var hintWord: FaceExpr?

    var body: some View {
        GameStage(mood: mood,
                  prompt: selectedFace == nil ? "Tap a face, then tap its feeling!" : "Now tap its feeling!",
                  confetti: !faces.isEmpty && matched.count == faces.count) {
            VStack(spacing: 16) {
                // tap a face to pick it
                HStack(spacing: 10) {
                    ForEach(faces, id: \.self) { e in
                        let done = matched.contains(e)
                        Button { if !done { selectedFace = e; hintWord = nil; SFX.tap() } } label: {
                            Text(e.emoji).font(.system(size: 48)).frame(width: 58, height: 58)
                                .opacity(done ? 0.18 : 1)
                                .scaleEffect(selectedFace == e ? 1.18 : (done ? 0.8 : 1))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.red, lineWidth: selectedFace == e ? 4 : 0))
                        }
                        .disabled(done)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.white.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selectedFace)

                // tap the matching feeling
                VStack(spacing: 10) {
                    ForEach(words, id: \.self) { w in wordRow(w) }
                }
            }
        }
        .onAppear {
            // Two short rounds, not three — fewer feelings to juggle at once.
            if pool.isEmpty { pool = Array(exprs.shuffled().prefix(perRound * 2)) }
            loadRound()
        }
    }

    private func wordRow(_ w: FaceExpr) -> some View {
        let done = matched.contains(w)
        return Button { tapWord(w) } label: {
            HStack(spacing: 12) {
                if done {
                    Text(w.emoji).font(.system(size: 30)).frame(width: 38, height: 38)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 26)).foregroundStyle(.white.opacity(0.9)).frame(width: 38, height: 38)
                }
                Text(w.word)
                    .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer()
                if done { Image(systemName: "checkmark.circle.fill").foregroundStyle(.white).font(.system(size: 22)) }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(done ? Theme.green : (wrongWord == w ? Theme.red : tileColor(words.firstIndex(of: w) ?? 0)))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.green, lineWidth: (hintWord == w && !done) ? 4 : 0))
        }
        .disabled(done)
        .wiggle(wrongWord == w)
    }

    private func tapWord(_ w: FaceExpr) {
        guard let sel = selectedFace, !matched.contains(w) else { return }
        if sel == w {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { _ = matched.insert(w) }
            selectedFace = nil; hintWord = nil; wrongForFace[w] = 0; mood = .happy; SFX.correct()
            if matched.count == faces.count {
                mood = .cheer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    if roundIndex + 1 < rounds.count { roundIndex += 1; loadRound() }
                    else { SFX.win(); onComplete() }
                }
            }
        } else {
            wrongWord = w; mood = .oops; SFX.wrong()
            // Second miss on this face: glow its correct feeling so he learns it.
            wrongForFace[sel, default: 0] += 1
            if wrongForFace[sel, default: 0] >= 2 { withAnimation { hintWord = sel } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongWord = nil; mood = .idle }
        }
    }

    private func loadRound() {
        let r = rounds[roundIndex]
        faces = r.shuffled()
        words = r.shuffled()
        matched = []
        mood = .idle
        hintWord = nil
        wrongForFace = [:]
    }
}

// MARK: - Progress dots

struct ProgressDots: View {
    let total: Int
    let done: Int
    let accent: Color
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i < done ? Theme.green : (i == done ? .white : .white.opacity(0.5)))
                    .frame(width: i == done ? 22 : 10, height: 8)
            }
        }
    }
}
