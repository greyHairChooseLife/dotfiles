local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- AERIAL
map("n", ",,a", function()
	vim.cmd("AerialToggle")
	vim.cmd("wincmd p")
end)
map("n", ",a", function()
	vim.cmd("norm ^ww")
	vim.cmd("AerialOpen")
end)
