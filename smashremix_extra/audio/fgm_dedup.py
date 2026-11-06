"""
Share byte-identical sound samples in src/FGM.asm.

Remix's FGM.asm inserts one copy of raw sample data per add_sound / add_sound_advanced
call. Several characters ship identical .aifc samples (e.g. the three Mr. Game & Watch
variants), so this patches the generated FGM.asm to insert each distinct sample once and
point duplicates' wavetables at the first copy. Each sample keeps its own predictors and
loop params, so playback is unchanged.
"""
import hashlib
import os
import re

from ..logger import logger

CALL = re.compile(r"^\s*(add_sound|add_sound_advanced)\((.*)\)\s*(//.*)?$")

INSERT_LOOP = """        while {n} <= new_sample_count {
            insert_raw_data({n})
            evaluate n({n}+1)
        }"""
INSERT_LOOP_NEW = """        while {n} <= new_sample_count {
            if !{defined SOUND_DUP_{n}} {
                global evaluate SOUND_RAW_OFFSET_{n}(origin() - RAW_SAMPLE_DATA)
                insert_raw_data({n})
            }
            evaluate n({n}+1)
        }"""
POINTERS = """            dw      raw_sample_data_extended_origin + added_raw_data_size - RAW_SAMPLE_DATA
            dw      SOUND_RAW_{num}.size
            variable added_raw_data_size(added_raw_data_size + SOUND_RAW_{num}.size)"""
POINTERS_NEW = """            if {defined SOUND_DUP_{num}} {
                evaluate src({SOUND_DUP_{num}})
            } else {
                evaluate src({num})
            }
            dw      {SOUND_RAW_OFFSET_{src}}
            dw      SOUND_RAW_{src}.size"""


def sample_bytes(aifc_path: str) -> bytes:
    """The bytes insert_raw_data() writes: 0x100 .. 0x100 + u32@0xF4 - 8."""
    with open(aifc_path, "rb") as f:
        data = f.read()
    size = int.from_bytes(data[0xF4:0xF8], "big") - 8
    return data[0x100:0x100 + size]


def dedup_fgm_samples(fgm_asm: str = "src/FGM.asm") -> int:
    """Patch fgm_asm in place. Returns the number of sample bytes no longer stored."""
    with open(fgm_asm, encoding="utf-8") as f:
        text = f.read()
    if INSERT_LOOP not in text or POINTERS not in text:
        logger.error("FGM.asm sample loops changed upstream: update smashremix_extra/audio/fgm_dedup.py")
        exit(1)

    # Sample numbers follow call order; that only holds if no call sits in an if/while/macro.
    lines = text.splitlines()
    calls = [i for i, l in enumerate(lines) if CALL.match(l)]
    for l in lines[calls[0]:calls[-1]]:
        if re.match(r"\s*(if|while|macro|scope)\b", l):
            logger.error(f"FGM.asm: add_sound calls are no longer straight-line ({l.strip()}): update fgm_dedup.py")
            exit(1)

    src_dir = os.path.dirname(fgm_asm)
    first, defines, saved, num = {}, [], 0, 0
    for line in lines:
        m = CALL.match(line)
        if not m:
            continue
        num += 1
        args = [a.strip() for a in m.group(2).split(",")]
        name = args[0] if m.group(1) == "add_sound" else args[1]
        data = sample_bytes(os.path.join(src_dir, name + ".aifc"))
        key = hashlib.sha1(data).digest()
        if key in first:
            defines.append(f"global define SOUND_DUP_{num}({first[key]})")
            saved += len(data)
        else:
            first[key] = num

    text = text.replace(INSERT_LOOP, INSERT_LOOP_NEW, 1).replace(POINTERS, POINTERS_NEW, 1)
    # defines go before the first add_sound call so the loops (which run later) see them
    first_call = next(m.start() for m in re.finditer(r"(?m)^\s*(add_sound|add_sound_advanced)\(", text))
    text = text[:first_call] + "\n".join("    " + d for d in defines) + "\n" + text[first_call:]
    with open(fgm_asm, "w", encoding="utf-8") as f:
        f.write(text)
    logger.info(f"FGM: {len(defines)} of {num} samples shared, {saved} bytes saved")
    return saved
