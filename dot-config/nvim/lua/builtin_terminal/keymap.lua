-- MEMO:: nice reference
-- https://www.youtube.com/watch?v=ooTcnx066Do

local map = vim.keymap.set
local opt = { noremap = true, silent = true }

map("n", "<C-t>", OpenOrFocusTerm)
map({ "n", "v", "t" }, "<C-\\><C-\\>", "<Cmd>ToggleTerm direction=float name=genaral<CR>")

-- function _yes()
--   local Terminal = require('toggleterm.terminal').Terminal
--   local absolute_path = vim.fn.expand("%:p")
--   local dir_path = vim.fn.fnamemodify(absolute_path, ":h")
--   local watch_image = Terminal:new({
--     cmd = "yazi",
--     hidden = true,
--     close_on_exit = true,
--     dir = dir_path,
--     direction = "vertical",
--     env = {
--       YAZI_CONFIG_HOME = "~/.config/yazi_for_neovim_image"
--     },
--     clear_env = true
--   })

--   watch_image:toggle()
-- end

-- map({ "n", "v", "t" }, "<C-\\><C-i>", "<Cmd>ToggleTerm dir=~/Download direction=vertical name=image<CR>")



-- vim.api.nvim_set_keymap("n", "<leader>G", "<cmd>lua _yes()<CR>", { noremap = true, silent = true })
