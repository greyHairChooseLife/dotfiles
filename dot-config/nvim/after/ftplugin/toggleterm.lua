local map = vim.keymap.set
local opt = { buffer = true, silent = true }

-- keymap
map("t", "<esc>", [[<C-\><C-n>]], opt)
-- NEW WINDOW & TAB
map("t", "<A-s>", "<Cmd>rightbelow new<CR>", opt)
map("t", "<A-v>", "<Cmd>vnew<CR>", opt)
map("t", "<A-t>", NewTabWithPrompt, opt)
map("t", "<A-r>", RenameCurrentTab, opt)
map("t", "<A-S-p>", MoveTabRight, opt)
map("t", "<A-S-o>", MoveTabLeft, opt)
-- FOCUS TABS
map("t", "<A-p>", [[<C-\><C-n>gt]], { noremap = true, silent = true, buffer = true })
map("t", "<A-o>", [[<C-\><C-n>gT]], { noremap = true, silent = true, buffer = true })
for i = 1, 9 do
    -- 숫자에 따른 탭 이동 (1gt, 2gt, ..., 9gt)
    map("t", "<A-" .. i .. ">", [[<C-\><C-n>]] .. i .. [[gt]], { noremap = true, silent = true })
end
-- FOCUS WINDOW
map("t", "<A-h>", "<Cmd>wincmd h<CR>", opt)
map("t", "<A-j>", "<Cmd>wincmd j<CR>", opt)
map("t", "<A-k>", "<Cmd>wincmd k<CR>", opt)
map("t", "<A-l>", "<Cmd>wincmd l<CR>", opt)
-- MOVE WINDOW PtSITION
map("t", "<A-H>", "<Cmd>WinShift left<CR>", opt)
map("t", "<A-J>", "<Cmd>WinShift down<CR>", opt)
map("t", "<A-K>", "<Cmd>WinShift up<CR>", opt)
map("t", "<A-L>", "<Cmd>WinShift right<CR>", opt)
map("t", ",mt", "<C-w>T", opt) -- move window to tab
map("t", ",st", "<Cmd>sp<CR><C-w>T", opt) -- copy window to tab
-- WINDOW RESIZEt
map("t", "<A-Left>", "<Cmd>vertical resize -2<CR>", opt)
map("t", "<A-Right>", "<Cmd>vertical resize +2<CR>", opt)
map("t", "<A-Down>", "<Cmd>horizontal resize -2<CR>", opt)
map("t", "<A-Up>", "<Cmd>horizontal resize +2<CR>", opt)
-- WINDOW RESIZEtHARD
map("t", "<A-S-Left>", "<Cmd>vertical resize -8<CR>", opt)
map("t", "<A-S-Right>", "<Cmd>vertical resize +8<CR>", opt)
map("t", "<A-S-Down>", "<Cmd>horizontal resize -8<CR>", opt)
map("t", "<A-S-Up>", "<Cmd>horizontal resize +8<CR>", opt)
