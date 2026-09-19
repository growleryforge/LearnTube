#!/bin/bash
# Double-click: list the devices Xcode can currently see, then compile the kid
# app and leave it staged. Installs to NOTHING. Pair with
# "Push to Gabriel iPad.command" when the install needs to land in a chosen
# moment rather than whenever a build happens to finish.
cd "$(dirname "$0")" || exit 1
bash tools/run.sh devices
bash tools/run.sh prebuild
echo; read -n1 -r -p "Done. Press any key to close..."
