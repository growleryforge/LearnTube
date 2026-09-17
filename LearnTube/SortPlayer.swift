import SwiftUI

// MARK: - Sorting: put each thing where it belongs
//
// The science games used to be quizzes: read a question, tap one of two tiles,
// done in three taps. But "living or not", "mammal or bird", "float or sink",
// "wild or pet" are not really questions, they are SORTING. So here he sorts.
//
// A pen on each side of the farm, a queue of animals and objects, and he drags
// each one where it belongs. Eight drags instead of three taps, and the work is
// something he does with his finger rather than something he reads and guesses.
//
// Two things worth knowing about why this shape was chosen:
//
//   * There is no shortcut. In a quiz, two deliberate misses used to leave one
//     tappable tile, which made missing the fast route through. Here, being
//     shown the answer still leaves him the whole drag to do, so guessing wrong
//     never saves him a single second.
//   * Teaching still happens. After the second miss on one item Leo says where
//     it goes and the right pen lights up, so he is never stuck and never
//     scolded. He just has to carry it there himself.

struct SortPlayer: View {
    let prompt: String
    let bins: [SortBin]
    let items: [SortThing]
    let perRound: Int
    let accent: Color
    let onComplete: () -> Void

    @State private var deck: [SortThing] = []
    @State private var placedIn: [String: [SortThing]] = [:]   // bin key -> what landed there
    @State private var placed = 0
    @State private var mood: MascotMood = .idle
    @State private var dragOffset: CGSize = .zero
    @State private var dragging = false
    @State private var wiggling = false
    @State private var missesHere = 0
    @State private var taughtBin: String? = nil    // the pen that glows after 2 misses
    @State private var justLanded: String? = nil
    @State private var binFrames: [String: CGRect] = [:]
    // A drop only counts when he ACTUALLY dragged: the gesture has to have moved
    // a real distance, and no landing may be in flight. Without these guards a
    // zero-distance gesture end (which SwiftUI can deliver on a re-render) was
    // enough to place an item, and the game walked itself to the finish.
    @State private var moved = false
    @State private var landing = false
    /// Mac only: he has clicked the thing and is holding it, waiting to click
    /// a pen. There is no drag on a trackpad worth asking a seven-year-old for.
    @State private var carrying = false
    /// Phone or iPad. On a phone four pens in one row are unhittable, so they
    /// wrap to two columns and everything shrinks to fit one screen.
    @Environment(\.horizontalSizeClass) private var hSize
    private var narrow: Bool { hSize == .compact }

    private var current: SortThing? { deck.first }

    /// On a Mac the job is in two halves, so the prompt says which half he is
    /// in. On a touch screen it is one drag and the prompt is left alone.
    private var stagePrompt: String {
        guard Pointer.isMac else { return prompt }
        return carrying ? "Now click the pen it belongs in." : prompt
    }

    var body: some View {
        GameStage(mood: mood, prompt: stagePrompt,
                  confetti: justLanded != nil && deck.isEmpty, compact: true) {
            VStack(spacing: narrow ? 10 : 14) {
                ProgressDots(total: max(1, placed + deck.count), done: placed, accent: accent)
                binRow
                carryRow
            }
            .padding(.bottom, 8)
        }
        .coordinateSpace(name: "sortscene")
        .onPreferenceChange(BinKey.self) { binFrames = $0 }
        .onAppear(perform: start)
    }

    // MARK: The pens

