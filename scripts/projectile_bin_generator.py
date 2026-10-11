#!/usr/bin/env python3
"""
Template-based generator/editor for extra-character projectile "gfx" and
"hitbox" bin files (e.g. templates/shuriken_projectile/shuriken_gfx.bin /
shuriken_hitbox.bin).

Scope (deliberately conservative): this does NOT build these files from
scratch. The pointer/relocation-chain plumbing (see
scripts/projectile_bin_annotator.py for how that's structured) and the
display list / sprite pixel data are copied byte-for-byte from an existing
working template file. Only the parts of the format that have been fully
reverse-engineered and validated against decomp source are edited:

  - hitbox.bin (WPAttributes, src/wp/wptypes.h): all the gameplay stat
    bitfields (damage, angle, knockback, size, element, flags, ...),
    attack_offsets, and the map-collision box. Bit-packing verified by
    diffing an extra-character hitbox.bin against decomp's
    dMarioSpecial1_Fireball_WeaponAttributes (near-exact match).

  - gfx.bin: the 16-color palette (@0x30) and the per-frame *hold
    duration* of the texture-ID animation script (frame values themselves
    stay 0.0, 1.0, 2.0, ... in sequence -- only how long each frame is
    held is editable, and only for a template that already has the same
    number of frames).

To reskin a projectile's sprite art itself (the actual CI4 pixel data),
you currently need to hand-edit the frame offsets reported by
projectile_bin_annotator.py's `gfx` command -- that isn't covered here yet.

Usage:
    python3 scripts/projectile_bin_generator.py hitbox --template templates/shuriken_projectile/shuriken_hitbox.bin --out new_hitbox.bin --damage 12 --angle 45
    python3 scripts/projectile_bin_generator.py gfx --template templates/shuriken_projectile/shuriken_gfx.bin --out new_gfx.bin --frame-waits 0,4,4,2
    python3 scripts/projectile_bin_generator.py gfx --template templates/shuriken_projectile/shuriken_gfx.bin --out new_gfx.bin --palette F800,07E0,001F,...(16 hex RGBA5551 values)
"""

import argparse
import struct
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from projectile_bin_annotator import (  # noqa: E402
    walk_chain, decode_wpattributes_bitfields, try_decode_matanim_script, u16,
)

# ---------------------------------------------------------------------------
# hitbox.bin (WPAttributes)
# ---------------------------------------------------------------------------

BITFIELD_LAYOUT = [
    # (name, width, signed, which_word)
    ("size", 16, False, 0), ("angle", 10, True, 0),
    ("knockback_scale", 10, False, 1), ("damage", 8, False, 1),
    ("element", 4, False, 1), ("knockback_weight", 10, False, 1),
    ("shield_damage", 8, True, 2), ("attack_count", 2, False, 2),
    ("can_setoff", 1, False, 2), ("sfx", 10, False, 2),
    ("priority", 3, False, 2), ("can_rehit_item", 1, False, 2),
    ("can_rehit_fighter", 1, False, 2), ("can_hop", 1, False, 2),
    ("can_reflect", 1, False, 2), ("can_absorb", 1, False, 2),
    ("can_shield", 1, False, 2), ("unused_0x2F_b6", 1, False, 2),
    ("unused_0x2F_b7", 1, False, 3), ("knockback_base", 10, False, 3),
]


def encode_wpattributes_bitfields(fields):
    """Inverse of decode_wpattributes_bitfields: pack a field dict back into
    the 4 raw 32-bit words (0x24-0x34) using the validated MSB-first,
    overflow-only packing model."""
    words = [0, 0, 0, 0]
    bitpos = [0, 0, 0, 0]
    for name, width, signed, word_idx in BITFIELD_LAYOUT:
        val = fields[name]
        if signed and val < 0:
            val &= (1 << width) - 1
        mask = (1 << width) - 1
        words[word_idx] = (words[word_idx] << width) | (val & mask)
        bitpos[word_idx] += width
    # Left-align each word's accumulated bits (we appended MSB-first already,
    # just need to shift the whole word up so the last field ends before
    # any trailing padding rather than at bit 0).
    for i in range(4):
        words[i] <<= (32 - bitpos[i])
    return b"".join(struct.pack(">I", w) for w in words)


