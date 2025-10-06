import re

import gdb


def disas_current_line(event):
    try:
        frame = gdb.selected_frame()
        sal = frame.find_sal()
        filename = sal.symtab.filename
        lineno = sal.line
        line_info = gdb.execute(f"info line {filename}:{lineno}", to_string=True)
        m = re.search(
            r"starts at address (0x[0-9a-fA-F]+).+ends at (0x[0-9a-fA-F]+)", line_info
        )
        if not m:
            print("Could not find address range for this line.")
            return
        start, end = m.group(1), m.group(2)
        # print(f"\n Disassembly for {filename}:{lineno} ({start} - {end}) ---")
        gdb.execute(f"disassemble {start}, {end}")
        # print("--- End disassembly ---")
    except Exception as e:
        print(f"Error in disas_current_line: {e}")


gdb.events.stop.connect(disas_current_line)
