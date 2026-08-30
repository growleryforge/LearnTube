import SwiftUI

struct ProgressLibraryView: View {
    @EnvironmentObject var state: AppState
    @State private var expanded: Set<Int> = [-1, 0, 1]
    @State private var drillSkill: Skill?

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 12) {
                    headerCard
                    ForEach(Curriculum.grades) { grade in
                        GradeBlock(grade: grade,
                                   isOpen: expanded.contains(grade.number),
                                   toggle: { toggle(grade.number) },
                                   onTap: { drillSkill = $0 })
                    }
                    Color.clear.frame(height: 16)
                }
                .padding(.horizontal, 14).padding(.top, 10)
            }
        }
        .sheet(item: $drillSkill) { sk in
            SkillMissesView(skill: sk, misses: state.misses(for: sk.id),
                            wrong: state.mergedWrongCount(sk.id), done: state.mergedCount(sk.id))
                .environmentObject(state)
        }
    }

    private func toggle(_ n: Int) {
        if expanded.contains(n) { expanded.remove(n) } else { expanded.insert(n) }
    }

    private var headerCard: some View {
        let skills = Curriculum.allSeededSkills
        let total = skills.count
        let threshold = max(1, state.saved.masteryThreshold)
        let mastered = skills.filter { state.mergedMastered($0.id) }.count
        let leftToMaster = max(0, total - mastered)
        // Guessed through: finished enough times to "complete" but with too many
        // wrong taps to count as mastered. These come back to practice.
        let guessedThrough = skills.filter {
            state.mergedCount($0.id) >= threshold && state.isGuessy($0.id)
        }.count
        // Percent = games truly MASTERED (finished cleanly) out of the whole
        // library. A game he only guessed his way through does not count.
        let pct = total == 0 ? 0 : Int((Double(mastered) / Double(total) * 100).rounded())
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Gabriel's Progress")
                    .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer()
                Text("\(pct)%")
                    .font(.system(size: 30, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceHi).frame(height: 14)
                    Capsule().fill(Theme.green)
                        .frame(width: total == 0 ? 0 : max(8, geo.size.width * CGFloat(mastered)/CGFloat(total)), height: 14)
                }
            }.frame(height: 14)
            HStack(spacing: 10) {
                progStat("\(mastered)/\(total)", "mastered", Theme.gold)
                progStat("\(leftToMaster)", "left to master", .orange)
                progStat("\(guessedThrough)", "to redo clean", Theme.alertInk)
            }
            Text("Mastered means he finished a game \(threshold) times cleanly. Games he only got through by guessing don't count and come back to practice.")
                .font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func progStat(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(color)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label).font(.system(size: 11, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Theme.surfaceHi).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MyFarmCard: View {
    @EnvironmentObject var state: AppState
    private let cols = [GridItem(.adaptive(minimum: 64), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "pawprint.fill").foregroundStyle(Theme.gold)
                Text("My Farm")
                    .font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer()
                Text("\(state.earnedBuddyCount)/\(Buddies.all.count) buddies")
                    .font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(Buddies.all) { b in
                    let have = state.hasBuddy(b.id)
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().fill(have ? b.color : Theme.surfaceHi).frame(width: 54, height: 54)
                            Image(systemName: have ? b.symbol : "lock.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(have ? .white : Theme.textSecondary)
                        }
                        Text(have ? b.name : "???")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(have ? .white : Theme.textSecondary)
                    }
                }
            }
        }
        .padding(18).frame(maxWidth: .infinity)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct GradeBlock: View {
    @EnvironmentObject var state: AppState
    let grade: Grade
    let isOpen: Bool
    let toggle: () -> Void
    var onTap: (Skill) -> Void = { _ in }

    /// Weighted percent for THIS grade — every game needs `threshold` finishes,
    /// so a game done once counts as partial, not zero.
    private var gradePct: Int {
        guard grade.isSeeded else { return 0 }
        // Truly mastered (finished cleanly) out of the grade — guessing doesn't count.
        let total = grade.skills.count
        let mastered = state.mergedMasteredCount(inGrade: grade.number)
        return total == 0 ? 0 : Int((Double(mastered) / Double(total) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: toggle) {
                HStack(spacing: 10) {
                    Text(grade.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    if state.saved.activeGrade == grade.number {
                        Text("ACTIVE").font(.system(size: 10, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Theme.redGradient).foregroundStyle(.white).clipShape(Capsule())
                    }
                    Spacer()
                    if grade.isSeeded {
                        Text("\(gradePct)%")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(gradePct >= 100 ? Theme.green : Theme.gold)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background((gradePct >= 100 ? Theme.green : Theme.gold).opacity(0.16))
                            .clipShape(Capsule())
                        Text("\(state.mergedMasteredCount(inGrade: grade.number))/\(grade.skills.count)")
                            .font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        if state.mergedProgress(inGrade: grade.number) >= 1 { Text("🏆") }
                    } else {
                        Text("Soon").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
            }
            if isOpen {
                if grade.isSeeded {
                    VStack(spacing: 0) {
                        ForEach(grade.skills) { skill in
                            Button { onTap(skill) } label: {
                                HStack(spacing: 8) {
                                    SkillProgressRow(skill: skill)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textSecondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if skill.id != grade.skills.last?.id { Divider().overlay(Theme.surfaceHi) }
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 12)
                } else {
                    Text("New lessons grow here as Gabriel is ready. 🌱")
                        .font(.system(size: 13, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.bottom, 14)
                }
            }
        }
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SkillProgressRow: View {
    @EnvironmentObject var state: AppState
    let skill: Skill
    var body: some View {
        let count = state.mergedCount(skill.id)
        let threshold = state.saved.masteryThreshold
        return HStack(spacing: 12) {
            Image(systemName: skill.subject.icon)
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(skill.subject.color).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(skill.title).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                Text(skill.standard).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
                if let t = state.mergedLastPlayed(skill.id) {
                    Text("Last done \(rowDate(t))")
                        .font(.system(size: 10, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                }
            }
            Spacer()
            HStack(spacing: 3) {
                ForEach(0..<threshold, id: \.self) { i in
                    Image(systemName: i < count ? "star.fill" : "star")
                        .font(.system(size: 12)).foregroundStyle(i < count ? Theme.gold : Theme.surfaceHi)
                }
            }
        }
        .padding(.vertical, 10)
    }

    private func rowDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(d) ? "'today' h:mm a" : "MMM d"
        return f.string(from: d)
    }
}

// MARK: - Insights (what to work on)

/// Turns Gabriel's play data into plain-language guidance for grown-ups:
/// where he's struggling (wrong taps), what he keeps quitting (abandoned
/// games), what to focus on next, and where he's shining. All family-wide.
struct InsightsView: View {
    @EnvironmentObject var state: AppState
    @State private var drillSkill: Skill?    // tapped row -> show that skill's misses

    /// One skill's struggle metrics. `wrong`/`abandoned`/`done`/`accuracy` are the
    /// RECENT rolling window (so insights stay fresh and age out over time);
    /// `lifetime*` are all-time, used to spot skills he's since bounced back on.
    private struct Metric: Identifiable {
        let skill: Skill
        let wrong: Int          // recent wrong taps
        let abandoned: Int      // recent games opened but not finished
        let done: Int           // recent completions
        let accuracy: Double?   // recent finishes / (finishes + wrong)
        let lifetimeWrong: Int
        let lifetimeDone: Int
        var id: String { skill.id }
        var focusScore: Int { wrong + abandoned * 2 }   // quitting hurts more
        var hasActivity: Bool { wrong > 0 || abandoned > 0 || done > 0 }
    }

    /// Use the fresh rolling window once real recent data is flowing; until then
    /// fall back to lifetime totals so the tab isn't misleadingly empty.
    private var useRecent: Bool { state.hasAnyRecentData }

    private var metrics: [Metric] {
        Curriculum.allSeededSkills.map { s in
            Metric(skill: s,
                   wrong: useRecent ? state.recentWrong(s.id) : state.mergedWrongCount(s.id),
                   abandoned: useRecent ? state.recentAbandoned(s.id) : state.mergedAbandoned(s.id),
                   done: useRecent ? state.recentDone(s.id) : state.mergedCount(s.id),
                   accuracy: useRecent ? state.recentAccuracy(s.id) : state.accuracy(s.id),
                   lifetimeWrong: state.mergedWrongCount(s.id),
                   lifetimeDone: state.mergedCount(s.id))
        }
    }

    // MARK: - Grouping (mirrors the Today dashboard: wins first, then getting
    // there, then needs a look — each skill sorted into a bucket by how his
    // recent play is going, so grown-ups scan it the same way on both tabs.)

    private enum Bucket { case good, getting, look }

    /// Every skill he's actually touched in the window (others don't clutter).
    private var active: [Metric] { metrics.filter { $0.hasActivity } }

    private func bucket(_ m: Metric) -> Bucket {
        let acc = m.accuracy ?? 1
        if m.done == 0 { return .look }                                 // tried, never finished
        if m.abandoned >= 2 || acc < 0.6 || m.wrong >= 5 { return .look }
        if m.wrong == 0 && m.abandoned == 0 { return .good }            // clean runs
        if acc >= 0.8 && m.wrong <= 2 { return .good }
        return .getting
    }

    private var goodItems: [Metric] { active.filter { bucket($0) == .good }.sorted { $0.done > $1.done } }
    private var gettingItems: [Metric] { active.filter { bucket($0) == .getting }.sorted { $0.focusScore > $1.focusScore } }
    private var lookItems: [Metric] { active.filter { bucket($0) == .look }.sorted { $0.focusScore > $1.focusScore } }

    private func statLine(_ m: Metric) -> String {
        var parts: [String] = []
        if let a = m.accuracy { parts.append("\(Int(a * 100))% right") }
        if m.wrong > 0 { parts.append("\(m.wrong) wrong") }
        if m.abandoned > 0 { parts.append("\(m.abandoned) quit") }
        parts.append("\(m.done) done")
        return parts.joined(separator: "  \u{00B7}  ")
    }

    private func pillText(_ m: Metric) -> String {
        switch bucket(m) {
        case .good: return m.wrong == 0 ? "clean" : "going well"
        case .getting: return "getting there"
        case .look:
            if m.done == 0 { return "not finished" }
            if m.abandoned >= 2 { return "keeps quitting" }
            if (m.accuracy ?? 1) < 0.6 { return "guessing" }
            return "needs work"
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        headerCard(proxy)
                        groupedSection("Going well", "checkmark.seal.fill", Theme.green, goodItems, anchor: "ins_good")
                        groupedSection("Getting there", "arrow.up.right.circle.fill", Theme.gold, gettingItems, anchor: "ins_getting")
                        groupedSection("Needs a look", "exclamationmark.triangle.fill", Theme.alertInk, lookItems, anchor: "ins_look", pillFill: Theme.alertFill)
                        recentMissesCard
                        Color.clear.frame(height: 24)
                    }
                    .padding(.horizontal, 14).padding(.top, 10)
                }
            }
        }
        .sheet(item: $drillSkill) { sk in
            SkillMissesView(skill: sk, misses: state.misses(for: sk.id),
                            wrong: state.mergedWrongCount(sk.id), done: state.mergedCount(sk.id))
                .environmentObject(state)
        }
    }

    @ViewBuilder
    private func groupedSection(_ title: String, _ icon: String, _ tint: Color, _ items: [Metric], anchor: String, pillFill: Color? = nil) -> some View {
        let fill = pillFill ?? tint.opacity(0.16)
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: icon).font(.system(size: 15, weight: .bold)).foregroundStyle(tint)
                    Text(title).font(.system(size: 17, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    let total = active.count
                    let pct = total > 0 ? Int((Double(items.count) / Double(total) * 100).rounded()) : 0
                    Text("\(items.count)  \u{00B7}  \(pct)%").font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundStyle(tint)
                        .padding(.horizontal, 8).padding(.vertical, 2).background(fill).clipShape(Capsule())
                    Spacer()
                }
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { idx, m in
                        if idx > 0 { Divider().overlay(Theme.surfaceHi) }
                        groupRow(m, tint: tint, fill: fill)
                    }
                }
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .id(anchor)
        }
    }

    private func groupRow(_ m: Metric, tint: Color, fill: Color) -> some View {
        Button { drillSkill = m.skill } label: {
            HStack(spacing: 10) {
                Image(systemName: m.skill.subject.icon)
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(m.skill.subject.color).frame(width: 24)
                Text(m.skill.title).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white).lineLimit(1).layoutPriority(1)
                Spacer(minLength: 8)
                Text(statLine(m)).font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary).lineLimit(1).truncationMode(.head)
                Text(pillText(m)).font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundStyle(tint)
                    .lineLimit(1).padding(.horizontal, 10).padding(.vertical, 4).background(fill).clipShape(Capsule())
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 14).padding(.vertical, 12).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func navChip(_ text: String, _ icon: String, _ color: Color, fill: Color? = nil, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .bold))
                Text(text).font(.system(size: 13, weight: .heavy, design: .rounded)).fixedSize()
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).opacity(0.7)
            }
            .foregroundStyle(color)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(fill ?? color.opacity(0.16)).clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func scrollTo(_ anchor: String, _ proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) { proxy.scrollTo(anchor, anchor: .top) }
    }

    /// The raw detail: exactly which questions he got wrong, what he tapped, and
    /// what the right answer was — so grown-ups can diagnose (can't-read vs
    /// doesn't-know vs guessing). Tap a row to see the full history for a skill.
    private var recentMissesCard: some View {
        let recent = Array(state.mergedMisses.prefix(12))
        return card(title: "Exactly what he missed", icon: "text.magnifyingglass", tint: .orange,
                    subtitle: "His last wrong answers — what he tapped vs. the correct answer. Tap for a skill's full history.") {
            if recent.isEmpty {
                emptyLine("No wrong answers recorded yet — this fills in as he plays the updated app.")
            } else {
                ForEach(recent, id: \.self) { m in missRow(m, showSkill: true) }
            }
        }
    }

    @ViewBuilder private func missRow(_ m: MissEvent, showSkill: Bool) -> some View {
        let skill = Curriculum.skill(id: m.skill)
        Button { if let skill { drillSkill = skill } } label: {
            VStack(alignment: .leading, spacing: 4) {
                if showSkill {
                    HStack {
                        Text(skill?.title ?? m.skill)
                            .font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                        Spacer()
                        Text(Self.rel(m.date)).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                }
                Text(m.prompt)
                    .font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundStyle(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    tagView("tapped: \(m.tapped)", .red)
                    tagView("answer: \(m.correct)", Theme.green)
                    if !showSkill { Spacer(); Text(Self.rel(m.date)).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary) }
                }
            }
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .overlay(Divider().background(Theme.surfaceHi), alignment: .bottom)
    }

    private func tagView(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy, design: .rounded)).foregroundStyle(color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.16)).clipShape(Capsule())
    }

    static func rel(_ d: Date) -> String {
        let f = RelativeDateTimeFormatter(); f.unitsStyle = .short
        return f.localizedString(for: d, relativeTo: Date())
    }

    // MARK: Cards

    private func headerCard(_ proxy: ScrollViewProxy) -> some View {
        let totalWrong = active.reduce(0) { $0 + $1.wrong }
        let totalAband = active.reduce(0) { $0 + $1.abandoned }
        let g = goodItems.count, ge = gettingItems.count, lk = lookItems.count
        return VStack(alignment: .leading, spacing: 12) {
            Text("What to Work On")
                .font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            Text(useRecent
                 ? "From the last 2 weeks across all his devices. Older struggles clear as he improves."
                 : "Across all his devices. Switches to a fresh 2-week view as he plays the updated app.")
                .font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
            HStack(spacing: 10) {
                statBox("\(lk)", "need\na look", Theme.alertInk)
                statBox("\(totalWrong)", "wrong\ntaps", Theme.alertInk)
                statBox("\(totalAband)", "quit\nearly", Theme.alertInk)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if lk > 0 { navChip("\(lk) need a look", "exclamationmark.triangle.fill", Theme.alertInk, fill: Theme.alertFill) { scrollTo("ins_look", proxy) } }
                    if totalWrong > 0 { navChip("\(totalWrong) wrong tap\(totalWrong == 1 ? "" : "s")", "hand.tap.fill", Theme.alertInk, fill: Theme.alertFill) { scrollTo("ins_look", proxy) } }
                    if ge > 0 { navChip("\(ge) getting there", "arrow.up.right", Theme.gold) { scrollTo("ins_getting", proxy) } }
                    if g > 0 { navChip("\(g) going well", "checkmark", Theme.green) { scrollTo("ins_good", proxy) } }
                }
                .padding(.vertical, 1)
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func statBox(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 30, weight: .heavy, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 11, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Theme.surfaceHi).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    /// Reading vs guessing: wrong taps per finished game. A high rate means he's
    /// tapping around instead of reading the question. Uses lifetime totals so
    /// there's enough signal to be meaningful.
    private var readingCard: some View {
        let played = metrics.filter { $0.lifetimeDone >= 2 }
        let totalWrong = played.reduce(0) { $0 + $1.lifetimeWrong }
        let totalDone = max(1, played.reduce(0) { $0 + $1.lifetimeDone })
        let rate = Double(totalWrong) / Double(totalDone)   // avg misses per game
        let guessy = played
            .map { (m: $0, r: Double($0.lifetimeWrong) / Double(max(1, $0.lifetimeDone))) }
            .filter { $0.r >= 1.5 }
            .sorted { $0.r > $1.r }.prefix(5)
        let verdict = rate < 0.6 ? "He's reading before he answers 📖"
                    : rate < 1.5 ? "Mixed — reading some, guessing some"
                                 : "Lots of guessing — he's tapping around"
        return card(title: "Reading vs guessing", icon: "eyes", tint: rate < 0.6 ? Theme.green : (rate < 1.5 ? Theme.gold : .orange),
                    subtitle: "About \(String(format: "%.1f", rate)) wrong taps per finished game. \(verdict)") {
            if guessy.isEmpty {
                emptyLine("No guess-prone games right now. 👍")
            } else {
                ForEach(Array(guessy), id: \.m.id) { item in
                    insightRow(item.m.skill,
                               note: "≈\(String(format: "%.1f", item.r)) wrong taps each time",
                               trailing: "guessing?", tint: .orange)
                }
            }
        }
    }

    private var focusCard: some View {
        let picks = metrics
            .filter { !state.mergedMastered($0.skill.id) && $0.focusScore > 0 }
            .sorted { $0.focusScore > $1.focusScore }
            .prefix(5)
        return card(title: "Focus next", icon: "target", tint: Theme.gold,
                    subtitle: "Not mastered yet, and where he's struggled in the last 2 weeks.") {
            if picks.isEmpty {
                emptyLine("Nothing to work on lately — struggles clear as he improves. 🌱")
            } else {
                ForEach(Array(picks)) { m in
                    insightRow(m.skill, note: focusNote(m),
                               trailing: m.abandoned > 0 ? "\(m.abandoned)× quit" : "\(m.wrong) misses",
                               tint: Theme.gold)
                }
            }
        }
    }

    private var troubleCard: some View {
        let picks = metrics.filter { $0.wrong > 0 }
            .sorted { $0.wrong > $1.wrong }.prefix(6)
        return card(title: "Most mistakes", icon: "exclamationmark.triangle.fill", tint: .orange,
                    subtitle: "The concepts he gets wrong most often.") {
            if picks.isEmpty {
                emptyLine("No wrong answers recorded yet.")
            } else {
                ForEach(Array(picks)) { m in
                    insightRow(m.skill,
                               note: m.accuracy.map { "\(Int($0 * 100))% right" } ?? "learning",
                               trailing: "\(m.wrong) wrong", tint: .orange)
                }
            }
        }
    }

    private var unfinishedCard: some View {
        let picks = metrics.filter { $0.abandoned > 0 }
            .sorted { $0.abandoned > $1.abandoned }.prefix(6)
        return card(title: "Started but not finished", icon: "figure.walk.departure", tint: .red,
                    subtitle: "Games he opened and left. Often a sign it felt too hard.") {
            if picks.isEmpty {
                emptyLine("He's finishing what he starts. 👏")
            } else {
                ForEach(Array(picks)) { m in
                    insightRow(m.skill,
                               note: "opened \(m.abandoned + m.done), finished \(m.done)",
                               trailing: "\(m.abandoned)× left", tint: .red)
                }
            }
        }
    }

    /// Skills that used to be hard but he's recently turned around — the
    /// "changed perspective" signal: a struggle that's now going well.
    private var bouncedBackCard: some View {
        let picks = metrics.filter { m in
            m.lifetimeWrong >= 4 && m.done > 0 && m.focusScore == 0 &&
            (m.accuracy == nil || (m.accuracy ?? 1) >= 0.8) &&
            !state.mergedMastered(m.skill.id)
        }
        .sorted { $0.lifetimeWrong > $1.lifetimeWrong }.prefix(5)
        return card(title: "Bounced back", icon: "arrow.up.forward.circle.fill", tint: Theme.green,
                    subtitle: "Used to be tricky — lately he's been getting these right.") {
            if picks.isEmpty {
                emptyLine("Skills he's turned around will show up here. 💪")
            } else {
                ForEach(Array(picks)) { m in
                    insightRow(m.skill,
                               note: "was a struggle, now \(m.accuracy.map { "\(Int($0 * 100))% right" } ?? "going well")",
                               trailing: "\(m.done)× lately", tint: Theme.green)
                }
            }
        }
    }

    private var strengthsCard: some View {
        let picks = metrics
            .filter { state.mergedMastered($0.skill.id) || ($0.accuracy ?? 0) >= 0.9 }
            .sorted { ($0.accuracy ?? 1) > ($1.accuracy ?? 1) }
            .sorted { $0.lifetimeDone > $1.lifetimeDone }.prefix(6)
        return card(title: "Doing great", icon: "star.fill", tint: Theme.green,
                    subtitle: "Strong and steady — good for confidence-building wins.") {
            if picks.isEmpty {
                emptyLine("Strengths show up here as he masters skills.")
            } else {
                ForEach(Array(picks)) { m in
                    insightRow(m.skill,
                               note: state.mergedMastered(m.skill.id) ? "mastered" : "\(Int((m.accuracy ?? 1) * 100))% right",
                               trailing: "\(m.lifetimeDone)× done", tint: Theme.green)
                }
            }
        }
    }

    // MARK: Building blocks

    private func focusNote(_ m: Metric) -> String {
        if m.abandoned > 0 && m.wrong > 0 { return "quits early and misses answers" }
        if m.abandoned > 0 { return "keeps leaving this one" }
        if let a = m.accuracy { return "\(Int(a * 100))% right so far" }
        return "needs more practice"
    }

    private func card<Content: View>(title: String, icon: String, tint: Color,
                                     subtitle: String,
                                     @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(tint)
                Text(title).font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            }
            Text(subtitle).font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
            VStack(spacing: 0) { content() }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func insightRow(_ skill: Skill, note: String, trailing: String, tint: Color) -> some View {
        let count = state.misses(for: skill.id).count
        return Button { drillSkill = skill } label: {
            HStack(spacing: 12) {
                Image(systemName: skill.subject.icon)
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(skill.subject.color).frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.title).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                    Text("\(skill.standard) · \(note)")
                        .font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text(trailing)
                    .font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundStyle(tint)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(tint.opacity(0.16)).clipShape(Capsule())
                // A chevron only when there's miss detail to drill into.
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold)).foregroundStyle(count > 0 ? Theme.textSecondary : .clear)
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func emptyLine(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8)
    }
}

