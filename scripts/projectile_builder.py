#!/usr/bin/env python3
"""
YAML-driven builder for extra-character projectile gfx.bin + hitbox.bin.

Point it at a list of frame images and hitbox stats and it produces a
gfx.bin/hitbox.bin pair. Neither needs an external template file:
hitbox.bin is built purely from declared fields (see
build_hitbox_from_fields in projectile_bin_generator.py), and gfx.bin is
built from DEFAULT_GFX_BASE_BYTES, a fully-documented byte constant
inlined in this file (see its definition for the section-by-section
layout) rather than a separate binary asset -- every part of it is either
independently-verified-formula-driven (palette, sprite pixels, frame
count/dimensions via resize_frame_count + patch_block_load, animation
timing, vertex UV, hitbox pointer targets) or explicitly labeled as a
carried-over constant with its provenance noted.

Sized/shaped by resize_frame_count (see there) to whatever frame count
the spec's frames: list calls for -- growing or shrinking the
sprite-pointer array and animation script as needed, not just patching
values into a fixed-size structure.

Example YAML spec (see templates/shuriken_projectile/shuriken_projectile.yaml,
a runnable end-to-end example with a public 3-frame spinning shuriken sprite):

    output_gfx: templates/shuriken_projectile/shuriken_gfx.bin
    output_hitbox: templates/shuriken_projectile/shuriken_hitbox.bin

    frames:
      - templates/shuriken_projectile/shuriken1.bmp
      - templates/shuriken_projectile/shuriken2.bmp
      - templates/shuriken_projectile/shuriken3.bmp
    frame_wait: 2             # frames to hold each frame (or a per-frame list, e.g. [5, 1, 2] --
                              # frame_wait[k] is exactly how long image k is visible, no
                              # off-by-one to think about; the tool handles the underlying
                              # script's "wait applies to the previous step" quirk internally).

    hitbox:
      size: 200
      angle: 361
      knockback_scale: 25
      damage: 6
      element: 1
      knockback_weight: 0
      shield_damage: 1
      attack_count: 1
      can_setoff: 1
      sfx: 28
      priority: 1
      can_rehit_item: 1
      can_hop: 1
      can_reflect: 1
      can_absorb: 1
      can_shield: 1
      knockback_base: 20

gfx_template: is only needed to explicitly point at some OTHER existing
file as the starting structure (rare -- if output_gfx already exists it's
used automatically, and otherwise DEFAULT_GFX_BASE_BYTES already covers
1..N frames via resizing). If you do set it, also set table_offset:
-- see projectile_bin_annotator.py's `gfx` command to find the right
value for any given file (its InternalFileTableOffsetBytes).

Usage:
    python3 scripts/projectile_builder.py templates/shuriken_projectile/shuriken_projectile.yaml
"""

import argparse
import os
import struct
import sys

import yaml
from PIL import Image

SCRIPT_DIR = __file__.rsplit("/", 1)[0]
sys.path.insert(0, SCRIPT_DIR)
from projectile_bin_annotator import walk_chain, u16  # noqa: E402
from projectile_bin_generator import (  # noqa: E402
    BITFIELD_LAYOUT, DEFAULT_ATTACK_OFFSETS, DEFAULT_MAP_COLL, DEFAULT_POINTER_PREFIX,
    build_hitbox_from_fields,
)

