import Foundation
import Combine
import Security

/// A per-install identifier that survives app reinstalls. Stored in the
/// keychain (which UserDefaults isn't — reinstalling wiped the old id and
/// spawned a brand-new "phantom" device every time). Migrates any existing
/// UserDefaults id in on first run so we don't create yet another record.
enum DeviceIdentity {
    private static let service = "com.turley.LearnTube.deviceID"

    static func stable(fallback: String) -> String {
        if let existing = read(), !existing.isEmpty { return existing }
        let id = fallback.isEmpty ? UUID().uuidString : fallback
        save(id)
        return id
    }

    private static func read() -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne]
        var out: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess,
              let data = out as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func save(_ id: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service]
        SecItemDelete(base as CFDictionary)
        var add = base
        add[kSecValueData as String] = Data(id.utf8)
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(add as CFDictionary, nil)
    }
}

/// A small, shareable summary of one device's progress. Synced through iCloud
/// key-value storage so a parent can see each child's activity on their own
/// phone (same Apple ID), with no server.
struct ProgressSnapshot: Codable, Identifiable {
    var deviceID: String
    var name: String
    var dayKey: String
    var todayCounts: [String: Int]   // lessonID -> times finished today
    var buddyCount: Int
    var updatedAt: Date
    // Optional so older synced snapshots (without these) still decode.
    var allCounts: [String: Int]?    // lessonID -> times finished all-time
    var masteredCount: Int?          // games reaching the mastery goal
    var lastPlayed: [String: Date]?  // lessonID -> when it was last finished
    var wrongCounts: [String: Int]?  // lessonID -> total wrong taps (struggle)
    var startedCounts: [String: Int]? // lessonID -> games opened (finished + abandoned)
    // Day-bucketed recent activity (lessonID -> "yyyy-MM-dd" -> count) for the
    // rolling recent window in Insights.
    var recentWrong: [String: [String: Int]]?
    var recentStarts: [String: [String: Int]]?
    var recentPlays: [String: [String: Int]]?
    var misses: [MissEvent]?          // recent specific wrong answers (newest first)
    var earnedBuddies: [String]?      // farm animals collected (so the farm is family-wide)
    var winsLog: [WinEvent]?          // celebration feed (so My Wins is family-wide)

    enum CodingKeys: String, CodingKey {
        case deviceID, name, dayKey, todayCounts, buddyCount, updatedAt, allCounts, masteredCount, lastPlayed, wrongCounts, startedCounts, recentWrong, recentStarts, recentPlays, misses, earnedBuddies, winsLog
    }
    init(deviceID: String, name: String, dayKey: String, todayCounts: [String: Int],
         buddyCount: Int, updatedAt: Date, allCounts: [String: Int]?, masteredCount: Int?,
         lastPlayed: [String: Date]? = nil, wrongCounts: [String: Int]? = nil,
         startedCounts: [String: Int]? = nil,
         recentWrong: [String: [String: Int]]? = nil,
         recentStarts: [String: [String: Int]]? = nil,
         recentPlays: [String: [String: Int]]? = nil,
         misses: [MissEvent]? = nil,
         earnedBuddies: [String]? = nil,
         winsLog: [WinEvent]? = nil) {
        self.deviceID = deviceID; self.name = name; self.dayKey = dayKey
        self.todayCounts = todayCounts; self.buddyCount = buddyCount; self.updatedAt = updatedAt
        self.allCounts = allCounts; self.masteredCount = masteredCount; self.lastPlayed = lastPlayed
        self.wrongCounts = wrongCounts; self.startedCounts = startedCounts
        self.recentWrong = recentWrong; self.recentStarts = recentStarts; self.recentPlays = recentPlays
        // Cap what we sync so the record stays small.
        self.misses = misses.map { Array($0.prefix(60)) }
        self.earnedBuddies = earnedBuddies
        self.winsLog = winsLog.map { Array($0.prefix(40)) }
    }
    // Lenient decode: Firebase omits empty maps, so default any missing fields.
    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        deviceID = try c.decode(String.self, forKey: .deviceID)
        name = (try? c.decode(String.self, forKey: .name)) ?? ""
        dayKey = (try? c.decode(String.self, forKey: .dayKey)) ?? ""
        todayCounts = (try? c.decode([String: Int].self, forKey: .todayCounts)) ?? [:]
        buddyCount = (try? c.decode(Int.self, forKey: .buddyCount)) ?? 0
        updatedAt = (try? c.decode(Date.self, forKey: .updatedAt)) ?? Date()
        allCounts = try? c.decode([String: Int].self, forKey: .allCounts)
        masteredCount = try? c.decode(Int.self, forKey: .masteredCount)
        lastPlayed = try? c.decode([String: Date].self, forKey: .lastPlayed)
        wrongCounts = try? c.decode([String: Int].self, forKey: .wrongCounts)
        startedCounts = try? c.decode([String: Int].self, forKey: .startedCounts)
        recentWrong = try? c.decode([String: [String: Int]].self, forKey: .recentWrong)
        recentStarts = try? c.decode([String: [String: Int]].self, forKey: .recentStarts)
        recentPlays = try? c.decode([String: [String: Int]].self, forKey: .recentPlays)
        misses = try? c.decode([MissEvent].self, forKey: .misses)
        earnedBuddies = try? c.decode([String].self, forKey: .earnedBuddies)
        winsLog = try? c.decode([WinEvent].self, forKey: .winsLog)
    }

    var id: String { deviceID }
    func playedTime(_ id: String) -> Date? { lastPlayed?[id] }
    var wrongTaps: [String: Int] { wrongCounts ?? [:] }
    var starts: [String: Int] { startedCounts ?? [:] }
    var recentWrongMap: [String: [String: Int]] { recentWrong ?? [:] }
    var recentStartsMap: [String: [String: Int]] { recentStarts ?? [:] }
    var recentPlaysMap: [String: [String: Int]] { recentPlays ?? [:] }
    var missList: [MissEvent] { misses ?? [] }
    var buddyList: [String] { earnedBuddies ?? [] }
    var winList: [WinEvent] { winsLog ?? [] }
    var totalToday: Int { todayCounts.values.reduce(0, +) }
    var allTime: [String: Int] { allCounts ?? [:] }
    var totalEver: Int { allTime.values.reduce(0, +) }
    var mastered: Int { masteredCount ?? 0 }
}

