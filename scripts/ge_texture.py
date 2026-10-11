#!/usr/bin/env python3
"""
ge_texture.py - list / extract / inject textures in a GoldEditor SSB64 .bin
model, so skins can be edited in any image editor instead of GoldEditor.

  ge_texture.py MODEL.bin --table 0x40C list
  ge_texture.py MODEL.bin --table 0x40C extract [--out DIR]
  ge_texture.py MODEL.bin --table 0x40C inject 0x130 newskin.png [--repalette]

Textures are found by scanning every G_SETTIMG (0xFD) whose operand is in the
file's fixup chain, then reading the neighbouring G_SETTILE / G_SETTILESIZE /
G_LOADTLUT / G_LOADBLOCK to recover format, size and dimensions. CI textures are
paired with the nearest preceding TLUT. N64 odd-row 32-bit word swizzle is
undone on extract and reapplied on inject.

inject keeps the byte length identical (same format + dimensions). For CI it
quantises to the existing palette unless --repalette (then the TLUT is rewritten
in place, same entry count).
"""
import argparse
import struct
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from smashremix_extra.ge_bin import (  # noqa: E402
    SIZ_BPP, FMT_NAME, u16, u32, walk_chain, find_chain_head, find_textures)


# ---------- swizzle ----------
# GoldEditor / SSB64 store these textures LINEARLY (verified: deswizzling the
# grenade CI4 makes it rougher, not smoother). The N64 odd-row 32-bit word swap
# is left here, opt-in via SWIZZLE, in case some file needs it.
SWIZZLE = False


def deswizzle(buf, w, h, bpp):
    row = w * bpp // 8
    if not SWIZZLE or row % 8 or row == 0:
        return bytes(buf[:row * h]) if row else bytes(buf)
    a = bytearray(buf[:row * h])
    words = row // 4
    for y in range(1, h, 2):
        base = y * row
        r = a[base:base + row]
        for i in range(0, words - (words % 2), 2):
            r[i * 4:(i + 1) * 4], r[(i + 1) * 4:(i + 2) * 4] = \
                bytes(r[(i + 1) * 4:(i + 2) * 4]), bytes(r[i * 4:(i + 1) * 4])
        a[base:base + row] = r
    return bytes(a)


reswizzle = deswizzle  # involution


# ---------- decode to RGBA ----------
def rgba16_to_rgba(v):
    r = (v >> 11) & 0x1F
    g = (v >> 6) & 0x1F
    b = (v >> 1) & 0x1F
    a = v & 1
    return (r << 3 | r >> 2, g << 3 | g >> 2, b << 3 | b >> 2, 255 if a else 0)


