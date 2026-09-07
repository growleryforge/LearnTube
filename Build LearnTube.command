#!/bin/bash
# Double-click: build LearnTube and install it on every reachable device
# (kid app to Gabriel's, grown-up app to the parents' phones and this Mac).
# Same as "Build LearnTube.app"; this one is for when Finder won't open the app.
cd "$(dirname "$0")" && bash tools/run.sh
echo; read -n1 -r -p "Done. Press any key to close..."
