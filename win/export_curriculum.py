#!/usr/bin/env python3
"""
Export the LearnTube curriculum from the Swift sources into platform-neutral
JSON so the Windows app (and any future client) reuses the exact same content:
every skill, its CA standard, its teaching note, and its questions.

Run:  python3 export_curriculum.py
Out:  curriculum.json
"""
import re, json, os
from collections import Counter

SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "LearnTube")

def read(name):
    with open(os.path.join(SRC, name), encoding="utf-8") as f:
        return f.read()

# ---------------------------------------------------------------- skills ----
def parse_skills(text, grade_label):
    out = []
    starts = [m.start() for m in re.finditer(r'Skill\(\s*id:\s*"', text)]
    for i, s in enumerate(starts):
        chunk = text[s: starts[i + 1] if i + 1 < len(starts) else len(text)]
        def grab(key):
            m = re.search(key + r':\s*"((?:[^"\\]|\\.)*)"', chunk)
            return m.group(1) if m else ""
        sid = grab("id")
        if not sid:
            continue
        subj = re.search(r'subject:\s*\.([A-Za-z]+)', chunk)
        out.append({
            "id": sid,
            "grade": grade_label,
            "subject": subj.group(1) if subj else "",
            "title": grab("title"),
            "standard": grab("standard"),
            "activity": grab("activity"),
            "parentTip": grab("parentTip"),
            "lesson": parse_lesson(chunk),
        })
    return out

def parse_lesson(chunk):
    m = re.search(r'lesson:\s*\.([a-zA-Z]+)', chunk)
    if not m:
        return {"type": "unknown"}
    kind = m.group(1)
    body = chunk[m.end():]

    if kind == "story":
        sid = re.search(r'id:\s*"([^"]+)"', body)
        return {"type": "story", "storyId": sid.group(1) if sid else ""}

    if kind in ("trace", "order"):
        prompt = re.search(r'prompt:\s*"([^"]*)"', body)
        items = re.search(r'items:\s*\[(.*?)\]', body, re.S)
        return {"type": kind,
                "prompt": prompt.group(1) if prompt else "",
                "items": re.findall(r'"([^"]*)"', items.group(1)) if items else []}

    if kind == "match":
        prompt = re.search(r'prompt:\s*"([^"]*)"', body)
        pairs = re.findall(r'\.init\(\s*"([^"]*)"\s*,\s*"([^"]*)"\s*\)', body)
        return {"type": "match",
                "prompt": prompt.group(1) if prompt else "",
                "pairs": [{"left": a, "right": b} for a, b in pairs]}

    if kind == "numberPad":
        probs = re.findall(r'NumberProblem\(\s*"([^"]*)"\s*,\s*(-?\d+)\s*\)', body)
        return {"type": "numberPad",
                "problems": [{"prompt": p, "answer": int(a)} for p, a in probs]}

    if kind == "quiz":
        qs = []
        for qm in re.finditer(
            r'Question\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*correct:\s*"((?:[^"\\]|\\.)*)"\s*,\s*wrong:\s*\[(.*?)\]',
            body, re.S):
            qs.append({"prompt": qm.group(1), "correct": qm.group(2),
                       "wrong": re.findall(r'"((?:[^"\\]|\\.)*)"', qm.group(3))})
        return {"type": "quiz", "questions": qs}

    if kind == "count":
        t = re.search(r'target:\s*(\d+)', body)
        sym = re.search(r'symbol:\s*"([^"]*)"', body)
        prompt = re.search(r'prompt:\s*"([^"]*)"', body)
        return {"type": "count",
                "target": int(t.group(1)) if t else 0,
                "symbol": sym.group(1) if sym else "",
                "prompt": prompt.group(1) if prompt else ""}

    return {"type": kind}

