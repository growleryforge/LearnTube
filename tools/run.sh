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
#   bash tools/run.sh macs         same thing, said out loud (Gabriel + Paige)
#   bash tools/run.sh all          everything above
#
# The default run now also refreshes the Mac builds in dist/, so Gabriel's
# laptop and Paige's Mac are never left behind on an older build than the
# iPads. Set STAGE_MACS_BY_DEFAULT=0 below to go back to the old behaviour.
#
# Double-clicking this on a Mac WITHOUT Xcode (Gabriel's laptop, Paige's Mac)
# does not fail: it installs the newest build staged in dist/ on that Mac and
# turns on auto-update, so the same double-click works everywhere.
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

# ---- the Macs ----------------------------------------------------------------
# Macs are not phones: devicectl cannot see them, so each one gets a Catalyst
# build staged in dist/ on the NAS and installed one of two ways:
#   - automatically, if dist/"Enable Auto Update.command" was double-clicked
#     once on that Mac (it checks the NAS every 30 minutes), or
#   - by hand, by double-clicking dist/"Install LearnTube.command" there.
#
#   Gabriel's Mac  -> dist/LearnTube.app         (kid games app)
#   Paige's Mac    -> dist/LearnTube Parent.app  (grown-up dashboard)
#   this Mac       -> /Applications              (grown-up dashboard, direct)
#
# 1 = every default run refreshes both, so Gabriel's laptop tracks the iPads.
STAGE_MACS_BY_DEFAULT=1
# Optional straight-to-the-laptop push. Set to user@host (Remote Login on and
# an ssh key set up on Gabriel's Mac) and the build installs itself there when
# the laptop is awake. Empty = leave it on the NAS for the updater to pick up.
GABRIEL_MAC_SSH="${GABRIEL_MAC_SSH:-}"

# ---- logging -----------------------------------------------------------------
mkdir -p build
RUNLOG="$REPO/build/run.log"
XLOG="$REPO/build/xcodebuild.log"
: > "$RUNLOG"; : > "$XLOG"
log() { echo "$*" | tee -a "$RUNLOG"; }
die() { log "!! $*"; log "   (details: build/xcodebuild.log)"; exit 1; }

