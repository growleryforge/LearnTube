#!/bin/bash
#
# Update Parent Admin.command
# ONE-CLICK: rebuild the LearnTube parent/admin dashboard from the current
# source and (re)install it on THIS Mac, then launch it. Just double-click me.
#
# It's the grown-up panel (Today with answer-level depth, Progress, Insights,
# Family, Grown-Ups) — a separate app from Gabriel's kid build, sharing the
# same synced family data. Each run stamps a fresh build number so you can
# confirm the update landed (shown in the top bar, e.g. "v1.0 · 2608111230").
#
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# A fresh, always-increasing build number (YYMMDDHHMM) so the installed app
# visibly changes every update. Stamped at build time only — the project file
# and the kid build numbering are left untouched.
STAMP=$(date +%y%m%d%H%M)

echo "==> Building LearnTube Admin  (build $STAMP) ..."
DD=/tmp/lt_admin_dd
# Clean build every time: the project lives on a network share whose timestamps
# confuse incremental builds and can silently ship stale code.
rm -rf "$DD"
xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DD" -allowProvisioningUpdates \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT' \
  CURRENT_PROJECT_VERSION="$STAMP" \
  PRODUCT_NAME='LearnTubeAdmin' \
  PRODUCT_BUNDLE_IDENTIFIER='com.turley.LearnTubeAdmin' \
  INFOPLIST_KEY_CFBundleDisplayName='LearnTube' \
  ASSETCATALOG_COMPILER_APPICON_NAME='AppIconAdmin' \
  CODE_SIGN_ENTITLEMENTS='' \
  build >/tmp/lt_admin_build.log 2>&1

APP="$DD/Build/Products/Debug-maccatalyst/LearnTubeAdmin.app"
if [ ! -d "$APP" ]; then
  echo "!! BUILD FAILED — last lines of /tmp/lt_admin_build.log:"
  tail -30 /tmp/lt_admin_build.log
  echo
  read -n1 -r -p "Press any key to close..."
  exit 1
fi

# Sign with this Mac's Apple Development identity so Gatekeeper launches it from
# a double-click. Falls back to ad-hoc if no Development cert is installed.
rm -f "$APP/Contents/embedded.provisionprofile"
DEVID=$(security find-identity -v -p codesigning 2>/dev/null | grep -o 'Apple Development[^"]*' | head -1)
if [ -n "$DEVID" ]; then
  echo "==> Signing with: $DEVID"
  codesign --force --deep --sign "$DEVID" "$APP" || echo "   (warning: dev re-sign failed)"
else
  echo "==> No Development cert found; using ad-hoc signature."
  codesign --force --deep --sign - "$APP" || echo "   (warning: ad-hoc re-sign failed)"
fi

# Close the running copy first, or it locks the bundle and the replace fails.
osascript -e 'quit app "LearnTube"' 2>/dev/null || true
pkill -9 -f LearnTubeAdmin 2>/dev/null || true
for i in 1 2 3 4 5; do pgrep -f LearnTubeAdmin >/dev/null || break; sleep 1; done

rm -rf "/Applications/LearnTubeAdmin.app"
ditto "$APP" "/Applications/LearnTubeAdmin.app"
xattr -dr com.apple.quarantine "/Applications/LearnTubeAdmin.app" 2>/dev/null || true
INSTVER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "/Applications/LearnTubeAdmin.app/Contents/Info.plist" 2>/dev/null)
open "/Applications/LearnTubeAdmin.app" || true

echo
echo "==> Installed & launched LearnTube Admin — build ${INSTVER:-$STAMP}."
echo "    Check the top bar shows · ${INSTVER:-$STAMP} to confirm this update."
echo
read -n1 -r -p "Done. Press any key to close..."