# --------------------------------------------------------------- stories ----
def parse_stories(text):
    stories = {}
    marks = [m for m in re.finditer(r'static let (\w+) = StoryContent\(', text)]
    for i, m in enumerate(marks):
        start = m.end()
        # Extent runs to the next `static let` (or end of file) — more robust
        # than looking for a fixed terminator, since stories with `pages:`
        # arrays don't end the same way as pure quiz stories.
        nxt = re.search(r'\n\s{0,8}static let ', text[start:])
        end = start + nxt.start() if nxt else len(text)
        seg = text[start:end]
        sid = re.search(r'id:\s*"([^"]+)"', seg)
        title = re.search(r'title:\s*"([^"]*)"', seg)
        covers = re.search(r'covers:\s*"((?:[^"\\]|\\.)*)"', seg)
        if not sid:
            continue
        questions = []
        for q in re.finditer(
            r'sqv?\(\s*(\[[^\]]*\]|\.\w+)\s*,\s*"((?:[^"\\]|\\.)*)"\s*,\s*\[(.*?)\]\s*,\s*\[(.*?)\]\s*\)',
            seg, re.S):
            visual_raw, teach, prompts_raw, choices_raw = q.groups()
            visuals = re.findall(r'"([^"]*)"', visual_raw) if visual_raw.startswith("[") else []
            choices = []
            for c in re.finditer(r'sc\(\s*"([^"]*)"\s*,\s*"([^"]*)"\s*(?:,\s*(true))?\s*\)', choices_raw):
                choices.append({"emoji": c.group(1), "label": c.group(2),
                                "correct": bool(c.group(3))})
            questions.append({
                "visuals": visuals,
                "teach": teach,
                "prompts": re.findall(r'"((?:[^"\\]|\\.)*)"', prompts_raw),
                "choices": choices,
            })
        # Reading stories also carry narrative pages.
        pages = [{"scene": sc, "text": tx.replace('\\"', '"')} for sc, tx in
                 re.findall(r'StoryPage\(\s*scene:\s*\.(\w+)\s*,\s*text:\s*"((?:[^"\\]|\\.)*)"', seg, re.S)]
        stories[sid.group(1)] = {
            "id": sid.group(1),
            "title": title.group(1) if title else "",
            "covers": covers.group(1) if covers else "",
            "pages": pages,
            "questions": questions,
        }
    return stories

# ------------------------------------------------------------------ main ----
def main():
    cur = read("Curriculum.swift")

    live = re.search(r'liveStops:\s*\[String\]\s*=\s*\[(.*?)\n    \]', cur, re.S)
    live_ids = re.findall(r'"([^"]+)"', live.group(1)) if live else []

    teach = {}
    tm = re.search(r'teachNotes:\s*\[String:\s*String\]\s*=\s*\[(.*?)\n    \]', cur, re.S)
    if tm:
        for k, v in re.findall(r'"([^"]+)":\s*"((?:[^"\\]|\\.)*)"', tm.group(1)):
            teach[k] = v.replace('\\"', '"')

    skills = parse_skills(read("CurriculumK.swift"), 0)
    skills += parse_skills(read("Curriculum1.swift"), 1)

    # Scan EVERY Swift file for story content — it lives in several files
    # (FamilyLesson, MathLesson, Story...), so don't hard-code the list.
    stories = {}
    for fn in sorted(os.listdir(SRC)):
        if not fn.endswith(".swift") or fn.startswith("._"):
            continue
        try:
            txt = read(fn)
        except Exception:
            continue
        if "StoryContent(" in txt:
            stories.update(parse_stories(txt))

    for s in skills:
        s["teach"] = teach.get(s["id"], s["activity"])
        s["live"] = s["id"] in live_ids

    data = {
        "generatedFrom": "LearnTube Swift sources",
        "liveStops": live_ids,
        "skills": skills,
        "stories": stories,
    }
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "curriculum.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)

    print(f"skills exported : {len(skills)}  (K={sum(1 for s in skills if s['grade']==0)}, G1={sum(1 for s in skills if s['grade']==1)})")
    print(f"live on home    : {sum(1 for s in skills if s['live'])}")
    print(f"lesson types    : {dict(Counter(s['lesson']['type'] for s in skills))}")
    print(f"teach notes     : {len(teach)}")
    print(f"stories         : {len(stories)}  ({sum(len(v['questions']) for v in stories.values())} questions)")
    empty = [s['id'] for s in skills if s['lesson']['type'] in ('quiz','trace','order','match','numberPad')
             and not any(s['lesson'].get(k) for k in ('questions','items','pairs','problems'))]
    print(f"empty payloads  : {len(empty)} {empty[:8]}")
    # Every .story skill must resolve to real content, or it's an unplayable tile.
    missing = [s['id'] for s in skills if s['lesson']['type'] == 'story'
               and s['lesson']['storyId'] not in stories]
    print(f"unresolved story: {len(missing)} {missing[:8]}")
    pages = sum(len(v.get('pages', [])) for v in stories.values())
    print(f"story pages     : {pages}")
    size = os.path.getsize(out)
    print(f"written         : curriculum.json ({size//1024} KB)")

if __name__ == "__main__":
    main()
