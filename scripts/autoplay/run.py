#!/usr/bin/env python3
"""Build a self-playing TEST ROM from the current build and screenshot it in Mupen (background).

usage: run.py <p1.txt> [p2.txt] [--shots 300,900,...] [--out DIR] [--timeout SEC] [--rom PATH]

Needs a finished character_appender.py run (main.asm, src/, original_extra.z64).
Script lines:  <frames> [BUTTON+BUTTON|_] [stick_x stick_y]    # comment
  BUTTONs: A B Z START DU DD DL DR L R CU CD CL CR.  Stick is -80..80.  Ends neutral.
"""
import argparse, os, re, subprocess, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HERE = os.path.dirname(os.path.abspath(__file__))
BASS = os.environ.get("BASS", "/tmp/bass-src/bass/bass")
RUNSH = os.path.expanduser("~/n64/emu/run.sh")
MASK = dict(A=0x8000, B=0x4000, Z=0x2000, START=0x1000, DU=0x0800, DD=0x0400, DL=0x0200,
            DR=0x0100, L=0x0020, R=0x0010, CU=0x0008, CD=0x0004, CL=0x0002, CR=0x0001)


def compile_script(path, label):
    out = [f"{label}:"]
    for n, line in enumerate(open(path), 1):
        tok = line.split("#")[0].split()
        if not tok:
            continue
        polls = int(tok[0])  # game frames
        assert 0 < polls < 0x10000, f"{path}:{n}: frames must be 1..65535"
        btn = 0
        if len(tok) > 1 and tok[1] != "_":
            for b in tok[1].upper().split("+"):
                assert b in MASK, f"{path}:{n}: unknown button {b}"
                btn |= MASK[b]
        x, y = (int(tok[2]), int(tok[3])) if len(tok) > 3 else (0, 0)
        assert -128 <= x < 128 and -128 <= y < 128, f"{path}:{n}: stick out of range"
        out.append(f"    dh {polls}, 0x{btn:04X}; db {x & 0xFF}, {y & 0xFF}; dh 0")
    out.append("    dh 0, 0; db 0, 0; dh 0")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("p1"); ap.add_argument("p2", nargs="?")
    ap.add_argument("--shots", help="omit to only build"); ap.add_argument("--out", default="/tmp/autoplay_out")
    ap.add_argument("--timeout", default="180"); ap.add_argument("--rom", default="/tmp/autoplay/test.z64")
    a = ap.parse_args()

    script = compile_script(a.p1, "script_p1") + "\n"
    script += compile_script(a.p2, "script_p2") if a.p2 else "script_p2:\n    dh 0, 0; db 0, 0; dh 0"
    open(os.path.join(HERE, "autoplay_script.asm"), "w").write(script + "\n")

    main_asm = open(os.path.join(ROOT, "main.asm"), encoding="utf-8").read()
    anchor = "OS.align(16)\nmidi_memory_block:"
    assert anchor in main_asm, "main.asm layout changed: midi_memory_block anchor not found"
    test_asm = os.path.join(ROOT, "main_autoplay.asm")
    open(test_asm, "w", encoding="utf-8").write(
        main_asm.replace(anchor, 'include "scripts/autoplay/autoplay.asm"\n' + anchor, 1))

    rom = os.path.abspath(a.rom)
    os.makedirs(os.path.dirname(rom), exist_ok=True)
    open(rom, "wb").close()
    try:
        r = subprocess.run([BASS, "-o", rom, "main_autoplay.asm"], cwd=ROOT,
                           capture_output=True, text=True)
    finally:
        os.remove(test_asm)
    if r.returncode:
        sys.exit("bass failed:\n" + (r.stdout + r.stderr)[-3000:])

    sys.path.insert(0, ROOT)
    import SSB
    n = SSB.N64(bytearray(open(rom, "rb").read()))
    n.calccrc("6103", True)
    open(rom, "wb").write(n.rom)

    if not a.shots:
        return print("built", rom)
    os.makedirs(a.out, exist_ok=True)
    for f in os.listdir(a.out):  # Mupen numbers new shots after old ones
        if f.endswith(".png"):
            os.remove(os.path.join(a.out, f))
    subprocess.run([RUNSH, rom, a.shots, a.out], env={**os.environ, "TIMEOUT": a.timeout})


if __name__ == "__main__":
    main()
