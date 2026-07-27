import os
import re
import yaml
import lineinfile
from typing import List, Optional

from smashremix_extra.logger import logger
from smashremix_extra.content_filter import filter_folders


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
                    f for f in os.listdir(f"extra_music/{_dir}/")
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
        # ASM lives between original_extra and MIDI_BANK. Remix reserved 4MB;
        # measured custom_heap is ~1.8MB for this roster, so 2.5MB is enough
        # headroom and recovers ~1.5MB toward the 64MB iOS limit.
        asm_headroom = int("0x280000", 16)  # 2.5 MB
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
