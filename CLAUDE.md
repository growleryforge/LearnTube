# LearnTube

Project memory for Claude. Read this first in any new session, then read the
files it points at. Keep it current: if you change how something works here,
update this file in the same commit.

## What this is

A SwiftUI app that fronts Gabriel's screen time. It looks and feels like
YouTube (red play wordmark, thumbnail feed, view counts, duration badges) but
the "videos" are short interactive lessons. Finishing a concept banks YouTube
minutes, and the banked minutes are what open the real YouTube session.

The disguise is the point. The app is built so Gabriel experiences it as his
YouTube app rather than as school, and so he never feels monitored while using
it. Progress records quietly and syncs to the grown-ups' dashboard.

Design constraints that show up all over the code:

- PDA-aware. Nothing nags, nothing blocks with a scold, `parentTip` on every
  skill is written as a gentle note to Paige rather than a directive.
- Gabriel is 7 and homeschooled. Curriculum tracks California standards.
- Kid devices show games only. No progress tabs, no dashboards, no "you got
  3 wrong" surfaces.

## Repo layout

```
LearnTube/            Swift sources, all of it (flat, no subfolders)
  Assets.xcassets/    App icons + the family's real animals as mascots
LearnTube.xcodeproj/  Single project, single target, single scheme
tools/check_qa.py     Curriculum guardrail, see below
win/                  Windows/web client + curriculum JSON export
dist/                 Built .app bundles staged for the NAS (gitignored)
deploy_*.sh           Build and install scripts, one per destination
"Update Parent Admin.command"  Double-clickable rebuild of the grown-up app
```

Roughly 18k lines of Swift. The big ones: `AdditionGame.swift` (~7k),
`TodayView.swift` (~1.4k), `FamilyLesson.swift`, `ProgressDashboardView.swift`,
`Curriculum1.swift`, `LessonPlayer.swift`, `AppState.swift`.

## Two apps, one target

There is only one scheme. The grown-up build is the same target compiled with
the `PARENT` flag:

    SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT'

| | Kid build | Grown-up build |
|---|---|---|
| Bundle id | `com.turley.LearnTube` | `com.turley.LearnTubeAdmin` |
| Icon | `AppIcon` | `AppIconAdmin` (gold) |
| UI | `HomeFeedView` only | TabView: Today, Progress, Insights, Family, Games, Grown-Ups |
| Tint | `Theme.green` | `Theme.gold` |
| Runs on | Gabriel's iPhone, iPad, laptop | Parents' Macs and iPhones |

`#if PARENT` appears in `ContentView.swift`, `AppState.swift`, `Theme.swift`.
Separate bundle ids mean both can be installed on the same device without
colliding.

## Finger or pointer

Every game he plays by moving something was written for a finger on glass. A
Mac has no finger: a drag there means holding the button down for the whole
movement, which is awkward with a mouse and close to impossible on a trackpad,
where the pointer runs out of trackpad and the button releases mid-stroke. The
old `TracePlayer.lift()` read that forced release as a mistake and told him
"keep your finger down all the way to the end", so the hardware failed and the
app blamed him.

`Pointer.isMac` (`Pointer.swift`, `ProcessInfo.processInfo.isMacCatalystApp`)
is the single switch. On a Mac:

| Game | Touch | Mac |
|---|---|---|
| `TracePlayer` | Finger down, follow the dots, lift at the end. | The stroke follows the pointer with **no button held**. Drifting off the path pauses and keeps his progress; releasing is not a mistake. |
| `SortPlayer` | Drag the thing into a pen. | Click the thing to pick it up, click the pen to put it down. |
| `SentencePlayer` | Drag the word into the gap. | Click the word, click the gap. |
| `ActOutPlayer` | Drag the animal to the pond or the gate. | Click the animal, click the pond or the gate. The carried animal has one legal destination; a click on the wrong zone does nothing rather than counting as a miss. |
| `AdditionGame` chips | Drag the group down into the pen. | Click the group. |

Two rules held onto deliberately:

- **No new shortcut.** He still has to carry the thing to the right place, so
  being shown the answer after two misses still saves him nothing. This is the
  property that made the sort and sentence conversions work in the first place.
- **Forgiveness is Mac-only.** A finger cannot leave the glass by accident, so
  touch keeps the stricter rules. Only the pointer gets the pause-and-resume
  behaviour.

Anything new that asks him to move something needs a pointer path too, or it is
broken on his laptop.

## Build and deploy

Requires Xcode on a Mac. Do not try to build from the Cowork container.

Everything goes through `tools/run.sh`. Double-clicking **Build LearnTube.app**
in the repo root runs the default. Output lands in `build/run.log` and
`build/xcodebuild.log` so a Cowork session can read what happened.

