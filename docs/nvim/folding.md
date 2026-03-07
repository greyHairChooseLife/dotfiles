# Neovim Folding

## 관련 파일

| 파일 | 역할 |
|------|------|
| `lua/UI/folding.lua` | fold 로직 전체 (markdown provider, virt text handler, codecompanion fold expr/text) |
| `lua/UI/plugins/ufo.lua` | nvim-ufo 설정, 키맵, autocmd. fold 로직은 `folding.lua`에 위임 |
| `after/ftplugin/markdown.lua` | markdown FileType 설정 (`foldenable` 등) |
| `lua/UI/filetype.lua` | FileType autocmd. codecompanion에서 `v:lua.codecompanion_fold_*` 참조 |
| `lua/qol/option.lua` | 전역 fold 옵션 (`foldlevel`, `foldlevelstart`, `modeline = false` 등) |

---

## 구조

### `lua/UI/folding.lua`

```
M.markdown_provider(bufnr)       -- ufo custom provider: fold ranges 계산
M.markdown_virt_text(...)        -- ufo fold_virt_text_handler: markdown foldtext
M.default_virt_text(...)         -- ufo fold_virt_text_handler: 기본 foldtext
_G.codecompanion_fold_text(...)  -- codecompanion foldtext (v:lua.* 방식)
_G.codecompanion_fold_expr(...)  -- codecompanion foldexpr (v:lua.* 방식)
```

### `lua/UI/plugins/ufo.lua`

```
provider_selector  →  markdown: require("UI.folding").markdown_provider
                       others:   { "treesitter", "indent" }
fold_virt_text_handler  →  markdown: folding.markdown_virt_text
                            others:   folding.default_virt_text
```

---

## Markdown Fold 규칙

### Fold 대상

1. **헤더** (`##` ~ `######`) — 각 헤더가 하위 내용을 fold
2. **Callout** (`> [!...]` 로 시작하는 블록) — 전체 callout 블록을 fold
3. **Bullet with bold header** (`**title**` 단독 줄 + 이후 bullet) — 리스트 묶어서 fold

### Provider 방식

- ufo `provider_selector`에서 함수를 직접 반환 → ufo가 custom provider로 인식
- 함수는 `bufnr`을 받아 `foldingrange.new(startLine, endLine)` 배열 반환 (0-indexed)
- 이 방식으로 `fold_virt_text_handler`가 활성화됨

### 핵심 제약

- ufo 내장 provider: `lsp`, `treesitter`, `indent`, `marker` 만 존재 (`"foldexpr"` 없음)
- `provider_selector`에서 `""` 반환 시 ufo skip → `fold_virt_text_handler` 비활성
- ufo 활성 시 `foldtext` option은 무시되고 `fold_virt_text_handler`가 우선

### Stack 알고리즘 핵심

- pop 조건: `stack[#stack].level > fl` (`>=` 이면 같은 레벨에서 즉시 닫힘)
- push 조건: `fl > get_fl(i-1)` OR `fl == get_fl(i-1)` 이면서 stack top이 같은 레벨이 아닐 때
  (같은 레벨 헤더 전환 시 새 fold 시작)

---

## Markdown Foldtext 스타일

첫 줄 텍스트(render-markdown extmark 포함) + `░` 채움 + 줄 수:

```
󰼐  컨텍스트 공유 방식  
░░░░░░░░░░░░░░░░░░░░░░ 28 lines (+1)
```

---

## 기타 수정 사항

- `opt.modeline = false` (`lua/qol/option.lua`) — markdown 테이블 구분자 `|---|` 이 vimscript로 해석되던 문제 수정
