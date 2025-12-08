local map = vim.keymap.set
local opts = { buffer = true }

vim.defer_fn(function()
    vim.fn.feedkeys("gU", "x") -- 시작시 커서를 unstaged 목록에 위치
end, 1)

map("n", "cc", OpenCommitMsg, opts)
map("n", "ca", AmendCommitMsg, opts)
map("n", "P", ":G push", opts)
map("n", "F", "<Cmd>G fetch<CR>", opts)
map("n", ",g", function()
    vim.cmd("q")
    if require("utils").tree:is_visible() then ReloadLayout() end
    if vim.bo.buftype ~= "nofile" then vim.wo.cursorline = false end
end, opts) -- close buffer, saving memory
map("n", "gq", function()
    vim.cmd("q")
    if require("utils").tree:is_visible() then ReloadLayout() end
    if vim.bo.buftype ~= "nofile" then vim.wo.cursorline = false end
end, opts) -- close buffer, saving memory
map("n", "i", function() vim.cmd("normal =") end, opts)

map("n", "L", function()
    vim.fn.feedkeys("0", "x")
    local gitRevision = vim.fn.expand("<cword>")
    gitRevision = require("utils").get_valid_rev(gitRevision)

    local git_log = vim.fn.system("git --no-pager show --stat " .. gitRevision .. " | sed '$d'")

    require("utils").create_floating_window(git_log, "git", 100, 20)
end, opts)
