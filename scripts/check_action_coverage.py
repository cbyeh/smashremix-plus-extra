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

# Values passed as the animation argument that mean "no override" rather than
# a real animation asset. Two actions both left at one of these don't tell us
# anything about whether their *animations* are interchangeable, so they must
# be excluded when building the reuse map below or they'd cluster every
# unrelated action in the game together.
SENTINEL_ANIMATIONS = {"-1", "0"}


def strip_comment(line):
    """Drop a trailing "// ..." comment. Character files commonly keep
    commented-out example/placeholder Character.edit_action_parameters
    calls (often referencing an animation constant that was never actually
    created) as scaffolding for actions the author hasn't gotten to yet -
    without this, every regex scan below would treat that placeholder text
    as a real, active declaration."""
    return line.split("//", 1)[0]

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


def get_shared_animation_reuse_map(actions, min_shared=2):
    """Find pairs of actions that are frequently pointed at the exact same
    animation asset across characters. Each character's own file can only
    ever contribute a literal string match for its own animation names, so a
    count > 1 here means multiple, independent characters made the same
    choice to reuse one animation for both actions - a real signal that the
    two actions are usually interchangeable animation-wise.

    Returns {action: [(other_action, count), ...]} sorted by count desc.
    """
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
                # Sandbag has no real animations of its own - it points
                # almost every action (Sleep, Stun, Dash, Run, ...) at the
                # same idle pose, which would otherwise look like a strong
                # cross-character signal that those actions are interchangeable.
                if file.lower() == "sandbag.asm" or file.endswith("_extra.asm"):
                    continue

                with open(os.path.join(root, file), encoding="utf-8") as f:
                    for line in f:
                        match = pattern.search(strip_comment(line))
                        if match:
                            raw_action, animation = map(
                                str.strip, match.groups())

                            if animation in SENTINEL_ANIMATIONS:
                                continue

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
        shared = [(other, count) for other, count in related.items()
                  if count >= min_shared]
        if shared:
            shared.sort(key=lambda pair: (-pair[1], pair[0]))
            action_shared_map[action] = shared

    return action_shared_map


def parse_character_file(character_file, actions):
    handled_actions = set()
    action_to_anim = {}
    character_vars = []
    # The animation argument counts as "handled" whether it's a real asset
    # (File.X), or one of the "no override" sentinels (0 / -1) - a character
    # can legitimately configure an action's moveset/hitbox data without
    # giving it its own animation.
    pattern = re.compile(
        r"\s*Character\.edit_action_parameters\(\s*([^,]+),\s*([A-Za-z0-9_.]+),\s*(File\.[A-Z0-9_]+|0|-1)\b"
    )
    value_to_name = {v: k for k, v in actions.items()}

    with open(character_file, 'r') as file:
        for line in file:
            match = pattern.search(strip_comment(line))
            if match:
                raw_character, raw_action, anim_full = match.groups()
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
                        m = pattern.search(strip_comment(line))
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


def analyze_coverage(actions_file, character_file, min_shared=2, max_suggestions=3):
    actions = parse_actions_file(actions_file)
    used_in_any_file = get_all_used_actions_in_src(actions)
    filtered_actions = {k: v for k,
                        v in actions.items() if k in used_in_any_file}

    handled_actions, action_to_anim, character_vars = parse_character_file(
        character_file, actions)
    reuse_map = get_shared_animation_reuse_map(actions, min_shared=min_shared)

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

    def find_suggestions(missing_action):
        """For a missing action, rank the character's own already-defined
        actions by how often other characters reuse the same animation for
        both, then return up to max_suggestions distinct animations."""
        missing_key = f"Action.{missing_action}"
        suggestions = []
        seen_anims = set()

        for source_action, count in reuse_map.get(missing_key, []):
            if source_action not in action_to_anim:
                continue
            anim = action_to_anim[source_action]
            if anim in seen_anims or anim in SENTINEL_ANIMATIONS:
                continue
            seen_anims.add(anim)
            suggestions.append((source_action, anim, count))
            if len(suggestions) >= max_suggestions:
                break

        return suggestions

    all_missing = required_missing | optional_missing
    suggestions_by_action = {
        missing: find_suggestions(missing) for missing in all_missing
    }
    suggestable_required = sum(
        1 for a in required_missing if suggestions_by_action[a])
    suggestable_optional = sum(
        1 for a in optional_missing if suggestions_by_action[a])

    print(f"> Total Actions: {total_actions}")
    print(
        f"> Required Covered Actions: {percent(required_covered, total_required)}")
    print(
        f"> Optional Covered Actions: {percent(optional_covered, total_optional)}")
    print(
        f"> Overall Covered Actions: {percent(overall_covered, total_actions)}")
    print(
        f"> Missing Required Actions: {len(required_missing)} ({suggestable_required} have a suggested reuse)")
    print(
        f"> Missing Optional Actions: {len(optional_missing)} ({suggestable_optional} have a suggested reuse)")

    def print_missing_section(title, missing_set):
        if missing_set:
            print(f"\n========== {title} ==========")
            for action in sorted(missing_set):
                flag = " *" if suggestions_by_action[action] else ""
                print(f"{action} (0x{actions[action]:02X}){flag}")
            if any(suggestions_by_action[a] for a in missing_set):
                print("(* has a suggested reuse below)")

    print_missing_section("Missing Required Actions", required_missing)
    print_missing_section("Missing Optional Actions", optional_missing)

    print("\n========== Suggested Reuses ==========")
    print(
        "; Animations the character already has, ranked by how many other characters\n"
        "; reuse that same animation for both the missing action and the source action.\n"
    )
    for missing in sorted(all_missing):
        missing_key = f"Action.{missing}"
        is_optional = missing in optional_missing
        suggestions = suggestions_by_action[missing]

        if suggestions:
            print(
                f"; {missing_key}{' (optional)' if is_optional else ''} - reuse candidates found")
            for source_action, anim, count in suggestions:
                times = "character" if count == 1 else "characters"
                print(
                    f"Character.edit_action_parameters({character_var}, {missing_key}, {anim}, -1, -1) "
                    f"; same animation as {source_action} in {count} other {times}"
                )
            print()

    total_missing = len(all_missing)
    total_suggestable = suggestable_required + suggestable_optional
    print(
        f"; {total_suggestable}/{total_missing} missing actions have a suggested animation reuse "
        f"({suggestable_required} required, {suggestable_optional} optional)."
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Analyze character action coverage and suggest reuse."
    )
    parser.add_argument("actions_file", type=str,
                        help="Path to the actions file (e.g., Action.asm).")
    parser.add_argument("character_file", type=str,
                        help="Path to the character file (e.g., Falco.asm).")
    parser.add_argument("--min-shared", type=int, default=2,
                        help="Minimum number of other characters that must reuse the "
                             "same animation for two actions before suggesting the "
                             "pairing (default: 2).")
    parser.add_argument("--max-suggestions", type=int, default=3,
                        help="Maximum number of reuse candidates to show per missing "
                             "action (default: 3).")
    args = parser.parse_args()

    analyze_coverage(args.actions_file, args.character_file,
                      min_shared=args.min_shared, max_suggestions=args.max_suggestions)
