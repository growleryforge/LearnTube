import UIKit

/// Opens YouTube in the DuckDuckGo browser (ddgQuickLink://), falling back to
/// the default browser if DuckDuckGo isn't installed.
enum YouTubeLauncher {
    static func open(_ urlString: String) {
        // Normalize whatever is configured to an https YouTube web URL.
        var web = urlString.trimmingCharacters(in: .whitespaces)
        if web.isEmpty || web.hasPrefix("youtube://") { web = "https://www.youtube.com" }
        if !web.hasPrefix("http") { web = "https://" + web }

        let host = web
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        let httpsURL = URL(string: web) ?? URL(string: "https://www.youtube.com")!
        let app = UIApplication.shared

        // DuckDuckGo's "Open in DuckDuckGo" scheme.
        if let ddg = URL(string: "ddgQuickLink://\(host)") {
            app.open(ddg, options: [:]) { opened in
                if !opened { app.open(httpsURL, options: [:], completionHandler: nil) }
            }
        } else {
            app.open(httpsURL, options: [:], completionHandler: nil)
        }
    }
}
