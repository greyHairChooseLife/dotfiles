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
-   `cc-generate-study-note`: **참고용** 구현. 설치하지 않는다. Claude Code 대화 기록을 OpenAI로 분석해
    학습 노트를 만들고 rclone으로 Drive에 업로드하는 방식의 예시다

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/dictionary` | 사전 조회 명령 (`~/.local/bin/dictionary`) |
| `bin/dict-popup` | 반복 조회 popup (`~/.local/bin/dict-popup`) |
| `bin/dictionary`의 로그 | `~/.local/state/english/lookups.jsonl` |
| `bin/english-brief` | 튜터 브리프 생성 (`~/.local/bin/english-brief`) |
| 리뷰 입력 | `~/.local/state/english/reviews/*.jsonl` |
| `research/english-study-evidence.md` | 브리프 설계 근거 정리 (논문 초록 인용) |
| `cc-generate-study-note` | 참고 구현 (설치 안 함) |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |

참고 구현을 실제로 쓰게 되면 `bin/`으로 옮기고 `install.sh`가 자동으로 링크하게 된다.

## 근거 자료

브리프의 규칙은 아래 자료에서 나왔다. 직접 확인할 때는 `research/english-study-evidence.md`를 보거나 원문을 연다.

-   Lyster & Saito (2010), *Oral Feedback in Classroom SLA*, SSLA 32(2) — prompts > recasts,
    free constructed speech에서 효과가 가장 크다.
    <https://www.cambridge.org/core/journals/studies-in-second-language-acquisition/article/abs/oral-feedback-in-classroom-sla/4999EE1C8379B2BF026B148EAF373CA1>
-   Li (2010), *The Effectiveness of Corrective Feedback in SLA: A Meta-Analysis*, Language Learning 60(2).
    <https://onlinelibrary.wiley.com/doi/full/10.1111/j.1467-9922.2010.00561.x>
-   Nation (2007), *The Four Strands* — 의미 중심 입력/출력, 언어 초점 학습, 유창성 개발의 균형.
    <https://www.wgtn.ac.nz/lals/resources/paul-nations-resources/paul-nations-publications/publications/documents/2007-Four-strands.pdf>
-   Kim & Webb (2022), *The Effects of Spaced Practice on Second Language Learning: A Meta-Analysis*, Language Learning 72(2).
    <https://onlinelibrary.wiley.com/doi/10.1111/lang.12479>
-   Nakata (2015), *Effects of expanding and equal spacing on L2 vocabulary learning*, SSLA — expanding이 항상
    더 좋지는 않다.
    <https://www.cambridge.org/core/journals/studies-in-second-language-acquisition/article/abs/effects-of-expanding-and-equal-spacing-on-second-language-vocabulary-learning/D1D796306985C52F9BE7A1200AC50DB9>
-   Nation (1989), *Improving speaking fluency* — 4/3/2 기법.
    <https://www.wgtn.ac.nz/lals/resources/paul-nations-resources/paul-nations-publications/publications/documents/1989-Fluency.pdf>
-   Thai & Boers (2016), *Repeating a Monologue under Increasing Time Pressure*, TESOL Quarterly — 유창성은
    오르지만 정확성은 그렇지 않다.
    <https://eric.ed.gov/?id=EJ1101159>
