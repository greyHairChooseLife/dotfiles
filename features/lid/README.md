# lid

덮개를 닫아 suspend 될 때 taskwarrior 활성 태스크를 멈추고, 그 결과를 `$CURRENT_TASKS`에 남긴다.
resume 후에는 화면이 준비되면 그 파일을 floating 창으로 띄운다.

-   보고서 대상 파일: `CURRENT_TASKS` (`dot-config/zsh.sub/etc_env.sh`)
-   창 크기/배치: `dot-config/i3/config`의 `for_window [class="lid-tasks"]`

## 구조

| 경로 | 역할 |
| --- | --- |
| `lid-hook` | payload. `pre`는 태스크 중지 + 보고서 prepend, `post`는 창 실행 |
| `50-lid` | systemd sleep hook 템플릿. `@@USER@@` / `@@HOME@@`는 설치 시 치환된다 |
| `install.sh` | `~/.local/bin/lid-hook` 링크 생성, `/usr/lib/systemd/system-sleep/50-lid` 설치 |
| `uninstall.sh` | 두 산출물 제거 |

## 설치

```bash
cd ~/dotfiles && ./features/lid/install.sh
```

sudo는 systemd hook 설치에만 사용된다. 끄려면 `./features/lid/uninstall.sh`.
