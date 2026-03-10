-- Markdown custom fold expression and fold text

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

-- foldexpr: 각 라인의 fold level을 반환
-- 반환값 규칙:
--   "0"        = fold 없음
--   "1"~"6"    = fold level
--   ">1"~">6"  = fold 시작 (fold level N)
--   "<1"~"<6"  = fold 끝
--   "="        = 이전 라인과 동일한 fold level

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

function MarkdownFoldExpr()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)

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

-- foldtext: 접힌 fold의 표시 텍스트 반환

local HEADING_WIDTHS = { 100, 80, 60, 40 }
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

-- 모듈 로드 완료 표시 (require 캐싱용)
return true
