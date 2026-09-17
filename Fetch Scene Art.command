#!/bin/bash
# Downloads Canva art listed in build/fetch_list.txt ("<file path> <url>" per line,
# paths relative to the repo) so Claude can install it. Double-click in Finder.
cd "$(dirname "$0")" || exit 1
ok=0; bad=0
while read -r dest url; do
  [ -z "$dest" ] && continue
  mkdir -p "$(dirname "$dest")"
  if curl -fsSL -o "$dest" "$url"; then ok=$((ok+1)); else bad=$((bad+1)); echo "failed: $dest"; fi
done < build/fetch_list.txt
echo "==> Done. $ok fetched, $bad failed." | tee build/fetch_result.txt
sleep 2; exit
