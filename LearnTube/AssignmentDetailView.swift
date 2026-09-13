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
    @State private var playRun = 0        // bumps to restart the player for Again!
    // Chaining: a ladder game can climb a step or two without leaving the
    // screen, so a math sitting is a rising arc instead of one short round.
    @State private var playedRung = 0        // the rung this round is playing
    @State private var rungsThisSitting = 1  // rungs played since the game opened (the cap)
    @State private var climbStreak = 1       // levels beaten back to back (the cheer)
    @State private var wrongLastRound = 0    // misses in the round just finished
    @State private var beatLevel: Int? = nil // the level he just beat, for the overlay
    @State private var bonusMinutes = 0      // extra minutes this finish paid
    @State private var bonusReasons: [String] = []

    private var isStory: Bool {
        if case .story = skill.lesson { return true } else { return false }
    }

    /// Games he plays by DRAGGING must fit on one screen. Inside a scroll view
    /// Every game fills the screen. Scrolling to find the answers is the single
    /// biggest reason he bounced: the question was at the top, the answers were
    /// below the fold, and nothing on screen said there was more. GameStage now
    /// puts the question in a bar across the top and hands the rest to the game.
    private var fillsScreen: Bool { true }

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
                } else {
                    LessonPlayerView(skill: skill, onComplete: finish).id(playRun)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                }
            }
            if showCelebrate {
                if justMastered {
                    MasteryOverlay(title: skill.title)
                } else if let lvl = beatLevel, let top = ladderTop {
                    LevelUpOverlay(level: lvl, top: top, streak: climbStreak)
                } else {
                    CelebrationOverlay()
                }
            }
        }
        .onAppear { if playedRung == 0 { playedRung = max(1, GameDifficulty.rung) } }
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
        if let l = state.ladder(skill.id) {
            if state.isLearned(skill.id) { return "Mastered 🏆" }
            // While chaining he is above his earned rung, so name the level in
            // front of him rather than the one the ladder has him banked on.
            let shown = max(l.rung, playedRung)
            return shown > l.rung ? "Level \(shown) of \(l.top)"
                                  : "Level \(l.rung) of \(l.top) · \(l.onRung)/\(t)"
        }
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
            // A ladder game reports itself as levels beaten, with the whole
            // ladder on show, so he can see how far he has come and how much is
            // left to beat. Everything else keeps the plain "you earned time".
            if let top = ladderTop, let beaten = beatLevel {
                Text("LEVEL \(beaten) BEATEN!")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)
                levelPips(beaten: beaten, top: top)
                Text(levelSubtitle(beaten: beaten, top: top))
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                if climbStreak > 1 {
                    Text("\(climbStreak) levels in a row! 🔥")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(.orange)
                }
            } else {
                Text("You earned more YouTube time! 🎉")
                    .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Watch now, or save it and earn more.")
                    .font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            // The bonus, called out by name. He should be able to see that the
            // extra minutes came from beating a new level, or from a clean run,
            // not from playing one more round.
            if bonusMinutes > 0 {
                VStack(spacing: 4) {
                    Text("BONUS  +\(bonusMinutes) min")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.gold)
                    Text(bonusReasons.joined(separator: "   "))
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10).padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Theme.gold.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            // Keep going: on a ladder game, step UP to the next rung right here
            // rather than replaying the same one. Capped per sitting, and never
            // offered after a rough round, so it lengthens the game without
            // turning it into a climb he can't stop.
            if let next = nextChainRung {
                Button {
                    keepGoing(to: next)
                } label: {
                    Label("Beat Level \(next)  →", systemImage: "flame.fill")
                }
                .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.green)))
            } else if state.canPlay(skill.id) && !state.isLearned(skill.id) {
                // Again!: a good game rolls straight into its next finish, which
                // is how it gets to 3 of 3 instead of being played once and buried.
                Button {
                    playAgain()
                } label: {
                    let onRung = state.ladder(skill.id)?.onRung ?? min(state.mergedCount(skill.id), state.saved.masteryThreshold)
                    Label("Again!  \(onRung) of \(state.saved.masteryThreshold) done", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.green)))
            }
            // While a level is still waiting in this sitting, YouTube isn't
            // offered here: the minutes are already banked (he is never docked
            // for stopping), the shortcut to spending them just isn't on this
            // screen until he's done climbing. Backing out to the games feed
            // always works, so he is never stuck.
            if nextChainRung == nil {
                Button {
                    showWatch = true
                } label: {
                    Label("Watch YouTube now", systemImage: "play.fill")
                }
                .buttonStyle(YTButtonStyle(background: AnyShapeStyle(Theme.redGradient)))
            }
            Button { dismiss() } label: {
                Text(nextChainRung == nil ? "Save it · back to games" : "Stop here · back to games")
            }
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

    /// How many levels this game's ladder has, if it is a ladder game at all.
    private var ladderTop: Int? { state.ladder(skill.id)?.top }

    /// The whole ladder on show: beaten levels lit gold, the rest waiting. This
    /// is the long view — he can see there is more to beat, not just one round.
    private func levelPips(beaten: Int, top: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(1...top, id: \.self) { n in
                ZStack {
                    Circle()
                        .fill(n <= beaten ? AnyShapeStyle(Theme.gold) : AnyShapeStyle(Color.white.opacity(0.14)))
                        .frame(width: 32, height: 32)
                    if n <= beaten {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .black)).foregroundStyle(Theme.ink)
                    } else {
                        Text("\(n)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
    }

    private func levelSubtitle(beaten: Int, top: Int) -> String {
        let left = top - beaten
        if left <= 0 { return "You beat every level! 🏆" }
        if left == 1 { return "1 more level to beat!" }
        return "\(left) more levels to beat!"
    }

    /// What Leo shouts out loud. Gets louder the further he climbs.
    private func levelCheer(beaten: Int, top: Int, streak: Int) -> String {
        if beaten >= top { return "You beat every level! You are the champion!" }
        switch streak {
        case 1:  return "Level \(beaten)! You beat it!"
        case 2:  return "Two levels in a row! Go Gabriel!"
        default: return "\(streak) levels in a row! You are on fire!"
        }
    }

    /// The rung he could climb to right now, or nil if the chain stops here.
    /// Ladder games only; there has to be a rung above the one he just played,
    /// room left in this sitting, a clean-enough round behind him, and plays
    /// left on the day.
    private var nextChainRung: Int? {
        guard let l = state.ladder(skill.id), !state.isLearned(skill.id) else { return nil }
        guard state.canPlay(skill.id) else { return nil }
        guard playedRung < l.top else { return nil }
        guard rungsThisSitting < AppState.maxChainRungs else { return nil }
        guard wrongLastRound < 2 else { return nil }   // struggling: don't push him up
        return playedRung + 1
    }

    private func keepGoing(to rung: Int) {
        playedRung = rung
        rungsThisSitting += 1
        climbStreak += 1
        GameDifficulty.rung = rung
        GameDifficulty.level = state.level(forRung: rung, id: skill.id)
        restartPlayer()
    }

    private func playAgain() {
        playedRung = state.currentRung(skill.id)
        climbStreak = 1          // a replay is not a climb; the cap stays where it is
        GameDifficulty.level = state.currentLevel(skill.id)
        GameDifficulty.rung = playedRung
        restartPlayer()
    }

    private func restartPlayer() {
        GameStats.begin(skill.id)
        newBuddy = nil; justMastered = false
        playRun += 1
        withAnimation { completed = false }
    }

    private func finish() {
        let before = state.completionCount(skill.id)
        let threshold = state.saved.masteryThreshold
        wrongLastRound = GameStats.wrongThisGame   // markDone resets this, so read it first
        beatLevel = ladderTop == nil ? nil : playedRung
        newBuddy = state.markDone(skill.id)
        bonusMinutes = state.lastWinBonus
        bonusReasons = state.lastWinBonusReasons
        // Did THIS finish push him over the top into mastery? Then it's the big
        // three-star, ribbons-and-stars celebration, not the regular one.
        justMastered = before < threshold && state.completionCount(skill.id) >= threshold
        withAnimation { completed = true }
        showCelebrate = true
        hapticSuccess()
        // Say it out loud too. Beating a level should feel like beating a level.
        if !justMastered {
            var line = ""
            if wrongLastRound == 0 {
                // Say the clean run FIRST and every time. This is the behaviour
                // we most want him to connect to getting something extra.
                line = "No mistakes! \(AppState.cleanRunBonus) extra minutes!"
            }
            if let lvl = beatLevel, let top = ladderTop {
                let cheer = levelCheer(beaten: lvl, top: top, streak: climbStreak)
                line = line.isEmpty ? cheer : line + " " + cheer
            }
            if !line.isEmpty { Leo.say(line) }
        }
        let hold = justMastered ? 2.6 : (beatLevel != nil ? 2.4 : 1.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + hold) { showCelebrate = false }
    }

    private func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Bouncing celebration emoji over a soft scrim.
/// Beating a level on a ladder game. Louder than an ordinary win and quieter
/// than MASTERED, with the whole ladder shown so the win lands as progress:
/// one more beaten, this many still to go.
struct LevelUpOverlay: View {
    let level: Int
    let top: Int
    let streak: Int
    @State private var pop = false
    @State private var spin = false
    private let gold = Color(red: 1.0, green: 0.82, blue: 0.25)

    private var allDone: Bool { level >= top }

    var body: some View {
        ZStack {
            Color.black.opacity(0.42).ignoresSafeArea()
            Confetti()
            if streak >= 3 || allDone { BalloonsView() }
            VStack(spacing: 12) {
                Text(allDone ? "ALL LEVELS BEATEN!" : "LEVEL \(level)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(gold)
                TrophyView(size: allDone ? 178 : 150)
                    .rotationEffect(.degrees(spin ? -4 : 4))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: spin)
                Text(allDone ? "CHAMPION!" : "BEATEN!")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28).padding(.vertical, 10)
                    .background(Theme.redGradient).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
                // The ladder itself: lit for beaten, dim for waiting.
                HStack(spacing: 7) {
                    ForEach(1...top, id: \.self) { n in
                        Circle()
                            .fill(n <= level ? AnyShapeStyle(gold) : AnyShapeStyle(Color.white.opacity(0.25)))
                            .frame(width: n <= level ? 18 : 13, height: n <= level ? 18 : 13)
                    }
                }
                if streak > 1 {
                    Text("\(streak) IN A ROW! 🔥")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.orange)
                }
                HStack(spacing: 8) {
                    Mascot(mood: .cheer, size: 54)
                    Text(allDone ? "You beat them all! 🏆"
                                 : (top - level == 1 ? "1 more to beat!" : "\(top - level) more to beat!"))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
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
