define rr
    start
    if $_is_pie
        b *main
    else
        b main
    end
end

# pwndbg의 up/down은 선택한 프레임의 backtrace만 stdout에 다시 출력한다. context 전체는
# stop 이후 prompt에서 한 번만 그려지므로(pwndbg/gdblib/prompt.py), 프레임을 옮겨도 regs/disasm/
# stack pane은 stop 시점 내용으로 남는다. 아래 wrapper는 pwndbg 함수를 그대로 호출한 뒤 context를
# 다시 그려서 모든 pane을 갱신한다. pwndbg가 없으면 아무것도 등록하지 않고 GDB 기본 up/down을 둔다.
python
import contextlib
import io

import gdb

try:
    import pwndbg.commands.context as _pwndbg_context
    import pwndbg.commands.updown as _pwndbg_updown

    class _FrameAndContext(gdb.Command):
        def __init__(self, name, fn, description):
            # gdb.Command.__init__이 명령을 등록하면서 __doc__을 읽으므로 먼저 설정한다.
            self.__doc__ = description
            gdb.Command.__init__(self, name, gdb.COMMAND_STACK)
            self._name = name
            self._fn = fn

        def invoke(self, arg, from_tty):
            try:
                gdb.selected_frame()
            except gdb.error:
                print("No stack.")
                return
            arg = arg.strip()
            try:
                n = int(arg) if arg else 1
            except ValueError:
                print("%s: expected a number, got %r" % (self._name, arg))
                return
            # pwndbg 함수는 backtrace를 stdout에 직접 출력한다. context가 pane에 같이
            # 그리므로, 중복 출력을 막기 위해 stdout만 잠시 버린다.
            with contextlib.redirect_stdout(io.StringIO()):
                self._fn(n)
            _pwndbg_context.context()

    for _name, _fn, _desc in (
        ("up", _pwndbg_updown.up, "Select and print stack frame that called this one."),
        ("do", _pwndbg_updown.down, "Select and print stack frame called by this one."),
        ("down", _pwndbg_updown.down, "Select and print stack frame called by this one."),
        ("dow", _pwndbg_updown.down, "Select and print stack frame called by this one."),
    ):
        _FrameAndContext(_name, _fn, _desc)
except Exception as _exc:
    print("gdb: up/down context wrapper disabled (%s)" % _exc)
end

define retprint
    finish
    print $_
end
document retprint
    현재 함수 실행을 마치고 리턴값을 출력합니다.
end

# (gdb) watch myvar
# - `myvar`가 변경될 때마다 GDB가 자동으로 멈춥니다.


#   wa / cw are Python commands (watch_cmd.py):
#   wa <expr>       watchpoint on expression
#   wa -f <path>    watchpoint per line of file
#   cw <expr>       contextwatch expression (live display)
#   cw -e <cmd>     run <cmd> as a gdb command, live (quotes optional)
#   cw -f <path>    contextwatch per line of file

define sizedHexDump
    if $argc == 1
        hexdump &$arg0 sizeof($arg0)
    else
        hexdump &$arg0 $arg1
    end
end
document sizedHexDump
    sizedHexDump <variable> [size] : Dump [size] bytes of the memory of the specified variable using hexdump (address and sizeof).
end

alias cw_del = contextunwatch
alias hx = hexdump
alias hxs = sizedHexDump
alias rmt = target extended-remote localhost:1234

# record 실행 시점부터 되감기가 가능하다.
# tmux로 단축키 만들어둠

define tmp_remote_target
	  directory .
    target extended-remote localhost:1234
    record
    b RecursiveReverse
    cw_file cw
end

alias ttt = tmp_remote_target


# ### 1. pwndbg의 `vmmap` 명령

# pwndbg에서는 아래 명령으로 메모리 맵을 볼 수 있습니다.

# ```
# (gdb) vmmap
# ```
# - Stack, Heap, libc, code 등 각 영역의 시작/끝 주소와 권한이 표시됩니다.

# 특정 주소가 어디에 속하는지 확인하려면:

# ```
# (gdb) vmmap 0x주소
# ```
# - 해당 주소가 포함된 영역의 정보를 보여줍니다.

# ---

# ### 2. GDB의 `info proc mappings`

# ```
# (gdb) info proc mappings
# ```

# ```
# x/32xb 0x주소
# ```
# 이렇게 입력하면 **해당 주소의 1바이트 값을 16진수(hex)로 출력**합니다.

# - `x` : examine(메모리 보기)
# - `/x` : 16진수로 출력
# - `b` : 바이트 단위(byte)
# - `0x주소` : 확인하고 싶은 메모리 주소
