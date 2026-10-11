import os
import sys
import argparse

# Python adaptation of SSB64FileAppender.java
def append_file(
    path_add: str, original_offset: int, internal_file_table_offset: int,
    path_target: str, target_internal_file_table_offset: int,
    path_output: str
):
    add_data: bytearray = bytearray()
    target_data: bytearray = bytearray()
    output_data: bytearray = bytearray()

    # This correction value will be applied to all pointers we find
    # Initially it is the original_offset, but if a target file is specified we must account for the internal file table offset of that file
    correction: int = -original_offset
    offset: int = internal_file_table_offset

    if (path_target is None) != (target_internal_file_table_offset is None):
        raise TypeError("Arguments target_file_path and target_table_offset must be specified together or omitted together.")

    # Read file that will be appended onto target data
    with open(path_add, 'rb') as add_file:
        add_data = bytearray(add_file.read())
        add_length = len(add_data)

    # Read target file that will get appended with new data
    if path_target is not None:
        with open(path_target, 'rb') as target_file:
            target_data = bytearray(target_file.read())
            target_length = len(target_data)

            correction += target_length
            offset += target_length

    output_data = target_data + add_data
    appended_length = len(output_data)

    if appended_length >= 0x3FFFC:
        raise ValueError("Result output too large, exceeds addressable space (0x3FFFC)")

    # Update final pointer from target file to point to first pointer in new file
    if path_target is not None:
        if target_internal_file_table_offset > 0:
            current_pointer_offset = target_internal_file_table_offset

            while current_pointer_offset < appended_length:
                next_pointer: int = get_pointer(output_data, current_pointer_offset, "next")

                if next_pointer == 0xFFFFFFFC or next_pointer == 0x3FFFC:
                    update_pointer(output_data, current_pointer_offset, offset, "next")
                    break

                current_pointer_offset = next_pointer

    # Update pointers in appended data
    while offset < appended_length and offset >= 0:
        pointers: list[int] = get_pointer(output_data, offset, "both")
        pointers_corrected: list[int] = [pointers[0] + correction, pointers[1] + correction]

        if  (not (pointers[0] == 0xFFFFFFFC or pointers[0] == 0x3FFFC)
            and pointers_corrected[0] < len(output_data)
            and pointers_corrected[0] >= 0):
                update_pointer(output_data, offset, pointers_corrected[0], "next")
        else: # this is the last "next" pointer, set to 0xFFFF
            update_pointer(output_data, offset, 0x3FFFC, "next")

        update_pointer(output_data, offset, pointers_corrected[1], "data")

        # Warn about pointers in external offset ranges
        if (pointers[1] - original_offset) < 0:
            print(f"Warning! Data pointer at 0x{offset:08X} references external offset (before start of added file): 0x{pointers_corrected[1]:08X}")
        elif (pointers[1] - original_offset) >= add_length:
            print(f"Warning! Data pointer at 0x{offset:08X} references external offset (after end of added file): 0x{pointers_corrected[1]:08X}")

        if pointers[0] == 0xFFFFFFFC or pointers[0] == 0x3FFFC:
            break

        offset = pointers_corrected[0]

    # Write output file with updated pointers
    with open(path_output, 'wb') as output_file:
        output_file.seek(0)
        output_file.write(output_data)

    return 0

def get_pointer(
    data: bytearray,
    offset: int,
    type: str
) -> int | list[int]:
    # commented version here should be how the original appender does it instead?
    #next_pointer: int = (((data[offset] << 8) & 0xFF00) | (data[offset + 0x01] & 0xFF)) * 4
    #data_pointer: int = (((data[offset + 0x02] << 8) & 0xFF00) | (data[offset + 0x03] & 0xFF)) * 4

    next_pointer: int = int.from_bytes(data[offset : offset+2], byteorder='big') * 4
    data_pointer: int = int.from_bytes(data[offset+2 : offset+4], byteorder='big') * 4

    # print(f'[GetPtr] (@ 0x{offset:08X}) Next 0x{next_pointer:08X} | 0x{data_pointer:08X} Data    (0x{next_pointer // 4:04X} | 0x{data_pointer // 4:04X})')

    if   type == "next": return next_pointer
    elif type == "data": return data_pointer
    elif type == "both": return [next_pointer, data_pointer]

    return 0

def update_pointer(
    data: bytearray,
    offset: int,
    new_address: int | list[int],
    ptr_type: str | None
) -> int:
    # commented version here should be how the original appender does it instead?
    #data[offset] = (new_addresses[0] // 4 >> 8) & 0xFF
    #data[offset+1] = (new_addresses[0] // 4) & 0xFF
    #data[offset+2] = ((new_addresses[1] // 4) >> 8) & 0xFF
    #data[offset+3] = (new_addresses[1] // 4) & 0xFF

    # update both pointers if new_address is list
    if type(new_address) == list[int]:
        # print(f'[UpdPtr] (@ 0x{offset:08X}) Next 0x{new_address[0]:08X} | 0x{new_address[1]:08X} Data -- (0x{new_address[0] // 4:04X} | 0x{new_address[1] // 4:04X})')
        data[offset:   offset+2] = (new_address[0] // 4).to_bytes(2, byteorder='big')
        data[offset+2: offset+4] = (new_address[1] // 4).to_bytes(2, byteorder='big')
    else:
        # print(f'[UpdPtr] (@ 0x{offset:08X}) {ptr_type} 0x{new_address:08X} -- (0x{new_address // 4:04X})')
        # needs 2 byte shift to get "data" ptr, otherwise works as-is for "next" ptr
        if ptr_type == "data": offset += 2

        data[offset: offset+2] = (new_address // 4).to_bytes(2, byteorder='big')

    return 0

# CLI Support
if __name__ == "__main__":
    def auto_int(x):
        return int(x, 0)

    parser = argparse.ArgumentParser(
        description="Appends SSB64 files together, updating pointers in the process. (SSB64FileAppender port to Python)"
    )
    parser.add_argument(
        "file_path",
        type=str,
        help="Path of file that will be appended to the file at target_file_path."
    )
    parser.add_argument(
        "file_original_offset",
        type=auto_int,
        help="Original offset to where file contents began if trimmed. Leave at 0 if full file."
    )
    parser.add_argument(
        "file_table_offset",
        type=auto_int,
        help="Internal file table offset of the file getting appended with."
    )
    parser.add_argument(
        "target_file_path",
        type=str,
        nargs="?",
        help="Path of file that will be appended to with file at file_path."
    )
    parser.add_argument(
        "target_table_offset",
        type=auto_int,
        nargs="?",
        help="Internal file table offset of the file being appended to."
    )
    parser.add_argument(
        "-o", "--out",
        type=str,
        required=False,
        default="./output.bin",
        help="Output path of appended file, default is \"./output.bin\"."
    )
    args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

    append_file(
        args.file_path, args.file_original_offset, args.file_table_offset,
        args.target_file_path, args.target_table_offset,
        args.out
    )