import SwiftUI

struct GrownUpsView: View {
    @EnvironmentObject var state: AppState
    @State private var unlocked = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            if unlocked {
                GrownUpSettings(lock: { unlocked = false })
            } else {
                GrownUpGate(onPass: { unlocked = true })
            }
        }
    }
}

/// A 4-digit PIN gate. First time, the grown-up creates a PIN; after that it's
/// required to enter the Grown-Ups area.
struct GrownUpGate: View {
    @EnvironmentObject var state: AppState
    let onPass: () -> Void

    @State private var entry = ""
    @State private var firstEntry = ""     // for confirming a new PIN
    @State private var shake = false
    @State private var error = ""

    private var creating: Bool { !state.hasPIN }
    private var confirming: Bool { creating && firstEntry.count == 4 }

    private var title: String {
        if confirming { return "Re-enter to confirm" }
        if creating { return "Create a 4-digit PIN" }
        return "Enter PIN"
    }

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "lock.shield.fill").font(.system(size: 50)).foregroundStyle(Theme.red)
            Text("Grown-Ups Only").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(.white)
            Text(title).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(Theme.textSecondary)

            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .strokeBorder(Theme.surfaceHi, lineWidth: 2)
                        .background(Circle().fill(i < entry.count ? Theme.red : .clear))
                        .frame(width: 18, height: 18)
                }
            }
            .offset(x: shake ? -10 : 0)

            if !error.isEmpty {
                Text(error).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundStyle(Theme.red)
            }

            pad
        }
        .padding(30)
    }

    private var pad: some View {
        VStack(spacing: 12) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 12) { ForEach(row, id: \.self) { n in key("\(n)") } }
            }
            HStack(spacing: 12) {
                Color.clear.frame(width: 70, height: 64)
                key("0")
                Button { if !entry.isEmpty { entry.removeLast() } } label: {
                    Image(systemName: "delete.left.fill").font(.system(size: 22))
                        .frame(width: 70, height: 64).foregroundStyle(.white)
                }
            }
        }
    }

    private func key(_ d: String) -> some View {
        Button { press(d) } label: {
            Text(d).font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(.white)
                .frame(width: 70, height: 64).background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func press(_ d: String) {
        guard entry.count < 4 else { return }
        error = ""
        entry += d
        if entry.count == 4 { submit() }
    }

    private func submit() {
        if creating {
            if firstEntry.isEmpty {
                firstEntry = entry; entry = ""
            } else if firstEntry == entry {
                state.setPIN(entry); onPass()
            } else {
                error = "PINs didn't match. Try again."; firstEntry = ""; entry = ""; doShake()
            }
        } else {
            if state.checkPIN(entry) { onPass() }
            else { error = "Wrong PIN."; entry = ""; doShake() }
        }
    }

    private func doShake() {
        withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) { shake = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shake = false }
    }
}

struct GrownUpSettings: View {
    @EnvironmentObject var state: AppState
    let lock: () -> Void
    @State private var youTube = ""
    @State private var name = ""
    @State private var showReset = false
    @State private var showResetBuddies = false
    @State private var ytSyncMsg = ""

