#!/usr/bin/env python3
# Guardrail: flag any quiz Question where the correct answer is effectively
# shown in the prompt (question == answer), which lets a kid match instead of
# read. Normalizes by lowercasing and stripping non-letters/digits so
# "Blend it: c-a-t" -> "blenditcat" is caught as containing "cat".
import re, sys, glob
norm = lambda s: re.sub(r'[^a-z0-9]', '', s.lower())
pat = re.compile(r'Question\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*correct:\s*"((?:[^"\\]|\\.)*)"')
flags = 0
for f in glob.glob("LearnTube/Curriculum*.swift"):
    for i, line in enumerate(open(f), 1):
        for m in pat.finditer(line):
            prompt, correct = m.group(1), m.group(2)
            if len(norm(correct)) >= 2 and norm(correct) in norm(prompt):
                print(f"{f}:{i}  answer '{correct}' is inside prompt \"{prompt}\"")
                flags += 1
print(f"\n{flags} question=answer issue(s) found." if flags else "\nClean: no question=answer issues.")
sys.exit(1 if flags else 0)