# ---- is this the build Mac? --------------------------------------------------
# Only one Mac in the house has Xcode. On the others (Gabriel's laptop, Paige's
# Mac) the same double-click installs the newest build staged in dist/ instead
# of trying to compile, and switches auto-update on while it is there.
this_mac_name() { scutil --get ComputerName 2>/dev/null || hostname 2>/dev/null || echo "this Mac"; }
mac_wants_admin() {
    local n="$1" a
    for a in "${ADMIN_DEVICES[@]}"; do [[ "$n" == *"$a"* ]] && return 0; done
    return 1
}
companion_install() {
    local name src label target
    name="$(this_mac_name)"
    log "LearnTube installer  ·  $(date '+%a %b %d %H:%M')"
    log "$name has no Xcode, so it is not the build Mac. Installing instead of building."
    if mac_wants_admin "$name"; then
        src="dist/LearnTube Parent.app"; label="grown-up dashboard"; target="LearnTube Parent.app"
    else
        src="dist/LearnTube.app"; label="kid games app"; target="LearnTube.app"
    fi
    if [ ! -d "$src" ]; then
        log "!! Nothing staged at $src."
        log "   Run the build once on the Mac with Xcode, then try this again."
        return 1
    fi
    local v age
    v=$(defaults read "$PWD/$src/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "?")
    age=$(( ( $(date +%s) - $(stat -f '%m' "$src") ) / 86400 ))
    log "==> Staged $label: v$v, built $(stat -f '%Sm' -t '%b %d %H:%M' "$src") ($age day(s) ago)."
    [ "$age" -gt 2 ] && log "    NOTE: that is not today's build. Run the build on the Xcode Mac for the newest one."

    osascript -e 'quit app "LearnTube"' 2>/dev/null
    pkill -9 -f "$target/Contents/MacOS" 2>/dev/null
    sleep 2

    local dest=""
    if rm -rf "/Applications/$target" 2>/dev/null && ditto "$src" "/Applications/$target" 2>>"$XLOG"; then
        dest="/Applications/$target"
    else
        mkdir -p "$HOME/Applications"
        rm -rf "$HOME/Applications/$target" 2>/dev/null
        ditto "$src" "$HOME/Applications/$target" 2>>"$XLOG" && dest="$HOME/Applications/$target"
    fi
    if [ -z "$dest" ]; then
        log "!! Could not write the app. Is the NAS still connected?"
        return 1
    fi
    xattr -dr com.apple.quarantine "$dest" 2>/dev/null
    log "==> Installed v$v to $dest"

    # Keep this Mac current on its own from now on (kid app only; the parent
    # dashboard is updated deliberately, not behind Paige's back).
    if [ "$label" = "kid games app" ] && [ -f tools/enable_auto_update.command ]; then
        if [ ! -f "$HOME/Library/LaunchAgents/com.turley.learntube.update.plist" ]; then
            log "==> Turning on auto-update for this Mac (checks the NAS every 30 min)."
            bash tools/enable_auto_update.command >> "$XLOG" 2>&1 || log "    (auto-update setup failed; app is still installed)"
        else
            log "==> Auto-update is already on for this Mac."
        fi
    fi
    open "$dest" 2>/dev/null || true
    log ""
    log "Done. Nothing else to do on this Mac."
    return 0
}

if [ ! -d "/Applications/Xcode.app" ]; then
    companion_install
    exit $?
fi

# Version: bump the PATCH on every build so the number on screen is short and
# comparable (2.1.4 is obviously newer than 2.1.3). Bump MAJOR.MINOR by hand in
# the Xcode project when a real feature wave ships.
PBX="$REPO/LearnTube.xcodeproj/project.pbxproj"
bump_version() {
    local cur major minor patch
    cur=$(grep -m1 'MARKETING_VERSION = ' "$PBX" | sed 's/.*MARKETING_VERSION = //; s/;//')
    major=$(echo "$cur" | cut -d. -f1)
    minor=$(echo "$cur" | cut -d. -f2)
    patch=$(echo "$cur" | cut -d. -f3)
    [ -z "$major" ] && major=2
    [ -z "$minor" ] && minor=1
    [ -z "$patch" ] && patch=0
    VERSION="$major.$minor.$((patch + 1))"
    sed -i '' "s/MARKETING_VERSION = .*;/MARKETING_VERSION = $VERSION;/g" "$PBX"
    BUILDNO=$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PBX" | sed 's/.*CURRENT_PROJECT_VERSION = //; s/;//')
    BUILDNO=$((BUILDNO + 1))
    sed -i '' "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $BUILDNO;/g" "$PBX"
}
bump_version
STAMP="$VERSION"
MODE="${1:-default}"; TARGET="${2:-}"
log "LearnTube $VERSION (build $BUILDNO)  ·  mode: $MODE  ·  $(date '+%a %b %d %H:%M')"
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
         CURRENT_PROJECT_VERSION="$BUILDNO" MARKETING_VERSION="$VERSION" "$@" build >> "$XLOG" 2>&1; then
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
# Gabriel's old iPad (iPad6,11, iOS 16.7.16) never appears to devicectl, and
# Xcode 26 cannot install to it either: Run builds and then silently does
# nothing, because devicectl is the only install path it has. ios-deploy still
# speaks the older protocol, so that is how this one gets updated. It is built
# from source once (no brew and no npm on this Mac) and kept in tools/bin.
#
# The iPad has to be plugged in over USB and unlocked.
OLD_IPAD_UDID=a83e7d4e1b9252ad7c5ebf53faeef5aee3280dc6
IOS_DEPLOY="$REPO/tools/bin/ios-deploy"

old_ipad_attached() {
    xcrun xctrace list devices 2>/dev/null \
        | awk '/^== Devices Offline ==/{exit} {print}' \
        | grep -qi "$OLD_IPAD_UDID"
}

build_ios_deploy() {
    [ -x "$IOS_DEPLOY" ] && return 0
    log "==> Building ios-deploy (once) so the old iPad can be updated ..."
    local src=/tmp/ios-deploy-src
    rm -rf "$src"
    git clone --depth 1 https://github.com/ios-control/ios-deploy.git "$src" >> "$XLOG" 2>&1 || {
        log "    could not fetch ios-deploy."; return 1; }
    ( cd "$src" && xcodebuild -project ios-deploy.xcodeproj -configuration Release \
        SYMROOT="$src/build" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO ) >> "$XLOG" 2>&1 || { log "    build failed."; return 1; }
    mkdir -p "$REPO/tools/bin"
    cp "$src/build/Release/ios-deploy" "$IOS_DEPLOY" || return 1
    log "    built."
    return 0
}

