# base

다른 feature가 공통으로 쓰는 기반 기능. feature 안에 가두면 그 feature를 끌 때 다른 곳이 함께
깨지므로, 전역 경로에 둔다.

-   `bin/find_file`: fzf로 파일을 고르는 공용 선택기. PATH에 있어 어떤 스크립트든 `find_file`로 호출한다
-   `libexec/base/show_spinner`: 진행 표시 helper. `~/.local/libexec/base/show_spinner`

## 전역 helper 경로 규약

| 경로 | 용도 |
| --- | --- |
| `~/.local/bin/` | 사람이 치거나 바인딩이 부르는 명령 (PATH) |
| `~/.local/libexec/base/` | feature 간 공용 helper (PATH 아님) |
| `~/.local/libexec/<feature>/` | 그 feature 전용 helper |

호출부는 `libexec="${DOTFILES_LIBEXEC:-$HOME/.local/libexec}"`로 기준을 잡고
`"$libexec/base/show_spinner"`처럼 절대경로로 부른다. `DOTFILES_LIBEXEC`은
`dot-config/zsh.sub/etc_env.sh`에서 정의한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/find_file` | 파일 선택기 |
| `libexec/show_spinner` | 진행 표시 |
| `install.sh` | `bin/*` → `~/.local/bin`, `libexec/*` → `~/.local/libexec/base` |
| `uninstall.sh` | 역순 제거 |
