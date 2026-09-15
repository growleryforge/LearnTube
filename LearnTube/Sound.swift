import AVFoundation
import UIKit
import Combine

/// A brief, app-wide input lock after ANY wrong tap. The first wrong still
/// registers (so it's recorded), then taps are ignored for a beat — which stops
/// machine-gun guessing in EVERY game, including the ~30 procedural mini-games,
/// from one place instead of editing each one. Driven by SFX.wrong().
final class GameGate: ObservableObject {
    static let shared = GameGate()
    @Published var blocked = false
    private var token = 0
    func block(_ seconds: Double = 1.1) {
        token += 1; let t = token; blocked = true
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if t == self.token { self.blocked = false }
        }
    }
}

/// Lightweight learning telemetry so grown-ups can see *what to work on*.
/// Every game plays SFX.wrong() on a mis-tap and calls GameStats.begin() when
/// it opens, so we capture struggles and abandoned games without editing each
/// of the ~40 game screens. AppState drains these deltas into synced storage.
enum GameStats {
    /// The skill currently being played (set on open); mis-taps are charged here.
    static var currentSkill = ""
    /// Wrong taps in the CURRENT game only (reset when a game opens). Used to
    /// decide whether a finish was a real run or a mash — a mash still earns
    /// YouTube but doesn't count toward a star.
    static var wrongThisGame = 0
    /// When true, nothing is recorded — used when a grown-up "tries" a game from
    /// the dashboard so their test play never lands in Gabriel's progress.
    static var suppressed = false
    /// Rounds a game OWES because it had to show him the answer.
    ///
    /// Every game teaches after the second miss on a question: the right tile
    /// lights up so he is never stuck. That is worth keeping. What is not worth
    /// keeping is what it used to cost him, which was nothing — two deliberate
    /// wrong taps were the fastest route through a question, and he found that
    /// out. So a revealed answer now adds a round: being shown it makes the game
    /// LONGER, never shorter, and getting it right first time is the quick way
    /// out. Capped, so a genuinely stuck round can't run away from him.
    static let maxOwedRounds = 2
    static var owedRounds = 0
    static func oweRound(speak: Bool = true) {
        guard owedRounds < maxOwedRounds else { return }
        owedRounds += 1
        if speak { Leo.say("Let's learn this one. Here it is.", slow: true) }
    }
    private static var pendingWrong: [String: Int] = [:]
    private static var pendingStart: [String: Int] = [:]
    /// Right answers, counted per ITEM the same way wrong taps are.
    ///
    /// Without this, "accuracy" had to be built out of the only two numbers
    /// the app had - games finished and wrong taps - which made it
    /// finishes / (finishes + wrong). That is not accuracy, it is completions
    /// per mistake, and it scales with how many questions a game asks. A
    /// one-question game he gets right reads 100%; a tracing game where one
    /// finish costs a dozen taps reads 6% for the same child on the same day.
    /// Worse, that number is fed into struggleScore at 8x, and struggleScore
    /// is what orders his feed - so the LENGTH of a game was quietly deciding
    /// which games looked hard and which ones he saw first.
    private static var pendingRight: [String: Int] = [:]
    /// AppState sets this to flush the deltas into persistent, synced storage.
    static var onChange: (() -> Void)?

    /// A specific wrong answer, captured so grown-ups can drill into exactly
    /// what he tapped vs. the right answer (not just a count).
    struct Miss { let skill: String; let prompt: String; let tapped: String; let correct: String; let at: Date }
    private static var pendingMisses: [Miss] = []
    /// Record the detail of a wrong tap in a quiz-style game.
    static func recordMiss(prompt: String, tapped: String, correct: String) {
        guard !suppressed, !currentSkill.isEmpty else { return }
        pendingMisses.append(Miss(skill: currentSkill, prompt: prompt, tapped: tapped, correct: correct, at: Date()))
        onChange?()
    }

    /// When the current game opened, so a finish can be turned into a real
    /// time-on-task number. Until this existed the app could count what he
    /// finished but never how long he was actually playing, which is the one
    /// thing nobody could answer about whether the games are long enough.
    static var startedAt: Date?

    /// A game screen opened for this skill (counts as one "started").
    static func begin(_ id: String) {
        currentSkill = id
        wrongThisGame = 0          // fresh game, no misses yet
        owedRounds = 0             // fresh game, owes nothing yet
        startedAt = Date()
        guard !suppressed else { return }
        pendingStart[id, default: 0] += 1
        onChange?()
    }
    /// A right answer in the current game, one per item.
    static func markRight() {
        guard !currentSkill.isEmpty, !suppressed else { return }
        pendingRight[currentSkill, default: 0] += 1
        onChange?()
    }
    /// A wrong tap in the current game.
    static func markWrong() {
        guard !currentSkill.isEmpty else { return }
        wrongThisGame += 1
        guard !suppressed else { return }
        pendingWrong[currentSkill, default: 0] += 1
        onChange?()
    }
    /// Hand the accumulated deltas to AppState and clear them.
    static func drain() -> (wrong: [String: Int], start: [String: Int], right: [String: Int], misses: [Miss]) {
        let w = pendingWrong, s = pendingStart, r = pendingRight, m = pendingMisses
        pendingWrong = [:]; pendingStart = [:]; pendingRight = [:]; pendingMisses = []
        return (w, s, r, m)
    }
}

/// Very faint, gentle feedback tones (volume-controlled) plus light haptics.
/// A wrong tap makes no sound, just a soft nudge, so it's never discouraging.
enum SFX {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionReady = false

    static func tap()     { impact(.light) }
    static func correct()  { play(freq: 880,  dur: 0.10, vol: 0.05, key: "correct"); notify(.success); GameStats.markRight() }
    static func wrong()    { impact(.soft); GameStats.markWrong(); DispatchQueue.main.async { GameGate.shared.block() } }
    static func win()      { play(freq: 1046, dur: 0.16, vol: 0.06, key: "win"); notify(.success) }

    private static func prepareSession() {
        guard !sessionReady else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        sessionReady = true
    }

    private static func play(freq: Double, dur: Double, vol: Float, key: String) {
        prepareSession()
        let player: AVAudioPlayer
        if let p = players[key] { player = p }
        else if let p = try? AVAudioPlayer(data: toneWAV(freq: freq, dur: dur)) {
            p.prepareToPlay(); players[key] = p; player = p
        } else { return }
        player.volume = vol      // very faint
        player.currentTime = 0
        player.play()
    }

    // Generates a short sine tone as 16-bit mono WAV data, with a tiny fade.
    private static func toneWAV(freq: Double, dur: Double) -> Data {
        let sr = 44100.0
        let n = Int(sr * dur)
        var samples = [Int16](); samples.reserveCapacity(n)
        for i in 0..<n {
            let t = Double(i) / sr
            let fade = min(1.0, min(Double(i), Double(n - i)) / (sr * 0.012))
            let s = sin(2 * Double.pi * freq * t) * fade * 0.5
            samples.append(Int16(max(-1, min(1, s)) * 32767))
        }
        var d = Data()
        func str(_ s: String) { d.append(s.data(using: .ascii)!) }
        func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        let dataSize = samples.count * 2
        str("RIFF"); u32(UInt32(36 + dataSize)); str("WAVE")
        str("fmt "); u32(16); u16(1); u16(1); u32(UInt32(sr)); u32(UInt32(sr) * 2); u16(2); u16(16)
        str("data"); u32(UInt32(dataSize))
        for s in samples { var x = s.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        return d
    }

    private static func notify(_ t: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(t)
    }
    private static func impact(_ s: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: s).impactOccurred()
    }
}