install_old_ipad() {
    old_ipad_attached || return 0
    build_ios_deploy || {
        log "    old iPad is attached but ios-deploy is not available; skipping it."
        return 1; }
    log "==> Installing LearnTube.app to Gabriel's old iPad (iOS 16, via ios-deploy) ..."
    # Grade this on whether the app actually INSTALLED, not on ios-deploy's exit
    # code. On this iPad the copy and install run all the way to
    # "[100%] InstallComplete" and then the tool fails in its debug phase,
    # because iOS 16.7.16 has no matching DeviceSupport Symbols directory for
    # the installed Xcode. That is a debugger-attach problem, not an install
    # problem - but the exit code is non-zero either way, so for two runs this
    # reported "did not take it" about an iPad that had just taken it.
    local out; out="$(mktemp)"
    "$IOS_DEPLOY" --id "$OLD_IPAD_UDID" --bundle "$KID_APP" --no-wifi --justlaunch \
        --timeout 15 > "$out" 2>&1
    cat "$out" >> "$XLOG"
    if grep -q "InstallComplete\|Installed package" "$out"; then
        log "    done."
        grep -q "Unable to locate DeviceSupport" "$out" && \
            log "    (installed, but not auto-launched - tap LearnTube on the iPad.)"
    else
        log "    did not take it. It must be plugged in over USB and unlocked."
    fi
    rm -f "$out"
}

ipad_note() {
    if old_ipad_attached; then
        log "    NOTE: Gabriel's old iOS 16 iPad is attached; it is updated over USB with ios-deploy."
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
    show_macs
}

show_macs() {
    log "==> Macs (staged in dist/ on the NAS, not through devicectl):"
    log "    this Mac         ->  grown-up app, straight into /Applications"
    local g="dist/LearnTube.app" p="dist/LearnTube Parent.app"
    if [ -d "$g" ]; then
        log "    Gabriel's Mac    ->  kid app        (dist/LearnTube.app, staged $(stat -f '%Sm' -t '%b %d %H:%M' "$g"))"
    else
        log "    Gabriel's Mac    ->  kid app        (nothing staged yet; run.sh dist)"
    fi
    if [ -n "$GABRIEL_MAC_SSH" ]; then
        log "                         direct push to $GABRIEL_MAC_SSH when it is awake"
    else
        log "                         picked up by the auto-updater, or Install LearnTube.command"
    fi
    if [ -d "$p" ]; then
        log "    Paige's Mac      ->  grown-up app   (dist/LearnTube Parent.app, staged $(stat -f '%Sm' -t '%b %d %H:%M' "$p"))"
    else
        log "    Paige's Mac      ->  grown-up app   (nothing staged yet; run.sh dist)"
    fi
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
    log "==> Grown-up app installed to /Applications and opened (LearnTube $VERSION)."
}

