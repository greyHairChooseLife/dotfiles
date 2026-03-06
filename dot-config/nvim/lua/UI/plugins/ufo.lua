return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
        enable_get_fold_virt_text = true,
        provider_selector = function(bufnr, filetype, buftype)
            if filetype == "markdown" then
                return "" -- use our custom foldexpr
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

            -- import block: skip closing bracket, just show line count
            local isImport = firstLine:match("^%s*import%s")
            local suffix
            if isImport then
                suffix = { { ("  " .. bar .. " %d lines more" .. depthText):format(lineCount + 1), "Comment" } }
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

            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    table.insert(newVirtText, { chunkText, chunk[2] })
                    break
                end
                curWidth = curWidth + chunkWidth
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

        -- prevent ufo from re-closing folds on TextChanged
        vim.defer_fn(function()
            for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "Ufo", event = "TextChanged" })) do
                pcall(vim.api.nvim_del_autocmd, au.id)
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

        vim.keymap.set("n", "zn", function() next_closed_fold("next") end, { desc = "Next fold" })
        vim.keymap.set("n", "zp", function() next_closed_fold("prev") end, { desc = "Prev fold" })

        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = vim.api.nvim_create_augroup("UfoReattach", { clear = true }),
            callback = function()
                if vim.bo.buftype == "" then
                    ufo.attach()
                end
            end,
        })
    end,
}
