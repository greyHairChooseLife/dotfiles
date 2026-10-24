import gdb

# cw / cws: 기본 저장 파일 이름
DEFAULT_SAVE_PATH = "cw.watch"

WATCH_HELP = """wa <expr>         : watchpoint on expression (stops on change)
wa -f <path>      : watchpoint per line of <path>
cw <expr>         : show expression live in pwndbg context (no stopping)
cw -e <cmd>       : run <cmd> as a gdb command, shown live (quotes optional)
cw -f <path>      : contextwatch per line of <path>
cw -d <num>...    : remove contextwatch entries by number (1-based)
cws [path]        : save current contextwatch entries (default: cw.watch)
remove with: cw -d / cunwatch / contextunwatch"""

WATCH_FILE_SAMPLE = """# cw -f / wa -f file: one contextwatch argument per line.
# Each line runs as: contextwatch <line>
# Blank lines and lines starting with '#' are skipped.
# cws writes this same format.

# --- eval: show a value inline ---
# eval lines with spaces must be quoted, otherwise argparse reads the first
# token as the eval/execute mode.
counter
items[0]
"*(int *)$rsp"

# --- execute: run a gdb command, output shown below the header ---
execute "info args"
execute "bt 5"
execute "x/8xg $rsp"

# --- pipe: post-process a gdb command through a shell command ---
execute "pipe disassemble | head -20"
execute "pipe info registers | grep rax"
"""


def _apply(cmd, line):
    line = line.strip()
    if not line or line.startswith("#"):
        return
    try:
        gdb.execute(f"{cmd} {line}")
    except gdb.error as e:
        print(f"{cmd} {line}: {e}")


def _run_file(cmd, path):
    try:
        with open(path) as f:
            for line in f:
                _apply(cmd, line)
    except FileNotFoundError:
        if cmd != "contextwatch":
            print(f"{cmd}: -f: {path}: no such file")
            return
        with open(path, "w") as f:
            f.write(WATCH_FILE_SAMPLE)
        print(f"{cmd}: -f: no such file, wrote sample to {path}")
    except OSError as e:
        print(f"{cmd}: {e}")


def _run(cmd, arg):
    arg = arg.strip()
    if not arg:
        print(WATCH_HELP)
        return

    mode, _, rest = arg.partition(" ")
    rest = rest.strip()

    if mode == "-f":
        if not rest:
            print(f"{cmd}: -f requires a file path")
            return
        _run_file(cmd, rest)
        return

    if mode == "-e":
        if not rest:
            print(f"{cmd}: -e requires a gdb command")
            return
        if not (rest.startswith('"') and rest.endswith('"')):
            rest = f'"{rest}"'
        _apply(cmd, f"execute {rest}")
        return

    try:
        gdb.execute(f"{cmd} {arg}")
    except gdb.error as e:
        print(f"{cmd} {arg}: {e}")


def _quote(s):
    """contextwatch 인자로 되돌릴 수 있게 인용한다 (gdb.string_to_argv 규칙)."""
    if not s:
        return '""'
    if not any(c in s for c in " \t\n'\"\\"):
        return s
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _delete(rest):
    tokens = rest.split()
    if not tokens:
        print("cw: -d requires one or more numbers")
        return
    nums = []
    for token in tokens:
        try:
            nums.append(int(token))
        except ValueError:
            print(f"cw: -d: not a number: {token}")
            return
    # 번호가 밀리지 않도록 큰 번호부터 지운다.
    for num in sorted(set(nums), reverse=True):
        try:
            gdb.execute(f"contextunwatch {num}")
        except gdb.error as e:
            print(f"cw: -d {num}: {e}")


def _save(path):
    try:
        import pwndbg.commands.context as context
    except Exception as e:
        print(f"cws: pwndbg not loaded ({e})")
        return

    if not context.expressions:
        print("cws: no contextwatch entries to save")
        return

    lines = []
    for expression, cmd in context.expressions:
        if cmd == "eval":
            lines.append(_quote(expression))
        else:
            lines.append(f"execute {_quote(expression)}")

    try:
        with open(path, "w") as f:
            f.write("# cws: saved contextwatch entries. load with: cw -f <this file>\n")
            f.write("# one contextwatch argument per line\n")
            for line in lines:
                f.write(line + "\n")
    except OSError as e:
        print(f"cws: {path}: {e}")
        return

    print(f"cws: wrote {len(lines)} entries to {path}")


class WaCommand(gdb.Command):
    """wa <expr> | wa -f <path>

    watchpoint on expression, or one per line of file (-f)."""

    def __init__(self):
        super().__init__("wa", gdb.COMMAND_BREAKPOINTS, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, tty):
        _run("watch", arg)


class CwCommand(gdb.Command):
    """cw <expr> | cw -e <cmd> | cw -f <path> | cw -d <num>...

    contextwatch: show expression live in pwndbg context, no stopping.
    -e runs a gdb command (quotes optional), -f loads one per line,
    -d removes entries by number (1-based, as shown in the context)."""

    def __init__(self):
        super().__init__("cw", gdb.COMMAND_SUPPORT, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, tty):
        mode, _, rest = arg.strip().partition(" ")
        if mode == "-d":
            _delete(rest)
            return
        _run("contextwatch", arg)


class CwsCommand(gdb.Command):
    """cws [path]

    Save the current contextwatch entries (the context 'expressions'
    section) to a file that `cw -f <path>` can load again.
    Default path: cw.watch."""

    def __init__(self):
        super().__init__("cws", gdb.COMMAND_SUPPORT, gdb.COMPLETE_FILENAME)

    def invoke(self, arg, tty):
        _save(arg.strip() or DEFAULT_SAVE_PATH)


WaCommand()
CwCommand()
CwsCommand()
