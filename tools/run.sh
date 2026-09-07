#!/bin/bash
#
# tools/run.sh — build LearnTube and put it on every device, one command.
#
#   bash tools/run.sh              kid build to Gabriel's devices, grown-up build
#                                  to the parents' phones and this Mac
#   bash tools/run.sh check        just compile both builds, install nothing
#   bash tools/run.sh devices      show what is reachable and which build it gets
#   bash tools/run.sh mac          grown-up build to /Applications on this Mac
#   bash tools/run.sh kid "Name"   kid build to one device by name (or UDID)
#   bash tools/run.sh admin "Name" grown-up build to one device by name (or UDID)
#   bash tools/run.sh dist         Catalyst builds for the other Macs into dist/
#   bash tools/run.sh all          everything above
#
# Double-clicking "Build LearnTube.app" (or .command) in the repo root runs the
# default in a Terminal window. Everything is also written to build/run.log
# and build/xcodebuild.log so a Cowork session can read what happened.
#
# Same shape as I Can Fly's and Obsession's run.sh. LearnTube-specific bits:
#   - the grown-up build is the same target with the PARENT flag, bundle id
#     com.turley.LearnTubeAdmin and the gold icon (see CLAUDE.md)
#   - every build is a clean build: the source lives on the NAS and SMB
#     timestamps make Xcode silently reuse stale code
#   - the build number is stamped YYMMDDHHMM at build time and shows in the
#     app's top bar as "v1.0 · <build>", so you can see which build landed
#   - Gabriel's iPad (iPad6,11, iOS 16.7) is invisible to devicectl, which
#     only speaks iOS 17+. It has to be installed from Xcode with Cmd-R.
#     This script says so when it sees the iPad in xctrace's list.

set -u
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

# ---- who gets which build ----------------------------------------------------
# Device names (as they appear in devicectl) that get the GROWN-UP dashboard.
# Everything else that is reachable gets the kid games app.
ADMIN_DEVICES=("GT Command Center" "GT Command" "Mrs. Turley" "Mrs Turley" "Paige")
# Devices to leave alone entirely (a name or a fragment). Apple Watches are
# always skipped.
IGNORE_DEVICES=("Watch")

# ---- logging -----------------------------------------------------------------
mkdir -p build
RUNLOG="$REPO/build/run.log"
XLOG="$REPO/build/xcodebuild.log"
: > "$RUNLOG"; : > "$XLOG"
log() { echo "$*" | tee -a "$RUNLOG"; }
die() { log "!! $*"; log "   (details: build/xcodebuild.log)"; exit 1; }

STAMP=$(date +%y%m%d%H%M)
MODE="${1:-default}"; TARGET="${2:-}"
log "LearnTube build $STAMP  ·  mode: $MODE  ·  $(date '+%a %b %d %H:%M')"
log "repo: $REPO"

# ---- builds ------------------------------------------------------------------
# All four products come from the one LearnTube scheme; the grown-up build is
# the same target compiled with PARENT. DerivedData stays in /tmp, never on the
# share, and is wiped before every build.
ADMIN_SETTINGS=(SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) PARENT'
                PRODUCT_NAME='LearnTubeAdmin'
                PRODUCT_BUNDLE_IDENTIFIER='com.turley.LearnTubeAdmin'
                INFOPLIST_KEY_CFBundleDisplayName='LearnTube'
                ASSETCATALOG_COMPILER_APPICON_NAME='AppIconAdmin')

# build <label> <derivedData> <destination> [extra xcodebuild settings...]
build() {
    local label="$1" dd="$2" dest="$3"; shift 3
    rm -rf "$dd"
    log "==> Building $label (clean) ..."
    echo "===== $label  $(date '+%H:%M:%S') =====" >> "$XLOG"
    if xcodebuild -project LearnTube.xcodeproj -scheme LearnTube \
         -destination "$dest" -derivedDataPath "$dd" -allowProvisioningUpdates \
         CURRENT_PROJECT_VERSION="$STAMP" "$@" build >> "$XLOG" 2>&1; then
        log "    built."
    else
        log "!! $label FAILED. First errors:"
        grep -E "error:|fatal error" "$XLOG" | grep -v "^warning" | head -12 | tee -a "$RUNLOG"
        return 1
    fi
}

KID_DD=/tmp/lt_kid_dd;        KID_APP="$KID_DD/Build/Products/Debug-iphoneos/LearnTube.app"
ADMIN_DD=/tmp/lt_admin_ios_dd; ADMIN_APP="$ADMIN_DD/Build/Products/Debug-iphoneos/LearnTubeAdmin.app"
MAC_DD=/tmp/lt_admin_dd;      MAC_APP="$MAC_DD/Build/Products/Debug-maccatalyst/LearnTubeAdmin.app"
KIDMAC_DD=/tmp/lt_mac_deploy; KIDMAC_APP="$KIDMAC_DD/Build/Products/Debug-maccatalyst/LearnTube.app"

