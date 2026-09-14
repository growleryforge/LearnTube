#!/bin/bash
# Try the install to Gabriel's old iPad every way this Mac offers, and write
# down exactly what each one says.
cd "$(dirname "$0")"
OUT="build/ipad_diag.log"
UDID=a83e7d4e1b9252ad7c5ebf53faeef5aee3280dc6
APP=/tmp/lt_kid_dd/Build/Products/Debug-iphoneos/LearnTube.app
{
  echo "=== date ==="; date
  echo; echo "=== kid app present? ==="; ls -d "$APP" 2>&1
  /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Info.plist" 2>&1
  /usr/libexec/PlistBuddy -c "Print MinimumOSVersion" "$APP/Info.plist" 2>&1

  echo; echo "=== devicectl install by xctrace udid ==="
  xcrun devicectl device install app --device "$UDID" "$APP" 2>&1 | tail -20

  echo; echo "=== devicectl info on that udid ==="
  xcrun devicectl device info details --device "$UDID" 2>&1 | tail -20

  echo; echo "=== what iOS versions can this Xcode run on? ==="
  ls "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport" 2>&1
  ls ~/Library/Developer/Xcode/iOS\ DeviceSupport 2>&1 | tail -20

  echo; echo "=== ios-deploy available? ==="
  which ios-deploy 2>&1
} > "$OUT" 2>&1
echo "done"
