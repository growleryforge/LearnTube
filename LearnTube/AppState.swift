import SwiftUI
import Combine
import UIKit

/// Codable snapshot persisted to UserDefaults.
struct SavedState: Codable {
    var activeGrade: Int = 0
    var requiredPerDay: Int = 3
    var menuSize: Int = 5
    var masteryThreshold: Int = 3
    var youTubeURL: String = "https://www.youtube.com"
    /// Calm day: serve only games he already knows and has not struggled with
    /// lately. For days when new material is not going to land. Local to this
    /// device (flip it in the grown-up area on his iPad).
    var calmMode: Bool = false
    var enabledGrades: [Int] = [-2, -1, 0]
    var completionCounts: [String: Int] = [:]
    var todayKey: String = ""
    var lastGrantDayLocal: String = ""   // last day this device applied the daily free-minutes reset
    var guessedResetV1: Bool = false     // one-time reset of topics he only guessed through
    var todayMenu: [String] = []
    var todayDone: [String] = []
    var lastUnlockKey: String = ""
    var earnedBuddies: [String] = []
    var earnedMinutes: Int = 0          // bank of YouTube minutes earned
    var minutesPerConcept: Int = 20     // 20 min per concept by default
    var sessionEndsAt: Date? = nil      // active YouTube hour countdown
    var completionsToday: [String: Int] = [:]   // plays per lesson today (cap 3)
    var maxPlaysPerDay: Int = 3
    var parentPIN: String = ""                   // 4-digit grown-up PIN (empty = not set)
    var deviceID: String = ""                    // stable per-install id for family sync
    var playerName: String = ""                  // "Whose phone is this?" label
    var winsLog: [WinEvent] = []                 // recent celebrations for My Wins
    var lastPlayed: [String: Date] = [:]         // lessonID -> when it was last finished
    var wrongCounts: [String: Int] = [:]         // lessonID -> total wrong taps (struggle signal)
    var startedCounts: [String: Int] = [:]       // lessonID -> games opened (finished + abandoned)
    // Day-bucketed recent activity (lessonID -> "yyyy-MM-dd" -> count) so Insights
    // can show a rolling recent window: old struggles drop out over time, and a
    // skill he re-engages with successfully changes how it's flagged.
    var recentWrong: [String: [String: Int]] = [:]   // wrong taps by day
    var recentStarts: [String: [String: Int]] = [:]  // games opened by day
    var recentPlays: [String: [String: Int]] = [:]   // games finished by day
    var misses: [MissEvent] = []                     // recent wrong answers, newest first
    // Mastery bonuses. Optional so that adding them cannot break decoding of an
    // existing save (SavedState is decoded with `try?` and falls back to blank,
    // so a missing non-optional key would wipe his progress on this device).
    var levelsBeaten: [String: Int]? = nil           // highest ladder level beaten per skill
    var masteryBonusPaid: [String]? = nil            // skills already paid the mastery bonus
    // Time on task. Optional for the same decoding reason as the two above.
    var secondsByDay: [String: Int]? = nil           // "yyyy-MM-dd" -> seconds played
    var secondsBySkill: [String: Int]? = nil         // lessonID -> seconds played
}

/// One specific wrong answer, so grown-ups can drill into what he actually
/// tapped vs. the correct answer — not just how many he missed.
struct MissEvent: Codable, Hashable {
    var skill: String
    var prompt: String
    var tapped: String
    var correct: String
    var date: Date
}

/// One celebratory moment for the My Wins feed.
struct WinEvent: Codable, Hashable {
    var text: String
    var emoji: String
    var date: Date
}

@MainActor
final class AppState: ObservableObject {

    @Published private(set) var saved: SavedState {
        didSet { persist() }
    }

    private let storeKey = "LearnTube.SavedState.v1"

    /// iCloud sync of each device's progress (same Apple ID = shared view).
    let family = FamilySync()
    private var bag = Set<AnyCancellable>()

