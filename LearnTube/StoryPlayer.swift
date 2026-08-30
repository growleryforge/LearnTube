import SwiftUI

/// Reads a story page by page, then plays the reading-skill games in sequence.
struct StoryPlayer: View {
    let storyId: String
    let accent: Color
    let onComplete: () -> Void

    enum Mode { case reading, playing }
    @State private var mode: Mode = .reading
    @State private var page = 0
    @State private var game = 0

    private var story: StoryContent? { Stories.story(id: storyId) }

    var body: some View {
        Group {
            if let story {
                // Straight into the activity: a story opens on its first page;
                // a game lesson (no reading pages) drops right into the first
                // game. Reading mode only renders when there are pages, so an
                // empty-page lesson can never index past the end of pages.
                // No "who's reading with you" gate — that note's in Grown-Ups.
                if mode == .reading && !story.pages.isEmpty {
                    reading(story)
                } else {
                    playing(story)
                }
            } else {
                Text("Story not found.").foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { page = 0; game = 0; mode = .reading }
    }

    // MARK: Reading (picture + text fill the window)

    private func reading(_ story: StoryContent) -> some View {
        let p = story.pages[page]
        let isLast = page == story.pages.count - 1
        return GeometryReader { geo in
            VStack(spacing: 12) {
                StorySceneView(scene: p.scene, height: geo.size.height * 0.46)
                Text(p.text)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(story.darkPages ? .white : Theme.ink)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(18)
                    .background(story.darkPages ? Theme.surface : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                HStack(spacing: 6) {
                    ForEach(0..<story.pages.count, id: \.self) { i in
                        Circle().fill(i == page ? accent : Theme.surfaceHi).frame(width: 8, height: 8)
                    }
                }

                HStack(spacing: 10) {
                    if page > 0 {
                        Button { page -= 1 } label: { Image(systemName: "chevron.left") }
                            .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.surface)))
                            .frame(width: 70)
                    }
                    Button {
                        if isLast { mode = .playing; game = 0 } else { page += 1 }
                    } label: {
                        Label(isLast ? "Play the games!" : "Next", systemImage: isLast ? "gamecontroller.fill" : "chevron.right")
                    }
                    .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.redGradient)))
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: Playing the skill games (scrolls if tall)

    private func playing(_ story: StoryContent) -> some View {
        let g = story.games[game]
        return GeometryReader { geo in
        ScrollView {
            VStack(spacing: 12) {
                Group {
                switch g.activity {
                case .quiz(let questions):
                    StoryQuizView(questions: questions, accent: accent, onComplete: nextGame).id(game)
                case .order(let prompt, let steps):
                    StoryOrderView(prompt: prompt, steps: steps, accent: accent, onComplete: nextGame).id(game)
                case .lesson(let lesson):
                    LessonRunner(lesson: lesson, accent: accent, onComplete: nextGame).id(game)
                case .addition(let level):
                    AdditionPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .sortCount(let level):
                    SortCountPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .shapes(let level):
                    ShapesPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .shapeSpot(let level):
                    ShapeSpotPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .letters(let level):
                    LetterDetectivePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .weather(let level):
                    WeatherPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .numbers(let level):
                    NumberDetectivePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .symbols(let level):
                    SymbolPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .helpers(let level):
                    HelperPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .holidays(let level):
                    HolidayPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .familyMembers(let level):
                    FamilyMemberPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .patterns(let level):
                    PatternPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .rhymes(let level):
                    RhymePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .geo(let level):
                    FlatSolidPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .living(let level):
                    LivingThingsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .compare(let level):
                    CompareObjectsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .build(let level):
                    ShapeBuilderPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .critterCount(let level):
                    CritterCountPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .familyAdd(let level):
                    FamilyAddPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .wordProblem(let level):
                    WordProblemPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .pushPull(let level):
                    PushPullPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .needs(let level):
                    NeedsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .position(let level):
                    PositionPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .sight(let level):
                    SightWordsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .numberOrder(let level):
                    NumberOrderPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .animalHomes(let level):
                    AnimalHomesPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .legs(let level):
                    LegsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .coverings(let level):
                    CoveringsPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .eats(let level):
                    EatPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .teen(let level):
                    TeenPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .baby(let level):
                    BabyPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .alive(let level):
                    LivingNotPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .dayNight(let level):
                    DayNightPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .make5(let level):
                    Make5Player(level: level, accent: accent, onComplete: nextGame).id(game)
                case .whichMore(let level):
                    WhichMorePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .egg(let level):
                    EggPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .wild(let level):
                    WildPetPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .make10(let level):
                    Make10Player(level: level, accent: accent, onComplete: nextGame).id(game)
                case .takeAway(let level):
                    TakeAwayPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .doubles(let level):
                    DoublesPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .ordinal(let level):
                    OrdinalPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .beginningSound(let level):
                    BeginningSoundPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .lifeCycle(let level):
                    LifeCyclePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .countTens(let level):
                    TensPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .fastSlow(let level):
                    FastSlowPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .sinkFloat(let level):
                    SinkFloatPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .letterCase(let level):
                    LetterCasePlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .fiveSenses(let level):
                    FiveSensesPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                case .opposites(let level):
                    OppositesPlayer(level: level, accent: accent, onComplete: nextGame).id(game)
                }
                }
                .frame(maxWidth: .infinity, minHeight: geo.size.height - 32, alignment: .center)
                Color.clear.frame(height: 20)
            }
            .padding(.horizontal, 4)
            .frame(minHeight: geo.size.height)
        }
        }
    }

    private func nextGame() {
        if game + 1 < (story?.games.count ?? 0) { game += 1 }
        else { onComplete() }
    }
}

// MARK: - Story quiz (teach, then ask; story picture + emoji answers)

struct StoryQuizView: View {
    let questions: [StoryQuestion]
    let accent: Color
    let onComplete: () -> Void

