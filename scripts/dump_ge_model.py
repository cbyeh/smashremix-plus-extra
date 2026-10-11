#!/usr/bin/env python3
"""
dump_ge_model.py - decompose a GoldEditor / SSB64 self-relocating .bin model.

Walks the internal fixup chain (linked list of 4-byte [u16 next_word][u16
data_word] pointer fields; head = the file's internal-table offset), classifies
every relocatable pointer by the GBI command or struct it sits in, follows the
display lists, sizes every texture / TLUT / vertex block by the gap to the next
region, and - given a root (a footer's DObjDesc pointer, or --root) - reports
which regions are reachable and which are orphaned leftovers.

Usage:
  dump_ge_model.py MODEL.bin --table 0x404 [--footer HITBOX.bin] [--root 0xCA0]
  dump_ge_model.py MODEL.bin --table 0x404 --raw        # full GBI listing
  dump_ge_model.py A.bin B.bin --table 0x404 --diff     # compare two exports
"""
import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from smashremix_extra.ge_bin import walk_chain, find_chain_head  # noqa: E402

GBI = {
    0x00: "SPNOOP", 0x01: "VTX", 0x03: "MOVEMEM", 0x04: "VTX_F3DEX",
    0x05: "TRI1", 0x06: "TRI2/QUAD", 0xB1: "TRI2", 0xB2: "MODIFYVTX",
    0xB3: "BRANCH_Z", 0xB4: "TRI1_EX", 0xB6: "CLEARGEOMETRYMODE",
    0xB7: "SETGEOMETRYMODE", 0xB8: "ENDDL", 0xB9: "SETOTHERMODE_L",
    0xBA: "SETOTHERMODE_H", 0xBB: "TEXTURE", 0xBC: "MOVEWORD", 0xBD: "POPMTX",
    0xBE: "CULLDL", 0xBF: "LINE3D", 0xE1: "RDPHALF_1", 0xE2: "SETOTHERMODE_L",
    0xE3: "SETOTHERMODE_H", 0xDE: "DL", 0xDF: "ENDDL", 0xD7: "TEXTURE",
    0xD8: "POPMTX", 0xD9: "GEOMETRYMODE", 0xDA: "MTX", 0xDB: "MOVEWORD",
    0xDC: "MOVEMEM", 0xDD: "LOAD_UCODE", 0xE0: "SPNOOP", 0xF0: "LOADTLUT",
    0xF2: "SETTILESIZE", 0xF3: "LOADBLOCK", 0xF4: "LOADTILE", 0xF5: "SETTILE",
    0xF6: "FILLRECT", 0xF7: "SETFILLCOLOR", 0xF8: "SETFOGCOLOR",
    0xF9: "SETBLENDCOLOR", 0xFA: "SETPRIMCOLOR", 0xFB: "SETENVCOLOR",
    0xFC: "SETCOMBINE", 0xFD: "SETTIMG", 0xFE: "SETZIMG", 0xFF: "SETCIMG",
}
SIZ = {0: "4b", 1: "8b", 2: "16b", 3: "32b"}
FMT = {0: "RGBA", 1: "YUV", 2: "CI", 3: "IA", 4: "I"}


def u16(b, o): return struct.unpack(">H", b[o:o + 2])[0]
def u32(b, o): return struct.unpack(">I", b[o:o + 4])[0]


def decode_dl(d, start, limit=4000):
    """Yield (off, opcode, name, w0, w1) until ENDDL. Does not recurse."""
    o = start
    for _ in range(limit):
        if o + 8 > len(d):
            return
        w0, w1 = u32(d, o), u32(d, o + 4)
        op = d[o]
        yield o, op, GBI.get(op, f"?{op:02X}"), w0, w1
        o += 8
        if op in (0xDF, 0xB8):
            return


