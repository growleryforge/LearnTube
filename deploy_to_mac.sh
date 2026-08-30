#!/bin/bash
#
# deploy_to_mac.sh
# Build the LearnTube Mac app and drop it on the NAS so Gabriel's Mac can
# install the update. Run this on the Mac that has Xcode.
#
# After it finishes: on Gabriel's Mac, open this project's `dist` folder on the
# NAS and double-click "Install LearnTube.command".
#
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Bump the build number so the on-screen version shows which build is live.
PBX="LearnTube.xcodeproj/project.pbxproj"
CUR=$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PBX" | grep -oE '[0-9]+' | head -1)
NEXT=$(( ${CUR:-0} + 1 ))
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*/CURRENT_PROJECT_VERSION = $NEXT/g" "$PBX"
echo "==> Building LearnTube Mac app (build $NEXT)..."

# Build with local DerivedData (fast, avoids SMB build churn). Always clean:
# the source is on a network share whose timestamps confuse incremental builds.
DD=/tmp/lt_mac_deploy
rm -rf "$DD"
xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DD" -allowProvisioningUpdates build >/tmp/lt_mac_deploy.log 2>&1

APP="$DD/Build/Products/Debug-maccatalyst/LearnTube.app"
if [ ! -d "$APP" ]; then echo "BUILD FAILED — see /tmp/lt_mac_deploy.log"; exit 1; fi

# Sign for PERMANENT install: Developer ID + hardened runtime, then notarize.
# (The old ad-hoc signature is why the app kept disappearing — macOS stops
# trusting ad-hoc/development-signed apps. Developer ID never expires.)
DEVID="Developer ID Application: GINA LOUISE TURLEY (2286RHQ434)"
rm -f "$APP/Contents/embedded.provisionprofile"

# Minimal entitlements: this Mac build syncs through Firebase, not iCloud, so
# drop the iCloud KVS entitlement (which would require a provisioning profile).
ENT=/tmp/lt_devid.entitlements
cat > "$ENT" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict/></plist>
PLIST

echo "==> Signing with Developer ID (permanent)..."
codesign --force --deep --options runtime --timestamp \
         --entitlements "$ENT" --sign "$DEVID" "$APP"
codesign --verify --strict "$APP" && echo "    signature OK"

# Notarize so macOS trusts it with no warning, using the ASC API key on this Mac.
ZIP=/tmp/LearnTube-notarize.zip
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
echo "==> Sending to Apple to notarize (usually 1-3 minutes)..."
if xcrun notarytool submit "$ZIP" \
     --key "$HOME/.appstoreconnect/private_keys/AuthKey_93Z3AGX448.p8" \
     --key-id 93Z3AGX448 \
     --issuer d06b6275-9506-447d-bbe3-065049d3ade5 \
     --wait; then
  xcrun stapler staple "$APP" && echo "    notarized + stapled ✅"
else
  echo "    (warning: notarization failed — app is still Developer ID signed,"
  echo "     but macOS may show a one-time 'unidentified developer' prompt)"
fi

# Copy the portable app out with ditto (preserves the bundle + signature).
DIST="$PROJECT_DIR/dist"
mkdir -p "$DIST"
rm -rf "$DIST/LearnTube.app"
ditto "$APP" "$DIST/LearnTube.app"

echo "==> Done. Build $NEXT dropped to: $DIST/LearnTube.app"
echo "==> On Gabriel's Mac: open the NAS 'dist' folder and double-click 'Install LearnTube.command'."
