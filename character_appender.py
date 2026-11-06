import lineinfile
import os
import sys
import shutil
import yaml
import re
import argparse
import hashlib
from pathlib import Path

from smashremix_extra.image_appender import append_image, get_image_data, ImageMode
from smashremix_extra.constants import SMASHREMIX_PATH as smashremix_path, VARIANT_TYPES
from smashremix_extra.asm_util import add_to_scope, add_to_scope_on_empty, add_to_label, add_to_label_on_empty
from smashremix_extra.rom_util import run_windows_command, extract_files
from smashremix_extra.smashremix.kirbyshared import kirby_shared
from smashremix_extra.logger import logger
from smashremix_extra import file_manager
from smashremix_extra.character.processor import CharacterProcessor
from smashremix_extra.character.bio_overflow import apply_bio_overflow_patches, write_bio_overflow_asm
from smashremix_extra.stage.processor import StageProcessor
from smashremix_extra.extra_import.processor import ExtraImportProcessor, EXTRA_IMPORTS_ASM
from smashremix_extra.audio.processor import AudioProcessor, ASM_HEADROOM
from smashremix_extra.injector import ROMInjector, MODIFIED_FILES
from smashremix_extra.injector.file_appender import pad_to_alignment
from smashremix_extra.content_filter import filter_folders, load_content_config

# original_extra.z64 must stay 64KB-aligned so Boot.asm can address the ASM
# bank with a bare `lui a0, HI`. Keep in sync with ROMInjector.save().
ROM_ALIGNMENT = 0x10000

# Most flash carts and iOS emulators refuse ROMs at or above 64 MiB.
ROM_SIZE_LIMIT = 64 * 1024 * 1024

# Replace Character.asm's REMIX_1P / ALLSTAR SRAM.block lines: RAM keeps 32-byte
# records, SRAM gets 16 (see rec_pack_ in BONUS_PACKED_BLOCK_ASM).
ONEP_PACKED_BLOCK_ASM = """\
    {name}_HIGH_SCORE_TABLE_BLOCK:
    dw      SRAM.address
    dw      pc() + 0xC
    dw      NUM_CHARACTERS * 0x10
    dw      0
    fill    NUM_CHARACTERS * 0x20
    SRAM.address = SRAM.address + (NUM_CHARACTERS * 0x10)"""

# Replaces Bonus.asm's REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK line; see
# CharacterAppender._patch_bonus_sram_packing(). Same block header as
# SRAM.block(), but the RAM table keeps 6-byte entries while SRAM gets 5.
BONUS_PACKED_BLOCK_ASM = """\
    constant BONUS_ENTRIES(NUM_BONUS_STAGES * Character.NUM_CHARACTERS)
    constant BONUS_PACKED_SIZE(((BONUS_ENTRIES * 5 + 0xF) / 0x10) * 0x10)
    REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK:
    dw      SRAM.address
    dw      pc() + 0xC
    dw      BONUS_PACKED_SIZE
    dw      0
    fill    BONUS_ENTRIES * 6
    SRAM.address = SRAM.address + BONUS_PACKED_SIZE
    OS.align(4)

    // @ Description
    // SRAM.write_ wrapper: packed tables (Remix Bonus, Remix 1P, All-Star) are packed in
    // place, written, then unpacked again; everything else is a plain write.
    // a0 - RAM source, a1 - SRAM destination, a2 - size
    scope sram_write_packed_: {
        li      t0, remix_bonus_high_score_table
        beq     a0, t0, _packed
        lli     t1, 0x0000                  // t1 = 0: Bonus layout
        li      t0, Character.REMIX_1P_HIGH_SCORE_TABLE
        beq     a0, t0, _packed
        lli     t1, 0x0001                  // t1 = 1: 1P record layout
        li      t0, Character.ALLSTAR_HIGH_SCORE_TABLE
        beq     a0, t0, _packed
        nop
        j       SRAM.write_                 // not a packed table: plain write
        nop

        _packed:
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0014(sp)              // save registers
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        jal     pack_table_                 // a0 = table, t1 = layout
        sw      t1, 0x0010(sp)              // ~
        lw      a0, 0x0004(sp)              // restore arguments
        lw      a1, 0x0008(sp)              // ~
        jal     SRAM.write_
        lw      a2, 0x000C(sp)              // ~
        lw      a0, 0x0004(sp)              // a0 = table
        jal     unpack_table_               // restore the RAM layout
        lw      t1, 0x0010(sp)              // t1 = layout
        lw      ra, 0x0014(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // SRAM.read_ wrapper: packed tables are unpacked in place after reading.
    // a0 - SRAM source, a1 - RAM destination, a2 - size
    scope sram_read_packed_: {
        li      t0, remix_bonus_high_score_table
        beq     a1, t0, _packed
        lli     t1, 0x0000                  // t1 = 0: Bonus layout
        li      t0, Character.REMIX_1P_HIGH_SCORE_TABLE
        beq     a1, t0, _packed
        lli     t1, 0x0001                  // t1 = 1: 1P record layout
        li      t0, Character.ALLSTAR_HIGH_SCORE_TABLE
        beq     a1, t0, _packed
        nop
        j       SRAM.read_                  // not a packed table: plain read
        nop

        _packed:
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0014(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~
        jal     SRAM.read_
        sw      t1, 0x0010(sp)              // ~
        lw      a0, 0x0008(sp)              // a0 = table
        jal     unpack_table_
        lw      t1, 0x0010(sp)              // t1 = layout
        lw      ra, 0x0014(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // a0 = table, t1 = layout (0 = Bonus, 1 = 1P record)
    scope pack_table_: {
        beqz    t1, bonus_pack_
        nop
        b       rec_pack_
        nop
    }

    scope unpack_table_: {
        beqz    t1, bonus_unpack_
        nop
        b       rec_unpack_
        nop
    }

    // @ Description
    // Packs Character.NUM_CHARACTERS 32-byte 1P records at a0 into 16 bytes each, front to back.
    // Only bytes 0x00-0x0C and 0x1D are ever written (vanilla's 1P record writer at 0x800D6738);
    // the rest stay 0. Keep 0x00-0x0E and carry 0x1D in the always-zero byte 0x0F.
    scope rec_pack_: {
        or      t0, a0, r0                  // t0 = 32-byte read cursor
        or      t1, a0, r0                  // t1 = 16-byte write cursor
        lli     t2, Character.NUM_CHARACTERS // t2 = records left
        _loop:
        lw      t3, 0x0000(t0)
        lw      t4, 0x0004(t0)
        lw      t5, 0x0008(t0)
        lw      t6, 0x000C(t0)
        lbu     t7, 0x001D(t0)
        srl     t6, t6, 8
        sll     t6, t6, 8
        or      t6, t6, t7                  // byte 0x0F = byte 0x1D
        sw      t3, 0x0000(t1)
        sw      t4, 0x0004(t1)
        sw      t5, 0x0008(t1)
        sw      t6, 0x000C(t1)
        addiu   t0, t0, 0x0020
        addiu   t2, t2, -0x0001
        bnez    t2, _loop
        addiu   t1, t1, 0x0010
        jr      ra
        nop
    }

    // @ Description
    // Inverse of rec_pack_, back to front so unpacked records never overwrite unread packed ones.
    scope rec_unpack_: {
        lli     t2, Character.NUM_CHARACTERS // t2 = records left
        addiu   t0, t2, -0x0001
        sll     t1, t0, 5
        addu    t1, a0, t1                  // t1 = last 32-byte record
        sll     t0, t0, 4
        addu    t0, a0, t0                  // t0 = last 16-byte record
        _loop:
        lw      t3, 0x0000(t0)
        lw      t4, 0x0004(t0)
        lw      t5, 0x0008(t0)
        lw      t6, 0x000C(t0)
        andi    t7, t6, 0x00FF              // t7 = byte 0x1D
        srl     t6, t6, 8
        sll     t6, t6, 8                   // byte 0x0F back to 0
        sw      t3, 0x0000(t1)
        sw      t4, 0x0004(t1)
        sw      t5, 0x0008(t1)
        sw      t6, 0x000C(t1)
        sw      r0, 0x0010(t1)
        sw      r0, 0x0014(t1)
        sw      r0, 0x0018(t1)
        sw      r0, 0x001C(t1)
        sb      t7, 0x001D(t1)
        addiu   t0, t0, -0x0010
        addiu   t2, t2, -0x0001
        bnez    t2, _loop
        addiu   t1, t1, -0x0020
        jr      ra
        nop
    }

    // @ Description
    // Packs each 6-byte entry (two 3-byte fields) into 5 bytes (two 20-bit fields), front to back.
    // Field: bit 19 = count flag (first byte 0x0A), bits 18-16 = first byte (time, <= 7), bits 15-0 = last two bytes.
    // Uses t0-t7 and at only (no mult/div: a caller keeps v0 in LO).
    scope bonus_pack_: {
        li      t0, remix_bonus_high_score_table // t0 = 6-byte read cursor
        or      t1, t0, r0                  // t1 = 5-byte write cursor (never passes t0)
        li      t2, BONUS_ENTRIES           // t2 = entries left

        _loop:
        // targets field -> t6
        lbu     t3, 0x0000(t0)
        lbu     t4, 0x0001(t0)
        lbu     t5, 0x0002(t0)
        sll     t4, t4, 8
        or      t4, t4, t5                  // t4 = last two bytes
        lli     at, 0x000A
        beq     t3, at, _t_flag             // count form
        sltiu   at, t3, 0x0008              // at = 1 if first byte fits in 3 bits
        bnez    at, _t_done                 // time form
        sll     t6, t3, 16                  // t6 = first byte << 16
        or      t4, r0, r0                  // out of range: store as an empty record
        _t_flag:
        lui     t6, 0x0008                  // t6 = count flag (bit 19)
        _t_done:
        or      t6, t6, t4                  // t6 = 20-bit targets value

        // platforms field -> t7
        lbu     t3, 0x0003(t0)
        lbu     t4, 0x0004(t0)
        lbu     t5, 0x0005(t0)
        sll     t4, t4, 8
        or      t4, t4, t5
        lli     at, 0x000A
        beq     t3, at, _p_flag
        sltiu   at, t3, 0x0008
        bnez    at, _p_done
        sll     t7, t3, 16
        or      t4, r0, r0
        _p_flag:
        lui     t7, 0x0008
        _p_done:
        or      t7, t7, t4                  // t7 = 20-bit platforms value

        srl     t3, t6, 12
        sb      t3, 0x0000(t1)              // targets bits 19-12
        srl     t3, t6, 4
        sb      t3, 0x0001(t1)              // targets bits 11-4
        sll     t3, t6, 4                   // targets bits 3-0 -> high nibble
        srl     t4, t7, 16                  // platforms bits 19-16 -> low nibble
        or      t3, t3, t4
        sb      t3, 0x0002(t1)
        srl     t3, t7, 8
        sb      t3, 0x0003(t1)              // platforms bits 15-8
        sb      t7, 0x0004(t1)              // platforms bits 7-0

        addiu   t0, t0, 0x0006
        addiu   t2, t2, -0x0001
        bnez    t2, _loop
        addiu   t1, t1, 0x0005
        jr      ra
        nop
    }

    // @ Description
    // Inverse of bonus_pack_, back to front so unpacked entries never overwrite unread packed ones.
    scope bonus_unpack_: {
        li      t0, remix_bonus_high_score_table + ((BONUS_ENTRIES - 1) * 5) // t0 = last packed entry
        li      t1, remix_bonus_high_score_table + ((BONUS_ENTRIES - 1) * 6) // t1 = last unpacked entry
        li      t2, BONUS_ENTRIES           // t2 = entries left

        _loop:
        lbu     t3, 0x0000(t0)
        lbu     t4, 0x0001(t0)
        lbu     t5, 0x0002(t0)
        lbu     t6, 0x0003(t0)
        lbu     t7, 0x0004(t0)
        sll     t8, t3, 12
        sll     t4, t4, 4
        or      t8, t8, t4
        srl     t4, t5, 4
        or      t8, t8, t4                  // t8 = 20-bit targets value
        andi    t5, t5, 0x000F
        sll     t9, t5, 16
        sll     t6, t6, 8
        or      t9, t9, t6
        or      t9, t9, t7                  // t9 = 20-bit platforms value

        srl     t3, t8, 16                  // t3 = first byte, or 8 if count flag
        sltiu   at, t3, 0x0008
        beqzl   at, pc() + 8                // if count flag, first byte = 0x0A
        lli     t3, 0x000A
        sb      t3, 0x0000(t1)
        srl     t3, t8, 8
        sb      t3, 0x0001(t1)
        sb      t8, 0x0002(t1)

        srl     t3, t9, 16
        sltiu   at, t3, 0x0008
        beqzl   at, pc() + 8
        lli     t3, 0x000A
        sb      t3, 0x0003(t1)
        srl     t3, t9, 8
        sb      t3, 0x0004(t1)
        sb      t9, 0x0005(t1)

        addiu   t0, t0, -0x0005
        addiu   t2, t2, -0x0001
        bnez    t2, _loop
        addiu   t1, t1, -0x0006
        jr      ra
        nop
    }"""


