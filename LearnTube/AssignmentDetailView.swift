import SwiftUI
import UIKit

struct WatchView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    let skill: Skill

    @State private var completed = false
    @State private var showCelebrate = false
    @State private var newBuddy: Buddy?
    @State private var showWatch = false
    @State private var justMastered = false

    private var isStory: Bool {
        if case .story = skill.lesson { return true } else { return false }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                watchBar
                if completed {
                    ScrollView {
                        completionPanel.padding(.horizontal, 14).padding(.top, 8)
                        Color.clear.frame(height: 24)
                    }
                } else if isStory {
                    LessonPlayerView(skill: skill, onComplete: finish)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                } else {
                    ScrollView {
                        LessonPlayerView(skill: skill, onComplete: finish)
                            .padding(.horizontal, 12).padding(.top, 6)
                        Color.clear.frame(height: 20)
                    }
                }
            }
            if showCelebrate {
                if justMastered { MasteryOverlay(title: skill.title) } else { CelebrationOverlay() }
            }
        }
        .inputShield()   // brief app-wide touch lock after a wrong tap (anti-guessing)
        .fullScreenCover(isPresented: $showWatch) { WatchYouTubeView().environmentObject(state) }
    }

    // Top bar with a back chevron, like tapping away from a video.
    private var watchBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    .padding(8)
            }
            Spacer()
            Text("Now Playing")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Color.clear.frame(width: 34, height: 1)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
    }

    // The "player" poster area.
    private var playerBanner: some View {
        ZStack {
            LinearGradient(colors: [skill.subject.color, skill.subject.color.opacity(0.6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(spacing: 14) {
                Image(systemName: skill.subject.icon)
                    .font(.system(size: 44, weight: .bold)).foregroundStyle(.white.opacity(0.9))
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.lesson.kindLabel.uppercased())
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(skill.title)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white).lineLimit(2)
                }
                Spacer()
            }
            .padding(18)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(skill.activity)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(skill.viewCount) • \(skill.standard)")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var channelRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(skill.subject.color).frame(width: 42, height: 42)
                Image(systemName: skill.subject.icon).font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("\(skill.subject.title) Channel")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text(masteryText)
                    .font(.system(size: 12, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if state.isDoneToday(skill.id) || completed {
                Label("Watched", systemImage: "checkmark")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Theme.surface).foregroundStyle(Theme.green).clipShape(Capsule())
            }
        }
    }

    private var masteryText: String {
        let c = state.completionCount(skill.id), t = state.saved.masteryThreshold
        return state.isMastered(skill.id) ? "Mastered 🏆" : "Mastery \(min(c,t))/\(t)"
    }

    private var completionPanel: some View {
        VStack(spacing: 14) {
            if let b = newBuddy {
                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(b.color).frame(width: 84, height: 84)
                        Image(systemName: b.symbol).font(.system(size: 40, weight: .bold)).foregroundStyle(.white)
                    }
                    Text("\(b.name) joined your farm!")
                        .font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(b.color)
                }
            } else {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 50)).foregroundStyle(Theme.green)
            }
            Text("You earned more YouTube time! 🎉")
                .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Watch now, or save it and earn more.")
                .font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button {
                showWatch = true
            } label: {
                Label("Watch YouTube now", systemImage: "play.fill")
            }
            .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.redGradient)))
            Button { dismiss() } label: { Text("Save it · back to games") }
                .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.surface)))
        }
        .padding(20).frame(maxWidth: .infinity)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var parentTip: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill").foregroundStyle(Theme.gold)
            Text(skill.parentTip)
                .font(.system(size: 13, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface.opacity(0.6)).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func finish() {
        let before = state.completionCount(skill.id)
        let threshold = state.saved.masteryThreshold
        newBuddy = state.markDone(skill.id)
        // Did THIS finish push him over the top into mastery? Then it's the big
        // three-star, ribbons-and-stars celebration, not the regular one.
        justMastered = before < threshold && state.completionCount(skill.id) >= threshold
        withAnimation { completed = true }
        showCelebrate = true
        hapticSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + (justMastered ? 2.6 : 1.7)) { showCelebrate = false }
    }

    private func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Bouncing celebration emoji over a soft scrim.
