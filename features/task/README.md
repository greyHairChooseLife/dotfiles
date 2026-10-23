# task

taskwarrior 보조 도구.

-   `task-timespent <id>`: `task <id> info`의 수정 로그를 세션 단위로 재구성해 markdown 표로 출력
-   `cheatsheet.md`: 속성/명칭/효과 참고표

`bin/task-timespent`는 `TASKRC`를 상속하므로 shell에서 실행한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/task-timespent` | 세션별 소요 시간 표 |
| `cheatsheet.md` | 속성 참고표 |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
