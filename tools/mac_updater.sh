#!/bin/bash
#
# LearnTube auto-updater. Lives on Gabriel's Mac at
# ~/Library/Application Support/LearnTube/update.sh and is run every 30
# minutes by the LaunchAgent that dist/"Enable Auto Update.command" installs.
#
# It compares the build number of the app staged on the NAS with the one
# installed here, and quietly swaps in the newer one when LearnTube is closed.
# Nothing happens if the NAS is not mounted or the app is open.
#
set -u
SUP="$HOME/Library/Application Support/LearnTube"
CONF="$SUP/updater.conf"
LOG="$HOME/Library/Logs/LearnTube-update.log"
mkdir -p "$(dirname "$LOG")"
say() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $*" >> "$LOG"; }

[ -f "$CONF" ] || { say "no updater.conf; run Enable Auto Update.command again"; exit 0; }
# shellcheck disable=SC1090
. "$CONF"

SRC="${DIST_DIR:-}/LearnTube.app"
if [ ! -d "$SRC" ]; then
    say "NAS not mounted at ${DIST_DIR:-unset}; skipping"
    exit 0
fi

ver() { defaults read "$1/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo 0; }
NEW=$(ver "$SRC")

TARGET=""
CUR=0
for dest in "/Applications/LearnTube.app" "$HOME/Applications/LearnTube.app"; do
    if [ -d "$dest" ]; then TARGET="$dest"; CUR=$(ver "$dest"); break; fi
done
[ -n "$TARGET" ] || TARGET="/Applications/LearnTube.app"

if [ "$NEW" = "$CUR" ]; then
    exit 0
fi

if pgrep -f "LearnTube.app/Contents/MacOS" >/dev/null 2>&1; then
    say "build $NEW is waiting but LearnTube is open (on $CUR); trying again later"
    exit 0
fi

say "updating build $CUR -> $NEW from $DIST_DIR"
TMP=$(mktemp -d)
if ! ditto "$SRC" "$TMP/LearnTube.app" 2>>"$LOG"; then
    say "copy from the NAS failed"
    rm -rf "$TMP"; exit 0
fi
rm -rf "$TARGET" 2>/dev/null
if ditto "$TMP/LearnTube.app" "$TARGET" 2>>"$LOG"; then
    xattr -dr com.apple.quarantine "$TARGET" 2>/dev/null
    say "installed build $NEW to $TARGET"
else
    mkdir -p "$HOME/Applications"
    if ditto "$TMP/LearnTube.app" "$HOME/Applications/LearnTube.app" 2>>"$LOG"; then
        xattr -dr com.apple.quarantine "$HOME/Applications/LearnTube.app" 2>/dev/null
        say "installed build $NEW to ~/Applications (no write access to /Applications)"
    else
        say "install failed"
    fi
fi
rm -rf "$TMP"
