# vocal

음성을 녹음해 텍스트로 옮긴다. `vocal`로 녹음을 시작하고, 다시 실행하면 녹음을 마치고 전사한다.
`vocal cancel`은 진행 중인 녹음/전사를 취소한다.

-   `bin/vocal`: 진입점 (zsh). 녹음은 `parecord`(PulseAudio), 전사는 `libexec/python/`의 스크립트가 한다
-   `libexec/python/transcribe.py`: 로컬 whisper 모델로 전사 (`MODE="local"`, 모델 경로 `~/whisper`)
-   `libexec/python/openai_uploader.py`: OpenAI API로 전사 (`MODE="api"`, `OPENAI_API_KEY` 필요)

i3에서 `$mod+i`(시작/완료), `$mod+Shift+i`(취소)로 호출한다.

## 상태

상태는 `$XDG_RUNTIME_DIR/vocal`에 파일로 남는다. 프로세스 이름으로 상태를 추측하지 않는다.

| 파일 | 내용 |
| --- | --- |
| `lock` | `flock` 잠금. 시작/종료 전환을 한 번에 하나만 한다 |
| `pid`, `wav` | 녹음 중인 `parecord`의 PID와 wav 경로 |
| `transcribing` | 전사 중인 wav 경로 |
| `notify` | 덮어쓸 dunst 알림 ID |
| `cancel` | `vocal cancel` 표시. 전사 인스턴스가 오류 알림을 내지 않게 한다 |
| `recorder.log`, `last.log` | 녹음기/전사기 stderr. 실패 알림에 마지막 줄이 나온다 |

세션마다 wav 이름이 다르므로, 전사 중에 새 녹음을 시작해도 이전 작업이 새 파일을 지우지 않는다.

## 의존

`parecord`(PulseAudio 또는 pipewire-pulse), `flock`(util-linux), `python3`, `notify-send`(dunst), `xclip`,
그리고 모드에 따라 `openai` 패키지 또는 로컬 `whisper` 모델.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/vocal` | 녹음/전사/취소 진입점 |
| `libexec/python/transcribe.py` | 로컬 whisper 전사 |
| `libexec/python/openai_uploader.py` | API 전사 |
| `install.sh` | `bin/*` → `~/.local/bin`, `libexec/*` → `~/.local/libexec/vocal` |
| `uninstall.sh` | 링크 제거 |
