#!/bin/bash
# Removes the .smbdelete tombstones a network share leaves behind. These get
# swept into the Xcode target by the synchronized folder group and break the
# linker. Run this from the Mac: its own SMB client is the one holding them.
cd "$(dirname "$0")" || exit 1
echo "Repo: $(pwd)"
before=$(find . -name ".smbdelete*" 2>/dev/null | wc -l | tr -d ' ')
echo "Leftovers found: $before"
find . -name ".smbdelete*" -print -delete 2>/dev/null
sleep 1
after=$(find . -name ".smbdelete*" 2>/dev/null | wc -l | tr -d ' ')
echo
echo "Remaining: $after"
if [ "$after" != "0" ]; then
  echo
  echo "Some are still held open. Try, in order:"
  echo "  1. Quit Xcode AND Finder windows showing this folder, then run again"
  echo "  2. Eject the Home share in Finder and reconnect it, then run again"
  echo "  3. Restart the Mac"
else
  echo "==> Clean. Xcode should build now."
fi
echo
echo "Press any key to close."
read -n 1 -s
exit