/// Grown-up settings shared across the family's devices (so the kid iPad,
/// which has no Grown-Ups tab, follows what a parent sets on their phone).
struct FamilySettings: Codable, Equatable {
    var minutesPerConcept: Int          // minutes earned per win (finished game)
    var masteryThreshold: Int
    var maxPlaysPerDay: Int
    var youTubeURL: String
    var dailyStartMinutes: Int = 15     // free minutes in the bank each new day
    var dailyCapMinutes: Int = 0        // 0 = no daily limit; else max watched/day

    init(minutesPerConcept: Int, masteryThreshold: Int, maxPlaysPerDay: Int,
         youTubeURL: String, dailyStartMinutes: Int = 15, dailyCapMinutes: Int = 0) {
        self.minutesPerConcept = minutesPerConcept
        self.masteryThreshold = masteryThreshold
        self.maxPlaysPerDay = maxPlaysPerDay
        self.youTubeURL = youTubeURL
        self.dailyStartMinutes = dailyStartMinutes
        self.dailyCapMinutes = dailyCapMinutes
    }
    // Lenient decode so older records (missing the newer keys) still load.
    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        minutesPerConcept = (try? c.decode(Int.self, forKey: .minutesPerConcept)) ?? 20
        masteryThreshold = (try? c.decode(Int.self, forKey: .masteryThreshold)) ?? 3
        maxPlaysPerDay = (try? c.decode(Int.self, forKey: .maxPlaysPerDay)) ?? 3
        youTubeURL = (try? c.decode(String.self, forKey: .youTubeURL)) ?? "https://www.youtube.com"
        dailyStartMinutes = (try? c.decode(Int.self, forKey: .dailyStartMinutes)) ?? 15
        dailyCapMinutes = (try? c.decode(Int.self, forKey: .dailyCapMinutes)) ?? 0
    }
}

/// One shared pool of YouTube time for the whole family, plus how much was
/// watched each day. Synced so every device shows the same number.
struct FamilyTime: Codable, Equatable {
    var availableMinutes: Int = 0
    var watchedByDay: [String: Int] = [:]
}

@MainActor
final class FamilySync: ObservableObject {
    static let prefix = "lt.progress."
    static let settingsKey = "lt.settings"
    private let store = NSUbiquitousKeyValueStore.default
    @Published private(set) var snapshots: [ProgressSnapshot] = []
    @Published private(set) var settings: FamilySettings?
    @Published private(set) var time: FamilyTime?
    /// Grown-up-assigned display names per deviceID (e.g. "Doosy's iPad mini"),
    /// so a device can be labeled correctly no matter what it calls itself.
    @Published private(set) var deviceNames: [String: String] = [:]
    /// Devices a grown-up marked "don't count" (e.g. a parent's test device).
    /// Filtered out of every total, mastery check, insight, and daily feed.
    @Published private(set) var excludedIDs: Set<String> = []