class CharacterAppender:
    def __init__(self, args):
        if not os.path.exists(os.path.join(smashremix_path, "src/File.asm")):
            print("\n"
                  f"ERROR: Smash Remix source code not found in '{smashremix_path}' folder. "
                  f"Initialize submodules (Git) or download source manually.")
            sys.exit(1)

        if not os.path.exists(os.path.join(smashremix_path, "roms/ssb.rom")):
            print("\n"
                  "ERROR: Vanilla SSB64 USA ROM titled 'ssb.rom' not in 'smashremix/roms' folder!")
            sys.exit(1)

        if not os.path.exists(os.path.join(smashremix_path, "roms/original.z64")):
            print("original.z64 not found. Trying to apply patch...")
            xdelta_exe = os.path.join(smashremix_path, "xdelta.exe")
            ssb_rom = os.path.join(smashremix_path, "roms", "ssb.rom")
            original_xdelta = os.path.join(smashremix_path, "original.xdelta")
            original_z64 = os.path.join(
                smashremix_path, "roms", "original.z64")
            result = run_windows_command(
                f'{xdelta_exe} -d -f -s {ssb_rom} {original_xdelta} {original_z64}'
            )
            if result.returncode != 0:
                print(result.stderr)
            print("OK")

        extract_files(smashremix_path)

        default_nameplate_pixels, w, h = get_image_data(
            "extra_resources/nameplate_default.png")
        name_texture_offset = append_image(
            "scripts/0011.bin", "scripts/0011.bin",
            default_nameplate_pixels, w, h, ImageMode.IA8
        )
        self.name_texture_default = f"0x{name_texture_offset:08X} + 0x10"

        default_sp_icon_pixels, w, h = get_image_data(
            "extra_resources/1p_icon.png")
        sp_icon_offset = append_image(
            "scripts/000B.bin", "scripts/000B.bin",
            default_sp_icon_pixels, w, h, ImageMode.RGBA5551
        )
        self.sp_icon_default = f"0x{sp_icon_offset:08X} + 0x10"

        content_cfg = load_content_config()

        self.char_folders = [cf for cf in os.listdir("extra_characters") if os.path.isdir(
            os.path.join("extra_characters", cf)) and not cf.startswith("_")]
        self.char_folders.sort()
        self.char_folders = filter_folders(
            self.char_folders, content_cfg.get("characters"), kind="characters"
        )

        if args.single_character:
            self.char_folders = [args.single_character]

        self.stage_folders = os.listdir("extra_stages")
        self.stage_folders = [
            sf for sf in self.stage_folders if not sf.startswith("_")]
        self.stage_folders = filter_folders(
            self.stage_folders, content_cfg.get("stages"), kind="stages"
        )

        # Check for stage variants
        self.stage_variants = []
        for sf in self.stage_folders:
            for variant_type in VARIANT_TYPES:
                variant_path = f"extra_stages/{sf}/{variant_type}"
                if os.path.isdir(variant_path):
                    self.stage_variants.append(f"{sf}/{variant_type}")

        self.stage_folders.extend(self.stage_variants)

        self.stage_folders.sort()

        if args.single_character:
            self.stage_folders = []

        if args.single_stage:
            # Build with only this stage (plus its variants) and no characters.
            variants = [
                v for v in self.stage_folders
                if v.startswith(f"{args.single_stage}/")
            ]
            self.stage_folders = [args.single_stage] + variants
            self.char_folders = []

        print(f"Extra characters: {len(self.char_folders)}")
        print(f"Extra stages: {len(self.stage_folders)}")

        self.audio_proc = AudioProcessor(
            music_selection=content_cfg.get("music")
        )
        # "vanilla": point every Remix MIDI at a vanilla SSB track instead of
        # inserting it, to free ROM space (see AudioProcessor.alias_remix_midis).
        self.remix_music = content_cfg.get("remix_music", "keep")

        last_sfx_id = 694  # Last vanilla SFX ID

        self.injected_file_num = 0

        # Count Remix's last FGM ID
        with open(os.path.join(smashremix_path, "src/FGM.asm"), 'r', encoding='utf-8') as file:
            for line in file:
                stripped_line = line.lstrip()
                if stripped_line.startswith('add_sound') or stripped_line.startswith('add_fgm'):
                    last_sfx_id += 1

        last_remix_sfx_id = last_sfx_id

        # Count Remix's last SwordTrail ID
        sword_trail_count = sum(
            1 for line in open(os.path.join(smashremix_path, 'src/SwordTrail.asm'), encoding='utf-8')
            if re.match(r'^\s*add_sword_trail\(', line))

        self.char_proc = CharacterProcessor(
            name_texture_default=self.name_texture_default,
            sp_icon_default=self.sp_icon_default,
            last_sfx_id=last_sfx_id,
            last_remix_sfx_id=last_remix_sfx_id,
            sword_trail_count=sword_trail_count,
            characters_exist=self.char_folders,
            stage_ids=self._collect_stage_ids(),
        )
        self.stage_proc = StageProcessor()
        self.import_proc = ExtraImportProcessor()

        # Delete the build folder if it exists and create a new one
        if os.path.exists("build"):
            shutil.rmtree("build")
        os.makedirs("build", exist_ok=True)

    def _collect_stage_ids(self) -> set:
        """Build the set of every valid Stages.id.X name: vanilla/remix
        stages (parsed from src/Stages.asm's `scope id { ... }` block)
        plus every extra stage folder we're about to add (using the same
        STAGE_<FOLDER> naming StageProcessor generates for them)."""
        stage_ids = set()

        stages_asm_path = "src/Stages.asm"
        if os.path.exists(stages_asm_path):
            with open(stages_asm_path, encoding="utf-8") as f:
                content = f.read()

            start = content.find("scope id {")
            if start != -1:
                depth = 0
                end = start
                for i, ch in enumerate(content[start:], start=start):
                    if ch == "{":
                        depth += 1
                    elif ch == "}":
                        depth -= 1
                        if depth == 0:
                            end = i
                            break
                block = content[start:end]
                stage_ids.update(re.findall(r"constant\s+(\w+)\s*\(", block))
        else:
            logger.warning(
                f"Could not find {stages_asm_path} to validate character singleplayer stage references against; "
                "only extra stages will be treated as valid."
            )

        for sf in self.stage_folders:
            stage_ids.add(f"STAGE_{sf.upper().replace('/', '_')}")

        return stage_ids

    def prepare_files(self):
        """Process all character and stage folders, registering files with FileManager."""
        for character_folder in self.char_folders:
            self._process_character(character_folder)

        # Continue the FGM/SFX id sequence for stage sound imports.
        self.stage_proc.LAST_SFX_ID = self.char_proc.LAST_SFX_ID

        for stage_folder in self.stage_folders:
            self._process_stage(stage_folder)

        # Extra imports' files and sounds (extra_imports/<Name>/config.yaml).
        # Their sound ids continue after the stage sounds.
        self.import_proc.LAST_SFX_ID = self.stage_proc.LAST_SFX_ID
        self.import_proc.process_all()

    def _process_character(self, character_folder):
        self.char_proc.process(character_folder)

    def _process_stage(self, stage_folder):
        self.stage_proc.process(stage_folder)

    def inject_files_in_rom(self):
        output_rom = os.path.join(smashremix_path, "roms/original_extra.z64")
        input_rom = os.path.join(smashremix_path, "roms/original.z64")

        has_imports = bool(file_manager.FileManager.get_import_files())
        # Always rebuild original_extra so size/origin stay in sync with content.
        if not self.char_folders and not self.stage_folders and not has_imports:
            # Pad here too: Boot.asm's `lui a0` can only encode the high 16 bits
            # of this file's size, so it must stay 64KB-aligned on every path.
            with open(input_rom, "rb") as f:
                rom_data = pad_to_alignment(f.read(), ROM_ALIGNMENT, pad_byte=0xFF)
            with open(output_rom, "wb") as f:
                f.write(rom_data)
            print(f"No EXTRA files to inject — copied {input_rom} -> {output_rom}")
            return

        injector = ROMInjector(
            input_rom=input_rom,
            output_rom=output_rom,
        )

        for file_id, path, tbl_off, res_off, level in MODIFIED_FILES:
            injector.modify(file_id, path, tbl_off, res_off,
                            compression_level=level)

        file_manager.FileManager.verify_aliases()
        for import_file in file_manager.FileManager.get_import_files():
            injector.add(
                file_path=import_file.path,
                tbl_offset=import_file.internal_file_table_offset,
                res_offset=import_file.internal_file_resource_offset,
                reqlist_path=import_file.reqlist_path,
                compression_level=import_file.compression_level,
            )

        injector.save(on_progress=print)

    def copy_remix_src(self):
        # Walk through all directories and files in the root folder
        print("Copying original source code into src/...")

        # Delete src/ folder if it exists
        if os.path.exists("src"):
            shutil.rmtree("src")

        os.makedirs("src", exist_ok=True)

        shutil.copytree(
            os.path.join(smashremix_path, "src"),
            "src",
            dirs_exist_ok=True,
        )

        shutil.copy(
            os.path.join(smashremix_path, "main.asm"),
            "main.asm"
        )

    def overwrite_files(self):
        # Overwrite src/ with smashremix_overwrite/. Resolved relative to this
        # file rather than CWD, since smashremix_overwrite ships alongside
        # character_appender.py and callers may run this from a different
        # working directory (e.g. a content repo that pulls this in as a
        # submodule, with its own extra_characters/build/src at CWD).
        print("Overwriting source code with custom files...")

        smashremix_overwrite_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "smashremix_overwrite")

        shutil.copytree(
            smashremix_overwrite_path,
            "src",
            dirs_exist_ok=True
        )

    def edit_src_files(self):
        original_size = os.path.getsize(os.path.join(
            smashremix_path, "roms/original_extra.z64"))

        # Boot.asm loads the ASM bank's ROM address with a bare `lui a0, HI`,
        # which can only encode the high 16 bits. If original_extra is not
        # 64KB-aligned the low bits are silently dropped and the boot DMA reads
        # from the wrong offset, yielding a ROM that boots into garbage.
        if original_size % ROM_ALIGNMENT != 0:
            print(
                f"ERROR: original_extra.z64 is {original_size} bytes, which is not "
                f"a multiple of 0x{ROM_ALIGNMENT:X} ({ROM_ALIGNMENT}).\n"
                f"       Boot.asm's `lui a0` would drop the low "
                f"0x{original_size % ROM_ALIGNMENT:X} bytes of the address."
            )
            sys.exit(1)

        # The final ROM is produced later by bass (patch_extra.bat), but its
        # floor is already known here: data + ASM region + the MIDI bank. Warn
        # now rather than after a multi-minute assemble.
        projected = original_size + ASM_HEADROOM
        print(
            f"ROM layout: data={original_size / (1024 * 1024):.3f} MiB + "
            f"ASM region={ASM_HEADROOM / (1024 * 1024):.3f} MiB "
            f"-> MIDI_BANK at {projected / (1024 * 1024):.3f} MiB"
        )
        if projected >= ROM_SIZE_LIMIT:
            print(
                f"ERROR: MIDI_BANK would start at {projected} bytes, at or past the "
                f"{ROM_SIZE_LIMIT / (1024 * 1024):.0f} MiB limit before any MIDI data.\n"
                f"       Remove content via extra_content.yaml."
            )
            sys.exit(1)

        self._patch_src_paths(original_size)
        self._patch_audio_asm(original_size)
        self._patch_character_asm()
        self._patch_stage_asm()
        self._patch_toggle_asm()
        self._patch_bonus_sram_packing()
        self._patch_sram_revision()

    def _patch_bonus_sram_packing(self):
        """
        Keep the save inside the cartridge's 32 KB SRAM.

        Bonus.REMIX_BONUS_HIGH_SCORE_TABLE holds NUM_BONUS_STAGES x
        NUM_CHARACTERS records of two 3-byte fields (targets, platforms), so it
        grows ~198 bytes per character and pushes the save past 0x8000 with more
        than one extra character. Data past 0x8000 is lost or written out of
        bounds by the emulator, which crashed the game on launch.

        Each field is either a count (first byte 0x0A) or a time <= 0x34BBF, so
        it fits in 20 bits: bit 19 = count flag, bits 18-16 = first byte, bits
        15-0 = last two bytes. The RAM table keeps its 6-byte layout (so none of
        the code that reads it changes); only SRAM holds the 5-byte packing,
        converted in place around SRAM.write_/read_.

        The Remix 1P and All-Star tables (32-byte vanilla-format records per
        character) get the same treatment: only bytes 0x00-0x0C and 0x1D are
        ever written to them, so SRAM keeps 16 bytes per record.
        """
        def sub_once(path, pattern, repl):
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            content, n = re.subn(pattern, lambda _: repl, content, flags=re.M)
            if n != 1:
                print(f"ERROR: expected one match for {pattern!r} in {path}, found {n}.")
                sys.exit(1)
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)

        sub_once("src/Bonus.asm", r"^\s*REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK:; SRAM\.block\(.*\)\s*$", BONUS_PACKED_BLOCK_ASM)
        for name in ("REMIX_1P", "ALLSTAR"):
            sub_once("src/Character.asm", rf"^\s*{name}_HIGH_SCORE_TABLE_BLOCK:; SRAM\.block\(.*\).*$",
                     ONEP_PACKED_BLOCK_ASM.format(name=name))
        sub_once("src/SRAM.asm", r"^\s*jal\s+read_\s+// read\s*$",
                 "        jal     Bonus.sram_read_packed_     // read (+EXTRA: unpacks the Remix Bonus table)")
        sub_once("src/SRAM.asm", r"^\s*jal\s+write_\s+// write\s*$",
                 "        jal     Bonus.sram_write_packed_    // write (+EXTRA: packs the Remix Bonus table)")

        # Remix only prints a warning when SRAM overflows; fail the build instead.
        with open("main.asm", "a", encoding="utf-8") as f:
            f.write(
                "\n// +EXTRA: save data must fit the cartridge's 32 KB SRAM\n"
                'print "+EXTRA: SRAM uses ", SRAM.address, " of 32768 bytes\\n"\n'
                "if SRAM.address > 0x8000 {\n"
                '    error "Save data exceeds 32 KB SRAM: remove content via extra_content.yaml"\n'
                "}\n"
            )

    def _patch_sram_revision(self):
        """
        Derive SRAM.REVISION from the built content selection.

        src/SRAM.asm says REVISION must be incremented whenever a stage, a MIDI,
        or a toggle is added, or the toggle order changes. This build does all of
        those: menu-music toggles are appended and Toggles.asm's MAX_VALUE is
        rewritten, which resizes block_music and therefore SHIFTS the SRAM
        offsets of every block after it (block_stages, block_pokemon,
        block_tags -- see the SRAM.block chain in src/Toggles.asm).

        REVISION is what tells check_saved_() to distrust an old save. Leaving it
        at Remix's stock value means a save written by a different content
        selection is treated as valid, and the game reads toggle/tag data from
        offsets that have moved -- garbage that can crash on boot. That matches
        the observed symptom: fresh save works, second launch crashes.

        Hashing the selection (rather than incrementing) means any change to the
        roster, stages, or music automatically invalidates stale saves, and the
        same selection keeps a stable revision so saves survive rebuilds.
        """
        selection = repr([
            sorted(self.char_folders),
            sorted(self.stage_folders),
            sorted(self.audio_proc.midi_files_list),
        ]).encode("utf-8")
        # The final Toggles.asm defines the SRAM block layout (gameplay and
        # menu-music toggles included) and SRAM.asm still holds Remix's stock
        # REVISION, so a change to either must also invalidate saves.
        for path in ("src/Toggles.asm", "src/SRAM.asm"):
            with open(path, "rb") as f:
                selection += f.read()
        # ...and so must a change to how the high-score tables are packed.
        selection += (BONUS_PACKED_BLOCK_ASM + ONEP_PACKED_BLOCK_ASM).encode("utf-8")

        # REVISION is read with `lli`, a 16-bit immediate, so it must fit in
        # 0x0000-0xFFFF. Stay clear of stock values to avoid colliding with a
        # save written by upstream Remix.
        revision = 0x1000 + (int(hashlib.sha256(selection).hexdigest(), 16) % 0xF000)

        print(
            f"SRAM revision: 0x{revision:04X} "
            f"({len(self.char_folders)} characters, {len(self.stage_folders)} stages, "
            f"{len(self.audio_proc.midi_files_list)} extra MIDIs)"
        )

        lineinfile.add_line_to_file(
            filepath="src/SRAM.asm",
            line=f'    constant REVISION(0x{revision:04X})',
            regexp=r'.*constant REVISION\(.*\)'
        )

    def _patch_src_paths(self, original_size):
        # main.asm
        # In all .asm files in src/, replace paths.
        # These paths get embedded as text for the assembler (bass) to resolve
        # at assembly time, run with CWD at the content repo root - so unlike
        # smashremix_path's own (possibly absolute, __file__-anchored) value
        # used for this script's own file I/O, what we embed here must be a
        # path relative to CWD, or bass ends up trying to resolve an absolute
        # path relative to itself.
        smashremix_path_relative = os.path.relpath(
            smashremix_path, os.getcwd())
        asm_files = []

        for root, dirs, files in os.walk("src"):
            for file in files:
                if file.endswith(".asm"):
                    filepath = os.path.join(root, file)

                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()

                    content = content.replace(
                        "../build/", f"../{smashremix_path_relative}/build/")
                    content = content.replace(
                        "roms/original.z64", f"{smashremix_path_relative}/roms/original_extra.z64")

                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)

        with open("main.asm", 'r', encoding='utf-8') as f:
            main_content = f.read()

        main_content = main_content.replace(
            "assembler/", f"{smashremix_path_relative}/assembler/")
        main_content = main_content.replace(
            "roms/original.z64", f"{smashremix_path_relative}/roms/original_extra.z64")

        # Stock Remix pads the ROM by writing one byte at 0x3E7FFFF. Once the
        # MIDI bank runs past that address the pad overwrites a byte of
        # MIDI/sample/FGM data, so only pad when the bank ends before it. Also
        # fail the assemble if the final ROM reaches the size limit.
        main_content, n = re.subn(
            r'origin\s+0x3E7FFFF\s*\n\s*db\s+0x00',
            "if MIDI.MIDI_BANK_END < 0x3E80000 {\n"
            "    origin 0x3E7FFFF\n"
            "    db 0x00\n"
            "}\n"
            f"if MIDI.MIDI_BANK_END >= 0x{ROM_SIZE_LIMIT:X} {{\n"
            '    error "ROM reaches 64 MiB: remove content via extra_content.yaml"\n'
            "}",
            main_content,
        )
        if n != 1:
            print("ERROR: stock ROM padding (origin 0x3E7FFFF) not found in main.asm; "
                  "update _patch_src_paths to match the new Remix layout.")
            sys.exit(1)

        with open("main.asm", 'w', encoding='utf-8') as f:
            f.write(main_content)

        # Insert new character asm files before Kirby
        lineinfile.add_line_to_file(
            filepath="main.asm",
            line="// Extra characters\n"+"\n".join(
                [f'include "build/extra_characters/{name}/main.asm"' for name in self.char_folders]),
            inserter=lineinfile.BeforeFirst(r"\/\/ KIRBY")
        )

        # Update internal name
        lineinfile.add_line_to_file(
            filepath="main.asm",
            line='db "REMIX EXTRA"',
            regexp=r'db\s+"SMASH REMIX"'
        )

        lineinfile.add_line_to_file(
            filepath="main.asm",
            line=f'origin 0x{original_size:08X}',
            regexp=r'origin\s+0x[0-9A-Fa-f]{8}'
        )

        # Extend file table size
        lineinfile.add_line_to_file(
            filepath="main.asm",
            line="fill 0x800",
            regexp=r'fill .*',
            inserter=lineinfile.AfterLast(r"file_table:.*\n")
        )

        # Fail the assembly if the ASM region (code + midi_memory_block +
        # file_table + custom_heap) grows past MIDI_BANK. Only bass knows where
        # custom_heap actually lands, so this has to be checked at assemble time
        # rather than from Python. Without it, an overflow silently overwrites
        # the MIDI bank and starves the runtime heap.
        # Boot.asm DMAs ((custom_heap - base) >> 16) + 1 64KB blocks, so check
        # that copy's end, not custom_heap itself; otherwise the tail of the copy
        # loads MIDI bank bytes into RAM above custom_heap.
        boot_dma = "((((custom_heap - 0x80400000) >> 16) + 1) << 16)"
        lineinfile.add_line_to_file(
            filepath="main.asm",
            line=(
                "\n// +EXTRA: guard against the ASM region colliding with MIDI_BANK\n"
                'print "+EXTRA: ASM region uses ", custom_heap - 0x80400000, '
                f'" (boot DMA ", {boot_dma}, ") of ", '
                f'MIDI.MIDI_BANK - 0x{original_size:08X}, " bytes\\n"\n'
                f"if {boot_dma} > (MIDI.MIDI_BANK - 0x{original_size:08X}) {{\n"
                '    error "ASM region overflows MIDI_BANK: reduce content or '
                'raise ASM_HEADROOM in smashremix_extra/audio/processor.py"\n'
                "}"
            ),
            inserter=lineinfile.AfterLast(r"custom_heap:.*\n")
        )

        # Boot.asm
        original_size_str = f'{original_size:08X}'

        lineinfile.add_line_to_file(
            filepath="src/Boot.asm",
            line=f'\t\tlui\t\ta0, 0x{original_size_str[:4]}',
            regexp=r'.*load rom address.*'
        )

        # Get version string
        version_string = ""
        with open("src/Boot.asm", 'r') as f:
            for line in f:
                m = re.match(
                    r'.*string_version:; String.insert\(\"(.*)\"\)', line)
                if m:
                    version_string = m.group(1)
                    break

        version_txt_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "version.txt")
        with open(version_txt_path, 'r', encoding='utf-8') as f:
            extra_version = f.read()
        lineinfile.add_line_to_file(
            filepath="src/Boot.asm",
            line=f'\tstring_version:; String.insert("{version_string} {extra_version}")',
            regexp=r'.*string_version.*'
        )

    def _patch_audio_asm(self, original_size):
        self.audio_proc.load()
        self.audio_proc.patch_midi_asm(
            original_size,
            self.char_proc.victory_theme_strings,
            self.char_proc.midi_priority_overrides,
            self.char_proc.midi_bend_range_overrides,
            self.char_proc.midi_master_volume_overrides,
        )
        if self.remix_music == "vanilla":
            # MIDIs still inserted with their own data: EXTRA victory themes and music packs
            external = re.findall(r"insert_external_midi\(\w+, \.\./([^,]+),",
                                  "\n".join(self.char_proc.victory_theme_strings + self.audio_proc.midi_files_list))
            self.audio_proc.alias_remix_midis([f"{p}.bin" for p in external])
        elif self.remix_music != "keep":
            print(f"ERROR: extra_content.yaml remix_music must be 'keep' or 'vanilla', got {self.remix_music!r}")
            sys.exit(1)

    def _patch_character_asm(self):
        # File.asm
        lineinfile.add_line_to_file(
            filepath="src/File.asm",
            line="\n".join(
                [f"\tconstant {import_file.name.upper()}(0x{import_file.id:04X})" for import_file in file_manager.FileManager.get_all_files()]),
            inserter=lineinfile.AfterLast(r"constant")
        )

        # filename_overrides.txt
        shutil.copy(
            os.path.join(smashremix_path, "roms/filename_overrides.txt"),
            os.path.join(smashremix_path, "roms/filename_overrides_extra.txt")
        )

        lineinfile.add_line_to_file(
            filepath=os.path.join(
                smashremix_path, "roms/filename_overrides_extra.txt"),
            line="\n".join(
                [f"{import_file.id:04X} {import_file.name.upper()}" for import_file in file_manager.FileManager.get_import_files()]),
            inserter=lineinfile.BeforeLast(r"^\s*$")
        )

        # Character.asm
        # Get ADD_CHARACTERS value
        add_characters_value = 0
        with open("src/Character.asm", 'r', encoding='utf-8') as f:
            for line in f:
                m = re.match(r'.*constant ADD_CHARACTERS\((.*)\)', line)
                if m:
                    add_characters_value = int(m.group(1))
                    break

        lineinfile.add_line_to_file(
            filepath="src/Character.asm",
            line=f'\tconstant ADD_CHARACTERS({
                add_characters_value+len(self.char_folders)})',
            regexp=r'.*constant ADD_CHARACTERS\(.*\)'
        )

        lineinfile.add_line_to_file(
            filepath="src/Character.asm",
            line="\t"+"\n\t".join(self.char_proc.character_defs),
            inserter=lineinfile.AfterLast(r".*ADD NEW CHARACTERS HERE")
        )

        # CharacterSelect.asm
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\n".join(
                [f"\tdb Character.id.{name.upper()}" for name in self.char_proc.bonus_chars]),
            inserter=lineinfile.AfterFirst(r"db Character.id.PIANO")
        )

        num_bonus_chars = 0
        with open("src/CharacterSelect.asm", 'r') as f:
            for line in f:
                m = re.match(r'.*constant NUM_BONUS_CHARS\((.*)\)', line)
                if m:
                    num_bonus_chars = int(m.group(1))
                    break

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line=f'\tconstant NUM_BONUS_CHARS({
                num_bonus_chars+len(self.char_proc.bonus_chars)})',
            regexp=r'.*constant NUM_BONUS_CHARS\(.*\)'
        )

        main_sizes = [
            f"dw {hex(os.path.getsize("./build/extra_characters/"+char_folder+"/character.bin"))} + 0x200 // {char_folder.upper()}" for char_folder in self.char_folders
        ]

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t"+"\n\t".join(main_sizes),
            inserter=lineinfile.AfterFirst(r".*ADD NEW CHARACTERS HERE")
        )

        model_req_strings = [
            f"add_alt_req_list(Character.id.{character.upper()}, ../build/extra_characters/{character}/MODEL_REQ)" for character in self.char_folders
        ]

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\n\t// EXTRA\n\t"+"\n\t".join(model_req_strings),
            inserter=lineinfile.AfterLast(r".*add_alt_req_list\(Character.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t"+"\n\t".join(self.char_proc.add_to_css_strings),
            inserter=lineinfile.AfterLast(r".*ADD NEW CHARACTERS HERE")
        )

        # # Sonic's alt_malloc_table entry sums his main model (0x16320) and Classic Sonic's model
        # # (0x170F0); the 0x22260 term doesn't correspond to any known file and is dropped here.
        # lineinfile.add_line_to_file(
        #     filepath="src/CharacterSelect.asm",
        #     line=f'\tdw  0x16320 + 0x200 + 0x170F0 + 0x200 // 0x3B - SONIC',
        #     regexp=r'.*0x16320 \+ 0x22260 \+ 0x170E8 \+ 0x200.*'
        # )

        # Increase dynamic css heap size
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line=f'\t\tconstant HEAP_SIZE(0x0001D000)',
            regexp=r'.*constant HEAP_SIZE\(.*\)'
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line=f'\t\tconstant ACTIVE_HEAP_COUNT(5)',
            inserter=lineinfile.AfterLast(r'.*constant HEAP_SIZE\(.*\)')
        )

        # Change ram threshold
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line=f'\t\tlui t7, 0x8050 // t7 = ram threshold',
            regexp=r'\s*lui\s*t7, 0x8078'
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line=f'\t\tlui t7, 0x8050 // t7 = ram threshold',
            regexp=r'\s*lui\s*t7, 0x8078'
        )

        for _ in range(2):
            lineinfile.add_line_to_file(
                filepath="src/CharacterSelect.asm",
                line=(f'\t\tlli s2, dynamic_css.ACTIVE_HEAP_COUNT '
                      '// s2 = loop index'),
                regexp=r'\s*lli\s+s2, 0x0008\s+// s2 = loop index'
            )

        for _ in range(2):
            lineinfile.add_line_to_file(
                filepath="src/CharacterSelect.asm",
                line=(f'\t\tlli t2, dynamic_css.ACTIVE_HEAP_COUNT - 1 '
                      '// t2 = times to loop - 1'),
                regexp=r'\s*lli\s+t2, 0x0007\s+// t2 = times to loop - 1'
            )

        # clear_first_obsolete_heap_slot_'s eviction search has no bound of its own - it walks past
        # heap_slot_0 looking for a slot not currently claimed by a player, trusting that with 8
        # slots and at most 4 players one is always spare. With only ACTIVE_HEAP_COUNT slots actually
        # initialized above, if it didn't find a candidate in range it would fall through into
        # heap_slot_4+, whose backing heap_struct was never given a real floor/ceiling (they're
        # left zeroed), so malloc would then hand out memory from a null heap - this is what was
        # causing the malloc errors/instability with 4 players on the CSS at once.
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t\t"+"\n\t\t".join([
                'slti    at, v0, dynamic_css.ACTIVE_HEAP_COUNT // at = 1 if v0 is still a real slot',
                'beqz    at, _out_of_slots // if v0 ran past the real slots, stop and fall back instead of reading garbage']),
            inserter=lineinfile.AfterFirst(
                r'addiu\s+v0,\s*v0,\s*0x0001\s+// v0 = next heap slot')
        )

        # If no obsolete slot is found, fall back to a second pass that only enforces the hard
        # safety rule (never evict a slot that's char_id-matched to one of the 4 currently active
        # players, t1-t4) and drops the softer "was used last frame" anti-flicker rule. With
        # ACTIVE_HEAP_COUNT(5) real slots holding at most 4 distinct active character ids, at least
        # one slot can never match t1-t4, so this pass is guaranteed to find a genuinely safe slot
        # instead of corrupting a live one. _forced_zero is an unreachable safety net in case that
        # guarantee is ever violated.
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t\t"+"\n\t\t".join([
                '_out_of_slots:',
                'li      t0, dynamic_css.heap_slot_0',
                'addiu   v0, r0, -0x0001',
                '_loop_2:',
                'addiu   v0, v0, 0x0001   // v0 = next heap slot',
                'slti    at, v0, dynamic_css.ACTIVE_HEAP_COUNT // at = 1 if v0 is still a real slot',
                'beqz    at, _forced_zero // unreachable in practice; force-reuse slot 0 rather than read past the array',
                'lw      at, 0x0004(t0)   // at = slot\'s char_id',
                'beql    at, t1, _loop_2  // if slot\'s char_id still in use, skip',
                'addiu   t0, t0, 0x0010   // t0 = next heap slot address',
                'beql    at, t2, _loop_2',
                'addiu   t0, t0, 0x0010',
                'beql    at, t3, _loop_2',
                'addiu   t0, t0, 0x0010',
                'beql    at, t4, _loop_2',
                'addiu   t0, t0, 0x0010',
                'b       _clear',
                'nop',
                '_forced_zero:',
                'lli     v0, 0x0000 // v0 = 0'
            ]),
            inserter=lineinfile.BeforeFirst(r'\s*_clear:')
        )

        # Character Data uses its own heap recycler
        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t\t"+"\n\t\t".join([
                'OS.read_byte(Global.current_screen, t7)',
                'lli     t8, Global.screen.DATA_CHARACTERS',
                'beq     t7, t8, _normal_load',
                'nop'
            ]),
            inserter=lineinfile.BeforeLast(r".*// Custom heap Logic:")
        )

        idStrings = []
        offsetStrings = []
        xyStrings = []
        dwStrings = []

        LAST_SERIES_ID = 0
        with open("src/CharacterSelect.asm", 'r', encoding='utf-8') as f:
            lines = f.readlines()

            in_scope = False
            constant = ''

            for i, line in enumerate(lines):
                if "scope series_logo" in line:  # Detect the scope
                    in_scope = True

                if in_scope and 'constant' in line:  # Detect the last constant
                    constant = line

                if in_scope and line.strip() == '':  # Update id with last constant's value if line is empty
                    match = re.search(r'(\d[0-9]*)', constant)
                    self.LAST_SERIES_ID = int(match.group(0))
                    break

        for cf, series_texture in self.char_proc.character_series_textures.items():
            self.LAST_SERIES_ID += 1
            idStrings.append(
                f'constant {cf.upper()}({self.LAST_SERIES_ID})'
            )

            offsetStrings.append(
                f'constant {cf.upper()}({series_texture.get("offset")})'
            )

            xyStrings.append(
                f'constant X_{cf.upper()}({series_texture.get("x")})'
            )

            xyStrings.append(
                f'constant Y_{cf.upper()}({series_texture.get("y")})'
            )

            dwStrings.append(
                f'dw offset.{cf.upper()}, position.X_{cf.upper()}, position.Y_{cf.upper()}'
            )

        for sf, series_texture in self.stage_proc.stage_series_textures.items():
            self.LAST_SERIES_ID += 1
            idStrings.append(
                f'constant {sf.upper()}({self.LAST_SERIES_ID})'
            )

            offsetStrings.append(
                f'constant {sf.upper()}({series_texture.get("offset")})'
            )

            xyStrings.append(
                f'constant X_{sf.upper()}({series_texture.get("x")})'
            )

            xyStrings.append(
                f'constant Y_{sf.upper()}({series_texture.get("y")})'
            )

            dwStrings.append(
                f'dw offset.{sf.upper()}, position.X_{sf.upper()}, position.Y_{sf.upper()}'
            )

        add_to_scope_on_empty("src/CharacterSelect.asm",
                              "scope series_logo", idStrings)
        add_to_scope("src/CharacterSelect.asm", "scope offset", offsetStrings)
        add_to_scope("src/CharacterSelect.asm", "scope position", xyStrings)

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\t\t"+"\n\t\t".join(dwStrings),
            inserter=lineinfile.AfterLast(
                r"^\s*(dw offset)\.*")
        )

        add_to_scope("src/CharacterSelect.asm", "scope portrait_offsets",
                     ["// extra"] + self.char_proc.character_portrait_defs)

        offsetStrings = []
        variantStrings = []
        for cf, variant_icon in self.char_proc.css_dpad_icons.items():
            offsetStrings.append(
                f"constant {cf.upper()}(0x{variant_icon:0X} + 0x10)"
            )

            variantStrings.append(
                f"\t\tlli     t2, Character.id.{cf.upper()}\n"
                f"\t\tbeql    a1, t2, _draw_icon          // If {cf.upper()}, then draw {cf.upper()} stock icon\n"
                f"\t\taddiu   a1, at, VARIANT_ICON_OFFSET.{cf.upper()} // a1 = {cf.upper()} footer struct"
            )

        add_to_scope("src/CharacterSelect.asm",
                     "scope VARIANT_ICON_OFFSET", offsetStrings)

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelect.asm",
            line="\n".join(variantStrings),
            inserter=lineinfile.AfterLast(r".*// a1 = ROY footer struct")
        )

        # CharacterDataScreen.asm
        lineinfile.add_line_to_file(
            filepath="src/CharacterDataScreen.asm",
            line="\t// Extra characters\n\t" +
            "\n\t".join(self.char_proc.character_data_screen_defs) +
            "\n\t",
            inserter=lineinfile.BeforeLast(
                r".*extend_tables\(\)")
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterDataScreen.asm",
            line="\t// Extra characters\n\t" +
            "\n\t".join(self.char_proc.character_data_screen_order),
            inserter=lineinfile.AfterLast(
                r".*set_char_order\(.*\)")
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterDataScreen.asm",
            line="\t\t" +
            "\n\t\t".join(self.char_proc.data_screen_big_border_defs),
            inserter=lineinfile.AfterLast(
                r".*// branch to use large border")
        )

        self.audio_proc.patch_bgm_asm()

        # FGM.asm - character sounds, then stage sounds, then extra import sounds
        # (matches the order LAST_SFX_ID was advanced, so the generated FGM ids stay correct).
        lineinfile.add_line_to_file(
            filepath="src/FGM.asm",
            line="\t"+"\n\t".join(
                self.char_proc.sound_add_list + self.stage_proc.sound_add_list +
                self.import_proc.sound_add_list),
            inserter=lineinfile.AfterLast(
                r"^\s*(add_sound|add_fgm|add_sound_advanced)\(.*")
        )

        # resultsscreen.asm
        lineinfile.add_line_to_file(
            filepath="src/resultsscreen.asm",
            line="\t"+"\n\t".join(self.char_proc.results_screen_defs),
            inserter=lineinfile.AfterLast(r".*ADD NEW CHARACTERS HERE")
        )

        lineinfile.add_line_to_file(
            filepath="src/resultsscreen.asm",
            line="\t\t"+"\n\t\t".join(self.char_proc.results_j_win_defs),
            inserter=lineinfile.AfterLast(r".*// a0 = offset to \"WIN!\"")
        )

        offsetStrings = []
        zoomStrings = []
        colorStrings = []

        for cf, series_model in self.char_proc.character_series_models.items():
            offsetStrings.append(
                f'constant {cf.upper()}({series_model.get("offset")})'
            )

            zoomStrings.append(
                f'constant {cf.upper()}({series_model.get("zoom")})'
            )

            colorStrings.append(
                f'constant {cf.upper()}({series_model.get("color")})'
            )

        add_to_scope("src/resultsscreen.asm", "series_logo:", offsetStrings)
        add_to_scope("src/resultsscreen.asm", "series_logo_zoom:", zoomStrings)
        add_to_scope("src/resultsscreen.asm",
                     "series_logo_color:", colorStrings)

        # yoshishared.asm
        # yoshi_jump
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_jump_defs),
            inserter=lineinfile.AfterLast(
                r".*beq     a0, v0, _yoshi_dj_1")
        )
        # yoshi_shield
        _shield_inserter_patterns = [
            r".*beq     t7, at, _yoshi_shield_1",
            r".*beq     t9, at, _yoshi_shield_2",
            r".*beq     t6, at, _yoshi_shield_3",
            r".*beq     t8, at, _yoshi_shield_4",
            r".*beq     t1, at, _yoshi_shield_5",
            r".*beq     t7, at, _yoshi_shield_6",
            r".*beq     v1, at, _yoshi_shield_7",
            r".*beq     t8, at, _yoshi_shield_8",
        ]
        for i, pattern in enumerate(_shield_inserter_patterns):
            lineinfile.add_line_to_file(
                filepath="src/yoshishared.asm",
                line="\t"+"\n\t".join(self.char_proc.yoshi_shield_defs[i]),
                inserter=lineinfile.AfterLast(pattern)
            )
        # yoshi_grab
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_grab1_defs),
            inserter=lineinfile.AfterLast(
                r".*beq     at, v0, _yoshi_grab_1")
        )
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_grab2_defs),
            inserter=lineinfile.AfterLast(
                r".*beq     at, v0, _yoshi_grab_2")
        )
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_throw1_defs),
            inserter=lineinfile.AfterLast(
                r".*beq     at, v0, _yoshi_throw_1")
        )
        # yoshi_recover
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_recover_defs),
            inserter=lineinfile.AfterLast(
                r".*beq     at, v0, _yoshi_recover_1")
        )
        # yoshi_upspecial
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_upspecial_defs),
            inserter=lineinfile.AfterLast(
                r".*li      a1, upspecial_struct_jyoshi     // JYOSHI File Pointer placed in correct location")
        )
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_upspecialstruct_defs),
            inserter=lineinfile.BeforeLast(
                ".*}")
        )
        # yoshi_downspecial
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_downspecial_defs),
            inserter=lineinfile.AfterLast(
                r".*li      a1, downspecial_struct_jyoshi   // JYOSHI File Pointer placed in correct location")
        )
        lineinfile.add_line_to_file(
            filepath="src/yoshishared.asm",
            line="\t"+"\n\t".join(self.char_proc.yoshi_downspecialstruct_defs),
            inserter=lineinfile.BeforeLast(
                ".*}")
        )

        # dkshared.asm
        # cargo_hold_fix_1
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_1),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _dkcargo_jump_1.*")
        )
        # cargo_hold_fix_2
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_2),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _dkcargo_jump_2.*")
        )
        # cargo_item_fix_1
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_3),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_1.*")
        )
        # cargo_item_fix_2
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_4),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_2.*")
        )
        # cargo_item_fix_3
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_5),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_3.*")
        )
        # cargo_item_fix_4
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_6),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_4.*")
        )
        # cargo_item_fix_5
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_7),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_5.*")
        )
        # cargo_item_fix_6
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cargo_defs_8),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, _item_jump_6.*")
        )
        # fully_charged_check_
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_fully_charged_defs),
            inserter=lineinfile.BeforeFirst(
                r".*beq\s*v0, at, j_0x800EAC64\s*// if JDK, take DK branch.*")
        )
        # kirby_power_check_flash_
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_kirby_flash_defs),
            inserter=lineinfile.BeforeFirst(
                r".*beq\s*v1, at, j_0x800E9A18\s*// if JDK, take DK branch.*")
        )
        # kirby_power_change_
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_kirby_power_defs),
            inserter=lineinfile.BeforeFirst(
                r".*beq\s*v0, at, j_0x80161EF0\s*// if JDK, take DK branch.*")
        )
        # giant_punch_fix_1
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_giant_punch_defs),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v0, at, check_action_giant_punch_.*")
        )
        # cpu_fix_2
        lineinfile.add_line_to_file(
            filepath="src/dkshared.asm",
            line="\t"+"\n\t".join(self.char_proc.dk_cpu_fix_2_defs),
            inserter=lineinfile.AfterLast(
                r".*beq\s*v1, at, _cpu_2.*")
        )

        # Inject patches related to Kirby clones
        kirby_shared.Inject()

        # Training.asm
        nameStrings = []
        dwStrings = []
        dbStrings = []
        idStrings = []
        registerCharacterStrings = []

        for i, cf in enumerate(self.char_folders):
            nameStrings.append(
                f'string_{cf.lower().replace(" ", "_")}:; '
                f'char_Ex{i:02X}:; db "{self.char_proc.character_names[i]}", 0x00'
            )

            dwStrings.append(
                f'dw char_Ex{i:02X}'
            )

            dbStrings.append(
                f'db Character.id.{cf.upper()}'
            )

            idStrings.append(
                f'db id.{cf.upper()}'
            )

            registerCharacterStrings.append(
                f'register_character_id({cf.upper()})'
            )

        lineinfile.add_line_to_file(
            filepath="src/Training.asm",
            line="\t"+"\n\t".join(nameStrings),
            inserter=lineinfile.AfterLast(r".*string_.*0x00")
        )

        lineinfile.add_line_to_file(
            filepath="src/Training.asm",
            line="\t"+"\n\t".join(dwStrings),
            inserter=lineinfile.BeforeLast(r".*dw char_0x0D.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/Training.asm",
            line="\t"+"\n\t".join(dbStrings),
            inserter=lineinfile.BeforeLast(r".*db Character\.id\.METAL.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/Training.asm",
            line="\t"+"\n\t".join(idStrings),
            inserter=lineinfile.AfterLast(r".*// ADD NEW CHARACTERS.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/Training.asm",
            line="\t\t"+"\n\t\t".join(registerCharacterStrings),
            inserter=lineinfile.AfterFirst(r".*// ADD BONUS CHARACTERS HERE.*")
        )

        # SwordTrail.asm
        lineinfile.add_line_to_file(
            filepath="src/SwordTrail.asm",
            line="\t"+"\n\t".join(self.char_proc.sword_trail_add_list),
            inserter=lineinfile.AfterLast(r'^\s*add_sword_trail\(')
        )

        # Costumes.asm
        costume_list = [
            f"db 0x{(self.char_proc.character_skins[n]-1):02X} // {c.upper()}" for n, c in enumerate(self.char_folders)
        ]

        lineinfile.add_line_to_file(
            filepath="src/Costumes.asm",
            line="\t\t"+"\n\t\t".join(costume_list),
            inserter=lineinfile.BeforeFirst(r'^\s*// Polygons')
        )

        # SinglePlayer.asm
        lineinfile.add_line_to_file(
            filepath="src/SinglePlayer.asm",
            line="\t\t// Extra characters\n\t\t"+
            "\n\t\t".join(self.char_proc.character_1p_name_defs),
            inserter=lineinfile.BeforeFirst(r'.*// Duo Teams')
        )

        lineinfile.add_line_to_file(
            filepath="src/SinglePlayer.asm",
            line="\n\t\t// Extra bosses\n\t\t"+
            "\n\t\t".join(self.char_proc.character_1p_boss_name_defs),
            inserter=lineinfile.BeforeFirst(r'.*// Duo Teams')
        )

        lineinfile.add_line_to_file(
            filepath="src/SinglePlayer.asm",
            line="\t"+"\n\t".join(self.char_proc.singleplayer_additions),
            inserter=lineinfile.AfterLast(r'^\s*add_to_single_player\(.*')
        )

        lineinfile.add_line_to_file(
            filepath="src/SinglePlayer.asm",
            line="\t\t" +
            "\n\t\t".join(
                self.char_proc.singleplayer_name_width_defs["normal"]),
            inserter=lineinfile.BeforeLast(
                r'.*// use normal width otherwise.*')
        )

        add_to_scope("src/SinglePlayer.asm", "name_delay",
                     ["// Extra characters"] + self.char_proc.character_1p_delay_defs)

        # SinglePlayerModes.asm
        lineinfile.add_line_to_file(
            filepath="src/SinglePlayerModes.asm",
            line="\t" +
            "\n\t".join(self.char_proc.singleplayer_remix_match_defs),
            inserter=lineinfile.BeforeLast(
                r".*// Add entry here if a new variant.type.NA character is added UPDATE.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/SinglePlayerModes.asm",
            line="\t\t" +
            "\n\t\t".join(self.char_proc.singleplayer_name_width_defs["team"]),
            inserter=lineinfile.BeforeLast(r'.*b       _adjust_footer_team.*')
        )

        lineinfile.add_line_to_file(
            filepath="src/SinglePlayerModes.asm",
            line="\t\t" +
            "\n\t\t".join(
                self.char_proc.singleplayer_name_width_defs["giant"]),
            inserter=lineinfile.BeforeLast(r'.*b       _done_giant.*')
        )

        add_to_scope("src/SinglePlayerModes.asm", "progress_icon",
                     self.char_proc.character_1p_icon_defs)
        add_to_scope("src/SinglePlayerModes.asm", "progress_icon",
                     self.char_proc.character_1p_boss_icon_defs)
        add_to_label_on_empty("src/SinglePlayerModes.asm", "duo_array",
                              self.char_proc.character_1p_duo_parameter_defs)
        add_to_label_on_empty("src/SinglePlayerModes.asm", "team_array",
                              self.char_proc.character_1p_team_parameter_defs)

        # SinglePlayer.asm - 1P clear images
        if self.char_proc.ending_image_defs:
            lineinfile.add_line_to_file(
                filepath="src/SinglePlayer.asm",
                line="\t" + "\n\t".join(self.char_proc.ending_image_defs),
                inserter=lineinfile.AfterLast(
                    r".*set_ending_image\(Character\.id\..*")
            )

        self.add_gallery_entries(self.char_proc.gallery_entries)

        # TwelveCharBattle.asm
        lineinfile.add_line_to_file(
            filepath="src/TwelveCharBattle.asm",
            line="\t"+"\n\t".join(self.char_proc.character_12cb_defs),
            inserter=lineinfile.AfterLast(r".*// ADD NEW CHARACTERS HERE.*")
        )

        # TagTeam.asm
        lineinfile.add_line_to_file(
            filepath="src/TagTeam.asm",
            line="\t// Extra characters\n\t" +
            "\n\t".join(self.char_proc.character_tag_team_preloads) +
            "\n\t",
            inserter=lineinfile.BeforeLast(r".*process_preloads().*")
        )

        # CharEnvColor.asm
        for char in self.char_proc.character_cloaking_fix:
            char_fix = self.char_proc.character_cloaking_fix[char]

            lineinfile.add_line_to_file(
                filepath="src/CharEnvColor.asm",
                line="\t"+"\n\t".join(char_fix["struct_defs"])+"\n",
                inserter=lineinfile.BeforeLast(
                    r".*scope custom_display_lists_struct_*")
            )

            lineinfile.add_line_to_file(
                filepath="src/CharEnvColor.asm",
                line="\t\t"+"\n\t\t".join(char_fix["fix_defs"]),
                inserter=lineinfile.BeforeLast(
                    r".*// skip if no fixing necessary*")
            )

            lineinfile.add_line_to_file(
                filepath="src/CharEnvColor.asm",
                line="\t\t"+"\n\t\t".join(char_fix["clear_defs"]),
                inserter=lineinfile.AfterLast(
                    r".*// if JKIRBY, clear JKIRBY's custom display lists*")
            )

            lineinfile.add_line_to_file(
                filepath="src/CharEnvColor.asm",
                line="\t\t"+"\n\t\t".join(char_fix["clear_asm"]),
                inserter=lineinfile.BeforeLast(r".*_clear_kirby:*")
            )

    def add_gallery_entries(self, entries):
        """Appends characters' 1P clear images to the end of the Gallery."""
        if not entries:
            return

        with open("src/Gallery.asm", 'r', encoding='utf-8') as f:
            gallery = f.read()

        size_match = re.search(r"constant id_table\.SIZE\((\d+)\)", gallery)
        old_size = int(size_match.group(1))
        new_size = old_size + len(entries)

        gallery = gallery.replace(
            size_match.group(0), f"constant id_table.SIZE({new_size})", 1)

        # BGM arrays go after the last one (bgm_remix), before its OS.align
        bgm_arrays = ""
        for entry in entries:
            bgm_arrays += f"\n    bgm_extra_{entry['character'].lower()}:\n"
            bgm_arrays += f"    dh {len(entry['bgm'])}".ljust(44) + \
                "// number of BGM\n"
            bgm_arrays += "".join(f"    dh {bgm}\n" for bgm in entry['bgm'])
        gallery = re.sub(
            r"(\n    bgm_remix:\n(?:    dh .*\n)+)",
            lambda m: m.group(1) + bgm_arrays, gallery, count=1)

        gallery = re.sub(
            r"(\n    dw bgm_remix.*\n)",
            lambda m: m.group(1) + "".join(
                f"    dw bgm_extra_{e['character'].lower()}".ljust(44) +
                f"// {e['name']}\n" for e in entries),
            gallery, count=1)

        gallery = re.sub(
            r"(\n    id_table:\n(?:.*\n)*?    db Character\.id\.BOSS\n)",
            lambda m: m.group(1) + "".join(
                f"    db Character.id.{e['character']}\n" for e in entries),
            gallery, count=1)

        with open("src/Gallery.asm", 'w', encoding='utf-8') as f:
            f.write(gallery)

        # Toggles.asm - names and index range for "View Gallery"
        with open("src/Toggles.asm", 'r', encoding='utf-8') as f:
            toggles = f.read()

        toggles = re.sub(
            r"(\n    string_table_gallery:\n(?:    dw .*\n)+)",
            lambda m: m.group(1) + "".join(
                f"    dw gallery_extra_{e['character'].lower()}\n" for e in entries),
            toggles, count=1)

        toggles = re.sub(
            r'(\n    remix:; db "Remix", 0x00\n)',
            lambda m: m.group(1) + "".join(
                f"    gallery_extra_{e['character'].lower()}:; "
                f"db \"{e['name']}\", 0x00\n" for e in entries),
            toggles, count=1)

        toggles = toggles.replace(
            f"OS.FALSE, 0, {old_size - 1}, view_gallery,",
            f"OS.FALSE, 0, {new_size - 1}, view_gallery,", 1)

        with open("src/Toggles.asm", 'w', encoding='utf-8') as f:
            f.write(toggles)

    def _patch_stage_asm(self):
        # Item.asm
        num_items = 0

        with open("src/Item.asm", 'r', encoding='utf-8') as f:
            lines = f.readlines()

            for line in lines:
                m = re.match(r'.*constant NUM_ITEMS\((.*)\)', line)
                if m:
                    num_items = int(m.group(1), 10)

        lineinfile.add_line_to_file(
            filepath="src/Item.asm",
            line=f'\tconstant NUM_ITEMS({num_items}+{self.char_proc.items_added}+{len(self.stage_proc.item_add_list)})',
            regexp=r'.*constant NUM_ITEMS\(.*\)'
        )

        # Stage-registered custom items: splice the add_item(...) calls in after
        # the last one in src/Item.asm (inside scope Item, where the macro and
        # its origin constants are defined).
        if self.stage_proc.item_add_list:
            lineinfile.add_line_to_file(
                filepath="src/Item.asm",
                line="\t" + "\n\t".join(self.stage_proc.item_add_list),
                inserter=lineinfile.AfterLast(r'^\s*add_item\([A-Za-z]')
            )

        # Stages.asm
        # Get NUM_PAGES value
        num_pages = 0
        stages_per_page = 0

        with open("src/Stages.asm", 'r') as f:
            lines = f.readlines()

            for line in lines:
                m = re.match(r'.*constant NUM_PAGES\((.*)\)', line)
                if m:
                    num_pages = int(m.group(1), 16)
                m = re.match(r'.*constant NUM_ROWS\((.*)\)', line)
                if m:
                    num_rows = int(m.group(1), 16)
                m = re.match(r'.*constant NUM_COLUMNS\((.*)\)', line)
                if m:
                    num_columns = int(m.group(1), 16)

            stages_per_page = num_rows * num_columns

        # -1 for the Random stage on the last slot of each page
        pages_needed = len(self.stage_folders) // (stages_per_page - 1) + 1

        if len(self.stage_folders) % (stages_per_page - 1) == 0:
            pages_needed -= 1

        num_pages += pages_needed

        lineinfile.add_line_to_file(
            filepath="src/Stages.asm",
            line=f'\tconstant NUM_PAGES(0x{num_pages:X})',
            regexp=r'.*constant NUM_PAGES\(.*\)'
        )

        max_stage_id = 0

        with open("src/Stages.asm", 'r') as f:
            for line in f:
                m = re.match(r'.*constant MAX_STAGE_ID\((.*)\)', line)
                if m:
                    max_stage_id = int(m.group(1), 16)
                    break

        stage_ids = []
        stage_background_table = []
        stage_zoom_table = []
        add_stage_strings = []
        self.REACHED_RANDOM_STAGE = False
        # We will reach random stage at this index
        self.RANDOM_STAGE_INDEX = 0xDE - max_stage_id - 1

        for i, config in enumerate(self.stage_proc.stage_configs):
            max_stage_id += 1

            # Skip 0xDE since it's the Random stage id
            if max_stage_id == 0xDE:
                max_stage_id += 1
                self.REACHED_RANDOM_STAGE = True

                stage_background_table.append(
                    "db id.PEACHS_CASTLE // RANDOM")

                stage_zoom_table.append(
                    "float32 0.5 // RANDOM")

                add_stage_strings.append(
                    "add_stage("
                    "RANDOM, "
                    '"RANDOM", '
                    "-1, "
                    "-1, "
                    "-1, "
                    "-1, "
                    "OS.FALSE, "
                    "HAZARDS_ON_MOVEMENT_ON, "
                    "OS.FALSE, "
                    "OS.FALSE, "
                    "class.BATTLE, "
                    "-1, -1, -1, -1, -1, 0x05, 0x05, 0x05, default_blue_shell_rate, default_lightning_rate, default_item_rate, default_item_rate, "
                    "SMASH, "
                    "Hazards.type.NONE, "
                    f"{900+len(add_stage_strings)})"
                )

            stage_ids.append(
                f"constant STAGE_{config['id'].upper().replace("/", "_")}(0x{max_stage_id:X})")

            stage_id = max_stage_id + 1

            series = f'{config.get("series", "SMASH")}'

            if self.stage_folders[i] in self.stage_proc.stage_series_textures:
                series = self.stage_folders[i].upper()

            name = config.get("name", config.get("id", ""))

            stage_zoom_table.append(
                f"float32 {config.get("sss_zoom", "0.5")} // {name}")

            stage_background_table.append(
                f"db id.{config.get("training_background", "PEACHS_CASTLE")} // {name}")

            music = [
                config.get('music', {}).get('main', '-1'),
                config.get('music', {}).get('occasional', '-1'),
                config.get('music', {}).get('rare', '-1'),
                config.get('music', {}).get('rare2', '-1')
            ]

            for i, track in enumerate(music):
                if str(track) != '-1':
                    music[i] = f"{{MIDI.id.{track}}}"

            add_stage_strings.append(
                f"add_stage("
                f"{config['id'].upper()}, "
                f'"{name}", '
                f"{music[0]}, "
                f"{music[1]}, "
                f"{music[2]}, "
                f"{music[3]}, "
                f"OS.TRUE, "
                f"HAZARDS_ON_MOVEMENT_ON, "
                f"OS.TRUE, "
                f"OS.TRUE, "
                f"class.BATTLE, "
                f"-1, -1, -1, "
                f'{config.get("base_stage", "-1")}, '
                f'{config.get("variant_type", "-1")}, '
                f"0x05, 0x05, 0x05, default_blue_shell_rate, default_lightning_rate, default_item_rate, default_item_rate, "
                f"{series}, "
                f"Hazards.type.{config.get('hazard_type', 'NONE')}, "
                f"{900+len(add_stage_strings)})"
            )

        lineinfile.add_line_to_file(
            filepath="src/Stages.asm",
            line="\t\t"+"\n\t\t".join(stage_ids),
            inserter=lineinfile.BeforeLast(r'.*constant MAX_STAGE_ID\((.*)\)')
        )

        lineinfile.add_line_to_file(
            filepath="src/Stages.asm",
            line=f'\t\tconstant MAX_STAGE_ID(0x{max_stage_id:X})',
            regexp=r'.*constant MAX_STAGE_ID\(.*\)'
        )

        lineinfile.add_line_to_file(
            filepath="src/Stages.asm",
            line="\t"+"\n\t".join(add_stage_strings),
            inserter=lineinfile.AfterLast(r'.*add_stage\(')
        )

        add_to_scope("src/Stages.asm", "header",
                     self.stage_proc.stage_headers_strings)

        # Assign stages to the menu slots
        # Any extra slots will be filled with the Random stage
        stage_slots = []
        for i, stg in enumerate(self.stage_folders):
            if "/" in stg:
                continue

            if i % (stages_per_page - 1) == 0:
                stage_slots.append(
                    f"// Extra page {i // (stages_per_page - 1) + 1}")

            if i % (stages_per_page - 1) == 0 and i != 0:
                stage_slots.append("db id.RANDOM")

            stage_slots.append(f"db id.STAGE_{stg.upper()}")

        stages_on_last_page = (
            len([s for s in self.stage_folders if "/" not in s]) % (stages_per_page - 1))

        if stages_on_last_page != 0:
            for _ in range((stages_per_page) - stages_on_last_page):
                stage_slots.append("db id.RANDOM")

        lineinfile.add_line_to_file(
            filepath="src/Stages.asm",
            line="\t" +
            "\n\t".join(stage_slots),
            inserter=lineinfile.BeforeLast(r'.*OS.align\(16\)')
        )

        # Add function_table entries for stages
        fun_table_entries = []
        hazards_import_strings = []

        for stg in self.stage_folders:
            # If there's a "hazards.asm" file in the stage folder, use that instead of the default CLONE function
            if os.path.isfile(f"extra_stages/{stg}/hazards.asm"):
                fun_table_entries.append(
                    f"dw Hazards.{stg.upper().replace("/", "_")}_HAZARDS.setup // {stg}")
                hazards_import_strings.append(
                    f'scope {stg.upper().replace("/", "_")}_HAZARDS {{; include "../build/extra_stages/{stg}/hazards.asm"; }}'
                )
            else:
                fun_table_entries.append(
                    f"dw function.CLONE // {stg}"
                )

        if self.REACHED_RANDOM_STAGE:
            fun_table_entries.insert(
                self.RANDOM_STAGE_INDEX, "dw function.CLONE // RANDOM")

        add_to_label("src/Stages.asm", "function_table", fun_table_entries)

        # add hazards imports inside scope Hazards in Hazards.asm
        lineinfile.add_line_to_file(
            filepath="src/Hazards.asm",
            line="\t"+"\n\t".join(hazards_import_strings)+"\n\n",
            inserter=lineinfile.BeforeFirst(r'^} // __HAZARDS__.*')
        )

        # add Character.asm include to Hazards.asm
        lineinfile.add_line_to_file(
            filepath="src/Hazards.asm",
            line="include \"Character.asm\"\n\n",
            inserter=lineinfile.BeforeFirst(r'^scope Hazards.*')
        )

        # generic helper for stage `files:` imports: fill a word with the RAM
        # address of a reqlist-loaded file. Used via resolve_stage_file(id, ptr).
        lineinfile.add_line_to_file(
            filepath="src/Hazards.asm",
            line=(
                "\n"
                "    // @ Description\n"
                "    // Fills the word at a1 with the RAM address of stage-reqlist file a0.\n"
                "    // a0 - file id     a1 - address of the destination word\n"
                "    scope resolve_stage_file_: {\n"
                "        OS.routine_begin(0x20)\n"
                "        sw      a1, 0x0018(sp)\n"
                "        jal     0x800CD698              // lbRelocFindForceStatusBufferFile(a0)\n"
                "        sw      a0, 0x001C(sp)\n"
                "        bnez    v0, _store\n"
                "        lw      a1, 0x0018(sp)\n"
                "        lw      a0, 0x001C(sp)\n"
                "        jal     Render.load_file_      // loads + writes the address into *a1\n"
                "        nop\n"
                "        lw      v0, 0x0000(a1)\n"
                "        _store:\n"
                "        sw      v0, 0x0000(a1)\n"
                "        OS.routine_end(0x20)\n"
                "    }\n"
                "\n"
                "    // @ Description\n"
                "    // resolve_stage_file(FILE_<NAME>, FILE_<NAME>_ptr) - call once in setup.\n"
                "    macro resolve_stage_file(id, ptr) {\n"
                "        lli     a0, {id}\n"
                "        li      a1, {ptr}\n"
                "        jal     Hazards.resolve_stage_file_\n"
                "        nop\n"
                "    }\n"
            ),
            inserter=lineinfile.AfterFirst(r'^scope Hazards\s*\{')
        )

        # Add icon offsets
        stage_icon_offsets = [
            f"dw {self.stage_proc.stage_icon_offsets[i]} // {stg}" for i, stg in enumerate(self.stage_folders)]

        if self.REACHED_RANDOM_STAGE:
            stage_icon_offsets.insert(
                self.RANDOM_STAGE_INDEX, "dw 0x00009BB8 // RANDOM")

        add_to_label("src/Stages.asm", "icon_offset_table", stage_icon_offsets)

        # Add stage zoom table
        add_to_label("src/Stages.asm", "zoom_table", stage_zoom_table)

        # Add stage background table
        add_to_label("src/Stages.asm",
                     "background_table", stage_background_table)

        # Add stage file table
        stage_file_table = [
            f"dw header.STAGE_{stg.upper().replace("/", "_")},\ttype.CLONE" for stg in self.stage_folders]
        if self.REACHED_RANDOM_STAGE:
            stage_file_table.insert(
                self.RANDOM_STAGE_INDEX, "dw 0x0,\ttype.CLONE")

        add_to_label("src/Stages.asm", "stage_file_table", stage_file_table)

        # Camera.asm
        lineinfile.add_line_to_file(
            filepath="src/Camera.asm",
            line="".join(
                self.stage_proc.stages_mushroom_kingdom_camera_strings),
            inserter=lineinfile.BeforeLast(
                r'.*addiu   at, r0, Stages.id.TOADSTURNPIKE')
        )

        # Spawn.asm
        # If reached random stage id, add 0,0,0,0 spawn locations for it
        if self.REACHED_RANDOM_STAGE:
            self.stage_proc.stage_spawn_location_strings["default"].insert(
                self.RANDOM_STAGE_INDEX,
                "\n\t".join([
                    "// RANDOM",
                    "float32 0, 0",
                    "float32 0, 0",
                    "float32 0, 0",
                    "float32 0, 0"
                ])
            )
            self.stage_proc.stage_spawn_location_strings["neutral"].insert(
                self.RANDOM_STAGE_INDEX,
                "\n\t".join([
                    "// RANDOM",
                    "float32 0, 0",
                    "float32 0, 0",
                    "float32 0, 0",
                    "float32 0, 0"
                ])
            )

        add_to_label(
            "src/Spawn.asm",
            "original_table",
            self.stage_proc.stage_spawn_location_strings["default"]
        )

        add_to_label(
            "src/Spawn.asm",
            "neutral_table",
            self.stage_proc.stage_spawn_location_strings["neutral"]
        )

    def _patch_toggle_asm(self):
        # Toggles.asm
        gameplay_toggles = [i.split(".")[0] for i in sorted(os.listdir(
            "./extra_toggles/gameplay/")) if i.endswith(".asm")]

        gameplay_toggles_strings = []

        # get the label of the last toggle
        LAST_TOGGLE = None

        with open('src/Toggles.asm', 'r') as file:
            lines = file.readlines()

        for i, line in enumerate(lines):
            if re.search(r'evaluate num_gameplay_toggles\(', line):
                # Traverse backwards to find the previous 'entry_.*:'
                for j in range(i - 1, -1, -1):
                    match = re.search(r'(entry_\w+):', lines[j])
                    if match:
                        LAST_TOGGLE = match.group(1)
                        break
                break

        # build toggles strings
        for i, gt in enumerate(gameplay_toggles):
            config = yaml.safe_load(open(
                f"extra_toggles/gameplay/{gt}.yaml"
            ))

            next_toggle = "OS.NULL"

            if i < len(gameplay_toggles)-1:
                next_toggle = f'entry_{gameplay_toggles[i+1]}'

            if config.get("is_bool"):
                gameplay_toggles_strings.append(
                    f'entry_{gt}:;\t\t'
                    f'entry_bool("{config.get("name", gt)}", '
                    f'OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, '
                    f'{next_toggle})'
                )

        print(f"Gameplay toggles: {gameplay_toggles}")

        if len(gameplay_toggles) > 0:
            with open('src/Toggles.asm', 'r', encoding='utf-8') as file:
                lines = file.readlines()

            # Find the line with 'evaluate num_gameplay_toggles('
            for i, line in enumerate(lines):
                if re.search(r'evaluate num_gameplay_toggles\(', line):
                    # Traverse backwards to find the previous line ending with 'OS.NULL)'
                    for j in range(i - 1, -1, -1):
                        if lines[j].strip().endswith('OS.NULL)'):
                            # Replace 'OS.NULL)' with '"mylabel"'
                            lines[j] = lines[j].replace('OS.NULL)', f'entry_{
                                gameplay_toggles[0]})')
                            break
                    break

            with open('src/Toggles.asm', 'w', encoding='utf-8') as file:
                file.writelines(lines)

            lineinfile.add_line_to_file(
                filepath="src/Toggles.asm",
                line="\t"+"\n\t".join(gameplay_toggles_strings),
                inserter=lineinfile.BeforeLast(
                    r'.*evaluate num_gameplay_toggles\(')
            )

        # Insert new toggles asm files before Kirby
        lineinfile.add_line_to_file(
            filepath="main.asm",
            line="// Extra toggles\n"+"\n".join(
                [f"include \"extra_toggles/gameplay/{gt}.asm\"" for gt in gameplay_toggles]),
            inserter=lineinfile.BeforeFirst(r"\/\/ KIRBY")
        )

        # Insert extra imports in main asm before characters start (before "// METAL MARIO").
        # An import with a data folder (extra_imports/<Name>/config.yaml) gets its
        # generated FILES/FGM scope included right before it.
        extra_import_includes = [f'include "{EXTRA_IMPORTS_ASM}"']
        for ei, ei_folder in ExtraImportProcessor.list_imports().items():
            if ei in self.import_proc.generated:
                extra_import_includes.append(
                    f'include "build/extra_imports/{ei}/generated.asm"')
            ei_path = os.path.join(ei_folder, f"{ei}.asm").replace("\\", "/")
            extra_import_includes.append(f'include "{ei_path}"')

        lineinfile.add_line_to_file(
            filepath="main.asm",
            line="// Extra imports\n"+"\n".join(extra_import_includes)+"\n",
            inserter=lineinfile.BeforeFirst(r"\/\/ METAL MARIO")
        )

        # Load extra imports' files at the start of every battle
        with open("src/Render.asm", 'r', encoding='utf-8') as f:
            render = f.read()
        for label in ["_1p", "_multiman", "_vs", "_training", "_bonus"]:
            anchor = f"\n        {label}:\n"
            if anchor not in render:
                raise RuntimeError(f"Render.asm: battle setup label {label} not found")
            render = render.replace(
                anchor,
                anchor + "        jal     ExtraImports.load_files_ // load extra imports' files\n        nop\n", 1)
        with open("src/Render.asm", 'w', encoding='utf-8') as f:
            f.write(render)

        # Add CSS debug menu toggles
        css_toggles = [i for i in sorted(os.listdir(
            "./extra_toggles/css/")) if i.endswith(".asm")]

        css_toggle_scope_strings = []

        for css_toggle in css_toggles:
            css_toggle_scope_strings.append(
                f"\tscope {css_toggle.split('.')[0]} {{\n"
                f'\t\tinclude "../extra_toggles/css/{css_toggle}"\n'
                f"\t}}"
            )

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelectDebugMenu.asm",
            line="\t// Extra CSS toggles\n" +
            "\n\n".join(css_toggle_scope_strings) +
            "\n\n",
            inserter=lineinfile.BeforeLast(r".*// Add Menu Items.*")
        )

        lineinfile.add_line_to_file(
            filepath="src/CharacterSelectDebugMenu.asm",
            line="\t// Extra CSS toggles\n" +
            "\n".join([f"\tadd_menu_item({csst.split('.')[0]})" for csst in css_toggles]) +
            "\n\n",
            inserter=lineinfile.BeforeLast(r".*// Write Menu Items.*")
        )

        self.audio_proc.patch_toggle_asm()

        # lineinfile patches from custom characters
        for patch in self.char_proc.character_lineinfile_patches:
            itype = patch[2]

            if itype == "BeforeFirst":
                insert = lineinfile.BeforeFirst(patch[3])
            elif itype == "AfterFirst":
                insert = lineinfile.AfterFirst(patch[3])
            elif itype == "BeforeLast":
                insert = lineinfile.BeforeLast(patch[3])
            elif itype == "AfterLast":
                insert = lineinfile.AfterLast(patch[3])
            elif itype != "regexp":
                continue

            if itype == "regexp":
                lineinfile.add_line_to_file(
                    filepath=f"{patch[0]}",
                    line=patch[1],
                    regexp=patch[3]
                )
            else:
                lineinfile.add_line_to_file(
                    filepath=f"{patch[0]}",
                    line=patch[1],
                    inserter=insert
                )


def main(args):
    ca = CharacterAppender(args)
    ca.copy_remix_src()
    ca.overwrite_files()
    ca.prepare_files()
    apply_bio_overflow_patches()
    write_bio_overflow_asm(ca.char_proc.bio_overflow_names)
    ca.inject_files_in_rom()
    ca.edit_src_files()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Appends extra files to Remix and prepare a base rom and source code for building."
    )
    parser.add_argument(
        "--single_character",
        nargs="?",
        help="Build with only a single character added, nothing else. Intended for faster character development."
    )
    parser.add_argument(
        "--single_stage",
        nargs="?",
        help="Build with only a single stage (and its variants) added, no characters. Intended for faster stage development."
    )
    args = parser.parse_args()
    main(args)
