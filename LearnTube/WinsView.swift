import SwiftUI

/// "My Wins" - the kid's celebration wall, right on Home next to My Farm.
/// Encouraging stats, milestone badges, and a graded-paper feed of wins.
struct MyWinsCard: View {
    @EnvironmentObject var state: AppState
    private let cols = [GridItem(.adaptive(minimum: 88), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill").foregroundStyle(Theme.gold)
                Text("My Wins")
                    .font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer()
            }

            // Encouraging stats
            HStack(spacing: 10) {
                statChip("\(state.gamesFinished)", "games", "🎮")
                statChip("\(state.totalStars)", "stars", "⭐️")
                statChip("\(state.earnedBuddyCount)", "buddies", "🐾")
            }

            // Milestone badges
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(badges, id: \.title) { b in
                    VStack(spacing: 4) {
                        Text(b.unlocked ? b.emoji : "🔒").font(.system(size: 26))
                            .opacity(b.unlocked ? 1 : 0.55)
                        Text(b.title)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(b.unlocked ? .white : Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(b.unlocked ? Theme.green.opacity(0.18) : Theme.surfaceHi)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            // Graded-paper feed of recent wins
            if state.recentWins.isEmpty {
                Text("Finish a game to win your first star! 🌟")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Great work!")
                    .font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                VStack(spacing: 8) {
                    ForEach(Array(state.recentWins.prefix(8)), id: \.self) { w in
                        HStack(spacing: 10) {
                            Text(w.emoji).font(.system(size: 20))
                            Text(w.text)
                                .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(.white)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 15)).foregroundStyle(Theme.green)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .background(Theme.surfaceHi).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(18).frame(maxWidth: .infinity)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func statChip(_ value: String, _ label: String, _ emoji: String) -> some View {
        VStack(spacing: 2) {
            Text(emoji).font(.system(size: 20))
            Text(value).font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Theme.surfaceHi).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private struct Badge { let title: String; let emoji: String; let unlocked: Bool }

    private var badges: [Badge] {
        let g = state.gamesFinished, s = state.totalStars, b = state.earnedBuddyCount, m = state.masteredSkillCount
        return [
            Badge(title: "First Win", emoji: "🌟", unlocked: g >= 1),
            Badge(title: "High Five", emoji: "🖐️", unlocked: g >= 5),
            Badge(title: "Ten Games", emoji: "🔟", unlocked: g >= 10),
            Badge(title: "Star Power", emoji: "✨", unlocked: s >= 15),
            Badge(title: "Animal Pal", emoji: "🐶", unlocked: b >= 5),
            Badge(title: "All-Star", emoji: "🏆", unlocked: m >= 5)
        ]
    }
}