    @State private var index = 0
    @State private var choices: [StoryChoice] = []
    @State private var chosenPrompt: String = ""
    @State private var correctId: UUID?
    @State private var wrongId: UUID?
    // Slow-down state: hold the answers back until he's had a beat to read the
    // question, pop the question to draw his eye, and pause briefly on a wrong
    // tap so guessing is the slow path and reading is the fast one.
    @State private var ready = false
    @State private var locked = false
    @State private var pulse = false
    @State private var hint = ""
    @State private var missed = 0
    @State private var revealed = false

    private var q: StoryQuestion { questions[index] }

    var body: some View {
        VStack(spacing: 14) {
            ProgressDots(total: questions.count, done: index, accent: Theme.red)
            if q.visual.isEmpty {
                StorySceneView(scene: q.scene, height: 200)
            } else {
                EmojiCountView(tokens: q.visual)
            }

            Text(chosenPrompt)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .scaleEffect(pulse ? 1 : 0.8)
                .animation(.spring(response: 0.45, dampingFraction: 0.55), value: pulse)
            // A gentle nudge while the answers are still held back / after a miss.
            Text(hint.isEmpty ? (ready ? " " : "👀 Read the question…") : hint)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(hint.isEmpty ? .white.opacity(0.65) : Theme.gold)
            VStack(spacing: 12) {
                ForEach(Array(choices.enumerated()), id: \.element.id) { i, choice in
                    Button { tap(choice) } label: { tile(choice, i) }
                        .wiggle(wrongId == choice.id)
                }
            }
            .opacity(ready ? 1 : 0.3)
            .allowsHitTesting(ready && !locked)
            .animation(.easeOut(duration: 0.25), value: ready)
        }
        .onAppear(perform: load)
    }

