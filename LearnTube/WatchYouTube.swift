import SwiftUI
import WebKit
import SafariServices
import UIKit

/// An in-app web view locked to YouTube (and the domains it needs). Top-level
/// navigation to other sites is blocked, so Gabriel stays on YouTube.
struct YouTubeWebView: UIViewRepresentable {
    let url: URL
    @Binding var navRequest: URL?

    func makeUIView(context: Context) -> WKWebView {
        // One shared, persistent session for every YouTube web view, so a sign-in
        // sticks across launches and his account governs what search can show.
        let wv = WKWebView(frame: .zero, configuration: YTWeb.makeConfiguration())
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true
        var req = URLRequest(url: url)
        // Ask YouTube for Restricted Mode at the network layer too (belt and
        // suspenders with the PREF cookie set in prepare()).
        req.setValue("Strict", forHTTPHeaderField: "YouTube-Restrict-Mode")
        // Always apply Restricted Mode, reuse any live sign-in, and only fall
        // back to the copied iCloud login when this device has none yet.
        YTSession.prepare(wv) { wv.load(req) }
        return wv
    }

    // Load a new page when the search bar requests one, then clear the request.
    func updateUIView(_ wv: WKWebView, context: Context) {
        if let target = navRequest {
            var req = URLRequest(url: target)
            if target.host?.lowercased().contains("youtube.") == true {
                req.setValue("Strict", forHTTPHeaderField: "YouTube-Restrict-Mode")
            }
            wv.load(req)
            DispatchQueue.main.async { navRequest = nil }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Only inspect top-level (main frame) page loads.
            if let frame = navigationAction.targetFrame, !frame.isMainFrame {
                decisionHandler(.allow); return
            }
            // Force SafeSearch on any Google search he lands on.
            if let safe = safeSearchRewrite(navigationAction.request.url) {
                decisionHandler(.cancel)
                webView.load(URLRequest(url: safe))
                return
            }
            decisionHandler(.allow)
        }

        /// If this is a Google search missing SafeSearch, return the safe URL.
        private func safeSearchRewrite(_ url: URL?) -> URL? {
            guard let url, let host = url.host?.lowercased(), host.contains("google."),
                  url.path.hasPrefix("/search"),
                  var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            var items = comps.queryItems ?? []
            if items.contains(where: { $0.name == "safe" && $0.value == "active" }) { return nil }
            items.removeAll { $0.name == "safe" }
            items.append(URLQueryItem(name: "safe", value: "active"))
            comps.queryItems = items
            return comps.url
        }
    }
}