# The 4 pointer/chain fields (0x00-0x0F) of WPAttributes are tied to the
# *gfx file's own internal layout*, not to any per-projectile stat -- as
# long as every gfx.bin is built on BASE_PROJECTILE_GFX (see
# projectile_builder.py), this exact byte sequence is the correct "data /
# p_mobjsubs / anim_joints(unused) / p_matanim_joints" chain prefix for
# every hitbox.bin, with no template file needed. Lifted byte-for-byte
# from an existing extra-character <projectile>_hitbox.bin.
DEFAULT_POINTER_PREFIX = bytes.fromhex("0001006a0003003600000000ffff0016")
DEFAULT_ATTACK_OFFSETS = [(0, 0, 0), (0, 0, 0)]
DEFAULT_MAP_COLL = (50, 0, -50, 50)


def build_hitbox_from_fields(out_path, fields, offsets=None, map_coll=None,
                              pointer_prefix=DEFAULT_POINTER_PREFIX):
    """Build a WPAttributes hitbox.bin purely from declared values -- no
    template file. `fields` must have every name in BITFIELD_LAYOUT."""
    data = bytearray(64)
    data[0x00:0x10] = pointer_prefix
    for i, (x, y, z) in enumerate(offsets or DEFAULT_ATTACK_OFFSETS):
        data[0x10 + i * 6:0x16 + i * 6] = struct.pack(">hhh", x, y, z)
    top, center, bottom, width = map_coll or DEFAULT_MAP_COLL
    data[0x1C:0x24] = struct.pack(">hhhh", top, center, bottom, width)
    data[0x24:0x34] = encode_wpattributes_bitfields(fields)

    with open(out_path, "wb") as f:
        f.write(data)
    print(f"Wrote {out_path} (64 bytes, no template)")
    print("Final stats:")
    for name, _, _, _ in BITFIELD_LAYOUT:
        print(f"  {name:18} = {fields[name]}")


def build_hitbox(template_path, out_path, overrides, offsets=None, map_coll=None):
    data = bytearray(open(template_path, "rb").read())
    if len(data) != 64:
        print(f"WARNING: template is {len(data)} bytes, expected 64 for WPAttributes", file=sys.stderr)

    fields = decode_wpattributes_bitfields(bytes(data))
    for k, v in overrides.items():
        if v is not None:
            fields[k] = v
    packed = encode_wpattributes_bitfields(fields)
    data[0x24:0x34] = packed

    if offsets:
        for i, (x, y, z) in enumerate(offsets):
            if x is None:
                continue
            off = 0x10 + i * 6
            data[off:off + 6] = struct.pack(">hhh", x, y, z)

    if map_coll:
        top, center, bottom, width = map_coll
        vals = [top, center, bottom, width]
        for i, v in enumerate(vals):
            if v is not None:
                off = 0x1C + i * 2
                data[off:off + 2] = struct.pack(">h", v)

    with open(out_path, "wb") as f:
        f.write(data)
    print(f"Wrote {out_path} ({len(data)} bytes)")
    print("Final stats:")
    for name, _, _, _ in BITFIELD_LAYOUT:
        print(f"  {name:18} = {fields[name]}")


# ---------------------------------------------------------------------------
# gfx.bin (palette + MatAnim frame-hold-duration editing)
# ---------------------------------------------------------------------------

def find_matanim_script_offset(data, table_offset):
    """Auto-locate the (first) real MatAnim TEXID script via the chain,
    same heuristic as the annotator but requiring >1 real command so we
    skip trivial all-zero false positives."""
    nodes = walk_chain(data, table_offset)
    seen = set()
    for _, _, target_word, target_addr in nodes:
        if target_word == 0 or target_addr in seen:
            continue
        seen.add(target_addr)
        script = try_decode_matanim_script(data, target_addr)
        if script and len(script) > 1:
            return target_addr
    return None


def count_setval_frames(data, off):
    """Count consecutive SetValAfterBlock/SetValAfter (opcode 10/11) pairs
    starting at `off`. Stops at the first word that isn't one of those
    opcodes -- NOT at an explicit End marker, since these scripts appear to
    cycle back to their start implicitly (frame count is tracked by the
    owning struct, not a sentinel word in the stream)."""
    pos = off
    count = 0
    while pos + 8 <= len(data):
        word = int.from_bytes(data[pos:pos + 4], "big")
        opcode = (word >> 25) & 0x7F
        if opcode not in (10, 11):
            break
        count += 1
        pos += 8
    return count