| Mode | What it does |
|---|---|
| (default) | Kid build to Gabriel's phones/iPads, grown-up build to the parents' phones and this Mac, and the Mac builds refreshed in `dist/` for Gabriel's and Paige's laptops. |
| `check` | Compiles both builds, installs nothing. |
| `devices` | Lists what is reachable, phones and Macs, and which build each gets. |
| `mac` | Grown-up build into `/Applications` on this Mac. |
| `kid "Name"` / `admin "Name"` | One device by name or UDID. |
| `dist` / `macs` | Mac Catalyst builds into `dist/`, Developer ID signed and notarized. |
| `all` | Everything. |

### The three Macs

devicectl cannot see Macs at all, so they are handled separately:

| Mac | Build | How it lands |
|---|---|---|
| This Mac (the build Mac) | Grown-up | `ditto` straight into `/Applications`. |
| Gabriel's laptop | Kid | `dist/LearnTube.app` on the NAS, picked up by the auto-updater on his Mac (or `dist/Install LearnTube.command` by hand, or a direct ssh push). |
| Paige's Mac | Grown-up | `dist/LearnTube Parent.app`, then `dist/Install LearnTube Parent.command`. |

**The same double-click works on every Mac.** `tools/run.sh` checks for
`/Applications/Xcode.app` first. If it is missing, this is not the build Mac, so
instead of compiling it installs the newest app staged in `dist/` (kid app,
unless the computer name matches `ADMIN_DEVICES`, which gets the parent
dashboard), strips quarantine, turns auto-update on, and opens it. Nothing
touches the pbxproj on a Mac that cannot build. So double-clicking **Build
LearnTube.app** on Gabriel's laptop installs LearnTube there; on the Xcode Mac it
builds and deploys as always.

**Gabriel's Mac auto-updates.** `dist/Enable Auto Update.command`, double-clicked
once on his laptop, copies `tools/mac_updater.sh` to
`~/Library/Application Support/LearnTube/update.sh` and installs the LaunchAgent
`com.turley.learntube.update` (every 30 minutes). The updater compares
`CFBundleVersion` on the NAS copy with the installed one and swaps it in only
when LearnTube is closed and the NAS is mounted. Its log is
`~/Library/Logs/LearnTube-update.log`. The NAS path it watches is recorded in
`updater.conf` at enable time, so re-run the enabler if the share ever remounts
somewhere else.

Set `GABRIEL_MAC_SSH=user@host` at the top of `tools/run.sh` (Remote Login on,
ssh key in place) and every `dist` run also pushes straight to the laptop via
`tools/mac_install_remote.sh`. An asleep laptop is not an error: the build just
waits in `dist/`.

`STAGE_MACS_BY_DEFAULT=0` in `tools/run.sh` goes back to the old behaviour where
only `dist` and `all` refresh the Mac builds. The default run skips notarization
to stay quick; `run.sh dist` notarizes.

Target: iOS 16.0, Mac Catalyst. Swift 5.0. Automatic signing, team `2286RHQ434`.
No Swift Package or CocoaPods dependencies at all, and it should stay that way.

**Always clean-build.** Every script does `rm -rf` on its DerivedData first.
The source lives on an SMB share and the network timestamps confuse Xcode's
incremental builds, which silently reuses stale code. If a change does not seem
to take effect, this is why. DerivedData goes to `/tmp/lt_*`, never onto the
share.

Build numbers surface in the app's top bar as `v1.0 · <build>`, which is how you
confirm the right build actually landed on a device.

**Gabriel's iPad cannot be deployed to by script.** It is an iPad6,11 on iOS
16.7.16 (UDID `a83e7d4e1b9252ad7c5ebf53faeef5aee3280dc6`). Every deploy script
installs with `xcrun devicectl`, which is CoreDevice and only supports iOS 17
and later, so that iPad is invisible to it regardless of cable or Wi-Fi. Install
to it from Xcode instead: pick it as the run destination and press Cmd-R. Cmd-B
compiles only and installs nothing, so "Build Succeeded" against that
destination is not evidence anything reached the device.

When a device seems unreachable, `xcrun xctrace list devices` is the honest
view: it lists every device on every iOS version. `xcrun devicectl list devices`
sees only iOS 17+, and will happily show a nameless "unavailable" record that is
a dead pairing rather than a real device. Chasing that ghost wastes time.

## State and sync

- `SavedState` in `AppState.swift` is the whole persisted model. UserDefaults,
  key `LearnTube.SavedState.v1`. Bump the key if you break the shape.
- `FamilySync.swift` mirrors each device's progress through the iCloud
  key-value store. Entitlement: `com.apple.developer.ubiquity-kvstore-identifier`.
  Same Apple ID means every device sees the same family view.
- Economy: `minutesPerConcept` (default 20) banks into `earnedMinutes`.
  `maxPlaysPerDay` (default 3) caps repeat farming of one lesson.
  `sessionEndsAt` runs the active YouTube countdown.
