define rr
    start
    if $_is_pie
        b *main
    else
        b main
    end
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


#   wa / cw are Python commands (watch_cmd.py) with optional -f <path>:
#   wa <expr>       watchpoint on expression
#   wa -f <path>    watchpoint per line of file
#   cw <expr>       contextwatch expression (live display)
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

alias cw_ex = contextwatch execute
alias cw_del = contextunwatch
alias hx = hexdump
alias hxs = sizedHexDump
alias rmt = target extended-remote localhost:1234

alias dis_cur_line = python disas_current_line(None)

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