    private func tile(_ c: StoryChoice, _ i: Int) -> some View {
        let base = tileColor(i)
        let bg: Color = (correctId == c.id || (revealed && c.correct)) ? Theme.green
                        : (wrongId == c.id ? Theme.red : base)
        return HStack(spacing: 12) {
            EmojiView(emoji: c.emoji, size: 34, tint: .white).frame(width: 40)
            Text(c.label)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func load() {
        choices = q.choices.shuffled()
        chosenPrompt = q.prompts.randomElement() ?? q.prompts.first ?? ""
        ready = false; locked = false; hint = ""
        missed = 0; revealed = false
        // Pop the question to draw his eye.
        pulse = false
        DispatchQueue.main.async { pulse = true }
        // Hold the answers back ~1.5s so he actually looks at the question.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { ready = true }
    }

    private func tap(_ c: StoryChoice) {
        guard ready, !locked, correctId == nil else { return }
        if c.correct {
            correctId = c.id; SFX.correct()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if index + 1 < questions.count {
                    index += 1; correctId = nil; wrongId = nil; load()
                } else { SFX.win(); onComplete() }
            }
        } else {
            // Pause after a wrong tap: lock the buttons for a beat with a gentle
            // "look again" (no scolding) so rapid guessing stops working. Then
            // reshuffle so memorizing a spot / tapping the last one left fail too.
            missed += 1
            wrongId = c.id; SFX.wrong()   // SFX.wrong() also logs the miss count for Insights
            GameStats.recordMiss(prompt: chosenPrompt, tapped: c.label,
                                 correct: choices.first(where: { $0.correct })?.label ?? "")
            locked = true
            if missed >= 2 {
                // Second miss: stop testing, start teaching. Show the answer in
                // green (it stays put — no reshuffle) and invite the tap.
                withAnimation { revealed = true }
                hint = "Here it is! Tap the green one 💚"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    wrongId = nil; locked = false
                }
            } else {
                hint = ["Look again 👀", "Try reading it 👀"].randomElement()!
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    wrongId = nil; locked = false; hint = ""
                    let curCorrect = choices.firstIndex(where: { $0.correct })
                    var c = choices.shuffled()
                    var tries = 0
                    while c.firstIndex(where: { $0.correct }) == curCorrect && tries < 16 { c = choices.shuffled(); tries += 1 }
                    withAnimation { choices = c }
                }
            }
        }
    }
}

// MARK: - Story order game (clear "tap in order", numbered slots, uniform emoji boxes)

struct StoryOrderView: View {
    let prompt: String
    let steps: [OrderStep]   // correct order
    let accent: Color
    let onComplete: () -> Void

    @State private var pool: [OrderStep] = []
    @State private var placed: [OrderStep] = []
    @State private var wrongId: UUID?
    private let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    private var hint: String {
        if placed.isEmpty { return "Tap what happened FIRST 👇" }
        if placed.count < steps.count { return "Now tap what happened NEXT 👇" }
        return "You did it! 🎉"
    }

    var body: some View {
        VStack(spacing: 14) {
            StorySceneView(scene: .title, height: 140)
            Text(hint)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)

            // numbered slots show the order so far
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { i in slot(i) }
            }

            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(pool) { step in
                    Button { tap(step) } label: { tile(step) }
                        .wiggle(wrongId == step.id)
                }
            }
        }
        .onAppear { pool = steps.shuffled() }
    }

    private func slot(_ i: Int) -> some View {
        ZStack {
            Circle().fill(i < placed.count ? Theme.green : Theme.surfaceHi)
                .frame(width: 46, height: 46)
            if i < placed.count {
                EmojiView(emoji: placed[i].emoji, size: 24, tint: .white)
            } else {
                Text("\(i + 1)").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        }
    }

    private func tile(_ step: OrderStep) -> some View {
        let idx = steps.firstIndex(of: step) ?? 0
        return VStack(spacing: 6) {
            EmojiView(emoji: step.emoji, size: 30, tint: .white)
            Text(step.label)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
                .lineLimit(3).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity).frame(height: 112)
        .padding(8)
        .background(wrongId == step.id ? Theme.red : tileColor(idx))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tap(_ step: OrderStep) {
        let next = steps[placed.count]
        if step.id == next.id {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                placed.append(step); pool.removeAll { $0.id == step.id }
            }
            SFX.correct()
            if placed.count == steps.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { SFX.win(); onComplete() }
            }
        } else {
            wrongId = step.id; SFX.wrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongId = nil }
        }
    }
}

// MARK: - Emoji count picture (matches the numbers in a math question)

/// Shows a row of big emoji that wraps, so what's on screen matches the
/// quantities the question is asking about. Operator tokens (➕ ➖ 🟰 🔟 ❓)
/// are drawn smaller and dimmer so the countable animals stand out.
struct EmojiCountView: View {
    let tokens: [String]
    private let cols = [GridItem(.adaptive(minimum: 52, maximum: 64), spacing: 8)]

    private func isOperator(_ t: String) -> Bool {
        ["➕", "➖", "🟰", "=", "🔟", "❓", "➡️"].contains(t)
    }

    var body: some View {
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, t in
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isOperator(t) ? Color.clear : Theme.surfaceHi)
                    EmojiView(emoji: t, size: isOperator(t) ? 26 : 34, tint: .white)
                }
                .frame(height: 56)
                .opacity(isOperator(t) ? 0.7 : 1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
