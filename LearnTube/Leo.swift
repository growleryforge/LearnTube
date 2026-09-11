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

    /// English voices, best first.
    static func candidates() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { a, b in
                if a.quality != b.quality { return a.quality.rawValue > b.quality.rawValue }
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
        if !voiceID.isEmpty, let v = AVSpeechSynthesisVoice(identifier: voiceID) { return v }
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
        u.rate = slow ? 0.36 : 0.45
        u.pitchMultiplier = 1.08
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
    @State private var bounce = false
    var body: some View {
        Button {
            Leo.say(text, slow: slow, force: true)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bounce.toggle() }
        } label: {
            Label("Read it to me", systemImage: "speaker.wave.2.fill")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Theme.surfaceHi).clipShape(Capsule())
                .scaleEffect(bounce ? 1.06 : 1)
        }
        .buttonStyle(.plain)
    }
}
