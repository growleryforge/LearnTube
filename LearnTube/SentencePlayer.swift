import SwiftUI

// MARK: - Finish the sentence by BUILDING it, not by tapping an answer
//
// "Finish the Sentence" used to be three tiles and a tap, and the data said he
// was not reading it at all: on Sept 9 his misses were random words, and on
// Sept 12 he missed "like" twice with "lip" and "lake" before landing it.
//
// So now the sentence has a real hole in it and he has to carry a word over and
// put it in. Same standard, but the sentence stays on screen the whole time,
// Leo reads it back to him once the word is in, and dropping a word takes long
// enough that skimming three tiles is no longer the cheap way through.
//
// Missing is not a shortcut here either: after the second miss Leo reads the
// whole sentence with the right word in it and that tile lights up, and the
// sentence comes back once more before the round ends.

struct SentencePlayer: View {
    let prompt: String
    let lines: [SentenceLine]
    let accent: Color
    let onComplete: () -> Void

    @State private var order: [Int] = []
    @State private var pos = 0
    @State private var redoQueue: [Int] = []
    @State private var redoSeen: Set<Int> = []
    @State private var inRedo = false
    @State private var answered = 0

    @State private var tiles: [String] = []
    @State private var dragWord: String? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var filled: String? = nil
    @State private var wrongWord: String? = nil
    @State private var misses = 0
    @State private var taught = false
    @State private var mood: MascotMood = .idle
    @State private var slotFrame: CGRect = .zero
    /// Same guard as SortPlayer: only a genuine finger drag may fill the gap.
    @State private var moved = false
    /// Mac only: the word he has picked up and is carrying to the gap.
    @State private var carried: String? = nil

    /// The sentence in front of him. Guarded so a malformed lesson can never
    /// crash the game in his hands.
    private var line: SentenceLine {
        guard !lines.isEmpty else { return SentenceLine("", "", "", answer: "", distractors: []) }
        guard !order.isEmpty else { return lines[0] }
        return lines[min(order[min(pos, order.count - 1)], lines.count - 1)]
    }

    /// Two halves on a Mac, one drag on a touch screen.
    private var stagePrompt: String {
        guard Pointer.isMac else { return prompt }
        return carried == nil ? prompt : "Now click the gap in the sentence."
    }

    var body: some View {
        GameStage(mood: mood, prompt: stagePrompt,
                  confetti: filled != nil && pos + 1 >= order.count, compact: true) {
            VStack(spacing: 12) {
                ProgressDots(total: lines.count + redoSeen.count, done: answered, accent: accent)
                if !line.picture.isEmpty {
                    EmojiView(emoji: line.picture, size: 56, tint: .white).frame(height: 60)
                }
                sentence
                wordTiles
            }
            .padding(.bottom, 8)
        }
        .coordinateSpace(name: "sentence")
        .onPreferenceChange(SlotKey.self) { slotFrame = $0 }
        .onAppear(perform: start)
    }

    // MARK: The sentence, with a hole in it

    private var sentence: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if !line.before.isEmpty { word(line.before) }
            slot
            if !line.after.isEmpty { word(line.after) }
        }
        .padding(.horizontal, 10)
    }

    private func word(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 26, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
    }

    private var slot: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: filled == nil ? [7, 6] : []))
                .foregroundStyle(filled == nil ? Theme.gold : Theme.green)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(filled == nil ? Color.white.opacity(0.08) : Theme.green.opacity(0.3))
                )
            if let f = filled {
                Text(f).font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        }
        .frame(width: 150, height: 52)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: filled)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            guard Pointer.isMac, filled == nil, let c = carried else { return }
            carried = nil
            if c == line.answer { land(c) } else { miss(c) }
        }
        .background(GeometryReader { g in
            Color.clear.preference(key: SlotKey.self, value: g.frame(in: .named("sentence")))
        })
    }

    // MARK: The words he can carry

    private var wordTiles: some View {
        HStack(spacing: 12) {
            ForEach(tiles, id: \.self) { t in
                let isRight = taught && t == line.answer
                Text(t)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.vertical, 14).padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(wrongWord == t ? Theme.red.opacity(0.55)
                                  : (isRight ? Theme.green.opacity(0.65) : Theme.surfaceHi))
                    )
                    .wiggle(wrongWord == t)
                    .offset(dragWord == t ? dragOffset : .zero)
                    .scaleEffect(dragWord == t || carried == t ? 1.1 : 1)
                    .zIndex(dragWord == t || carried == t ? 10 : 0)
                    .opacity(filled != nil ? 0.35 : 1)
                    .contentShape(Rectangle())
                    // Priority over the surrounding scroll view, same as the
                    // other drag games.
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("sentence"))
                            .onChanged { v in
                                guard filled == nil else { return }
                                if abs(v.translation.width) > 8 || abs(v.translation.height) > 8 { moved = true }
                                dragWord = t; dragOffset = v.translation
                            }
                            .onEnded { v in drop(t, at: v.location) }
                    )
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: dragWord)
    }

    // MARK: Play

    private func start() {
        order = Array(lines.indices).shuffled()
        pos = 0; answered = 0; redoQueue = []; redoSeen = []; inRedo = false
        load()
    }

    private func load() {
        filled = nil; wrongWord = nil; misses = 0; taught = false; carried = nil
        tiles = ([line.answer] + line.distractors).shuffled()
        Leo.say(spoken(line, blank: true))
    }

    /// The sentence read aloud. `blank` reads the gap as "blank" so he hears
    /// where the hole is; otherwise the whole thing is read with the answer in.
    private func spoken(_ l: SentenceLine, blank: Bool) -> String {
        let mid = blank ? "blank" : l.answer
        return [l.before, mid, l.after].filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func drop(_ t: String, at point: CGPoint) {
        let realDrag = moved
        moved = false
        let onSlot = slotFrame.insetBy(dx: -40, dy: -40).contains(point)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragWord = nil; dragOffset = .zero }
        // Mac: a click that did not move picks the word up; the gap is then
        // one more click. He still carries it there, so nothing here turns
        // this back into a game he can win with a single tap.
        if Pointer.isMac, !realDrag, filled == nil {
            carried = (carried == t) ? nil : t
            return
        }
        guard realDrag, onSlot, filled == nil else { return }
        if t == line.answer { land(t) } else { miss(t) }
    }

    private func land(_ t: String) {
        filled = t; mood = .cheer; SFX.correct()
        Leo.say(spoken(line, blank: false))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            answered += 1
            if !inRedo && pos + 1 < order.count {
                pos += 1; mood = .idle; load()
            } else if !redoQueue.isEmpty {
                let idx = redoQueue.removeFirst()
                order.append(idx); pos = order.count - 1; inRedo = true
                mood = .idle; load()
            } else { SFX.win(); onComplete() }
        }
    }

    private func miss(_ t: String) {
        misses += 1
        wrongWord = t; mood = .oops; SFX.wrong()
        GameStats.recordMiss(prompt: spoken(line, blank: true), tapped: t, correct: line.answer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongWord = nil; mood = .idle }
        if misses >= 2 && !taught {
            // Shown the answer: read the whole sentence with it, light the right
            // word, and put this sentence back in the pile. Longer, not shorter.
            taught = true
            Leo.say("Listen. " + spoken(line, blank: false), slow: true)
            let idx = order[pos]
            if !inRedo && !redoSeen.contains(idx) { redoSeen.insert(idx); redoQueue.append(idx) }
        }
    }
}

private struct SlotKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let n = nextValue(); if n != .zero { value = n }
    }
}
