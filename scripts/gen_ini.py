import argparse
import hashlib
import os

TEMPLATE = """[{}]
GoodName=SmashRemix2.0.1 {}
CRC={} {}
RefMD5=5AAC6E652C5CF1E37A466AC0073E88CA
CountPerOp=1"""


def main(filename):
    with open(filename, "rb") as f:
        md5 = hashlib.md5(f.read()).hexdigest().upper()
        f.seek(0x10)
        val1 = f.read(4)
        val2 = f.read(4)
    hex1 = val1.hex().upper()
    hex2 = val2.hex().upper()

    version_txt_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "version.txt")
    with open(version_txt_path, 'r', encoding='utf-8') as f:
        version = f.read()

    print(TEMPLATE.format(md5, version, hex1, hex2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate INI entry from ROM file."
    )
    parser.add_argument(
        "filename",
        nargs="?",
        default="ssb64asm_extra.z64",
        help="Path to the ROM file (default: %(default)s)"
    )
    args = parser.parse_args()
    main(args.filename)