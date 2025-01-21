local map = vim.keymap.set
local opt = { noremap = true, silent = true }

map("n", "<C-t>", OpenOrFocusTerm)
map({ "n", "v", "t" }, "<C-\\><C-\\>", "<Cmd>ToggleTerm direction=float name=genaral<CR>")
