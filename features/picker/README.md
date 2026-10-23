# picker

fzf로 파일이나 검색 결과를 고른 뒤 tmux pane에 경로를 입력한다. pane이 `claude`/`pi`면
`@file:line` 형식으로, 아니면 `file:line`으로 보낸다.

-   `cc_file_picker <pane>`: 파일 선택 → `@path`
-   `find_file_tmux <pane>`: 파일 선택 → path (`find_file` 사용)
-   `rg_picker <pane>`: ripgrep+fzf → `@file:line` 또는 `file:line`

`tmux.conf`의 `C-f`(파일), `C-w`(검색) 바인딩이 호출한다. 의존: `features/base`(`find_file`).

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/cc_file_picker` | 파일 선택 + `@path` 입력 |
| `bin/find_file_tmux` | 파일 선택 + path 입력 |
| `bin/rg_picker` | 검색 + `file:line` 입력 |
| `libexec/rg_search` | 현재 query/hidden/glob 상태로 rg 실행 |
| `libexec/rg_preview` | 결과 미리보기 (bat) |
| `libexec/rg_reload` | fzf reload 액션 문자열 생성 |
| `install.sh` | `bin/*` → `~/.local/bin`, `libexec/*` → `~/.local/libexec/picker` |
| `uninstall.sh` | 역순 제거 |
