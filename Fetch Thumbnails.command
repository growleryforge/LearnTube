#!/bin/bash
# Copies the freshly built kid app onto the NAS so Xcode's Devices window can install it on the iOS 16 iPad.
cd /Volumes/Home/Dev/LearnTube || exit 1
rm -rf build/LearnTube.app
cp -R /tmp/lt_kid_dd/Build/Products/Debug-iphoneos/LearnTube.app build/LearnTube.app && ls -la build/LearnTube.app | head -5 && echo "==> Copied."
sleep 2; exit
