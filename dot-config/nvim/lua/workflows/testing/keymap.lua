local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- DEPRECATED:: 2024-01-17, tmux 이후로 keymap이 겹쳐서 안쓴다. 기능을 대체한 것은 아님
-- >>>>>>>>>
-- -- 삽입 도중 undo
-- map("i", "<C-h>", function()
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
-- 											-- DeleteAndStore()
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, true, true), "n", true)
-- end, opt)
--
-- -- 삽입 도중 redo
-- map("i", "<C-l>", function()
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
-- 											-- PasteFromHistory()
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, true, true), "n", true)
-- end, opt)
-- <<<<<<<<<<
