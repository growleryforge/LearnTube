import SwiftUI

// MARK: - Syllable Safari (RF.K.2): tap the beats, then count them
//
// Gabriel could not hear syllable counts from a word on a screen (Sept 10: nine
// misses, always guessing low). So the game is now concrete-first, like the
// math: the word is shown in chunks (CROC / O / DILE). He taps each chunk in
// order and a clap pops up over it with its number. Only then does the question
// come, and the claps stay on screen so the answer is something he can count,
// not something he has to guess.

struct SyllableLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

struct SyllableWord { let emoji: String; let chunks: [String] }

enum SyllableGen {
    static let words: [SyllableWord] = [
        SyllableWord(emoji: "🐱", chunks: ["CAT"]),
        SyllableWord(emoji: "🐶", chunks: ["DOG"]),
        SyllableWord(emoji: "🐷", chunks: ["PIG"]),
        SyllableWord(emoji: "🐰", chunks: ["RAB", "BIT"]),
        SyllableWord(emoji: "🦒", chunks: ["GI", "RAFFE"]),
        SyllableWord(emoji: "🐧", chunks: ["PEN", "GUIN"]),
        SyllableWord(emoji: "🐒", chunks: ["MON", "KEY"]),
        SyllableWord(emoji: "🐢", chunks: ["TUR", "TLE"]),
        SyllableWord(emoji: "🐘", chunks: ["EL", "E", "PHANT"]),
        SyllableWord(emoji: "🦋", chunks: ["BUT", "TER", "FLY"]),
        SyllableWord(emoji: "🐊", chunks: ["CROC", "O", "DILE"]),
        SyllableWord(emoji: "🦘", chunks: ["KAN", "GA", "ROO"])
    ]
    static var bag: [Int] = []
    static var last: Int?
    static func next() -> SyllableWord {
        if bag.isEmpty {
            bag = Array(words.indices).shuffled()
            if let l = last, bag.count > 1, bag[0] == l { bag.swapAt(0, bag.count - 1) }
        }
        let i = bag.removeFirst(); last = i; return words[i]
    }
}

struct SyllablePlayer: View {
    let level: SyllableLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var word = SyllableGen.words[0]
    @State private var tapped = 0            // chunks tapped so far, in order
    @State private var options: [Int] = []
    @State private var wrong: Int?
    @State private var cheer = false
    @State private var pulse = false

    private var asking: Bool { tapped >= word.chunks.count }
    private var beats: Int { word.chunks.count }
    private var wordText: String { word.chunks.joined(separator: " · ") }
    private var fact: String {
        "\(wordText) — \(beats) \(beats == 1 ? "clap" : "claps")! " + String(repeating: "👏", count: beats)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }

                Text(asking ? "How many claps? 👏" : "Tap each beat and clap 👏")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                // The animal and its name in chunks. The next chunk to tap has a
                // gold ring and a gentle pulse so it is obvious what to do.
                VStack(spacing: 14) {
                    EmojiView(emoji: word.emoji, size: 96, tint: .white)
                    HStack(spacing: 12) {
                        ForEach(word.chunks.indices, id: \.self) { i in
                            chunk(i)
                        }
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                if asking {
                    HStack(spacing: 14) {
                        ForEach(options, id: \.self) { n in
                            Button { pick(n) } label: { numberTile(n) }.wiggle(wrong == n)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Text("\(tapped) of \(beats)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            if cheer { CheerOverlay(custom: fact).transition(.opacity).id("sylcheer\(round)") }
        }
        .onAppear { round = 0; newRound() }
        .onAppear { withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { pulse = true } }
    }

    private func chunk(_ i: Int) -> some View {
        let done = i < tapped
        let next = i == tapped
        return Button { tapChunk(i) } label: {
            VStack(spacing: 6) {
                // The clap and its number sit over the chunk once it is tapped,
                // so the count is visible when the question comes.
                ZStack {
                    Text("👏").font(.system(size: 40)).opacity(done ? 1 : 0)
                    if done {
                        Text("\(i + 1)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(6).background(Theme.green).clipShape(Circle())
                            .offset(x: 26, y: -20)
                    }
                }
                .frame(height: 50)
                Text(word.chunks[i])
                    .font(.system(size: word.chunks[i].count > 4 ? 34 : 42, weight: .black, design: .rounded))
                    .foregroundStyle(done ? Theme.green : .white)
                    .padding(.horizontal, 18).padding(.vertical, 12)
                    .background(done ? Theme.green.opacity(0.18) : Theme.surfaceHi)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.yellow, lineWidth: next ? 4 : 0)
                    )
                    .scaleEffect(next && pulse ? 1.06 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(asking || !next)
    }

    private func numberTile(_ n: Int) -> some View {
        VStack(spacing: 4) {
            Text(String(repeating: "👏", count: n)).font(.system(size: 26))
            Text("\(n)").font(.system(size: 52, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).frame(height: 140)
        .background(wrong == n ? Theme.red.opacity(0.5) : Theme.surfaceHi)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        word = SyllableGen.next(); tapped = 0; wrong = nil; cheer = false
        options = [1, 2, 3].shuffled()
        Leo.say("\(word.chunks.joined().capitalized). Tap each beat and clap.")
    }

    private func tapChunk(_ i: Int) {
        guard i == tapped, !asking else { return }
        SFX.correct()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { tapped += 1 }
        if tapped >= beats {
            Leo.say("\(word.chunks[i].lowercased()). \(word.chunks.joined().capitalized)! How many claps?", slow: true)
        } else {
            Leo.say(word.chunks[i].lowercased(), slow: true)
        }
    }

    private func pick(_ n: Int) {
        guard !cheer else { return }
        if n == beats {
            SFX.win(); withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            wrong = n; SFX.wrong()
            GameStats.recordMiss(prompt: "How many claps in \(word.emoji) \(wordText)?", tapped: "\(n)", correct: "\(beats)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrong = nil }
        }
    }
}