build_kid_ios()   { build "kid app (iOS)" "$KID_DD" 'generic/platform=iOS'; }
build_admin_ios() { build "grown-up app (iOS)" "$ADMIN_DD" 'generic/platform=iOS' "${ADMIN_SETTINGS[@]}"; }
build_admin_mac() { build "grown-up app (Mac)" "$MAC_DD" 'platform=macOS,variant=Mac Catalyst' "${ADMIN_SETTINGS[@]}" CODE_SIGN_ENTITLEMENTS=''; }
build_kid_mac()   { build "kid app (Mac)" "$KIDMAC_DD" 'platform=macOS,variant=Mac Catalyst'; }

# ---- devices -----------------------------------------------------------------
# devicectl is asked ONCE per run (an occasionally-empty answer used to make
# the loop skip a phone that was plainly there). "connected" and
# "available (paired)" count; "unavailable" is a dead pairing, not a device.
DEV_LIST=""
scan_devices() {
    DEV_LIST=$(xcrun devicectl list devices 2>/dev/null | grep -iE "connected|available" | grep -viE "unavailable")
}
device_ids()  { echo "$DEV_LIST" | grep -oiE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}'; }
# devicectl's table is: Name   Hostname   Identifier   State   Model, columns
# separated by runs of spaces; the name itself may have single spaces in it.
device_name() { echo "$DEV_LIST" | grep -i "$1" | head -1 | sed -E 's/ {2,}.*//'; }
is_admin_device() {
    local n="$1"; for a in "${ADMIN_DEVICES[@]}"; do [[ "$n" == *"$a"* ]] && return 0; done; return 1
}
is_ignored() {
    local n="$1"; for a in "${IGNORE_DEVICES[@]}"; do [[ "$n" == *"$a"* ]] && return 0; done; return 1
}
# Gabriel's iPad is iOS 16 and never appears to devicectl. xctrace sees it.
ipad_note() {
    if xcrun xctrace list devices 2>/dev/null | grep -qiE "iPad.*\(16\."; then
        log "    NOTE: an iOS 16 iPad is attached (Gabriel's). devicectl cannot install to it."
        log "          Open LearnTube.xcodeproj in Xcode, pick that iPad, press Cmd-R (Cmd-B installs nothing)."
    fi
}
show_devices() {
    scan_devices
    log "==> Devices devicectl can reach:"
    local any=0
    for id in $(device_ids); do
        any=1; local n; n=$(device_name "$id")
        if is_ignored "$n"; then log "    $n  ->  skipped"
        elif is_admin_device "$n"; then log "    $n  ->  grown-up app"
        else log "    $n  ->  kid app"; fi
    done
    [ $any -eq 0 ] && log "    (none: unlock the phone, same Wi-Fi or plugged in)"
    ipad_note
}

# install <app> <udid> <name>
install_to() {
    local app="$1" id="$2" name="$3"
    log "==> Installing $(basename "$app") to $name ..."
    if xcrun devicectl device install app --device "$id" "$app" >> "$XLOG" 2>&1; then
        log "    done."; return 0
    else
        log "    did not accept the install (asleep, locked, off Wi-Fi, or iOS 16)."; return 1
    fi
}

# resolve "Name" or UDID -> UDID (first match)
resolve() {
    local want="$1"
    scan_devices
    for id in $(device_ids); do
        [[ "$id" == "$want" ]] && { echo "$id"; return; }
        [[ "$(device_name "$id")" == *"$want"* ]] && { echo "$id"; return; }
    done
}

# ---- this Mac ----------------------------------------------------------------
install_mac() {
    [ -d "$MAC_APP" ] || die "no Mac build to install"
    rm -f "$MAC_APP/Contents/embedded.provisionprofile"
    local devid; devid=$(security find-identity -v -p codesigning 2>/dev/null | grep -o 'Apple Development[^"]*' | head -1)
    if [ -n "$devid" ]; then codesign --force --deep --sign "$devid" "$MAC_APP" >> "$XLOG" 2>&1 || log "    (warning: re-sign failed)"
    else codesign --force --deep --sign - "$MAC_APP" >> "$XLOG" 2>&1 || log "    (warning: ad-hoc sign failed)"; fi
    # Never quit the running copy with AppleScript from here: the first run
    # pops a "Terminal wants to control LearnTube" consent and osascript then
    # blocks forever, silently, after the build already succeeded. pkill is enough.
    pkill -9 -f "LearnTubeAdmin.app" 2>/dev/null || true
    for i in 1 2 3 4 5; do pgrep -f "LearnTubeAdmin.app" >/dev/null || break; sleep 1; done
    rm -rf "/Applications/LearnTubeAdmin.app"
    ditto "$MAC_APP" "/Applications/LearnTubeAdmin.app"
    xattr -dr com.apple.quarantine "/Applications/LearnTubeAdmin.app" 2>/dev/null || true
    open "/Applications/LearnTubeAdmin.app" || true
    log "==> Grown-up app installed to /Applications and opened (build $STAMP)."
}

