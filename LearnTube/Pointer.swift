import Foundation

// MARK: - Finger or pointer
//
// Every game he plays by moving something was written for a finger on glass.
// On a Mac there is no finger. A drag there means holding the button down for
// the whole movement, which is awkward with a mouse and close to impossible on
// a trackpad: the pointer runs out of trackpad partway through, the button
// releases, and the game reads a forced release as a mistake he made.
//
// So the Mac gets its own way in, everywhere something has to be moved:
//
//   * Tracing follows the pointer with no button held at all. He moves along
//     the dots; leaving the path pauses rather than punishes.
//   * Sorting, sentence building and the act-it-out stages are click to pick
//     up, click to put down. He still has to carry the thing to the right
//     place, so being shown the answer still saves him nothing.
//
// This is the one switch that decides which way a game behaves.
enum Pointer {
    /// True when this is the Mac Catalyst build, which is the only build with
    /// a pointer and no touch screen.
    static let isMac: Bool = ProcessInfo.processInfo.isMacCatalystApp
}
