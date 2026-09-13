#!/bin/bash
# Downloads Canva scene art for the act-it-out games into build/scene/.
cd "$(dirname "$0")" && mkdir -p build/scene
curl -fSL -o build/scene/leo-sheet.png 'https://export-download.canva.com/Lrjx8/DAHVCBLrjx8/-1/0/0001-5700946937502117002.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260912%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260912T161601Z&X-Amz-Expires=33404&X-Amz-Signature=94ff58bad28954f6adbf20f838f1cfbee0feb51f577309bd6920803f6ba2c4e4&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Sun%2C%2013%20Sep%202026%2001%3A32%3A45%20GMT' && ls -la build/scene && echo "==> Done."
sleep 2; exit
