#!/bin/bash
# Update ONLY Gabriel's old iPad, without rebuilding and reinstalling
# everything else. A normal "Build LearnTube" run already does this on its own
# when the iPad is plugged in; this is just the shortcut.
#
# The iPad has to be plugged in with a cable and unlocked.
cd "$(dirname "$0")"
./tools/run.sh oldipad
echo
read -n 1 -s -r -p "Press any key to close."
