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

## Build and deploy

Requires Xcode on a Mac. Do not try to build from the Cowork container.

| Script | What it does |
|---|---|
| `deploy_to_phones.sh` | Kid build to every connected iPhone/iPad. Bumps `CURRENT_PROJECT_VERSION` in the pbxproj. |
| `deploy_to_mac.sh` | Kid build as Mac Catalyst, staged to `dist/` on the NAS for Gabriel's Mac. |
| `deploy_admin_mac.sh` | Grown-up build installed on this Mac. |
| `deploy_admin_iphone.sh` | Grown-up build to a parent's iPhone. |
| `deploy_parent_mac.sh` | Grown-up build, ad-hoc signed and portable, staged to `dist/` for Paige's Mac. |
| `Update Parent Admin.command` | One-click version of the above for this Mac. Stamps a `YYMMDDHHMM` build number. |

Target: iOS 16.0, Mac Catalyst. Swift 5.0. Automatic signing, team `2286RHQ434`.
No Swift Package or CocoaPods dependencies at all, and it should stay that way.

**Always clean-build.** Every script does `rm -rf` on its DerivedData first.
The source lives on an SMB share and the network timestamps confuse Xcode's
incremental builds, which silently reuses stale code. If a change does not seem
to take effect, this is why. DerivedData goes to `/tmp/lt_*`, never onto the
share.

Build numbers surface in the app's top bar as `v1.0 · <build>`, which is how you
confirm the right build actually landed on a device.

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

Run the guardrail after touching any curriculum file:

    python3 tools/check_qa.py

It fails if a correct answer is visibly contained in its own prompt, which would
let a kid pattern-match instead of read.

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