# Built-in base gfx structure (header + MObj/MObjSub + animation script +
# sprite-pointer array + display list, 3-frame/32x32-native) used when a
# spec doesn't name its own gfx_template. This is data, not a mystery
# blob: every section below is exactly what scripts/projectile_bin_annotator.py
# decodes it as, and everything parametric (palette, sprite pixels, frame
# count, dimensions, animation timing, hitbox pointer targets) gets
# patched on top by build_gfx/resize_frame_count/patch_block_load -- all
# of which is understood and driven by verified formulas, not guesswork.
# What's IN this constant and NOT independently re-derived: the display
# list's fixed RDP setup bytes (render mode / combiner mode constants,
# 0x98/0xA0 below) and a handful of MObjSub "unk" fields confirmed (by
# diffing working files of different sizes) to be constant regardless of
# sprite dimensions -- see the field dump in the projectile_bin_annotator.py
# session history for provenance. This used to be a separate binary asset
# (assets/base_projectile_3frame_32x32.bin); it's inlined here instead so
# there's no opaque external file in the loop, only inspectable source.
#
# Layout (byte offsets from the start of this constant):
#   0x00-0x2F  header padding (never referenced by any pointer)
#   0x30-0x4F  palette, 16x RGBA5551 (overwritten per-build)
#   0x50-0x57  padding
#   0x58       self-relocation chain head (InternalFileTableOffsetBytes)
#   0x60-0x87  animation script: 4 SetValAfterBlock steps (frame 0,1,2,
#              loop-back-to-0) + a couple of chain-node pointer fields
#   0x88-0xBF  MObj fields (texture_id/palette_id/aobj/matanim_joint/etc.)
#   0xC0-0xCB  sprite-pointer array, 3 entries (targets 0x290/0x498/0x690)
#   0xD8-0xE7  more chain-node fields
#   0xE8-0x15F MObjSub struct (fmt/siz/sprites ptr/scale/palettes ptr/
#              block_fmt/block_dxt/colors/etc.)
#   0x160-0x1BF further MObjSub tail + chain fields
#   0x1C0-0x28F F3D display list (PipeSync/SetGeometryMode/SetTile x3/
#              SetImage/LoadPalette/SetCombiner/SetTileSize/LoadBlock/
#              Vtx/Tri2/EndDL -- sequence and static params cross-checked
#              against Mario FireballDisplayLists.txt)
#   0x168-0x1A7 (referenced from within the DL region) 4 Vtx entries:
#              x=0, y/z=+-150 (on-screen quad size, fixed regardless of
#              texture resolution), s/t UV scaled by frame dimensions
#   0x290+     sprite pixel data (3x 512-byte 32x32 CI4 slots, native;
#              zeroed here, replaced per-build -- appended below since
#              it's pure placeholder, not meaningfully "structure")
#
# The chain terminates cleanly at field@0x244 (0xFFFF) -- the original
# donor file (started life as a clone of Wolf's projectile) carried a
# whole second unused MObj/DL/sprite sub-object past this point; it's not
# included here at all rather than being stripped at build time.
_BASE_HEADER_AND_DL = bytes.fromhex(
    "0000000000000000dac0a181c249dacdf30bfd4bfe8f0003af44736db98eb9bf7bef7b000000"
    "00000000000000000000f1c01c6935f55e7da73df7bd0ba30000000000000000000000000000"
    "00000000000000000000000000210022000000001400800000000000140080023f8000001400"
    "80034000000014008001000000001c0000000022001800300018000000000000000000000000"
    "0000123363321100000001252232100000200000422110000041000152110000000004222200"
    "0000003100a400320126003601a8000000000000000000000000003700580038000c003b0002"
    "00000000000002020045003000200000001000100000000000000000000000003f8000003f80"
    "0000000000003f80000000580037000502000010001000100010000000000000000000000000"
    "0000000000002005ffffffff00000000000000ff00000000ffffff00ffffff00000000000000"
    "000000000000000000000091003a00000000000000960096000000000000ffffff000000ff6a"
    "0096000000000400ffffff000000ff6aff6a000004000400ffffff0000000096ff6a00000400"
    "0000ffffff00e700000000000000e300100100008000e2001e0100000001e200001c00553048"
    "fc127e24fffff3f9f900000000000000e800000000000000f500010005000000f55000000701"
    "4050f540040000094250de0000000e000000e600000000000000f3000000070ff400e7000000"
    "00000000d7000002fffffffff20000000007c07ce600000000000000e700000000000000d9dd"
    "fbff0000000001004008ffff005a0606040200000602e700000000000000e700000000000000"
    "d9ffffff00220400e300100100000000e2001e0100000000df00000000000000000000000000"
    "00000000000000000000"
)
DEFAULT_GFX_BASE_BYTES = _BASE_HEADER_AND_DL + bytes(3 * 512)  # 3 native 32x32 sprite slots


def resize_region(data, table_offset, insert_at, delta, extra_addrs=()):
    """Insert `delta` bytes at `insert_at` (delta>0: zero bytes inserted;
    delta<0: abs(delta) bytes removed -- caller must ensure that range is
    genuinely unused/safe to drop). Every chain node's field address,
    `next` link, and pointer `target` gets shifted by `delta` if it was
    at or past `insert_at`, so the self-relocation chain stays internally
    consistent. `table_offset` and any addresses in `extra_addrs` (e.g.
    addresses referenced from *outside* this file, like a hitbox.bin's
    pointer fields) are shifted the same way and returned.

    This is the one generic primitive true frame-count resizing relies on:
    growing/shrinking the sprite-pointer array and the animation script
    are both just calls to this at their respective end-of-region offset.

    Returns (data, new_table_offset, new_extra_addrs).
    """
    nodes = walk_chain(bytes(data), table_offset)

    def shift(addr):
        return addr + delta if addr >= insert_at else addr

    if delta > 0:
        data[insert_at:insert_at] = bytes(delta)
    elif delta < 0:
        del data[insert_at:insert_at - delta]

    for field_addr, next_raw, target_word, target_addr in nodes:
        new_field_addr = shift(field_addr)
        new_next_raw = 0xFFFF if next_raw == 0xFFFF else shift(next_raw * 4) // 4
        new_target_word = 0 if target_word == 0 else shift(target_addr) // 4
        struct.pack_into(">HH", data, new_field_addr, new_next_raw, new_target_word)

    new_table_offset = shift(table_offset)
    new_extra_addrs = [shift(a) for a in extra_addrs]
    return data, new_table_offset, new_extra_addrs


def detect_sprite_array_any_length(data, table_offset):
    """Like find_sprite_array, but without needing to know the array's
    length in advance: returns the longest run of consecutive 4-byte
    chain fields with evenly-spaced, non-null targets. Used for resizing,
    where we need to find whatever the template's *native* frame count is
    before growing/shrinking it."""
    nodes = walk_chain(data, table_offset)
    by_addr = sorted((n[0], n[3]) for n in nodes if n[2] != 0)
    best = None
    i = 0
    while i < len(by_addr):
        j = i
        while j + 1 < len(by_addr) and by_addr[j + 1][0] == by_addr[j][0] + 4:
            j += 1
        run = by_addr[i:j + 1]
        if len(run) >= 2:
            targets = [t for _, t in run]
            diffs = {targets[k + 1] - targets[k] for k in range(len(targets) - 1)}
            # spacing must be positive: a real sprite array's slots point at
            # distinct, increasing addresses. Fields that just coincidentally
            # sit next to each other pointing at the SAME thing (e.g. two
            # separate pointers both referencing the anim script) match
            # len(diffs)==1 with spacing 0 and would otherwise false-positive.
            if len(diffs) == 1 and next(iter(diffs)) > 0 and (best is None or len(run) > len(best)):
                best = run
        i = j + 1
    if best is None:
        return None, None, None
    targets = [t for _, t in best]
    spacing = targets[1] - targets[0] if len(targets) > 1 else None
    return [a for a, _ in best], targets, spacing


