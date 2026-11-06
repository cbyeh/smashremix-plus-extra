#!/usr/bin/env python3
"""Append a full moveset (ground, smash, specials, aerials, grab, taunt, shield) to two
autoplay scripts so both fighters perform the same moves at the same time.
usage: moveset.py p1.txt p2.txt   (P2's stick x is mirrored: it faces the other way)"""
import sys

def frames(path):
    return sum(int(l.split()[0]) for l in open(path) if l.split() and not l.lstrip().startswith('#'))

GAP = "50 _"
MOVES = [  # (label, [lines])
    ("jab x3", ["3 A", "8 _", "3 A", "8 _", "3 A"]),
    ("forward tilt", ["4 A 45 0"]), ("up tilt", ["4 A 0 45"]), ("down tilt", ["10 _ 0 -80", "4 A 0 -80"]),
    ("forward smash", ["4 A 80 0"]), ("up smash", ["4 A 0 80"]), ("down smash", ["4 A 0 -80"]),
    ("dash attack", ["16 _ 80 0", "4 A 80 0"]), ("turn back", ["4 _ -80 0"]),
    ("neutral B", ["4 B"]), ("side B", ["4 B 80 0"]), ("up B", ["4 B 0 80"]), ("down B", ["4 B 0 -80"]),
    ("nair", ["3 CU", "8 _", "4 A"]), ("fair", ["3 CU", "8 _", "4 A 80 0"]),
    ("bair", ["3 CU", "8 _", "4 A -80 0"]), ("uair", ["3 CU", "8 _", "4 A 0 80"]),
    ("dair", ["3 CU", "8 _", "4 A 0 -80"]), ("double jump", ["3 CU", "12 _", "3 CU"]),
    ("grab + throw", ["4 Z", "10 _", "4 _ 80 0"]), ("taunt", ["4 L"]),
    ("shield", ["40 R"]), ("roll", ["4 R", "4 R 80 0"]), ("walk", ["40 _ 35 0"]), ("crouch", ["30 _ 0 -80"]),
]

def mirror(line):
    t = line.split()
    if len(t) == 4:
        t[2] = str(-int(t[2]))
    return " ".join(t)

p1, p2 = sys.argv[1:3]
pad = frames(p1) - frames(p2)
assert pad >= 0, "P2 script is longer than P1's"
a, b = [f"# --- moveset"], [f"{pad} _   # line up with P1"] if pad else []
t = frames(p1)
for label, lines in MOVES:
    a += [f"# {label} @ {t}"] + lines + [GAP]
    b += [f"# {label}"] + [mirror(l) for l in lines] + [GAP]
    t += sum(int(l.split()[0]) for l in lines) + 50
open(p1, "a").write("\n".join(a) + "\n")
open(p2, "a").write("\n".join(b) + "\n")
print("moveset ends at game frame", t)
