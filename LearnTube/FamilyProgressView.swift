import SwiftUI

/// What each device in the family has been doing - synced over iCloud so a
/// parent can check it from their own phone without holding the child's.
struct FamilyProgressView: View {
    @EnvironmentObject var state: AppState
    @State private var renaming: ProgressSnapshot?
    @State private var newName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                if cards.isEmpty {
                    emptyState
                } else {
                    ForEach(cards) { card($0) }
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .alert("Rename device", isPresented: Binding(
            get: { renaming != nil },
            set: { if !$0 { renaming = nil } })) {
            TextField("Name", text: $newName)
            Button("Save") {
                if let r = renaming { state.renameDevice(r.deviceID, to: newName) }
                renaming = nil
            }
            Button("Cancel", role: .cancel) { renaming = nil }
        } message: {
            Text("What should this device show as? For example, \u{201C}Doosy\u{2019}s iPad mini.\u{201D} Leave blank to clear.")
        }
    }

    private var cards: [ProgressSnapshot] {
        // Collapse phantom duplicates: reinstalling the app makes a new device
        // ID with the same name, so keep only the most recent snapshot per name.
        var latest: [String: ProgressSnapshot] = [:]
        for s in state.familySnapshots {
            if s.totalEver == 0 && s.totalToday == 0 { continue }   // drop empty phantoms
            let key = state.deviceDisplayName(s).lowercased()
            if let e = latest[key], e.updatedAt >= s.updatedAt { continue }
            latest[key] = s
        }
        return latest.values.sorted {
            let ea = state.isDeviceExcluded($0.deviceID), eb = state.isDeviceExcluded($1.deviceID)
            if ea != eb { return !ea }              // counted devices first, ignored ones last
            return $0.updatedAt > $1.updatedAt
        }
    }

