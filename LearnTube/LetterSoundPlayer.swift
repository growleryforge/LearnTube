import SwiftUI

// MARK: - Letter Sounds (RF.K.3a): hear the sound, tap the letter
//
// Letter Detective is text-first and G through L are his shakiest letters
// (Sept 10: 12 misses in Letters G to L, 6 in Letter Detective). This game is
// sound-first: Leo says the sound and its farm word out loud, he taps the
// letter. Half the rounds come from the focus set (G H I J K L). After a miss
// the picture and word appear as a hint; after two the answer is held green.

struct LetterSoundLevel: Identifiable, Hashable { let id = UUID(); let skill: String; let rounds: Int }

extension LetterInfo {
    /// How Leo says the sound out loud ("/g/" reads badly through TTS).
    var spoken: String {
        let map: [String: String] = [
            "A": "ah", "B": "buh", "C": "kuh", "D": "duh", "E": "eh", "F": "fff", "G": "guh",
            "H": "huh", "I": "ih", "J": "juh", "K": "kuh", "L": "lll", "M": "mmm", "N": "nnn",
            "O": "ah", "P": "puh", "Q": "kwuh", "R": "rrr", "S": "sss", "T": "tuh", "U": "uh",
            "V": "vvv", "W": "wuh", "Y": "yuh", "Z": "zzz"
        ]
        return map[id] ?? lower
    }
}

enum LetterSoundGen {
    static let focus: Set<String> = ["G", "H", "I", "J", "K", "L"]
    static var lastId: String?
    static var focusTurn = false
    static func make() -> LetterQ {
        focusTurn.toggle()
        var pool = focusTurn ? LetterGen.letters.filter { focus.contains($0.id) } : LetterGen.letters
        if pool.isEmpty { pool = LetterGen.letters }
        pool = pool.filter { $0.id != lastId }
        let t = pool.randomElement() ?? LetterGen.letters[0]
        lastId = t.id
        return LetterQ(target: t, options: ([t] + LetterGen.distractors(for: t)).shuffled())
    }
}

struct LetterSoundPlayer: View {
    let level: LetterSoundLevel
    let accent: Color
    let onComplete: () -> Void

    @State private var round = 0
    @State private var q = LetterGen.make()
    @State private var options: [LetterInfo] = []
    @State private var wrongId: String?
    @State private var cheer = false
    @State private var missed = 0
    @State private var revealed = false
    @State private var bounce = false

    private var line: String { "\(q.target.spoken). \(q.target.spoken). \(q.target.word) starts with \(q.target.spoken). Which letter?" }

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                if level.rounds > 1 { ProgressDots(total: level.rounds, done: round, accent: Theme.red) }

                Text("Which letter makes this sound? 👂")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                // The big speaker is the whole point: tap to hear it again.
                Button {
                    Leo.say(line, slow: true, force: true)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bounce.toggle() }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.surface)
                        HStack(spacing: 18) {
                            Text("🔊").font(.system(size: 72))
                                .scaleEffect(bounce ? 1.1 : 1)
                            if missed > 0 {
                                // Hint after a miss: the picture and its word.
                                VStack(spacing: 4) {
                                    EmojiView(emoji: q.target.emoji, size: 64, tint: .white)
                                    Text(q.target.word)
                                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Tap to hear it")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                    .frame(height: 150)
                }
                .buttonStyle(.plain)

                HStack(spacing: 14) {
                    ForEach(options) { letter in
                        Button { tap(letter) } label: { tile(letter) }.wiggle(wrongId == letter.id)
                    }
                }
            }
            if cheer { CheerOverlay(custom: q.target.fact).transition(.opacity).id("lscheer\(round)") }
        }
        .onAppear { round = 0; newRound() }
    }

    private func tile(_ letter: LetterInfo) -> some View {
        VStack(spacing: 2) {
            Text(letter.upper).font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(letter.lower).font(.system(size: 30, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).frame(height: 150)
        .background(revealed && letter.id == q.target.id ? Theme.green
                    : (wrongId == letter.id ? Theme.red.opacity(0.5) : Theme.surfaceHi))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newRound() {
        q = LetterSoundGen.make(); options = q.options
        wrongId = nil; cheer = false; missed = 0; revealed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { Leo.say(line, slow: true) }
    }

    private func tap(_ letter: LetterInfo) {
        guard !cheer else { return }
        if letter.id == q.target.id {
            SFX.win(); Leo.say("\(q.target.upper) says \(q.target.spoken), like \(q.target.word)!")
            withAnimation { cheer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if round + 1 < level.rounds { round += 1; newRound() } else { onComplete() }
            }
        } else {
            missed += 1
            withAnimation { wrongId = letter.id }
            SFX.wrong()
            GameStats.recordMiss(prompt: "Which letter says \(q.target.sound) (\(q.target.word))?",
                                 tapped: letter.upper, correct: q.target.upper)
            Leo.say("\(letter.upper) says \(letter.spoken). Listen again: \(q.target.spoken), \(q.target.word).", slow: true)
            if missed >= 2 { withAnimation { revealed = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { wrongId = nil }
        }
    }
}
