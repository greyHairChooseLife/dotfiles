# Markdown Folding Implementation Plan

**Goal:** markdown 파일에 커스텀 foldexpr/foldtext를 적용해 헤더/코드블록/리스트/callout 4가지 타입의 접기 규칙과 스타일을 구현한다.

**Status:** Tasks 1~4 완료. 헤더 fold 계층 구조 개선 작업 진행 중 (미완).

---

## 완료된 작업

### 구현 파일
- `dot-config/nvim/lua/note_taking/markdown_fold.lua` — fold 로직 전체
- `dot-config/nvim/after/ftplugin/markdown.lua` — ftplugin 연결

### 핵심 해결 사항: vim.schedule 필요 이유
ftplugin 실행 시점에 BufReadPost autocmd 체인이 진행 중이라, 이후 핸들러(loadview 등)가 foldexpr를 덮어씀.
`vim.schedule`로 이벤트 루프 완료 후 실행해서 해결.

```lua
vim.schedule(function()
    vim.cmd([[
        setlocal foldmethod=expr
        setlocal foldexpr=v:lua.MarkdownFoldExpr()
        setlocal foldtext=v:lua.MarkdownFoldText()
        setlocal foldlevel=99
        setlocal foldcolumn=1
    ]])
end)
```

---

## 현재 미완 작업: 헤더 fold 계층 구조

### 원하는 동작

```
# Top                     ← 항상 보임 (fold 밖)
  ## Sub                  ← 항상 보임, # Top fold 안에 포함
    content               ← ## Sub fold 안
  ## Sub2                 ← 항상 보임, # Top fold 안에 포함
    content
# Top2                    ← 항상 보임, 이전 # Top fold 종료
```

- 헤더 라인 자체는 항상 보여야 함 (fold 시작점이 아님)
- 헤더 다음 내용이 fold됨
- 상위 헤더 fold가 하위 헤더 + 그 내용을 포함

### 시도한 방식들과 실패 이유

**시도 1: 헤더 `>N`, 라인별 독립 계산**
- 헤더 `>N` → 헤더가 foldtext로 표시됨 (헤더 자체가 접혀버림)
- 실패 이유: 헤더 라인이 fold 안으로 들어가서 보이지 않음

**시도 2: 헤더 `=`, 다음 라인 `>N`**
- 헤더 다음에 빈 줄이 있으면 `>N` 조건 ("이전 라인이 헤더")이 작동 안 함
- 실패 이유: 실제 마크다운은 거의 항상 헤더 다음에 빈 줄 있음

**시도 3: 헤더 `<N` (fold 종료)**
- `<N`은 해당 라인을 이전 fold의 마지막으로 만듦 → 헤더가 이전 fold에 포함됨
- 실패 이유: 헤더가 fold 밖에 있어야 한다는 요구사항 위반

**시도 4: 빈 줄에서 다음이 헤더면 `0` 반환**
- 같은 레벨 헤더 앞 빈 줄은 fold 종료, 하위 헤더 앞 빈 줄은 유지하려 했음
- 실패 이유: `foldexpr`는 라인별 독립 호출이라 "현재 fold 레벨"을 알 수 없음
- `_current_heading_level(lnum)`으로 위로 탐색해도, `### Sub3` 아래 빈 줄에서 ctx_level=3이 되어 `### Sub4`(레벨 3)를 상위로 판단해 fold 끊음

**시도 5: 전체 파일 사전 계산 + 캐시 (현재 코드)**
- 참고한 UFO 플러그인의 `markdown_provider` 방식 적용
- `changedtick` 기반 캐시로 파일 전체를 한 번에 계산
- **현재 상태**: 헤더 처리 로직이 아직 미완성, 계층 구조가 정확하지 않음

### 현재 코드 (`markdown_fold.lua`) 핵심 로직