def build_gfx(template_path, out_path, table_offset, palette=None, frame_waits=None):
    data = bytearray(open(template_path, "rb").read())

    if palette:
        if len(palette) != 16:
            sys.exit(f"ERROR: palette needs exactly 16 entries, got {len(palette)}")
        for i, val in enumerate(palette):
            struct.pack_into(">H", data, 0x30 + i * 2, val)
        print("Palette updated (16 entries @0x30).")

    if frame_waits is not None:
        off = find_matanim_script_offset(bytes(data), table_offset)
        if off is None:
            sys.exit("ERROR: could not locate an animation script in this template "
                      "(--frame-waits only works on multi-frame templates like fsmash_gfx.bin)")
        pos = off
        frame_idx = 0
        while frame_idx < len(frame_waits):
            word = int.from_bytes(data[pos:pos + 4], "big")
            opcode = (word >> 25) & 0x7F
            if opcode == 0:
                sys.exit(f"ERROR: template's animation script has fewer frames "
                          f"({frame_idx}) than --frame-waits ({len(frame_waits)})")
            flags = (word >> 15) & 0x3FF
            new_word = (opcode << 25) | (flags << 15) | (frame_waits[frame_idx] & 0x7FFF)
            data[pos:pos + 4] = struct.pack(">I", new_word)
            pos += 8  # skip the value word (frame index float stays unchanged)
            frame_idx += 1
        # Confirm the script ends where we expect (next word should be End)
        end_word = int.from_bytes(data[pos:pos + 4], "big")
        if end_word != 0:
            print(f"WARNING: expected End (0x00000000) after last edited frame "
                  f"at 0x{pos:04X}, found 0x{end_word:08X} -- template may have "
                  f"more frames than --frame-waits provided.", file=sys.stderr)
        print(f"Animation frame-hold durations updated ({len(frame_waits)} frames "
              f"@0x{off:04X}): {frame_waits}")

    with open(out_path, "wb") as f:
        f.write(data)
    print(f"Wrote {out_path} ({len(data)} bytes)")


def parse_offset(s):
    x, y, z = (int(v) for v in s.split(","))
    return x, y, z


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_hb = sub.add_parser("hitbox", help="Edit a WPAttributes hitbox.bin from a template")
    p_hb.add_argument("--template", required=True)
    p_hb.add_argument("--out", required=True)
    for name, _, _, _ in BITFIELD_LAYOUT:
        p_hb.add_argument(f"--{name.replace('_', '-')}", type=int, default=None)
    p_hb.add_argument("--offset0", type=parse_offset, default=None, help="attack_offsets[0] as x,y,z")
    p_hb.add_argument("--offset1", type=parse_offset, default=None, help="attack_offsets[1] as x,y,z")
    p_hb.add_argument("--map-coll-top", type=int, default=None)
    p_hb.add_argument("--map-coll-center", type=int, default=None)
    p_hb.add_argument("--map-coll-bottom", type=int, default=None)
    p_hb.add_argument("--map-coll-width", type=int, default=None)

    p_gfx = sub.add_parser("gfx", help="Edit palette / animation timing of a gfx.bin from a template")
    p_gfx.add_argument("--template", required=True)
    p_gfx.add_argument("--out", required=True)
    p_gfx.add_argument("--table-offset", default="0x58",
                        help="InternalFileTableOffsetBytes from config.yaml (default: 0x58)")
    p_gfx.add_argument("--palette", default=None,
                        help="16 comma-separated 4-hex-digit RGBA5551 values, e.g. F800,07E1,...")
    p_gfx.add_argument("--frame-waits", default=None,
                        help="Comma-separated hold-duration (in frames) per animation frame, "
                             "e.g. 0,4,4,2 -- count must match the template's existing frame count")

    args = parser.parse_args()

    if args.cmd == "hitbox":
        overrides = {name: getattr(args, name) for name, _, _, _ in BITFIELD_LAYOUT}
        offsets = None
        if args.offset0 or args.offset1:
            offsets = [args.offset0, args.offset1]
        map_coll = None
        if any(v is not None for v in (args.map_coll_top, args.map_coll_center,
                                        args.map_coll_bottom, args.map_coll_width)):
            map_coll = (args.map_coll_top, args.map_coll_center,
                        args.map_coll_bottom, args.map_coll_width)
        build_hitbox(args.template, args.out, overrides, offsets, map_coll)

    elif args.cmd == "gfx":
        palette = None
        if args.palette:
            palette = [int(v, 16) for v in args.palette.split(",")]
        frame_waits = None
        if args.frame_waits:
            frame_waits = [int(v) for v in args.frame_waits.split(",")]
        build_gfx(args.template, args.out, int(args.table_offset, 16), palette, frame_waits)


if __name__ == "__main__":
    sys.exit(main())
