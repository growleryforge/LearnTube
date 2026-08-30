import Foundation
import WebKit

/// One shared, persistent web session for every place LearnTube opens YouTube.
///
/// The old code built a fresh `WKWebViewConfiguration()` each time the watch
/// screen appeared. Each got its own process pool, so a sign-in made in one
/// instance was not reliably carried to the next — he'd end up logged OUT on the
/// next open, and a logged-out YouTube search is unfiltered. Reusing a single
/// process pool + the default (on-disk, persistent) data store keeps him signed
/// into his account across launches, so his account's restrictions govern search.
enum YTWeb {
    static let pool = WKProcessPool()

    /// The identifying cookies a real YouTube/Google login leaves behind. If any
    /// are present we already have a session and must not clobber it.
    static let loginCookieNames: Set<String> = [
        "SID", "SSID", "HSID", "SAPISID", "APISID",
        "__Secure-1PSID", "__Secure-3PSID", "LOGIN_INFO"
    ]

    @MainActor
    static func makeConfiguration() -> WKWebViewConfiguration {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.processPool = pool                    // shared across every web view
        c.websiteDataStore = .default()         // persistent, on-disk, shared
        // WKWebView's default user-agent is missing the "Version/… Safari/…"
        // token that real Safari sends, so Google flags it as an insecure
        // embedded browser and refuses to KEEP the account signed in. Appending
        // the Safari token makes the login stick like it does in Safari.
        c.applicationNameForUserAgent = "Version/17.0 Mobile/15E148 Safari/604.1"
        return c
    }

    /// True once he's signed in, so we don't overwrite a live session with a
    /// stale copied one.
    @MainActor
    static func hasLogin(_ store: WKHTTPCookieStore, _ done: @escaping (Bool) -> Void) {
        store.getAllCookies { cookies in
            done(cookies.contains { loginCookieNames.contains($0.name) })
        }
    }

    /// YouTube Restricted Mode + Google SafeSearch preference cookie, set on the
    /// shared store so results stay filtered even in a brief logged-out window.
    /// `f2=8000000` is YouTube's Restricted Mode bit inside the PREF cookie.
    @MainActor
    static func enforceRestricted(_ store: WKHTTPCookieStore, _ done: @escaping () -> Void) {
        let group = DispatchGroup()
        let year = Date().addingTimeInterval(60 * 60 * 24 * 365)
        for domain in [".youtube.com", ".google.com"] {
            if let c = HTTPCookie(properties: [
                .name: "PREF", .value: "f2=8000000&f6=8",
                .domain: domain, .path: "/", .expires: year, .secure: "TRUE"
            ]) {
                group.enter(); store.setCookie(c) { group.leave() }
            }
        }
        group.notify(queue: .main) { done() }
    }
}

/// A YouTube login cookie, stored so it can be copied between the family's
/// devices over iCloud (so the kid iPad keeps Gabriel's signed-in session).
struct StoredCookie: Codable {
    var name: String
    var value: String
    var domain: String
    var path: String
    var expires: Date?
    var isSecure: Bool

    init(_ c: HTTPCookie) {
        name = c.name; value = c.value; domain = c.domain; path = c.path
        expires = c.expiresDate; isSecure = c.isSecure
    }

    var httpCookie: HTTPCookie? {
        var props: [HTTPCookiePropertyKey: Any] = [
            .name: name, .value: value, .domain: domain, .path: path
        ]
        if let e = expires { props[.expires] = e }
        if isSecure { props[.secure] = "TRUE" }
        return HTTPCookie(properties: props)
    }
}

/// Copies the YouTube login session between this family's devices via iCloud,
/// so the kid iPad can reuse a sign-in done on a logged-in phone (Family Link
/// blocks a fresh sign-in inside the app, but a copied session works).
enum YTSession {
    static let key = "lt.ytcookies"
    private static let domains = ["youtube", "google", "ggpht", "ytimg", "gstatic", "googleusercontent", "googlevideo"]

    private static func relevant(_ c: HTTPCookie) -> Bool {
        let d = c.domain.lowercased()
        return domains.contains { d.contains($0) }
    }

    /// Read this device's YouTube cookies and publish them to iCloud.
    @MainActor
    static func export(_ completion: @escaping (Int) -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let coded = cookies.filter(relevant).map { StoredCookie($0) }
            if !coded.isEmpty, let data = try? JSONEncoder().encode(coded) {
                NSUbiquitousKeyValueStore.default.set(data, forKey: key)
                NSUbiquitousKeyValueStore.default.synchronize()
            }
            completion(coded.count)
        }
    }

    /// Prepare the shared session, then run `load`. Restricted Mode is always
    /// applied. The copied iCloud login is only injected when this device has no
    /// live session yet, so we never overwrite a good, already-persisted sign-in
    /// with a stale copy.
    @MainActor
    static func prepare(_ webView: WKWebView, then load: @escaping () -> Void) {
        let store = webView.configuration.websiteDataStore.httpCookieStore
        YTWeb.enforceRestricted(store) {
            YTWeb.hasLogin(store) { loggedIn in
                guard !loggedIn,
                      let data = NSUbiquitousKeyValueStore.default.data(forKey: key),
                      let coded = try? JSONDecoder().decode([StoredCookie].self, from: data) else {
                    load(); return
                }
                let cookies = coded.compactMap { $0.httpCookie }
                guard !cookies.isEmpty else { load(); return }
                let group = DispatchGroup()
                for c in cookies { group.enter(); store.setCookie(c) { group.leave() } }
                group.notify(queue: .main) { load() }
            }
        }
    }
}
