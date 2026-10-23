# misc

단독으로 쓰는 작은 도구. 설정·상태·의존이 없어 feature로 나누기에는 작은 것들을 모은다.

-   `txt2pdf [TEXT] [-o output.pdf]`: 텍스트를 PostScript로 직접 생성해 PDF로 변환

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/txt2pdf` | 텍스트 → PDF |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
