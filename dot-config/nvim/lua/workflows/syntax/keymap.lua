local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- DEPRECATED:: 2025-02-06, which-key
-- AERIAL
-- map("n", ",,a", function()
-- 	vim.cmd("AerialToggle")
-- 	vim.cmd("wincmd p")
-- end)
-- map("n", ",a", function()
-- 	vim.cmd("norm ^ww")
-- 	vim.cmd("AerialOpen")
-- end)