    // Shared time pool lives in the family's Firebase Realtime Database, so the
    // Mac browser gate, the iPhone, and the iPad all read and write one number.
    static let dbURL = "https://learntube-family-default-rtdb.firebaseio.com"
    private var pollTimer: Timer?

    func writeSettings(_ s: FamilySettings) {
        settings = s
        guard let data = try? JSONEncoder().encode(s) else { return }
        // iCloud for devices that have the entitlement; Firebase works everywhere
        // (including the ad-hoc-signed admin Mac), so settings sync from any device.
        store.set(data, forKey: Self.settingsKey); store.synchronize()
        if let url = URL(string: "\(Self.dbURL)/family/settings.json") {
            var req = URLRequest(url: url); req.httpMethod = "PUT"; req.httpBody = data
            URLSession.shared.dataTask(with: req).resume()
        }
    }

    /// Pull shared grown-up settings from Firebase.
    func pullSettings() {
        guard let url = URL(string: "\(Self.dbURL)/family/settings.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, data.count > 4,
                  let s = try? JSONDecoder().decode(FamilySettings.self, from: data) else { return }
            Task { @MainActor in if self?.settings != s { self?.settings = s } }
        }.resume()
    }

    /// Pull grown-up-assigned device names from Firebase.
    func pullDeviceNames() {
        guard let url = URL(string: "\(Self.dbURL)/family/deviceNames.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, data.count > 4,
                  let obj = try? JSONDecoder().decode([String: String].self, from: data) else { return }
            Task { @MainActor in if self?.deviceNames != obj { self?.deviceNames = obj } }
        }.resume()
    }

    /// Pull the set of "don't count" devices from Firebase.
    func pullExcluded() {
        guard let url = URL(string: "\(Self.dbURL)/family/excludedDevices.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, err in
            guard err == nil, let data = data else { return }
            let obj = (try? JSONDecoder().decode([String: Bool].self, from: data)) ?? [:]
            let ids = Set(obj.filter { $0.value }.keys)
            Task { @MainActor in if self?.excludedIDs != ids { self?.excludedIDs = ids } }
        }.resume()
    }

    /// Mark a device as counted or ignored, shared to every device.
    func setExcluded(_ deviceID: String, _ excluded: Bool) {
        if excluded { excludedIDs.insert(deviceID) } else { excludedIDs.remove(deviceID) }
        guard let url = URL(string: "\(Self.dbURL)/family/excludedDevices/\(deviceID).json") else { return }
        var req = URLRequest(url: url)
        if excluded { req.httpMethod = "PUT"; req.httpBody = Data("true".utf8) }
        else { req.httpMethod = "DELETE" }
        URLSession.shared.dataTask(with: req).resume()
    }

    /// Set (or clear, if blank) the display name for one device, shared to all.
    func setDeviceName(_ deviceID: String, _ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { deviceNames[deviceID] = nil } else { deviceNames[deviceID] = trimmed }
        guard let url = URL(string: "\(Self.dbURL)/family/deviceNames/\(deviceID).json") else { return }
        var req = URLRequest(url: url)
        if trimmed.isEmpty {
            req.httpMethod = "DELETE"
        } else {
            req.httpMethod = "PUT"; req.httpBody = try? JSONEncoder().encode(trimmed)
        }
        URLSession.shared.dataTask(with: req).resume()
    }

    /// Update the shared pool: keep it locally and push to Firebase.
    func writeTime(_ t: FamilyTime) {
        time = t
        pushTime(t)
    }

    /// Directly OVERWRITE this device's cloud completion and wrong counts. Used
    /// by the one-time "reset the guessed-through topics" pass — the normal push
    /// only ever grows counts (to survive reinstalls), so a reset must set them.
    func overwriteCounts(deviceID: String, allCounts: [String: Int], wrongCounts: [String: Int]) {
        guard !deviceID.isEmpty else { return }
        func put(_ path: String, _ dict: [String: Int]) {
            guard let url = URL(string: "\(Self.dbURL)/family/progress/\(deviceID)/\(path).json"),
                  let body = try? JSONEncoder().encode(dict) else { return }
            var r = URLRequest(url: url); r.httpMethod = "PUT"; r.httpBody = body
            URLSession.shared.dataTask(with: r).resume()
        }
        put("allCounts", allCounts)
        put("wrongCounts", wrongCounts)
    }

