#!/usr/bin/env python3
"""Install ActOutPlayer scene art: python3 tools/install_scene.py <asset> <png>
Sprites (act-gate, act-crate) get their white background made transparent.
"""
import json, os, sys
from PIL import Image
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
asset, src = sys.argv[1], sys.argv[2]
kinds = {a["asset"]: a["kind"] for a in json.load(open(os.path.join(REPO, "tools/thumbs/scene.json")))["assets"]}
im = Image.open(src).convert("RGBA")
if kinds.get(asset) == "sprite":
    px = im.load(); w, h = im.size
    # flood from the corners: anything near-white connected to the edge goes clear
    seen = set(); stack = [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]
    while stack:
        x, y = stack.pop()
        if (x,y) in seen or x<0 or y<0 or x>=w or y>=h: continue
        r,g,b,a = px[x,y]
        if min(r,g,b) < 235: continue
        seen.add((x,y)); px[x,y] = (255,255,255,0)
        stack += [(x+1,y),(x-1,y),(x,y+1),(x,y-1)]
    im = im.crop(im.getbbox())
im.thumbnail((1280, 1280))
d = os.path.join(REPO, "LearnTube", "Assets.xcassets", asset + ".imageset"); os.makedirs(d, exist_ok=True)
im.save(os.path.join(d, asset + ".png"))
json.dump({"images":[{"filename": asset + ".png","idiom":"universal","scale":"1x"},{"idiom":"universal","scale":"2x"},{"idiom":"universal","scale":"3x"}],
           "info":{"author":"xcode","version":1}}, open(os.path.join(d,"Contents.json"),"w"), indent=2)
print("installed", asset, im.size)
