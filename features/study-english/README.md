# study-english

영어 학습 노트 자동 생성 아이디어를 보관하는 디렉토리. **아직 설치물이 없다.**

`cc-generate-study-note`는 참고용 구현이다. Claude Code 대화 기록(`~/english-study-notes.md`)을
OpenAI로 분석해 오류를 문법/어휘/표현으로 분류한 학습 노트를 만들고, rclone으로 Drive에
업로드한다. 지금은 실행하지 않고 참고만 한다.

나중에 실제로 쓰게 되면:

1.  스크립트를 `bin/`으로 옮긴다 (`bin/generate-study-note` 등)
2.  `install.sh` / `uninstall.sh`를 추가한다 (`features/keyboard/` 참고)
3.  `install.sh --status`가 `status_bin "$DIR"`을 호출하게 한다

## 구조

| 경로 | 역할 |
| --- | --- |
| `cc-generate-study-note` | 참고 구현. 설치되지 않는다 |
