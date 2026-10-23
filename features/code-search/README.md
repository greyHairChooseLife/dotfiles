# code-search

검색 결과를 fzf로 고르고 nvim으로 연다. `rg_fzf_search`는 ripgrep, `sg_fzf_search`는 ast-grep을 쓴다.

-   `rg_fzf_search <pattern> [rg flags] [paths...]`
-   `sg_fzf_search -p '<pattern>' -l <lang> [paths...]`

의존: `rg`, `ast-grep`, `jq`, `fzf`, `bat`, `nvim`. zsh alias `rgs`, `sgs`가 호출한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/rg_fzf_search` | ripgrep 결과 → fzf → nvim |
| `bin/sg_fzf_search` | ast-grep 결과 → fzf → nvim |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
