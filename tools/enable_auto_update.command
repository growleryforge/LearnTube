#!/bin/bash
#
# Double-click this ONCE on Gabriel's Mac (run.sh also calls it for you).
#
# After that his laptop checks the NAS every half hour and installs any newer
# LearnTube on its own, so it stays on the same build as the iPads. Nobody has
# to double-click anything again.
#
# To turn it off:  launchctl unload ~/Library/LaunchAgents/com.turley.learntube.update.plist
# What it did:     ~/Library/Logs/LearnTube-update.log
#
DIR="$(cd "$(dirname "$0")" && pwd)"
SUP="$HOME/Library/Application Support/LearnTube"
AGENTS="$HOME/Library/LaunchAgents"
AGENT="$AGENTS/com.turley.learntube.update.plist"

# Where is dist/? This file lives in both dist/ and tools/.
DIST=""
for cand in "$DIR" "$DIR/../dist" "$DIR/dist"; do
    if [ -d "$cand/LearnTube.app" ]; then DIST="$(cd "$cand" && pwd)"; break; fi
done
if [ -z "$DIST" ]; then
    echo "Couldn't find dist/LearnTube.app. Make sure the NAS is connected, then try again."
    read -n 1 -s -r -p "Press any key to close."
    exit 1
fi

UPDATER=""
for cand in "$DIR/mac_updater.sh" "$DIR/../tools/mac_updater.sh" "$DIST/../tools/mac_updater.sh"; do
    if [ -f "$cand" ]; then UPDATER="$cand"; break; fi
done
if [ -z "$UPDATER" ]; then
    echo "Couldn't find tools/mac_updater.sh. Make sure the NAS is connected, then try again."
    read -n 1 -s -r -p "Press any key to close."
    exit 1
fi

mkdir -p "$SUP" "$AGENTS" "$HOME/Library/Logs"
cp "$UPDATER" "$SUP/update.sh"
chmod +x "$SUP/update.sh"
printf 'DIST_DIR="%s"\n' "$DIST" > "$SUP/updater.conf"

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.turley.learntube.update</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SUP/update.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>1800</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/LearnTube-update.err</string>
</dict>
</plist>
PLIST

launchctl unload "$AGENT" 2>/dev/null
launchctl load "$AGENT" 2>/dev/null

echo "Auto-update is on for this Mac."
echo "It watches: $DIST"
"$SUP/update.sh"
echo "Done. LearnTube will keep itself up to date from now on."
