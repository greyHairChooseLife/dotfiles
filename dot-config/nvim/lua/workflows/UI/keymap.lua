local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>>>>> Noice.nvim
-- DEPRECATED:: 2025-02-03
-- map("n", "<Space>n", "<cmd>NoiceDismiss<CR>")

map("n", ",.N", "<cmd>Noice telescope<CR>") -- N for Noice
-- <<<<<<<<<<<<<<<<<<<<
