#!/bin/bash
# One-off: update ONLY Gabriel's old iPad, without a full build of everything.
# A normal "Build LearnTube" run already does this automatically when the iPad
# is plugged in, so this is just the shortcut.
cd "$(dirname "$0")"
exec ./tools/run.sh kid "Gabriel’s iPad"