    var body: some View {
        Form {
            Section("This Phone") {
                TextField("Whose phone is this?", text: $name)
                    .autocorrectionDisabled()
                    .onChange(of: name) { new in state.setPlayerName(new) }
                Text("This name labels this phone in Family Progress, so you can tell whose activity is whose. Set it to \"Gabriel\" on his phone.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("YouTube Time") {
                // Menu-of-Buttons instead of Picker(selection:): a Picker bound to a
                // custom get/set Binding does NOT fire its setter reliably in a Form on
                // Mac Catalyst, so changes silently never saved. Buttons always fire.
                LabeledContent("Per win (game)") {
                    Menu("\(state.saved.minutesPerConcept) min") {
                        ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { m in
                            Button("\(m) min") { state.setMinutesPerConcept(m) }
                        }
                    }
                }
                LabeledContent("Start of day") {
                    Menu(state.dailyStartMinutes == 0 ? "None" : "\(state.dailyStartMinutes) min") {
                        ForEach([0, 10, 15, 20, 30], id: \.self) { m in
                            Button(m == 0 ? "None" : "\(m) min") { state.setDailyStartMinutes(m) }
                        }
                    }
                }
                LabeledContent("Daily limit") {
                    Menu(state.dailyCapMinutes == 0 ? "No limit" : "\(state.dailyCapMinutes) min") {
                        Button("No limit") { state.setDailyCapMinutes(0) }
                        ForEach([30, 45, 60, 90, 120], id: \.self) { m in
                            Button("\(m) min") { state.setDailyCapMinutes(m) }
                        }
                    }
                }
                HStack {
                    Text("Available now")
                    Spacer()
                    Text(state.minutesLabel(state.availableMinutes)).foregroundStyle(.secondary)
                }
                HStack(spacing: 10) {
                    Button("Gift +15") { state.addFamilyMinutes(15) }.buttonStyle(.borderless)
                    Button("−15") { state.addFamilyMinutes(-15) }.buttonStyle(.borderless)
                    Spacer()
                    Button("Clear", role: .destructive) { state.resetEarnedTime() }.buttonStyle(.borderless)
                }
                HStack {
                    Text("Watched today")
                    Spacer()
                    Text("\(state.watchedTodayMinutes) min\(state.dailyCapMinutes > 0 ? " / \(state.dailyCapMinutes)" : "")").foregroundStyle(.secondary)
                }
                Text("He starts each day with the \"start of day\" minutes, earns \"per win\" for each finished game, and you can gift more any time. \"Daily limit\" caps total watching per day (off by default). Shared across all his devices.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("YouTube Login") {
                Button("Copy YouTube login to Gabriel's iPad") {
                    YTSession.export { count in
                        ytSyncMsg = count > 0
                            ? "Copied the login (\(count) items). It will sync to the iPad in a minute."
                            : "No YouTube login found on this phone. Open YouTube here and sign in first, then try again."
                    }
                }
                if !ytSyncMsg.isEmpty {
                    Text(ytSyncMsg).font(.footnote).foregroundStyle(.secondary)
                }
                Text("Do this on a phone that's already signed in to YouTube. It copies the login to his iPad so he stays signed in. Re-run it if he gets signed out (logins expire after a while).")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Active Grade") {
                LabeledContent("Working on") {
                    Menu(Curriculum.gradeNames[state.saved.activeGrade] ?? "Grade \(state.saved.activeGrade)") {
                        ForEach(Curriculum.grades.filter { $0.isSeeded }) { g in
                            Button(g.name) { state.setActiveGrade(g.number) }
                        }
                    }
                }
                if state.activeGradeComplete {
                    Label("This grade is fully mastered! 🏆 Consider moving up.", systemImage: "trophy.fill")
                        .font(.footnote).foregroundStyle(Theme.green)
                }
            }
            Section("Mastery") {
                Stepper("Mastered after \(state.saved.masteryThreshold) completions",
                        value: Binding(get: { state.saved.masteryThreshold },
                                       set: { state.setMasteryThreshold($0) }), in: 1...5)
                Text("A skill must be completed this many times before it counts as mastered, so it's real mastery, not a one-off.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("YouTube Reward") {
                TextField("youtube://", text: $youTube).autocorrectionDisabled().textInputAutocapitalization(.never)
                Text("YouTube opens inside the app, locked to YouTube, with the time counter on top. Leave as the default unless you want a specific page (e.g. YouTube Kids).")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Save Link") { state.setYouTubeURL(youTube.isEmpty ? "youtube://" : youTube) }
            }
            Section("Reading Together") {
                Text("Lessons open straight into the activity now, with no \"who's reading with you?\" step to slow Gabriel down. He can play on his own anytime. When you'd like to read along, Mommy or Maddy can simply sit with him and read each page aloud together.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                ShareLink("Export learning report", item: state.homeschoolReport())
            } header: {
                Text("Homeschool Record")
            } footer: {
                Text("A summary of everything Gabriel has completed, grouped by subject and California standard — for your homeschool records.")
            }
            Section("Today") {
                Button("Shuffle today's concepts") { state.reshuffleMenu() }
                Button("Reset today's progress") { state.resetTodayProgress() }
                Button("Reset earned YouTube time") { state.resetEarnedTime() }
            }
            Section {
                Button(role: .destructive) { showResetBuddies = true } label: {
                    Text("Reset farm animals (\(state.earnedBuddyCount) of \(Buddies.all.count))")
                }
            } footer: {
                Text("Clears the animal buddies Gabriel has collected so he can earn them all again. Stars and earned time are kept.")
            }
            Section {
                Button(role: .destructive) { showReset = true } label: { Text("Reset all mastery progress") }
            } footer: {
                Text("Clears every star across all grades. Cannot be undone.")
            }
            Section {
                Button("Change PIN") { state.setPIN(""); lock() }
                Button("Lock Grown-Ups area") { lock() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .onAppear { youTube = state.saved.youTubeURL; name = state.saved.playerName }
        .confirmationDialog("Reset everything?", isPresented: $showReset, titleVisibility: .visible) {
            Button("Reset all progress", role: .destructive) { state.resetAllMastery() }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Reset farm animals?", isPresented: $showResetBuddies, titleVisibility: .visible) {
            Button("Reset farm animals", role: .destructive) { state.resetBuddies() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
