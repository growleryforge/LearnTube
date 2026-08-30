import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var state: AppState

    init() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(red: 0.055, green: 0.055, blue: 0.055, alpha: 1)
        tab.stackedLayoutAppearance.selected.iconColor = .white
        tab.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.6, alpha: 1)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            content
        }
        .background(Theme.bg.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var content: some View {
        #if PARENT
        // Parent dashboard — this build runs ONLY on the parent's Mac. Every
        // one of Gabriel's devices (iPhone, iPad, and his laptop) is games-only.
        // Includes a Games tab for testing.
        TabView {
            TodayDigestView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
            ProgressLibraryView()
                .tabItem { Label("Progress", systemImage: "star.fill") }
            InsightsView()
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }
            FamilyProgressView()
                .tabItem { Label("Family", systemImage: "person.2.fill") }
            HomeFeedView()
                .tabItem { Label("Games", systemImage: "gamecontroller.fill") }
            GrownUpsView()
                .tabItem { Label("Grown-Ups", systemImage: "person.crop.circle") }
        }
        .tint(Theme.gold)
        #else
        // Gabriel's iPhone AND iPad: just the games, no parent tabs, so he
        // never feels watched. Progress still records quietly and syncs to the
        // parent dashboard on the Mac.
        HomeFeedView()
        #endif
    }
}

/// Persistent YouTube-style top bar: the LearnTube wordmark + a reward pill.
struct TopBar: View {
    @EnvironmentObject var state: AppState

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "v\(v) · \(b)"
    }

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Theme.redGradient)
                        .frame(width: 52, height: 37)
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .offset(x: 1)
                }
                Text("LearnTube")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .layoutPriority(1)
                Text(appVersion)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.leading, 1)
            }
            Spacer()
            RewardPill()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
    }
}

struct RewardPill: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let mins = state.availableMinutes
        let lit = mins > 0
        HStack(spacing: 6) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 13, weight: .bold))
            Text(lit ? state.minutesLabel(mins) : "0 min")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(lit ? AnyShapeStyle(Theme.redGradient) : AnyShapeStyle(Theme.surface))
        .clipShape(Capsule())
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
