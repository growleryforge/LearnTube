#!/usr/bin/env python3
"""Split the Canva Leo expression sheet into four mascot sprites and install
them as imagesets.

    python3 tools/install_leo.py build/scene/leo-sheet.png

The sheet is a 2x2 grid of the same cub on plain white:
    top-left  idle      top-right  happy
    bottom-left cheer   bottom-right oops
Each quadrant has its white background flood-cleared from the edges (so the
cub can sit on any scene), is cropped tight, and is written to
Assets.xcassets/leo-<mood>.imageset.
"""
import json, os, sys
from collections import deque
from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, "build/scene/leo-sheet.png")
MOODS = ["idle", "happy", "cheer", "oops"]     # reading order: TL, TR, BL, BR

def clear_white(im):
    """Anything near-white and connected to the edge becomes transparent."""
    px = im.load(); w, h = im.size
    seen = set()
    q = deque([(x, 0) for x in range(w)] + [(x, h-1) for x in range(w)]
              + [(0, y) for y in range(h)] + [(w-1, y) for y in range(h)])
    while q:
        x, y = q.popleft()
        if (x, y) in seen or x < 0 or y < 0 or x >= w or y >= h: continue
        r, g, b, a = px[x, y]
        if min(r, g, b) < 235: continue
        seen.add((x, y)); px[x, y] = (255, 255, 255, 0)
        q += [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]
    return im

sheet = Image.open(src).convert("RGBA")
W, H = sheet.size
halves = [(0, 0), (W//2, 0), (0, H//2), (W//2, H//2)]
for mood, (ox, oy) in zip(MOODS, halves):
    tile = sheet.crop((ox, oy, ox + W//2, oy + H//2))
    tile = clear_white(tile)
    bbox = tile.getbbox()
    if bbox: tile = tile.crop(bbox)
    tile.thumbnail((800, 800))
    asset = "leo-" + mood
    d = os.path.join(REPO, "LearnTube", "Assets.xcassets", asset + ".imageset")
    os.makedirs(d, exist_ok=True)
    tile.save(os.path.join(d, asset + ".png"))
    json.dump({"images": [{"filename": asset + ".png", "idiom": "universal", "scale": "1x"},
                          {"idiom": "universal", "scale": "2x"},
                          {"idiom": "universal", "scale": "3x"}],
               "info": {"author": "xcode", "version": 1}},
              open(os.path.join(d, "Contents.json"), "w"), indent=2)
    print("installed", asset, tile.size)