/// Full-screen in-app YouTube with the earned-time countdown. Auto-closes when
/// time runs out; a grown-up (or Gabriel) can close it any time with Done.
struct WatchYouTubeView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    /// Where to open. Defaults to YouTube; his Scratch favorites pass their own.
    var startURL: URL? = nil

    @State private var remaining = 0
    @State private var endDate: Date?
    @State private var elapsed = 0
    @State private var query = ""
    @State private var searchYouTube = false   // false = web (SafeSearch), true = YouTube
    @State private var navRequest: URL?
    @State private var poolEmptyTicks = 0
    @State private var openedAt = Date()
    @State private var spentMinutes = 0
    @State private var active = false
    @State private var showEarnMore = false   // out of time / hit cap → gentle prompt, not a hard cut
    // @State so the timer is created ONCE per session. As a plain `let` it was
    // rebuilt on every view refresh (which happens constantly as devices sync),
    // stacking many timers that each spent from the shared pool at the same
    // time — that's what drained his earned minutes away in seconds.
    @State private var ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var url: URL {
        // YouTube starts at the sign-in page (bounces to YouTube if already
        // signed in). A non-YouTube favorite like Ploofle Pals opens its own
        // page directly.
        let login = URL(string: "https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fwww.youtube.com%2F")!
        guard let s = startURL else { return login }
        let host = s.host?.lowercased() ?? ""
        if host.contains("youtube.") || host.contains("google.") { return login }
        return s
    }

    var body: some View {
        Group {
            if showEarnMore {
                EarnMorePrompt(capReached: state.dailyCapReached) { dismiss() }
            } else {
                VStack(spacing: 0) {
                    header
                    YouTubeWebView(url: url, navRequest: $navRequest)
                }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .onAppear {
            // No time (or today's cap is used up)? Show the friendly "earn more"
            // screen instead of flashing a doomed one-minute video.
            if state.availableMinutes <= 0 || state.dailyCapReached { showEarnMore = true; return }
            let mins = state.availableMinutes
            openedAt = Date()
            active = true
            endDate = Date().addingTimeInterval(Double(mins) * 60)
            remaining = mins * 60
            // Charge the first minute immediately on open. Otherwise a session
            // shorter than 60s deducts nothing, and he can bounce in and out of
            // the buttons for endless free minutes.
            state.recordWatchedMinute()
            spentMinutes = 1
        }
        .onReceive(ticker) { _ in
            guard active else { return }
            // One minute per minute of real watching, counting the CURRENT
            // minute up front (minute 1 was already charged on open). Even if an
            // extra timer fires, spending can't run past real time.
            let minutesEntered = Int(Date().timeIntervalSince(openedAt)) / 60 + 1
            while spentMinutes < minutesEntered {
                state.recordWatchedMinute()
                spentMinutes += 1
            }
            if let e = endDate { remaining = max(0, Int(e.timeIntervalSinceNow)) }
            // His session length is the local countdown from the time he had when
            // he opened it. Only bail on the shared pool if it stays empty for a
            // few seconds (a real Clear), so a brief sync dip from another device
            // can't kick him out mid-video.
            poolEmptyTicks = state.availableMinutes <= 0 ? poolEmptyTicks + 1 : 0
            if remaining <= 0 || poolEmptyTicks >= 6 || state.dailyCapReached {
                active = false
                showEarnMore = true    // gentle "earn more" screen instead of an abrupt close
            }
        }
        .onDisappear {
            active = false
            // A phone that just watched (signed in) refreshes the shared login
            // so the iPad's copy stays current.
            if UIDevice.current.userInterfaceIdiom != .pad {
                YTSession.export { _ in }
            }
        }
    }

    private func runSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty,
              let enc = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        // Search is YouTube-only — no open web search from inside the kid app.
        navRequest = URL(string: "https://www.youtube.com/results?search_query=\(enc)")
    }

    private var favoritesBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PortalDestination.all(youTubeURL: state.saved.youTubeURL)) { fav in
                    Button { navRequest = fav.url } label: {
                        HStack(spacing: 6) {
                            Text(fav.emoji).font(.system(size: 15))
                            Text(fav.title).font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(fav.bg).clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
        .background(Theme.bg)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Label("YouTube", systemImage: "play.rectangle.fill")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Theme.redGradient).clipShape(Capsule())
            TextField("Search YouTube…", text: $query)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .onSubmit(runSearch)
            Button { runSearch() } label: {
                Image(systemName: "magnifyingglass").font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Theme.bg)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Label("Done", systemImage: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "timer")
                Text(String(format: "%d:%02d", remaining / 60, remaining % 60))
                    .monospacedDigit()
            }
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Theme.redGradient).clipShape(Capsule())
            Spacer()
            Text("LearnTube")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Theme.bg)
    }
}


// MARK: - Safari-shared watch screen (kid iPad)
//
// SFSafariViewController uses Safari's real cookies, so a YouTube sign-in made
// in Safari (allowed for Family Link accounts, unlike the embedded web view)
// carries in and YouTube opens as Gabriel. Auto-closes when earned time ends.

struct SafariWatchView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let cfg = SFSafariViewController.Configuration()
        cfg.barCollapsingEnabled = false
        cfg.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: cfg)
        vc.dismissButtonStyle = .done
        return vc
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

struct SafariWatchScreen: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var url: URL {
        URL(string: state.saved.youTubeURL) ?? URL(string: "https://www.youtube.com")!
    }

    var body: some View {
        SafariWatchView(url: url)
            .ignoresSafeArea()
            .onReceive(ticker) { _ in
                if state.availableMinutes <= 0 { dismiss() }
            }
    }
}

/// Shown instead of abruptly closing the video: a warm nudge to go earn more
/// time, so running out never feels like a punishment or a glitch.
struct EarnMorePrompt: View {
    let capReached: Bool
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Text(capReached ? "🌙" : "⭐️").font(.system(size: 84))
            Text(capReached ? "All done with YouTube for today!" : "Time for a game!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white).multilineTextAlignment(.center)
            Text(capReached
                 ? "You watched a lot today. More YouTube tomorrow! 💛"
                 : "Finish a game to earn more YouTube time!")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: onBack) {
                Text(capReached ? "Okay!" : "Play a game! 🎮")
                    .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(capReached ? AnyShapeStyle(Theme.surfaceHi) : AnyShapeStyle(Theme.green))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg.ignoresSafeArea())
    }
}
