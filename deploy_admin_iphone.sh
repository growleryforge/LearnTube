#!/bin/bash
#
# deploy_admin_iphone.sh
# Build the LearnTube parent DASHBOARD as an iOS app (the PARENT build) and
# install it on a grown-up's iPhone. Same dashboard as the Mac — Today, Games,
# Insights, Family, Progress, Grown-Ups — just on iOS. Separate bundle id and
# gold icon so it never collides with Gabriel's kid app (com.turley.LearnTube).
#
# Usage:  ./deploy_admin_iphone.sh              (installs to GT Command by default)
#         LT_DEVICE=<udid> ./deploy_admin_iphone.sh
#
set -e
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

DD=/tmp/lt_ios_admin_dd
rm -rf "$DD"     # clean build (network-share timestamps confuse incremental builds)
echo "==> Building LearnTube dashboard for iPhone..."
xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DD" -allowProvisioningUpdates \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT' \
  PRODUCT_NAME='LearnTubeAdmin' \
  PRODUCT_BUNDLE_IDENTIFIER='com.turley.LearnTubeAdmin' \
  INFOPLIST_KEY_CFBundleDisplayName='LearnTube' \
  ASSETCATALOG_COMPILER_APPICON_NAME='AppIconAdmin' \
  build >/tmp/lt_ios_admin.log 2>&1

APP="$DD/Build/Products/Debug-iphoneos/LearnTubeAdmin.app"
if [ ! -d "$APP" ]; then echo "!! BUILD FAILED - see /tmp/lt_ios_admin.log"; exit 1; fi
echo "==> Built version $(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Info.plist" 2>/dev/null)"

DEV="${LT_DEVICE:-20D8DEF8-08D8-5429-8924-73C05702759B}"   # GT Command (parent iPhone)
echo "==> Installing to device $DEV ..."
if xcrun devicectl device install app --device "$DEV" "$APP" >/dev/null 2>&1; then
  echo "==> Done - LearnTube dashboard installed on the iPhone."
else
  echo "!! Device not reachable. Unlock the iPhone, keep it on Wi-Fi, and re-run."
fi
