#!/usr/bin/env python3
"""
Extract a single self-contained "group" (e.g. the bomb model, group 3) out
of a GoldenEye-Setup-Editor-exported multi-group item file (like Link's
Entry, which bundles 4 groups -- 3 that reference shared/external ROM data
via GE's ROMReference addressing and are meaningless standalone, plus one
self-contained group using FileReferenceShort addressing).

How this works: the file's self-relocation chain (same format as
projectile gfx.bin -- see projectile_bin_annotator.py's module docstring)
already exposes every pointer field in the file regardless of which
higher-level GE struct (ModelParts/Tracks/etc.) owns it. So instead of
needing to reverse-engineer those struct layouts, this just needs a
boundary offset B such that:
  - every node with field_addr < B has target < B (nothing in the group
    being discarded points forward into the group being kept -- if it
    does, B needs to move to include that shared data, or the discarded
    group isn't cleanly separable from the kept one)
  - no node with field_addr >= B has a target that would break the
    kept group's own internal consistency once rebased

Confirmed empirically for extra_characters testing data (see
projectile_bin_annotator.py's session history) that Link's Entry's group 3
(the bomb) is a clean tail from such a boundary: nothing in that region
references back into groups 0-2, though groups 0-2 do reference some
shared texture data that happens to physically live past the boundary too
(harmless extra bytes in the extraction -- can be cleaned up by a second
reachability pass the same way projectile_builder.py strips dead trailing
data, not yet automated here).

The boundary itself isn't auto-detected -- find it by reading the GE
Setup Editor's exported .txt dump for the file (look for the last
"Extra Header N Type ModelParts" line; its group's Vertices/Indices
range start is usually the true payload start, which can sit earlier in
the file than the header struct itself references it from). Then verify
it with check-boundary before extracting.

Usage:
    python3 scripts/item_bin_extractor.py check-boundary <file.bin> <boundary_hex> [--table-offset 0x16C]
    python3 scripts/item_bin_extractor.py extract <file.bin> <boundary_hex> <output.bin> [--table-offset 0x16C]
"""

import argparse
import struct
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from projectile_bin_annotator import walk_chain  # noqa: E402


def check_boundary(data, table_offset, boundary):
    """Check whether `boundary` is a safe cut point for extract_tail: every
    kept node (field_addr >= boundary) must NOT target back into the
    discarded head (< boundary), or the extracted group would be missing
    data it actually needs. Note this must be checked against the ACTUAL
    intended boundary, not scanned blindly across all offsets -- internal
    forward references within the kept region can make an arbitrary B
    look "unclean" even when the true group boundary is fine, since a
    node's own target can legitimately sit earlier in the file than some
    other, later B still inside the same group.

    Returns (tail_to_head_crossings, head_to_tail_crossings). The first
    list must be empty for `boundary` to be usable with extract_tail; the
    second is informational only (shared data the discarded head also
    references -- harmless to leave behind in the extraction).
    """
    nodes = walk_chain(data, table_offset)
    tail_to_head = [(f, t) for f, _, tw, t in nodes if f >= boundary and tw != 0 and t < boundary]
    head_to_tail = [(f, t) for f, _, tw, t in nodes if f < boundary and tw != 0 and t >= boundary]
    return tail_to_head, head_to_tail


def find_dead_prefix_boundary(data, table_offset):
    """Auto-detect a safe extract_tail boundary for files that just need
    their unreferenced leading garbage stripped -- no manual GE Setup
    Editor dump needed, unlike the boundary for the initial cut out of a
    multi-group source file (which genuinely requires knowing where the
    wanted group starts, since several groups can be independently
    self-consistent).

    The boundary is the earliest byte anything in the chain actually
    points to, capped at table_offset itself (the table's own fields
    can't be trimmed into, or the chain would lose its start). Everything
    before this boundary is unreferenced by construction, so it's always
    a safe cut -- no check_boundary call needed to confirm it afterward.

    Confirmed empirically: several extra character projectile gfx bins are
    independent copies of the exact same half-cleaned extraction out of
    Link's Entry file (same size 0xDD8, table_offset 0x404, min_target
    0x408) -- the 0x000-0x403 dead prefix in all of them is leftover data
    from Link's up-B trail graphic, never touched by the second cleanup
    pass that should have stripped it after the original group-boundary
    extraction.
    """
    nodes = walk_chain(data, table_offset)
    live_targets = [t for _, _, tw, t in nodes if tw != 0]
    return min([table_offset] + live_targets)


