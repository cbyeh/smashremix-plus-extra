import re
import os
import struct
import sys
import pandas as pd
import yaml
import tempfile
import argparse

APPENDER_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SMASHREMIX_DIR = os.path.join(APPENDER_DIR, "smashremix")

sys.path.insert(0, APPENDER_DIR)

from SSB import SSBtbl, N64  # noqa: E402


class IndentedListDumper(yaml.Dumper):
    """Forces list items ("- key: value") to be indented under their parent
    key rather than left flush with it, which is PyYAML's default."""

    def increase_indent(self, flow=False, indentless=False):
        return super().increase_indent(flow, False)


# FTAttributes field names, types, and byte offsets below are taken from the
# ssb-decomp-re project (https://github.com/VetriTheRetri/ssb-decomp-re/,
# src/ft/fttypes.h and tools/typeFTAttributes.py), whose layout is verified
# by asserting exact byte offsets against 20 different fighters' relocData.
# The struct is 0x348 (840) bytes long.
FTATTR_SIZE = 0x348

# u32 bitfield at offset 0x100, 22 x 1-bit flags packed from the MSB down.
BITFIELD_NAMES = [
    "is_have_attack11", "is_have_attack12", "is_have_attackdash",
    "is_have_attacks3", "is_have_attackhi3", "is_have_attacklw3",
    "is_have_attacks4", "is_have_attackhi4", "is_have_attacklw4",
    "is_have_attackairn", "is_have_attackairf", "is_have_attackairb",
    "is_have_attackairhi", "is_have_attackairlw",
    "is_have_specialn", "is_have_specialairn",
    "is_have_specialhi", "is_have_specialairhi",
    "is_have_speciallw", "is_have_specialairlw",
    "is_have_catch", "is_have_voice",
]