    private var binRow: some View {
        let cols = (narrow && bins.count > 2) ? 2 : bins.count
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: cols),
                         spacing: 8) {
            ForEach(bins, id: \.key) { bin in
                let glow = taughtBin == bin.key
                let landed = justLanded == bin.key
                VStack(spacing: 4) {
                    EmojiView(emoji: bin.emoji, size: narrow ? 30 : 40, tint: .white)
                        .frame(height: narrow ? 34 : 44)
                    if !bin.label.isEmpty {
                    Text(bin.label)
                        .font(.system(size: narrow ? 14 : 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2).minimumScaleFactor(0.7)
                    }
                    // What he has already put in this pen, so the sort adds up
                    // to something he can see rather than vanishing.
                    HStack(spacing: 2) {
                        ForEach(Array((placedIn[bin.key] ?? []).suffix(5).enumerated()), id: \.offset) { _, it in
                            Text(it.emoji).font(.system(size: narrow ? 15 : 18))
                                .lineLimit(1).minimumScaleFactor(0.3)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(height: narrow ? 18 : 22)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, narrow ? 8 : 12).padding(.horizontal, 6)
                // Doosy, on the first four TK games: white on the light blue
                // sky is hard to read. It was - the pens were a 13% white wash
                // over a pale scene, so the label was near-white on near-white.
                // They now use the same dark panel the prompt chip uses, which
                // is the one thing on these boards that always read cleanly.
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black.opacity(landed ? 0.55 : 0.40))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(glow ? Theme.green : Color.white.opacity(0.40),
                                      lineWidth: glow ? 5 : 2)
                )
                .shadow(color: .black.opacity(0.22), radius: 5, y: 2)
                .scaleEffect(landed ? 1.05 : 1)
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: justLanded)
                .animation(.easeOut(duration: 0.25), value: taughtBin)
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture {
                    guard Pointer.isMac, carrying, let it = current else { return }
                    place(it, into: bin)
                }
                .background(GeometryReader { g in
                    Color.clear.preference(key: BinKey.self,
                                           value: [bin.key: g.frame(in: .named("sortscene"))])
                })
            }
        }
    }

    // MARK: The thing in his hand

    @ViewBuilder private var carryRow: some View {
        if let it = current {
            let dot: CGFloat = narrow ? 84 : 104
            VStack(spacing: narrow ? 4 : 8) {
                ZStack {
                    Circle().fill(.white.opacity(0.92)).frame(width: dot, height: dot)
                    if it.emoji.isPlainText {
                        // Letters, sounds and numbers ("c a t", "54", "sh"):
                        // dark on the white disc, shrunk to fit inside it.
                        Text(it.emoji)
                            .font(.system(size: narrow ? 38 : 46, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.12, green: 0.14, blue: 0.22))
                            .lineLimit(1).minimumScaleFactor(0.35)
                            .frame(width: dot - 16)
                    } else if it.emoji.count > 1 {
                        // A little group to count ("🍎🍎🍎🍎🍎🍎🍎"): wrap it
                        // inside the disc instead of running off the side.
                        Text(it.emoji)
                            .font(.system(size: narrow ? 20 : 24))
                            .multilineTextAlignment(.center)
                            .lineLimit(3).minimumScaleFactor(0.5)
                            .frame(width: dot - 14, height: dot - 14)
                    } else {
                        EmojiView(emoji: it.emoji, size: narrow ? 50 : 64, tint: .white)
                    }
                }
                .overlay(Circle().strokeBorder(Theme.gold, lineWidth: 4).frame(width: dot, height: dot))
                .offset(dragOffset)
                .scaleEffect(dragging || carrying ? 1.12 : 1)
                .shadow(color: .black.opacity(dragging || carrying ? 0.3 : 0), radius: 8, y: 4)
                .wiggle(wiggling)
                .zIndex(10)
                .contentShape(Circle())
                // One gesture, taking priority over the scroll view every game
                // sits inside — otherwise the scroll eats the finger and nothing
                // ever moves. Same fix as ActOutPlayer.
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("sortscene"))
                        .onChanged { v in
                            if abs(v.translation.width) > 8 || abs(v.translation.height) > 8 { moved = true }
                            dragging = true
                            dragOffset = v.translation
                        }
                        .onEnded { v in drop(it, at: v.location) }
                )
                VStack(spacing: 2) {
                    Text(it.name)
                        .font(.system(size: narrow ? 19 : 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(deck.count > 1 ? "\(deck.count - 1) more to sort" : "last one!")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Capsule().fill(.black.opacity(0.42)))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: dragging)
        }
    }

    // MARK: Play

    private func start() {
        deck = Array(items.shuffled().prefix(max(1, perRound)))
        placedIn = [:]; placed = 0; missesHere = 0; taughtBin = nil; carrying = false
        Leo.say(prompt)
        if let first = deck.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { Leo.say(first.name) }
        }
    }

    private func drop(_ it: SortThing, at point: CGPoint) {
        let realDrag = moved
        dragging = false; moved = false
        // Not a real drag, or a landing is already playing: put it back, no
        // penalty, no placement.
        guard realDrag, !landing else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragOffset = .zero }
            // Mac: a click that did not move picks the thing up, or puts it
            // back down. The pen is then one more click away.
            if Pointer.isMac, !landing { carrying.toggle() }
            return
        }
        let hit = bins.first { binFrames[$0.key]?.contains(point) ?? false }
        guard let bin = hit else {
            // Dropped on nothing: no penalty, it just comes back to his hand.
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragOffset = .zero }
            return
        }
        place(it, into: bin)
    }

    /// The moment of judgement, reached either by a finger dropping the thing
    /// on a pen or by a Mac click on one.
    private func place(_ it: SortThing, into bin: SortBin) {
        guard !landing else { return }
        carrying = false
        if bin.key == it.bin {
            land(it, in: bin)
        } else {
            miss(it, tried: bin)
        }
    }

    private func land(_ it: SortThing, in bin: SortBin) {
        landing = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { dragOffset = .zero }
        placedIn[bin.key, default: []].append(it)
        deck.removeFirst()
        placed += 1
        missesHere = 0; taughtBin = nil
        mood = .cheer; SFX.correct(); justLanded = bin.key
        Leo.say("\(it.name), \(bin.spoken).")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            justLanded = nil; landing = false
            if deck.isEmpty { SFX.win(); onComplete() }
            else { mood = .idle; if let next = deck.first { Leo.say(next.name) } }
        }
    }

    private func miss(_ it: SortThing, tried: SortBin) {
        missesHere += 1
        mood = .oops; SFX.wrong()      // SFX.wrong also arms the app-wide pause
        GameStats.recordMiss(prompt: "Where does \(it.name) go?",
                             tapped: tried.spoken,
                             correct: bins.first { $0.key == it.bin }?.spoken ?? it.bin)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { dragOffset = .zero }
        wiggling = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wiggling = false; mood = .idle }
        // Second miss: teach it. The right pen lights up and Leo says where it
        // goes — but he still has to carry it there, so being shown the answer
        // has never saved him anything.
        if missesHere >= 2, let right = bins.first(where: { $0.key == it.bin }) {
            taughtBin = right.key
            Leo.say("\(it.name) goes in \(right.spoken). Take it there.", slow: true)
        }
    }
}

private struct BinKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}


extension String {
    /// True for ordinary letters, digits and punctuation, false as soon as
    /// there is a picture emoji in it. Sort items use the emoji slot for both.
    var isPlainText: Bool {
        !isEmpty && unicodeScalars.allSatisfy { $0.value < 0x2000 && !$0.properties.isEmojiPresentation }
    }
}
