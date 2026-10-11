#!/usr/bin/env python3
"""
stage_collision.py - decode the map-collision ("clip" / yakumono) data in an
SSB64 stage.bin.

The stage file is a GoldEditor self-relocating .bin (fixup chain -> see ge_bin).
Somewhere in it sits an `MPGeometryData` struct that the engine reads at load
(`mpCollisionInitGroundData`):

    MPGeometryData  (7 words)
      +0x00  u16 yakumono_count          # of collision GROUPS (ids run 1..count)
      +0x04  MPVertexData   *vertex_data   {s16 x, s16 y, u16 flags} x N
      +0x08  u16            *vertex_id     flat list of vertex indices, per line
      +0x0C  MPVertexLinks  *vertex_links  {u16 first_id_index, u16 vertex_count} per LINE
      +0x10  MPLineInfo     *line_info     one per group (see below)
      +0x14  u16 mapobj_count
      +0x18  MPMapObjData   *mapobjs       {u16 kind, s16 x, s16 y} x M

    MPLineInfo  (18 bytes, one per group, in group order 1..count)
      +0x00  u16 yakumono_id              the group id (what GE calls "group N")
      +0x02  MPLineData line_data[4]      one per line TYPE: floor, ceil, rwall, lwall
               MPLineData { u16 first_line_id ; u16 line_count }

    line -> vertex_links[line_id] = {first, cnt}; its vertices are
            vertex_data[ vertex_id[first .. first+cnt-1] ].
    vertex flags: bit15 (0x8000) grab-able ledge, bit14 (0x4000) drop-through,
                  low byte = material index.

The engine's yakumono DObj array is indexed by DObjDesc-entry order of the
COLLISION geometry layer (`gr_desc[1]`), entry 0 = base, entries 1.. = the
groups -> so **GE "collision group N" == engine yakumono index N** (1-indexed).

    stage_collision.py STAGE.bin [--geom 0xNNN] [--table 0xNNN]  # decode + dump
    stage_collision.py STAGE.bin --emit-yaml                     # -> config.yaml collision: list
    stage_collision.py STAGE.bin --build SPEC.yaml [--header H]  # rewrite STAGE from a spec
                                                                #   (max 6 groups)
    stage_collision.py STAGE.bin --rebirth X,Y                   # move the rebirth platform

The rewrite (also run by the appender for a stage config.yaml `collision:` key)
lives in smashremix_extra/stage/collision.py: it rebuilds the 5 arrays, APPENDS
them, and repoints the self-relocating pointers - header.bin is untouched.
"""
import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))  # -> appender/
from smashremix_extra import ge_bin as ge  # noqa: E402

LINE_TYPE = ["floor", "ceil", "rwall", "lwall"]
MAPOBJ_KIND = {
    0x00: "P1 start", 0x01: "P2 start", 0x02: "P3 start", 0x03: "P4 start",
    0x04: "item spawn", 0x05: "scale L", 0x06: "scale R", 0x07: "pakkun L",
    0x08: "pakkun R", 0x09: "power block", 0x0A: "pipe L", 0x0B: "pipe R",
    0x0C: "acid", 0x0D: "twister", 0x0E: "monster",
    0x13: "bumper", 0x14: "pipe wall",
    0x15: "movie player 1", 0x16: "movie player 2", 0x17: "movie player 3",
    0x18: "demo P1", 0x19: "demo P2", 0x1A: "demo P3", 0x1B: "demo P4",
    0x1C: "demo P5", 0x1D: "demo P6", 0x1E: "demo P7", 0x1F: "demo P8",
    0x20: "rebirth platform", 0x21: "1P player",
    0x22: "1P ally 1", 0x23: "1P ally 2", 0x24: "1P ally 3",
    0x25: "1P enemy 1", 0x26: "1P enemy 2", 0x27: "1P enemy 3", 0x28: "1P enemy 4",
    0x29: "bonus3 taru bomb", 0x2B: "1P enemy team", 0x2C: "challenger player",
}


def s16(d, o): return struct.unpack_from(">h", d, o)[0]
def u16(d, o): return struct.unpack_from(">H", d, o)[0]
def u32(d, o): return struct.unpack_from(">I", d, o)[0]


def reloc(word):
    """a fixup field still in [next|data] form -> the data offset it points at."""
    return (word & 0xFFFF) * 4


