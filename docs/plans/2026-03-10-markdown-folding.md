# Markdown Folding Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** markdown 파일에 커스텀 foldexpr/foldtext를 적용해 헤더/코드블록/리스트/callout 4가지 타입의 접기 규칙과 스타일을 구현한다.

**Architecture:** `lua/note_taking/markdown_fold.lua`에 `MarkdownFoldExpr()`와 `MarkdownFoldText()`를 전역 함수로 구현하고, `after/ftplugin/markdown.lua`에서 `foldmethod=expr`로 설정한다. foldexpr는 각 라인을 스캔해 컨텍스트를 파악하는 stateful 방식으로 구현한다.

**Tech Stack:** Neovim 0.10+, Lua, vim foldexpr/foldtext API

---

## Fold Rules 요약

| 타입 | 조건 | 동작 |
|------|------|------|
| 헤더 | `#`으로 시작 | 헤더 depth = fold level, 헤더 라인 자체 노출, 다음 같은/상위 레벨 헤더 전까지 접기 |
| 코드블록 | ` ``` ` 포함 총 5줄 이상 | 4번째 줄(```` ``` ```` 포함 카운트)부터 접기 |
| 리스트 | `-` 시작 (depth 무관) 3줄 이상 | 3번째 줄부터 접기 |
| callout | `>` 시작 3줄 이상, 독립 처리 | 2번째 줄부터 접기 |

---

### Task 1: markdown_fold.lua 파일 생성 — MarkdownFoldExpr 구현

**Files:**
- Create: `dot-config/nvim/lua/note_taking/markdown_fold.lua`

**Step 1: 파일 생성 및 헤더 fold 구현**

`dot-config/nvim/lua/note_taking/markdown_fold.lua` 생성:

```lua
-- Markdown custom fold expression and fold text

-- foldexpr: 각 라인의 fold level을 반환
-- 반환값 규칙:
--   "0"        = fold 없음
--   "1"~"6"    = fold level
--   ">1"~">6"  = fold 시작 (fold level N)
--   "<1"~"<6"  = fold 끝
--   "="        = 이전 라인과 동일한 fold level

function MarkdownFoldExpr()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)
    local next_line = vim.fn.getline(lnum + 1)

    -- 1. 헤더: # 레벨에 따라 fold level 부여
    --    헤더 라인 자체는 fold 시작점 (노출됨)
    local heading_level = line:match("^(#+)%s")
    if heading_level then
        return ">" .. #heading_level
    end

    -- 2. 코드블록: ``` 로 시작하는 라인 처리
    local in_code, code_start = _md_fold_code_block(lnum)
    if in_code and code_start then
        local offset = lnum - code_start
        if offset >= 3 then  -- 4번째 줄부터 (0-indexed: offset 3)
            return ">1"
        end
        return "="
    end

    -- 3. 리스트: - 로 시작하는 블록 처리
    local in_list, list_start = _md_fold_list_block(lnum)
    if in_list and list_start then
        local offset = lnum - list_start
        if offset >= 2 then  -- 3번째 줄부터 (0-indexed: offset 2)
            return ">1"
        end
        return "="
    end

    -- 4. callout: > 로 시작하는 블록 처리
    local in_callout, callout_start = _md_fold_callout_block(lnum)
    if in_callout and callout_start then
        local offset = lnum - callout_start
        if offset >= 1 then  -- 2번째 줄부터 (0-indexed: offset 1)
            return ">1"
        end
        return "="
    end

    return "="
