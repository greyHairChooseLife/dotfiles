return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
        enable_get_fold_virt_text = true,
        provider_selector = function(bufnr, filetype, buftype)
            if filetype == "markdown" then return require("UI.folding").markdown_provider end
            return { "treesitter", "indent" }
        end,
        close_fold_kinds_for_ft = {},
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
            local folding = require("UI.folding")
            if vim.bo[ctx.bufnr].filetype == "markdown" then return folding.markdown_virt_text(virtText, lnum, endLnum, width, truncate, ctx) end
            return folding.default_virt_text(virtText, lnum, endLnum, width, truncate, ctx)
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
