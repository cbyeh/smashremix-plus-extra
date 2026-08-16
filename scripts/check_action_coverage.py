import os
import re
import argparse
from collections import defaultdict

# The bundled smashremix submodule, resolved relative to this file rather
# than a hardcoded "smashremix/src", since a caller may pull this script in
# from a different working directory (e.g. a content repo that has this
# repo as a submodule under some other name than "smashremix").
BUNDLED_SMASHREMIX_SRC = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "smashremix", "src")

unused_actions = [
    0x4, 0x6, 0xE, 0xC6, 0xC8
]

optional_actions = [
    "LandingAirN",
    "LandingAirF",
    "LandingAirB",
    "LandingAirU",
    "LandingAirD",
    "FSmashHigh",
    "FSmashMidHigh",
    "FSmashLow",
    "FSmashMidLow",
    "FTiltLow",
    "FTiltMidLow",
    "FTiltHigh",
    "FTiltMidHigh",
    "Thrown3",
    "ThrownFoxB",
    "ThrownFoxFStart",
]


def parse_actions_file(actions_file):
    actions = {}
    scope_pattern = re.compile(r"scope\s+(\w+)")
    action_pattern = re.compile(r"constant\s+(\w+)\((0x[0-9A-Fa-f]+)\)")
    current_scope = None

    with open(actions_file, 'r') as file:
        for line in file:
            scope_match = scope_pattern.search(line)
            if scope_match:
                current_scope = scope_match.group(1)
            elif current_scope == "Action":
                action_match = action_pattern.search(line)
                if action_match:
                    action_name, action_value = action_match.groups()
                    actions[action_name] = int(action_value, 16)

    for action_name, action_value in list(actions.items()):
        if action_value in unused_actions:
            del actions[action_name]

    return actions


def get_shared_animation_reuse_map(actions, min_shared=3):
    value_to_name = {v: k for k, v in actions.items()}
    pattern = re.compile(
        r"\s*Character\.edit_action_parameters\(\s*[^,]+,\s*([A-Za-z0-9_.]+),\s*([^,]+),"
    )
    animation_to_actions = defaultdict(set)

    for src_dir in ["src", BUNDLED_SMASHREMIX_SRC]:
        if not os.path.isdir(src_dir):
            continue
        for root, _, files in os.walk(src_dir):
            for file in files:
                if not file.endswith(".asm"):
                    continue
                if file == "sandbag.asm" or file.endswith("_extra.asm"):
                    continue

                with open(os.path.join(root, file), encoding="utf-8") as f:
                    for line in f:
                        match = pattern.search(line)
                        if match:
                            raw_action, animation = map(
                                str.strip, match.groups())

                            if raw_action.startswith("Action."):
                                action_name = raw_action
                            else:
                                try:
                                    if raw_action.startswith("0x"):
                                        val = int(raw_action, 16)
                                    else:
                                        val = int(raw_action)
                                    resolved = value_to_name.get(val)
                                    action_name = f"Action.{resolved}" if resolved else f"Action.UNKNOWN_0x{val:X}"
                                except Exception:
                                    action_name = "Action.UNKNOWN"

                            animation_to_actions[animation].add(action_name)

    co_usage_count = defaultdict(lambda: defaultdict(int))
    for actions_set in animation_to_actions.values():
        filtered = [a for a in actions_set if a.startswith("Action.")]
        for a in filtered:
            for b in filtered:
                if a != b:
                    co_usage_count[a][b] += 1

    action_shared_map = {}
    for action, related in co_usage_count.items():
        shared = [other for other, count in related.items() if count >=
                  min_shared]
        if shared:
            action_shared_map[action] = sorted(shared)

    return action_shared_map


def parse_character_file(character_file, actions):
    handled_actions = set()
    action_to_anim = {}
    character_vars = []
    pattern = re.compile(
        r"\s*Character\.edit_action_parameters\(\s*([^,]+),\s*([A-Za-z0-9_.]+),\s*(?:File\.([A-Z0-9_]+)|0)"
    )
    value_to_name = {v: k for k, v in actions.items()}

    with open(character_file, 'r') as file:
        for line in file:
            match = pattern.search(line)
            if match:
                raw_character, raw_action, anim_name = match.groups()
                character_var = raw_character.strip()
                if character_var not in character_vars:
                    character_vars.append(character_var)

                if raw_action.startswith("Action."):
                    action_key = raw_action[7:]
                else:
                    try:
                        if raw_action.startswith("0x"):
                            val = int(raw_action, 16)
                        else:
                            val = int(raw_action)
                        action_key = value_to_name.get(
                            val, f"UNKNOWN_0x{val:X}")
                    except Exception:
                        action_key = "UNKNOWN"

                if action_key != "UNKNOWN":
                    handled_actions.add(action_key)
                    anim_full = f"File.{anim_name}" if anim_name else "0"
                    action_to_anim[f"Action.{action_key}"] = anim_full

    return handled_actions, action_to_anim, character_vars


