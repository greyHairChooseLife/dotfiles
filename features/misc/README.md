# misc

단독으로 쓰는 작은 도구와 외부 서비스로 내보내는 명령을 모은다.

-   `txt2pdf [TEXT] [-o output.pdf]`: 텍스트를 PostScript로 직접 생성해 PDF로 변환
-   `share-file-using-QR-code`: 파일을 골라 tmpfiles.org에 업로드하고 QR을 출력
-   `share-docker-image-temporarily [시간]`: docker 이미지를 ttl.sh에 임시 업로드

공유 명령은 파일을 외부 서비스로 전송한다. 필요 없으면 `uninstall.sh`로 끄면 된다.
의존: `features/base`(`find_file`, `show_spinner`).

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/txt2pdf` | 텍스트 → PDF |
| `bin/share-file-using-QR-code` | 파일 → URL + QR |
| `bin/share-docker-image-temporarily` | 이미지 → ttl.sh |
| `install.sh` | `bin/*` → `~/.local/bin` |
| `uninstall.sh` | 링크 제거 |
