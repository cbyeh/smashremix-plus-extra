from __future__ import annotations
import re
from typing import List, Tuple
from .logger import logger

OPENERS = {
    "(": ")",
    "{": "}",
    "[": "]",
}
CLOSERS = {value: key for key, value in OPENERS.items()}
QUOTE_CHARS = {'"', "'"}


def find_unmatched_delimiters(text: str) -> List[str]:
    """Return a list of delimiter mismatch messages for the given text."""
    errors: List[str] = []
    stack: List[Tuple[str, int, int]] = []
    in_quote: str | None = None
    escaped = False
    in_block_comment = False

    lines = text.splitlines(keepends=True)
    for line_number, line in enumerate(lines, start=1):
        column = 0
        i = 0
        while i < len(line):
            char = line[i]
            column += 1

            if escaped:
                escaped = False
                i += 1
                continue

            if in_block_comment:
                if char == "*" and i + 1 < len(line) and line[i + 1] == "/":
                    in_block_comment = False
                    i += 2
                    column += 1
                else:
                    i += 1
                continue

            if not in_quote and char == "/" and i + 1 < len(line) and line[i + 1] == "/":
                break

            if not in_quote and char == "/" and i + 1 < len(line) and line[i + 1] == "*":
                in_block_comment = True
                i += 2
                column += 1
                continue

            if in_quote:
                if char == "\\":
                    escaped = True
                    i += 1
                    continue
                if char == in_quote:
                    in_quote = None
                i += 1
                continue

            if char in QUOTE_CHARS:
                in_quote = char
                i += 1
                continue

            if char in OPENERS:
                stack.append((char, line_number, column))
                i += 1
                continue

            if char in CLOSERS:
                if stack and stack[-1][0] == CLOSERS[char]:
                    stack.pop()
                else:
                    errors.append(
                        f"Unmatched closing '{char}' at line {line_number}, column {column}."
                    )
                i += 1
                continue

            i += 1

    if in_quote is not None:
        errors.append(f"Unclosed quote {in_quote} at end of text.")

    while stack:
        opener, line_number, column = stack.pop()
        expected = OPENERS[opener]
        errors.append(
            f"Unmatched opening '{opener}' at line {line_number}, column {column}; expected '{expected}'."
        )

    return errors


def validate_asm(asm_file: str) -> List[str]:
    """Check the given assembly file for unmatched delimiters."""
    errors: List[str] = []

    with open(asm_file, "r", encoding="utf-8") as f:
        text = f.read()

    errors.extend(find_unmatched_delimiters(text))

    if errors:
        logger.error(f"ASM syntax errors found in {asm_file}:")

        for error in errors:
            logger.error(f"  {error}")

        raise SyntaxError(f"ASM syntax errors found in {asm_file}.")

    return errors


def get_included_files(asm_file: str) -> List[str]:
    """Return a list of files included by the given assembly file."""
    included_files: List[str] = []

    with open(asm_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("include"):
                parts = line.split()
                if len(parts) >= 2:
                    included_file = parts[1].strip('"')
                    included_files.append(included_file)

    return included_files


def add_to_scope(file: str, scope: str, entries: List[str]) -> None:
    """Insert entries before the closing brace of a named scope in an ASM file."""
    with open(file, 'r') as f:
        lines = f.readlines()

    in_scope = False
    last_indentation = ''

    for i, line in enumerate(lines):
        if scope in line:
            in_scope = True
        if in_scope and 'constant' in line:
            last_indentation = line[:len(line) - len(line.lstrip())]
        if in_scope and '}' in line:
            new_constants = [f'{last_indentation}{entry}\n' for entry in entries]
            lines[i:i] = new_constants
            break

    with open(file, 'w') as f:
        f.writelines(lines)


def add_to_scope_on_empty(file: str, scope: str, entries: List[str]) -> None:
    """Insert entries at the first blank line inside a named scope in an ASM file."""
    with open(file, 'r') as f:
        lines = f.readlines()

    in_scope = False
    last_indentation = ''

    for i, line in enumerate(lines):
        if scope in line:
            in_scope = True
        if in_scope and 'constant' in line:
            last_indentation = line[:len(line) - len(line.lstrip())]
        if in_scope and line.strip() == '':
            new_constants = [f'{last_indentation}{entry}\n' for entry in entries]
            lines[i:i] = new_constants
            break

    with open(file, 'w') as f:
        f.writelines(lines)


def add_to_label(file: str, label: str, entries: List[str]) -> None:
    """Insert entries after the last data line under a label in an ASM file."""
    with open(file, 'r') as f:
        lines = f.readlines()

    label_found = False
    insert_index = None
    last_indentation = ''

    for i, line in enumerate(lines):
        if f"{label}:" in line:
            label_found = True
            continue
        if label_found:
            if re.match(r'.*OS\.align\(', line) or re.match(r'.*\w+:', line) or re.match(r'.*\}', line):
                insert_index += 1
                break
        if label_found and line.strip():
            last_indentation = line[:len(line) - len(line.lstrip())]
            insert_index = i

    if insert_index:
        new_entries = [f'{last_indentation}{entry}\n' for entry in entries]
        lines[insert_index:insert_index] = new_entries

    with open(file, 'w') as f:
        f.writelines(lines)

def add_to_label_on_empty(file: str, label: str, entries: List[str]) -> None:
    """Insert entries at the first blank line under a label in an ASM file."""
    with open(file, 'r') as f:
        lines = f.readlines()

    label_found = False
    insert_index = None
    last_indentation = ''

    for i, line in enumerate(lines):
        if f"{label}:" in line:
            label_found = True
            last_indentation = line[:len(line) - len(line.lstrip())]
            continue
        if label_found and line.strip() == '':
            insert_index = i
            break

    if insert_index:
        new_entries = [f'{last_indentation}{entry}\n' for entry in entries]
        lines[insert_index:insert_index] = new_entries

    with open(file, 'w') as f:
        f.writelines(lines)