def get_all_used_actions_in_src(actions):
    value_to_name = {v: k for k, v in actions.items()}
    pattern = re.compile(
        r"\s*Character\.edit_action_parameters\(\s*\w+,\s*([A-Za-z0-9_.]+),"
    )
    found = set()

    for src_dir in ["src", BUNDLED_SMASHREMIX_SRC]:
        if not os.path.isdir(src_dir):
            continue
        for root, _, files in os.walk(src_dir):
            for f in files:
                if not f.endswith(".asm"):
                    continue
                with open(os.path.join(root, f), encoding="utf-8") as fh:
                    for line in fh:
                        m = pattern.search(line)
                        if m:
                            raw = m.group(1)
                            if raw.startswith("Action."):
                                found.add(raw[7:])
                            else:
                                try:
                                    if raw.startswith("0x"):
                                        val = int(raw, 16)
                                    else:
                                        val = int(raw)
                                    name = value_to_name.get(val)
                                    if name:
                                        found.add(name)
                                except Exception:
                                    pass
    return found


def analyze_coverage(actions_file, character_file):
    actions = parse_actions_file(actions_file)
    used_in_any_file = get_all_used_actions_in_src(actions)
    filtered_actions = {k: v for k,
                        v in actions.items() if k in used_in_any_file}

    handled_actions, action_to_anim, character_vars = parse_character_file(
        character_file, actions)
    reuse_map = get_shared_animation_reuse_map(actions, min_shared=3)

    if len(character_vars) > 1:
        print(
            f"> WARNING: multiple character variables found in {character_file}: {character_vars}."
        )
        print(
            "> This file may be editing more than one character, which is likely incorrect."
        )

    character_var = character_vars[0] if character_vars else "character"

    required_missing = set()
    optional_missing = set()

    for action in filtered_actions:
        if action not in handled_actions:
            if action in optional_actions:
                optional_missing.add(action)
            else:
                required_missing.add(action)

    total_actions = len(filtered_actions)
    total_optional = len(
        [a for a in filtered_actions if a in optional_actions])
    total_required = total_actions - total_optional

    required_covered = total_required - len(required_missing)
    optional_covered = total_optional - len(optional_missing)
    overall_covered = required_covered + optional_covered

    def percent(n, d):
        return f"{n}/{d} ({round(n / d * 100, 2)}%)" if d > 0 else "0/0 (0%)"

    print(f"> Total Actions: {total_actions}")
    print(
        f"> Required Covered Actions: {percent(required_covered, total_required)}")
    print(
        f"> Optional Covered Actions: {percent(optional_covered, total_optional)}")
    print(
        f"> Overall Covered Actions: {percent(overall_covered, total_actions)}")
    print(f"> Missing Required Actions: {len(required_missing)}")
    print(f"> Missing Optional Actions: {len(optional_missing)}")

    def print_missing_section(title, missing_set):
        if missing_set:
            print(f"\n========== {title} ==========")
            for action in sorted(missing_set):
                print(f"{action} (0x{actions[action]:02X})")

    print_missing_section("Missing Required Actions", required_missing)
    print_missing_section("Missing Optional Actions", optional_missing)

    print("\n========== Suggested Reuses ==========\n")
    for missing in sorted(required_missing | optional_missing):
        missing_key = f"Action.{missing}"
        is_optional = missing in optional_missing
        suggestions = []

        if missing_key in reuse_map:
            seen_anims = set()
            for source_action in reuse_map[missing_key]:
                if source_action in action_to_anim:
                    anim = action_to_anim[source_action]
                    if anim not in seen_anims:
                        seen_anims.add(anim)
                        suggestions.append(
                            f"Character.edit_action_parameters({character_var}, {missing_key}, {anim}, -1, -1)"
                        )

        if suggestions:
            print(
                f"# Missing action animation: {missing_key} {'(optional)' if is_optional else ''}")
            print("# Suggested reuses:")
            for line in suggestions:
                print(line)
            print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Analyze character action coverage and suggest reuse."
    )
    parser.add_argument("actions_file", type=str,
                        help="Path to the actions file (e.g., Action.asm).")
    parser.add_argument("character_file", type=str,
                        help="Path to the character file (e.g., Falco.asm).")
    args = parser.parse_args()

    analyze_coverage(args.actions_file, args.character_file)
