#!/bin/bash
# Downloads the Canva export of "LearnTube 2.0 Thumbnails" (85 pages) into
# build/ so the session can split it. Runs in the Mac's own Terminal, which
# can reach Canva. Safe to delete after use.
cd "$(dirname "$0")" && mkdir -p build
URL='https://export-download.canva.com/lR_zY/DAHUkSlR_zY/-1/0-6722137755982200929.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260909%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260909T034339Z&X-Amz-Expires=7888&X-Amz-Signature=d2da99e1eb2375a8518eaa9435db1fb420c2179e58f1e9b0de734d9520c13e56&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Wed%2C%2009%20Sep%202026%2005%3A55%3A07%20GMT'
echo "==> Downloading LearnTube 2.0 Thumbnails.pdf (85 pages) ..."

if curl -fSL -o "build/thumbs85.pdf" "$URL"; then ls -la build/thumbs85.pdf; echo "==> Done."; else echo "!! Download failed."; fi
sleep 2; exit