class AttributesDumper:
    def __init__(self, args):
        self.args = args

        self.temp_dir = tempfile.TemporaryDirectory()
        self.rom_file = SSBtbl.fromROM(N64(open(args.rom, "rb").read()))

    def extract_file(self, file_id):
        print(f"Extracting file {file_id:04X} from ROM")
        with open(f"{self.temp_dir.name}/{file_id:04X}.bin", "wb") as f:
            f.write(self.rom_file[int(file_id)].extract())

    def extract_constants(self, file_path):
        constants_map = {}
        pattern = r'constant\s+(\w+_MAIN)\((0x[0-9a-fA-F]+)\)'
        with open(file_path, 'r') as file:
            for line in file:
                match = re.search(pattern, line)
                if match:
                    name = match.group(1).replace("_MAIN", "")
                    value = match.group(2)
                    constants_map[name] = f"{value[2:]:0>4}"
        return constants_map

    def find_last_instance_of_pattern(binary_data, pattern):
        last_position = -1
        for i in range(len(binary_data) - len(pattern) + 1):
            if binary_data[i:i + len(pattern)] == pattern:
                last_position = i
        return last_position

    def extract_original_constants(self, original_path):
        constants_map = {}
        pattern = r'([0-9a-fA-F]+).*-\s(\w+ Main Character)'
        with open(original_path, 'r', encoding='utf-8') as file:
            for line in file:
                match = re.search(pattern, line)
                if match:
                    name = match.group(2).replace(" Main Character", "")
                    value = match.group(1)
                    if value == "0853":
                        break
                    constants_map[name] = f"{value}"
        return constants_map

    def parse_fighter_attributes(self, binary_data, base):
        """Parse the big-endian FTAttributes struct starting at `base` in
        `binary_data`, field-for-field, per the ssb-decomp-re layout above.

        Pure pointer fields (setup_parts, hiddenparts, sprites, ...) are
        internal engine linkage rather than tunable attributes - they're
        skipped rather than misread as bogus floats/ints.
        """
        attrs = {}
        off = 0

        def f32(name):
            nonlocal off
            attrs[name] = struct.unpack_from(">f", binary_data, base + off)[0]
            off += 4

        def s32(name):
            nonlocal off
            attrs[name] = struct.unpack_from(">i", binary_data, base + off)[0]
            off += 4

        def bool32(name):
            nonlocal off
            val = struct.unpack_from(">i", binary_data, base + off)[0]
            attrs[name] = bool(val)
            off += 4

        def u16(name):
            nonlocal off
            attrs[name] = struct.unpack_from(">H", binary_data, base + off)[0]
            off += 2

        def u8():
            nonlocal off
            val = binary_data[base + off]
            off += 1
            return val

        def skip(n):
            nonlocal off
            off += n

        def skip_ptr():
            skip(4)

        # ---- Movement / physics scalars ----
        for name in [
            "size", "walkslow_anim_length", "walkmiddle_anim_length", "walkfast_anim_length",
            "throw_walkslow_anim_length", "throw_walkmiddle_anim_length", "throw_walkfast_anim_length",
            "rebound_anim_length", "walk_speed_mul", "traction", "dash_speed", "dash_decel",
            "run_speed", "kneebend_anim_length", "jump_vel_x", "jump_height_mul", "jump_height_base",
            "jumpaerial_vel_x", "jumpaerial_height", "air_accel", "air_speed_max_x", "air_friction",
            "gravity", "tvel_base", "tvel_fast",
        ]:
            f32(name)
        assert off == 0x064, hex(off)

        s32("jumps_max")
        assert off == 0x068, hex(off)

        for name in [
            "weight", "attack1_followup_frames", "dash_to_run", "shield_size",
            "shield_break_vel_y", "shadow_size", "jostle_width", "jostle_x",
        ]:
            f32(name)
        assert off == 0x088, hex(off)

        bool32("is_metallic")
        assert off == 0x08C, hex(off)

        for name in ["cam_offset_y", "closeup_camera_zoom", "camera_zoom", "camera_zoom_base"]:
            f32(name)
        assert off == 0x09C, hex(off)

        for name in ["map_coll_top", "map_coll_center", "map_coll_bottom", "map_coll_width"]:
            f32(name)
        assert off == 0x0AC, hex(off)

        f32("cliffcatch_coll_x")
        f32("cliffcatch_coll_y")
        assert off == 0x0B4, hex(off)

        u16("dead_fgm_ids[0]")
        u16("dead_fgm_ids[1]")
        u16("deadup_sfx")
        u16("damage_sfx")
        u16("smash_sfx[0]")
        u16("smash_sfx[1]")
        u16("smash_sfx[2]")
        assert off == 0x0C2, hex(off)

        skip(2)  # alignment padding before item_pickup
        assert off == 0x0C4, hex(off)

        for group in ["pickup_offset_light", "pickup_range_light",
                      "pickup_offset_heavy", "pickup_range_heavy"]:
            f32(f"{group}_x")
            f32(f"{group}_y")
        assert off == 0x0E4, hex(off)

        u16("itemthrow_vel_scale")
        u16("itemthrow_damage_scale")
        u16("heavyget_sfx")
        assert off == 0x0EA, hex(off)
        skip(2)  # alignment padding before halo_size
        assert off == 0x0EC, hex(off)

        f32("halo_size")
        assert off == 0x0F0, hex(off)

        for i in range(3):
            attrs[f"shade_color[{i}]_r"] = u8()
            attrs[f"shade_color[{i}]_g"] = u8()
            attrs[f"shade_color[{i}]_b"] = u8()
            attrs[f"shade_color[{i}]_a"] = u8()
        attrs["fog_color_r"] = u8()
        attrs["fog_color_g"] = u8()
        attrs["fog_color_b"] = u8()
        attrs["fog_color_a"] = u8()
        assert off == 0x100, hex(off)

        bitfield = struct.unpack_from(">I", binary_data, base + off)[0]
        off += 4
        for i, bit_name in enumerate(BITFIELD_NAMES):
            attrs[bit_name] = bool((bitfield >> (31 - i)) & 1)
        assert off == 0x104, hex(off)

        # FTDamageCollDesc damage_coll_descs[11]: joint_id, placement,
        # is_grabbable, offset (Vec3f), size (Vec3f) - 36 bytes each.
        for i in range(11):
            s32(f"damage_coll_descs[{i}]_joint_id")
            s32(f"damage_coll_descs[{i}]_placement")
            bool32(f"damage_coll_descs[{i}]_is_grabbable")
            for axis in "xyz":
                f32(f"damage_coll_descs[{i}]_offset_{axis}")
            for axis in "xyz":
                f32(f"damage_coll_descs[{i}]_size_{axis}")
        assert off == 0x290, hex(off)

        for axis in "xyz":
            f32(f"hit_detect_range_{axis}")
        assert off == 0x29C, hex(off)

        skip_ptr()  # setup_parts
        skip_ptr()  # animlock
        assert off == 0x2A4, hex(off)

        for i in range(5):
            s32(f"effect_joint_ids[{i}]")
        assert off == 0x2B8, hex(off)

        for i in range(5):
            bool32(f"cliff_status_ga[{i}]")
        assert off == 0x2CC, hex(off)

        s32("unused_0x2CC")
        assert off == 0x2D0, hex(off)

        skip_ptr()  # hiddenparts
        skip_ptr()  # commonparts_container
        skip_ptr()  # dobj_lookup
        assert off == 0x2DC, hex(off)

        skip(4 * 8)  # shield_anim_joints[8] (pointers)
        assert off == 0x2FC, hex(off)

        s32("joint_rfoot_id")
        f32("joint_rfoot_rotate")
        s32("joint_lfoot_id")
        f32("joint_lfoot_rotate")
        assert off == 0x30C, hex(off)

        filler = binary_data[base + off: base + off + 16]
        off += 16
        attrs["filler_0x30C"] = filler.hex()
        assert off == 0x31C, hex(off)

        f32("unk_0x31C")
        f32("unk_0x320")
        assert off == 0x324, hex(off)

        skip_ptr()  # translate_scales
        skip_ptr()  # modelparts_container
        skip_ptr()  # accesspart
        skip_ptr()  # textureparts_container
        assert off == 0x334, hex(off)

        s32("joint_itemheavy_id")
        assert off == 0x338, hex(off)

        skip_ptr()  # thrown_status
        assert off == 0x33C, hex(off)

        s32("joint_itemlight_id")
        assert off == 0x340, hex(off)

        skip_ptr()  # sprites
        skip_ptr()  # skeleton
        assert off == FTATTR_SIZE, hex(off)

        return attrs

    def process_binary_files(self, constants_map):
        characters = {}
        pattern = b'\x00\x64\x00\x64'

        for name, value in constants_map.items():
            self.extract_file(int(value, 16))
            binary_file_path = os.path.join(
                self.temp_dir.name, f"{value}.bin")
            if not os.path.exists(binary_file_path):
                continue

            with open(binary_file_path, 'rb') as binary_file:
                binary_data = binary_file.read()

            last_position = AttributesDumper.find_last_instance_of_pattern(
                binary_data, pattern)
            global_pos = last_position - 228
            print(
                f"{name}: FTAttributes at {hex(global_pos)} in '{binary_file_path}'")

            try:
                characters[name] = self.parse_fighter_attributes(
                    binary_data, global_pos)
            except (AssertionError, struct.error, IndexError) as e:
                print(f"  Failed to parse attributes for {name}: {e}")

        return characters

    def dump_attributes(self, output_file, format="yaml", csv_output_file=None):
        file_path = self.args.file_asm
        constants_map = self.extract_constants(file_path)

        filename_overrides = self.args.filename_overrides
        constants_map.update(
            self.extract_original_constants(filename_overrides))

        characters = self.process_binary_files(constants_map)

        if format == "yaml":
            characters_as_lists = {
                name: [{attr: value} for attr, value in attrs.items()]
                for name, attrs in characters.items()
            }
            with open(output_file, "w") as f:
                yaml.dump(characters_as_lists, f, Dumper=IndentedListDumper,
                          sort_keys=False, default_flow_style=False)
        else:
            df = pd.DataFrame.from_dict(characters, orient='index')
            df.to_csv(output_file)

        if csv_output_file and format != "csv":
            df = pd.DataFrame.from_dict(characters, orient='index')
            df.to_csv(csv_output_file)

    def cleanup(self):
        self.temp_dir.cleanup()


