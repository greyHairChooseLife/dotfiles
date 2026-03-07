local M = {}

-- markdown: ufo custom provider (fold range 계산)
function M.markdown_provider(bufnr)
    local foldingrange = require("ufo.model.foldingrange")
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local total = #lines

    local levels = {}
    local function get_fl(i) return levels[i] or 0 end

    local function compute(lnum)
        local prev = lines[lnum - 1] or ""
        local curr = lines[lnum] or ""
        local next = lines[lnum + 1] or ""

        if prev:match("^######%s") then return 5 end
        if prev:match("^#####%s")  then return 4 end
        if prev:match("^####%s")   then return 3 end
        if prev:match("^###%s")    then return 2 end
        if prev:match("^##%s")     then return 1 end

        if curr:match("^%s*$") then
            if next:match("^######%s") then return 4 end
            if next:match("^#####%s")  then return 3 end
            if next:match("^####%s")   then return 2 end
            if next:match("^###%s")    then return 1 end
            if next:match("^##%s")     then return 0 end
        end

        if lnum == total then return 0 end

        if curr:match("^>%s*%[!") then
            return get_fl(lnum - 1) + 1
        end
        if curr:match("^>") and prev:match("^>") then
            return get_fl(lnum - 1)
        end

        if curr:match("^%*%*[^%*]+%*%*%s*$") then
            local nb = next:match("^%s*[-*+]%s") or next:match("^%s*%d+%.%s")
            if nb then return get_fl(lnum - 1) + 1 end
        end

        if curr:match("^%s*[-*+]%s") or curr:match("^%s*%d+%.%s") then
            local pfl = get_fl(lnum - 1)
            if pfl > 0 then return pfl end
        end

        return get_fl(lnum - 1)
    end

    for i = 1, total do
        levels[i] = compute(i)
    end

    local ranges = {}
    local stack = {}
    for i = 1, total do
        local fl = levels[i]
        while #stack > 0 and stack[#stack].level > fl do
            local top = table.remove(stack)
            if i - 1 > top.lnum then
                table.insert(ranges, foldingrange.new(top.lnum - 1, i - 2))
            end
        end
        if fl > 0 and (fl > get_fl(i - 1) or (fl == get_fl(i - 1) and (#stack == 0 or stack[#stack].level ~= fl))) then
            table.insert(stack, { lnum = i, level = fl })
        end
    end
    while #stack > 0 do
        local top = table.remove(stack)
        if total > top.lnum then
            table.insert(ranges, foldingrange.new(top.lnum - 1, total - 1))
        end
    end

    return ranges
end

-- markdown: ufo fold_virt_text_handler
function M.markdown_virt_text(virtText, lnum, endLnum, width, truncate, ctx)
    local newVirtText = {}
    local lineCount = endLnum - lnum - 1

    local baseLevel = vim.fn.foldlevel(lnum)
    local maxLevel = baseLevel
    for row = lnum + 1, endLnum - 1 do
        local l = vim.fn.foldlevel(row)
        if l > maxLevel then maxLevel = l end
    end
    local depth = maxLevel - baseLevel
    local depthText = depth > 0 and (" (+%d)"):format(depth) or ""

    local countText = ("  %d lines" .. depthText):format(lineCount + 1)
    local firstLineWidth = 0
    for _, chunk in ipairs(virtText) do
        firstLineWidth = firstLineWidth + vim.fn.strdisplaywidth(chunk[1])
    end
    local fillLen = math.max(1, width - firstLineWidth - vim.fn.strdisplaywidth(countText))
    local suffix = { { string.rep("░", fillLen) .. countText, "Comment" } }

    local sufWidth = vim.fn.strdisplaywidth(suffix[1][1])
    local targetWidth = math.max(0, width - sufWidth)
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
            curWidth = curWidth + chunkWidth
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            break
        end
    end
    table.insert(newVirtText, suffix[1])
    return newVirtText
end

-- default: ufo fold_virt_text_handler (non-markdown)
function M.default_virt_text(virtText, lnum, endLnum, width, truncate, ctx)
    local newVirtText = {}
    local firstLine = vim.api.nvim_buf_get_lines(ctx.bufnr, lnum - 1, lnum, false)[1] or ""
    local lineCount = endLnum - lnum - 1

    local barLen = math.min(50, math.max(1, math.floor(lineCount / 2)))
    local bar = string.rep("󰇘", barLen)

    local baseLevel = vim.fn.foldlevel(lnum)
    local maxLevel = baseLevel
    for row = lnum + 1, endLnum - 1 do
        local l = vim.fn.foldlevel(row)
        if l > maxLevel then maxLevel = l end
    end
    local depth = maxLevel - baseLevel
    local depthText = depth > 0 and (" (+%d)"):format(depth) or ""

    local isImport = firstLine:match("^%s*import%s")
    local suffix
    if isImport then
        suffix = { { ("  " .. bar .. " %d lines" .. depthText):format(lineCount + 1), "Comment" } }
    else
        local endVirtText = ctx.get_fold_virt_text(endLnum)
        local endTrimmed = {}
        local seenNonSpace = false
        for _, chunk in ipairs(endVirtText) do
            if seenNonSpace or not chunk[1]:match("^%s*$") then
                seenNonSpace = true
                table.insert(endTrimmed, chunk)
            end
        end
        suffix = { { ("  " .. bar .. " %d lines" .. depthText .. " " .. bar .. "  "):format(lineCount), "Comment" } }
        for _, chunk in ipairs(endTrimmed) do
            table.insert(suffix, chunk)
        end
    end

    local sufWidth = 0
    for _, chunk in ipairs(suffix) do
        sufWidth = sufWidth + vim.fn.strdisplaywidth(chunk[1])
    end

    local targetWidth = math.max(0, width - sufWidth)
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
            curWidth = curWidth + chunkWidth
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
            break
        end
    end

    for _, chunk in ipairs(suffix) do
        table.insert(newVirtText, chunk)
    end
    return newVirtText
end

-- codecompanion: foldtext (전역 등록, v:lua.* 방식으로 참조)
_G.codecompanion_fold_text = function(foldstart, foldend, foldlevel)
    local line_start_icon
    if foldlevel == 1 then
        line_start_icon = "  "
    elseif foldlevel == 2 then
        line_start_icon = "  󱞪  "
    elseif foldlevel == 3 then
        line_start_icon = "    󱞪  "
    elseif foldlevel == 4 then
        line_start_icon = "      󱞪  "
    end
    local line_count = foldend - foldstart + 1
    return line_start_icon .. line_count .. "  "
end

_G.codecompanion_fold_expr = function(lnum)
    local prev_line = vim.fn.getline(lnum - 1)
    local curr_line = vim.fn.getline(lnum)
    local next_line = vim.fn.getline(lnum + 1)

    if string.match(prev_line, "^##%s")    then return "1" end
    if string.match(prev_line, "^###%s")   then return "2" end
    if string.match(prev_line, "^####%s")  then return "3" end
    if string.match(prev_line, "^#####%s") then return "4" end
    if string.match(curr_line, "^%s*$") and string.match(next_line, "^###%s")   then return "1" end
    if string.match(curr_line, "^%s*$") and string.match(next_line, "^####%s")  then return "2" end
    if string.match(curr_line, "^%s*$") and string.match(next_line, "^#####%s") then return "3" end
    if string.match(curr_line, "^%s*$") and string.match(next_line, "^######%s") then return "4" end
    if string.match(curr_line, "^%s*$") and string.match(next_line, "^##%s") then return "0" end
    return "="
end

return M