// MARK: - Per-skill miss detail (the drill-down sheet)

/// Every recent wrong answer for ONE skill: the exact question, what he tapped,
/// and the correct answer — so a grown-up can see WHY he's missing it.
struct SkillMissesView: View {
    let skill: Skill
    let misses: [MissEvent]
    let wrong: Int
    let done: Int
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var playing = false

    private var playCount: Int { state.mergedCount(skill.id) }
    private var mastered: Bool { state.mergedMastered(skill.id) }
    private var masteredDate: Date? {
        state.mergedWins.first { $0.text == "Mastered \(skill.title)!" }?.date
    }
    private var wrongTotal: Int { max(wrong, state.mergedWrongCount(skill.id)) }
    private var accuracyPct: Int? { state.accuracy(skill.id).map { Int($0 * 100) } }
    private var lastPlayed: Date? { state.mergedLastPlayed(skill.id) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    playButton
                    statsGrid
                    missesSection
                }
                .padding(18).padding(.top, 12)
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26)).foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
        }
        // Grown-up "try it" — plays the real game with recording suppressed, so
        // a test run never lands in Gabriel's progress.
        .fullScreenCover(isPresented: $playing, onDismiss: { GameStats.suppressed = false }) {
            ZStack(alignment: .topLeading) {
                Theme.bg.ignoresSafeArea()
                LessonPlayerView(skill: skill) { playing = false }
                    .padding(.top, 6)
                Button { playing = false } label: {
                    Label("Done", systemImage: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Theme.surface).clipShape(Capsule())
                }
                .padding(16)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: skill.subject.icon).foregroundStyle(skill.subject.color)
                Text(skill.title).font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            }
            Text("\(skill.subject.title) · \(skill.standard)")
                .font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)
            if !skill.parentTip.isEmpty {
                Text("💡 \(skill.parentTip)")
                    .font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var playButton: some View {
        Button {
            GameStats.suppressed = true               // don't record a grown-up's test run
            GameDifficulty.level = state.currentLevel(skill.id)
            GameStats.begin(skill.id)
            playing = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.circle.fill").font(.system(size: 20, weight: .bold))
                Text("Try this game").font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(Theme.redGradient).clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var statsGrid: some View {
        let cols = [GridItem(.adaptive(minimum: 104), spacing: 10)]
        return LazyVGrid(columns: cols, spacing: 10) {
            stat("\(playCount)×", "played", Theme.green, "checkmark.seal.fill")
            if mastered {
                stat(masteredDate.map(Self.shortDate) ?? "Yes", "mastered", Theme.gold, "star.fill")
            } else {
                stat("\(playCount)/\(state.saved.masteryThreshold)", "to master", Theme.textSecondary, "star")
            }
            if let a = accuracyPct {
                stat("\(a)%", "accuracy", a >= 80 ? Theme.green : Theme.gold, "target")
            }
            stat("\(wrongTotal)", "wrong taps", wrongTotal == 0 ? Theme.green : .orange, "hand.tap.fill")
            if let lp = lastPlayed {
                stat(Self.shortDate(lp), "last played", .white, "clock.fill")
            }
            if state.currentLevel(skill.id) > 1 {
                stat("Lv \(state.currentLevel(skill.id))", "difficulty", Theme.red, "chart.line.uptrend.xyaxis")
            }
        }
    }

    private func stat(_ value: String, _ label: String, _ color: Color, _ icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 14, weight: .bold)).foregroundStyle(color)
            Text(value).font(.system(size: 18, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.65)
            Text(label).font(.system(size: 11, weight: .bold, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder private var missesSection: some View {
        if misses.isEmpty {
            Text(wrongTotal == 0 ? "No wrong answers recorded — he's nailing this one. 🌟"
                                 : "No specific wrong answers saved yet — this fills in as he plays.")
                .font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
        } else {
            Text("What he got wrong (newest first)")
                .font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            ForEach(misses, id: \.self) { m in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(m.prompt)
                            .font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Text(InsightsView.rel(m.date))
                            .font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
                    }
                    HStack(spacing: 8) {
                        tag("he tapped: \(m.tapped)", .red)
                        tag("answer: \(m.correct)", Theme.green)
                    }
                }
                .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func tag(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundStyle(color)
            .padding(.horizontal, 9).padding(.vertical, 5)
            .background(color.opacity(0.16)).clipShape(Capsule())
    }

    static func shortDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f.string(from: d)
    }
}
