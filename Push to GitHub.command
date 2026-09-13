#!/bin/bash
# Pushes LearnTube to GitHub. Double-click, then type your GitHub username and
# a Personal Access Token when asked (the token is the "password" field).
cd "$(dirname "$0")" || exit 1
echo "Repo: $(pwd)"
git config credential.helper osxkeychain   # remember it, so this is the last time
echo
echo "Commits waiting to push: $(git rev-list --count origin/main..HEAD)"
echo
git push origin main && echo && echo "==> Pushed. You should not be asked again."
echo
echo "Press any key to close."
read -n 1 -s
exit
