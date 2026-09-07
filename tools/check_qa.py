#!/usr/bin/env python3
# Guardrails for the curriculum files. Run after touching any of them.
#
# 1. Flag any quiz Question where the correct answer is effectively shown in
#    the prompt (question == answer), which lets a kid match instead of read.
#    Normalizes by lowercasing and stripping non-letters/digits so
#    "Blend it: c-a-t" -> "blenditcat" is caught as containing "cat".
#
# 2. Flag any take-away NumberProblem whose picture is only the leftover group.
#    "5 ducks, 2 swim away" drawn as three ducks is a counting-to-3 game with
#    subtraction words on it; that bug shipped in five games before anyone
#    noticed. A take-away prompt ("left", "away", "less", "-") must draw the
#    WHOLE starting group (`draw: .takeAway(...)`) or nothing that equals the
#    answer.
import re, sys, glob
norm = lambda s: re.sub(r'[^a-z0-9]', '', s.lower())
qpat = re.compile(r'Question\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*correct:\s*"((?:[^"\\]|\\.)*)"')
npat = re.compile(r'NumberProblem\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*(\d+)\s*,\s*visual:\s*\[([^\]]*)\]')
takeaway = re.compile(r'\bleft\b|\baway\b|\bless\b|\bbefore\b|\s-\s', re.I)
flags = 0
for f in sorted(glob.glob("LearnTube/Curriculum*.swift")):
    for i, line in enumerate(open(f), 1):
        for m in qpat.finditer(line):
            prompt, correct = m.group(1), m.group(2)
            if len(norm(correct)) >= 2 and norm(correct) in norm(prompt):
                print(f"{f}:{i}  answer '{correct}' is inside prompt \"{prompt}\"")
                flags += 1
        for m in npat.finditer(line):
            prompt, answer, visual = m.group(1), int(m.group(2)), m.group(3)
            tokens = [t for t in re.findall(r'"([^"]*)"', visual) if t not in ("➕", "➖", "🟰", "=")]
            if takeaway.search(prompt) and tokens and len(tokens) == answer:
                print(f"{f}:{i}  take-away draws only the answer ({answer}) for \"{prompt}\"")
                flags += 1
print(f"\n{flags} issue(s) found." if flags else "\nClean: no question=answer or answer-only take-away issues.")
sys.exit(1 if flags else 0)