- `ProgressSnapshot` is the synced payload. Newer fields are Optional on
  purpose so snapshots written by an older build still decode. Keep them
  Optional when adding more.
- `DeviceIdentity` in `FamilySync.swift` keeps the per-install `deviceID` in the
  Keychain (service `com.turley.LearnTube.deviceID`), not UserDefaults.
  Reinstalling used to wipe the id and spawn a phantom device in the family
  view. Do not move it back.
- `parentPIN` gates the grown-up areas on shared devices.
- Struggle signals (`wrongCounts`, `recentWrong`, `misses`) are day-bucketed on
  purpose, so an old struggle ages out and re-engagement changes the flag rather
  than a permanent red mark.

## Curriculum

`Curriculum.swift` holds the `Skill` model: stable id (`K-M1`), grade, subject,
title, CA standard code, an activity hook written as a video description, a
`parentTip`, and the interactive `Lesson`.

Grades run -2 (Warm-Ups), -1 (TK), 0 (Kindergarten), 1 upward. Content lives in
`Curriculum.swift`, `CurriculumK.swift`, `Curriculum1.swift`, `FamilyLesson.swift`.

`Curriculum.liveStops` is the gate. Only ids listed there appear on Home, in that
order. Authoring a skill does not ship it; adding its id to `liveStops` does.
Pulled concepts stay in the source with a comment explaining why (see `TK-M5`,
patterns, pulled because he taps the last item every time).

### Number games

Number-pad math comes in two shapes:

- `.numberPad([NumberProblem])`: fixed problems, shuffled per play. Each
  `NumberProblem` carries a `NumberVisual` (`draw:`); the old `visual: [String]`
  init still works and becomes `.tokens`. Every problem should draw something.
- `.numberGen(NumberGame, rounds:, boost:)`: `ProblemGen.swift` makes fresh
  problems each play, reading `GameDifficulty.level` (1...3), so a game climbs
  as he masters it. `boost` opens a game higher on the ladder (First Grade
  "add within 20" should not start at sums to 8). All the live count/add/
  take-away/teen/doubles/skip-count games use this since 2026-09-06.

`NumberVisual` (in `Lesson.swift`, drawn by `NumberVisualView.swift`):
`.takeAway` draws the WHOLE starting group and fades and crosses off the ones
that leave after a beat. Never draw only the leftover group for a subtraction:
that shipped for months and turned every take-away game into a counting game.
`.tens` and `.frame` are real 5x2 ten-frames; `.compare` lines two groups up in
columns; `.groups` is pairs/hands for skip counting.

`AppState.levelableSkills` is every `.numberGen` skill. A levelable game only
retires after mastery at all three levels.

### Quizzes

`Question(prompt, correct:, wrong:, jokes:)`. Put deliberately funny wrong
answers ("Blame the dog") in `jokes:`; tapping one gets a laugh line and is not
recorded as a miss, because he picks those on purpose and a joke is not a
struggle signal.

### Feed order

`HomeFeedView.available` sorts the whole feed by recent struggle (easiest
first), not within grade bands, and weaves a never-opened game (NEW badge) in
after every two familiar ones. Sorting grade-first used to keep two Warm-Ups he
kept missing at the top for weeks while 39 unopened First Grade games sat below
everything.

Run the guardrail after touching any curriculum file:

    python3 tools/check_qa.py

It fails if a correct answer is visibly contained in its own prompt (a kid
pattern-matches instead of reading), or if a take-away `NumberProblem` draws
only its answer. Three pulled games (`G1-M10`, `TK-M5`) trip the first rule
and always have; ignore those unless they come back to `liveStops`.

## Windows / web client

`win/export_curriculum.py` parses the Swift sources and emits platform-neutral
`curriculum.json` so other clients reuse identical content. `win/ui/` is an
HTML/CSS/JS client on top of it. Note `curriculum.json` currently exists twice,
in `win/` and `win/ui/`. Re-run the exporter rather than hand-editing either.

## Git

- Remote: `https://github.com/growleryforge/LearnTube.git`, branch `main`.
- Committed as Doosy <gina.turley@protonmail.com>.
- `.gitignore` covers `.DS_Store`, `._*` (the share generates AppleDouble files
  constantly), `build/`, `DerivedData/`, `xcuserdata/`, `dist/`, `*.ipa`, `*.app`.

## Known rough edges

- `AdditionGame.swift` is ~7000 lines in one file and is the obvious candidate
  for splitting.
- `_today.png` and `Screenshot 2026-07-02 at 5.47.01 PM.png` sit tracked in the
  repo root with no clear owner.
- The project lives on the NAS. If the SMB mount drops mid-session, tooling
  loses the folder. Cloning to local disk and treating the NAS as a push target
  would be more durable.

## House context

Part of Growlery Forge, the software company meant for Gabriel to take over
someday. Favor choices that stay teachable and readable over clever ones: plain
SwiftUI, no dependencies, comments that explain why rather than what.
