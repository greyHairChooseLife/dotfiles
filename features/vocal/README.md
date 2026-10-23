# vocal

음성을 녹음해 텍스트로 옮긴다. `vocal`로 녹음을 시작하고, 다시 실행하면 녹음을 마치고 전사한다.
`vocal cancel`은 진행 중인 녹음/전사를 취소한다.

-   `bin/vocal`: 진입점 (zsh). 녹음은 `rec`(sox), 전사는 `libexec/python/`의 스크립트가 한다
-   `libexec/python/transcribe.py`: 로컬 whisper 모델로 전사 (`MODE="local"`, 모델 경로 `~/whisper`)
-   `libexec/python/openai_uploader.py`: OpenAI API로 전사 (`MODE="api"`, `OPENAI_API_KEY` 필요)

i3에서 `$mod+i`(시작/완료), `$mod+Shift+i`(취소)로 호출한다.

## 의존

`sox`(`rec`), `python3`, `notify-send`, `dunstctl`, `xclip`, 그리고 모드에 따라 `openai` 패키지 또는
로컬 `whisper` 모델.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/vocal` | 녹음/전사/취소 진입점 |
| `libexec/python/transcribe.py` | 로컬 whisper 전사 |
| `libexec/python/openai_uploader.py` | API 전사 |
| `install.sh` | `bin/*` → `~/.local/bin`, `libexec/*` → `~/.local/libexec/vocal` |
| `uninstall.sh` | 링크 제거 |
