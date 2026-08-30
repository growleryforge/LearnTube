#!/bin/bash
#
# deploy_to_phones.sh
# Build the latest LearnTube and install it on every connected iPhone/iPad.
# Run this before testing on a device (and before Claude drives the simulator),
# so the phones always have the newest version.
#
# Usage:  ./deploy_to_phones.sh
#
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Auto-increment the build number so the app's on-screen version tells us
# exactly which build is installed on each device.
PBX="LearnTube.xcodeproj/project.pbxproj"
CUR=$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PBX" | grep -oE '[0-9]+' | head -1)
NEXT=$(( ${CUR:-0} + 1 ))
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEXT;/g" "$PBX"
echo "==> Build number: $NEXT"

echo "==> Building LearnTube for device (this takes a minute)..."
xcodebuild -project LearnTube.xcodeproj \
           -scheme LearnTube \
           -destination 'generic/platform=iOS' \
           -allowProvisioningUpdates \
           -quiet \
           build

APP=$(find ~/Library/Developer/Xcode/DerivedData/LearnTube-*/Build/Products/Debug-iphoneos \
        -maxdepth 1 -name "LearnTube.app" 2>/dev/null | head -1)

if [ -z "$APP" ]; then
  echo "!! Could not find the built LearnTube.app. Build may have failed."
  exit 1
fi
echo "==> Built: $APP"

# Find every paired device (connected or just paired) and try each one.
LIST=$(xcrun devicectl list devices 2>/dev/null)
IDS=$(echo "$LIST" \
        | grep -iE "connected|available" \
        | grep -oiE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}')

if [ -z "$IDS" ]; then
  echo "!! No paired devices found. Plug in a phone (unlocked) and try again."
  exit 1
fi

OK=0
for ID in $IDS; do
  NAME=$(echo "$LIST" | grep -i "$ID" | awk '{print $1, $2}')
  # The kid GAMES app belongs only on Gabriel's devices + the shared iPad.
  # Parent phones (GT Command, Mrs. Turley) get the DASHBOARD instead
  # (deploy_admin_iphone.sh), so never install the games app there.
  SKIP="GT Command|Mrs. Turley|Mrs Turley${LT_EXCLUDE:+|$LT_EXCLUDE}"
  if echo "$NAME" | grep -qiE "$SKIP"; then
    echo "==> Skipping ${NAME} (dashboard-only device)."
    continue
  fi
  echo "==> Installing to ${NAME:-$ID} ..."
  if xcrun devicectl device install app --device "$ID" "$APP" >/dev/null 2>&1; then
    echo "    done."
    OK=$((OK+1))
  else
    echo "    SKIPPED: ${NAME:-$ID} is not reachable (asleep, locked, or off Wi-Fi)."
  fi
done

if [ "$OK" -gt 0 ]; then
  echo "==> Pushed the latest LearnTube to $OK phone(s). 🎉"
else
  echo "!! No phone was reachable. Unlock the phone and make sure it's on the same Wi-Fi (or plugged in)."
  exit 1
fi
