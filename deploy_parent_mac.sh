#!/bin/bash
#
# deploy_parent_mac.sh
# Build the LearnTube PARENT dashboard as a portable app and drop it on the NAS
# so another parent's Mac (e.g. Paige's) can install it. Ad-hoc signed so it
# runs on any Mac without a developer certificate.
#
# After it finishes: on the other parent's Mac, open this project's `dist`
# folder on the NAS and double-click "Install LearnTube Parent.command".
#
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==> Building LearnTube parent dashboard (portable)..."
DD=/tmp/lt_parent_deploy
rm -rf "$DD"     # always clean: network-share timestamps confuse incremental builds
xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DD" -allowProvisioningUpdates \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT' \
  PRODUCT_NAME='LearnTubeAdmin' \
  PRODUCT_BUNDLE_IDENTIFIER='com.turley.LearnTubeAdmin' \
  INFOPLIST_KEY_CFBundleDisplayName='LearnTube' \
  ASSETCATALOG_COMPILER_APPICON_NAME='AppIconAdmin' \
  CODE_SIGN_ENTITLEMENTS='' \
  build >/tmp/lt_parent_deploy.log 2>&1

APP="$DD/Build/Products/Debug-maccatalyst/LearnTubeAdmin.app"
if [ ! -d "$APP" ]; then echo "!! BUILD FAILED — see /tmp/lt_parent_deploy.log"; exit 1; fi

# Portable ad-hoc signature so it runs on any Mac (not just registered dev Macs).
rm -f "$APP/Contents/embedded.provisionprofile"
codesign --force --deep --sign - "$APP" || echo "   (warning: ad-hoc re-sign failed)"

DIST="$PROJECT_DIR/dist"
mkdir -p "$DIST"
rm -rf "$DIST/LearnTube Parent.app"
ditto "$APP" "$DIST/LearnTube Parent.app"

VER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$DIST/LearnTube Parent.app/Contents/Info.plist" 2>/dev/null)
echo "==> Done. Parent dashboard (build ${VER:-?}) dropped to: $DIST/LearnTube Parent.app"
echo "==> On the other parent's Mac: open the NAS 'dist' folder and double-click 'Install LearnTube Parent.command'."