def main():
    parser = argparse.ArgumentParser(
        description='Dump character attributes to a YAML (or CSV) file')
    parser.add_argument('--rom', default=os.path.join(SMASHREMIX_DIR, "roms", "original.z64"),
                        help='Path to the ROM file (default: the vanilla ROM bundled with the '
                             'smashremix submodule; pass the built extra ROM to include custom '
                             'characters)')
    parser.add_argument('--format', choices=['yaml', 'csv'], default='yaml',
                        help='Output format for --output (default: yaml)')
    parser.add_argument('--output', default=None,
                        help='Output file path (default: char_data.yml or char_data.csv, '
                             'depending on --format)')
    parser.add_argument('--csv-output', default=None,
                        help='If set, also dump a CSV copy to this path, regardless of --format '
                             '(useful for keeping a CSV artifact alongside the printed YAML)')
    parser.add_argument('--file_asm', default=os.path.join(SMASHREMIX_DIR, "src", "File.asm"),
                        help='File.asm path (default: smashremix\'s own, vanilla-only File.asm; '
                             'pass the content repo\'s src/File.asm to include custom characters)')
    parser.add_argument('--filename_overrides',
                        default=os.path.join(
                            SMASHREMIX_DIR, "roms", "filename_overrides.txt"),
                        help='Filename overrides path')
    args = parser.parse_args()

    output_file = args.output or (
        'char_data.yml' if args.format == 'yaml' else 'char_data.csv')

    dumper = AttributesDumper(args)
    try:
        dumper.dump_attributes(
            output_file, format=args.format, csv_output_file=args.csv_output)
        print(f"Attributes dumped to {output_file}")
        if args.csv_output:
            print(f"CSV copy dumped to {args.csv_output}")
    finally:
        dumper.cleanup()


if __name__ == "__main__":
    main()
