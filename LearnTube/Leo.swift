import AVFoundation
import SwiftUI

// MARK: - Leo's voice
//
// The lion cub reads prompts and words aloud. The built-in default voice is
// robotic, so Leo picks the best English voice installed on the device
// (Premium > Enhanced > default) and the grown-up area has a picker with a
// preview. Better voices are a free download in Settings > Accessibility >
// Spoken Content > Voices > English; once downloaded they show up here.

enum Leo {
    private static let synth = AVSpeechSynthesizer()
    private static let onKey = "leoVoiceOn"
    private static let idKey = "leoVoiceID"

    static var enabled: Bool {
        get { UserDefaults.standard.object(forKey: onKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: onKey) }
    }
    /// The chosen voice identifier; empty means "best available".
    static var voiceID: String {
        get { UserDefaults.standard.string(forKey: idKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: idKey) }
    }

    /// iOS ships a pile of NOVELTY voices next to the real ones — Albert, Bad
    /// News, Bubbles, Zarvox, Trinoids — and they all report "default" quality.
    /// The old sort was quality, then name, so on any device without an
    /// Enhanced voice downloaded the alphabetically-first voice won, which is
    /// "Albert": a croaky joke voice. That is why Leo was unintelligible.
    /// These are never Leo.
    private static let novelty: Set<String> = [
        "Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos",
        "Deranged", "Good News", "Hysterical", "Jester", "Junior", "Kathy",
        "Organ", "Pipe Organ", "Princess", "Ralph", "Superstar", "Trinoids",
        "Whisper", "Wobble", "Zarvox", "Fred", "Bruce", "Agnes", "Vicki"
    ]
    // (Rishi, Lee, Gordon and the other regional voices are real voices and
    // stay in the pool — only the joke voices above are excluded.)

    /// Clear, natural, child-friendly voices, in the order we want them. Leo
    /// takes the best one installed; anything outside this list is a fallback.
    /// Leo is a boy lion cub, so the male voices lead. Evan and Tom are the
    /// warmest American male voices Apple ships; Alex is the old high-quality
    /// one and is clear but adult; Daniel and Oliver are British. The female
    /// voices stay as the fallback so he is never left with a robot.
    private static let preferred = [
        "Evan", "Tom", "Nathan", "Alex", "Daniel", "Oliver", "Rishi", "Lee",
        "Ava", "Samantha", "Allison", "Nicky", "Zoe", "Karen", "Serena", "Tessa"
    ]

    /// English voices, best first: real voices only, highest quality first,
    /// then our preferred names, then US English, then alphabetical.
    static func candidates() -> [AVSpeechSynthesisVoice] {
        let english = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        let real = english.filter { !novelty.contains($0.name) }
        let pool = real.isEmpty ? english : real     // never leave him mute
        return pool.sorted { a, b in
            if a.quality != b.quality { return a.quality.rawValue > b.quality.rawValue }
            let ai = preferred.firstIndex(of: a.name) ?? Int.max
            let bi = preferred.firstIndex(of: b.name) ?? Int.max
            if ai != bi { return ai < bi }
            let aUS = a.language == "en-US", bUS = b.language == "en-US"
            if aUS != bUS { return aUS }
            return a.name < b.name
        }
    }

    static func qualityName(_ v: AVSpeechSynthesisVoice) -> String {
        switch v.quality {
        case .premium: return "Premium"
        case .enhanced: return "Enhanced"
        default: return "Default"
        }
    }

    static var voice: AVSpeechSynthesisVoice? {
        // A voice picked before the novelty filter existed could still be a
        // joke voice, so a saved choice only counts if it survives the filter.
        if !voiceID.isEmpty, let v = AVSpeechSynthesisVoice(identifier: voiceID),
           !novelty.contains(v.name) { return v }
        return candidates().first ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    /// Speak a line, dropping emoji and symbols so they are not read as names.
    /// `slow` stretches words for beats and letter sounds.
    static func say(_ text: String, slow: Bool = false, force: Bool = false) {
        guard enabled || force else { return }
        let clean = text.unicodeScalars
            .filter { !($0.properties.isEmojiPresentation || $0.properties.isEmojiModifier || $0.value == 0xFE0F || $0.value == 0x200D) }
            .map { String($0) }.joined()
            .replacingOccurrences(of: "___", with: "blank")
            .replacingOccurrences(of: " · ", with: ", ")
            .replacingOccurrences(of: " — ", with: ". ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let u = AVSpeechUtterance(string: clean)
        u.voice = voice
        // Slower, and no pitch shift. Pushing the pitch up made a compact voice
        // sound cuter in theory and mushier in practice.
        u.rate = slow ? 0.32 : 0.40
        u.pitchMultiplier = 1.0
        u.postUtteranceDelay = 0.1
        synth.speak(u)
    }

    static func stop() { if synth.isSpeaking { synth.stopSpeaking(at: .immediate) } }
}

/// Grown-up settings for Leo's voice: on/off, which voice, and a preview.
struct LeoVoiceSection: View {
    @State private var on = Leo.enabled
    @State private var id = Leo.voiceID
    private let voices = Leo.candidates()

    var body: some View {
        Section {
            Toggle("Leo reads aloud", isOn: $on)
                .onChange(of: on) { v in Leo.enabled = v }
            Menu {
                Button("Best available") { id = ""; Leo.voiceID = ""; Leo.say("Hi, I'm Leo! Let's play.", force: true) }
                ForEach(voices, id: \.identifier) { v in
                    Button("\(v.name)  ·  \(Leo.qualityName(v))  ·  \(v.language)") {
                        id = v.identifier; Leo.voiceID = v.identifier
                        Leo.say("Hi, I'm Leo! Let's play.", force: true)
                    }
                }
            } label: {
                HStack {
                    Text("Voice")
                    Spacer()
                    Text(currentName).foregroundStyle(.secondary)
                }
            }
            Button("Hear Leo") { Leo.say("Which word rhymes with pig? Tap each beat and clap!", force: true) }
        } header: {
            Text("Leo's Voice")
        } footer: {
            Text("Leo reads questions and words to Gabriel. The default iPad voice sounds robotic; download a better one free in Settings > Accessibility > Spoken Content > Voices > English (look for Premium or Enhanced, e.g. Ava, Evan, Zoe, Samantha Enhanced), then pick it here. \"Best available\" always uses the highest-quality English voice installed.")
        }
    }

    private var currentName: String {
        if id.isEmpty { return "Best available" + (voices.first.map { " (\($0.name) \(Leo.qualityName($0)))" } ?? "") }
        if let v = voices.first(where: { $0.identifier == id }) { return "\(v.name) \(Leo.qualityName(v))" }
        return "Best available"
    }
}

/// A small speaker capsule that reads a line aloud when tapped.
struct LeoSpeakButton: View {
    let text: String
    var slow: Bool = false
    /// In the game top bar on a phone there is no room for the words, so it
    /// becomes the speaker on its own. Same size target, same job.
    var compact: Bool = false
    @State private var bounce = false
    var body: some View {
        Button {
            Leo.say(text, slow: slow, force: true)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bounce.toggle() }
        } label: {
            Group {
                if compact {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Theme.surfaceHi).clipShape(Circle())
                } else {
                    Label("Read it to me", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Theme.surfaceHi).clipShape(Capsule())
                }
            }
            .fixedSize()
            .scaleEffect(bounce ? 1.06 : 1)
        }
        .buttonStyle(.plain)
    }
}
