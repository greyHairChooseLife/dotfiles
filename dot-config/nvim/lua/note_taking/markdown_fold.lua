-- Markdown custom fold expression and fold text

-- 버퍼별 fold level 캐시
local _cache = {}

-- 헤더 섹션 범위를 먼저 결정한 뒤, 범위 기반으로 level 할당
local function _compute_levels(lines)
    local total = #lines
    local levels = {}
    local foldexprs = {}

    -- 0단계: frontmatter 처리 (파일 첫 줄이 "---"인 경우)
    local frontmatter_end = 0
    if lines[1] and lines[1]:match("^%-%-%-$") then
        for i = 2, total do
            if lines[i]:match("^%-%-%-$") then
                frontmatter_end = i
                break
            end
        end
        if frontmatter_end > 2 then
            levels[1] = 0
            for i = 2, frontmatter_end - 1 do
                levels[i] = 1
            end
            foldexprs[2] = ">1"
            foldexprs[frontmatter_end] = "0"
            levels[frontmatter_end] = 0
        end
    end

    -- 1단계: 모든 헤더 위치와 레벨 수집
    local headers = {} -- { {lnum, depth} }
    for i = 1, total do
        local h = lines[i]:match("^(#+)%s")
        -- MEMO:: replace with this line below to include header level 1.
        -- if h then headers[#headers + 1] = { lnum = i, depth = #h } end
        if h and #h > 1 then headers[#headers + 1] = { lnum = i, depth = #h - 1 } end
    end

    -- 2단계: 각 헤더의 섹션 끝(= 같거나 상위 헤더 바로 앞 라인) 계산
    for idx, hdr in ipairs(headers) do
        local section_end = total
        for j = idx + 1, #headers do
            if headers[j].depth <= hdr.depth then
                section_end = headers[j].lnum - 1
                break
            end
        end
        hdr.section_end = section_end
    end

    -- 3단계: level 할당
    -- 헤더 라인: depth - 1 (fold 밖)
    -- 헤더 다음 라인 ~ section_end: depth (fold 안)
    -- 어디에도 속하지 않는 라인: 0

    -- 먼저 전부 0으로 초기화
    for i = 1, total do
        levels[i] = 0
    end

    -- 얕은 헤더부터 처리, max로 갱신하므로 깊은 헤더가 자연스럽게 덮어씀
    for _, hdr in ipairs(headers) do
        -- 헤더 라인 자체
        foldexprs[hdr.lnum] = tostring(math.max(hdr.depth - 1, 0))
        levels[hdr.lnum] = math.max(hdr.depth - 1, 0)

        -- 헤더 다음 라인이 있고, section_end가 헤더보다 뒤에 있을 때만 fold
        if hdr.lnum < total and hdr.section_end > hdr.lnum then
            local fold_start = hdr.lnum + 1
            local fold_end = hdr.section_end

            -- fold 시작 라인
            foldexprs[fold_start] = ">" .. hdr.depth

            -- fold 범위 안의 라인: 더 깊은 헤더가 이미 높은 값을 줬을 수 있으므로 max
            for i = fold_start, fold_end do
                if levels[i] < hdr.depth then levels[i] = hdr.depth end
            end
        end
    end

    -- section_end 바깥 라인은 0 초기화 상태 유지

    -- 4단계: 코드블록 후처리
    local in_codeblock = false
    local cb_start_level = 0
    local cb_start_lnum = 0

    for i = 1, total do
        local line = lines[i] or ""
        if line:match("^%s*```") then
            if not in_codeblock then
                in_codeblock = true
                cb_start_level = levels[i]
                cb_start_lnum = i
            else
                in_codeblock = false
                foldexprs[i] = nil
                levels[i] = cb_start_level + 1
            end
        elseif in_codeblock then
            foldexprs[i] = nil
            if i <= cb_start_lnum + 3 then
                levels[i] = cb_start_level
            else
                levels[i] = cb_start_level + 1
            end
        end
    end

    -- 5단계: 테이블 후처리
    local i = 1
    while i <= total do
        local line = lines[i] or ""
        local is_separator = line:match("^|%s*%-%-%-") or line:match("^%s*|?%-%-%-")
        if is_separator then
            local prev_line = lines[i - 1] or ""
            if prev_line:match("^%s*|") then
                local data_start = i + 1
                local data_end = data_start - 1
                for j = data_start, total do
                    if (lines[j] or ""):match("^%s*|") then
                        data_end = j
                    else
                        break
                    end
                end
                local data_count = data_end - data_start + 1
                if data_count >= 3 then
                    local base = levels[i]
                    for j = data_start, data_end do
                        foldexprs[j] = nil
                        levels[j] = base + 1
                    end
                end
                i = data_end + 1
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end

    -- 6단계: callout/리스트 후처리
    for i = 1, total do
        local curr = lines[i] or ""
        local prev = lines[i - 1] or ""

        -- 코드블록 안이면 건너뜀
        if foldexprs[i] == nil and not curr:match("^%s*```") then
            if curr:match("^%s*>%s*%[!") then
                -- callout 시작: 현재 level 유지
            elseif curr:match("^%s*>") and prev:match("^%s*>%s*%[!") then
                levels[i] = levels[i] + 1
            elseif curr:match("^%s*>") and prev:match("^%s*>") then
                levels[i] = levels[i - 1]
            elseif curr:match("^%s*>") then
                levels[i] = levels[i] + 1
            else
                local is_list = curr:match("^%s*[-*+]%s") or curr:match("^%s*%d+%.%s")
                if is_list then
                    local prev_is_list = prev:match("^%s*[-*+]%s") or prev:match("^%s*%d+%.%s")
                    if not prev_is_list then
                        -- 리스트 첫 줄: level 유지 (fold 밖)
                    else
                        -- 리스트 두 번째 줄부터: +1
                        levels[i] = levels[i] + 1
                    end
                end
            end
        end
    end

    return levels, foldexprs
end

local function _get_cache(bufnr)
    local tick = vim.api.nvim_buf_get_changedtick(bufnr)
    local cached = _cache[bufnr]
    if cached and cached.changedtick == tick then return cached.levels, cached.foldexprs end
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local levels, foldexprs = _compute_levels(lines)
    _cache[bufnr] = { changedtick = tick, levels = levels, foldexprs = foldexprs }
    return levels, foldexprs
end

function MarkdownFoldExpr()
    local bufnr = vim.api.nvim_get_current_buf()
    local lnum = vim.v.lnum
    local levels, foldexprs = _get_cache(bufnr)

    if foldexprs[lnum] then return foldexprs[lnum] end

    local curr = levels[lnum] or 0
    local prev = levels[lnum - 1] or 0

    if curr > prev then return ">" .. curr end
    if curr < prev then return tostring(curr) end
    return "="
end

-- foldtext

local function _md_foldtext_heading_hl(line, level, fold_size, win_width)
    -- H1 제외이므로 index 1=H2, 2=H3, 3=H4, 4=H5
    local HEADING_WIDTHS = { 92, 76, 50, 32, 17 }
    -- level = 원래 # 개수 (2~5), index로 변환 (H2→1, H3→2, ...)
    local idx = math.max(level - 1, 1)
    idx = math.min(idx, #HEADING_WIDTHS)
    local target_width = HEADING_WIDTHS[idx]
    target_width = math.min(target_width, win_width - 2)
    local info = "+--" .. string.format("%3d", fold_size) .. " lines  "
    local pad = target_width - #info
    local dots = pad > 0 and string.rep("█", pad) or ""
    return {
        { "  " },
        { dots, "MdFoldBlock" },
        { info, "MDFoldHeaderInfo" },
    }
end

local function _md_foldtext_codeblock_hl(line, fold_size, win_width)
    local indent = line:match("^(%s*)")
    local info = "  +++ " .. fold_size .. " lines more                       "
    local suffix = "▉▊▋▌▍▎"
    return {
        { indent, "FoldIndent" },
        { info, "FoldTextCodeblock" },
        { suffix, "FoldTextCodeblockReverse" },
    }
end

local function _md_foldtext_bulletpoint_hl(line, fold_size, win_width)
    local indent = line:match("^(%s*)")
    local info = "  +-- " .. fold_size .. " lines"
    return {
        { indent, "FoldIndent" },
        { info, "FoldText" },
    }
end

local function _md_foldtext_callout_hl(line, fold_size, win_width)
    local indent = line:match("^(%s*)")
    local info = "█ +-- " .. fold_size + 1 .. " lines"
    return {
        { indent, "FoldIndent" },
        { info, "FoldText" },
    }
end

local function _md_foldtext_table_hl(line, fold_size, win_width)
    local indent = line:match("^(%s*)")
    local info = "  + entries: " .. fold_size + 1 .. " "
    local suffix = "▉▊▋▌▍▎"
    return {
        { indent, "FoldIndent" },
        { info, "FoldTextMDTable" },
        { suffix, "FoldTextMDTableSuffix" },
    }
end

function MarkdownFoldText()
    local lnum = vim.v.foldstart
    local line = vim.fn.getline(lnum)
    local fold_size = vim.v.foldend - vim.v.foldstart
    local win_width = vim.fn.winwidth(0)

    -- foldstart 위에 헤더가 있으면 헤더를 foldtext로 표시
    local prev_line = lnum > 1 and vim.fn.getline(lnum - 1) or ""
    local prev_heading = prev_line:match("^(#+)%s")
    if prev_heading then return _md_foldtext_heading_hl(prev_line, #prev_heading, fold_size, win_width) end

    local prev_codeblock_line = lnum > 4 and vim.fn.getline(lnum - 4) or ""
    local prev_codeblock = prev_codeblock_line:match("^%s*```")
    if prev_codeblock then return _md_foldtext_codeblock_hl(line, fold_size, win_width) end

    local prev_callout = prev_line:match("^%s*>%s*%[!")
    if prev_callout then return _md_foldtext_callout_hl(prev_line, fold_size, win_width) end

    if line:match("^%s*[-*+]%s") or line:match("^%s*%d+%.%s") then
        return _md_foldtext_bulletpoint_hl(line, fold_size, win_width)
    elseif line:match("^%s*|") then
        return _md_foldtext_table_hl(line, fold_size, win_width)
    end

    return { { line .. " ··· (" .. fold_size .. " lines)", "FoldText" } }
end

return true