def decode(d, rec):
    w, h = rec["w"], rec["h"]
    fmt, siz = rec["fmt"], rec["siz"]
    bpp = SIZ_BPP[siz]
    if not w or not h:
        raise SystemExit(f"no dimensions for texture @0x{rec['off']:X}")
    raw = deswizzle(d[rec["off"]:], w, h, bpp)
    px = np.zeros((h, w, 4), np.uint8)
    if fmt == 0 and siz == 2:  # RGBA16
        for i in range(w * h):
            px[i // w, i % w] = rgba16_to_rgba(struct.unpack(">H", raw[i*2:i*2+2])[0])
    elif fmt == 0 and siz == 3:  # RGBA32
        for i in range(w * h):
            px[i // w, i % w] = tuple(raw[i*4:i*4+4])
    elif fmt == 3 and siz == 2:  # IA16
        for i in range(w * h):
            I, A = raw[i*2], raw[i*2+1]
            px[i // w, i % w] = (I, I, I, A)
    elif fmt == 3 and siz == 1:  # IA8
        for i in range(w * h):
            b = raw[i]
            I = (b >> 4) * 17
            A = (b & 0xF) * 17
            px[i // w, i % w] = (I, I, I, A)
    elif fmt == 3 and siz == 0:  # IA4
        for i in range(w * h):
            b = raw[i // 2]
            n = (b >> 4) if i % 2 == 0 else (b & 0xF)
            I = ((n >> 1) & 7) * 36
            A = 255 if n & 1 else 0
            px[i // w, i % w] = (I, I, I, A)
    elif fmt == 4 and siz == 1:  # I8
        for i in range(w * h):
            px[i // w, i % w] = (raw[i], raw[i], raw[i], 255)
    elif fmt == 4 and siz == 0:  # I4
        for i in range(w * h):
            b = raw[i // 2]
            n = (b >> 4) if i % 2 == 0 else (b & 0xF)
            v = n * 17
            px[i // w, i % w] = (v, v, v, 255)
    elif fmt == 2:  # CI
        pal = read_tlut(d, rec["tlut"])
        for i in range(w * h):
            if siz == 0:
                b = raw[i // 2]
                idx = (b >> 4) if i % 2 == 0 else (b & 0xF)
            else:
                idx = raw[i]
            px[i // w, i % w] = pal[idx] if idx < len(pal) else (255, 0, 255, 255)
    else:
        raise SystemExit(f"unhandled fmt={FMT_NAME.get(fmt)} siz={siz}")
    return px


def read_tlut(d, t):
    if not t:
        raise SystemExit("CI texture but no TLUT found")
    n = t["tlut_count"] or (t["region_bytes"] // 2)
    return [rgba16_to_rgba(struct.unpack(">H", d[t["off"] + i*2:t["off"] + i*2 + 2])[0])
            for i in range(n)]


# ---------- encode from RGBA ----------
def rgba_to_rgba16(r, g, b, a):
    return ((r >> 3) << 11) | ((g >> 3) << 6) | ((b >> 3) << 1) | (1 if a >= 128 else 0)


def encode(px, rec, d, repalette):
    h, w, _ = px.shape
    if (w, h) != (rec["w"], rec["h"]):
        raise SystemExit(f"image is {w}x{h}, texture slot is {rec['w']}x{rec['h']}")
    fmt, siz = rec["fmt"], rec["siz"]
    out = bytearray()
    if fmt == 0 and siz == 2:
        for y in range(h):
            for x in range(w):
                out += struct.pack(">H", rgba_to_rgba16(*px[y, x]))
    elif fmt == 0 and siz == 3:
        for y in range(h):
            for x in range(w):
                out += bytes(px[y, x])
    elif fmt == 3 and siz == 2:
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[y, x]
                out += bytes(((int(r)+int(g)+int(b))//3, a))
    elif fmt == 3 and siz == 1:
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[y, x]
                I = ((int(r)+int(g)+int(b))//3) >> 4
                out += bytes([(I << 4) | (int(a) >> 4)])
    elif fmt == 4 and siz == 1:
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[y, x]
                out += bytes([(int(r)+int(g)+int(b))//3])
    elif fmt == 2:
        pal_rgba = read_tlut(d, rec["tlut"])
        n = len(pal_rgba)
        if repalette:
            im = Image.fromarray(px, "RGBA").convert("RGB").quantize(colors=n)
            newpal = im.getpalette()[:n*3]
            tl = bytearray()
            for i in range(n):
                r, g, b = newpal[i*3:i*3+3]
                tl += struct.pack(">H", rgba_to_rgba16(r, g, b, 255))
            rec["_new_tlut"] = bytes(tl)
            idxmap = np.array(im)
        else:
            pal = np.array([[c[0], c[1], c[2]] for c in pal_rgba], np.int32)
            flat = px[:, :, :3].reshape(-1, 3).astype(np.int32)
            dist = ((flat[:, None, :] - pal[None, :, :]) ** 2).sum(2)
            idxmap = dist.argmin(1).reshape(h, w)
        for y in range(h):
            for x in range(w):
                i = y * w + x
                idx = int(idxmap[y, x])
                if siz == 0:
                    if i % 2 == 0:
                        out.append(idx << 4)
                    else:
                        out[-1] |= idx & 0xF
                else:
                    out.append(idx)
    else:
        raise SystemExit(f"encode unhandled fmt={FMT_NAME.get(fmt)} siz={siz}")
    bpp = SIZ_BPP[siz]
    return reswizzle(bytes(out), w, h, bpp)


# ---------- commands ----------
def cmd_list(d, texs):
    print(f"{'#':>2}  {'offset':>8}  {'kind':<20} {'dims':>9} {'bytes':>6}  tlut")
    for i, t in enumerate(texs):
        kind = "TLUT" if t["is_tlut"] else f"{FMT_NAME.get(t['fmt'],'?')}{SIZ_BPP[t['siz']]}b"
        dims = f"{t['w']}x{t['h']}" if t['w'] else "-"
        exp = (t['w'] * t['h'] * SIZ_BPP[t['siz']] // 8) if t['w'] else None
        warn = ""
        if exp and not t["is_tlut"] and exp > t["region_bytes"]:
            warn = f"  !! {exp}>{t['region_bytes']}"
        tl = f"0x{t['tlut']['off']:X}" if (not t["is_tlut"] and t.get("tlut")) else ""
        if t["is_tlut"]:
            tl = f"{t['tlut_count']} entries"
        print(f"{i:>2}  0x{t['off']:06X}  {kind:<20} {dims:>9} {t['region_bytes']:>6}  {tl}{warn}")


FMT_STR = {
    "CI4": (2, 0), "CI8": (2, 1), "IA4": (3, 0), "IA8": (3, 1), "IA16": (3, 2),
    "I4": (4, 0), "I8": (4, 1), "RGBA16": (0, 2), "RGBA32": (0, 3),
}


def parse_tex(spec, d):
    """OFF:FMT:WxH[:TLUToff] -> a manual texture record."""
    p = spec.split(":")
    off = int(p[0], 0)
    fmt, siz = FMT_STR[p[1].upper()]
    w, h = (int(x, 0) for x in p[2].lower().split("x"))
    rec = dict(cmd=-1, off=off, fmt=fmt, siz=siz, w=w, h=h, is_tlut=False,
               tlut_count=None, region_bytes=w * h * SIZ_BPP[siz] // 8, tlut=None)
    if len(p) > 3:
        t = int(p[3], 0)
        rec["tlut"] = dict(off=t, is_tlut=True, tlut_count=(16 if siz == 0 else 256),
                           region_bytes=(16 if siz == 0 else 256) * 2)
    return rec


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("model")
    ap.add_argument("--table", type=lambda x: int(x, 0), default=None,
                    help="chain head (default: auto-detect)")
    ap.add_argument("--swizzle", action="store_true",
                    help="apply N64 odd-row word swap (default: linear)")
    ap.add_argument("--tex", action="append", default=[], metavar="OFF:FMT:WxH[:TLUT]",
                    help="add a texture the DL scan can't see (e.g. MObj sprites)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list")
    pe = sub.add_parser("extract")
    pe.add_argument("--out", default=None)
    pe.add_argument("--only", type=lambda x: int(x, 0), default=None)
    pi = sub.add_parser("inject")
    pi.add_argument("offset", type=lambda x: int(x, 0))
    pi.add_argument("png")
    pi.add_argument("--repalette", action="store_true")
    a = ap.parse_args()

    global SWIZZLE
    SWIZZLE = a.swizzle
    d = bytearray(Path(a.model).read_bytes())
    head = a.table if a.table is not None else find_chain_head(d)
    if head is None:
        raise SystemExit("could not auto-detect chain head - pass --table 0xNNN")
    texs = find_textures(d, head) + [parse_tex(s, d) for s in a.tex]

    if a.cmd == "list":
        cmd_list(d, texs)
        return

    if a.cmd == "extract":
        outdir = Path(a.out or Path(a.model).stem + "_tex")
        outdir.mkdir(exist_ok=True)
        for t in texs:
            if t["is_tlut"] or (a.only is not None and t["off"] != a.only):
                continue
            if not t["w"]:
                print(f"skip 0x{t['off']:X} (no dims)")
                continue
            px = decode(d, t)
            p = outdir / f"{Path(a.model).stem}_{t['off']:06X}_{FMT_NAME[t['fmt']]}{SIZ_BPP[t['siz']]}_{t['w']}x{t['h']}.png"
            Image.fromarray(px, "RGBA").save(p)
            print(f"wrote {p}")
        return

    if a.cmd == "inject":
        t = next((x for x in texs if x["off"] == a.offset and not x["is_tlut"]), None)
        if not t:
            raise SystemExit(f"no image texture at 0x{a.offset:X} (see `list`)")
        img = Image.open(a.png).convert("RGBA")
        px = np.array(img)
        blob = encode(px, t, d, a.repalette)
        if len(blob) > t["region_bytes"]:
            raise SystemExit(f"encoded {len(blob)} B > slot {t['region_bytes']} B")
        Path(a.model).with_suffix(".bin.texbak").write_bytes(bytes(d))
        d[t["off"]:t["off"] + len(blob)] = blob
        if t.get("_new_tlut"):
            tl = t["tlut"]
            d[tl["off"]:tl["off"] + len(t["_new_tlut"])] = t["_new_tlut"]
            print(f"rewrote TLUT @0x{tl['off']:X} ({len(t['_new_tlut'])} B)")
        Path(a.model).write_bytes(bytes(d))
        print(f"injected {len(blob)} B into 0x{t['off']:X} "
              f"({FMT_NAME[t['fmt']]}{SIZ_BPP[t['siz']]} {t['w']}x{t['h']})  "
              f"backup .bin.texbak")


if __name__ == "__main__":
    main()
