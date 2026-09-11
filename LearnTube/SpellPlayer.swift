import SwiftUI

// MARK: - Word Builder (RF.K.3 / L.1.2): build a farm word letter by letter
//
// The drag-the-animals concept, applied to reading. A picture and its word
// in empty slots; letter tiles below (the word's letters plus two extras).
// He taps the next letter he needs; it slides into its slot and Leo says
// the letter sound. When the word is built Leo reads it back. A wrong letter
// wiggles and counts as a miss; after two misses the next letter glows.

struct SpellLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct SpellWord { let word: String; let emoji: String }

enum SpellGen {
    static let words: [SpellWord] = [
        SpellWord(word: "cat", emoji: "🐱"), SpellWord(word: "dog", emoji: "🐶"),
        SpellWord(word: "pig", emoji: "🐷"), SpellWord(word: "hen", emoji: "🐔"),
        SpellWord(word: "cow", emoji: "🐄"), SpellWord(word: "egg", emoji: "🥚"),
        SpellWord(word: "sun", emoji: "☀️"), SpellWord(word: "bug", emoji: "🐛"),
        SpellWord(word: "fox", emoji: "🦊"), SpellWord(word: "bee", emoji: "🐝"),
        SpellWord(word: "ant", emoji: "🐜"), SpellWord(word: "owl", emoji: "🦉"),
        SpellWord(word: "hay", emoji: "🌾"), SpellWord(word: "mud", emoji: "🟤"),
        SpellWord(word: "ram", emoji: "🐏"), SpellWord(word: "pen", emoji: "🖊️")
    ]
    static var bag: [Int] = []
    static var last: Int?
    static func next() -> SpellWord {
        if bag.isEmpty {
            bag = Array(words.indices).shuffled()
            if let l = last, bag.count > 1, bag[0] == l { bag.swapAt(0, bag.count - 1) }
        }
        let i = bag.removeFirst(); last = i; return words[i]
    }
    static func tiles(for w: SpellWord) -> [Character] {
        let need = Set(w.word)
        let extras = "abcdefghijklmnoprstuwy".filter { !need.contains($0) }.shuffled().prefix(2)
        return (Array(w.word) + Array(extras)).shuffled()
    }
}

struct SpellPlayer: View {
    let level: SpellLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var word = SpellGen.words[0]
    @State private var tiles: [Character] = []
    @State private var used: Set<Int> = []       // tile indexes already placed
    @State private var filled = 0                // slots filled so far
    @State private var wrongIndex: Int?
    @State private var missed = 0
    @State private var cheer = false
    @State private var pulse = false

    private var letters: [Character] { Array(word.word) }
    private var done: Bool { filled >= letters.count }
    private func spoken(_ c: Character) -> String {
        LetterGen.letters.first { $0.lower == String(c) }?.spoken ?? String(c)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }

                Text("Build the word! 🔤")
                    .font(.system(size: 36, weight: .heavy, design: .rounded)).foregroundStyle(.white)

                // Picture and slots.
                VStack(spacing: 14) {
                    EmojiView(emoji: word.emoji, size: 96, tint: .white)
                    HStack(spacing: 12) {
                        ForEach(letters.indices, id: \.self) { i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(i < filled ? Theme.green.opacity(0.22) : Theme.surfaceHi)
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(i == filled && !done ? Color.yellow : Color.clear, lineWidth: 4)
                                if i < filled {
                                    Text(String(letters[i]))
                                        .font(.system(size: 52, weight: .black, design: .rounded))
                                        .foregroundStyle(Theme.green)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .frame(width: 84, height: 96)
                            .scaleEffect(i == filled && !done && pulse ? 1.05 : 1)
                        }
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                // Letter tiles.
                HStack(spacing: 12) {
                    ForEach(tiles.indices, id: \.self) { i in
                        Button { tap(i) } label: {
                            Text(String(tiles[i]))
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 96)
                                .background(wrongIndex == i ? Theme.red.opacity(0.5)
                                            : (missed >= 2 && !done && tiles[i] == letters[filled] && !used.contains(i)
                                               ? Theme.green.opacity(0.5) : Theme.surfaceHi))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .opacity(used.contains(i) ? 0.15 : 1)
                        .disabled(used.contains(i) || done)
                        .wiggle(wrongIndex == i)
                    }
                }
            }
            if cheer { CheerOverlay(custom: "\(letters.map(String.init).joined(separator: " · ")) — \(word.word)! \(word.emoji)").transition(.opacity).id("spcheer\(round)") }
        }
        .onAppear { round = 0; newRound() }
        .onAppear { withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { pulse = true } }
    }

    private func newRound() {
        word = SpellGen.next(); tiles = SpellGen.tiles(for: word)
        used = []; filled = 0; wrongIndex = nil; missed = 0; cheer = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { Leo.say("\(word.word). Build the word \(word.word).") }
    }

    private func tap(_ i: Int) {
        guard !done, !used.contains(i) else { return }
        if tiles[i] == letters[filled] {
            SFX.correct()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { used.insert(i); filled += 1 }
            if filled >= letters.count {
                SFX.win()
                Leo.say("\(letters.map(spoken).joined(separator: ", ")). \(word.word)!", slow: true)
                withAnimation { cheer = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
                }
            } else {
                Leo.say(spoken(tiles[i]), slow: true)
            }
        } else {
            missed += 1
            wrongIndex = i; SFX.wrong()
            GameStats.recordMiss(prompt: "Build \(word.word) (letter \(filled + 1))", tapped: String(tiles[i]), correct: String(letters[filled]))
            Leo.say("Not \(String(tiles[i])). \(word.word) needs \(spoken(letters[filled])).", slow: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrongIndex = nil }
        }
    }
}