    init() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let decoded = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.saved = decoded
        } else {
            self.saved = SavedState()
        }
        // A keychain-backed id that survives reinstalls (migrates any existing
        // UserDefaults id in), so reinstalling never spawns a phantom device.
        saved.deviceID = DeviceIdentity.stable(fallback: saved.deviceID)
        // Re-publish when another device's progress arrives over iCloud.
        family.objectWillChange
            .sink { [weak self] _ in
                self?.applyRemoteSettings()
                self?.objectWillChange.send()
            }
            .store(in: &bag)
        refreshForToday()
        applyRemoteSettings()
        bootstrapSettingsIfNeeded()
        #if PARENT
        // The parent Mac is the dashboard + test surface: keep its own
        // play-throughs out of Gabriel's real progress, and label it clearly.
        if saved.playerName.isEmpty { saved.playerName = "Parent Mac" }
        family.setExcluded(saved.deviceID, true)
        #endif
        pushSnapshot()
        // Fold each mis-tap / game-open (captured globally in GameStats) into
        // synced storage so grown-ups can see what to work on.
        GameStats.onChange = { [weak self] in
            Task { @MainActor in self?.flushGameStats() }
        }
    }

    /// Move accumulated wrong-tap / game-start deltas into persistent, synced
    /// storage. Called (deferred to the main actor) whenever GameStats changes.
    func flushGameStats() {
        let d = GameStats.drain()
        guard !d.wrong.isEmpty || !d.start.isEmpty || !d.misses.isEmpty else { return }
        var w = saved.wrongCounts, s = saved.startedCounts
        for (id, c) in d.wrong { w[id, default: 0] += c }
        for (id, c) in d.start { s[id, default: 0] += c }
        saved.wrongCounts = w
        // Keep the detail of recent wrong answers (newest first, capped).
        if !d.misses.isEmpty {
            var m = saved.misses
            for x in d.misses.reversed() {
                m.insert(MissEvent(skill: x.skill, prompt: x.prompt, tapped: x.tapped,
                                   correct: x.correct, date: x.at), at: 0)
            }
            if m.count > 120 { m.removeLast(m.count - 120) }
            saved.misses = m
        }
        saved.startedCounts = s   // didSet persists + pushes the snapshot
        // Also record into today's bucket for the rolling recent window.
        let day = AppState.dayKey
        var rw = saved.recentWrong, rs = saved.recentStarts
        for (id, c) in d.wrong { rw[id, default: [:]][day, default: 0] += c }
        for (id, c) in d.start { rs[id, default: [:]][day, default: 0] += c }
        saved.recentWrong = AppState.pruneRecent(rw)
        saved.recentStarts = AppState.pruneRecent(rs)
    }

    /// Keep only day buckets within the recent window so the maps stay small.
    static let recentWindowDays = 14
    static func cutoffDayKey(_ days: Int) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date())
    }
    static func pruneRecent(_ m: [String: [String: Int]]) -> [String: [String: Int]] {
        let cut = cutoffDayKey(recentWindowDays)
        var out: [String: [String: Int]] = [:]
        for (id, days) in m {
            let kept = days.filter { $0.key >= cut }
            if !kept.isEmpty { out[id] = kept }
        }
        return out
    }

    // MARK: - Shared grown-up settings (synced across devices)

    private func currentSettings() -> FamilySettings {
        FamilySettings(minutesPerConcept: saved.minutesPerConcept,
                       masteryThreshold: saved.masteryThreshold,
                       maxPlaysPerDay: saved.maxPlaysPerDay,
                       youTubeURL: saved.youTubeURL,
                       dailyStartMinutes: family.settings?.dailyStartMinutes ?? 15,
                       dailyCapMinutes: family.settings?.dailyCapMinutes ?? 0)
    }

    /// Free minutes granted at the start of each new day (default 15).
    var dailyStartMinutes: Int { family.settings?.dailyStartMinutes ?? 15 }
    /// Daily watch limit in minutes (0 = no limit).
    var dailyCapMinutes: Int { family.settings?.dailyCapMinutes ?? 0 }
    /// True once he's watched up to today's cap (only when a cap is set).
    var dailyCapReached: Bool { dailyCapMinutes > 0 && watchedTodayMinutes >= dailyCapMinutes }

    func setDailyStartMinutes(_ n: Int) {
        var s = currentSettings(); s.dailyStartMinutes = max(0, min(n, 120)); family.writeSettings(s)
    }
    func setDailyCapMinutes(_ n: Int) {
        var s = currentSettings(); s.dailyCapMinutes = max(0, min(n, 600)); family.writeSettings(s)
    }

    /// Adopt settings a grown-up changed on another device (e.g. the iPad
    /// follows the reward time set on a parent's iPhone).
    private func applyRemoteSettings() {
        guard let s = family.settings else { return }
        if saved.minutesPerConcept != s.minutesPerConcept { saved.minutesPerConcept = s.minutesPerConcept }
        if saved.masteryThreshold != s.masteryThreshold { saved.masteryThreshold = s.masteryThreshold }
        if saved.maxPlaysPerDay != s.maxPlaysPerDay { saved.maxPlaysPerDay = s.maxPlaysPerDay }
        if !s.youTubeURL.isEmpty && saved.youTubeURL != s.youTubeURL { saved.youTubeURL = s.youTubeURL }
    }

    /// If no shared settings exist yet, a grown-up phone whose reward differs
    /// from the default seeds them for the family so the iPad can follow.
    private func bootstrapSettingsIfNeeded() {
        guard family.settings == nil else { return }
        if UIDevice.current.userInterfaceIdiom != .pad && saved.minutesPerConcept != 20 {
            family.writeSettings(currentSettings())
        }
    }

    /// Convenience: this device's synced progress (and everyone else's).
    var familySnapshots: [ProgressSnapshot] { family.snapshots }

    /// The name to show for a device: a grown-up override if set, else the
    /// name the device reports, else a placeholder.
    func deviceDisplayName(_ snap: ProgressSnapshot) -> String {
        if let n = family.deviceNames[snap.deviceID], !n.isEmpty { return n }
        return snap.name.isEmpty ? "Unnamed device" : snap.name
    }

    /// Grown-up renames a device; the label syncs to every device.
    func renameDevice(_ deviceID: String, to name: String) { family.setDeviceName(deviceID, name) }

    /// Whether a device is marked "don't count" (e.g. a parent's test device).
    func isDeviceExcluded(_ deviceID: String) -> Bool { family.excludedIDs.contains(deviceID) }
    /// Toggle whether a device counts toward totals, mastery, and insights.
    func setDeviceExcluded(_ deviceID: String, _ excluded: Bool) { family.setExcluded(deviceID, excluded) }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
        if !suppressPush { pushSnapshot() }
    }

    /// When true, saving persists locally but does NOT push the snapshot — used
    /// during the one-time reset so a max-merge push can't re-inflate cleared counts.
    private var suppressPush = false

    /// One-time: wipe the completion + wrong history for any game this device
    /// only guessed through (finished, but with more wrong taps than clean runs),
    /// so those topics return to his feed and he re-earns them cleanly on the
    /// now-fixed games. Runs once per device.
    func resetGuessedTopicsIfNeeded() {
        guard !saved.guessedResetV1 else { return }
        let thr = saved.masteryThreshold
        var s = saved
        var changed = false
        for (id, done) in s.completionCounts where done >= thr {
            if (s.wrongCounts[id] ?? 0) >= done {          // guessed it through
                s.completionCounts[id] = 0
                s.wrongCounts[id] = 0
                s.recentWrong[id] = nil
                changed = true
            }
        }
        s.guessedResetV1 = true
        suppressPush = true
        saved = s                                          // persist locally only
        suppressPush = false
        // Authoritative cloud write with the cleared values (last write wins).
        if changed {
            family.overwriteCounts(deviceID: saved.deviceID,
                                   allCounts: saved.completionCounts,
                                   wrongCounts: saved.wrongCounts)
        }
    }

    /// Share this device's current progress to iCloud for the family view.
    private func pushSnapshot() {
        guard !saved.deviceID.isEmpty else { return }
        // The iPad is kid-only with no Grown-Ups tab to set a name, so give it a
        // sensible default label in the family view.
        let name = saved.playerName.isEmpty
            ? (UIDevice.current.userInterfaceIdiom == .pad ? "Gabriel's iPad" : "")
            : saved.playerName
        let mastered = saved.completionCounts.filter { $0.value >= saved.masteryThreshold }.count
        family.write(ProgressSnapshot(
            deviceID: saved.deviceID,
            name: name,
            dayKey: saved.todayKey,
            todayCounts: saved.completionsToday,
            buddyCount: saved.earnedBuddies.count,
            updatedAt: Date(),
            allCounts: saved.completionCounts,
            masteredCount: mastered,
            lastPlayed: saved.lastPlayed,
            wrongCounts: saved.wrongCounts,
            startedCounts: saved.startedCounts,
            recentWrong: saved.recentWrong,
            recentStarts: saved.recentStarts,
            recentPlays: saved.recentPlays,
            misses: saved.misses,
            earnedBuddies: saved.earnedBuddies,
            winsLog: saved.winsLog))
    }

    func setPlayerName(_ s: String) {
        saved.playerName = String(s.prefix(20))
    }

    // MARK: - Date helpers

    static var dayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    /// Rebuild today's menu if it's a new day.
    func refreshForToday() {
        let key = AppState.dayKey
        if saved.todayKey != key {
            saved.todayKey = key
            saved.todayDone = []
            saved.completionsToday = [:]
            saved.todayMenu = makeMenu()
        } else if saved.todayMenu.isEmpty {
            saved.todayMenu = makeMenu()
        }
        // Always honor the curated live set if one is defined (story-only for now),
        // overriding any older saved menu.
        let live = Curriculum.liveStops.filter { Curriculum.skill(id: $0) != nil }
        if !live.isEmpty && saved.todayMenu != live {
            saved.todayMenu = live
            saved.todayDone = saved.todayDone.filter { live.contains($0) }
        }
        // Reset the shared bank to the daily free minutes ONCE per new day.
        // Only the first device to open on a new day resets (leftover/earned
        // time does NOT roll over), and the local-day marker makes the reset
        // fire reliably even when Firebase is briefly unreachable.
        if saved.lastGrantDayLocal != key {
            saved.lastGrantDayLocal = key
            family.applyDailyStartIfNeeded(dailyStartMinutes)
        }
        // One-time: clear the topics he only guessed through so he re-earns them.
        resetGuessedTopicsIfNeeded()
    }

    // MARK: - Menu generation

    private func makeMenu() -> [String] {
        // If a curated set of live concepts is defined, show only those.
        let live = Curriculum.liveStops.filter { id in Curriculum.skill(id: id) != nil }
        if !live.isEmpty { return live }

        let pool = Curriculum.skills(for: saved.activeGrade)
        guard !pool.isEmpty else { return [] }

        let unmastered = pool.filter { !isMastered($0.id) }
        let working = unmastered.isEmpty ? pool : unmastered

        // Variety: try to cover different subjects first.
        var bySubject: [Subject: [Skill]] = [:]
        for s in working.shuffled() { bySubject[s.subject, default: []].append(s) }

        var picks: [Skill] = []
        var subjects = Array(bySubject.keys).shuffled()
        while picks.count < saved.menuSize, !subjects.isEmpty {
            for subj in subjects {
                if var list = bySubject[subj], !list.isEmpty {
                    picks.append(list.removeFirst())
                    bySubject[subj] = list
                    if picks.count >= saved.menuSize { break }
                }
            }
            subjects = subjects.filter { !(bySubject[$0]?.isEmpty ?? true) }
        }
        return Array(picks.prefix(saved.menuSize)).map { $0.id }
    }

    func reshuffleMenu() {
        saved.todayDone = []
        saved.todayMenu = makeMenu()
    }

    // MARK: - Today's data

    var todaySkills: [Skill] {
        saved.todayMenu.compactMap { Curriculum.skill(id: $0) }
    }

    func isDoneToday(_ id: String) -> Bool { saved.todayDone.contains(id) }

    var completedTodayCount: Int { saved.todayDone.count }

    // MARK: - Shared YouTube time (one pool for the whole family)

    /// Minutes earned for finishing one concept.
    var minutesPerConcept: Int { saved.minutesPerConcept }

    /// Minutes available to watch right now - shared across all devices.
    var availableMinutes: Int { family.time?.availableMinutes ?? 0 }

    /// Minutes watched in the app today (family total).
    var watchedTodayMinutes: Int { family.time?.watchedByDay[AppState.dayKey] ?? 0 }

    var canWatch: Bool { availableMinutes > 0 && !dailyCapReached }

    /// Add minutes to the shared pool (negative to remove). Reads the current
    /// shared value first so it can't clobber another device (e.g. a Clear).
    func addFamilyMinutes(_ n: Int) { family.applyMinutesDelta(n, watchedDay: nil) }

    /// Called once per minute while watching: spend a minute and log it.
    func recordWatchedMinute() { family.applyMinutesDelta(-1, watchedDay: AppState.dayKey) }

    /// "2 hr 30 min" style label for minutes.
    func minutesLabel(_ mins: Int) -> String {
        let h = mins / 60, m = mins % 60
        if h > 0 && m > 0 { return "\(h) hr \(m) min" }
        if h > 0 { return "\(h) hr" }
        return "\(m) min"
    }

    /// Returns the buddy newly earned (if any) so the UI can celebrate it.
    func playsToday(_ id: String) -> Int { saved.completionsToday[id] ?? 0 }
    func canPlay(_ id: String) -> Bool { playsToday(id) < saved.maxPlaysPerDay }
    func playsLeft(_ id: String) -> Int { max(0, saved.maxPlaysPerDay - playsToday(id)) }

    /// Above this many wrong taps in one game, the finish was a mash: he still
    /// earns his YouTube time, but it gives no star and doesn't count toward
    /// mastery, so the game stays in his feed until he does it for real.
    static let maxWrongForCredit = 10

    // MARK: - Mastery bonuses
    //
    // Extra minutes ON TOP of the flat per-win rate. Nothing is ever taken away:
    // every finish still pays `minutesPerConcept` exactly as before. These only
    // add a top end, so getting better is worth more than just doing more.
    static let newLevelBonus = 5      // first time he beats a given level
    static let cleanRunBonus = 5      // a round with no wrong taps at all
    static let masteryBonus = 30      // once, when a game is finished for good

    /// The longest a single finish may count as time on task. A game left open
    /// while the iPad sits on the sofa must not land as two hours of learning —
    /// that is exactly the bug that made the watched-minutes figures useless.
    static let maxSecondsPerPlay = 600

    /// What the last finish paid in bonus, and why, so the win screen can show
    /// him that being good earned him more than just showing up.
    private(set) var lastWinBonus = 0
    private(set) var lastWinBonusReasons: [String] = []

    @discardableResult
    func markDone(_ id: String) -> Buddy? {
        defer { pushSnapshot() }   // share updated progress after every game
        let wrongCount = GameStats.wrongThisGame
        lastWinBonus = 0; lastWinBonusReasons = []
        let messy = wrongCount > AppState.maxWrongForCredit
        GameStats.wrongThisGame = 0            // reset for the next game
        let plays = playsToday(id)
        saved.lastPlayed[id] = Date()
        // Reward + activity ALWAYS happen: he finished, so he earns YouTube and
        // the play is logged. We never withhold the reward (PDA).
        saved.recentPlays[id, default: [:]][AppState.dayKey, default: 0] += 1
        saved.recentPlays = AppState.pruneRecent(saved.recentPlays)
        recordTimeOnTask(id)
        if plays < saved.maxPlaysPerDay {
            addFamilyMinutes(saved.minutesPerConcept + playBonuses(id, wrong: wrongCount, messy: messy))
        }
        saved.completionsToday[id] = plays + 1
        guard let skill = Curriculum.skill(id: id) else { return nil }
        logWin(WinEvent(text: "Finished \(skill.title)!", emoji: "🎉", date: Date()))
        // A mash earns time but no credit: no "done" check, no star, no mastery,
        // no buddy — and it stays in the feed so he does it again for real.
        if messy { return nil }
        if !saved.todayDone.contains(id) { saved.todayDone.append(id) }
        saved.completionCounts[id, default: 0] += 1
        let newCount = saved.completionCounts[id] ?? 0
        if newCount == saved.masteryThreshold {
            logWin(WinEvent(text: "Mastered \(skill.title)!", emoji: "⭐️", date: Date()))
        }
        payMasteryBonusIfEarned(id, title: skill.title)
        let buddy = Buddies.forSkill(skill)
        if !hasBuddy(buddy.id) {   // not earned on ANY device yet
            saved.earnedBuddies.append(buddy.id)
            logWin(WinEvent(text: "\(buddy.name) joined your farm!", emoji: "🐾", date: Date()))
            return buddy
        }
        return nil
    }

    /// How long this play actually took, banked by day and by game. Clamped, so
    /// a game he walked away from and came back to cannot inflate the number.
    private func recordTimeOnTask(_ id: String) {
        guard let started = GameStats.startedAt else { return }
        GameStats.startedAt = nil
        let secs = min(Self.maxSecondsPerPlay, max(0, Int(Date().timeIntervalSince(started))))
        guard secs > 0 else { return }
        var byDay = saved.secondsByDay ?? [:]
        byDay[AppState.dayKey, default: 0] += secs
        saved.secondsByDay = byDay
        var bySkill = saved.secondsBySkill ?? [:]
        bySkill[id, default: 0] += secs
        saved.secondsBySkill = bySkill
    }

    /// Minutes actually spent playing today, and the average length of a game.
    var minutesOnTaskToday: Int { ((saved.secondsByDay ?? [:])[AppState.dayKey] ?? 0) / 60 }
    func averagePlaySeconds(_ id: String) -> Int? {
        let total = (saved.secondsBySkill ?? [:])[id] ?? 0
        let plays = saved.completionCounts[id] ?? 0
        guard total > 0, plays > 0 else { return nil }
        return total / plays
    }

    /// Bonus minutes for this finish: beating a level he has never beaten
    /// before, and a round with no wrong taps. A level pays its bonus once;
    /// replaying it still pays the normal rate. A mash earns neither.
    private func playBonuses(_ id: String, wrong: Int, messy: Bool) -> Int {
        guard !messy else { return 0 }
        var bonus = 0
        if Self.levelableSkills.contains(id) {
            let rung = max(1, GameDifficulty.rung)
            var beaten = saved.levelsBeaten ?? [:]
            if rung > (beaten[id] ?? 0) {
                beaten[id] = rung
                saved.levelsBeaten = beaten
                bonus += Self.newLevelBonus
                lastWinBonusReasons.append("🔥 New level")
                logWin(WinEvent(text: "New level beaten! +\(Self.newLevelBonus) min", emoji: "🔥", date: Date()))
            }
        }
        if wrong == 0 {
            bonus += Self.cleanRunBonus
            lastWinBonusReasons.insert("🎯 No mistakes", at: 0)   // loudest first
            logWin(WinEvent(text: "Clean run, no mistakes! +\(Self.cleanRunBonus) min", emoji: "🎯", date: Date()))
        }
        lastWinBonus += bonus
        return bonus
    }

    /// Paid once, the first time a game is done for good: every level beaten on
    /// a ladder game, or mastered on a plain one.
    private func payMasteryBonusIfEarned(_ id: String, title: String) {
        guard isLearned(id) else { return }
        var paid = saved.masteryBonusPaid ?? []
        guard !paid.contains(id) else { return }
        paid.append(id)
        saved.masteryBonusPaid = paid
        addFamilyMinutes(Self.masteryBonus)
        lastWinBonus += Self.masteryBonus
        lastWinBonusReasons.append("🏆 Mastered it")
        logWin(WinEvent(text: "MASTERED \(title)! +\(Self.masteryBonus) min", emoji: "🏆", date: Date()))
    }

    /// Levels beaten across every ladder game — the long view for the grown-up
    /// area and for him: proof of how much he has actually climbed.
    var levelsBeatenTotal: Int { (saved.levelsBeaten ?? [:]).values.reduce(0, +) }

    private func logWin(_ e: WinEvent) {
        saved.winsLog.insert(e, at: 0)
        if saved.winsLog.count > 40 { saved.winsLog.removeLast(saved.winsLog.count - 40) }
    }

    // MARK: - My Wins (celebration stats) — family-wide, so everything he earns
    // on any device shows up on every device.

    /// Every celebration across the family, newest first, deduped and capped.
    var mergedWins: [WinEvent] {
        var all: [WinEvent] = []
        if !family.excludedIDs.contains(saved.deviceID) { all += saved.winsLog }
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            all += snap.winList
        }
        var seen = Set<WinEvent>(); var out: [WinEvent] = []
        for w in all.sorted(by: { $0.date > $1.date }) where !seen.contains(w) { seen.insert(w); out.append(w) }
        return Array(out.prefix(40))
    }
    var recentWins: [WinEvent] { mergedWins }
    var gamesFinished: Int { mergedCounts.values.reduce(0, +) }
    var totalStars: Int { mergedCounts.reduce(0) { $0 + min($1.value, saved.masteryThreshold) } }
    var masteredSkillCount: Int { mergedCounts.filter { $0.value >= saved.masteryThreshold }.count }

    // MARK: - Buddies / collection — family-wide farm.

    /// Every farm animal he's earned on ANY device (union).
    var mergedBuddies: Set<String> {
        var s = Set<String>()
        if !family.excludedIDs.contains(saved.deviceID) { s.formUnion(saved.earnedBuddies) }
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            s.formUnion(snap.buddyList)
        }
        return s
    }
    func hasBuddy(_ id: String) -> Bool { mergedBuddies.contains(id) }
    var earnedBuddyCount: Int { mergedBuddies.count }

    /// Days in a row he's finished at least one game, across every device,
    /// counting back from today (or yesterday if he hasn't played yet today so
    /// it doesn't read 0 first thing in the morning). A gentle "keep it going"
    /// signal for the home badge. Capped by the recent-plays window (~14 days).
    var dayStreak: Int {
        var days = Set<String>()
        func collect(_ m: [String: [String: Int]]) {
            for (_, byDay) in m { for (day, n) in byDay where n > 0 { days.insert(day) } }
        }
        if !family.excludedIDs.contains(saved.deviceID) { collect(saved.recentPlays) }
        for snap in family.snapshots where !family.excludedIDs.contains(snap.deviceID) {
            collect(snap.recentPlaysMap)
        }
        guard !days.isEmpty else { return 0 }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        var cursor = Date()
        if !days.contains(f.string(from: cursor)) {
            cursor = cal.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        var streak = 0
        while days.contains(f.string(from: cursor)) {
            streak += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }

    /// Buddies tied to today's stops (in menu order).
    var todayBuddies: [Buddy] { todaySkills.map { Buddies.forSkill($0) } }

    func undo(_ id: String) {
        guard let idx = saved.todayDone.firstIndex(of: id) else { return }
        saved.todayDone.remove(at: idx)
        if let c = saved.completionCounts[id], c > 0 {
            saved.completionCounts[id] = c - 1
        }
    }

    // MARK: - Mastery

    func completionCount(_ id: String) -> Int { saved.completionCounts[id] ?? 0 }

    /// Mastered anywhere in the family: his iPads and phone add up.
    func isMastered(_ id: String) -> Bool {
        mergedCount(id) >= saved.masteryThreshold && !isGuessy(id)
    }

    // MARK: - Finish Line (close out TK and K before First Grade takes over)

    /// The pre-First-Grade games (Warm-Ups, TK, K, Stretch; grade 0 and below,
    /// not the Farm Writing Club) that are live in his feed.
    var finishLinePool: [Skill] {
        todaySkills.filter { $0.grade <= 0 && !$0.id.hasPrefix("TW-") }
    }
    /// Of those, the ones not yet mastered: one to three plays from done.
    var finishLine: [Skill] { finishLinePool.filter { !isLearned($0.id) } }

    /// Done with this game for good: a plain game after `masteryThreshold`
    /// clean finishes; a ladder game (generated math) only once every rung is
    /// mastered. Ladder games are served one rung at a time (see
    /// `currentRung`), so the feed always shows the portion he is on, and the
    /// game stays until the whole ladder is climbed.
    func isLearned(_ id: String) -> Bool {
        Self.levelableSkills.contains(id) ? isRetired(id) : isMastered(id)
    }

    /// (rung, top, finishes on this rung) for a ladder game; nil otherwise.
    func ladder(_ id: String) -> (rung: Int, top: Int, onRung: Int)? {
        guard Self.levelableSkills.contains(id) else { return nil }
        let top = Self.concreteSkills.contains(id) ? Self.concreteStages + Self.maxLevel : Self.maxLevel
        let t = max(1, saved.masteryThreshold)
        let rung = currentRung(id)
        let onRung = rung >= top ? min(t, mergedCount(id) - (top - 1) * t) : mergedCount(id) % t
        return (rung, top, max(0, onRung))
    }
    var finishLineDone: Int { finishLinePool.count - finishLine.count }
    /// While more than this many are left, First Grade holds off: nothing new
    /// from grade 1 is woven into the feed, though it stays reachable below.
    /// Set past any real count so First Grade is never held back: new content
    /// weaves in as soon as he has mastered what he is on.
    static let finishLineHoldsFirstGrade = Int.max

    func masteredCount(inGrade grade: Int) -> Int {
        Curriculum.skills(for: grade).filter { isMastered($0.id) }.count
    }

    func progress(inGrade grade: Int) -> Double {
        let skills = Curriculum.skills(for: grade)
        guard !skills.isEmpty else { return 0 }
        return Double(masteredCount(inGrade: grade)) / Double(skills.count)
    }

    var activeGradeComplete: Bool {
        let skills = Curriculum.skills(for: saved.activeGrade)
        return !skills.isEmpty && skills.allSatisfy { isMastered($0.id) }
    }

    // MARK: - Merged family progress (so Progress matches the Family tab)

    /// Completion counts across the whole family: this device's live counts plus
    /// every other synced device (his phone + iPad), so the Progress tab and the
    /// report reflect the real total no matter which device you're looking at.
    var mergedCounts: [String: Int] {
        var out: [String: Int] = [:]
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            for (id, c) in snap.allTime { out[id, default: 0] += c }
        }
        // This device's own contribution: the greater of its live local counts
        // and its own saved cloud record. A reinstall wipes local storage, so
        // without this a game he already mastered would reappear on this device.
        if !family.excludedIDs.contains(saved.deviceID) {
            let ownCloud = family.snapshots.first { $0.deviceID == saved.deviceID }?.allTime ?? [:]
            for id in Set(saved.completionCounts.keys).union(ownCloud.keys) {
                out[id, default: 0] += max(saved.completionCounts[id] ?? 0, ownCloud[id] ?? 0)
            }
        }
        return out
    }
    func mergedCount(_ id: String) -> Int { mergedCounts[id] ?? 0 }

    /// He's "guessing his way through" this game when he averages about one or
    /// more wrong taps for every finish — brute-forcing, not knowing it. Such a
    /// game does NOT count as mastered no matter how many times he finished it.
    func isGuessy(_ id: String) -> Bool {
        let d = mergedCount(id)
        guard d >= 1 else { return false }
        return Double(mergedWrongCount(id)) / Double(d) >= 1.0
    }
    /// Mastered = finished enough times AND actually getting it right (not guessing).
    func mergedMastered(_ id: String) -> Bool {
        mergedCount(id) >= saved.masteryThreshold && !isGuessy(id)
    }
    func mergedMasteredCount(inGrade grade: Int) -> Int {
        Curriculum.skills(for: grade).filter { mergedMastered($0.id) }.count
    }
    func mergedProgress(inGrade grade: Int) -> Double {
        let skills = Curriculum.skills(for: grade)
        guard !skills.isEmpty else { return 0 }
        return Double(mergedMasteredCount(inGrade: grade)) / Double(skills.count)
    }

    /// Most recent time a skill was finished, across this device and the family.
    func mergedLastPlayed(_ id: String) -> Date? {
        var best = family.excludedIDs.contains(saved.deviceID) ? nil : saved.lastPlayed[id]
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            if let t = snap.playedTime(id), best == nil || t > best! { best = t }
        }
        return best
    }

    // MARK: - Struggle signals (wrong taps + abandoned games), family-wide

    /// Total wrong taps per skill across this device and every synced device.
    var mergedWrong: [String: Int] {
        var out: [String: Int] = [:]
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            for (id, c) in snap.wrongTaps { out[id, default: 0] += c }
        }
        if !family.excludedIDs.contains(saved.deviceID) {
            for (id, c) in saved.wrongCounts { out[id, default: 0] += c }
        }
        return out
    }
    func mergedWrongCount(_ id: String) -> Int { mergedWrong[id] ?? 0 }

    /// Total games opened per skill (finished + abandoned), family-wide.
    var mergedStarted: [String: Int] {
        var out: [String: Int] = [:]
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            for (id, c) in snap.starts { out[id, default: 0] += c }
        }
        if !family.excludedIDs.contains(saved.deviceID) {
            for (id, c) in saved.startedCounts { out[id, default: 0] += c }
        }
        return out
    }
    func mergedStartedCount(_ id: String) -> Int { mergedStarted[id] ?? 0 }
    /// Has this game ever been opened on any device? Older records only kept
    /// finishes (`startedCounts` came later), so a finish counts as a start.
    func everStarted(_ id: String) -> Bool { mergedStartedCount(id) > 0 || mergedCount(id) > 0 }

    /// Games opened but not finished (a frustration / difficulty signal).
    func mergedAbandoned(_ id: String) -> Int {
        max(0, mergedStartedCount(id) - mergedCount(id))
    }

    /// Rough accuracy for a skill: finishes vs. finishes + wrong taps.
    /// Nil when there isn't enough activity to be meaningful.
    func accuracy(_ id: String) -> Double? {
        let done = mergedCount(id), wrong = mergedWrongCount(id)
        let attempts = done + wrong
        guard attempts >= 3 else { return nil }
        return Double(done) / Double(attempts)
    }

    // MARK: - Recent-window struggle signals (rolling window, family-wide)
    // These let Insights show FRESH guidance: struggles age out as days pass,
    // and a skill he re-engages with successfully changes how it's flagged.

    private func windowSum(_ map: [String: [String: Int]], _ id: String, cutoff: String) -> Int {
        guard let days = map[id] else { return 0 }
        return days.reduce(0) { $1.key >= cutoff ? $0 + $1.value : $0 }
    }
    private func mergedRecent(_ pick: (ProgressSnapshot) -> [String: [String: Int]],
                              _ own: [String: [String: Int]], _ id: String, days: Int) -> Int {
        let cut = AppState.cutoffDayKey(days)
        var t = 0
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            t += windowSum(pick(snap), id, cutoff: cut)
        }
        if !family.excludedIDs.contains(saved.deviceID) { t += windowSum(own, id, cutoff: cut) }
        return t
    }
    func recentWrong(_ id: String, days: Int = AppState.recentWindowDays) -> Int {
        mergedRecent({ $0.recentWrongMap }, saved.recentWrong, id, days: days)
    }
    func recentDone(_ id: String, days: Int = AppState.recentWindowDays) -> Int {
        mergedRecent({ $0.recentPlaysMap }, saved.recentPlays, id, days: days)
    }
    func recentStarted(_ id: String, days: Int = AppState.recentWindowDays) -> Int {
        mergedRecent({ $0.recentStartsMap }, saved.recentStarts, id, days: days)
    }
    func recentAbandoned(_ id: String, days: Int = AppState.recentWindowDays) -> Int {
        max(0, recentStarted(id, days: days) - recentDone(id, days: days))
    }
    func recentAccuracy(_ id: String, days: Int = AppState.recentWindowDays) -> Double? {
        let done = recentDone(id, days: days), wrong = recentWrong(id, days: days)
        let attempts = done + wrong
        guard attempts >= 3 else { return nil }
        return Double(done) / Double(attempts)
    }
    /// How hard a game has been for him lately (higher = harder): recent wrong
    /// taps, weighted quits, and low accuracy. Used to serve the feed easiest
    /// first, so he opens on games he can win instead of ones he's fighting.
    /// Brand-new games score 0, so they sit up front as fresh, pressure-free wins.
    func struggleScore(_ id: String, days: Int = AppState.recentWindowDays) -> Double {
        var s = Double(recentWrong(id, days: days)) + 3.0 * Double(recentAbandoned(id, days: days))
        if let a = recentAccuracy(id, days: days) { s += (1.0 - a) * 8.0 }
        return s
    }

    func hasRecentActivity(_ id: String, days: Int = AppState.recentWindowDays) -> Bool {
        recentStarted(id, days: days) > 0 || recentWrong(id, days: days) > 0 || recentDone(id, days: days) > 0
    }

    /// Every recent wrong answer across the family, newest first — the raw
    /// detail behind the Insights counts, for drilling into what he missed.
    var mergedMisses: [MissEvent] {
        var all: [MissEvent] = []
        if !family.excludedIDs.contains(saved.deviceID) { all += saved.misses }
        for snap in family.snapshots where snap.deviceID != saved.deviceID && !family.excludedIDs.contains(snap.deviceID) {
            all += snap.missList
        }
        return all.sorted { $0.date > $1.date }
    }
    func misses(for id: String) -> [MissEvent] { mergedMisses.filter { $0.skill == id } }

    /// True once ANY device has started recording the day-bucketed recent data.
    /// Until then (e.g. right after the update, before his devices run the new
    /// build), Insights falls back to lifetime totals so it isn't misleadingly
    /// empty — showing "0 wrong" when he really did miss some.
    var hasAnyRecentData: Bool {
        func any(_ m: [String: [String: Int]]) -> Bool { m.contains { !$0.value.isEmpty } }
        if !family.excludedIDs.contains(saved.deviceID),
           any(saved.recentWrong) || any(saved.recentStarts) || any(saved.recentPlays) { return true }
        for snap in family.snapshots where !family.excludedIDs.contains(snap.deviceID) {
            if any(snap.recentWrongMap) || any(snap.recentStartsMap) || any(snap.recentPlaysMap) { return true }
        }
        return false
    }

    // MARK: - Leveling (games get harder as he masters them)

    static let maxLevel = 3
    /// Skills whose difficulty scales each time he masters them — counting,
    /// adding, and subtracting climb from Kindergarten counts toward within 20.
    /// Every generated number game (`.numberGen`) is levelable, so the ladder
    /// applies to what is actually live instead of three ids that were pulled
    /// from the feed. A levelable game leaves the feed only after it has been
    /// mastered at every level (see `isRetired`).
    static let levelableSkills: Set<String> = Set(Curriculum.allSeededSkills.compactMap { s -> String? in
        if case .numberGen = s.lesson { return s.id } else { return nil }
    })

    /// Every generated number game is taught concrete-first: three act-it-out
    /// stages (ActOutPlayer: drag the animals, count them, predict) come BEFORE
    /// the number pad. These games have a 6-rung ladder: stages 1-3, then
    /// number pad levels 1-3.
    static let concreteStages = 3
    static let concreteSkills: Set<String> = levelableSkills

    /// How many rungs of one ladder game he may climb in a single sitting.
    /// A round ends, the win screen offers "Keep going", and he can step up the
    /// ladder this many times before the offer stops and he goes back to the
    /// feed to pick something else. Raise it if the sittings still end too fast.
    /// (Paige, Sept 2026: the games were over too quickly.)
    static let maxChainRungs = 3

    /// Rounds in ONE level of a generated number game. The curriculum entries
    /// still carry a `rounds:` number each, but those were written when a round
    /// was a single tap. A round is now a drag, a count and a tap, and with
    /// three levels chained the old 4 made a sitting 12 of them long — which is
    /// what Doosy hit: "it is really long, I never wanted more than 3 at once."
    /// This is the one dial. Three levels of 2 is a six-round sitting.
    static let numberRoundsPerLevel = 2

    /// The MOST items one sorting game asks him to carry in a single play.
    /// Most sorts were written at 8 (a couple at 9), which made them the
    /// longest thing left in the app once the math sittings came down to six
    /// rounds. This is a ceiling, not a fixed number: a sort deliberately
    /// written short stays short.
    static let sortItemsPerPlay = 6

    /// The rung a skill is on (1-based), from how many times it has been
    /// mastered across the family. For most games this is the same as the
    /// level; for concrete-first games rungs 1-3 are the act-it-out stages.
    func currentRung(_ id: String) -> Int {
        guard Self.levelableSkills.contains(id) else { return 1 }
        let top = Self.concreteSkills.contains(id) ? Self.concreteStages + Self.maxLevel : Self.maxLevel
        return min(top, 1 + mergedCount(id) / max(1, saved.masteryThreshold))
    }

    /// Current difficulty level (1...maxLevel) for a skill, from how many times
    /// it has been mastered across the family. A concrete-first game is at
    /// level 1 until it has climbed past its act-it-out stages.
    func currentLevel(_ id: String) -> Int { level(forRung: currentRung(id), id: id) }

    /// The difficulty level a given rung plays at. `currentLevel` is this
    /// applied to the rung he has earned; a chained sitting uses it to look one
    /// rung ahead without touching his earned progress.
    func level(forRung rung: Int, id: String) -> Int {
        guard Self.levelableSkills.contains(id) else { return 1 }
        if Self.concreteSkills.contains(id) { return max(1, min(Self.maxLevel, rung - Self.concreteStages)) }
        return min(Self.maxLevel, rung)
    }

    /// A game leaves the home feed only when fully done: mastered once for a
    /// plain skill, or mastered at every level for a levelable one.
    func isRetired(_ id: String) -> Bool {
        let rungs = Self.concreteSkills.contains(id) ? Self.concreteStages + Self.maxLevel : Self.maxLevel
        let need = Self.levelableSkills.contains(id) ? saved.masteryThreshold * rungs : saved.masteryThreshold
        // Only retire a game once it's truly mastered — finished enough times AND
        // cleanly. A game he only guessed his way through stays in his feed so he
        // gets the chance to actually learn it.
        return mergedCount(id) >= need && !isGuessy(id)
    }

    // MARK: - Homeschool report (for Paige's records)

    /// A plain-text learning report grouped by subject and California standard.
    func homeschoolReport() -> String {
        let counts = mergedCounts
        let df = DateFormatter(); df.dateStyle = .long
        let played = counts.values.reduce(0, +)
        let done = Curriculum.allSeededSkills.filter { (counts[$0.id] ?? 0) > 0 }
        let mastered = done.filter { (counts[$0.id] ?? 0) >= saved.masteryThreshold }
        var lines: [String] = []
        lines.append("Gabriel's Learning Report")
        lines.append(df.string(from: Date()))
        lines.append("")
        lines.append("Games completed: \(played)")
        lines.append("Skills practiced: \(done.count)    Mastered: \(mastered.count)")
        lines.append("")
        for subject in Subject.allCases {
            let inSubject = done.filter { $0.subject == subject }.sorted { $0.title < $1.title }
            guard !inSubject.isEmpty else { continue }
            lines.append("\(subject.emoji) \(subject.title.uppercased())")
            for s in inSubject {
                let c = counts[s.id] ?? 0
                let star = c >= saved.masteryThreshold ? "  \u{2713} mastered" : ""
                lines.append("   • \(s.title)  (\(s.standard)) — \(c)\(star)")
            }
            lines.append("")
        }
        lines.append("Standards: California Kindergarten / Grade 1 (Common Core & NGSS).")
        return lines.joined(separator: "\n")
    }

    // MARK: - Settings mutations

    func setActiveGrade(_ g: Int) {
        saved.activeGrade = g
        if !saved.enabledGrades.contains(g) { saved.enabledGrades.append(g) }
        reshuffleMenu()
    }

    var hasPIN: Bool { saved.parentPIN.count == 4 }
    func setPIN(_ p: String) { saved.parentPIN = p }
    func checkPIN(_ p: String) -> Bool { p == saved.parentPIN }

    func setMinutesPerConcept(_ n: Int) { saved.minutesPerConcept = max(5, min(n, 120)); family.writeSettings(currentSettings()) }
    func setCalmMode(_ on: Bool) { saved.calmMode = on }

    /// A week-at-a-glance card for grown-ups: what he finished, what he
    /// mastered, where he is stuck and the exact things he missed.
    func weeklyReport(days: Int = 7) -> String {
        let df = DateFormatter(); df.dateStyle = .medium
        let all = Curriculum.allSeededSkills
        let played = all.filter { recentDone($0.id, days: days) > 0 }
        let finishes = played.reduce(0) { $0 + recentDone($1.id, days: days) }
        let newlyMastered = played.filter { isMastered($0.id) }
        let stuck = all.filter { recentWrong($0.id, days: days) >= 3 || recentAbandoned($0.id, days: days) >= 2 }
            .sorted { struggleScore($0.id, days: days) > struggleScore($1.id, days: days) }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let misses = mergedMisses.filter { $0.date >= cutoff }
        var lines: [String] = []
        lines.append("Gabriel this week (\(df.string(from: cutoff)) to \(df.string(from: Date())))")
        lines.append("")
        lines.append("Finished \(finishes) games across \(played.count) skills.")
        let secs = (saved.secondsByDay ?? [:]).values.reduce(0, +)
        if secs > 0 {
            let mins = secs / 60
            let avg = finishes > 0 ? secs / finishes : 0
            lines.append("Time actually playing: \(mins) min, about \(avg)s per game.")
        }
        if !newlyMastered.isEmpty {
            lines.append("Mastered: " + newlyMastered.map(\.title).sorted().joined(separator: ", "))
        }
        lines.append("")
        if stuck.isEmpty {
            lines.append("Nothing he is stuck on. 🎉")
        } else {
            lines.append("Where he is stuck:")
            for s in stuck.prefix(6) {
                let w = recentWrong(s.id, days: days), q = recentAbandoned(s.id, days: days)
                var detail = "\(w) misses"
                if q > 0 { detail += ", quit \(q)x" }
                lines.append("  • \(s.title) (\(detail))")
                // The three most common wrong taps, so the grown-up knows exactly what to practice.
                var tally: [String: Int] = [:]
                for m in misses where m.skill == s.id { tally["\(m.correct) ← tapped \(m.tapped)", default: 0] += 1 }
                for (k, n) in tally.sorted(by: { $0.value > $1.value }).prefix(3) {
                    lines.append("      \(k)\(n > 1 ? " ×\(n)" : "")")
                }
            }
        }
        // Letters: every letter or stroke he missed this week, tallied.
        var letters: [String: Int] = [:]
        for m in misses where m.correct.count == 1 && m.correct.first?.isLetter == true {
            letters[m.correct.uppercased(), default: 0] += 1
        }
        if !letters.isEmpty {
            lines.append("")
            lines.append("Letters to practice: " + letters.sorted { $0.value > $1.value }
                .map { "\($0.key) (\($0.value))" }.joined(separator: ", "))
        }
        return lines.joined(separator: "\n")
    }

    func setMasteryThreshold(_ n: Int) { saved.masteryThreshold = max(1, min(n, 5)); family.writeSettings(currentSettings()) }
    func setYouTubeURL(_ s: String) { saved.youTubeURL = s; family.writeSettings(currentSettings()) }
    func resetEarnedTime() { family.setMinutes(0) }

    func resetTodayProgress() {
        saved.todayDone = []
    }

    /// Clear the collected animal buddies so they can be earned again.
    func resetBuddies() {
        saved.earnedBuddies = []
        saved.lastUnlockKey = ""
    }

    func resetAllMastery() {
        saved.completionCounts = [:]
        reshuffleMenu()
    }
}
