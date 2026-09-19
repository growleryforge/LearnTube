#!/bin/bash
# Double-click: send the already-compiled kid app to Gabriel's iPad. Seconds,
# not minutes, because nothing is recompiled. Run "Prebuild Kid App" first.
# His iPad must be awake, unlocked and on Wi-Fi.
cd "$(dirname "$0")" && bash tools/run.sh push "Turley Farms"
echo; read -n1 -r -p "Done. Press any key to close..."
