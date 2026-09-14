#!/bin/bash
# Downloads Canva scene art for the act-it-out games into build/scene/.
cd "$(dirname "$0")" && mkdir -p build/scene
curl -fSL -o build/scene/act-field.png 'https://export-download.canva.com/soe2M/DAHVI3soe2M/-1/0/0001-2640751104601252909.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260913%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260913T044005Z&X-Amz-Expires=86334&X-Amz-Signature=1c66464e1b71ad9eb3ef7d213a9226f89a63ab228723bb236749c315a514bb81&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Mon%2C%2014%20Sep%202026%2004%3A38%3A59%20GMT' && ls -la build/scene && echo "==> Done."
sleep 2; exit
