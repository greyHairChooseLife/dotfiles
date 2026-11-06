# study-english

영어 학습용 도구.

-   `dictionary <word>`: 네이버 사전 조회 (한/영 자동 판별). python3 표준 라이브러리만 사용하고 네트워크가 필요하다.
    조회할 때마다 `~/.local/state/english/lookups.jsonl`에 `{"ts", "query"}` 한 줄을 남긴다.
    5자 미만 단어는 학습 노트에 쓸모가 없으므로 기록하지 않는다. 기록 실패는 조회를 막지 않는다
-   `dict-popup [word]`: 한 창에서 단어를 계속 조회한다. 결과를 본 뒤 다시 입력할 수 있다.
    닫는 방법은 `Ctrl-c` 하나뿐이고, 페이저에서 `q`나 `Esc`를 누르면 입력 프롬프트로 돌아온다.
    `tmux.conf`의 번역 popup 바인딩이 호출한다
-   `cc-generate-study-note`: **참고용** 구현. 설치하지 않는다. Claude Code 대화 기록을 OpenAI로 분석해
    학습 노트를 만들고 rclone으로 Drive에 업로드하는 방식의 예시다

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/dictionary` | 사전 조회 명령 (`~/.local/bin/dictionary`) |
| `bin/dict-popup` | 반복 조회 popup (`~/.local/bin/dict-popup`) |
| `bin/dictionary`의 로그 | `~/.local/state/english/lookups.jsonl` |
| `cc-generate-study-note` | 참고 구현 (설치 안 함) |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |

참고 구현을 실제로 쓰게 되면 `bin/`으로 옮기고 `install.sh`가 자동으로 링크하게 된다.
