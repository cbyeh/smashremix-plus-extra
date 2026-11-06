import struct

from PIL import Image

# 1P victory ("clear") image: two files (top/bottom), each a sprite with
# 300x110 RGBA32 pixels. The game reads the Sprite header at a fixed offset.
WIDTH = 300
HALF_HEIGHT = 110
STRIP_HEIGHT = 3  # rows per bitmap (300 * 4 * 3 bytes)
STRIP_PAD = bytes.fromhex("DF00000000000000")  # precedes every strip


def _swap_qwords(row: bytes) -> bytes:
    # RGBA32 TMEM interleave: odd rows have each pair of 8-byte words swapped
    return b"".join(row[i + 8:i + 16] + row[i:i + 8] for i in range(0, len(row), 16))


def _build_sprite(image: Image.Image) -> tuple[bytes, int]:
    """Returns (file bytes, offset of first reloc pointer)."""
    pixels = image.tobytes()
    row_size = WIDTH * 4
    num_strips = -(-HALF_HEIGHT // STRIP_HEIGHT)

    data = bytearray()
    strips = []  # (buffer offset, height)
    for i in range(num_strips):
        height = min(STRIP_HEIGHT, HALF_HEIGHT - i * STRIP_HEIGHT)
        data += STRIP_PAD
        strips.append((len(data), height))
        for r in range(height):
            y = i * STRIP_HEIGHT + r
            row = pixels[y * row_size:(y + 1) * row_size]
            data += _swap_qwords(row) if r % 2 else row

    bitmaps_offset = len(data)
    sprite_offset = bitmaps_offset + num_strips * 0x10
    bitmap_ptr_offset = sprite_offset + 0x34

    # Bitmap structs; buf pointers form the reloc chain
    for i, (buf, height) in enumerate(strips):
        if i + 1 < num_strips:
            next_reloc = (bitmaps_offset + (i + 1) * 0x10 + 8) // 4
        else:
            next_reloc = bitmap_ptr_offset // 4
        data += struct.pack(">hhhhHHhh", WIDTH, WIDTH, 0, 0,
                            next_reloc, buf // 4, height, 0)

    # Sprite struct
    data += struct.pack(
        ">hhhhffhhHhBBBBhhIhhhhhhBBxxHHIIhh",
        0, 0, WIDTH, HALF_HEIGHT,     # x, y, width, height
        1.0, 1.0,                     # scalex, scaley
        0, 0,                         # expx, expy
        0x0220, 0x1234,               # attr, zdepth
        0xFF, 0xFF, 0xFF, 0xFF,       # rgba
        0, 0, 0,                      # startTLUT, nTLUT, LUT
        0, 1,                         # istart, istep
        num_strips, 0x1D4,            # nbitmaps, ndisplist
        STRIP_HEIGHT, STRIP_HEIGHT,   # bmheight, bmHreal
        0, 3,                         # bmfmt (RGBA), bmsiz (32b)
        0xFFFF, bitmaps_offset // 4,  # bitmap (end of reloc chain)
        0, 0,                         # rsp_dl, rsp_dl_next
        0, 0,                         # frac_s, frac_t
    )
    data += bytes(-len(data) % 8)

    return bytes(data), bitmaps_offset + 8


def generate_victory_images(png_path: str, top_path: str, bottom_path: str) -> int:
    """
    Splits a 300x220 1P clear image into top/bottom Sprite files.
    Returns the internal file table offset (same for both files).
    """
    image = Image.open(png_path).convert("RGBA")
    if image.size != (WIDTH, HALF_HEIGHT * 2):
        raise ValueError(
            f"{png_path} must be {WIDTH}x{HALF_HEIGHT * 2}, got {image.width}x{image.height}")

    reloc_offset = None
    for path, top in ((top_path, 0), (bottom_path, HALF_HEIGHT)):
        half = image.crop((0, top, WIDTH, top + HALF_HEIGHT))
        data, reloc_offset = _build_sprite(half)
        with open(path, "wb") as f:
            f.write(data)

    return reloc_offset