end
```

> **Note:** 위 구조는 헬퍼 함수 `_md_fold_code_block`, `_md_fold_list_block`, `_md_fold_callout_block`에 의존함. 다음 스텝에서 구현.

**Step 2: 코드블록 헬퍼 함수 추가**

파일에 추가:

```lua
-- 코드블록 헬퍼: lnum이 코드블록 내부인지, 블록 시작 라인을 반환
-- 반환: (in_block: bool, block_start: number|nil)
-- 조건: ``` 포함 총 5줄 이상인 블록만 fold 대상
function _md_fold_code_block(lnum)
    local total = vim.fn.line("$")
    -- 위로 올라가며 ``` 찾기
    local start_lnum = nil
    for i = lnum, 1, -1 do
        local l = vim.fn.getline(i)
        if l:match("^%s*```") then
            start_lnum = i
            break
        end
    end
    if not start_lnum then return false, nil end
    -- 위에서 찾은 ``` 가 opening인지 closing인지 판별
    -- opening: 그 위에 ``` 쌍이 없어야 함
    local open_count = 0
    for i = 1, start_lnum do
        if vim.fn.getline(i):match("^%s*```") then
            open_count = open_count + 1
        end
    end
    -- open_count가 홀수면 opening
    if open_count % 2 == 0 then return false, nil end  -- closing이므로 무시

    -- closing ``` 찾기
    local end_lnum = nil
    for i = start_lnum + 1, total do
        if vim.fn.getline(i):match("^%s*```") then
            end_lnum = i
            break
        end
    end
    if not end_lnum then return false, nil end

    -- 총 라인 수 체크 (5줄 이상)
    local block_size = end_lnum - start_lnum + 1
    if block_size < 5 then return false, nil end

    -- lnum이 블록 범위 내인지
    if lnum >= start_lnum and lnum <= end_lnum then
        return true, start_lnum
    end
    return false, nil
end
```

**Step 3: 리스트 헬퍼 함수 추가**

```lua
-- 리스트 헬퍼: lnum이 리스트 블록 내부인지, 블록 시작 라인을 반환
-- - 로 시작하는 연속된 라인 (들여쓰기 무관) 3줄 이상
function _md_fold_list_block(lnum)
    local line = vim.fn.getline(lnum)
    -- 현재 라인이 리스트 라인인지
    if not line:match("^%s*%-") then return false, nil end

    -- 블록 시작 찾기 (위로 올라가며)
    local start_lnum = lnum
    for i = lnum - 1, 1, -1 do
        local l = vim.fn.getline(i)
        if l:match("^%s*%-") then
            start_lnum = i
        else
            break
        end
    end

    -- 블록 끝 찾기 (아래로 내려가며)
    local total = vim.fn.line("$")
    local end_lnum = lnum
    for i = lnum + 1, total do
        local l = vim.fn.getline(i)
        if l:match("^%s*%-") then
            end_lnum = i
        else
            break
        end
    end

    -- 3줄 이상인지
    local block_size = end_lnum - start_lnum + 1
    if block_size < 3 then return false, nil end

    return true, start_lnum
end
```

**Step 4: callout 헬퍼 함수 추가**

```lua
-- callout 헬퍼: lnum이 callout 블록 내부인지, 블록 시작 라인을 반환
-- > 로 시작하는 연속된 라인 3줄 이상, 독립 처리
function _md_fold_callout_block(lnum)
    local line = vim.fn.getline(lnum)
    if not line:match("^>") then return false, nil end

    -- 블록 시작 찾기
    local start_lnum = lnum
    for i = lnum - 1, 1, -1 do
        local l = vim.fn.getline(i)
        if l:match("^>") then
            start_lnum = i
        else
            break
        end
    end

    -- 블록 끝 찾기
    local total = vim.fn.line("$")
    local end_lnum = lnum
    for i = lnum + 1, total do
        local l = vim.fn.getline(i)
        if l:match("^>") then
            end_lnum = i
        else
            break
        end
    end

    -- 3줄 이상인지
    local block_size = end_lnum - start_lnum + 1
    if block_size < 3 then return false, nil end

    return true, start_lnum
