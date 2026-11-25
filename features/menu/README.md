# menu

rofi 모드 메뉴. 키바인드 하나(`$mod+n`)로 열고, row를 고르면 **같은 rofi 인스턴스가**
`\0switch-mode`로 해당 모드로 바뀐다. rofi를 새로 띄우지 않으므로 깜빡임이 없다.

-   `windows`: rofi window 모드
-   `notifications`: `rofi-notif` (dunst 히스토리)
-   매칭되는 row가 없는 문자열을 입력하고 Enter: Google 검색 (`xdg-open`)

`rofi-notif`는 `ROFI_MENU=1`을 물려받았을 때만 마지막 row에 `← back`을 붙인다. 그래서
`$mod+Shift+m`으로 바로 열 때는 back row가 없다. builtin `window` 모드에는 row를 넣을 수
없으므로 거기서는 `Shift+Left`(`kb-mode-previous`)로 돌아온다.

`$mod+n`이 이 메뉴, `$mod+Shift+n`은 drun, `$mod+Shift+m`은 알림 목록이다. `$mod+z`의
`morc_menu`는 이 메뉴로 대체했다. 의존: `features/notif`, `rofi`, `xdg-open`.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/rofi-menu` | 키바인드 실행 시 rofi를 띄우고, rofi가 부르면 script mode로 동작 |
| `install.sh` | `features/notif` 확인 + `bin/*` → `~/.local/bin` |
| `uninstall.sh` | 링크 제거 |
