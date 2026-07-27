"""Load extra_content.yaml and filter which EXTRA folders are built."""

from __future__ import annotations

import os
from typing import Iterable, List, Optional

import yaml

CONTENT_CONFIG_PATH = "extra_content.yaml"


def load_content_config(path: str = CONTENT_CONFIG_PATH) -> dict:
    if not os.path.isfile(path):
        return {}
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    if not isinstance(data, dict):
        raise ValueError(f"{path} must be a mapping")
    return data


def filter_folders(
    folders: Iterable[str],
    selection: Optional[list],
    *,
    kind: str,
) -> List[str]:
    """
    Apply an include list from extra_content.yaml.

    selection:
      - None / missing key: keep all folders (minus "_" prefixes already applied)
      - []: keep none
      - ["A", "B"]: keep only those names (order preserved from folders)
    """
    folders = list(folders)
    if selection is None:
        return folders

    if not isinstance(selection, list):
        raise ValueError(f"extra_content.yaml '{kind}' must be a list or null")

    wanted = {str(name) for name in selection}
    # For stage variants like "EmeraldCoast/remix", match on base folder name
    # when the selection entry is the base name only.
    kept = []
    for folder in folders:
        base = folder.split("/")[0]
        if folder in wanted or base in wanted:
            kept.append(folder)

    missing = wanted - {f.split("/")[0] for f in folders} - set(folders)
    if missing:
        print(f"WARNING: {kind} in {CONTENT_CONFIG_PATH} not found: {sorted(missing)}")

    print(f"{kind} filter: {len(kept)}/{len(folders)} included ({', '.join(kept) or 'none'})")
    return kept
