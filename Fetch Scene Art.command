#!/bin/bash
# Downloads Canva scene art for the act-it-out games into build/scene/.
cd "$(dirname "$0")" && mkdir -p build/scene
curl -fSL -o build/scene/act-pond.png 'https://export-download.canva.com/QW3nU/DAHUxFQW3nU/-1/0/0001-8277005632861902188.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260909%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260909T113039Z&X-Amz-Expires=69690&X-Amz-Signature=cb54395e3a5a795711b71271f5a78d044323844cf83de98ed00e57da81f5e43a&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Thu%2C%2010%20Sep%202026%2006%3A52%3A09%20GMT' && ls -la build/scene && echo "==> Done."
sleep 2; exit