def rgba5551(r, g, b, alpha):
    red, green, blue = (r & 0xF8) >> 3, (g & 0xF8) >> 3, (b & 0xF8) >> 3
    return (red << 11) | (green << 6) | (blue << 1) | (1 if alpha else 0)


def find_sprite_array(data, table_offset, n_frames):
    """Locate the template's sprite-pointer array: n_frames consecutive
    4-byte chain fields with evenly-spaced targets. Returns
    (field_addrs, target_addrs, spacing).

    Not meaningful for n_frames==1 (a single field trivially "matches"
    whichever chain node happens to sort first, which usually isn't the
    sprite pointer at all) -- single-frame templates must be pointed at
    explicitly via the spec's `sprite_fields` override instead."""
    if n_frames == 1:
        return None, None, None
    nodes = walk_chain(data, table_offset)
    by_addr = sorted((n[0], n[3]) for n in nodes if n[2] != 0)
    for i in range(len(by_addr) - n_frames + 1):
        run = by_addr[i:i + n_frames]
        if all(run[j + 1][0] == run[j][0] + 4 for j in range(len(run) - 1)):
            targets = [t for _, t in run]
            diffs = {targets[j + 1] - targets[j] for j in range(len(targets) - 1)}
            # spacing must be positive -- see detect_sprite_array_any_length
            # for why (rules out e.g. two unrelated fields both pointing at
            # the same script address, which trivially "matches" otherwise).
            if len(diffs) == 1 and next(iter(diffs)) > 0 and len(run) == n_frames:
                spacing = diffs.pop() if diffs else 0
                return [a for a, _ in run], targets, spacing
    return None, None, None


def find_vtx_block(data, table_offset):
    """Locate the sprite quad's 4 Vtx entries via the chain: the G_VTX
    command's address word is itself a relocated chain node, so any chain
    target that decodes as 4x 16-byte Vtx (x==0, y/z symmetric +-K, s/t
    only 0 or a shared max) is the quad. Confirmed against real ground
    truth: Mario's actual 16px fireball uses x=0,y=+-150,z=+-150,
    s/t in {0, 512}; our 32px base template uses the same +-150 geometry
    with s/t in {0, 1024} -- i.e. on-screen quad size is independent of
    texture resolution, only UV range should scale with it.
    Returns (vtx_offset, uv_max) or (None, None)."""
    nodes = walk_chain(data, table_offset)
    seen = set()
    for _, _, target_word, target_addr in nodes:
        if target_word == 0 or target_addr in seen or target_addr + 64 > len(data):
            continue
        seen.add(target_addr)
        try:
            verts = [struct.unpack(">hhhhhhBBBB", data[target_addr + i * 16:target_addr + i * 16 + 16])
                     for i in range(4)]
        except struct.error:
            continue
        xs = {v[0] for v in verts}
        if xs != {0}:
            continue
        ys = {v[1] for v in verts}
        zs = {v[2] for v in verts}
        if len(ys) != 2 or len(zs) != 2 or ys != {-y for y in ys} or zs != {-z for z in zs}:
            continue
        st_vals = {v[4] for v in verts} | {v[5] for v in verts}
        if 0 not in st_vals or len(st_vals) != 2:
            continue
        uv_max = max(st_vals)
        return target_addr, uv_max
    return None, None