def extract_tail(data, table_offset, boundary):
    """Keep only data[boundary:], rebasing every chain node so the result
    is a standalone, correctly self-relocating file starting fresh at its
    own offset 0. Nodes entirely before `boundary` are dropped along with
    their bytes. Any node before `boundary` whose target lands at/past it
    (shared data, e.g. textures groups 0-2 also reference) is left as
    inaccessible dead weight in the extracted file rather than an error --
    check find_candidate_boundaries's crosses_in report first to know if
    that applies.

    Returns (new_data, new_table_offset).
    """
    nodes = walk_chain(data, table_offset)
    kept = [n for n in nodes if n[0] >= boundary]
    if not kept:
        sys.exit(f"ERROR: no chain nodes at or past boundary 0x{boundary:04X}")

    new_data = bytearray(data[boundary:])

    def rebase(addr):
        return addr - boundary

    for field_addr, next_raw, target_word, target_addr in kept:
        new_field_addr = rebase(field_addr)
        new_next_raw = 0xFFFF if next_raw == 0xFFFF else rebase(next_raw * 4) // 4
        new_target_word = 0 if target_word == 0 else rebase(target_addr) // 4
        struct.pack_into(">HH", new_data, new_field_addr, new_next_raw, new_target_word)

    new_table_offset = rebase(kept[0][0])
    return bytes(new_data), new_table_offset


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_find = sub.add_parser("check-boundary", help="Verify a candidate boundary is a safe cut point")
    p_find.add_argument("file")
    p_find.add_argument("boundary", help="Hex offset, e.g. 0xD90")
    p_find.add_argument("--table-offset", default="0x16C")

    p_ex = sub.add_parser("extract", help="Extract data[boundary:] as a standalone rebased file")
    p_ex.add_argument("file")
    p_ex.add_argument("boundary", help="Hex offset, e.g. 0xD90")
    p_ex.add_argument("output")
    p_ex.add_argument("--table-offset", default="0x16C")

    p_clean = sub.add_parser(
        "clean",
        help="Auto-detect and strip an already-extracted file's dead unreferenced prefix "
             "(no manual boundary needed - works directly on half-cleaned files)")
    p_clean.add_argument("file")
    p_clean.add_argument("output")
    p_clean.add_argument("--table-offset", default="0x16C")

    args = parser.parse_args()
    data = open(args.file, "rb").read()
    table_offset = int(args.table_offset, 16)

    if args.cmd == "check-boundary":
        boundary = int(args.boundary, 16)
        tail_to_head, head_to_tail = check_boundary(data, table_offset, boundary)
        if tail_to_head:
            print(f"UNSAFE: {len(tail_to_head)} node(s) past the boundary reference back "
                  f"into the discarded head -- boundary is inside the group, not before it:")
            for f, t in tail_to_head:
                print(f"  field 0x{f:04X} -> target 0x{t:04X}")
        else:
            print(f"OK: no node past 0x{boundary:04X} references before it")
        if head_to_tail:
            print(f"Note: {len(head_to_tail)} node(s) before the boundary reference into the "
                  f"kept region (shared data, e.g. textures) -- harmless dead weight, kept anyway:")
            for f, t in head_to_tail:
                print(f"  field 0x{f:04X} -> target 0x{t:04X}")
    elif args.cmd == "extract":
        boundary = int(args.boundary, 16)
        new_data, new_table_offset = extract_tail(data, table_offset, boundary)
        with open(args.output, "wb") as f:
            f.write(new_data)
        print(f"Wrote {args.output}: {len(new_data)} bytes, "
              f"new table_offset=0x{new_table_offset:X}")
    elif args.cmd == "clean":
        boundary = find_dead_prefix_boundary(data, table_offset)
        if boundary == 0:
            print("Nothing to clean -- no dead prefix found (already starts at a referenced byte)")
            return
        new_data, new_table_offset = extract_tail(data, table_offset, boundary)
        with open(args.output, "wb") as f:
            f.write(new_data)
        print(f"Detected dead prefix: 0x0-0x{boundary - 1:04X} ({boundary} bytes)")
        print(f"Wrote {args.output}: {len(new_data)} bytes, "
              f"new table_offset=0x{new_table_offset:X}")


if __name__ == "__main__":
    sys.exit(main())
