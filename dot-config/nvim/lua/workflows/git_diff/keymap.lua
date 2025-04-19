local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- git status 관리
map("n", ",g", "<cmd>G<CR>") -- shortcut
map("n", "<leader>gc", function()
	vim.cmd("silent G commit")
	vim.cmd("normal! gg")
end, { silent = true }) -- 즉시 커밋, 버퍼가 상단이 아니라 우측에서 열리도록 하고 view는 유지
map("v", "<leader>gc", Commit_with_selected, { silent = true })
map("n", "<leader>ga", "<cmd>silent G commit --amend<CR>", { silent = true })

-- GITSIGNS
map("n", "gsth", "<cmd>Gitsigns stage_hunk | NvimTreeRefresh<CR>") -- stage hunk
map("v", "gsth", Visual_stage) -- stage hunk
map("v", "gstu", Visual_undo_stage) -- stage hunk
map("n", "gstb", "<cmd>Gitsigns stage_buffer | NvimTreeRefresh<CR>") -- stage buffer
map("n", "greh", "<cmd>Gitsigns reset_hunk | NvimTreeRefresh<CR>") -- reset hunk, de-active
map("v", "greh", Visual_reset) -- reset hunk, de-active
map("n", "gpre", "<cmd>Gitsigns preview_hunk<CR>") -- show diff
map("n", "gbl", "<cmd>Gitsigns blame_line<CR>") -- show diff
