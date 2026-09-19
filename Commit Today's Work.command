#!/bin/bash
# Double-click: commit today's LearnTube work to the local git repo on the NAS.
# Pushing to GitHub is separate ("Push to GitHub.command") because it needs
# credentials typed into a real Terminal.
cd "$(dirname "$0")" || exit 1
# git on an SMB share leaves lock files behind when a previous run was cut off.
rm -f .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock 2>/dev/null
git add -A
git commit -F - <<'MSG'
Sorting climbs, First Grade arrives, and three real bugs

Sorting is a ladder now: 3 things to carry, then 4, then 6. Mapped onto
the three finishes mastery already took, so no game that was finished
becomes unfinished and no Finish Line barn goes dark. Covers the 60 live
sort games, the engine most of the app now runs on. The "N OF 3" cheer
and pips already on screen line up with the step.

Nine First Grade sort games go live: G1-R1, G1-M6, G1-S1, G1-W2, G1-M10,
G1-R6, G1-S3, G1-L3, G1-M8. Until now the only First Grade he ever met
was the FR number ladders, 27 of which he has never once finished, so
the grade read as a wall of math. G1-R2 and G1-R7 held back: they
duplicate FR-R5 and FR-R4, which are already live.

Fixes:

- SavedState decode. bugWrongCapV1 and guessedResetV1 were non-optional
  with defaults, and Swift's synthesized decoder does not fall back to a
  default value for a missing key. Upgrading from any build predating
  them would have thrown, hit the `try?` blank-state fallback, and wiped
  on-device progress.

- Day rollover. refreshForToday now also runs on scenePhase .active. An
  iPad that keeps LearnTube resident overnight never re-ran init or
  onAppear, so the day never rolled: the Today card went blank and
  completionsToday still held yesterday's counts, silently spending his
  three plays per game.

- Today card. Counts from recentPlaysMap[id][todayKey] instead of
  filtering devices on dayKey, so one stale device can no longer zero
  every number on the card while the family-level minutes pill stays
  right. A missed day now renders retroactively.

tools/run.sh: `prebuild` updates the grown-ups and holds the kid app
back; `push NAME` installs the staged kid app with no rebuild and no
version bump. Together they let an install land in a chosen moment
rather than whenever a build happens to finish.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01GYw4HU8CGorKnK9mAUkyPL
MSG
echo
echo "---- status ----"
git log --oneline -3
git status --short | head
git rev-list --count origin/main..HEAD 2>/dev/null | sed 's/^/commits ahead of origin: /'
echo; read -n1 -r -p "Done. Press any key to close..."
