---
name: test-rom
description: Build a self-playing Smash Remix +EXTRA test ROM and run it in Mupen in the background (scripted controller input, screenshots). Use to playtest characters, reproduce a bug, or check a build change in game without touching the user's keyboard.
---

# Test a ROM in game

`scripts/autoplay/` builds a **test-only** ROM whose controller ports 1 and 2 read from a frame script instead of the pad, so the game drives its real menus and matches by itself. Release builds never include it.

## Prerequisites (macOS)
- A finished build: `pipenv run python character_appender.py` (makes `main.asm`, `src/`, `smashremix/roms/original_extra.z64`).
- bass with the Remix extensions at `/tmp/bass-src/bass/bass` (override with `BASS=`).
- `~/n64/emu/run.sh` (Mupen, GLideN64, rsp-hle, runs behind the user's windows and hands focus back).

## Run
```sh
python3 -I scripts/autoplay/run.py scripts/autoplay/ken_p1.txt scripts/autoplay/ryu_p2.txt \
  --shots "$(seq -s, 1800 15 4500),99999" --timeout 1500 --out /tmp/ap_out
python3 -I scripts/autoplay/run.py p1.txt [p2.txt] --rom /tmp/x.z64     # build only, no --shots
```
- End the shot list with a huge frame (`99999`): Mupen quits after the last shot.
- Each screenshot costs ~2.5 s: shoot every 15 frames, not every frame. Run long jobs in the background, **one emulator at a time** (two at once ran 4x slower and timed out).
- Contact sheet: `ffmpeg -pattern_type glob -i '/tmp/ap_out/*.png' -vf "scale=320:-1,tile=6x4" -frames:v 1 sheet.png`.

## Script format
One line per step: `<frames> [BUTTON+BUTTON|_] [stick_x stick_y]  # comment`. Buttons: `A B Z START DU DD DL DR L R CU CD CL CR`; stick -80..80. The script ends neutral.
- Timing is in game frames (`Global.frame_counter`), not polls: the game polls the pad more than once a frame. Screenshot frame numbers are VI frames and drift against it: confirm with shots.
- Runs of one ROM are deterministic; two different ROMs are not like for like (load times shift input timing), so don't pixel-diff builds.

## Known recipes (16-character build)
- `to_vs_css.txt`: 13 START taps 40 frames apart reach Mode Select, then DD, A, A: VS character select. Port 2 shows as HMN (the hook reports it connected).
- Extra characters live in the **"+" bonus bookend** (left of the grid): cursor on it, tap **R** (4 on, 12 off) to step through `CharacterSelect.bonus_chars` (Dark Samus = 0, Ken 14, MRGAW 16, Ryu 19), then A. Taps before the cursor arrives are lost, and how many depends on the rest of the script (P2 lost 3 to 5): **always screenshot the selection (~frame 1250) before a long run.** P2 needed 22 taps for Ryu and 21 + `DU` (D-pad up = SPECIAL variant) for MRGAWPLUS (`mrgaw_p1.txt` / `mrgawvar_p2.txt`).
- Cursor moves ~9 px/frame at full stick. P1: 26 up + 10 left reaches "+"; P2: 26 up + 27 left.
- Stage select: tap A several times (it accepts input late). `moveset.py p1.txt p2.txt` appends a full moveset to both, synced, P2 mirrored.

## Verify file wiring without playing
After a build, every `File.asm` name should resolve to its file's final bytes in `original_extra.z64` (compare `SSB.SSBtbl.fromROM(...)[id].extract('data')` against the source file for each `Added file` / `Deduplicated` line of the last run in `smashremix_extra.log`). This caught a dedup that pointed MRGAWPLUS at MRGAW's `main.bin`.