# ---- Gabriel's Mac, over the wire --------------------------------------------
# Only used when GABRIEL_MAC_SSH is set. Never fatal: an asleep laptop just
# means the build waits in dist/ for the auto-updater.
push_gabriel_mac() {
    [ -n "$GABRIEL_MAC_SSH" ] || return 0
    [ -d "dist/LearnTube.app" ] || return 0
    log "==> Pushing to Gabriel's Mac ($GABRIEL_MAC_SSH) ..."
    if ! ssh -o ConnectTimeout=8 -o BatchMode=yes "$GABRIEL_MAC_SSH" true >> "$XLOG" 2>&1; then
        log "    not reachable (asleep, off the network, or Remote Login is off)."
        log "    The build is in dist/; his Mac picks it up on its next check."
        return 0
    fi
    ssh "$GABRIEL_MAC_SSH" 'rm -rf /tmp/LearnTube-push && mkdir -p /tmp/LearnTube-push' >> "$XLOG" 2>&1
    if rsync -a --delete "dist/LearnTube.app" "$GABRIEL_MAC_SSH:/tmp/LearnTube-push/" >> "$XLOG" 2>&1 \
       && ssh "$GABRIEL_MAC_SSH" 'bash -s' < tools/mac_install_remote.sh >> "$XLOG" 2>&1; then
        log "    installed on Gabriel's Mac."
    else
        log "    push failed; left in dist/ for the updater (details: build/xcodebuild.log)."
    fi
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
        if [ "${NOTARIZE:-1}" != 1 ]; then
            log "    (skipping notarization on this run; 'run.sh dist' notarizes)"
        elif [ -f "$key" ]; then
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
    # Keep the two double-clickables beside the app; dist/ is gitignored and
    # gets wiped, tools/ is the tracked copy.
    cp tools/enable_auto_update.command "dist/Enable Auto Update.command" 2>/dev/null
    chmod +x "dist/Enable Auto Update.command" 2>/dev/null
    log "==> dist/LearnTube.app ready for Gabriel's Mac (auto-updater, or Install LearnTube.command)."

    [ -d "$MAC_APP" ] || build_admin_mac || return 1
    rm -f "$MAC_APP/Contents/embedded.provisionprofile"
    codesign --force --deep --sign - "$MAC_APP" >> "$XLOG" 2>&1 || true
    rm -rf "dist/LearnTube Parent.app"; ditto "$MAC_APP" "dist/LearnTube Parent.app"
    log "==> dist/LearnTube Parent.app ready for Paige's Mac (Install LearnTube Parent.command)."
    push_gabriel_mac
}

# ---- phones ------------------------------------------------------------------
deploy_phones() {
    scan_devices
    local ids; ids=$(device_ids)
    if [ -z "$ids" ]; then
        if old_ipad_attached; then
            build_kid_ios || return 1
            install_old_ipad
        else
            log "==> No phone or iPad reachable; skipped the phones."
        fi
        return 0
    fi
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
    log "==> $ok device(s) updated to LearnTube $VERSION."
    install_old_ipad
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
    oldipad)
        if old_ipad_attached; then build_kid_ios && install_old_ipad
        else die "Gabriel's old iPad is not attached. Plug it in with a cable and unlock it."; fi ;;
    dist|macs)
        make_dist ;;
    all)
        deploy_phones; build_admin_mac && install_mac; make_dist ;;
    default|"")
        deploy_phones; build_admin_mac && install_mac
        if [ "$STAGE_MACS_BY_DEFAULT" = 1 ]; then
            NOTARIZE=0
            make_dist || log "!! staging the Mac builds failed; phones and this Mac are still updated."
            NOTARIZE=1
        fi ;;
    *)
        die "unknown mode '$MODE' (check | devices | mac | kid NAME | admin NAME | oldipad | dist | macs | all)" ;;
esac
status=$?
log ""
log "Finished $(date '+%H:%M:%S'). Log: build/run.log  ·  compiler output: build/xcodebuild.log"
exit $status