def patch_block_load(data, header_end, old_dim, w, h):
    """Patch the static DL's G_SETTILE (row-stride/wrap-mask) and
    G_LOADBLOCK (texel-count/dxt) fields so the RDP's TMEM load matches
    the new, tightly-packed frame size instead of the template's native
    (padded) size.

    Formulas verified two ways: against real Nintendo ROM data (Mario's
    actual 16px fireball display list: texels=0x3F dxt=0x800 for tight
    16x16 CI4), and cross-checked against an independently authored
    16x16 CI4 extra-character projectile gfx.bin -- both agree exactly:
        row_bytes = w // 2                  (CI4: 2px/byte)
        line      = row_bytes // 8           (TMEM row-stride, in qwords)
        masks/maskt = log2(w) / log2(h)      (S/T wrap mask)
        texels    = (w * h // 4) - 1
        dxt       = 16384 // row_bytes

    Only patches SETTILE/LOADBLOCK instances whose *current* fields match
    the template's native-size formula -- so this can't misfire on an
    unrelated command that happens to share the 0xF5/0xF3 opcode byte.
    """
    old_line = (old_dim // 2) // 8
    old_mask = old_dim.bit_length() - 1
    old_texels = (old_dim * old_dim // 4) - 1
    new_masks, new_maskt = w.bit_length() - 1, h.bit_length() - 1
    new_line = (w // 2) // 8
    new_texels = (w * h // 4) - 1
    new_dxt = 16384 // (w // 2)

    pos = 0
    while pos + 8 <= header_end:
        opcode = data[pos]
        if opcode in (0xF5, 0xF3):
            w0, w1 = struct.unpack(">II", data[pos:pos + 8])
            if opcode == 0xF5:
                cur_masks, cur_maskt, cur_line = (w1 >> 4) & 0xF, (w1 >> 14) & 0xF, (w0 >> 9) & 0x1FF
                changed = False
                if cur_masks == old_mask:
                    w1 = (w1 & ~(0xF << 4)) | (new_masks << 4)
                    changed = True
                if cur_maskt == old_mask:
                    w1 = (w1 & ~(0xF << 14)) | (new_maskt << 14)
                    changed = True
                if old_line and cur_line == old_line:
                    w0 = (w0 & ~(0x1FF << 9)) | (new_line << 9)
                    changed = True
                if changed:
                    struct.pack_into(">II", data, pos, w0, w1)
                    print(f"G_SETTILE @0x{pos:04X}: row-stride/wrap-mask updated for {w}x{h}")
            else:
                cur_texels = (w1 >> 12) & 0xFFF
                if cur_texels == old_texels:
                    new_w1 = (w1 & 0xFF000000) | (new_texels << 12) | new_dxt
                    struct.pack_into(">I", data, pos + 4, new_w1)
                    print(f"G_LOADBLOCK @0x{pos:04X}: texels 0x{old_texels:X}->0x{new_texels:X}, "
                          f"dxt 0x{16384 // (old_dim // 2):X}->0x{new_dxt:X}")
        pos += 4


def find_single_sprite_field(data, table_offset, expected_size):
    """Auto-locate a single (non-array) sprite pointer field for a
    one-frame template. Unlike the multi-frame case, a lone chain field
    can't be told apart from any other lone pointer (palette, MObjSub,
    etc.) by position alone -- but the sprite DATA it points at is always
    bounded immediately by the next real field/target address (nothing
    else lives in that gap). So: for each chain target T, find the next
    higher known boundary (any field address or target address from the
    chain) and check whether the gap matches `expected_size` exactly.
    Returns the field_addr, or None if no unambiguous match is found."""
    nodes = walk_chain(data, table_offset)
    boundaries = sorted({n[0] for n in nodes} | {n[3] for n in nodes if n[2] != 0} | {len(data)})
    candidates = []
    for field_addr, _, target_word, target_addr in nodes:
        if target_word == 0:
            continue
        next_boundary = next((b for b in boundaries if b > target_addr), len(data))
        if next_boundary - target_addr == expected_size:
            candidates.append(field_addr)
    if len(candidates) == 1:
        return candidates[0]
    return None


def find_animation_script(data, table_offset):
    """Same heuristic as the annotator: first chain target that decodes
    as >1 SetValAfterBlock/SetValAfter command."""
    nodes = walk_chain(data, table_offset)
    seen = set()
    for _, _, target_word, target_addr in nodes:
        if target_word == 0 or target_addr in seen:
            continue
        seen.add(target_addr)
        pos = target_addr
        count = 0
        while pos + 8 <= len(data):
            word = int.from_bytes(data[pos:pos + 4], "big")
            if (word >> 25) & 0x7F not in (10, 11):
                break
            count += 1
            pos += 8
        if count > 1:
            return target_addr, count
    return None, 0


def resize_frame_count(data, table_offset, new_n_frames, hitbox_targets):
    """Grow or shrink the template's sprite-pointer array and animation
    script to support new_n_frames, using resize_region for both. Keeps
    the "N distinct frames + 1 loop-back-to-frame0 step" script shape
    (see the frame_wait handling in build_gfx) rather than a bare N-step
    script, since that's the shape the whole rest of this file assumes.

    hitbox_targets: gfx-file addresses that some OTHER file's (hitbox.bin)
    pointer fields resolve to (e.g. the DL, the MObjSub struct's first
    chain hop, the anim script) -- these live outside this file's own
    self-relocation chain, so resize_region can't discover and fix them up
    on its own the way it does for gfx's internal chain nodes. Pass them
    in, get back where they ended up, so the caller can re-point
    hitbox.bin's pointer_prefix at the new locations.

    Returns (data, table_offset, array_field_addrs, frame_size,
    sprite_data_start, new_hitbox_targets). sprite_data_start is where the
    template's native sprite pixel data begins (shifted through the
    resize, same as everything else) -- the caller packs new pixel data
    starting there.
    """
    field_addrs, targets, spacing = detect_sprite_array_any_length(data, table_offset)
    anim_off, script_steps = find_animation_script(data, table_offset)
    if field_addrs is None or anim_off is None:
        sys.exit("ERROR: could not locate the template's sprite array / animation "
                  "script to resize (needed because it doesn't already have "
                  f"{new_n_frames} frames)")
    old_n_frames = len(field_addrs)
    old_script_steps = script_steps
    new_script_steps = new_n_frames + 1
    frame_size = spacing  # bytes/frame in the template's native (un-shrunk) storage

    def relink_array(data, table_offset, old_first, old_count, new_count):
        """resize_region shifts every *existing* node's next/target by
        delta, but doesn't know to splice new nodes into a linked list (for
        growth) or skip removed ones (for shrink) -- that linkage is on us.
        Must run BEFORE resize_region touches this region, since shrinking
        physically deletes the old last node we need to read first."""
        old_last = old_first + (old_count - 1) * 4
        continuation_next_raw = u16(bytes(data), old_last)  # what came after the array
        # Growing: insert right after the last OLD element (old_count).
        # Shrinking: remove right after the last KEPT element (new_count).
        # Both are "min(old_count, new_count)" -- the boundary after
        # whatever's common to both sizes.
        insert_at = old_first + min(old_count, new_count) * 4
        delta = (new_count - old_count) * 4

        def shift(addr):
            return addr + delta if addr >= insert_at else addr

        continuation_next_addr = None if continuation_next_raw == 0xFFFF else continuation_next_raw * 4
        return insert_at, delta, continuation_next_raw, continuation_next_addr, shift

    array_insert_at, array_delta, cont_next_raw, cont_next_addr, array_shift = \
        relink_array(data, table_offset, field_addrs[0], old_n_frames, new_n_frames)
    sprite_data_start = targets[0]  # where the native array's pixel data starts

    n_hb = len(hitbox_targets)
    extras = list(hitbox_targets.values()) + [anim_off, sprite_data_start]
    data, table_offset, extras = resize_region(data, table_offset, array_insert_at, array_delta, extras)
    hitbox_targets = dict(zip(hitbox_targets.keys(), extras[:n_hb]))
    anim_off, sprite_data_start = extras[n_hb:]

    field_addrs = [field_addrs[0] + i * 4 for i in range(new_n_frames)]
    new_cont_next_raw = (0xFFFF if cont_next_raw == 0xFFFF
                          else array_shift(cont_next_addr) // 4)
    for i in range(new_n_frames - 1):
        struct.pack_into(">H", data, field_addrs[i], field_addrs[i + 1] // 4)
    struct.pack_into(">H", data, field_addrs[-1], new_cont_next_raw)

    # Same min(old, new) logic as the array: growing inserts after the last
    # OLD step, shrinking removes after the last KEPT step.
    script_insert_at = anim_off + min(old_script_steps, new_script_steps) * 8
    script_delta = (new_script_steps - old_script_steps) * 8
    n_hb = len(hitbox_targets)
    extras = list(hitbox_targets.values()) + [anim_off, sprite_data_start] + field_addrs
    data, table_offset, extras = resize_region(data, table_offset, script_insert_at, script_delta, extras)
    hitbox_targets = dict(zip(hitbox_targets.keys(), extras[:n_hb]))
    anim_off, sprite_data_start = extras[n_hb:n_hb + 2]
    field_addrs = extras[n_hb + 2:]

    # Rewrite every step's command+value word fresh: growth leaves new steps
    # as raw zero bytes (not valid SetValAfterBlock commands, so
    # find_animation_script wouldn't see them), and shrink just truncated
    # whatever was past the cut. Cycles frame index 0.0, 1.0, ..., back to
    # 0.0 for the loop-back step; hold durations default to 0 here and get
    # set for real by build_gfx's frame_wait handling right after this.
    pos = anim_off
    for i in range(new_script_steps):
        frame_value = float(i if i < new_n_frames else 0)
        word = (10 << 25) | (0x001 << 15)  # SetValAfterBlock, TEXID track, wait=0 (placeholder)
        struct.pack_into(">I", data, pos, word)
        struct.pack_into(">f", data, pos + 4, frame_value)
        pos += 8

    print(f"Resized: sprite array {old_n_frames}->{new_n_frames} frames, "
          f"animation script {old_script_steps}->{new_script_steps} steps")
    return data, table_offset, field_addrs, frame_size, sprite_data_start, hitbox_targets


def resolve_hitbox_pointer_prefix(spec):
    """The 4 pointer/chain fields (0x00-0x0F) of a hitbox.bin are tied to
    the specific gfx file's internal layout. Resolve them the same way
    build_gfx resolves its own base structure: explicit override >
    existing output file (already correct for whatever gfx layout it
    currently targets) > the bundled default (matches DEFAULT_GFX_BASE_BYTES)."""
    prefix_hex = spec.get("hitbox_pointer_prefix")
    if prefix_hex:
        return bytes.fromhex(prefix_hex)
    if os.path.exists(spec.get("output_hitbox", "")):
        return open(spec["output_hitbox"], "rb").read(16)
    return DEFAULT_POINTER_PREFIX


def decode_hitbox_targets(prefix):
    """Decode the byte-address targets of the 3 pointer fields a hitbox.bin
    actually uses (WPAttributes: data, p_mobjsubs, p_matanim_joints -- the
    anim_joints slot at prefix[8:12] is unused for every projectile built
    here, a static-joint weapon with no skeletal animation)."""
    return {
        "data": u16(prefix, 2) * 4,
        "p_mobjsubs": u16(prefix, 6) * 4,
        "p_matanim_joints": u16(prefix, 14) * 4,
    }


def encode_hitbox_targets(prefix, targets):
    """Inverse of decode_hitbox_targets: write updated target addresses
    into a copy of `prefix`, keeping the next_raw (chain-link) bytes
    untouched -- those describe hitbox.bin's own internal field traversal
    order, unrelated to gfx file layout."""
    prefix = bytearray(prefix)
    struct.pack_into(">H", prefix, 2, targets["data"] // 4)
    struct.pack_into(">H", prefix, 6, targets["p_mobjsubs"] // 4)
    struct.pack_into(">H", prefix, 14, targets["p_matanim_joints"] // 4)
    return bytes(prefix)


def load_ci4_frame(path):
    im = Image.open(path)
    if im.mode != "P":
        sys.exit(f"ERROR: {path} must be a palette-indexed (mode 'P') image, got {im.mode}")
    return im


def build_gfx(spec):
    frame_paths = spec["frames"]
    n_frames = len(frame_paths)
    out_gfx_path = spec["output_gfx"]

    # No explicit gfx_template? If the output file already exists, treat IT as
    # the base and patch it in place (it's already got a correct structure).
    # Otherwise start from the built-in structure (DEFAULT_GFX_BASE_BYTES,
    # inline in this file's source -- see its definition for what's in it)
    # for a from-nothing build.
    if "gfx_template" in spec:
        template_path = spec["gfx_template"]
        data = bytearray(open(template_path, "rb").read())
    elif os.path.exists(out_gfx_path):
        template_path = out_gfx_path
        data = bytearray(open(template_path, "rb").read())
    else:
        template_path = "<built-in base structure>"
        data = bytearray(DEFAULT_GFX_BASE_BYTES)
    table_offset = int(spec.get("table_offset", "0x58"), 16)

    # --- Palette + frames: all frame images must share one <=16 color palette ---
    images = [load_ci4_frame(p) for p in frame_paths]
    w, h = images[0].size
    for im, p in zip(images, frame_paths):
        if im.size != (w, h):
            sys.exit(f"ERROR: {p} is {im.size}, all frames must share the same size")
    pal = images[0].getpalette()

    sprite_fields_override = spec.get("sprite_fields")
    field_addrs = None
    if sprite_fields_override:
        field_addrs = [int(f, 16) for f in sprite_fields_override]
        old_targets = [u16(bytes(data), fa + 2) * 4 for fa in field_addrs]
        template_dim_override = spec.get("template_dim")
        if template_dim_override is None:
            sys.exit("ERROR: sprite_fields override requires template_dim too "
                      "(the template's native sprite width/height -- can't be "
                      "inferred from a single field the way an array's spacing can)")
        spacing = (int(template_dim_override) ** 2) // 2  # CI4: 2px/byte
    elif n_frames == 1:
        # Templates that are natively single-frame (e.g. a rapid-fire jab
        # projectile's gfx.bin) have a lone sprite pointer, not an array --
        # try that first. If it's not
        # found, fall through to the general resize path below, which also
        # covers shrinking a native N-frame array (e.g. the bundled 3-frame
        # base) down to a true single frame.
        single_field = find_single_sprite_field(bytes(data), table_offset, w * h // 2)
        if single_field is not None:
            field_addrs = [single_field]
            old_targets = [u16(bytes(data), single_field + 2) * 4]
            spacing = w * h // 2
    else:
        # Must check the TRUE native array length (longest valid run), not
        # just "can I find *some* N-length match" -- a native 3-element
        # array trivially contains a valid-looking 2-element sub-match too,
        # which would wrongly skip the resize this frame count actually needs.
        native_field_addrs, _, _ = detect_sprite_array_any_length(bytes(data), table_offset)
        if native_field_addrs is not None and len(native_field_addrs) == n_frames:
            field_addrs, old_targets, spacing = find_sprite_array(bytes(data), table_offset, n_frames)

    if field_addrs is None:
            # Template's native frame count doesn't match -- actually resize
            # the sprite array + animation script rather than giving up.
            current_prefix = resolve_hitbox_pointer_prefix(spec)
            hitbox_targets = decode_hitbox_targets(current_prefix)
            data, table_offset, field_addrs, native_frame_size, sprite_data_start, hitbox_targets = \
                resize_frame_count(data, table_offset, n_frames, hitbox_targets)
            new_prefix = bytearray(encode_hitbox_targets(current_prefix, hitbox_targets))
            if n_frames == 1:
                # A single static frame has no real animation to play --
                # match the original single-frame convention (confirmed
                # against pellet's pre-unification hitbox.bin) instead of
                # blindly keeping the multi-frame template's p_matanim_joints
                # wiring. wpManagerMakeWeapon calls gcAddAnimAll() whenever
                # p_matanim_joints != NULL (see wpmanager.c), allocating a
                # real AObj to track it -- pointing it at a "trivial" 1-frame
                # loop instead of NULL still triggers that allocation on
                # every spawn, which is how this crashed pellet (spawned
                # repeatedly per jab combo) while fsmash/tornado (spawned
                # once per use) didn't show the same problem.
                struct.pack_into(">H", new_prefix, 4, 0xFFFF)  # p_mobjsubs.next -> terminate here
                struct.pack_into(">I", new_prefix, 12, 0)       # p_matanim_joints: true null
            new_prefix = bytes(new_prefix)
            spec["_resized_hitbox_pointer_prefix"] = new_prefix.hex()

            # The old sprite-data region only shifted by the array/script's
            # small delta, but the new frame count can need much more room
            # than that -- reusing it in place risks colliding with
            # whatever comes right after (e.g. a cloned template's dead
            # leftover sub-object, still only lightly shifted). Simplest
            # correct fix: relocate. Null the array's targets first so
            # stripping doesn't think the doomed old spot is still live,
            # cut everything from sprite_data_start onward (old data +
            # anything dead beyond it), then append fresh room at the end
            # and point the array at that instead.
            for fa in field_addrs:
                struct.pack_into(">H", data, fa + 2, 0)
            data = strip_unused_tail(data, table_offset, sprite_data_start)
            frame_size = w * h // 2  # resized frames are always tightly packed, never padded
            new_sprite_start = len(data)
            data += bytearray(frame_size * n_frames)
            for i, fa in enumerate(field_addrs):
                struct.pack_into(">H", data, fa + 2, (new_sprite_start + i * frame_size) // 4)
            old_targets = [new_sprite_start] * n_frames
            # Keep spacing as the TEMPLATE's native per-frame size (not the new
            # tight one) -- template_dim below is derived from it, and needs to
            # reflect the template's real native pixel size so the existing
            # shrink-detection (SETTILESIZE/vertex-UV/block-load patching) still
            # fires correctly when frames are smaller than that, e.g. resizing
            # the bundled 32x32 3-frame base down to a single 16x16 frame.
            spacing = native_frame_size
    print(f"Sprite array: fields {[hex(a) for a in field_addrs]} -> "
          f"slots {[hex(t) for t in old_targets]} (spacing 0x{spacing:X} bytes/frame)")
    used = set()
    for im in images:
        used |= set(im.getdata())
    used = sorted(used)
    if len(used) > 16:
        sys.exit(f"ERROR: frames use {len(used)} colors, CI4 only supports 16")
    for im, p in zip(images, frame_paths):
        if im.getpalette()[:len(used) * 3] != pal[:len(used) * 3]:
            print(f"WARNING: {p}'s palette differs from {frame_paths[0]}'s -- "
                  f"make sure frames were exported with a shared palette", file=sys.stderr)

    palette16 = [0] * 16
    for i in used:
        r, g, b = pal[i * 3:i * 3 + 3]
        alpha = 0 if i == 0 else 1  # convention: index 0 = background/transparent
        palette16[i] = rgba5551(r, g, b, alpha)
    for i, val in enumerate(palette16):
        struct.pack_into(">H", data, 0x30 + i * 2, val)
    print(f"Palette: {len(used)} colors written @0x30")

    # --- Pack each frame tightly, no padding (see patch_block_load below for why
    # this is safe: LOADBLOCK/SETTILE's row-stride fields get updated to match) ---
    template_dim = int((spacing * 2) ** 0.5)  # CI4: 2 px/byte
    if w > template_dim or h > template_dim:
        sys.exit(f"ERROR: frames are {w}x{h}, template slots only fit {template_dim}x{template_dim}")
    row_bytes = w // 2  # CI4: 2px/byte
    frame_size = row_bytes * h
    base_off = old_targets[0]
    new_targets = [base_off + i * frame_size for i in range(n_frames)]
    packed = bytearray()
    for im in images:
        pixels = list(im.getdata())
        block = bytearray(frame_size)
        for row in range(h):
            for col in range(0, w, 2):
                hi = pixels[row * w + col] & 0xF
                lo = pixels[row * w + col + 1] & 0xF if col + 1 < w else 0
                block[row * row_bytes + col // 2] = (hi << 4) | lo
        packed += block
    data[base_off:base_off + len(packed)] = packed
    for field_addr, new_target in zip(field_addrs, new_targets):
        struct.pack_into(">H", data, field_addr + 2, new_target // 4)
    print(f"Packed {n_frames} frames tightly at 0x{base_off:04X} "
          f"({w}x{h}, {frame_size} bytes/frame, no padding)")

    if (w, h) != (template_dim, template_dim):
        patch_block_load(data, header_end=base_off, old_dim=template_dim, w=w, h=h)

    # --- G_SETTILESIZE: clip the rendered tile to the real frame size ---
    settilesize_off = spec.get("settilesize_offset")
    if settilesize_off is None:
        idx = data.find(bytes([0xF2, 0, 0, 0]))
        if idx == -1:
            sys.exit("ERROR: could not auto-locate G_SETTILESIZE (0xF2) -- set settilesize_offset in the spec")
        settilesize_off = idx
    else:
        settilesize_off = int(settilesize_off, 16)
    new_w1 = ((h - 1) * 4 << 12) | ((w - 1) * 4)
    data[settilesize_off + 4:settilesize_off + 8] = struct.pack(">I", new_w1)
    print(f"G_SETTILESIZE @0x{settilesize_off:04X} -> {w}x{h}")

    # --- Quad UV coords: rescale to match the real frame size ---
    # The on-screen quad size (vertex X/Y/Z) is independent of texture
    # resolution -- confirmed against real ground truth (Mario's actual 16px
    # fireball and our 32px base template both use the same +-150 quad, only
    # differing in UV range: 512 vs 1024, i.e. pixels*32 in S10.5 fixed
    # point). Only the UV max needs to shrink to match a smaller frame, or
    # this renders the sprite stretched into a corner of the old UV range.
    if (w, h) != (template_dim, template_dim):
        vtx_off, old_uv_max = find_vtx_block(bytes(data), table_offset)
        if vtx_off is None:
            sys.exit("ERROR: frames are smaller than the template's native sprite size, "
                      "but could not auto-locate the quad's Vtx block to rescale UVs")
        new_uv_w, new_uv_h = w * 32, h * 32
        for i in range(4):
            off = vtx_off + i * 16
            x, y, z, pad, s, t, r, g, b, a = struct.unpack(">hhhhhhBBBB", data[off:off + 16])
            s = new_uv_w if s == old_uv_max else 0
            t = new_uv_h if t == old_uv_max else 0
            struct.pack_into(">hhhhhhBBBB", data, off, x, y, z, pad, s, t, r, g, b, a)
        print(f"Vtx UVs @0x{vtx_off:04X}: rescaled from 0-{old_uv_max} to "
              f"0-{new_uv_w}/0-{new_uv_h} (quad on-screen size left unchanged)")

    # --- Animation timing ---
    # Note: the animation script's step count (M) is independent of the number
    # of distinct sprite images (N) -- e.g. fsmash's template has 4 steps
    # (frame0, frame1, frame2, back-to-frame0) cycling through 3 sprite slots.
    # We only touch each step's hold duration here, never which sprite index
    # it selects, so M and N don't need to match.
    anim_off, script_steps = find_animation_script(bytes(data), table_offset)
    frame_wait = spec.get("frame_wait")
    if frame_wait is not None and anim_off is not None:
        waits = frame_wait if isinstance(frame_wait, list) else [frame_wait] * n_frames
        if len(waits) == script_steps - 1:
            # Common case: the template's script has one extra step re-showing
            # frame 0 before looping (see find_animation_script). SetValAfterBlock's
            # wait controls how long the PREVIOUS step's value stays visible, not
            # its own -- i.e. dur[i] is frame(i-1)'s hold time, not frame(i)'s. So
            # frame_wait[k] (the hold time we actually want for image k) belongs at
            # script dur[k+1], and dur[0] (which would only add extra hold time to
            # the wraparound-repeated frame 0, split awkwardly across the loop seam)
            # is set to 0 so frame_wait[0] alone fully controls frame 0's duration.
            waits = [0] + waits
        if len(waits) != script_steps:
            sys.exit(f"ERROR: template's animation script has {script_steps} steps "
                      f"(usually = frame count + 1, for the implicit loop-back-to-frame0 "
                      f"step), but frame_wait provided {len(waits)} values")
        pos = anim_off
        for wait in waits:
            word = int.from_bytes(data[pos:pos + 4], "big")
            opcode, flags = (word >> 25) & 0x7F, (word >> 15) & 0x3FF
            data[pos:pos + 4] = struct.pack(">I", (opcode << 25) | (flags << 15) | (wait & 0x7FFF))
            pos += 8
        print(f"Animation: {script_steps} script steps @0x{anim_off:04X}, hold durations {waits} "
              f"(cycling {n_frames} distinct sprite images)")

    # --- Strip unreachable trailing data (e.g. a leftover template's dead MObj,
    # or the gap left behind by tight-packing smaller-than-native frames) ---
    # Always on: strip_unused_tail refuses to cut anything a live pointer still
    # reaches, so this is safe by construction -- no reason to make it optional.
    data = strip_unused_tail(data, table_offset, base_off + len(packed))

    out_path = spec["output_gfx"]
    with open(out_path, "wb") as f:
        f.write(data)
    print(f"Wrote {out_path} ({len(data)} bytes)")


def strip_unused_tail(data, table_offset, keep_through):
    """Truncate data at `keep_through` if the self-relocation chain has no
    node whose field address or target lands before that point and links
    to something beyond it -- i.e. everything past `keep_through` is
    unreachable dead weight (like a cloned template's unused sub-object).
    Fixes up the chain's terminator so the loader doesn't walk into the
    truncated region."""
    nodes = walk_chain(bytes(data), table_offset)
    last_live_idx = None
    for i, (field_addr, next_raw, target_word, target_addr) in enumerate(nodes):
        if field_addr < keep_through and target_addr < keep_through:
            last_live_idx = i
        elif field_addr < keep_through and target_addr >= keep_through:
            sys.exit(f"ERROR: live field@0x{field_addr:04X} points at 0x{target_addr:04X}, "
                      f"past the proposed cut point 0x{keep_through:04X} -- refusing to strip "
                      f"(the tail may not be fully dead; inspect with projectile_bin_annotator.py)")
    if last_live_idx is None:
        print("WARNING: no live chain nodes found before cut point; skipping strip.")
        return data
    last_field_addr = nodes[last_live_idx][0]
    struct.pack_into(">H", data, last_field_addr, 0xFFFF)  # terminate the chain here
    removed = len(data) - keep_through
    print(f"Stripped {removed} bytes of unreachable tail data "
          f"(chain terminated at field@0x{last_field_addr:04X})")
    return data[:keep_through]


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("spec", help="Path to the projectile YAML spec")
    args = parser.parse_args()

    with open(args.spec) as f:
        spec = yaml.safe_load(f)

    build_gfx(spec)

    if "hitbox" in spec:
        hb = spec["hitbox"]
        fields = {name: hb.get(name, 0) for name, _, _, _ in BITFIELD_LAYOUT}
        offsets = hb.get("attack_offsets", DEFAULT_ATTACK_OFFSETS)
        map_coll = hb.get("map_coll", DEFAULT_MAP_COLL)
        if "_resized_hitbox_pointer_prefix" in spec:
            # build_gfx had to resize the sprite array/animation script (the
            # frame count didn't match the template's native one), which
            # moved the gfx addresses hitbox.bin's pointer fields target --
            # this is the recomputed prefix pointing at the new locations.
            pointer_prefix = bytes.fromhex(spec["_resized_hitbox_pointer_prefix"])
        else:
            pointer_prefix = resolve_hitbox_pointer_prefix(spec)
        build_hitbox_from_fields(spec["output_hitbox"], fields, offsets, map_coll, pointer_prefix)


if __name__ == "__main__":
    sys.exit(main())
