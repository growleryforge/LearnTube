import UIKit
import AVFoundation

// MARK: - Doing the slow things once, early, and off the main thread
//
// Two beats Doosy could feel: the app taking a moment to come up, and a game
// taking a moment to appear after she tapped it. Neither was the game logic.
//
//   * Leo resolved his voice by calling AVSpeechSynthesisVoice.speechVoices()
//     — which walks every voice installed on the device — on the MAIN thread,
//     for every single line he said. The first line of a game paid for it
//     while the screen was trying to draw.
//   * The scene art is three 1280x720 PNGs. A PNG is not an image until
//     something decodes it, and that decode happened on the main thread at the
//     exact moment the pond first appeared.
//
// So: resolve the voice once and cache it, and decode the artwork on a
// background queue right after the first screen is up. Nothing here blocks
// launch; it just means the work is already done by the time he taps a game.

enum Warmup {
    private static var done = false

    /// Scenery and the mascot: everything a game needs the instant it opens.
    private static let images = [
        "act-pond", "act-field", "act-fence", "act-gate", "act-crate",
        "leo-idle", "leo-happy", "leo-cheer", "leo-oops"
    ]

    static func run() {
        guard !done else { return }
        done = true
        Leo.warmUp()
        DispatchQueue.global(qos: .utility).async {
            for name in images {
                // preparingForDisplay does the expensive decode here instead of
                // on the main thread mid-animation. A missing asset is fine:
                // several of these are optional and fall back to a drawing.
                _ = UIImage(named: name)?.preparingForDisplay()
            }
        }
    }
}