end
```

**Step 5: 동작 확인**

nvim에서 markdown 파일 열고 `:set foldexpr=v:lua.MarkdownFoldExpr()` 수동 설정 후 각 타입별 fold 동작 확인.

**Step 6: Commit**

```bash
git add dot-config/nvim/lua/note_taking/markdown_fold.lua
git commit -m "feat(markdown): add custom foldexpr for heading/code/list/callout"
```

---

### Task 2: MarkdownFoldText 구현 — 헤더 스타일

**Files:**
- Modify: `dot-config/nvim/lua/note_taking/markdown_fold.lua`

**Step 1: 헤더 foldtext 구현 추가**

파일 끝에 추가:

```lua
-- foldtext: 접힌 fold의 표시 텍스트 반환
function MarkdownFoldText()
    local lnum = vim.v.foldstart
    local line = vim.fn.getline(lnum)
    local fold_size = vim.v.foldend - vim.v.foldstart  -- 접힌 라인 수 (시작 라인 제외)
    local win_width = vim.fn.winwidth(0)

    -- 헤더 처리
    local heading_level = line:match("^(#+)%s")
    if heading_level then
        return _md_foldtext_heading(line, #heading_level, fold_size, win_width)
    end

    -- 코드블록 처리
    if line:match("^%s*```") then
        return _md_foldtext_block(line, fold_size, win_width, "code")
    end

    -- 리스트 처리
    if line:match("^%s*%-") then
        return _md_foldtext_block(line, fold_size, win_width, "list")
    end

    -- callout 처리
    if line:match("^>") then
        return _md_foldtext_block(line, fold_size, win_width, "callout")
    end

    return line .. " ··· (" .. fold_size .. " lines)"
end
```

**Step 2: 헤더 foldtext 헬퍼 추가**

헤더별 너비: H1=100, H2=80, H3=60, H4+=40

```lua
local HEADING_WIDTHS = { 100, 80, 60, 40 }

function _md_foldtext_heading(line, level, fold_size, win_width)
    local target_width = HEADING_WIDTHS[math.min(level, 4)]
    target_width = math.min(target_width, win_width - 2)

    local suffix = " (" .. fold_size .. " lines)"
    local available = target_width - #line - #suffix
    local dots = available > 0 and string.rep("·", available) or " "

    return line .. dots .. suffix
end
```

**Step 3: 코드블록/리스트/callout foldtext 헬퍼 추가**

```lua
function _md_foldtext_block(line, fold_size, win_width, block_type)
    local fixed_width = 60
    fixed_width = math.min(fixed_width, win_width - 2)

    local suffix = " (" .. fold_size .. " lines)"
    local available = fixed_width - #line - #suffix
    local dots = available > 0 and string.rep("·", available) or " "

    return line .. dots .. suffix
end
```

**Step 4: Commit**

```bash
git add dot-config/nvim/lua/note_taking/markdown_fold.lua
git commit -m "feat(markdown): add foldtext with heading level widths and dot fill"
```

---

### Task 3: foldtext 색상 highlight 추가

**Files:**
- Modify: `dot-config/nvim/lua/note_taking/markdown_fold.lua`

nvim 0.10+에서 `foldtext`가 highlight chunks를 반환하는 방식을 지원함.
반환값을 `{ {text, hl_group}, ... }` 형태로 변경.

**Step 1: highlight 그룹 정의 추가**

파일 상단에 추가:

```lua
-- Highlight groups for fold text
-- 처음 로드 시 한 번만 설정
local _fold_hl_initialized = false
local function _ensure_fold_highlights()
    if _fold_hl_initialized then return end
    _fold_hl_initialized = true

    -- 헤더 레벨별 배경색 (H1 밝음 → H4 어두움)
    vim.api.nvim_set_hl(0, "MdFoldH1", { bg = "#3a3a52", fg = "#c0caf5", bold = true })
    vim.api.nvim_set_hl(0, "MdFoldH2", { bg = "#2e3a4a", fg = "#9aa5ce", bold = true })
    vim.api.nvim_set_hl(0, "MdFoldH3", { bg = "#263040", fg = "#7882a4" })
    vim.api.nvim_set_hl(0, "MdFoldH4", { bg = "#1e2638", fg = "#565f89" })
    -- dots & lines 색상
    vim.api.nvim_set_hl(0, "MdFoldDots", { fg = "#414868" })
    vim.api.nvim_set_hl(0, "MdFoldInfo", { fg = "#565f89", italic = true })
    -- 코드블록/리스트/callout
    vim.api.nvim_set_hl(0, "MdFoldBlock", { bg = "#1e2030", fg = "#737aa2" })
end
```

**Step 2: MarkdownFoldText를 chunks 방식으로 교체**

`MarkdownFoldText` 함수를 아래로 교체:

```lua
function MarkdownFoldText()
    _ensure_fold_highlights()
    local lnum = vim.v.foldstart
    local line = vim.fn.getline(lnum)
    local fold_size = vim.v.foldend - vim.v.foldstart
    local win_width = vim.fn.winwidth(0)

    local heading_level = line:match("^(#+)%s")
    if heading_level then
        return _md_foldtext_heading_hl(line, #heading_level, fold_size, win_width)
    end

    if line:match("^%s*```") or line:match("^%s*%-") or line:match("^>") then
        return _md_foldtext_block_hl(line, fold_size, win_width)
    end

    return { { line .. " ··· (" .. fold_size .. " lines)", "MdFoldBlock" } }
end
```

**Step 3: 헤더 highlight chunks 헬퍼 교체**

`_md_foldtext_heading` 함수를 아래로 교체:

```lua
local HEADING_HL = { "MdFoldH1", "MdFoldH2", "MdFoldH3", "MdFoldH4" }

function _md_foldtext_heading_hl(line, level, fold_size, win_width)
    local hl = HEADING_HL[math.min(level, 4)]
    local target_width = HEADING_WIDTHS[math.min(level, 4)]
    target_width = math.min(target_width, win_width - 2)

    local suffix = " (" .. fold_size .. " lines)"
    local available = target_width - #line - #suffix
    local dots = available > 0 and string.rep("·", available) or ""

    return {
        { line, hl },
        { dots, "MdFoldDots" },
        { suffix, "MdFoldInfo" },
    }
end
```

**Step 4: 블록 highlight chunks 헬퍼 교체**

`_md_foldtext_block` 함수를 아래로 교체:

```lua
function _md_foldtext_block_hl(line, fold_size, win_width)
    local fixed_width = 60
    fixed_width = math.min(fixed_width, win_width - 2)

    local suffix = " (" .. fold_size .. " lines)"
    local available = fixed_width - #line - #suffix
    local dots = available > 0 and string.rep("·", available) or ""

    return {
        { line, "MdFoldBlock" },
        { dots, "MdFoldDots" },
        { suffix, "MdFoldInfo" },
    }
end
```

**Step 5: Commit**

```bash
git add dot-config/nvim/lua/note_taking/markdown_fold.lua
git commit -m "feat(markdown): add highlight colors to foldtext chunks"
```

---

### Task 4: ftplugin 연결 및 전체 통합

**Files:**
- Modify: `dot-config/nvim/after/ftplugin/markdown.lua`
- Modify: `dot-config/nvim/lua/note_taking/markdown_fold.lua` (require 추가)

**Step 1: markdown_fold.lua 상단에 require 확인**

`markdown_fold.lua`는 전역 함수를 노출하므로 별도 return 없이 `require`로 로드만 하면 됨. 파일 맨 마지막에 추가:

```lua
-- 모듈 로드 완료 표시 (require 캐싱용)
return true
```

**Step 2: markdown.lua ftplugin에 fold 설정 추가**

`dot-config/nvim/after/ftplugin/markdown.lua` 상단 (line 1 `local map = ...` 바로 위에) 추가:

```lua
-- Markdown custom folding
require("note_taking.markdown_fold")
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.MarkdownFoldExpr()"
vim.opt_local.foldtext = "v:lua.MarkdownFoldText()"
vim.opt_local.foldlevel = 99
vim.opt_local.foldlevelstart = 99
vim.opt_local.foldcolumn = "1"  -- markdown은 foldcolumn 표시
```

> **Note:** `foldcolumn = "1"`으로 설정해 markdown에서만 fold 컬럼 표시. 전역 설정은 `"0"`이므로 local 오버라이드.

**Step 3: nvim 재시작 후 통합 동작 확인**

테스트용 markdown 내용:
```md
# H1 제목

본문 내용1
본문 내용2
본문 내용3

## H2 제목

### H3 제목

본문

```lua
local x = 1
local y = 2
local z = 3
local w = 4
```

- 항목 1
- 항목 2
- 항목 3
- 항목 4

> [!NOTE]
> 내용1
> 내용2
> 내용3
```

확인 항목:
- `zM` → 모두 접기
- `zR` → 모두 펼치기
- `zo` (= `za`) → toggle
- foldtext에 색상이 적용되는지

**Step 4: Commit**

```bash
git add dot-config/nvim/after/ftplugin/markdown.lua dot-config/nvim/lua/note_taking/markdown_fold.lua
git commit -m "feat(markdown): integrate custom fold into markdown ftplugin"
```

---

## 실행 순서 요약

| # | 작업 | 파일 | 중요도 |
|---|------|------|--------|
| 1 | foldexpr 4가지 규칙 구현 | `markdown_fold.lua` (신규) | 필수 |
| 2 | foldtext 텍스트 포맷 구현 | `markdown_fold.lua` | 필수 |
| 3 | foldtext highlight 색상 적용 | `markdown_fold.lua` | 권장 |
| 4 | ftplugin 연결 | `markdown.lua`, `markdown_fold.lua` | 필수 |
