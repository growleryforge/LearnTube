#!/usr/bin/env python3
"""Turn a Canva export of the "LearnTube 2.0 Thumbnails" design into asset
catalog imagesets named thumb-<skill id>, which LessonThumb prefers over the
drawn tile whenever one exists.

    python3 tools/install_thumbs.py <export.pdf | folder of 0001.png...> [--order tools/thumbs/order.json]

The page order of the Canva design is recorded in tools/thumbs/order.json
(page 1 = first id). Re-run after adding pages to the design: existing
imagesets are overwritten, nothing else in Assets.xcassets is touched.

Needs pdftoppm (poppler) for PDF input; a folder of already-rasterised
PNGs works without it. Tiles are stored at 640x360, which is 2x the tallest
tile the feed draws.
"""
import json, os, shutil, subprocess, sys, tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(REPO, "LearnTube", "Assets.xcassets")

def rasterise(pdf, out):
    subprocess.run(["pdftoppm", "-png", "-r", "72", "-scale-to-x", "640", "-scale-to-y", "-1", pdf,
                    os.path.join(out, "page")], check=True)
    return sorted(f for f in os.listdir(out) if f.endswith(".png"))

def main():
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    src = sys.argv[1]
    order_path = sys.argv[sys.argv.index("--order") + 1] if "--order" in sys.argv else os.path.join(REPO, "tools", "thumbs", "order.json")
    order = json.load(open(order_path))
    tmp = tempfile.mkdtemp()
    if os.path.isdir(src):
        pages = sorted(f for f in os.listdir(src) if f.lower().endswith(".png"))
        pagedir = src
    else:
        pages = rasterise(src, tmp); pagedir = tmp
    if len(pages) != len(order):
        print(f"!! {len(pages)} pages but order.json lists {len(order)} ids; refusing to guess.")
        sys.exit(2)
    for page, sid in zip(pages, order):
        name = f"thumb-{sid}"
        d = os.path.join(ASSETS, name + ".imageset")
        os.makedirs(d, exist_ok=True)
        shutil.copy(os.path.join(pagedir, page), os.path.join(d, name + ".png"))
        json.dump({"images": [{"filename": name + ".png", "idiom": "universal", "scale": "1x"},
                              {"idiom": "universal", "scale": "2x"},
                              {"idiom": "universal", "scale": "3x"}],
                   "info": {"author": "xcode", "version": 1}},
                  open(os.path.join(d, "Contents.json"), "w"), indent=2)
        print("  ", name)
    print(f"==> {len(order)} thumbnails installed into Assets.xcassets")

if __name__ == "__main__":
    main()