# ---- dist/ for the other Macs ------------------------------------------------
# Kid app for Gabriel's Mac (Developer ID signed and notarized when the key is
# present) and a portable ad-hoc grown-up app for Paige's Mac. Both land in
# dist/ on the NAS beside their Install*.command scripts.
make_dist() {
    build_kid_mac || return 1
    local devid="Developer ID Application: GINA LOUISE TURLEY (2286RHQ434)"
    local key="$HOME/.appstoreconnect/private_keys/AuthKey_93Z3AGX448.p8"
    rm -f "$KIDMAC_APP/Contents/embedded.provisionprofile"
    local ent=/tmp/lt_devid.entitlements
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict/></plist>\n' > "$ent"
    if codesign --force --deep --options runtime --timestamp --entitlements "$ent" --sign "$devid" "$KIDMAC_APP" >> "$XLOG" 2>&1; then
        log "    Developer ID signed."
        if [ -f "$key" ]; then
            local zip=/tmp/LearnTube-notarize.zip; rm -f "$zip"; ditto -c -k --keepParent "$KIDMAC_APP" "$zip"
            log "==> Notarizing (1-3 minutes) ..."
            if xcrun notarytool submit "$zip" --key "$key" --key-id 93Z3AGX448 \
                 --issuer d06b6275-9506-447d-bbe3-065049d3ade5 --wait >> "$XLOG" 2>&1; then
                xcrun stapler staple "$KIDMAC_APP" >> "$XLOG" 2>&1 && log "    notarized and stapled."
            else log "    (notarization failed; still Developer ID signed, Gabriel's Mac may prompt once)"; fi
        else log "    (no notary key at $key; skipping notarization)"; fi
    else
        log "    (Developer ID signing failed; falling back to ad-hoc)"
        codesign --force --deep --sign - "$KIDMAC_APP" >> "$XLOG" 2>&1 || true
    fi
    mkdir -p dist; rm -rf "dist/LearnTube.app"; ditto "$KIDMAC_APP" "dist/LearnTube.app"
    log "==> dist/LearnTube.app ready for Gabriel's Mac (Install LearnTube.command)."

    [ -d "$MAC_APP" ] || build_admin_mac || return 1
    rm -f "$MAC_APP/Contents/embedded.provisionprofile"
    codesign --force --deep --sign - "$MAC_APP" >> "$XLOG" 2>&1 || true
    rm -rf "dist/LearnTube Parent.app"; ditto "$MAC_APP" "dist/LearnTube Parent.app"
    log "==> dist/LearnTube Parent.app ready for Paige's Mac (Install LearnTube Parent.command)."
}

# ---- phones ------------------------------------------------------------------
deploy_phones() {
    scan_devices
    local ids; ids=$(device_ids)
    if [ -z "$ids" ]; then log "==> No phone or iPad reachable; skipped the phones."; ipad_note; return 0; fi
    local need_kid=0 need_admin=0
    for id in $ids; do
        local n; n=$(device_name "$id"); is_ignored "$n" && continue
        if is_admin_device "$n"; then need_admin=1; else need_kid=1; fi
    done
    [ $need_kid -eq 1 ]   && { build_kid_ios   || return 1; }
    [ $need_admin -eq 1 ] && { build_admin_ios || return 1; }
    local ok=0
    for id in $ids; do
        local n; n=$(device_name "$id"); is_ignored "$n" && { log "==> Skipping $n."; continue; }
        if is_admin_device "$n"; then install_to "$ADMIN_APP" "$id" "$n" && ok=$((ok+1))
        else install_to "$KID_APP" "$id" "$n" && ok=$((ok+1)); fi
    done
    log "==> $ok device(s) updated to build $STAMP."
    ipad_note
}

# ---- modes -------------------------------------------------------------------
case "$MODE" in
    check)
        build_kid_ios && build_admin_ios && log "==> Both builds compile. Nothing installed." ;;
    devices)
        show_devices ;;
    mac)
        build_admin_mac && install_mac ;;
    kid|admin)
        [ -n "$TARGET" ] || die "usage: run.sh $MODE \"Device Name\""
        id=$(resolve "$TARGET"); [ -n "$id" ] || die "no reachable device matches \"$TARGET\" (try: run.sh devices)"
        if [ "$MODE" = kid ]; then build_kid_ios && install_to "$KID_APP" "$id" "$(device_name "$id")"
        else build_admin_ios && install_to "$ADMIN_APP" "$id" "$(device_name "$id")"; fi ;;
    dist)
        make_dist ;;
    all)
        deploy_phones; build_admin_mac && install_mac; make_dist ;;
    default|"")
        deploy_phones; build_admin_mac && install_mac ;;
    *)
        die "unknown mode '$MODE' (check | devices | mac | kid NAME | admin NAME | dist | all)" ;;
esac
status=$?
log ""
log "Finished $(date '+%H:%M:%S'). Log: build/run.log  ·  compiler output: build/xcodebuild.log"
exit $status
