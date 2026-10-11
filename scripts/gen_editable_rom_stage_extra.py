#!/usr/bin/env python3
"""
Injects an extra stage over its matching vanilla stage, producing a ROM GE
can open directly to edit its model/geometry.

The base vanilla stage is auto-detected by diffing header.bin against every
vanilla stage header (custom stages start as a copy of one). Stage/background
file IDs come from that vanilla header's own reqlist.

Usage:
    python3 scripts/gen_editable_rom_stage_extra.py --stage SuzakuCastle \\
        --rom /path/to/ssb64asm_extra.z64 --output suzaku_over_hyrule.z64
"""
import argparse
import os
import re
import shutil
import sys
import tempfile

APPENDER_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SMASHREMIX_DIR = os.path.join(APPENDER_DIR, "smashremix")
# character_appender.py builds against the *content* repo that embeds
# appender/ as a submodule (extra_characters/, extra_stages/, src/,
# main.asm, build/ all live there, cwd-relative) - not against paths
# inside appender/ itself.
CONTENT_ROOT = os.path.dirname(APPENDER_DIR)
EXTRA_STAGES_DIR = os.path.join(CONTENT_ROOT, "extra_stages")

sys.path.insert(0, APPENDER_DIR)

# Header file ID for each original vanilla stage (Stages.asm's `header` scope).
VANILLA_STAGE_HEADERS = {
    "PEACHS_CASTLE": 0x0103,
    "SECTOR_Z": 0x0106,
    "CONGO_JUNGLE": 0x0105,
    "PLANET_ZEBES": 0x0101,
    "HYRULE_CASTLE": 0x0109,
    "YOSHIS_ISLAND": 0x0107,
    "DREAM_LAND": 0x00FF,
    "SAFFRON_CITY": 0x0108,
    "MUSHROOM_KINGDOM": 0x0104,
    "DREAM_LAND_BETA_1": 0x0100,
    "DREAM_LAND_BETA_2": 0x0102,
    "HOW_TO_PLAY": 0x010B,
    "MINI_YOSHIS_ISLAND": 0x010E,
    "META_CRYSTAL": 0x010D,
    "DUEL_ZONE": 0x010C,
    "RACE_TO_THE_FINISH": 0x0127,
    "FINAL_DESTINATION": 0x010A,
}


def load_extra_overrides(overrides_path):
    """Map CONSTANT_NAME -> file ID, for one specific extra ROM build."""
    overrides = {}
    pattern = re.compile(r'^([0-9A-Fa-f]{4})\s+([A-Z0-9_]+)$')
    with open(overrides_path, "r", encoding="utf-8") as f:
        for line in f:
            match = pattern.match(line.strip())
            if match:
                file_id, name = match.groups()
                overrides[name] = int(file_id, 16)
    return overrides


def find_best_matching_vanilla_stage(custom_header_path, vanilla_entries):
    custom_header = open(custom_header_path, "rb").read()

    scored = []
    for name, header_id in VANILLA_STAGE_HEADERS.items():
        vanilla_header = vanilla_entries[header_id].extract("data")
        n = min(len(vanilla_header), len(custom_header))
        diff = sum(1 for i in range(n) if vanilla_header[i] != custom_header[i])
        scored.append((diff, name, header_id))

    scored.sort()
    best_diff, best_name, best_id = scored[0]
    runner_up_diff = scored[1][0] if len(scored) > 1 else None
    return best_name, best_id, best_diff, runner_up_diff


def get_stage_and_background_ids(vanilla_entries, header_id):
    """A vanilla stage header's own reqlist is [stage_id]*N + [background_id]
    (+ possibly more trailing entries we don't need). Recover both IDs from it."""
    idx = vanilla_entries[header_id].idx
    ids = [int.from_bytes(idx[i:i+2], 'big') for i in range(0, (len(idx) >> 1) * 2, 2)]

    stage_id = ids[0]
    background_id = next((fid for fid in ids if fid != stage_id), None)
    if background_id is None:
        raise ValueError(
            f"Couldn't find a background file ID in header 0x{header_id:04X}'s reqlist: {[hex(i) for i in ids]}")
    return stage_id, background_id


