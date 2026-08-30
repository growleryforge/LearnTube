import SwiftUI
import UIKit

/// The Home tab: pick any concept, finish it, earn an hour of YouTube.
struct HomeFeedView: View {
    @EnvironmentObject var state: AppState
    @State private var watch: Skill?

    // Fit as many thumbnails as the screen allows at a consistent size:
    // ~2 across on iPhone, more on a wide Mac, each roughly the same width.
    private var cols: [GridItem] {
        [GridItem(.adaptive(minimum: 170, maximum: 220), spacing: 14)]
    }

    /// Games he can still pick: mastered games drop off so he moves on to new
    /// ones. Uses the merged family count so mastering across his phone + iPad
    /// removes it everywhere.
    private var available: [Skill] {
        let live = state.todaySkills.filter { !state.isRetired($0.id) }
        // Serve the easiest games first so he opens on a win, never on a fight:
        // games he's struggled with lately sink toward the bottom. Games already
        // finished today sink furthest, nudging him to a fresh one. He can still
        // scroll down to replay or tackle a harder one whenever he wants.
        return live.enumerated().sorted { a, b in
            // Kindergarten before Grade 1: he finishes the earlier grade first,
            // so brand-new higher-grade games can't jump ahead of unfinished K.
            if a.element.grade != b.element.grade { return a.element.grade < b.element.grade }
            let aDone = state.isDoneToday(a.element.id)
            let bDone = state.isDoneToday(b.element.id)
            if aDone != bDone { return !aDone }              // not-yet-done first
            let sa = state.struggleScore(a.element.id)
            let sb = state.struggleScore(b.element.id)
            if sa != sb { return sa < sb }                   // easiest (least struggle) first
            return a.offset < b.offset                       // stable fallback
        }.map { $0.element }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        Color.clear.frame(height: 1).id("top")
                        sectionLabel
                        ChampionCard()
                        // Only when there's time to watch; no lock when there isn't.
                        if state.canWatch { YouTubeTimeCard() }
                        if state.todaySkills.isEmpty {
                            jumpBadges(proxy)
                            EmptyFeed()
                        } else if available.isEmpty {
                            jumpBadges(proxy)
                            AllMasteredFeed()
                        } else {
                            jumpBadges(proxy)
                            LazyVGrid(columns: cols, spacing: 14, pinnedViews: []) {
                                ForEach(available) { skill in
                                    let maxed = !state.canPlay(skill.id)
                                    StopTile(skill: skill, done: state.isDoneToday(skill.id), maxed: maxed,
                                             plays: state.completionCount(skill.id),
                                             masteryGoal: state.saved.masteryThreshold,
                                             level: state.currentLevel(skill.id))
                                        .onTapGesture { if !maxed { GameDifficulty.level = state.currentLevel(skill.id); GameStats.begin(skill.id); watch = skill } }
                                }
                            }
                        }
                        // The kid's reward collection + celebration wall, on Home.
                        MyFarmCard().id("myfarm")
                        MyWinsCard().id("mywins")
                        backToTopButton(proxy)
                        // Clear the floating tab bar so the last row is fully visible.
                        Color.clear.frame(height: 96)
                    }
                    .padding(.horizontal, 14).padding(.top, 10)
                }
            }
        }
        .fullScreenCover(item: $watch) { WatchView(skill: $0) }
    }

    /// Two tappable badges at the top - My Farm and My Wins - that jump down to
    /// each collection.
    private func jumpBadges(_ proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 10) {
            jumpBadge(proxy, target: "myfarm", icon: "pawprint.fill", title: "My Farm",
                      trailing: "\(state.earnedBuddyCount)/\(Buddies.all.count)")
            jumpBadge(proxy, target: "mywins", icon: "trophy.fill", title: "My Wins",
                      trailing: "\(state.totalStars)⭐️")
        }
    }

    private func backToTopButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            withAnimation(.easeInOut) { proxy.scrollTo("top", anchor: .top) }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.up").font(.system(size: 13, weight: .bold))
                Text("Back to top").font(.system(size: 15, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 13).frame(maxWidth: .infinity)
            .background(Theme.surface).clipShape(Capsule())
        }
    }

    private func jumpBadge(_ proxy: ScrollViewProxy, target: String, icon: String,
                           title: String, trailing: String) -> some View {
        Button {
            withAnimation(.easeInOut) { proxy.scrollTo(target, anchor: .top) }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 15)).foregroundStyle(Theme.gold)
                Text(title).font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer(minLength: 2)
                Text(trailing).font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.gold)
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Theme.surface).clipShape(Capsule())
        }
    }

    private var sectionLabel: some View {
        Text("Every lesson you do earns more time!")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - YouTube time card (earn / watch)

/// One of his allowed web destinations, shown as a tappable favorite.
struct PortalDestination: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let url: URL
    let bg: AnyShapeStyle

    /// The shared favorites, used on the home card and inside the browser.
    static func all(youTubeURL: String) -> [PortalDestination] {
        [
            PortalDestination(title: "YouTube", emoji: "▶️",
                url: URL(string: youTubeURL) ?? URL(string: "https://www.youtube.com")!,
                bg: AnyShapeStyle(Theme.redGradient)),
            // Kept by request — his favorite. The others stay removed.
            PortalDestination(title: "Ploofle Pals", emoji: "🐱",
                url: URL(string: "https://scratch.mit.edu/search/projects?q=ploofle%20pals")!,
                bg: AnyShapeStyle(Color.orange))
        ]
    }
}

struct YouTubeTimeCard: View {
    @EnvironmentObject var state: AppState
    @State private var portal: PortalDestination?
    @Environment(\.horizontalSizeClass) private var hSize

    private var favorites: [PortalDestination] { PortalDestination.all(youTubeURL: state.saved.youTubeURL) }

