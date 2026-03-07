# Markdown Folding Plan

## 목표

nvim-ufo를 사용하면서 markdown 파일에서 다음 요소를 fold 가능하게 만들기:

1. **헤더** (`##` ~ `######`) - 각 헤더가 하위 내용을 fold
2. **Callout** (`> [!some-text]` 로 시작하는 블록) - 전체 callout 블록을 fold
3. **Bullet with bold header** (`**title**` 단독 줄 + 이후 bullet 리스트) - 제목 기준으로 리스트 묶어서 fold

### Foldtext 목표

- fold 기준 줄의 아래에 한 줄에 표현
- 줄 수, 하위 헤더 정보 표시
- 첫 줄은 render-markdown.nvim이 렌더한 상태 그대로 보임 (extmark, conceal 유지)

---

## 관련 파일

| 파일 | 역할 |
|------|------|
| `lua/UI/plugins/ufo.lua` | nvim-ufo 설정, provider_selector, fold_virt_text_handler |
| `lua/UI/folding_styles.lua` | `markdown_fold_expr`, `markdown_fold_text` 등 전역 함수 |
| `after/ftplugin/markdown.lua` | markdown FileType 설정, foldmethod/foldexpr 연결 |
| `lua/UI/filetype.lua` | FileType autocmd (winhighlight 등) |
| `~/Documents/zk/resource/study_20260304-000000.md` | 잘 동작하는지 테스트하는 문서 파일 |

---

## 시도한 방법들

### 시도 1: `provider_selector`에서 `""` 반환 + 수동 foldexpr

- **방법**: ufo의 `provider_selector`에서 markdown을 `""` 반환 → ufo가 skip
  - `after/ftplugin/markdown.lua`에서 `foldmethod=expr`, `foldexpr=v:lua.markdown_fold_expr(v:lnum)` 설정
  - `folding_styles.lua`에 `_G.markdown_fold_expr` 함수 정의
- **결과**: fold는 동작하지만 ufo의 `fold_virt_text_handler`가 비활성화됨
  - foldtext는 `v:lua.markdown_fold_text(...)` 로 커스텀 문자 바 방식
  - render-markdown extmark가 fold 첫 줄에 유지되지 않음
- **문제**: ufo가 `""` 반환 시 attach하지 않아서 virttext handler 동작 안 함

### 시도 2: `provider_selector`에서 `{ "foldexpr" }` 반환

- **방법**: ufo provider로 `"foldexpr"` 문자열 지정
- **결과**: 즉시 에러
  ```
  Can't find a module in `ufo.provider.foldexpr`
  ```
- **원인**: ufo가 지원하는 내장 provider는 `lsp`, `treesitter`, `indent`, `marker` 뿐

### 시도 3: `provider_selector`에서 함수 직접 반환 (✅ 완료)

- **방법**: `provider_selector`에서 함수를 직접 반환 → ufo가 함수를 custom provider로 인식
  - 함수 내부에서 `markdown_fold_expr` 로직과 동일한 계산으로 `foldingrange` 배열 반환
  - ufo fold ranges를 직접 제공하므로 `fold_virt_text_handler` 활성화
  - `after/ftplugin/markdown.lua`에서 `foldmethod=expr`, `foldexpr` 제거
- **결과**: 정상 동작 확인
- **핵심 버그 2개 수정**:
  1. stack pop 조건 `>=` → `>` 로 변경 (같은 레벨에서 즉시 pop되던 문제)
  2. push 조건 추가: 같은 레벨 헤더가 새로 시작될 때도 push (`fl == get_fl(i-1)` 케이스)
- **부수 수정**: `opt.modeline = false` 추가 (markdown 테이블 `|---|` 이 vimscript로 해석되던 문제)

---

## 핵심 제약 조건

- **ufo 내장 provider**: `lsp`, `treesitter`, `indent`, `marker` 만 존재
- **`""` 반환 시**: ufo skip → `fold_virt_text_handler` 비활성
- **함수 provider**: ufo manager.lua 113번 줄 확인 결과 `type == 'function'` 지원됨
  - 함수는 `bufnr`을 받아 `foldingrange` 객체 배열 반환해야 함
  - `foldingrange.new(startLine, endLine)` - 0-indexed
- **foldtext vs virttext**: ufo 활성 시 `fold_virt_text_handler`가 우선, `foldtext` option은 무시됨

---

## 결론

시도 3 (함수 provider) 방식으로 완료. 추가 옵션 탐색 불필요.

---

## 검증 방법

테스트 노트: `/home/sy/Documents/zk/project/krafton-jungle/index_20260305-081255.md`

예상 fold 구조:
```
## Overview                          ← level 1 fold
  > [!NOTE] ...                      ← level 2 fold (callout)
  > **TOC** ...                      ← level 2 (callout 아님, plain blockquote)

## Category of Notes                 ← level 1 fold
  ### hard skills                    ← level 2 fold
    #### Algorithm                   ← level 3 fold
      > [!NOTE] ...                  ← level 4 fold (callout)
    #### Data Structure              ← level 3 fold
    #### Computer Science(CS)        ← level 3 fold
    ...
```