```lua
local function _compute_levels(lines)
    local levels = {}
    local header_levels = {}  -- 각 라인이 속한 헤더 레벨 추적

    local function compute(lnum)
        local prev = lines[lnum - 1] or ""
        local curr = lines[lnum] or ""
        local next = lines[lnum + 1] or ""

        -- 헤더 다음 라인: 헤더 레벨로 fold 시작
        local prev_heading = prev:match("^(#+)%s")
        if prev_heading then
            header_levels[lnum] = #prev_heading
            return #prev_heading
        end

        header_levels[lnum] = get_hl(lnum - 1)  -- 이전 라인의 헤더 레벨 전파

        -- 빈 줄: 다음이 같거나 상위 헤더면 fold 종료
        if curr:match("^%s*$") then
            local next_heading = next:match("^(#+)%s")
            if next_heading then
                local hl = get_hl(lnum)
                if hl == 0 or #next_heading <= hl then return 0 end
            end
            return get_hl(lnum)
        end

        -- 헤더 자체: 상위 헤더 레벨 반환 (fold 밖처럼 동작)
        local curr_heading = curr:match("^(#+)%s")
        if curr_heading then
            local my_level = #curr_heading
            for i = lnum - 1, 1, -1 do
                local h = lines[i]:match("^(#+)%s")
                if h and #h < my_level then return #h end
            end
            return 0
        end

        -- callout, 리스트 등...
    end
    -- ...
end
```

### 문제점 (아직 미해결)

헤더 바로 다음에 빈 줄이 있는 경우:
```
## Notes      ← compute: curr_heading 처리 → 상위 레벨 반환
              ← compute: prev_heading 있으므로 >2 반환 (빈줄인데 fold 시작?)
yes
```

빈 줄이 fold 시작점이 되는 문제가 있음. `prev_heading` 체크가 빈 줄보다 먼저 실행됨.

### 다음 세션 작업 방향

UFO 코드를 더 정확히 분석해서 적용:

1. **`prev_heading` 체크 순서 문제 해결**: 빈 줄인 경우 먼저 체크하고, 빈 줄이 아닌 경우에만 `prev_heading` 체크
2. **헤더 자체 레벨 처리**: 헤더 라인은 `levels[i] = my_level - 1` (상위 레벨), 헤더 다음 첫 비빈줄 라인은 `levels[i] = my_level`
3. **UFO 코드 참고점**: UFO에서는 `prev:match("^##%s")` 방식으로 각 레벨을 개별 처리하고, `header_levels` 배열로 현재 섹션 레벨을 전파함

UFO 코드의 핵심 패턴:
```lua
-- 헤더 다음 라인이 fold 시작
if prev:match("^##%s") then
    header_levels[lnum] = 1  -- ## = depth 1 (0-indexed)
    return 1
end
-- 빈 줄: 다음 헤더 레벨에 따라 fold 종료
if curr:match("^%s*$") then
    if next:match("^##%s") then return 0 end   -- ## 앞 → 종료
    if next:match("^###%s") then return 1 end  -- ### 앞 → 유지
    return get_hl(lnum)
end
```

UFO와의 차이: UFO는 fold range를 직접 반환하는 방식이고, 여기서는 `foldexpr`용 level을 반환해야 함. `MarkdownFoldExpr`에서 `curr > prev`면 `>curr`, `curr < prev`면 `curr`, 같으면 `=` 반환.

---

## Fold Rules 요약

| 타입 | 조건 | 동작 |
|------|------|------|
| 헤더 | `#`으로 시작 | 헤더 라인 자체는 보임, 다음 내용이 접힘, 계층 구조 유지 |
| 코드블록 | ` ``` ` 포함 총 5줄 이상 | 처음 3줄 노출, 이후 접힘 |
| 리스트 | `-`/`*`/`+` 시작 연속 | 이전 라인이 리스트면 같은 레벨, 아니면 +1 |
| callout | `>` 시작 | `> [!type]` 라인은 같은 레벨, 이후 내용 +1 |
| table | `|-` 시작, `-|` 끝 |  |
