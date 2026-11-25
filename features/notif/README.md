# notif

rofi로 dunst 알림 히스토리를 목록으로 보고, body를 클립보드로 복사한다. i3에서는
`$mod+Shift+m`이 `rofi-notif`를 실행한다. rofi의 script mode(`-modi`)로 동작하므로
목록 생성과 키 처리를 같은 스크립트가 맡는다.

-   `rofi-notif`: 알림 목록을 띄운다. 직접 실행해도 되고 `rofi -show notif -modi "notif:rofi-notif"`로도 된다.
-   Enter: 선택한 알림의 body를 클립보드(`xclip`)로 복사
-   Alt+1: 선택한 알림을 dunst 팝업으로 다시 띄운다 (긴 문장은 여기서 읽는다)
-   Alt+2: 선택한 알림을 히스토리에서 지우고 목록을 갱신

dunst는 닫힌 알림만 히스토리에 넣으므로, 목록을 열 때 `dunstctl close-all`을 먼저 실행한다.
즉 목록을 여는 순간 화면에 떠 있던 팝업은 사라지고 목록으로 들어온다. 목록이 비어 있으면
`No notifications` 한 줄만 보여준다. 의존: `dunst`, `rofi`, `xclip`.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/rofi-notif` | rofi script mode 진입점 (목록 생성, 키 처리) |
| `install.sh` | `bin/*` → `~/.local/bin` |
| `uninstall.sh` | 링크 제거 |

## rofi row 형식

행 하나는 `id\x1fapp\x1fsummary\x1fbody`를 원문으로 두고 rofi의 row option으로 표시만 바꾼다.
`\0display`로 보기 좋은 한 줄을, `\0icon`/`\0urgent`로 아이콘과 긴급 표시를 붙인다.
원문에 body 전체가 들어 있어서 선택 시에도 body 전체를 복사한다.
