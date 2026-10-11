import hashlib
import os
import re
import struct
import yaml
import lineinfile
from typing import List, Optional

from smashremix_extra.logger import logger
from smashremix_extra.content_filter import filter_folders
from smashremix_extra.audio import cseq

# ROM space reserved between original_extra.z64 and MIDI_BANK for the custom
# ASM, midi_memory_block and file_table, up to custom_heap. Remix reserves 4 MB,
# but only the boot DMA (up to the 64 KB block past custom_heap) has to fit;
# the runtime heap itself lives in RAM. 7 characters use 0x1D0000. The build
# fails (see the main.asm guard) if this is too small.
ASM_HEADROOM = 0x240000  # 2.25 MB


class AudioProcessor:
    """Processes extra_music/ and accumulates MIDI/BGM patch data."""

    def __init__(self, music_selection: Optional[list] = None):
        self.music_selection = music_selection
        self.midi_series_list: List[str] = []
        self.midi_files_list: List[str] = []
        self.midi_priority_overrides: List[str] = []
        self.midi_bend_range_overrides: List[str] = []
        self.midi_master_volume_overrides: List[str] = []
        self.midi_menu_defs1: List[str] = []
        self.midi_menu_defs2: List[str] = []
        self.midi_menu_defs3: List[str] = []
        self.midi_menu_defs4: List[str] = []
        self.midi_menu_defs5: List[str] = []
        self.midi_menu_toggle_strings: List[str] = []
        self.midi_menu_toggle_dw: List[str] = []

    def load(self) -> None:
        """Scan extra_music/ and populate all accumulated lists."""
        num_menu_track = 0
        with open("src/Toggles.asm", 'r', encoding='utf-8') as f:
            for line in f:
                m = re.match(r'.*constant MAX_VALUE\((.*)\)', line)
                if m:
                    # Subtract 4: RANDOM, RANDOM CLASSICS, RANDOM ALL, OFF
                    num_menu_track = int(m.group(1)) - 4
                    break

        music_dirs = [
            d for d in sorted(os.listdir("extra_music"))
            if os.path.isdir(os.path.join("extra_music", d)) and not d.startswith("_")
        ]
        music_dirs = filter_folders(
            music_dirs, self.music_selection, kind="music"
        )

        for _dir in music_dirs:
            try:
                config = yaml.safe_load(open(
                    f"extra_music/{_dir}/config.yaml", 'r', encoding='utf-8'
                ))
                self.midi_series_list.append(
                    f'add_game({_dir}, "{config.get("game_name")}")'
                )

                midi_files = [
                    f for f in sorted(os.listdir(f"extra_music/{_dir}/"))
                    if f.endswith(".yaml") and f != "config.yaml"
                ]

                for midi_file in midi_files:
                    try:
                        midi_config = yaml.safe_load(open(
                            f"extra_music/{_dir}/{midi_file}", 'r', encoding='utf-8'
                        ))
                        midi_filename = midi_file.rsplit(".", 1)[0]
                        midi_name = midi_config.get("name", midi_filename)
                        midi_id = f"{{MIDI.id.{_dir.upper()}_{midi_filename.upper()}}}"

                        if midi_config.get('priority_overrides'):
                            for override in midi_config.get('priority_overrides'):
                                self.midi_priority_overrides.append(
                                    f"add_priority_override({midi_id}, {override[0]}, {override[1]})"
                                )

                        if midi_config.get('bend_range_overrides'):
                            for override in midi_config.get('bend_range_overrides'):
                                self.midi_bend_range_overrides.append(
                                    f"add_bend_range_override({midi_id}, {override[0]}, {override[1]})"
                                )

                        if midi_config.get('master_volume_override'):
                            self.midi_master_volume_overrides.append(
                                f"add_master_volume_override({midi_id}, {midi_config.get('master_volume_override')})"
                            )

                        if midi_config.get('is_menu_music') is True:
                            num_menu_track += 1
                            self.midi_menu_defs1.append(
                                f"lli     t1, 0x{num_menu_track:04X}                  // t1 = {num_menu_track} ({midi_name.upper()})"
                                f"\n\t\tbeql    t1, t0, _check_current_track// if {midi_name.upper()}, then use {midi_name.upper()} BGM"
                                f"\n\t\taddiu   a1, r0, {midi_id}"
                            )
                            self.midi_menu_defs2.append(
                                f"nop"
                                f"\n\t\tlli     t1, {midi_id}   // t1 = {midi_id}"
                                f"\n\t\tbeq     t0, t1, _check_music_toggle // if playing {midi_name.upper()}, then don't restart it"
                            )
                            self.midi_menu_defs3.append(
                                f"nop"
                                f"\n\t\tlli     t1, {midi_id}   // t1 = {midi_id}"
                                f"\n\t\tbeq     t0, t1, _done               // if playing {midi_name.upper()}, then don't stop it"
                            )
                            self.midi_menu_defs4.append(
                                f"lli     a0, {midi_id}"
                                f"\n\t\tbeq     t1, a0, _reset_menu_music"
                            )
                            self.midi_menu_defs5.append(
                                f"lli     t1, 0x{num_menu_track:04X}                  // t1 = 18 ({midi_name.upper()})"
                                f"\n\t\tbeql    t1, t0, _play               // if {midi_name.upper()}, then use {midi_name.upper()} BGM"
                                f"\n\t\taddiu   a1, r0, {midi_id}"
                            )
                            self.midi_menu_toggle_strings.append(
                                f"menu_music_{midi_filename}:; db \"{midi_name.upper()}\", 0x00"
                            )
                            self.midi_menu_toggle_dw.append(
                                f"dw menu_music_{midi_filename}"
                            )

                        self.midi_files_list.append(
                            f"insert_external_midi("
                            f"{_dir.upper()}_{midi_filename.upper()}, "
                            f"../extra_music/{_dir}/{midi_filename}, "
                            f"{midi_config.get('random_tournament_profile', 'OS.TRUE')}, "
                            f"{midi_config.get('random_netplay_profile', 'OS.TRUE')}, "
                            f"{midi_config.get('can_toggle', 'OS.TRUE')}, "
                            f"{midi_config.get('has_title', 'OS.TRUE')}, "
                            f'"{midi_name}", '
                            f"{_dir}, "
                            f"{1000+len(self.midi_files_list)})"
                        )
                    except Exception as e:
                        logger.warning(f"Music: Error loading midi file {midi_file} for {_dir}: {e}")
            except Exception as e:
                logger.warning(f"Music: Error loading game config for {_dir}: {e}")

    def patch_midi_asm(
        self,
        original_size: int,
        victory_theme_strings: List[str],
        char_priority_overrides: List[str],
        char_bend_overrides: List[str],
        char_volume_overrides: List[str],
    ) -> None:
        """Patch midi.asm: MIDI_BANK address, game series, tracks, and overrides."""
        # See ASM_HEADROOM for how this region is sized.
        asm_headroom = ASM_HEADROOM
        midi_bank_addr = original_size + asm_headroom
        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line=f'\tconstant MIDI_BANK(0x{midi_bank_addr:07X})',
            regexp=r'.*constant MIDI_BANK\(.*'
        )

        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line="\t"+"\n\t".join(self.midi_series_list),
            inserter=lineinfile.AfterLast(r"^\s*add_game\(")
        )

        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line="\t"+"\n\t".join(victory_theme_strings)+"\n\t" +
            "\n\t".join(self.midi_files_list),
            inserter=lineinfile.AfterLast(
                r".*(insert_midi|insert_extra_midi|insert_named_extra_midi).*")
        )

        # Merge character victory-theme overrides with extra_music overrides
        all_priority = char_priority_overrides + self.midi_priority_overrides
        all_bend     = char_bend_overrides     + self.midi_bend_range_overrides
        all_volume   = char_volume_overrides   + self.midi_master_volume_overrides

        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line="\t"+"\n\t".join(all_priority),
            inserter=lineinfile.AfterLast(r"^\s*add_priority_override\(")
        )
        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line="\t"+"\n\t".join(all_bend),
            inserter=lineinfile.AfterLast(r"^\s*add_bend_range_override\(")
        )
        lineinfile.add_line_to_file(
            filepath="src/midi.asm",
            line="\t"+"\n\t".join(all_volume),
            inserter=lineinfile.AfterLast(r"^\s*add_master_volume_override\(")
        )

    def alias_remix_midis(self, external_midis: List[str]) -> None:
        """
        Point every Remix MIDI at a vanilla SSB track instead of inserting it
        (extra_content.yaml: remix_music: vanilla). Frees ~3 MiB of ROM.

        Track IDs, toggles, stage assignments and overrides keep working because
        each Remix ID still gets its music-table entry; only the entry's data
        is a vanilla track's. Victory themes go to a vanilla victory fanfare,
        menu tracks to the vanilla main menu, the rest to a vanilla stage track
        from the same series where there is one. insert_external_midi (EXTRA
        victory themes and music packs, passed as external_midis) is
        untouched, and only the Remix instruments those MIDIs use keep their
        sample data.
        """
        path = "src/midi.asm"
        with open(path, "r", encoding="utf-8") as f:
            asm = f.read()

        # vanilla BGM ids (src/BGM.asm). 0 (Dream Land) is moved by Remix, so
        # its original table entry is stale; never alias to it.
        win = {"LINK": 21, "FOX": 16, "SAMUS": 13, "NESS": 17, "PIKACHU": 20,
               "KIRBY": 15, "DK": 14, "MARIO": 12}
        victory_series = [
            (("GANON", "YOUNGLINK", "SHEIK", "MARINA"), "LINK"),
            (("FALCO", "WOLF"), "FOX"), (("DSAMUS",), "SAMUS"),
            (("LUCAS",), "NESS"), (("MEWTWO",), "PIKACHU"),
            (("DEDEDE",), "KIRBY"), (("DKING", "LANKY"), "DK"),
        ]
        series_stage = [
            (("yoshi",), 8), (("dk",), 5),
            (("zelda", "lttp", "awakening", "ocarina", "majora", "skyward"), 9),
            (("metroid",), 1), (("starfox",), 4),
            (("pokemon", "stadium", "heypika"), 7), (("kirby", "dream"), 34),
            (("ssb", "brawl", "melee"), 25), (("fzero",), 37),
            (("smb", "sml", "smw", "sm64", "sunshine", "nsmb", "drm", "smk",
              "mk64", "mkds", "mario", "smrpg", "paper", "talentstudio",
              "ddrmm", "wario", "ww"), 6),
        ]
        spread = [1, 2, 4, 5, 6, 7, 8, 9, 25, 34, 36, 37]
        menu_words = ("MENU", "MAIN_", "FILESELECT", "GALLERY", "OPTIONS",
                      "STAGESEL", "PAUSE", "ITSATRAP", "PLAY_A_MINIGAME",
                      "ENEMYCARD", "WATCH_THEME", "BRAWL")
        games = set(re.findall(r"^\s*add_game\((\w+),", asm, re.M))

        def pick(name, game):
            if "VICTORY" in name:
                for keys, who in victory_series:
                    if any(k in name for k in keys):
                        return win[who]
                return win["MARIO"]
            if any(w in name for w in menu_words):
                return 44  # menu.MAIN
            for keys, track in series_stage:
                if game and any(game.startswith(k) for k in keys):
                    return track
            # stable spread (Python's str hash is salted per run)
            return spread[int(hashlib.md5(name.encode()).hexdigest(), 16) % len(spread)]

        calls = re.findall(
            r"^\s*insert_(?:midi|extra_midi|named_extra_midi)\((\w+)([^\n]*)\)",
            asm, re.M)
        aliases = []
        for name, rest in calls:
            game = next((t for t in re.findall(r"\b\w+\b", rest) if t in games), None)
            aliases.append(f"    global define ALIAS_{name}({pick(name, game)})")

        rom = re.search(r'read32 MUSIC_TABLE, "([^"]+)"', asm).group(1)
        old_body = (
            "        origin  MUSIC_TABLE_END\n"
            "        dw      origin_MIDI_{file_name} - MUSIC_TABLE\n"
            "        dw      MIDI_{file_name}.size\n"
            "        global variable MUSIC_TABLE_END(origin())\n"
            "\n"
            "        // insert the MIDI file and update MIDI_BANK_END\n"
            "        origin  MIDI_BANK_END\n"
            "        constant origin_MIDI_{file_name}(origin())\n"
            "        insert  MIDI_{file_name}, \"{path_MIDI_{file_name}}\"\n"
            "        OS.align(4)\n"
            "        global variable MIDI_BANK_END(origin())\n"
        )
        new_body = (
            "        // +EXTRA remix_music: vanilla -- reuse vanilla track {ALIAS_{file_name}} instead of inserting this MIDI\n"
            f"        read32  ALIAS_OFFSET_{{file_name}}, \"{rom}\", MUSIC_TABLE + 0x4 + ({{ALIAS_{{file_name}}}} * 0x8)\n"
            f"        read32  ALIAS_SIZE_{{file_name}}, \"{rom}\", MUSIC_TABLE + 0x8 + ({{ALIAS_{{file_name}}}} * 0x8)\n"
            "        origin  MUSIC_TABLE_END\n"
            "        dw      ALIAS_OFFSET_{file_name}\n"
            "        dw      ALIAS_SIZE_{file_name}\n"
            "        global variable MUSIC_TABLE_END(origin())\n"
        )
        old_largest = (
            "        if MIDI_{file_name}.size > largest_midi {\n"
            "            global variable largest_midi(MIDI_{file_name}.size)\n"
        )
        new_largest = (
            "        if ALIAS_SIZE_{file_name} > largest_midi {\n"
            "            global variable largest_midi(ALIAS_SIZE_{file_name})\n"
        )
        # Remix instruments (0x2B-0x46) are only needed by MIDIs that still
        # carry their own data. Keep the instrument entries (MIDIs address them
        # by number) but replace unused ones' sample data with 16 bytes of
        # silence. If any remaining MIDI can't be parsed, keep them all.
        keep = set(range(0x2B, 0x47))
        try:
            needed = set()
            for p in external_midis:
                with open(p, "rb") as f:
                    needed |= cseq.programs(f.read())
            keep = {n for n in needed if n >= 0x2B}
        except (OSError, cseq.Err, IndexError, struct.error) as e:
            logger.warning(f"remix_music: vanilla: keeping all Remix instruments ({e})")
        aliases += [f"    global define KEEP_INST_{n}({int(n in keep)})" for n in range(0x2B, 0x47)]
        old_sample = (
            "        insert SAMPLE_RAW_{inst_num}_{sample_num}, \"../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.aifc\", 0x100, SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008\n"
        )
        new_sample = (
            "        if {KEEP_INST_{inst_num}} == 1 {\n"
            "            insert SAMPLE_RAW_{inst_num}_{sample_num}, \"../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.aifc\", 0x100, SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008\n"
            "            evaluate sample_len(SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008)\n"
            "        } else {\n"
            "            fill    0x10                // +EXTRA: no remaining MIDI uses this instrument\n"
            "            evaluate sample_len(0x10)\n"
            "        }\n"
        )
        old_len = "        dw      SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008               // length of raw data\n"
        new_len = "        dw      {sample_len}                                               // length of raw data\n"

        anchor = "    move_dream_land_midi()\n"
        # Only the 8-argument insert_midi macro matches: insert_external_midi
        # uses {midi_id} rather than {file_name}.
        for old, new in ((old_body, new_body), (old_largest, new_largest),
                         (old_sample, new_sample), (old_len, new_len)):
            if old not in asm:
                logger.error("remix_music: vanilla: midi.asm layout changed; update alias_remix_midis()")
                raise SystemExit(1)
            asm = asm.replace(old, new, 1)
        if asm.count(anchor) != 1:
            logger.error("remix_music: vanilla: move_dream_land_midi() call not found")
            raise SystemExit(1)
        asm = asm.replace(anchor, anchor + "\n".join(aliases) + "\n")

        with open(path, "w", encoding="utf-8") as f:
            f.write(asm)
        print(f"remix_music: vanilla -- aliased {len(calls)} Remix MIDIs to vanilla tracks; "
              f"keeping Remix instruments {sorted(hex(n) for n in keep)}")

    def patch_bgm_asm(self) -> None:
        """Patch BGM.asm with menu music track definitions."""
        lineinfile.add_line_to_file(
            filepath="src/BGM.asm",
            line="\t\t"+"\n\t\t".join(self.midi_menu_defs1),
            inserter=lineinfile.BeforeLast(
                r".*// t1 = max value of menu music \(OFF\)")
        )
        lineinfile.add_line_to_file(
            filepath="src/BGM.asm",
            line="\t\t"+"\n\t\t".join(self.midi_menu_defs2),
            inserter=lineinfile.AfterLast(
                r".*beq     t0, t1, _check_music_toggle")
        )
        lineinfile.add_line_to_file(
            filepath="src/BGM.asm",
            line="\t\t"+"\n\t\t".join(self.midi_menu_defs3),
            inserter=lineinfile.AfterLast(r".*beq     t0, t1, _done")
        )

    def patch_toggle_asm(self) -> None:
        """Patch Toggles.asm with menu music MAX_VALUE, toggle labels and defs."""
        num_menu_track = 0
        with open("src/Toggles.asm", 'r', encoding='utf-8') as f:
            for line in f:
                m = re.match(r'.*constant MAX_VALUE\((.*)\)', line)
                if m:
                    num_menu_track = int(m.group(1))
                    break

        lineinfile.add_line_to_file(
            filepath="src/Toggles.asm",
            line=f'\t\tconstant MAX_VALUE({num_menu_track+len(self.midi_menu_toggle_dw)})',
            regexp=r'.*constant MAX_VALUE\(.*\)'
        )
        lineinfile.add_line_to_file(
            filepath="src/Toggles.asm",
            line="\t"+"\n\t".join(self.midi_menu_toggle_strings),
            inserter=lineinfile.BeforeLast(r'.*menu_music_random_menu:')
        )
        lineinfile.add_line_to_file(
            filepath="src/Toggles.asm",
            line="\t"+"\n\t".join(self.midi_menu_toggle_dw),
            inserter=lineinfile.BeforeFirst(r'.*dw menu_music_random_menu')
        )
        lineinfile.add_line_to_file(
            filepath="src/Toggles.asm",
            line="\t\t"+"\n\t\t".join(self.midi_menu_defs4),
            inserter=lineinfile.AfterLast(r'.*beq     t1, a0, _reset_menu_music')
        )
        lineinfile.add_line_to_file(
            filepath="src/Toggles.asm",
            line="\t\t"+"\n\t\t".join(self.midi_menu_defs5),
            inserter=lineinfile.BeforeLast(r'.*lli     t1, menu_music.MAX_VALUE - 3')
        )