struct CelebrationOverlay: View {
    @State private var pop = false
    @State private var spin = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.38).ignoresSafeArea()
            Confetti()
            VStack(spacing: 14) {
                TrophyView(size: 168)
                    .rotationEffect(.degrees(spin ? -4 : 4))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: spin)
                Text("Gabriel  #1!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                    .background(Theme.redGradient).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
                HStack(spacing: 8) {
                    Mascot(mood: .cheer, size: 58)
                    Text("You're a winner!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(pop ? 1 : 0.4).opacity(pop ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.55), value: pop)
        }
        .onAppear { pop = true; spin = true }
        .allowsHitTesting(false)
    }
}

/// A golden trophy with Gabriel's real photo in the cup — he bought a trophy and
/// wrote "Gabriel #1" on it, so here he is, the champion, every time he wins.
struct TrophyView: View {
    var size: CGFloat = 160
    private let gold = Color(red: 1.0, green: 0.83, blue: 0.28)
    var body: some View {
        let s = size
        ZStack {
            Text("🏆").font(.system(size: s * 0.96))
            // Gabriel's real photo as a medallion on the cup.
            PetAvatar(imageName: "GabeMascot", size: s * 0.38)
                .overlay(Circle().stroke(gold, lineWidth: s * 0.03))
                .offset(y: -s * 0.12)
        }
        .frame(width: size, height: size)
    }
}

/// A blue winner ribbon rosette with a gold star and two tails.
struct RibbonView: View {
    var size: CGFloat = 60
    private let blue = Color(red: 0.26, green: 0.53, blue: 0.93)
    private let blueDark = Color(red: 0.16, green: 0.36, blue: 0.72)
    private let gold = Color(red: 1.0, green: 0.82, blue: 0.25)
    var body: some View {
        let s = size
        ZStack {
            HStack(spacing: s * 0.10) {
                RibbonTail().fill(blueDark).frame(width: s * 0.26, height: s * 0.55)
                RibbonTail().fill(blueDark).frame(width: s * 0.26, height: s * 0.55)
            }.offset(y: s * 0.52)
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    let a = Double(i) / 12.0 * 2.0 * .pi
                    Circle().fill(blue).frame(width: s * 0.26, height: s * 0.26)
                        .offset(x: CGFloat(cos(a)) * s * 0.33, y: CGFloat(sin(a)) * s * 0.33)
                }
                Circle().fill(blue).frame(width: s * 0.74, height: s * 0.74)
                Circle().fill(blueDark).frame(width: s * 0.58, height: s * 0.58)
                Text("#1").font(.system(size: s * 0.30, weight: .black, design: .rounded))
                    .foregroundStyle(gold).minimumScaleFactor(0.5)
            }
            .frame(width: s, height: s)
        }
        .frame(width: size, height: size * 1.5)
    }
}

struct RibbonTail: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: .init(x: r.minX, y: r.minY))
        p.addLine(to: .init(x: r.maxX, y: r.minY))
        p.addLine(to: .init(x: r.maxX, y: r.maxY))
        p.addLine(to: .init(x: r.midX, y: r.maxY - r.height * 0.28))
        p.addLine(to: .init(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// The big 3-star mastery moment — the trophy flanked by blue ribbons, gold
/// stars, and a proud "Gabriel is #1!". Bigger and louder than a normal win.
struct MasteryOverlay: View {
    let title: String
    @State private var pop = false
    private let gold = Color(red: 1.0, green: 0.82, blue: 0.25)
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            Confetti()
            BalloonsView()
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star.fill").font(.system(size: 30)).foregroundStyle(gold)
                    }
                }
                ZStack {
                    RibbonView(size: 72).offset(x: -122, y: 12)
                    RibbonView(size: 72).offset(x: 122, y: 12)
                    TrophyView(size: 178)
                }
                Text("MASTERED!")
                    .font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(gold)
                Text("Gabriel is #1!  🏆")
                    .font(.system(size: 26, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(Theme.redGradient).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
                HStack(spacing: 8) {
                    Mascot(mood: .cheer, size: 54)
                    Text("🥇 Three stars! 🌟")
                        .font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                }
            }
            .scaleEffect(pop ? 1 : 0.4).opacity(pop ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.55), value: pop)
        }
        .onAppear { pop = true }
        .allowsHitTesting(false)
    }
}

/// A transparent, full-screen touch shield shown for a beat after any wrong tap
/// (driven by GameGate). Invisible, but it swallows taps so he can't machine-gun
/// through the answers — works over EVERY game, procedural ones included.
struct InputShield: ViewModifier {
    @ObservedObject private var gate = GameGate.shared
    func body(content: Content) -> some View {
        content.overlay {
            if gate.blocked {
                Color.white.opacity(0.001)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
    }
}
extension View { func inputShield() -> some View { modifier(InputShield()) } }
