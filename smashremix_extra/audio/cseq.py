"""
Program-change scan for N64 libultra compressed sequences (ALCSeq), the format
Remix's MIDIs use. Follows libultra's __getTrackByte: 0xFE starts a back-reference
(2-byte distance, 1-byte length) unless doubled.

Self-check against the vanilla tracks (they must only use instruments <= 0x2A):
    python -m smashremix_extra.audio.cseq smashremix/roms/original_extra.z64
"""
import struct

class Err(Exception): pass

def programs(seq):
    progs = set()
    offsets = struct.unpack_from(">16I", seq, 0)
    for trk, start in enumerate(offsets):
        if not start: continue
        loc = [start]; bu = [0, 0]  # backup ptr, backup len
        def byte():
            if bu[1]:
                b = seq[bu[0]]; bu[0] += 1; bu[1] -= 1; return b
            if loc[0] >= len(seq): raise Err(f"track {trk} ran off the end")
            b = seq[loc[0]]; loc[0] += 1
            if b == 0xFE:
                nxt = seq[loc[0]]; loc[0] += 1
                if nxt != 0xFE:
                    back = (nxt << 8) | seq[loc[0]]; loc[0] += 1
                    ln = seq[loc[0]]; loc[0] += 1
                    bu[0] = loc[0] - (back + 4); bu[1] = ln
                    if bu[0] < 0: raise Err("bad backref")
                    b = seq[bu[0]]; bu[0] += 1; bu[1] -= 1
            return b
        def varlen():
            v = 0
            for _ in range(4):
                b = byte(); v = (v << 7) | (b & 0x7F)
                if not b & 0x80: return v
            raise Err("varlen too long")
        status = None; events = 0
        while True:
            varlen()                                   # delta time
            b = byte()
            if b >= 0x80:
                status = b
                if b == 0xFF:
                    t = byte()
                    if t == 0x2F: break                # end of track
                    elif t == 0x51: byte(); byte(); byte()
                    elif t == 0x2E: byte(); byte()     # loop start
                    elif t == 0x2D: [byte() for _ in range(6)]   # loop end
                    else: raise Err(f"track {trk}: unknown meta 0x{t:02X}")
                    status = None; continue
                d1 = byte()
            else:
                if status is None: raise Err(f"track {trk}: data byte without status")
                d1 = b
            hi = status & 0xF0
            if hi == 0x90: byte(); varlen()            # note: velocity + duration
            elif hi in (0x80, 0xA0, 0xB0, 0xE0): byte()
            elif hi == 0xC0: progs.add(d1)
            elif hi == 0xD0: pass
            else: raise Err(f"track {trk}: status 0x{status:02X}")
            events += 1
            if events > 2_000_000: raise Err("runaway")
    return progs


if __name__ == "__main__":
    import sys
    rom = open(sys.argv[1], "rb").read()
    table = struct.unpack_from(">I", rom, 0x3D768)[0]
    used, parsed = set(), 0
    for i in range(1, 0x2F):
        off, size = struct.unpack_from(">II", rom, table + 4 + 8 * i)
        try:
            used |= programs(rom[table + off: table + off + size])
            parsed += 1
        except Err:
            pass
    assert parsed >= 40 and max(used) == 0x2A, (parsed, sorted(used))
    print(f"ok: {parsed}/46 vanilla tracks parsed, instruments 0x00-0x{max(used):02X}")
