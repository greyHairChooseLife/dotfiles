# study-english

영어 학습용 도구.

-   `dictionary <word>`: 네이버 사전 조회 (한/영 자동 판별). python3 표준 라이브러리만 사용하고 네트워크가 필요하다.
    조회할 때마다 `~/.local/state/english/lookups.jsonl`에 `{"ts", "query"}` 한 줄을 남긴다.
    5자 미만 단어는 학습 노트에 쓸모가 없으므로 기록하지 않는다. 기록 실패는 조회를 막지 않는다
-   `dict-popup [word]`: 한 창에서 단어를 계속 조회한다. 결과를 본 뒤 다시 입력할 수 있다.
    닫는 방법은 `Ctrl-c` 하나뿐이고, 페이저에서 `q`나 `Esc`를 누르면 입력 프롬프트로 돌아온다.
    `tmux.conf`의 번역 popup 바인딩이 호출한다
-   `english-brief [--days N] [--no-upload]`: 조회 기록과 pi 세션 리뷰를 모아 **말로 하는 튜터 세션용 브리프**를
    만든다. 화면으로 읽는 문서가 아니라, 산책(5-10분) 중 AI 튜터가 즉흥적으로 진행할 대본이다.
    `~/Documents/english_study_note/YYYY-MM-DD-tutor-brief.md`에 쓰고 `gdrive:english-study-notes`로 올린다.
    조회 기록은 단어별로 합치고, 개수 상한은 두지 않는다. 하루 한 파일이 원칙이라 오늘 파일이 이미 있으면
    아무것도 하지 않고, 다시 만들려면 `--force`를 준다. crontab이 12:00-22:00 두 시간 간격으로 실행한다.
    그날 파일이 없으면 12:00에 처음 만들어지므로, 오전 산책은 전날 파일을 쓰거나 파일이 없다

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/dictionary` | 사전 조회 명령 (`~/.local/bin/dictionary`) |
| `bin/dict-popup` | 반복 조회 popup (`~/.local/bin/dict-popup`) |
| `bin/dictionary`의 로그 | `~/.local/state/english/lookups.jsonl` |
| `bin/english-brief` | 튜터 브리프 생성 (`~/.local/bin/english-brief`) |
| 리뷰 입력 | `~/.local/state/english/reviews/*.jsonl` |
| `research/english-study-evidence.md` | 브리프 설계 근거 정리 (논문 초록 인용) |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
