vim.api.nvim_create_autocmd("BufUnload", {

    pattern = "COMMIT_EDITMSG",
    group = vim.api.nvim_create_augroup("GitCommitCursorPosition", { clear = true }),
    callback = function()
        vim.defer_fn(function() require("utils").restore_cursor_position(true) end, 1)
    end,
})

-- nvim-tree's git watcher only reacts to .git/index, but git writes .git/index.lock
-- and renames it, so the rename is reported as "index.lock" and gets filtered out.
-- Reload right after the commit message is written so the git signs refresh.
vim.api.nvim_create_autocmd({ "BufWritePost", "BufUnload" }, {
    pattern = "COMMIT_EDITMSG",
    group = vim.api.nvim_create_augroup("GitCommitTreeReload", { clear = true }),
    callback = function()
        vim.defer_fn(function()
            if not package.loaded["nvim-tree.api"] then return end
            pcall(require("nvim-tree.api").tree.reload)
        end, 50)
    end,
})