    private func timeStr(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(d) ? "'Today' h:mm a" : "MMM d, h:mm a"
        return f.string(from: d)
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Family Progress")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Updates over iCloud from every phone signed in to your account.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "icloud").font(.system(size: 42)).foregroundStyle(Theme.textSecondary)
            Text("No progress yet")
                .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            Text("As soon as a game is finished on any phone, it shows up here. iCloud can take a minute to sync.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
        .padding(.vertical, 40).padding(.horizontal, 20)
    }

    private func card(_ s: ProgressSnapshot) -> some View {
        let isToday = s.dayKey == AppState.dayKey
        let isSelf = s.deviceID == state.saved.deviceID
        let items = s.todayCounts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
        let allItems = s.allTime.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "iphone").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.textSecondary)
                Text(state.deviceDisplayName(s))
                    .font(.system(size: 21, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Button { newName = state.deviceDisplayName(s); renaming = s } label: {
                    Image(systemName: "pencil").font(.system(size: 15, weight: .bold))
                }
                .buttonStyle(.plain).foregroundStyle(Theme.textSecondary)
                let excluded = state.isDeviceExcluded(s.deviceID)
                Button { state.setDeviceExcluded(s.deviceID, !excluded) } label: {
                    Image(systemName: excluded ? "eye.slash" : "eye").font(.system(size: 15, weight: .bold))
                }
                .buttonStyle(.plain).foregroundStyle(excluded ? Theme.gold : Theme.textSecondary)
                if excluded {
                    Text("Not counted")
                        .font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.gold)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Theme.gold.opacity(0.16)).clipShape(Capsule())
                }
                if isSelf {
                    Text("this phone")
                        .font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Theme.surfaceHi).clipShape(Capsule())
                }
                Spacer()
                Text(relative(s.updatedAt))
                    .font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }

            if isToday && !items.isEmpty {
                Text("\(s.totalToday) game\(s.totalToday == 1 ? "" : "s") today")
                    .font(.system(size: 16, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                VStack(spacing: 7) {
                    ForEach(items, id: \.key) { key, count in
                        HStack(spacing: 8) {
                            Text(title(for: key))
                                .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                                .lineLimit(1)
                            Spacer()
                            if let t = s.playedTime(key) {
                                Text(timeStr(t))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)
                            }
                            Text(count > 1 ? "×\(count)" : "×1")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(count > 1 ? Theme.red : Theme.textSecondary)
                        }
                    }
                }
            } else {
                Text(isToday ? "No games yet today" : "Last played \(friendlyDay(s.dayKey))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }

            if !allItems.isEmpty {
                Rectangle().fill(Theme.textSecondary.opacity(0.2)).frame(height: 1).padding(.vertical, 2)
                Text("All time:  \(s.mastered) mastered  •  \(s.totalEver) games played")
                    .font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
                VStack(spacing: 6) {
                    ForEach(allItems, id: \.key) { key, count in
                        let isMastered = count >= state.saved.masteryThreshold
                        HStack(spacing: 8) {
                            Image(systemName: isMastered ? "star.fill" : "star")
                                .font(.system(size: 13)).foregroundStyle(isMastered ? Theme.green : Theme.textSecondary)
                            Text(title(for: key))
                                .font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(.white).lineLimit(1)
                            Spacer()
                            if let t = s.playedTime(key) {
                                Text(timeStr(t))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)
                            }
                            Text("×\(count)")
                                .font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "pawprint.fill").font(.system(size: 15)).foregroundStyle(Theme.green)
                Text("\(s.buddyCount) animal budd\(s.buddyCount == 1 ? "y" : "ies") collected")
                    .font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .opacity(state.isDeviceExcluded(s.deviceID) ? 0.55 : 1)
    }

    private func title(for id: String) -> String {
        Curriculum.skill(id: id)?.title ?? id
    }

    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func friendlyDay(_ key: String) -> String {
        let inF = DateFormatter(); inF.dateFormat = "yyyy-MM-dd"
        guard let d = inF.date(from: key) else { return key }
        let outF = DateFormatter(); outF.dateFormat = "MMM d"
        return outF.string(from: d)
    }
}

// MARK: - Today (the grown-up landing screen)

/// The parent's starting screen: everything that happened today across the
/// family, newest first, with a quick summary of games, time earned, watched,
/// and remaining. Pulls from the same synced snapshots as the Family view.
struct TodayDigestView: View {
    @EnvironmentObject var state: AppState
    @State private var drill: Skill?

    // MARK: - Data

    /// Collapse phantom duplicates (a reinstall makes a new device id with the
    /// same name) by keeping only the most recent snapshot per name.
    private var cards: [ProgressSnapshot] {
        var latest: [String: ProgressSnapshot] = [:]
        for s in state.familySnapshots {
            if s.totalEver == 0 && s.totalToday == 0 { continue }
            let key = s.name.isEmpty ? s.deviceID : s.name.lowercased()
            if let e = latest[key], e.updatedAt >= s.updatedAt { continue }
            latest[key] = s
        }
        return Array(latest.values)
    }

    private var todayCards: [ProgressSnapshot] {
        cards.filter { $0.dayKey == AppState.dayKey && !state.isDeviceExcluded($0.deviceID) }
    }

    private var todayKey: String { AppState.dayKey }

    private var gamesToday: Int { todayCards.reduce(0) { $0 + $1.totalToday } }
    private var earnedToday: Int {
        let cap = state.saved.maxPlaysPerDay
        var games = 0
        for s in todayCards { for (_, c) in s.todayCounts { games += min(c, cap) } }
        return games * state.saved.minutesPerConcept
    }

    enum Status { case look, getting, good }

    /// One skill Gabriel touched today, with today's counts and the exact wrong
    /// answers behind them.
    private struct SkillDay: Identifiable {
        let id: String
        let title: String
        let standard: String
        let subject: Subject?
        let finished: Int
        let started: Int
        let wrong: Int
        let lastTime: Date?
        let misses: [MissEvent]
        var abandoned: Int { max(0, started - finished) }
        var attempts: Int { finished + wrong }
        var accuracy: Double? { attempts > 0 ? Double(finished) / Double(attempts) : nil }
        /// How today's practice really went. A game finished with zero wrong
        /// taps means he read and answered it; finishing only after wrong taps
        /// is button-mashing, not learning, so it does NOT count as going well.
        var status: Status {
            if finished == 0 {
                // Opened but not finished is only a red "needs a look" if he was
                // actually struggling (several wrong taps). A clean bail — he
                // just backed out — is amber "getting there", not a failure.
                return wrong >= 3 ? .look : .getting
            }
            if wrong == 0 { return .good }       // clean run — he actually did it
            if wrong <= 2 { return .getting }    // a stumble, not a mash
            return .look                         // got through only by guessing
        }
    }

    /// Every skill practiced today, most wrong taps first, each carrying today's
    /// finished/started/wrong-tap counts and the specific questions he missed.
    private var skillDays: [SkillDay] {
        var finished: [String: Int] = [:], started: [String: Int] = [:], wrong: [String: Int] = [:]
        var lastTime: [String: Date] = [:]
        for s in todayCards {
            for (id, c) in s.todayCounts where c > 0 {
                finished[id, default: 0] += c
                if let t = s.playedTime(id), lastTime[id] == nil || t > lastTime[id]! { lastTime[id] = t }
            }
            for (id, days) in s.recentStartsMap { if let v = days[todayKey] { started[id, default: 0] += v } }
            for (id, days) in s.recentWrongMap { if let v = days[todayKey] { wrong[id, default: 0] += v } }
        }
        var missBySkill: [String: [MissEvent]] = [:]
        for m in state.mergedMisses where Calendar.current.isDateInToday(m.date) {
            missBySkill[m.skill, default: []].append(m)
        }
        let ids = Set(finished.keys).union(started.keys).union(wrong.keys).union(missBySkill.keys)
        let out = ids.map { id -> SkillDay in
            let sk = Curriculum.skill(id: id)
            return SkillDay(id: id, title: sk?.title ?? id, standard: sk?.standard ?? "",
                            subject: sk?.subject, finished: finished[id] ?? 0,
                            started: started[id] ?? 0, wrong: wrong[id] ?? 0,
                            lastTime: lastTime[id],
                            misses: (missBySkill[id] ?? []).sorted { $0.date > $1.date })
        }
        return out.sorted {
            if $0.wrong != $1.wrong { return $0.wrong > $1.wrong }
            switch ($0.lastTime, $1.lastTime) {
            case let (a?, b?): return a > b
            case (nil, _?): return false
            case (_?, nil): return true
            default: return $0.title < $1.title
            }
        }
    }

    private func group(_ s: Status) -> [SkillDay] { skillDays.filter { $0.status == s } }

    private var wrongTotal: Int { skillDays.reduce(0) { $0 + $1.wrong } }
    private var finishedSkills: Int { skillDays.filter { $0.finished > 0 }.count }
    private var cleanSkills: Int { skillDays.filter { $0.finished > 0 && $0.wrong == 0 }.count }

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    dashboard(proxy)
                    if skillDays.isEmpty {
                        emptyState
                    } else {
                        groupSection("Going well", "checkmark.seal.fill", Theme.green, group(.good), anchor: "good")
                        groupSection("Getting there", "arrow.up.right.circle.fill", Theme.gold, group(.getting), anchor: "getting")
                        groupSection("Needs a look", "exclamationmark.triangle.fill", Theme.alertInk, group(.look), anchor: "look", pillFill: Theme.alertFill)
                    }
                    Color.clear.frame(height: 16)
                }
                .padding(16)
            }
        }
        .background(Theme.bg)
        .sheet(item: $drill) { sk in
            let sd = skillDays.first { $0.id == sk.id }
            SkillMissesView(skill: sk,
                            misses: sd?.misses ?? state.misses(for: sk.id),
                            wrong: sd?.wrong ?? 0,
                            done: sd?.finished ?? 0)
                .environmentObject(state)
        }
    }

    // MARK: - Dashboard header

    private func dashboard(_ proxy: ScrollViewProxy) -> some View {
        let df = DateFormatter(); df.dateFormat = "EEEE, MMMM d"
        let look = group(.look).count, getting = group(.getting).count, good = group(.good).count
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                Spacer()
                Text(df.string(from: Date())).font(.system(size: 15, weight: .medium, design: .rounded)).foregroundStyle(Theme.textSecondary)
            }
            HStack(spacing: 10) {
                kpi(finishedSkills > 0 ? "\(cleanSkills)/\(finishedSkills)" : "—", "clean runs",
                    finishedSkills > 0 && cleanSkills == finishedSkills ? Theme.green : (cleanSkills == 0 ? .orange : Theme.gold))
                kpi("\(gamesToday)", "games", .white)
                kpi("\(earnedToday)m", "earned", Theme.gold)
                kpi("\(state.watchedTodayMinutes)m", "watched", Theme.red)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if look > 0 { navChip("\(look) need a look", "exclamationmark.triangle.fill", Theme.alertInk, fill: Theme.alertFill) { scrollTo("look", proxy) } }
                    if wrongTotal > 0 { navChip("\(wrongTotal) wrong tap\(wrongTotal == 1 ? "" : "s")", "hand.tap.fill", Theme.alertInk, fill: Theme.alertFill) { scrollTo("look", proxy) } }
                    if getting > 0 { navChip("\(getting) getting there", "arrow.up.right", Theme.gold) { scrollTo("getting", proxy) } }
                    if good > 0 { navChip("\(good) going well", "checkmark", Theme.green) { scrollTo("good", proxy) } }
                }
                .padding(.vertical, 1)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func kpi(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Theme.surfaceHi).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func navChip(_ text: String, _ icon: String, _ color: Color, fill: Color? = nil, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 14, weight: .bold))
                Text(text).font(.system(size: 15, weight: .heavy, design: .rounded)).fixedSize()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).opacity(0.7)
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

    // MARK: - Grouped skills

    private func groupSection(_ title: String, _ icon: String, _ tint: Color, _ items: [SkillDay], anchor: String, pillFill: Color? = nil) -> some View {
        let fill = pillFill ?? tint.opacity(0.16)
        return VStack(alignment: .leading, spacing: 10) {
            if !items.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: icon).font(.system(size: 17, weight: .bold)).foregroundStyle(tint)
                    Text(title).font(.system(size: 19, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                    let totalToday = skillDays.count
                    let pct = totalToday > 0 ? Int((Double(items.count) / Double(totalToday) * 100).rounded()) : 0
                    Text("\(items.count)  \u{00B7}  \(pct)%").font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(tint)
                        .padding(.horizontal, 8).padding(.vertical, 2).background(fill).clipShape(Capsule())
                    Spacer()
                }
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { idx, sd in
                        if idx > 0 { Divider().overlay(Theme.surfaceHi) }
                        skillRow(sd, tint: tint, pillFill: fill)
                    }
                }
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .id(anchor)
    }

    private func skillRow(_ sd: SkillDay, tint: Color, pillFill: Color? = nil) -> some View {
        Button {
            if let sk = Curriculum.skill(id: sd.id) { drill = sk }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: sd.subject?.icon ?? "star.fill")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(sd.subject?.color ?? Theme.green).frame(width: 24)
                Text(sd.title).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white).lineLimit(1).layoutPriority(1)
                Spacer(minLength: 8)
                Text(quickStats(sd)).font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary).lineLimit(1).truncationMode(.head)
                Text(statusPill(sd)).font(.system(size: 14, weight: .heavy, design: .rounded)).foregroundStyle(tint)
                    .lineLimit(1)
                    .padding(.horizontal, 10).padding(.vertical, 4).background(pillFill ?? tint.opacity(0.16)).clipShape(Capsule())
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// One-glance answer to "when did he finish this, and how many times?" —
    /// today's finish time, today's count, and the all-time total. Tapping the
    /// row still drills into the full history and the exact questions he missed.
    private func quickStats(_ sd: SkillDay) -> String {
        var parts: [String] = []
        if let t = sd.lastTime {
            let f = DateFormatter(); f.dateFormat = "h:mm a"
            parts.append(f.string(from: t))
        }
        if sd.finished > 1 { parts.append("\(sd.finished)\u{00D7} today") }
        else if sd.finished == 1 { parts.append("once today") }
        let all = state.mergedCount(sd.id)
        if all > 0 { parts.append("\(all) all-time") }
        return parts.joined(separator: "  \u{00B7}  ")
    }

    private func statusPill(_ sd: SkillDay) -> String {
        if sd.finished == 0 {
            return sd.wrong > 0 ? "\(sd.wrong) wrong, left" : "opened, not finished"
        }
        if sd.wrong == 0 { return sd.finished > 1 ? "\(sd.finished)\u{00D7} clean" : "clean, first try" }
        return "finished, \(sd.wrong) wrong tap\(sd.wrong == 1 ? "" : "s")"
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sun.max").font(.system(size: 42)).foregroundStyle(Theme.textSecondary)
            Text("Nothing yet today")
                .font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            Text("As soon as Gabriel finishes a game on any device, it shows up here — grouped by how it's going.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
        .padding(.vertical, 40).padding(.horizontal, 20)
    }
}
