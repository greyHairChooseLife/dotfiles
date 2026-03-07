return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
        enable_get_fold_virt_text = true,
        provider_selector = function(bufnr, filetype, buftype)
            if filetype == "markdown" then
                -- custom provider: foldexpr 로직으로 ufo fold ranges 계산
                return function(bufnr)
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

                    -- foldlevel 배열에서 fold ranges 추출
                    local ranges = {}
                    local stack = {}
                    for i = 1, total do
                        local fl = levels[i]
                        -- 현재 레벨보다 높은 fold 닫기
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
            end
            return { "treesitter", "indent" }
        end,
        close_fold_kinds_for_ft = {},
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
            local newVirtText = {}
            local firstLine = vim.api.nvim_buf_get_lines(ctx.bufnr, lnum - 1, lnum, false)[1] or ""
            local lineCount = endLnum - lnum - 1

            -- elastic bar: 1 block per ~2 lines, capped at 50
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

            -- import block or markdown: skip closing line, just show line count
            local isImport = firstLine:match("^%s*import%s")
            local isMarkdown = vim.bo[ctx.bufnr].filetype == "markdown"
            local suffix
            if isImport or isMarkdown then
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
                    local truncatedWidth = vim.fn.strdisplaywidth(chunkText)
                    table.insert(newVirtText, { chunkText, chunk[2] })
                    curWidth = curWidth + truncatedWidth
                    break
                end
            end

            for _, chunk in ipairs(suffix) do
                table.insert(newVirtText, chunk)
            end
            return newVirtText
        end,
    },
    config = function(_, opts)
        local ufo = require("ufo")
        ufo.setup(opts)

        local orig_cursor_hl = vim.api.nvim_get_hl(0, { name = "Cursor" })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = vim.api.nvim_create_augroup("UfoCursorMismatch", { clear = true }),
            callback = function()
                local lnum = vim.fn.line(".")
                local fold_start = vim.fn.foldclosed(lnum)
                if fold_start ~= -1 and fold_start ~= lnum then
                    vim.api.nvim_set_hl(0, "Cursor", { bg = "#c678dd", fg = "#282c34" })
                    vim.api.nvim_set_hl(0, "SmearCursor", { bg = "#c678dd", fg = "#282c34" })
                    vim.api.nvim_set_hl(0, "SmearCursorHideable", { bg = "#c678dd", fg = "#282c34" })
                else
                    vim.api.nvim_set_hl(0, "Cursor", orig_cursor_hl)
                    vim.api.nvim_set_hl(0, "SmearCursor", {})
                    vim.api.nvim_set_hl(0, "SmearCursorHideable", {})
                end
            end,
        })

        -- prevent ufo from re-closing folds on TextChanged or returning to normal mode
        vim.defer_fn(function()
            for _, event in ipairs({ "TextChanged", "ModeChanged" }) do
                for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "Ufo", event = event })) do
                    pcall(vim.api.nvim_del_autocmd, au.id)
                end
            end
        end, 100)

        local function next_closed_fold(direction)
            local lnum = vim.fn.line(".")
            local total = vim.fn.line("$")
            local step = direction == "next" and 1 or -1
            local i = lnum + step
            while i >= 1 and i <= total do
                if vim.fn.foldclosed(i) == i then
                    vim.fn.cursor(i, 1)
                    return
                end
                i = i + step
            end
        end

        vim.keymap.set("n", "w", function()
            if vim.fn.foldclosed(vim.fn.line(".")) ~= -1 then
                vim.cmd("normal! 10zo")
            else
                vim.cmd("normal! w")
            end
        end, { desc = "w (open fold if closed)" })
        vim.keymap.set("n", "zn", function() next_closed_fold("next") end, { desc = "Next fold" })
        vim.keymap.set("n", "zp", function() next_closed_fold("prev") end, { desc = "Prev fold" })
        vim.keymap.set("n", "zx", function()
            local lnum = vim.fn.line(".")
            local curLevel = vim.fn.foldlevel(lnum)
            if curLevel == 0 then return end

            -- find the boundary of the current fold
            local foldstart = lnum
            while foldstart > 1 and vim.fn.foldlevel(foldstart - 1) >= curLevel do
                foldstart = foldstart - 1
            end
            local foldend = lnum
            local total = vim.fn.line("$")
            while foldend < total and vim.fn.foldlevel(foldend + 1) >= curLevel do
                foldend = foldend + 1
            end

            -- collect max depth first, close deepest folds first
            local maxDepth = curLevel
            for i = foldstart, foldend do
                local l = vim.fn.foldlevel(i)
                if l > maxDepth then maxDepth = l end
            end

            for depth = maxDepth, curLevel, -1 do
                local i = foldstart
                while i <= foldend do
                    if vim.fn.foldlevel(i) == depth and vim.fn.foldclosed(i) == -1 then
                        vim.fn.cursor(i, 1)
                        vim.cmd("normal! zc")
                        -- skip to after this fold
                        i = vim.fn.foldclosedend(i) + 1
                    else
                        i = i + 1
                    end
                end
            end
            vim.fn.cursor(foldstart, 1)
        end, { desc = "Close current and nested folds recursively" })

        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = vim.api.nvim_create_augroup("UfoReattach", { clear = true }),
            callback = function()
                if vim.bo.buftype == "" then ufo.attach() end
            end,
        })
    end,
}