def find_geometry(d, nodes):
    """MPGeometryData = u16 count, then 4 consecutive fixup-pointer fields at
    +0x04/+0x08/+0x0C/+0x10 whose targets ascend, then u16 + 1 more pointer at
    +0x18. Scan the fixup fields for that shape."""
    fields = sorted(n.field for n in nodes)
    fset = set(fields)
    for base in range(0, len(d) - 0x1C, 4):
        if not all((base + off) in fset for off in (0x04, 0x08, 0x0C, 0x10, 0x18)):
            continue
        t = [reloc(u32(d, base + off)) for off in (0x04, 0x08, 0x0C, 0x10)]
        if not (t[0] < t[1] < t[2] < t[3]):
            continue
        cnt = u16(d, base)
        if 1 <= cnt <= 32:
            return base
    return None


def _emit_yaml(d, verts, vid, links, p_lni, yk_count):
    """Print the decoded geometry as a config.yaml `collision:` list."""
    types = ["floor", "ceil", "rwall", "lwall"]
    print("collision:")
    for g in range(yk_count):
        o = p_lni + g * 18
        gid = u16(d, o)
        for lt in range(4):
            first = u16(d, o + 2 + lt * 4)
            cnt = u16(d, o + 4 + lt * 4)
            for ln in range(first, first + cnt):
                f, c = links[ln]
                flat = [v for k in range(f, f + c) for v in verts[vid[k]][:2]]
                fl = verts[vid[f]][2]
                names = []
                if fl & 0x4000:
                    names.append("drop_through")
                if fl & 0x8000:
                    names.append("ledge")
                if fl & 0xFF:
                    names.append(str(fl & 0xFF))
                tail = f", flags: [{', '.join(names)}]" if names else ""
                print(f"  - {{group: {gid}, {types[lt]}: {flat}{tail}}}")


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("stage")
    ap.add_argument("--table", type=lambda x: int(x, 0), default=None,
                    help="fixup chain head (default: auto)")
    ap.add_argument("--geom", type=lambda x: int(x, 0), default=None,
                    help="MPGeometryData offset (default: auto-detect)")
    ap.add_argument("--emit-yaml", action="store_true",
                    help="print the decoded geometry as a config.yaml `collision:` block")
    ap.add_argument("--build", metavar="SPEC.yaml",
                    help="apply a `collision:` spec (a full config.yaml, or just "
                         "the collision block) and rewrite STAGE in place")
    ap.add_argument("--header", metavar="header.bin",
                    help="with --draw: read blast zones / camera bounds / light")
    ap.add_argument("--gd", type=lambda x: int(x, 0), default=0x14,
                    help="MPGroundData offset in --header (default 0x14)")
    ap.add_argument("--draw", metavar="OUT.png",
                    help="draw a top-down layout diagram (collision by group, "
                         "blast zones, camera bounds, map objects)")
    ap.add_argument("--rebirth", metavar="X,Y",
                    help="move the rebirth (revival) platform - the kind-0x20 "
                         "map object - to X,Y")
    a = ap.parse_args()

    d = Path(a.stage).read_bytes()
    head = a.table if a.table is not None else ge.find_chain_head(d)
    if head is None:
        sys.exit("could not find the fixup chain - pass --table")

    if a.draw:
        from smashremix_extra.stage import draw
        hdr = a.header or str(Path(a.stage).with_name("header.bin"))
        draw.render_files(a.stage, hdr, a.draw, chain_head=head, groupdata_off=a.gd)
        print(f"wrote {a.draw}")
        return

    if a.rebirth:
        from smashremix_extra.stage import collision
        x, y = (int(v) for v in a.rebirth.split(","))
        collision.set_rebirth(a.stage, head, x, y)
        print(f"{a.stage}: rebirth platform -> ({x}, {y})")
        return

    if a.build:
        import yaml
        from smashremix_extra.stage import collision
        spec = yaml.safe_load(Path(a.build).read_text())
        if isinstance(spec, dict) and "collision" in spec:
            spec = spec["collision"]
        info = collision.apply(a.stage, spec, head,
                               header_path=a.header,
                               groupdata_off=a.gd if a.header else None)
        print(f"{a.stage}: {info}")
        return

    nodes = ge.walk_chain(d, head)

    geom = a.geom if a.geom is not None else find_geometry(d, nodes)
    if geom is None:
        sys.exit("could not locate MPGeometryData - pass --geom 0xNNN")

    yk_count = u16(d, geom)
    p_vtx = reloc(u32(d, geom + 0x04))
    p_vid = reloc(u32(d, geom + 0x08))
    p_lnk = reloc(u32(d, geom + 0x0C))
    p_lni = reloc(u32(d, geom + 0x10))
    mo_count = u16(d, geom + 0x14)
    p_mo = reloc(u32(d, geom + 0x18))

    print(f"{a.stage}: {len(d)} bytes, chain head 0x{head:X}")
    print(f"MPGeometryData @ 0x{geom:X}")
    print(f"  yakumono_count : {yk_count}   (GE 'collision groups'; ids 1..{yk_count})")
    print(f"  vertex_data    : 0x{p_vtx:X}")
    print(f"  vertex_id      : 0x{p_vid:X}")
    print(f"  vertex_links   : 0x{p_lnk:X}")
    print(f"  line_info      : 0x{p_lni:X}")
    print(f"  mapobjs        : 0x{p_mo:X}   ({mo_count})")

    # --- vertices (bounded by the next thing that is pointed at) ---
    tgts = sorted(set(n.target for n in nodes) | {len(d)})
    v_end = next(t for t in tgts if t > p_vtx)
    nv = (v_end - p_vtx) // 6
    verts = [(s16(d, p_vtx + i * 6), s16(d, p_vtx + i * 6 + 2),
              u16(d, p_vtx + i * 6 + 4)) for i in range(nv)]

    vid_end = next(t for t in tgts if t > p_vid)
    vid = [u16(d, p_vid + i * 2) for i in range((vid_end - p_vid) // 2)]

    lnk_end = next(t for t in tgts if t > p_lnk)
    links = [(u16(d, p_lnk + i * 4), u16(d, p_lnk + i * 4 + 2))
             for i in range((lnk_end - p_lnk) // 4)]

    if a.emit_yaml:
        _emit_yaml(d, verts, vid, links, p_lni, yk_count)
        return

    def vflags(f):
        parts = []
        if f & 0x8000:
            parts.append("ledge")
        if f & 0x4000:
            parts.append("drop-thru")
        mat = f & 0xFF
        if mat:
            parts.append(f"mat{mat}")
        return ",".join(parts) or "solid"

    def line_pts(line_id):
        first, cnt = links[line_id]
        idxs = vid[first:first + cnt]
        return [(verts[i][0], verts[i][1], verts[i][2]) for i in idxs if i < len(verts)]

    print(f"\nVERTICES ({nv}) @ 0x{p_vtx:X}")
    for i, (x, y, f) in enumerate(verts):
        print(f"  [{i:2}] ({x:6},{y:6})  {vflags(f)}")

    print(f"\nLINES (via vertex_links, {len(links)}) @ 0x{p_lnk:X}")
    for i, (first, cnt) in enumerate(links):
        pts = line_pts(i)
        s = " -> ".join(f"({x},{y})" for x, y, _ in pts)
        fl = pts[0][2] if pts else 0
        print(f"  line {i:2}: {s}   [{vflags(fl)}]")

    print(f"\nGROUPS / line_info ({yk_count}) @ 0x{p_lni:X}")
    for g in range(yk_count):
        o = p_lni + g * 18
        yid = u16(d, o)
        print(f"  group #{yid}  (GE 'collision group {yid}')")
        for lt in range(4):
            first = u16(d, o + 2 + lt * 4)
            cnt = u16(d, o + 4 + lt * 4)
            if cnt == 0:
                continue
            for ln in range(first, first + cnt):
                pts = line_pts(ln) if ln < len(links) else []
                s = " -> ".join(f"({x},{y})" for x, y, _ in pts)
                fl = pts[0][2] if pts else 0
                print(f"      {LINE_TYPE[lt]:5} line {ln:2}: {s}   [{vflags(fl)}]")

    print(f"\nMAP OBJECTS ({mo_count}) @ 0x{p_mo:X}")
    for i in range(mo_count):
        o = p_mo + i * 6
        k = u16(d, o)
        print(f"  [{i:2}] kind 0x{k:02X} {MAPOBJ_KIND.get(k, '?'):<18} "
              f"({s16(d, o + 2):6},{s16(d, o + 4):6})")

    # --- FYI: the engine links lines only where they share the SAME vertex
    #     index. Disconnected groups / lone endpoints are fine on a stage; this
    #     is just a note of where vertices coincide by position but not index.
    dupes = {}
    for i, (x, y, _) in enumerate(verts):
        dupes.setdefault((x, y), []).append(i)
    dupes = {p: ix for p, ix in dupes.items() if len(ix) > 1}
    if dupes:
        print("\ncoincident vertices (same position, separate index):")
        for (x, y), ix in sorted(dupes.items()):
            print(f"     ({x},{y}): indices {ix}")


if __name__ == "__main__":
    main()
