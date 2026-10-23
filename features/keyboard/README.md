# keyboard

내장 키보드와 블루투스 키보드를 전환한다. `xinput`과 `setxkbmap`을 직접 호출하며,
지원 호스트에서만 동작한다.

-   `btkb on`: 블루투스 키보드 사용. 내장 키보드 비활성, ctrl/caps 스왑 해제
-   `btkb off`: 내장 키보드 사용. 내장 활성, ctrl/caps 스왑 적용
-   `btkb toggle`: 내장 키보드 상태를 보고 전환, dunst로 결과 알림

호출부는 `dot-config`가 소유한다. 로그인 시 `.xinitrc`가 `btkb off`, 잠금 시
`dot-config/i3/script/lock.sh`가 화면 잠금 전후로 `off` / `on`을 호출한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/btkb` | 실행 명령 (`on` / `off` / `toggle`) |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |

## 지원 호스트

`sy-Lenovo-ideapad`, `cbpm-laptop`, `sy-x390`. 그 외 호스트에서는 에러를 출력하고 종료한다.
