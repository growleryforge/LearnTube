#!/bin/bash
#
# Runs ON Gabriel's Mac. tools/run.sh rsyncs the new kid app to
# /tmp/LearnTube-push and then pipes this script in over ssh.
#
set -u
SRC=/tmp/LearnTube-push/LearnTube.app
[ -d "$SRC" ] || { echo "nothing staged at $SRC"; exit 1; }

osascript -e 'quit app "LearnTube"' 2>/dev/null
pkill -9 -f "LearnTube.app/Contents/MacOS" 2>/dev/null
sleep 2

TARGET=""
if rm -rf "/Applications/LearnTube.app" 2>/dev/null && ditto "$SRC" "/Applications/LearnTube.app" 2>/dev/null; then
    TARGET="/Applications/LearnTube.app"
else
    mkdir -p "$HOME/Applications"
    rm -rf "$HOME/Applications/LearnTube.app" 2>/dev/null
    ditto "$SRC" "$HOME/Applications/LearnTube.app" 2>/dev/null && TARGET="$HOME/Applications/LearnTube.app"
fi
rm -rf /tmp/LearnTube-push

[ -n "$TARGET" ] || { echo "install failed"; exit 1; }
xattr -dr com.apple.quarantine "$TARGET" 2>/dev/null
echo "installed to $TARGET"