    /// Once per calendar day, set the shared bank to the daily starting amount.
    /// Coordinated through Firebase (`lastGrantDay`) so only the first device to
    /// open on a new day applies it, and leftover time doesn't roll over.
    func applyDailyStartIfNeeded(_ amount: Int) {
        let today = AppState.dayKey
        guard let markURL = URL(string: "\(Self.dbURL)/family/lastGrantDay.json"),
              let poolURL = URL(string: "\(Self.dbURL)/family/availableMinutes.json") else { return }
        URLSession.shared.dataTask(with: markURL) { [weak self] data, _, err in
            // If the read succeeds and another device already granted today, skip.
            // If the read FAILS (Firebase briefly unreachable), still reset — the
            // caller only invokes this on a genuinely new local day, so we must
            // not let a flaky read leave yesterday's balance rolling over.
            if err == nil {
                let last = (data.flatMap { String(data: $0, encoding: .utf8) } ?? "")
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"\n \t"))
                if last == today { return }              // already granted today
            }
            var mreq = URLRequest(url: markURL); mreq.httpMethod = "PUT"
            mreq.httpBody = try? JSONEncoder().encode(today)
            URLSession.shared.dataTask(with: mreq).resume()
            var preq = URLRequest(url: poolURL); preq.httpMethod = "PUT"
            preq.httpBody = Data(String(amount).utf8)
            URLSession.shared.dataTask(with: preq).resume()
            Task { @MainActor in
                var t = self?.time ?? FamilyTime(); t.availableMinutes = amount; self?.time = t
            }
        }.resume()
    }

    init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(externalChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
        store.synchronize()
        reload()
        // Start the shared sync (time + progress): pull now, then poll.
        pullTime(); pullProgress(); pullSettings(); pullDeviceNames(); pullExcluded()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.pullTime(); self?.pullProgress(); self?.pullSettings(); self?.pullDeviceNames(); self?.pullExcluded() }
        }
    }

    /// iCloud pushed a change from another device.
    @objc nonisolated private func externalChange() {
        Task { @MainActor in self.reload() }
    }

    /// Publish this device's progress snapshot to the shared Firebase record.
    func write(_ snap: ProgressSnapshot) {
        // Show our own progress immediately, then push to Firebase.
        snapshots.removeAll { $0.deviceID == snap.deviceID }
        snapshots.append(snap)
        snapshots.sort { $0.updatedAt > $1.updatedAt }
        guard let url = URL(string: "\(Self.dbURL)/family/progress/\(snap.deviceID).json") else { return }
        // Read the existing cloud record first and keep the LARGER of each
        // count, so a device's all-time history can only grow. A reinstall
        // wipes local data, but the cloud copy (and the school-credit totals)
        // must never shrink.
        URLSession.shared.dataTask(with: url) { data, _, _ in
            var merged = snap
            if let data = data, data.count > 4,
               let remote = try? JSONDecoder().decode(ProgressSnapshot.self, from: data) {
                var counts = snap.allCounts ?? [:]
                for (k, v) in remote.allTime { counts[k] = max(counts[k] ?? 0, v) }
                merged.allCounts = counts
                var lp = snap.lastPlayed ?? [:]
                for (k, v) in (remote.lastPlayed ?? [:]) where lp[k] == nil || v > lp[k]! { lp[k] = v }
                merged.lastPlayed = lp
                merged.masteredCount = counts.values.filter { $0 >= 3 }.count
                merged.buddyCount = max(snap.buddyCount, remote.buddyCount)
            }
            guard let body = try? JSONEncoder().encode(merged) else { return }
            var req = URLRequest(url: url); req.httpMethod = "PUT"; req.httpBody = body
            URLSession.shared.dataTask(with: req).resume()
        }.resume()
    }

    /// Re-read shared grown-up settings from iCloud. Progress now syncs through
    /// Firebase (see pullProgress), so it is not rebuilt here.
    func reload() {
        if let data = store.data(forKey: Self.settingsKey),
           let s = try? JSONDecoder().decode(FamilySettings.self, from: data) {
            settings = s
        }
    }

    // MARK: - Firebase shared time (REST)

    /// Pull the shared pool from Firebase and publish it if it changed.
    func pullTime() {
        guard let url = URL(string: "\(Self.dbURL)/family.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            let avail = (obj["availableMinutes"] as? NSNumber)?.intValue ?? 0
            var watched: [String: Int] = [:]
            if let w = obj["watchedByDay"] as? [String: Any] {
                for (k, v) in w { watched[k] = (v as? NSNumber)?.intValue ?? 0 }
            }
            let t = FamilyTime(availableMinutes: avail, watchedByDay: watched)
            Task { @MainActor in
                guard let self else { return }
                if self.time != t { self.time = t }
            }
        }.resume()
    }

    /// Push this device's pool to Firebase (absolute value, last write wins).
    private func pushTime(_ t: FamilyTime) {
        if let url = URL(string: "\(Self.dbURL)/family/availableMinutes.json") {
            var req = URLRequest(url: url)
            req.httpMethod = "PUT"
            req.httpBody = Data(String(t.availableMinutes).utf8)
            URLSession.shared.dataTask(with: req).resume()
        }
        if let url = URL(string: "\(Self.dbURL)/family/watchedByDay.json"),
           let body = try? JSONEncoder().encode(t.watchedByDay) {
            var req = URLRequest(url: url)
            req.httpMethod = "PATCH"                     // merge days, don't clobber
            req.httpBody = body
            URLSession.shared.dataTask(with: req).resume()
        }
    }

    // MARK: - Firebase shared progress (REST)

    /// Pull every device's progress snapshot from Firebase.
    func pullProgress() {
        guard let url = URL(string: "\(Self.dbURL)/family/progress.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, data.count > 4,
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            var out: [ProgressSnapshot] = []
            for (_, v) in obj {
                if let d = try? JSONSerialization.data(withJSONObject: v),
                   let snap = try? JSONDecoder().decode(ProgressSnapshot.self, from: d) {
                    out.append(snap)
                }
            }
            let sorted = out.sorted { $0.updatedAt > $1.updatedAt }
            Task { @MainActor in self?.snapshots = sorted }
        }.resume()
    }

    /// Change the shared minutes by a delta, reading the current remote value
    /// first so simultaneous changes on two devices don't clobber each other
    /// (e.g. a parent's Clear while the kid is watching).
    func applyMinutesDelta(_ delta: Int, watchedDay: String?) {
        guard let url = URL(string: "\(Self.dbURL)/family/availableMinutes.json") else { return }
        let localBase = time?.availableMinutes    // last known value, captured on the main actor
        URLSession.shared.dataTask(with: url) { [weak self] data, _, err in
            // Firebase returns a bare number (e.g. "30"). Parse it as text.
            // If the read fails, fall back to the last known local value —
            // NEVER default to 0, or a spend would wipe the whole shared pool.
            let remote = (err == nil) ? Self.parseInt(data) : nil
            guard let base = remote ?? localBase else { return }
            let next = max(0, base + delta)
            Self.putInt(next, to: url)
            if let day = watchedDay, let wurl = URL(string: "\(Self.dbURL)/family/watchedByDay/\(day).json") {
                URLSession.shared.dataTask(with: wurl) { wdata, _, _ in
                    let w = Self.parseInt(wdata) ?? 0
                    Self.putInt(w + 1, to: wurl)
                    Task { @MainActor in
                        guard let self else { return }
                        var t = self.time ?? FamilyTime(); t.availableMinutes = next; t.watchedByDay[day] = w + 1; self.time = t
                    }
                }.resume()
            } else {
                Task { @MainActor in
                    guard let self else { return }
                    var t = self.time ?? FamilyTime(); t.availableMinutes = next; self.time = t
                }
            }
        }.resume()
    }

    /// Parse a bare JSON number leaf ("30", "null") from a Firebase REST read.
    private static func parseInt(_ data: Data?) -> Int? {
        guard let data, let s = String(data: data, encoding: .utf8) else { return nil }
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t == "null" || t.isEmpty { return 0 }
        return Int(t)
    }

    private static func putInt(_ v: Int, to url: URL) {
        var req = URLRequest(url: url); req.httpMethod = "PUT"; req.httpBody = Data(String(v).utf8)
        URLSession.shared.dataTask(with: req).resume()
    }

    /// Set the shared minutes to an exact value (parent Clear / set).
    func setMinutes(_ value: Int) {
        let v = max(0, value)
        if let url = URL(string: "\(Self.dbURL)/family/availableMinutes.json") {
            var put = URLRequest(url: url); put.httpMethod = "PUT"; put.httpBody = Data(String(v).utf8)
            URLSession.shared.dataTask(with: put).resume()
        }
        var t = time ?? FamilyTime(); t.availableMinutes = v; time = t
    }
}