def fix_crc(rom_path):
    """Recompute the ROM's CRC via rn64crc.exe."""
    import platform
    import subprocess

    rn64crc = os.path.join(SMASHREMIX_DIR, "assembler", "rn64crc.exe")
    command = f"{rn64crc} -u {rom_path}"
    if platform.system() == "Linux":
        command = "wine " + command

    result = subprocess.run(command.split(" "), capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    if result.returncode != 0:
        raise RuntimeError(f"rn64crc.exe failed on {rom_path}")


def file_offsets(entries, file_id):
    """tbl/res as ROMInjector.modify() expects them, read from the file
    being injected (not the vanilla slot it's going into)."""
    entry = entries[file_id]
    tbl = entry.tbl if entry.tbl is not None else 0x3FFFC
    res = entry.res if entry.res is not None else 0x3FFFC
    return tbl, res


def main():
    parser = argparse.ArgumentParser(
        description="Generates a vanilla ROM with an extra stage injected over its matching vanilla stage for editing.")
    parser.add_argument('--stage', required=True,
                         help="Extra stage folder name under extra_stages/, e.g. SuzakuCastle")
    parser.add_argument('--rom', required=True,
                         help="Path to the built extra ROM (e.g. ssb64asm_extra.z64) containing the stage's data")
    parser.add_argument('--vanilla', default=os.path.join(SMASHREMIX_DIR, "roms", "ssb.rom"),
                         help="Path to the vanilla Smash 64 ROM file")
    parser.add_argument('--overrides', default=os.path.join(SMASHREMIX_DIR, "roms", "filename_overrides_extra.txt"),
                         help="filename_overrides_extra.txt matching --rom's build")
    parser.add_argument('--base-stage', default=None, choices=list(VANILLA_STAGE_HEADERS.keys()),
                         help="Vanilla stage to overwrite. Auto-detected from the stage's header.bin if omitted.")
    parser.add_argument('--output', default='editable_stage_rom.z64',
                         help='Output ROM file path')
    args = parser.parse_args()

    stage_dir = os.path.join(EXTRA_STAGES_DIR, args.stage)
    if not os.path.isdir(stage_dir):
        raise ValueError(f"Stage folder not found: {stage_dir}")

    output_path = os.path.abspath(args.output)
    rom_path = os.path.abspath(args.rom)
    vanilla_path = os.path.abspath(args.vanilla)
    overrides_path = os.path.abspath(args.overrides)

    from SSB import SSBtbl, N64
    from smashremix_extra.injector.injector import ROMInjector

    vanilla_rom = N64(open(vanilla_path, "rb").read())
    vanilla_entries = SSBtbl.fromROM(vanilla_rom)

    if args.base_stage:
        base_name = args.base_stage
        base_header_id = VANILLA_STAGE_HEADERS[base_name]
        print(f"Using requested base stage: {base_name} (header 0x{base_header_id:04X})")
    else:
        base_name, base_header_id, diff, runner_up_diff = find_best_matching_vanilla_stage(
            os.path.join(stage_dir, "header.bin"), vanilla_entries)
        print(
            f"Auto-detected base stage: {base_name} (header 0x{base_header_id:04X}), "
            f"{diff} differing bytes (next closest: {runner_up_diff})"
        )

    base_stage_id, base_background_id = get_stage_and_background_ids(vanilla_entries, base_header_id)
    print(f"Vanilla {base_name}: header=0x{base_header_id:04X} stage=0x{base_stage_id:04X} background=0x{base_background_id:04X}")

    overrides = load_extra_overrides(overrides_path)
    stage_prefix = args.stage.upper()
    try:
        custom_header_id = overrides[f"{stage_prefix}_HEADER"]
        custom_stage_id = overrides[f"{stage_prefix}_STAGE"]
        custom_background_id = overrides[f"{stage_prefix}_BACKGROUND"]
    except KeyError as e:
        raise ValueError(
            f"Couldn't find {e} in {overrides_path} - is --stage spelled like the extra_stages/ folder, "
            f"and does --rom actually contain this stage?")
    print(
        f"{args.stage} in this build: header=0x{custom_header_id:04X} "
        f"stage=0x{custom_stage_id:04X} background=0x{custom_background_id:04X}"
    )

    source_rom = N64(open(rom_path, "rb").read())
    source_entries = SSBtbl.fromROM(source_rom)

    workdir = tempfile.mkdtemp(prefix="gen_editable_rom_stage_extra_")
    try:
        def extract(file_id, name):
            path = os.path.join(workdir, f"{name}.bin")
            with open(path, "wb") as f:
                f.write(source_entries[file_id].extract("data"))
            return path

        header_path = extract(custom_header_id, "header")
        stage_path = extract(custom_stage_id, "stage")
        background_path = extract(custom_background_id, "background")

        # Remap the header's internal reqlist so its stage/background
        # references point at the vanilla target IDs instead of this
        # build's own IDs.
        idx = source_entries[custom_header_id].idx
        header_reqlist_path = os.path.join(workdir, "header_reqlist.txt")
        with open(header_reqlist_path, "w", encoding="utf-8") as f:
            for i in range(0, (len(idx) >> 1) * 2, 2):
                fid = int.from_bytes(idx[i:i+2], 'big')
                if fid == custom_stage_id:
                    fid = base_stage_id
                elif fid == custom_background_id:
                    fid = base_background_id
                f.write(f"{fid:04X}\n")
            f.write("END OF REQ LIST")

        injector = ROMInjector(vanilla_path, output_path)

        h_tbl, h_res = file_offsets(source_entries, custom_header_id)
        injector.modify(base_header_id, header_path, h_tbl, h_res,
                         reqlist_path=header_reqlist_path, compression_level=1)

        s_tbl, s_res = file_offsets(source_entries, custom_stage_id)
        injector.modify(base_stage_id, stage_path, s_tbl, s_res, compression_level=2)

        b_tbl, b_res = file_offsets(source_entries, custom_background_id)
        injector.modify(base_background_id, background_path, b_tbl, b_res, compression_level=2)

        injector.save(on_progress=print)
    finally:
        shutil.rmtree(workdir, ignore_errors=True)

    fix_crc(output_path)

    print(f"\nDone. Output ROM: {output_path}")


if __name__ == "__main__":
    main()