def analyze(path, table_off, footer_path, root_override, raw):
    d = Path(path).read_bytes()
    n = len(d)
    if table_off is None:
        table_off = find_chain_head(d)
        if table_off is None:
            sys.exit(f"{path}: could not auto-detect chain head - pass --table")
    nodes = walk_chain(d, table_off)
    targets = sorted(set(t for _, _, t in nodes))
    bounds = sorted(set([0, n] + targets))

    def region(x):
        lo = 0
        for b in bounds:
            if b <= x:
                lo = b
            else:
                break
        return lo, bounds[bounds.index(lo) + 1] if bounds.index(lo) + 1 < len(bounds) else n

    # classify each fixup node by the command byte 4 bytes before its operand
    kind = {}
    for off, _, tgt in nodes:
        pre = d[off - 4] if off >= 4 else -1
        if pre == 0xFD:
            kind[off] = "SETTIMG"
        elif pre in (0x01, 0x04):
            kind[off] = "VTX"
        elif pre == 0xDE:
            kind[off] = "DL"
        elif pre in (0x03, 0xDC):
            kind[off] = "MOVEMEM"
        else:
            kind[off] = "struct"

    # texture format: for each SETTIMG node, scan forward in its DL for SETTILE/SETTILESIZE
    tex_meta = {}
    for off, _, tgt in nodes:
        if kind[off] != "SETTIMG":
            continue
        cmd = off - 4
        fmt = siz = w = h = None
        is_tlut = False
        for co, op, name, w0, w1 in decode_dl(d, cmd, 40):
            if co == cmd:
                siz = (d[cmd + 1] >> 3) & 3
                fmt = (d[cmd + 1] >> 5) & 7
                continue
            if op == 0xF0:
                is_tlut = True
            if op == 0xF5 and co != cmd:  # next SETTILE
                pass
            if op == 0xF2:  # SETTILESIZE: lrs/lrt in w1 (10.2)
                lrs = (w0 >> 12) & 0xFFF
                lrt = w0 & 0xFFF
                w = (lrs >> 2) + 1
                h = (lrt >> 2) + 1
                break
            if op in (0xDF, 0xB8, 0x05, 0x06):
                break
        tex_meta[tgt] = (fmt, siz, w, h, is_tlut)

    # reachability
    roots = []
    fd = fp = None
    if footer_path:
        f = Path(footer_path).read_bytes()
        fnodes = walk_chain(f, 0x40)
        if len(fnodes) >= 1:
            fd = u16(f, 0x40 + 2) * 4
        if len(fnodes) >= 2:
            fp = u16(f, fnodes[1][0] + 2) * 4
        roots += [x for x in (fd, fp) if x is not None]
    if root_override is not None:
        roots.append(root_override)
    if not roots:
        roots = [targets[0]] if targets else []

    reach = set()
    work = [region(r)[0] for r in roots]
    while work:
        r = work.pop()
        if r in reach:
            continue
        reach.add(r)
        s, e = region(r)
        for off, _, tgt in nodes:
            if s <= off < e:
                work.append(region(tgt)[0])

    # DObjDesc lists: [x][ptr][00000004][0] preamble then 0x2C entries to id 0x12
    objs = []
    for h in range(0, n - 12, 4):
        if u32(d, h + 8) == 4 and u32(d, h + 12) == 0 and h + 0x10 + 0x2C <= n:
            e = h + 0x10
            ids = []
            while e + 4 <= n and u32(d, e) != 0x12 and len(ids) < 24:
                ids.append((u32(d, e), u32(d, e + 4)))
                e += 0x2C
            if e + 4 <= n and u32(d, e) == 0x12:
                objs.append((h, e + 4, ids))

    print(f"\n{'='*72}\n{path}   {n} bytes (0x{n:X})   chain head 0x{table_off:X}, "
          f"{len(nodes)} nodes\n{'='*72}")
    if footer_path:
        print(f"footer {Path(footer_path).name}: DObjDesc -> 0x{fd:X}"
              + (f", p_mobjsubs -> 0x{fp:X}" if fp is not None else ""))
    print(f"\nOBJECTS (DObjDesc lists): {len(objs)}")
    for s, e, ids in objs:
        used = region(s + 0x10)[0] in reach or any(region(s)[0] == region(r)[0] for r in roots)
        tag = "  <== ROOT" if any(abs(r - (s + 0x10)) < 0x40 for r in roots) else (
            "" if used else "   [ORPHAN]")
        print(f"  0x{s:04X}..0x{e:04X}  entries={[i for i,_ in ids]}{tag}")

    print(f"\nREGIONS  ({sum(1 for b in bounds[:-1])} between fixup targets)")
    print(f"  {'range':<20}{'size':>7}  {'reach':<6} kind")
    orphan_bytes = 0
    for i, b in enumerate(bounds[:-1]):
        e = bounds[i + 1]
        r = "USED" if b in reach else "----"
        knodes = [kind[o] for o, _, t in nodes if b <= o < e]
        tnodes_ = [kind[o] for o, _, t in nodes if region(t)[0] == b]
        desc = ""
        if b in tex_meta:
            fmt, siz, w, h, tl = tex_meta[b]
            desc = "TLUT" if tl else "TEX"
            if fmt is not None:
                desc += f" {FMT.get(fmt,'?')}{SIZ.get(siz,'?')}"
            if w:
                desc += f" {w}x{h}"
        elif any(k == "VTX" for k in tnodes_):
            desc = "vertex data"
        elif any(region(s2)[0] <= b < e2 for s2, e2, _ in objs):
            desc = "DObjDesc/DLLink"
        elif knodes:
            desc = "struct (" + ",".join(sorted(set(knodes))) + ")"
        elif b == 0:
            desc = "vertex data / header"
        else:
            # is it inside a DL?
            desc = "DL / data"
        if b not in reach:
            orphan_bytes += e - b
        print(f"  0x{b:04X}..0x{e:04X}  {e-b:>6}  {r:<6} {desc}")
    print(f"\nORPHAN (unreachable from root): {orphan_bytes} bytes of {n}")

    node_tgt = {o: t for o, _, t in nodes}

    def reloc(word):
        """A dl/ptr field still in [next|data] form -> data offset."""
        return (word & 0xFFFF) * 4

    if raw:
        print("\nOBJECT / DISPLAY-LIST TREE:")
        seen_dl = set()

        def dump_dl(start, ind):
            if start in seen_dl or not (0 <= start < n - 8):
                return
            seen_dl.add(start)
            pad = "  " * ind
            print(f"{pad}--- DL @ 0x{start:X} ---")
            for co, op, name, w0, w1 in decode_dl(d, start, 300):
                mark = ""
                if co + 4 in node_tgt:
                    mark = f"  -> 0x{node_tgt[co+4]:X} [{kind[co+4]}]"
                print(f"{pad}  0x{co:04X}: {w0:08X} {w1:08X}  {name}{mark}")
                if op == 0xDE and (w1 >> 24) not in (0x0E, 0x09, 0x08):
                    if co + 4 in node_tgt:
                        dump_dl(node_tgt[co + 4], ind + 1)
            # a DLLink array precedes some DLs: pairs [id, dl] till id==4
            # nothing to recurse

        for s, e, ids in objs:
            print(f"  DObjDesc list @ 0x{s:X}  (entries {[i for i,_ in ids]})")
            for idv, dlw in ids:
                if dlw == 0:
                    print(f"    id={idv}  dl=NULL")
                    continue
                tgt = reloc(dlw)
                print(f"    id={idv}  dl=0x{dlw:08X} -> 0x{tgt:X}")
                # tgt may be a DLLink array {u32 list_id; Gfx* dl} till list_id==4
                p = tgt
                for _ in range(8):
                    if p + 8 > n:
                        break
                    lid = u32(d, p)
                    if lid == 4 or lid > 0x20:
                        break
                    dlt = reloc(u32(d, p + 4)) if (p + 4) in node_tgt or True else 0
                    if p + 4 in node_tgt:
                        dlt = node_tgt[p + 4]
                    print(f"      DLLink list_id={lid} -> 0x{dlt:X}")
                    dump_dl(dlt, 3)
                    p += 8
        # any reachable region that starts with a GBI opcode and wasn't dumped
        print("\n  other reachable DL-looking regions:")
        for i, b in enumerate(bounds[:-1]):
            if b in reach and b not in seen_dl and d[b] in GBI and d[b] in (
                    0xE7, 0xDB, 0xD9, 0xFC, 0xE3, 0xFD, 0x01):
                dump_dl(b, 2)

    return dict(path=path, n=n, nodes=nodes, targets=targets, reach=reach,
               tex_meta=tex_meta, orphan=orphan_bytes)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("models", nargs="+")
    ap.add_argument("--table", type=lambda x: int(x, 0), default=None,
                    help="chain head (default: auto-detect)")
    ap.add_argument("--footer", default=None)
    ap.add_argument("--root", type=lambda x: int(x, 0), default=None)
    ap.add_argument("--raw", action="store_true", help="dump GBI listings")
    ap.add_argument("--diff", action="store_true", help="byte-compare two models")
    a = ap.parse_args()
    res = [analyze(m, a.table, a.footer, a.root, a.raw) for m in a.models]
    if a.diff and len(res) == 2:
        A = Path(res[0]["path"]).read_bytes()
        B = Path(res[1]["path"]).read_bytes()
        print(f"\n{'='*72}\nDIFF {res[0]['path']} vs {res[1]['path']}")
        runs = []
        i = 0
        while i < min(len(A), len(B)):
            if A[i] != B[i]:
                j = i
                while j < min(len(A), len(B)) and A[j] != B[j]:
                    j += 1
                runs.append((i, j))
                i = j
            else:
                i += 1
        tot = sum(j - i for i, j in runs)
        print(f"  {len(runs)} diff runs, {tot} bytes; sizes {len(A)} vs {len(B)}")
        for i, j in runs[:40]:
            print(f"  0x{i:04X}..0x{j:04X} ({j-i}b)")


if __name__ == "__main__":
    main()
