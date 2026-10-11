"""Dump a character's FTAttributes to character_attributes.yaml (debug).
Same field names as config['attributes']; the offset tables are passed in
from processor.py so this can't drift from the write path."""
from __future__ import annotations

import struct

import yaml


def dump(data, attr_offset, attr_values, attr_ints, attr_sounds):
    """data = the patched main.bin bytes. attr_values (f32) / attr_ints (s32)
    / attr_sounds (u16 hex) = {config key: byte offset}. -> YAML string."""
    doc = {}
    for name, pos in attr_values.items():
        doc[name] = struct.unpack_from(">f", data, attr_offset + pos)[0]
    for name, pos in attr_ints.items():
        doc[name] = struct.unpack_from(">i", data, attr_offset + pos)[0]
    for name, pos in attr_sounds.items():
        doc[name] = f"{struct.unpack_from('>H', data, attr_offset + pos)[0]:04X}"
    return yaml.safe_dump(doc, sort_keys=True, default_flow_style=False, width=100)


def dump_to(out_path, data, attr_offset, attr_values, attr_ints, attr_sounds):
    open(out_path, "w", encoding="utf-8").write(
        dump(data, attr_offset, attr_values, attr_ints, attr_sounds))
    return out_path
