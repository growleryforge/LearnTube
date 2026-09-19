import SwiftUI

@main
struct LearnTubeApp: App {
    @StateObject private var state = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .tint(Theme.green)
                .onAppear {
                    state.refreshForToday()
                    Warmup.run()
                    #if targetEnvironment(macCatalyst)
                    // Open filling the whole screen (maximized, not macOS full-screen).
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { maximizeCatalystWindow() }
                    #endif
                }
                .onChange(of: scenePhase) { phase in
                    // refreshForToday used to run only from AppState.init and
                    // ContentView.onAppear, so an iPad that keeps LearnTube
                    // resident overnight never rolled the day over: the Today
                    // card read yesterday's dayKey and went blank, and
                    // completionsToday still held yesterday's counts, which
                    // silently spent his three plays per game. Coming back to
                    // the foreground now rolls the day.
                    if phase == .active { state.refreshForToday() }
                }
        }
    }
}

#if targetEnvironment(macCatalyst)
/// Zoom the app's AppKit window so it fills the visible screen on launch.
private func maximizeCatalystWindow() {
    let sharedSel = NSSelectorFromString("sharedApplication")
    guard let appClass = NSClassFromString("NSApplication") as? NSObjectProtocol,
          appClass.responds(to: sharedSel),
          let nsApp = appClass.perform(sharedSel)?.takeUnretainedValue() as? NSObject,
          let windows = nsApp.value(forKey: "windows") as? [NSObject] else { return }
    let zoomSel = NSSelectorFromString("zoom:")
    for w in windows where w.responds(to: zoomSel) {
        let isZoomed = (w.value(forKey: "isZoomed") as? Bool) ?? false
        if !isZoomed { _ = w.perform(zoomSel, with: nil) }
    }
}
#endif