    // Buttons that flow to fill the available width. Narrow min on iPhone (2
    // across), wider on Mac/iPad. Titles shrink to fit rather than clip.
    @ViewBuilder private func favButtons(minWidth: CGFloat) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minWidth), spacing: 10)], spacing: 10) {
            ForEach(favorites) { fav in
                Button { portal = fav } label: {
                    HStack(spacing: 9) {
                        Text(fav.emoji).font(.system(size: 22))
                        Text(fav.title)
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .lineLimit(1).minimumScaleFactor(0.65)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(fav.bg).clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    var body: some View {
        Group {
            if state.availableMinutes <= 0 {
                HStack(spacing: 10) {
                    Text("🎮").font(.system(size: 22))
                    Text("Play a game to earn YouTube time!")
                        .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                Group {
                    if hSize == .compact {
                        // iPhone: label on top, buttons fill the full width below.
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time to Play")
                                .font(.system(size: 21, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                            favButtons(minWidth: 150)
                        }
                    } else {
                        // Mac / iPad: label to the left, buttons flow beside it.
                        HStack(alignment: .center, spacing: 16) {
                            Text("Time to Play")
                                .font(.system(size: 21, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize()
                            favButtons(minWidth: 200)
                        }
                    }
                }
                .padding(16).frame(maxWidth: .infinity)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        // Locked in-app browser for his favorites. Time counts down while he
        // watches or plays, and it closes when the earned time runs out.
        .fullScreenCover(item: $portal) { WatchYouTubeView(startURL: $0.url).environmentObject(state) }
    }
}

// MARK: - Stop tile (a concept = a mini-game)

struct StopTile: View {
    let skill: Skill
    let done: Bool
    var maxed: Bool = false
    var plays: Int = 0          // how many times this game has been completed
    var masteryGoal: Int = 3    // completions needed to count as mastered
    var level: Int = 1          // current difficulty level (shown when > 1)
    private var buddy: Buddy { Buddies.forSkill(skill) }
    private var mastered: Bool { plays >= masteryGoal }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                LessonThumb(skill: skill).frame(maxWidth: .infinity).frame(height: 116).clipped()
                // YouTube-style dark gradient + centered play button
                LinearGradient(colors: [.clear, .clear, .black.opacity(0.35)],
                               startPoint: .top, endPoint: .bottom)
                if !done {
                    ZStack {
                        Circle().fill(.black.opacity(0.32)).frame(width: 54, height: 54)
                        Image(systemName: "play.fill").font(.system(size: 22)).foregroundStyle(.white)
                    }
                }
                // duration pill (bottom-right) like a YouTube thumbnail
                VStack { Spacer(); HStack {
                    Spacer()
                    Text(done ? "✓ Done" : skill.duration)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(.black.opacity(0.7)).clipShape(Capsule())
                        .padding(7)
                } }
                if level > 1 {
                    VStack { HStack {
                        Text("Lv \(level)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Theme.redGradient).clipShape(Capsule())
                            .padding(7)
                        Spacer()
                    }; Spacer() }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 116)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(skill.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(skill.subject.title) • \(skill.lesson.kindLabel)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary).lineLimit(1)
                // Mastery: how many times he's finished this game (under the title).
                HStack(spacing: 5) {
                    Image(systemName: mastered ? "star.fill" : "star")
                        .font(.system(size: 12)).foregroundStyle(mastered ? Theme.green : Theme.textSecondary)
                    Text(maxed ? "All done today!" : "Mastery \(plays)/\(masteryGoal)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(mastered ? Theme.green : Theme.textSecondary)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 196)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(done ? Theme.green.opacity(0.5) : .clear, lineWidth: 2))
        .opacity(maxed ? 0.5 : 1)
    }
}

// MARK: - Lesson thumbnail (a real frame from the game, YouTube-style)

/// Shows an actual preview of each lesson's game so the home feed pulls Gabriel
/// in, instead of a generic icon. Falls back to a colorful badge for any
/// lesson without a custom preview.
struct LessonThumb: View {
    let skill: Skill

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 116)
        .clipped()
    }

    private func hills(_ c: Color) -> some View {
        Hills().fill(c).frame(height: 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder private var background: some View {
        switch skill.id {
        case "K-R14":   // Syllable Safari — warm savanna
            LinearGradient(colors: [Color(red: 0.98, green: 0.72, blue: 0.36), Color(red: 0.99, green: 0.88, blue: 0.60)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.80, green: 0.62, blue: 0.30))
        case "K-R15":   // Baby Animal Names — soft pink
            LinearGradient(colors: [Color(red: 0.98, green: 0.60, blue: 0.72), Color(red: 0.99, green: 0.86, blue: 0.90)],
                           startPoint: .top, endPoint: .bottom)
        case "K-S18":   // Animal Groups — meadow green
            LinearGradient(colors: [Color(red: 0.52, green: 0.82, blue: 0.60), Color(red: 0.88, green: 0.95, blue: 0.82)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.70, blue: 0.44))
        case "K-S19":   // Animal Sounds — sunny yellow
            LinearGradient(colors: [Color(red: 0.99, green: 0.84, blue: 0.36), Color(red: 0.99, green: 0.93, blue: 0.70)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.46, green: 0.72, blue: 0.42))
        case "K-S20":   // Four Seasons — sky
            LinearGradient(colors: [Color(red: 0.55, green: 0.80, blue: 0.96), Color(red: 0.92, green: 0.96, blue: 0.86)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.46, green: 0.74, blue: 0.44))
        case "K-S21":   // Swim, Fly, or Walk? — ocean/sky teal
            LinearGradient(colors: [Color(red: 0.40, green: 0.78, blue: 0.90), Color(red: 0.82, green: 0.94, blue: 0.92)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.42, green: 0.72, blue: 0.46))
        case "K-S22":   // Parts of a Plant — garden green
            LinearGradient(colors: [Color(red: 0.60, green: 0.85, blue: 0.55), Color(red: 0.90, green: 0.96, blue: 0.80)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.66, blue: 0.36))
        case "K-S23":   // Hot or Cold? — warm-to-cool
            LinearGradient(colors: [Color(red: 0.98, green: 0.52, blue: 0.38), Color(red: 0.55, green: 0.80, blue: 0.96)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-MATH21", "K-MATH22":   // skip counting — bright blue
            LinearGradient(colors: [Color(red: 0.58, green: 0.82, blue: 0.97), Color(red: 0.87, green: 0.94, blue: 0.87)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.44, green: 0.74, blue: 0.44))
        case "K-STORY1":
            LinearGradient(colors: [Color(red: 1.0, green: 0.80, blue: 0.45), Color(red: 0.97, green: 0.93, blue: 0.72)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.50, green: 0.74, blue: 0.40))
        case "K-MATH1", "K-MATH2", "K-MATH3":
            LinearGradient(colors: [Color(red: 0.65, green: 0.85, blue: 0.98), Color(red: 0.86, green: 0.95, blue: 0.86)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.42, green: 0.74, blue: 0.42))
        case "K-MATH4", "K-MATH5":
            LinearGradient(colors: [Color(red: 0.78, green: 0.74, blue: 0.96), Color(red: 0.93, green: 0.88, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-MATH10":
            LinearGradient(colors: [Color(red: 0.55, green: 0.78, blue: 0.95), Color(red: 0.86, green: 0.92, blue: 0.80)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.46, green: 0.72, blue: 0.42))
        case "G1-M4":
            LinearGradient(colors: [Color(red: 0.42, green: 0.70, blue: 0.52), Color(red: 0.86, green: 0.93, blue: 0.74)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.66, blue: 0.40))
        case "K-S6":
            LinearGradient(colors: [Color(red: 0.40, green: 0.72, blue: 0.86), Color(red: 0.80, green: 0.92, blue: 0.74)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.42, green: 0.70, blue: 0.42))
        case "K-MATH12":
            LinearGradient(colors: [Color(red: 0.60, green: 0.78, blue: 0.50), Color(red: 0.88, green: 0.93, blue: 0.74)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.44, green: 0.68, blue: 0.40))
        case "K-S7":
            LinearGradient(colors: [Color(red: 0.86, green: 0.66, blue: 0.42), Color(red: 0.94, green: 0.88, blue: 0.70)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.50, green: 0.66, blue: 0.40))
        case "K-S8":
            LinearGradient(colors: [Color(red: 0.52, green: 0.76, blue: 0.46), Color(red: 0.90, green: 0.92, blue: 0.70)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.44, green: 0.68, blue: 0.40))
        case "K-MATH13":
            LinearGradient(colors: [Color(red: 0.50, green: 0.66, blue: 0.92), Color(red: 0.84, green: 0.90, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-S9":
            LinearGradient(colors: [Color(red: 0.96, green: 0.74, blue: 0.52), Color(red: 0.99, green: 0.90, blue: 0.74)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.48, green: 0.68, blue: 0.42))
        case "K-S10":
            LinearGradient(colors: [Color(red: 0.48, green: 0.74, blue: 0.50), Color(red: 0.86, green: 0.92, blue: 0.72)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.42, green: 0.66, blue: 0.40))
        case "K-S11":
            LinearGradient(colors: [Color(red: 0.32, green: 0.34, blue: 0.62), Color(red: 0.62, green: 0.66, blue: 0.90)],
                           startPoint: .top, endPoint: .bottom)
        case "K-MATH14":
            LinearGradient(colors: [Color(red: 0.46, green: 0.64, blue: 0.92), Color(red: 0.82, green: 0.88, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-MATH15":
            LinearGradient(colors: [Color(red: 0.52, green: 0.70, blue: 0.92), Color(red: 0.84, green: 0.90, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-S12":
            LinearGradient(colors: [Color(red: 0.94, green: 0.84, blue: 0.50), Color(red: 0.98, green: 0.93, blue: 0.74)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.48, green: 0.68, blue: 0.42))
        case "K-S13":
            LinearGradient(colors: [Color(red: 0.86, green: 0.66, blue: 0.40), Color(red: 0.96, green: 0.88, blue: 0.66)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.50, green: 0.66, blue: 0.38))
        case "K-S3":
            LinearGradient(colors: [Color(red: 0.96, green: 0.66, blue: 0.40), Color(red: 0.98, green: 0.86, blue: 0.66)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-S2":
            LinearGradient(colors: [Color(red: 0.46, green: 0.76, blue: 0.50), Color(red: 0.84, green: 0.92, blue: 0.70)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.66, blue: 0.38))
        case "K-MATH11":
            LinearGradient(colors: [Color(red: 0.66, green: 0.58, blue: 0.92), Color(red: 0.88, green: 0.84, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-R6":
            LinearGradient(colors: [Color(red: 0.36, green: 0.74, blue: 0.80), Color(red: 0.70, green: 0.90, blue: 0.88)],
                           startPoint: .top, endPoint: .bottom)
        case "K-M5":
            LinearGradient(colors: [Color(red: 0.42, green: 0.62, blue: 0.92), Color(red: 0.78, green: 0.86, blue: 0.98)],
                           startPoint: .top, endPoint: .bottom)
        case "K-MATH6":
            LinearGradient(colors: [Color(red: 0.55, green: 0.80, blue: 0.70), Color(red: 0.82, green: 0.93, blue: 0.86)],
                           startPoint: .top, endPoint: .bottom)
        case "K-MATH9":
            LinearGradient(colors: [Color(red: 0.96, green: 0.70, blue: 0.40), Color(red: 0.98, green: 0.88, blue: 0.70)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-MATH7":
            LinearGradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.55), Color(red: 0.98, green: 0.85, blue: 0.62)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-MATH8":
            LinearGradient(colors: [Color(red: 0.50, green: 0.62, blue: 0.88), Color(red: 0.80, green: 0.86, blue: 0.96)],
                           startPoint: .top, endPoint: .bottom)
        case "K-R10":
            LinearGradient(colors: [Color(red: 0.52, green: 0.80, blue: 0.70), Color(red: 0.80, green: 0.92, blue: 0.78)],
                           startPoint: .top, endPoint: .bottom)
        case "K-S5":
            LinearGradient(colors: [Color(red: 0.46, green: 0.74, blue: 0.46), Color(red: 0.80, green: 0.90, blue: 0.66)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.66, blue: 0.36))
        case "K-SS4":
            LinearGradient(colors: [Color(red: 0.96, green: 0.55, blue: 0.62), Color(red: 0.99, green: 0.80, blue: 0.70)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-SS1":
            LinearGradient(colors: [Color(red: 0.30, green: 0.36, blue: 0.66), Color(red: 0.78, green: 0.40, blue: 0.44)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-SS2":
            LinearGradient(colors: [Color(red: 0.98, green: 0.78, blue: 0.42), Color(red: 0.96, green: 0.62, blue: 0.46)],
                           startPoint: .top, endPoint: .bottom)
        case "K-SS3":
            LinearGradient(colors: [Color(red: 0.62, green: 0.46, blue: 0.84), Color(red: 0.95, green: 0.66, blue: 0.52)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "K-S4":
            LinearGradient(colors: [Color(red: 0.45, green: 0.70, blue: 0.95), Color(red: 0.80, green: 0.90, blue: 0.99)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.50, green: 0.74, blue: 0.40))
        case "K-R9":
            LinearGradient(colors: [Color(red: 0.40, green: 0.78, blue: 0.86), Color(red: 0.62, green: 0.88, blue: 0.80)],
                           startPoint: .top, endPoint: .bottom)
        case "K-L1":
            LinearGradient(colors: [Color(red: 0.99, green: 0.86, blue: 0.40), Color(red: 0.98, green: 0.72, blue: 0.42)],
                           startPoint: .top, endPoint: .bottom)
        case "G1-R1", "G1-R2", "G1-R3", "G1-R4", "G1-R5", "G1-R6", "G1-R7":   // 1st grade reading — teal
            LinearGradient(colors: [Color(red: 0.36, green: 0.74, blue: 0.82), Color(red: 0.74, green: 0.92, blue: 0.90)],
                           startPoint: .top, endPoint: .bottom)
        case "G1-M1", "G1-M2", "G1-M3", "G1-M5", "G1-M6", "G1-M7", "G1-M8", "G1-M9", "G1-M10":   // 1st grade math — blue
            LinearGradient(colors: [Color(red: 0.48, green: 0.66, blue: 0.94), Color(red: 0.82, green: 0.90, blue: 0.99)],
                           startPoint: .top, endPoint: .bottom)
        case "G1-W1", "G1-W2", "G1-W3":   // 1st grade writing — violet
            LinearGradient(colors: [Color(red: 0.64, green: 0.56, blue: 0.92), Color(red: 0.89, green: 0.85, blue: 0.99)],
                           startPoint: .top, endPoint: .bottom)
        case "G1-S1", "G1-S2", "G1-S3":   // 1st grade science — green
            LinearGradient(colors: [Color(red: 0.50, green: 0.80, blue: 0.54), Color(red: 0.86, green: 0.95, blue: 0.78)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.40, green: 0.68, blue: 0.40))
        case "G1-L1", "G1-L2", "G1-L3":   // 1st grade life — warm gold
            LinearGradient(colors: [Color(red: 0.99, green: 0.82, blue: 0.42), Color(red: 0.99, green: 0.90, blue: 0.68)],
                           startPoint: .top, endPoint: .bottom)
        case "K-NUM1", "K-NUM2", "K-NUM3", "K-NUM4":   // concrete number games — bright blue
            LinearGradient(colors: [Color(red: 0.42, green: 0.66, blue: 0.96), Color(red: 0.80, green: 0.90, blue: 0.99)],
                           startPoint: .top, endPoint: .bottom)
            hills(Color(red: 0.42, green: 0.70, blue: 0.44))
        case "K-W1", "K-W2", "K-W3":   // writing — warm pencil/paper
            LinearGradient(colors: [Color(red: 0.98, green: 0.80, blue: 0.46), Color(red: 0.99, green: 0.93, blue: 0.78)],
                           startPoint: .top, endPoint: .bottom)
        case "K-L2", "K-L3":   // life — warm
            LinearGradient(colors: [Color(red: 0.98, green: 0.72, blue: 0.52), Color(red: 0.99, green: 0.90, blue: 0.78)],
                           startPoint: .top, endPoint: .bottom)
        default:
            // Bright, playful fallback so a game without custom art still pops:
            // a sunny two-tone wash, a soft white highlight, and a grassy hill —
            // the same friendly look the hand-made thumbnails have.
            LinearGradient(colors: [skill.subject.color, skill.subject.color.opacity(0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            LinearGradient(colors: [.white.opacity(0.34), .clear],
                           startPoint: .top, endPoint: .center)
            hills(skill.subject.color.opacity(0.85))
        }
    }

    // Split into small per-group builders so no single SwiftUI switch
    // nests deep enough to overflow the launch stack on device.
    @ViewBuilder private var content: some View {
        let sid = skill.id
        if sid.hasPrefix("WU-") || sid.hasPrefix("TK-") || sid.hasPrefix("ST-") { bridgeContent }
        else if sid.hasPrefix("BR-") { brContent }
        else if sid.hasPrefix("G1-") { g1Content }
        else { kContent }
    }

    @ViewBuilder private var brContent: some View {
        switch skill.id {
        case "BR-M1":   // One More
            HStack(spacing: 5) {
                EmojiView(emoji: "🐤", size: 30, tint: .white)
                Text("+1").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "BR-M2":   // One Less
            HStack(spacing: 5) {
                EmojiView(emoji: "🍎", size: 30, tint: .white)
                Text("−1").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "BR-M3":   // Doubles to 20
            Text("7 + 7").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "BR-M4":   // Ten and Some More
            HStack(spacing: 6) {
                EmojiView(emoji: "🔟", size: 38, tint: .white)
                Text("+4").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "BR-M5":   // Count On
            Text("12 →").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "BR-M6":   // Fill the Ten
            HStack(spacing: 4) {
                EmojiView(emoji: "🐟", size: 26, tint: .white)
                EmojiView(emoji: "🐟", size: 26, tint: .white)
                EmojiView(emoji: "⬜", size: 24, tint: .white)
                EmojiView(emoji: "⬜", size: 24, tint: .white)
                Text("=?").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "BR-M7":   // Add Within 20
            Text("8 + 5").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "BR-M8":   // Take Away to 20
            Text("12 − 4").font(.system(size: 36, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "BR-M9":   // Ten More, Ten Less
            Text("+10").font(.system(size: 42, weight: .black, design: .rounded)).foregroundStyle(.white)
        default: EmptyView()
        }
    }

    @ViewBuilder private var bridgeContent: some View {
        switch skill.id {
        case "WU-M1":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                Text("+").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                Text("=?").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-M2":
            HStack(spacing: 6) {
                EmojiView(emoji: "🍪", size: 32, tint: .white)
                EmojiView(emoji: "🍪", size: 32, tint: .white)
                Text("−1").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-M3":
            HStack(spacing: 8) {
                EmojiView(emoji: "🔟", size: 40, tint: .white)
                Text("+3").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-M4":
            HStack(spacing: 5) {
                EmojiView(emoji: "🐤", size: 28, tint: .white)
                EmojiView(emoji: "🐤", size: 28, tint: .white)
                EmojiView(emoji: "🐤", size: 28, tint: .white)
                Text("…10").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-M5":
            HStack(spacing: 5) {
                EmojiView(emoji: "🦆", size: 30, tint: .white)
                Text("+").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🦆", size: 30, tint: .white)
                Text("=?").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-M6":
            HStack(spacing: 5) {
                EmojiView(emoji: "🐟", size: 30, tint: .white)
                EmojiView(emoji: "🐟", size: 30, tint: .white)
                Text("−?").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-R1":
            Text("c-a-t").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "WU-R2":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐶", size: 40, tint: .white)
                Text("d").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "WU-R3", "TK-R3":
            Text("cat · hat").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "TK-M1":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐤", size: 30, tint: .white)
                EmojiView(emoji: "🐤", size: 30, tint: .white)
                EmojiView(emoji: "🐤", size: 30, tint: .white)
                Text("3").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "TK-M2":
            Text("1 2 3 4 5").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "TK-M3":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐝", size: 30, tint: .white)
                EmojiView(emoji: "🐝", size: 30, tint: .white)
                EmojiView(emoji: "🐝", size: 30, tint: .white)
                Text("=?").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "TK-M4":
            HStack(spacing: 8) {
                EmojiView(emoji: "🐘", size: 48, tint: .white)
                EmojiView(emoji: "🐜", size: 22, tint: .white)
            }
        case "TK-M5":
            HStack(spacing: 6) {
                EmojiView(emoji: "🔴", size: 28, tint: .white)
                EmojiView(emoji: "🔵", size: 28, tint: .white)
                EmojiView(emoji: "🔴", size: 28, tint: .white)
                Text("?").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "TK-M6":
            HStack(spacing: 8) {
                EmojiView(emoji: "🔺", size: 34, tint: .white)
                EmojiView(emoji: "🟦", size: 34, tint: .white)
                EmojiView(emoji: "🟠", size: 34, tint: .white)
            }
        case "TK-C1":
            HStack(spacing: 6) {
                EmojiView(emoji: "🔴", size: 28, tint: .white)
                EmojiView(emoji: "🟡", size: 28, tint: .white)
                EmojiView(emoji: "🟢", size: 28, tint: .white)
                EmojiView(emoji: "🔵", size: 28, tint: .white)
            }
        case "TK-R1":
            HStack(spacing: 8) {
                Text("B").font(.system(size: 46, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("b").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "TK-R2":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐱", size: 40, tint: .white)
                Text("c").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "TK-S1":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                EmojiView(emoji: "🐱", size: 32, tint: .white)
                EmojiView(emoji: "🐰", size: 32, tint: .white)
            }
        case "TK-S2":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐦", size: 36, tint: .white)
                Text("→").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🏠", size: 36, tint: .white)
            }
        case "TK-S3":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐔", size: 36, tint: .white)
                Text("→").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐥", size: 36, tint: .white)
            }
        case "TK-L1":
            HStack(spacing: 10) {
                EmojiView(emoji: "😀", size: 42, tint: .white)
                EmojiView(emoji: "😢", size: 42, tint: .white)
            }
        case "ST-M1":
            Text("6 + 4").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "ST-M2":
            Text("10 − 4").font(.system(size: 38, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "ST-M3":
            Text("7  8  __  10").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "ST-M4":
            Text("4 + 4").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "ST-M5":
            HStack(spacing: 4) {
                EmojiView(emoji: "🐤", size: 26, tint: .white)
                EmojiView(emoji: "🐤", size: 26, tint: .white)
                EmojiView(emoji: "⬜", size: 24, tint: .white)
                EmojiView(emoji: "⬜", size: 24, tint: .white)
                Text("=?").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "ST-M6":
            Text("2 + 2 + 2").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "ST-R1":
            HStack(spacing: 10) {
                EmojiView(emoji: "📖", size: 44, tint: .white)
                EmojiView(emoji: "❓", size: 36, tint: .white).offset(y: -6)
            }
        case "ST-R2":
            HStack(spacing: 10) {
                EmojiView(emoji: "✏️", size: 40, tint: .white)
                Text("I ___").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        default: EmptyView()
        }
    }

    @ViewBuilder private var g1Content: some View {
        switch skill.id {
        case "G1-R1":   // Short and Long Vowels
            Text("a e i o u").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-R2":   // Team Sounds
            Text("sh ch th").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-R3":   // Word-Wall Words
            Text("said").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-R4":   // Read and Answer
            HStack(spacing: 12) {
                EmojiView(emoji: "📖", size: 46, tint: .white)
                EmojiView(emoji: "❓", size: 40, tint: .white).offset(y: -6)
            }
        case "G1-R5":   // Question Words
            HStack(spacing: 10) {
                EmojiView(emoji: "❓", size: 46, tint: .white)
                Text("who?").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-R6":   // Main Idea
            HStack(spacing: 12) {
                EmojiView(emoji: "💡", size: 46, tint: .white)
                EmojiView(emoji: "📖", size: 42, tint: .white).offset(y: -4)
            }
        case "G1-R7":   // Blends
            Text("st bl gr").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-W1":   // Build a Sentence
            HStack(spacing: 10) {
                EmojiView(emoji: "✏️", size: 42, tint: .white)
                Text("Cats run.").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-W2":   // Spot the Opinion
            HStack(spacing: 12) {
                EmojiView(emoji: "💭", size: 44, tint: .white)
                EmojiView(emoji: "👍", size: 40, tint: .white).offset(y: -6)
            }
        case "G1-W3":   // Put the Story in Order
            HStack(spacing: 8) {
                Text("1·2·3").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "📖", size: 42, tint: .white)
            }
        case "G1-M1":   // Count to 120
            HStack(spacing: 6) {
                Text("118·119·").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("120").font(.system(size: 38, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-M2":   // Add Within 20
            Text("8 + 5").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-M3":   // Subtract Within 20
            Text("14 − 6").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-M5":   // Tens and Ones
            HStack(spacing: 10) {
                EmojiView(emoji: "🔟", size: 44, tint: .white)
                Text("34").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-M6":   // Compare Numbers
            Text("54 > 45").font(.system(size: 38, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "G1-M7":   // Measure with Paperclips
            HStack(spacing: 6) {
                EmojiView(emoji: "📎", size: 40, tint: .white)
                EmojiView(emoji: "📎", size: 40, tint: .white)
                EmojiView(emoji: "📎", size: 40, tint: .white)
            }
        case "G1-M8":   // Tell Time
            HStack(spacing: 12) {
                EmojiView(emoji: "🕐", size: 48, tint: .white)
                EmojiView(emoji: "🕧", size: 48, tint: .white).offset(y: -6)
            }
        case "G1-M9":   // Tally and Count
            HStack(spacing: 10) {
                EmojiView(emoji: "✏️", size: 44, tint: .white)
                Text("| | | |").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-M10":   // Halves and Fourths
            HStack(spacing: 12) {
                EmojiView(emoji: "🍕", size: 48, tint: .white)
                Text("½  ¼").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "G1-S1":   // Light and Sound
            HStack(spacing: 14) {
                EmojiView(emoji: "🔦", size: 46, tint: .white)
                EmojiView(emoji: "🔊", size: 44, tint: .white).offset(y: -4)
            }
        case "G1-S2":   // Plant and Animal Parts
            HStack(spacing: 12) {
                EmojiView(emoji: "🌿", size: 46, tint: .white)
                EmojiView(emoji: "👂", size: 42, tint: .white).offset(y: -4)
            }
        case "G1-S3":   // Sky Patterns
            HStack(spacing: 10) {
                EmojiView(emoji: "☀️", size: 40, tint: .white)
                EmojiView(emoji: "🌙", size: 40, tint: .white).offset(y: -6)
                EmojiView(emoji: "⭐", size: 34, tint: .white)
            }
        case "G1-L1":   // Today's Date
            EmojiView(emoji: "📅", size: 60, tint: .white)
        case "G1-L2":   // Know Your Coins
            HStack(spacing: 10) {
                EmojiView(emoji: "🪙", size: 46, tint: .white)
                EmojiView(emoji: "💰", size: 44, tint: .white).offset(y: -4)
            }
        case "G1-L3":   // Calm-Down Game
            HStack(spacing: 12) {
                EmojiView(emoji: "🧘", size: 48, tint: .white)
                EmojiView(emoji: "🌬️", size: 40, tint: .white).offset(y: -4)
            }
        case "G1-M4":
            HStack(spacing: 8) {
                EmojiView(emoji: "🐤", size: 34, tint: .white)
                EmojiView(emoji: "🐤", size: 34, tint: .white).offset(y: -5)
                Text("+").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐤", size: 34, tint: .white)
                Text("=").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("?").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        default: EmptyView()
        }
    }

    @ViewBuilder private var kContent: some View {
        switch skill.id {
        case "K-NUM1":   // Count the Critters
            HStack(spacing: 8) {
                EmojiView(emoji: "🐤", size: 34, tint: .white)
                EmojiView(emoji: "🐤", size: 34, tint: .white).offset(y: -5)
                EmojiView(emoji: "🐤", size: 34, tint: .white)
                Text("=3").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-NUM2":   // How Many in All?
            HStack(spacing: 6) {
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                Text("+").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                Text("=?").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-NUM3":   // Count by 2s
            HStack(spacing: 10) {
                EmojiView(emoji: "👟", size: 34, tint: .white)
                EmojiView(emoji: "👟", size: 34, tint: .white)
                Text("2·4").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-NUM4":   // Count by 5s
            HStack(spacing: 8) {
                EmojiView(emoji: "🖐️", size: 40, tint: .white)
                Text("5·10").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-W1":   // Write Your Name
            HStack(spacing: 8) {
                EmojiView(emoji: "✏️", size: 42, tint: .white)
                Text("name").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-W2":   // Trace Capital Letters
            HStack(spacing: 8) {
                EmojiView(emoji: "✏️", size: 42, tint: .white)
                Text("ABC").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-W3":   // Label the Animal
            HStack(spacing: 8) {
                EmojiView(emoji: "✏️", size: 40, tint: .white)
                EmojiView(emoji: "🐄", size: 40, tint: .white)
            }
        case "K-M4":   // Number Order
            Text("0 1 2 3").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "K-R3":   // Letter Sounds Safari
            HStack(spacing: 8) {
                Text("A").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🦁", size: 40, tint: .white)
            }
        case "K-R5":   // Sound It Out
            Text("c-a-t").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "K-R6":   // Star Words
            HStack(spacing: 8) {
                EmojiView(emoji: "⭐", size: 40, tint: .white)
                Text("the").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-R7":   // What Happens First?
            HStack(spacing: 8) {
                Text("1·2·3").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "📖", size: 40, tint: .white)
            }
        case "K-R8":   // How Books Work
            EmojiView(emoji: "📖", size: 56, tint: .white)
        case "K-L2":   // Days of the Week
            HStack(spacing: 8) {
                EmojiView(emoji: "📅", size: 46, tint: .white)
                Text("7").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-L3":   // Be a Helper
            EmojiView(emoji: "🤝", size: 56, tint: .white)
        case "K-R14":   // Syllable Safari
            HStack(spacing: 10) {
                EmojiView(emoji: "🦒", size: 50, tint: .white)
                EmojiView(emoji: "👏", size: 38, tint: .white).offset(y: -8)
            }
        case "K-R15":   // Baby Animal Names
            HStack(spacing: 8) {
                EmojiView(emoji: "🐶", size: 40, tint: .white)
                EmojiView(emoji: "🐣", size: 40, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐱", size: 40, tint: .white)
            }
        case "K-S18":   // Animal Groups
            HStack(spacing: 8) {
                EmojiView(emoji: "🐕", size: 38, tint: .white)
                EmojiView(emoji: "🐦", size: 38, tint: .white).offset(y: -5)
                EmojiView(emoji: "🐟", size: 38, tint: .white)
                EmojiView(emoji: "🐝", size: 34, tint: .white).offset(y: -5)
            }
        case "K-S19":   // Animal Sounds
            HStack(spacing: 8) {
                EmojiView(emoji: "🐮", size: 48, tint: .white)
                EmojiView(emoji: "🎵", size: 38, tint: .white).offset(y: -8)
                EmojiView(emoji: "🎵", size: 30, tint: .white).offset(y: 6)
            }
        case "K-S20":   // Four Seasons
            HStack(spacing: 8) {
                EmojiView(emoji: "🌸", size: 36, tint: .white)
                EmojiView(emoji: "☀️", size: 36, tint: .white).offset(y: -5)
                EmojiView(emoji: "🍂", size: 36, tint: .white)
                EmojiView(emoji: "❄️", size: 36, tint: .white).offset(y: -5)
            }
        case "K-S21":   // Swim, Fly, or Walk?
            HStack(spacing: 10) {
                EmojiView(emoji: "🐟", size: 40, tint: .white)
                EmojiView(emoji: "🦅", size: 40, tint: .white).offset(y: -8)
                EmojiView(emoji: "🐕", size: 40, tint: .white)
            }
        case "K-S22":   // Parts of a Plant
            HStack(spacing: 8) {
                EmojiView(emoji: "🌸", size: 38, tint: .white)
                EmojiView(emoji: "🌿", size: 44, tint: .white).offset(y: -4)
                EmojiView(emoji: "🌱", size: 38, tint: .white)
            }
        case "K-S23":   // Hot or Cold?
            HStack(spacing: 16) {
                EmojiView(emoji: "🔥", size: 50, tint: .white)
                EmojiView(emoji: "❄️", size: 50, tint: .white).offset(y: -6)
            }
        case "K-MATH21":   // Count by 5s
            HStack(spacing: 10) {
                EmojiView(emoji: "🖐️", size: 46, tint: .white)
                Text("5·10·15").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-MATH22":   // Count by 2s
            HStack(spacing: 10) {
                EmojiView(emoji: "👀", size: 44, tint: .white)
                Text("2·4·6").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-STORY1":
            ZStack {
                Circle().fill(Color(red: 1.0, green: 0.86, blue: 0.30)).frame(width: 52, height: 52).offset(y: 30)
                RoosterView(size: 74).offset(y: -4)
            }
        case "K-MATH1":
            HStack(spacing: 12) {
                CountPal(color: Color(red: 0.95, green: 0.45, blue: 0.45), size: 46)
                CountPal(color: Color(red: 0.35, green: 0.62, blue: 0.92), size: 46).offset(y: -5)
                CountPal(color: Color(red: 0.45, green: 0.78, blue: 0.45), size: 46)
            }.offset(y: 4)
        case "K-MATH2":
            HStack(spacing: 8) {
                PetAvatar(imageName: "GabeMascot", size: 36)
                PetAvatar(imageName: "TigerCat", size: 36).offset(y: -5)
                PetAvatar(imageName: "PJCat", size: 36)
                PetAvatar(imageName: "Bodhi", size: 36).offset(y: -5)
            }.offset(y: 4)
        case "K-MATH3":
            HStack(spacing: 8) {
                EmojiView(emoji: "🐔", size: 34, tint: .white)
                EmojiView(emoji: "🐑", size: 34, tint: .white).offset(y: -5)
                EmojiView(emoji: "🐱", size: 34, tint: .white)
                EmojiView(emoji: "🐶", size: 34, tint: .white).offset(y: -5)
            }.offset(y: 4)
        case "K-MATH4":
            HStack(spacing: 12) {
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 38, height: 38)
                ShapeFigure(kind: .circle, color: ShapeKind.circle.color).frame(width: 38, height: 38).offset(y: -5)
                ShapeFigure(kind: .square, color: ShapeKind.square.color).frame(width: 36, height: 36)
            }
        case "K-MATH10":
            HStack(spacing: 10) {
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 30, height: 30)
                Text("+").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                ShapeFigure(kind: .square, color: ShapeKind.square.color).frame(width: 28, height: 28)
                Text("=").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                BuildCanvas(build: BuildGen.teachBuild, missingIndex: -1, canvas: 56).frame(width: 56, height: 56)
            }
        case "K-S3":
            HStack(spacing: 14) {
                EmojiView(emoji: "🛒", size: 48, tint: .white)
                EmojiView(emoji: "🛷", size: 46, tint: .white).offset(y: -4)
            }
        case "K-S2":
            HStack(spacing: 10) {
                EmojiView(emoji: "🌻", size: 44, tint: .white)
                EmojiView(emoji: "💧", size: 40, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐶", size: 44, tint: .white)
            }
        case "K-MATH11":
            ZStack {
                EmojiView(emoji: "📦", size: 54, tint: .white)
                EmojiView(emoji: "🐱", size: 38, tint: .white).offset(y: -34)
            }
        case "K-R6":
            Text("the")
                .font(.system(size: 50, weight: .black, design: .rounded)).foregroundStyle(.white)
        case "K-M5":
            HStack(spacing: 12) {
                Text("7").font(.system(size: 52, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text(">").font(.system(size: 36, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                Text("4").font(.system(size: 52, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-SS4":
            HStack(spacing: 10) {
                LionView(mane: true, glasses: false, cub: false).frame(width: 48, height: 48)
                LionView(mane: false, glasses: true, cub: false).frame(width: 48, height: 48).offset(y: -6)
                LionView(mane: false, glasses: false, cub: true).frame(width: 44, height: 44)
            }
        case "K-MATH9":
            HStack(alignment: .center, spacing: 14) {
                Circle().fill(.white).frame(width: 64, height: 64)
                Circle().fill(.white).frame(width: 30, height: 30)
            }
        case "K-MATH7":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐶", size: 30, tint: .white)
                EmojiView(emoji: "🐱", size: 30, tint: .white)
                EmojiView(emoji: "🐶", size: 30, tint: .white)
                Circle().strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 3])).foregroundStyle(.white.opacity(0.8))
                    .overlay(Text("?").font(.system(size: 18, weight: .black, design: .rounded)).foregroundStyle(.white))
                    .frame(width: 32, height: 32)
            }
        case "K-MATH8":
            HStack(spacing: 12) {
                ShapeFigure(kind: .square, color: ShapeKind.square.color).frame(width: 44, height: 44)
                Solid3DView(kind: .cube, color: Color(red: 0.50, green: 0.62, blue: 0.88)).frame(width: 54, height: 54)
            }
        case "K-R10":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐱", size: 46, tint: .white)
                EmojiView(emoji: "🎩", size: 46, tint: .white).offset(y: -6)
            }
        case "K-S5":
            HStack(spacing: 10) {
                EmojiView(emoji: "🌳", size: 48, tint: .white)
                EmojiView(emoji: "🦋", size: 44, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐶", size: 48, tint: .white)
            }
        case "K-S6":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐮", size: 44, tint: .white)
                EmojiView(emoji: "🐠", size: 42, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐧", size: 44, tint: .white)
            }
        case "K-MATH12":
            HStack(spacing: 12) {
                EmojiView(emoji: "🐶", size: 52, tint: .white)
                Text("4").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-S7":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐔", size: 44, tint: .white)
                EmojiView(emoji: "🐱", size: 44, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐟", size: 42, tint: .white)
            }
        case "K-S8":
            HStack(spacing: 8) {
                EmojiView(emoji: "🐰", size: 44, tint: .white)
                Text("→").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🥕", size: 40, tint: .white)
            }
        case "K-MATH13":
            HStack(spacing: 4) {
                Text("10").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("+").font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                EmojiView(emoji: "🐥", size: 30, tint: .white)
                EmojiView(emoji: "🐥", size: 30, tint: .white)
                EmojiView(emoji: "🐥", size: 30, tint: .white)
            }
        case "K-S9":
            HStack(spacing: 8) {
                EmojiView(emoji: "🐶", size: 50, tint: .white)
                Text("→").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐶", size: 30, tint: .white)
            }
        case "K-S10":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐶", size: 46, tint: .white)
                EmojiView(emoji: "🧸", size: 42, tint: .white).offset(y: -6)
                EmojiView(emoji: "🌻", size: 44, tint: .white)
            }
        case "K-S11":
            HStack(spacing: 10) {
                EmojiView(emoji: "🦉", size: 46, tint: .white)
                EmojiView(emoji: "🌙", size: 36, tint: .white).offset(y: -8)
                EmojiView(emoji: "🐝", size: 42, tint: .white)
            }
        case "K-MATH14":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐥", size: 34, tint: .white)
                EmojiView(emoji: "🐥", size: 34, tint: .white)
                EmojiView(emoji: "🐥", size: 34, tint: .white)
                Text("+?").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-MATH15":
            HStack(spacing: 12) {
                HStack(spacing: 3) {
                    EmojiView(emoji: "🐶", size: 28, tint: .white)
                    EmojiView(emoji: "🐶", size: 28, tint: .white)
                    EmojiView(emoji: "🐶", size: 28, tint: .white)
                }
                Text("vs").font(.system(size: 18, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                EmojiView(emoji: "🐶", size: 28, tint: .white)
            }
        case "K-S12":
            HStack(spacing: 10) {
                EmojiView(emoji: "🥚", size: 40, tint: .white)
                EmojiView(emoji: "🐔", size: 44, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐶", size: 44, tint: .white)
            }
        case "K-S13":
            HStack(spacing: 10) {
                EmojiView(emoji: "🐶", size: 46, tint: .white)
                EmojiView(emoji: "🦁", size: 46, tint: .white).offset(y: -6)
                EmojiView(emoji: "🐱", size: 42, tint: .white)
            }
        case "K-MATH6":
            HStack(spacing: 12) {
                Text("3").font(.system(size: 60, weight: .black, design: .rounded)).foregroundStyle(.white)
                VStack(spacing: 5) {
                    HStack(spacing: 5) { Circle().fill(.white).frame(width: 16, height: 16); Circle().fill(.white).frame(width: 16, height: 16) }
                    Circle().fill(.white).frame(width: 16, height: 16)
                }
            }
        case "K-MATH5":
            HStack(spacing: 14) {
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 42, height: 42).rotationEffect(.degrees(20))
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 30, height: 30).rotationEffect(.degrees(-35)).offset(y: -8)
                ShapeFigure(kind: .triangle, color: ShapeKind.triangle.color).frame(width: 36, height: 36).rotationEffect(.degrees(160))
            }
        case "K-S4":
            HStack(spacing: 12) {
                EmojiView(emoji: "☀️", size: 50, tint: .white)
                EmojiView(emoji: "🌧️", size: 50, tint: .white).offset(y: -6)
                EmojiView(emoji: "❄️", size: 50, tint: .white)
            }
        case "K-SS1":
            HStack(spacing: 10) {
                USFlagView().frame(width: 58, height: 38)
                EmojiView(emoji: "🦅", size: 40, tint: .white).offset(y: -6)
                EmojiView(emoji: "🗽", size: 40, tint: .white)
            }
        case "K-SS2":
            HStack(spacing: 10) {
                EmojiView(emoji: "🧑‍🚒", size: 48, tint: .white)
                EmojiView(emoji: "👮", size: 48, tint: .white).offset(y: -6)
                EmojiView(emoji: "🧑‍⚕️", size: 48, tint: .white)
            }
        case "K-SS3":
            HStack(spacing: 12) {
                EmojiView(emoji: "🦃", size: 48, tint: .white)
                EmojiView(emoji: "🎆", size: 48, tint: .white).offset(y: -6)
                EmojiView(emoji: "🎉", size: 48, tint: .white)
            }
        case "K-R9":
            HStack(spacing: 10) {
                Text("A").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("B").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white).offset(y: -6)
                Text("C").font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-L1":
            HStack(spacing: 4) {
                FaceEmoji(expr: .happy, size: 54)
                FaceEmoji(expr: .surprised, size: 46).offset(y: -6)
                FaceEmoji(expr: .sad, size: 54)
            }
        case "K-MATH16":
            HStack(spacing: 5) {
                EmojiView(emoji: "🐥", size: 30, tint: .white)
                EmojiView(emoji: "🐥", size: 30, tint: .white)
                EmojiView(emoji: "🐥", size: 30, tint: .white)
                Text("= 10").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
        case "K-MATH17":
            HStack(spacing: 6) {
                EmojiView(emoji: "🐤", size: 38, tint: .white)
                EmojiView(emoji: "🐤", size: 38, tint: .white)
                EmojiView(emoji: "🐤", size: 38, tint: .white).opacity(0.2)
            }
        case "K-MATH18":
            HStack(spacing: 4) {
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                Text("+").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                EmojiView(emoji: "🐶", size: 32, tint: .white)
                EmojiView(emoji: "🐶", size: 32, tint: .white)
            }
        case "K-MATH19":
            HStack(spacing: 8) {
                EmojiView(emoji: "🥇", size: 40, tint: .white)
                EmojiView(emoji: "🐶", size: 40, tint: .white).offset(y: -5)
                EmojiView(emoji: "🐱", size: 38, tint: .white)
                EmojiView(emoji: "🐰", size: 38, tint: .white).offset(y: -5)
            }
        case "K-MATH20":
            HStack(spacing: 8) {
                Text("10").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("20").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.9))
                Text("30").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.8))
            }
        case "K-R11":
            HStack(spacing: 10) {
                Text("B").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐻", size: 48, tint: .white).offset(y: -4)
            }
        case "K-R12":
            HStack(spacing: 8) {
                Text("B").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("b").font(.system(size: 58, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
            }
        case "K-R13":
            HStack(spacing: 10) {
                EmojiView(emoji: "🔥", size: 46, tint: .white)
                Text("vs").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white.opacity(0.85))
                EmojiView(emoji: "❄️", size: 46, tint: .white)
            }
        case "K-S14":
            HStack(spacing: 6) {
                EmojiView(emoji: "🥚", size: 38, tint: .white)
                Text("→").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🐛", size: 38, tint: .white).offset(y: -5)
                Text("→").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                EmojiView(emoji: "🦋", size: 40, tint: .white)
            }
        case "K-S15":
            HStack(spacing: 16) {
                EmojiView(emoji: "🐆", size: 48, tint: .white)
                EmojiView(emoji: "🐢", size: 44, tint: .white).offset(y: -5)
            }
        case "K-S16":
            HStack(spacing: 16) {
                EmojiView(emoji: "🦆", size: 46, tint: .white)
                EmojiView(emoji: "🪨", size: 42, tint: .white).offset(y: -5)
            }
        case "K-S17":
            HStack(spacing: 10) {
                EmojiView(emoji: "👀", size: 42, tint: .white)
                EmojiView(emoji: "👂", size: 42, tint: .white).offset(y: -5)
                EmojiView(emoji: "👃", size: 42, tint: .white)
            }
        default:
            ZStack {
                Circle().fill(.white.opacity(0.22)).frame(width: 70, height: 70)
                Image(systemName: Buddies.forSkill(skill).symbol)
                    .font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
            }
        }
    }
}

struct EmptyFeed: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 44)).foregroundStyle(Theme.green)
            Text("All done for now!").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text("A grown-up can switch grades in the Grown-Ups tab.")
                .font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(30).frame(maxWidth: .infinity).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

/// Shown when every game has been mastered, so there's nothing left to pick.
struct AllMasteredFeed: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy.fill").font(.system(size: 46)).foregroundStyle(Theme.green)
            Text("You mastered them all! 🎉")
                .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            Text("Amazing work. A grown-up can add more, switch grades, or reset mastery in the Grown-Ups tab.")
                .font(.system(size: 14, design: .rounded)).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(30).frame(maxWidth: .infinity).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

/// Home badge: Gabriel is the champion. His photo on a gold trophy, a blue
/// winner ribbon, and his tally of mastered games, buddies, and wins — so the
/// first thing he sees when he opens the app is that he's #1.
struct ChampionCard: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        let mastered = Curriculum.allSeededSkills.filter { state.mergedMastered($0.id) }.count
        return HStack(spacing: 0) {
            TrophyView(size: 80)
            Spacer(minLength: 10)
            // Name and his counts centered in the space between the two prizes.
            VStack(spacing: 10) {
                Text("Gabriel Turley")
                    .font(.system(size: 25, weight: .black, design: .rounded)).foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.6)
                HStack(spacing: 10) {
                    // Farm buddies and total wins are on the pills below, so the
                    // badge shows games mastered and his day streak instead —
                    // nothing here repeats a number shown elsewhere.
                    champStat("🏆", "\(mastered)")
                    champStat("🔥", "\(state.dayStreak)")
                }
            }
            Spacer(minLength: 10)
            // The ribbon is bottom-heavy (its tails hang below the rosette), so
            // keep the layout box at the trophy height and lift it a touch so the
            // rosette lines up with the trophy instead of sinking to the bottom.
            RibbonView(size: 72).frame(height: 80).offset(y: -12)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [Color(red: 0.30, green: 0.34, blue: 0.62),
                                            Color(red: 0.17, green: 0.21, blue: 0.44)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    private func champStat(_ e: String, _ n: String) -> some View {
        HStack(spacing: 3) {
            Text(e).font(.system(size: 14))
            Text(n).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(.white)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(.white.opacity(0.16)).clipShape(Capsule())
    }
}
