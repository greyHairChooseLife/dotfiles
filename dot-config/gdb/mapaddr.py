import gdb
import sys

class MapAddr(gdb.Command):
    """Which mapped region contains an address?

Usage: mapaddr EXPR     e.g. mapaddr str, mapaddr &buf[4],
                        mapaddr 0x555555556004, mapaddr $rip
Prints all mappings and marks the one containing the address."""

    def __init__(self):
        super(MapAddr, self).__init__("mapaddr", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        addr = int(gdb.parse_and_eval(arg))
        tty = sys.stdout.isatty()
        found = False
        for line in gdb.execute("info proc mappings", to_string=True).splitlines():
            parts = line.split()
            if len(parts) < 5:
                print(line)
                continue
            try:
                start, end = int(parts[0], 16), int(parts[1], 16)
            except ValueError:
                print(line)
                continue
            if start <= addr < end:
                line += "   <<< contains 0x%x" % addr
                if tty:
                    line = "\x1b[31m" + line + "\x1b[0m"
                found = True
            print(line)
        if not found:
            print("(0x%x is not in any mapping)" % addr)

MapAddr()
