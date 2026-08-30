#!/bin/bash
#
# deploy_admin_mac.sh
# Build the grown-up "LearnTube Admin" panel and install it on THIS Mac
# (the parent's Mac). It's a separate app from the kid build — it opens to
# Family, Progress, and Grown-Ups, and shares the same synced family data.
#
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==> Building LearnTube Admin (grown-up panel)..."
DD=/tmp/lt_admin_dd
# Always clean: the project lives on a network share whose timestamps confuse
# incremental builds, which silently reused stale code. A clean build is a bit
# slower but guarantees the source changes actually make it into the app.
rm -rf "$DD"
xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DD" -allowProvisioningUpdates \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT' \
  PRODUCT_NAME='LearnTubeAdmin' \
  PRODUCT_BUNDLE_IDENTIFIER='com.turley.LearnTubeAdmin' \
  INFOPLIST_KEY_CFBundleDisplayName='LearnTube' \
  ASSETCATALOG_COMPILER_APPICON_NAME='AppIconAdmin' \
  CODE_SIGN_ENTITLEMENTS='' \
  build >/tmp/lt_admin_build.log 2>&1

APP="$DD/Build/Products/Debug-maccatalyst/LearnTubeAdmin.app"
if [ ! -d "$APP" ]; then echo "!! BUILD FAILED — see /tmp/lt_admin_build.log"; exit 1; fi

# Sign with this Mac's Apple Development identity so Gatekeeper trusts it and
# it launches from a Finder/Dock double-click (ad-hoc signatures get blocked
# on recent macOS). Falls back to ad-hoc only if no Development cert is found.
rm -f "$APP/Contents/embedded.provisionprofile"
DEVID=$(security find-identity -v -p codesigning 2>/dev/null | grep -o 'Apple Development[^"]*' | head -1)
if [ -n "$DEVID" ]; then
  echo "==> Signing with: $DEVID"
  codesign --force --deep --sign "$DEVID" "$APP" || echo "   (warning: dev re-sign failed)"
else
  echo "==> No Development cert found; using ad-hoc signature."
  codesign --force --deep --sign - "$APP" || echo "   (warning: ad-hoc re-sign failed)"
fi

osascript -e 'quit app "LearnTube Admin"' 2>/dev/null
pkill -9 -f LearnTubeAdmin 2>/dev/null || true
# Wait until it's really gone, or the running copy locks the bundle and the
# replace silently fails (leaving the old version installed).
for i in 1 2 3 4 5; do pgrep -f LearnTubeAdmin >/dev/null || break; sleep 1; done
rm -rf "/Applications/LearnTubeAdmin.app"
ditto "$APP" "/Applications/LearnTubeAdmin.app"
INSTVER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "/Applications/LearnTubeAdmin.app/Contents/Info.plist" 2>/dev/null)
echo "==> Installed version: ${INSTVER:-unknown}"
xattr -dr com.apple.quarantine "/Applications/LearnTubeAdmin.app" 2>/dev/null || true
open "/Applications/LearnTubeAdmin.app" || true
echo "==> Installed 'LearnTube Admin' to /Applications and launched it."
