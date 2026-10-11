#!/usr/bin/env python3
"""
strip_ge_model.py - pull ONE object out of a multi-object GoldEditor .bin.

GoldEditor often exports a .bin holding several DObjDesc lists ("objects" /
"models") even when a mod only wires one of them (an item's <name>_hitbox.bin
footer, or a stage file, points at a single object).  This tool garbage-collects
the file down to just the regions the chosen object needs, recompacts it,
rebuilds the self-relocation chain, and prints every offset you then have to
reconnect by hand (config.yaml table offset, the hitbox->graphics pointer,
texture / sprite offsets used by ASM, ...).

    # what's in here?
    strip_ge_model.py list  MODEL.bin [--table auto|0xNNN] [--footer HB.bin]

    # cut it down to one object and see the new offsets (dry run)
    strip_ge_model.py strip MODEL.bin --keep-object 0 [--map 0x45C 0x12A0 ...]
    strip_ge_model.py strip MODEL.bin --footer HB.bin --apply

    # re-exported a model from GE? map your old hard-coded offsets to the new file
    strip_ge_model.py translate OLD.bin NEW.bin 0x294 0x2A8 0x328 ...

--keep-object N   keep DObjDesc list #N (from `list`)
--root 0xNNN      keep whatever this file offset reaches (an object start, etc.)
--footer HB.bin   keep what the footer's DObjDesc + p_mobjsubs reach; with
                  --apply the footer is rewritten (backup: HB.bin.orig)
--drop A:B        also force byte range [A,B) out (dead DL tails)
--map 0xNNN ...   extra offsets to show old->new in the report (seg_tex etc.)
--apply           write MODEL.bin (backup: MODEL.bin.orig) [+ footer]
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from smashremix_extra import ge_bin as ge  # noqa: E402


def _resolve_head(d, table):
    if table in (None, "auto"):
        h = ge.find_chain_head(d)
        if h is None:
            sys.exit("could not auto-detect the chain head - pass --table 0xNNN")
        return h, True
    return int(table, 0), False


def _tex_label(t):
    if t["is_tlut"]:
        return f"TLUT {t['tlut_count']}"
    k = f"{ge.FMT_NAME.get(t['fmt'], '?')}{ge.SIZ_BPP[t['siz']]}"
    return f"{k} {t['w']}x{t['h']}" if t["w"] else k


# --------------------------------------------------------------------- list ---
def cmd_list(a):
    d = Path(a.model).read_bytes()
    head, auto = _resolve_head(d, a.table)
    nodes = ge.walk_chain(d, head)
    objs = ge.find_objects(d)
    texs = ge.find_textures(d, nodes=nodes)
    bounds = ge.region_bounds(d, nodes)

    roots = []
    if a.footer:
        fr = ge.footer_roots(Path(a.footer).read_bytes())
        roots = [x for x in (fr.dobjdesc, fr.pmobjsubs) if x is not None]
    reach = ge.reachable_regions(nodes, bounds, roots) if roots else set()

    print(f"{a.model}: {len(d)} bytes (0x{len(d):X})")
    print(f"  chain head : 0x{head:X}" + ("   (auto-detected)" if auto else ""))
    print(f"  fixups     : {len(nodes)}")
    if a.footer:
        print(f"  footer     : DObjDesc 0x{fr.dobjdesc:X}" + (
            f", p_mobjsubs 0x{fr.pmobjsubs:X}" if fr.pmobjsubs is not None else ""))
    print(f"\n  OBJECTS ({len(objs)}):")
    for i, o in enumerate(objs):
        tag = ""
        if roots:
            near = any(o.start <= r < o.end for r in roots)
            tag = "  <- footer" if near else "  (orphan)" if \
                ge.region_of(bounds, o.start)[0] not in reach else ""
        print(f"    #{i}  0x{o.start:04X}..0x{o.end:04X}  entries={o.ids}{tag}")
    print(f"\n  TEXTURES ({len(texs)}):")
    for t in texs:
        print(f"    0x{t['off']:06X}  {_tex_label(t):<16} {t['region_bytes']:>5} B"
              + (f"  tlut 0x{t['tlut']['off']:X}"
                 if t.get("tlut") else ""))
    if len(objs) > 1 and not a.footer:
        print("\n  -> multi-object file; `strip ... --keep-object N` to isolate one.")


# -------------------------------------------------------------------- strip ---
def _run_strip(model, head, roots, drop, apply, extra_map, footer_path):
    d = Path(model).read_bytes()
    res = ge.gc(d, roots, drop=drop, head=head)
    for line in res.report:
        print("  " + line)

    old_nodes = ge.walk_chain(d, head)
    old_tex = ge.find_textures(d, nodes=old_nodes)

    print("\nCONNECT THE DOTS  (old -> new; update these by hand)")
    same = " (unchanged)" if res.new_head == head else ""
    print(f"  config.yaml  files: table offset      0x{head:X} -> "
          f"0x{res.new_head:X}{same}")

    objs = ge.find_objects(d)
    for i, o in enumerate(objs):
        nn = res.remap.get(o.start)
        if nn is not None:
            print(f"  object #{i} DObjDesc (point a hitbox here)  "
                  f"0x{o.start:X} -> 0x{nn:X}")

    fr = None
    if footer_path:
        fr = ge.footer_roots(Path(footer_path).read_bytes())
        nd = res.remap.get(fr.dobjdesc)
        print(f"  {Path(footer_path).name}  DObjDesc (gfx addr)  "
              f"0x{fr.dobjdesc:X} -> " + (f"0x{nd:X}" if nd is not None else "DROPPED!"))
        if fr.pmobjsubs is not None:
            npm = res.remap.get(fr.pmobjsubs)
            print(f"  {Path(footer_path).name}  p_mobjsubs          "
                  f"0x{fr.pmobjsubs:X} -> "
                  + (f"0x{npm:X}" if npm is not None else "DROPPED!"))

    if old_tex:
        print("  textures / TLUTs:")
        for t in old_tex:
            nn = res.remap.get(t["off"])
            arrow = f"0x{nn:X}" if nn is not None else "dropped"
            print(f"      0x{t['off']:06X} {_tex_label(t):<15} -> {arrow}")

    if extra_map:
        print("  --map offsets:")
        for x in extra_map:
            nn = res.remap.get(x)
            print(f"      0x{x:X} -> " + (f"0x{nn:X}" if nn is not None else "dropped"))

    if apply:
        bak = Path(model).with_suffix(".bin.orig")
        if not bak.exists():
            bak.write_bytes(d)
        Path(model).write_bytes(res.data)
        msg = f"\nWROTE {model} ({res.new_len} bytes)"
        if footer_path and fr is not None:
            fb = bytearray(Path(footer_path).read_bytes())
            nd = res.remap.get(fr.dobjdesc)
            if nd is None:
                sys.exit("footer DObjDesc was dropped - aborting footer write")
            ge.w16(fb, fr.dd_node + 2, nd // 4)
            if fr.pm_node is not None and res.remap.get(fr.pmobjsubs) is not None:
                ge.w16(fb, fr.pm_node + 2, res.remap[fr.pmobjsubs] // 4)
            fbak = Path(footer_path).with_suffix(".bin.orig")
            if not fbak.exists():
                fbak.write_bytes(Path(footer_path).read_bytes())
            Path(footer_path).write_bytes(fb)
            msg += f"  + {footer_path}"
        print(msg)
    else:
        print("\n(dry run - pass --apply to write)")
    return res


def cmd_strip(a):
    d = Path(a.model).read_bytes()
    head, _ = _resolve_head(d, a.table)
    drop = [tuple(int(v, 0) for v in s.split(":")) for s in a.drop]
    extra = [int(x, 0) for x in a.map]

    roots = []
    footer_path = a.footer
    if a.footer:
        fr = ge.footer_roots(Path(a.footer).read_bytes())
        roots = [x for x in (fr.dobjdesc, fr.pmobjsubs) if x is not None]
    if a.root is not None:
        roots.append(int(a.root, 0))
    if a.keep_object is not None:
        objs = ge.find_objects(d)
        if not 0 <= a.keep_object < len(objs):
            sys.exit(f"--keep-object {a.keep_object}: file has {len(objs)} objects")
        roots.append(objs[a.keep_object].start)
    if not roots:
        sys.exit("nothing to keep - pass --footer, --root or --keep-object")

    _run_strip(a.model, head, roots, drop, a.apply, extra, footer_path)


# ---------------------------------------------------------------- translate ---
def cmd_translate(a):
    old = Path(a.old).read_bytes()
    new = Path(a.new).read_bytes()
    oh, _ = _resolve_head(old, a.table)
    nh = ge.find_chain_head(new) if a.new_table in (None, "auto") \
        else int(a.new_table, 0)
    print(f"{a.old} head 0x{oh:X}  ->  {a.new} head 0x{nh:X}")
    try:
        bp = ge.chain_breakpoints(old, oh, new, nh)
    except ValueError as e:
        sys.exit(f"can't auto-pair: {e}")
    print(f"shift breakpoints: " + ", ".join(
        f"@0x{o:X}:{'+' if d >= 0 else ''}{d:#x}" for o, d in bp))
    print("\n  old -> new")
    for x in a.offsets:
        xi = int(x, 0)
        print(f"    0x{xi:X} -> 0x{ge.translate(xi, bp):X}")


# ---------------------------------------------------------------------- main ---
def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    pl = sub.add_parser("list", help="show objects / textures / chain head")
    pl.add_argument("model")
    pl.add_argument("--table", default="auto")
    pl.add_argument("--footer", default=None)
    pl.set_defaults(fn=cmd_list)

    ps = sub.add_parser("strip", help="GC to one object + print new offsets")
    ps.add_argument("model")
    ps.add_argument("--table", default="auto")
    ps.add_argument("--footer", default=None)
    ps.add_argument("--root", default=None)
    ps.add_argument("--keep-object", type=int, default=None)
    ps.add_argument("--drop", nargs="*", default=[], metavar="A:B")
    ps.add_argument("--map", nargs="*", default=[], metavar="0xNNN")
    ps.add_argument("--apply", action="store_true")
    ps.set_defaults(fn=cmd_strip)

    pt = sub.add_parser("translate", help="map old offsets onto a re-exported bin")
    pt.add_argument("old")
    pt.add_argument("new")
    pt.add_argument("offsets", nargs="+", metavar="0xNNN")
    pt.add_argument("--table", default="auto")
    pt.add_argument("--new-table", default="auto")
    pt.set_defaults(fn=cmd_translate)

    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
