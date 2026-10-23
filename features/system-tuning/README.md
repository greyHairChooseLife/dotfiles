# system-tuning

CPU 전력 정책을 다룬다. AC에서는 `performance`, 배터리에서는 `balance_performance`,
배터리 20% 이하에서는 `power`로 EPP를 바꾼다.

-   `change-cpu-performance [powersave]`: scaling_governor 즉시 전환 (sudo 사용)
-   `battery-epp-switch`: udev가 호출하는 EPP 전환 스크립트
-   `10-cpu-performance.conf`: TLP drop-in (`/etc/tlp.d/`)
-   `99-battery-epp.rules`: 배터리/AC 변화 시 위 스크립트 실행 (`/etc/udev/rules.d/`)

설치하면 udev 규칙을 reload하고 TLP를 시작한 뒤 EPP를 한 번 적용한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/change-cpu-performance` | governor 전환 명령 |
| `battery-epp-switch` | `/usr/local/bin/`에 설치되는 EPP 스크립트 |
| `10-cpu-performance.conf` | `/etc/tlp.d/`에 설치 |
| `99-battery-epp.rules` | `/etc/udev/rules.d/`에 설치 |
| `install.sh` | 링크 + sudo 설치 + udev reload |
| `uninstall.sh` | 역순 제거 |
