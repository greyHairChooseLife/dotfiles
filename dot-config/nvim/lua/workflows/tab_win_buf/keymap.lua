local map = vim.keymap.set
local opt = { noremap = true, silent = true }

---------------------------------------------------------------------------------------------------------------------------------- BUFFER
-- Navigation (next/prev)
map("n", "<Tab>", function()
	NavBuffAfterCleaning("next")
end, opt)
map("n", "<S-Tab>", function()
	NavBuffAfterCleaning("prev")
end, opt)
map("n", "<C-i>", "<C-i>", opt)
-- Quit
map("n", "<leader>Q", "<cmd>qa!<CR>")
map("n", "qq", "<cmd>q<CR>") -- 버퍼를 남겨둘 필요가 있는 경우가 오히려 더 적다. 희안하게 !를 붙이면 hidden이 아니라 active상태다.
map("n", "gq", ManageBuffer_gq)
map("n", "gQ", ManageBuffer_gQ)
map("n", "g<Tab>", BufferNextDropLast)
map("n", "gtq", ManageBuffer_gtq)
map("n", "gtQ", ManageBuffer_gtQ)
-- Save
map("n", "gw", function()
	vim.cmd("silent w")
	vim.notify("Saved current buffers", 3, { render = "minimal" })
end)
map("n", "gW", function()
	vim.cmd("wa")
	vim.notify("Saved all buffers", 3, { render = "minimal" })
end)
-- Save & Quit
map("n", "ge", ManageBuffer_ge)
map("n", "gE", ManageBuffer_gE)
-- Etc
map({ "n", "v" }, "<A-Enter><Space>", function()
	local utils = require("utils")
	local is_tree_visible = utils.tree:is_visible()

	CloseOtherBuffersInCurrentTab()

	if is_tree_visible then
		utils.tree:open()
	end
end)

---------------------------------------------------------------------------------------------------------------------------------- WINDOW
-- New ( horizontal / vertical )
map("n", "<A-x>", "<cmd>rightbelow new<CR>")
map("n", "<A-v>", "<cmd>vnew<CR>")
-- Navigation
map("n", "<A-h>", "<cmd>wincmd h<CR>")
map("n", "<A-j>", "<cmd>wincmd j<CR>")
map("n", "<A-k>", "<cmd>wincmd k<CR>")
map("n", "<A-l>", "<cmd>wincmd l<CR>")
map("n", "<A-space>", FocusFloatingWindow, opt)
-- Swap Position
map("n", "<A-H>", "<Cmd>WinShift left<CR>")
map("n", "<A-J>", "<Cmd>WinShift down<CR>")
map("n", "<A-K>", "<Cmd>WinShift up<CR>")
map("n", "<A-L>", "<Cmd>WinShift right<CR>")
-- Resize
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", {})
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", {})
map("n", "<A-Down>", "<cmd>horizontal resize -2<CR>", {})
map("n", "<A-Up>", "<cmd>horizontal resize +2<CR>", {})
map("n", "<A-S-Left>", "<cmd>vertical resize -8<CR>", {})
map("n", "<A-S-Right>", "<cmd>vertical resize +8<CR>", {})
map("n", "<A-S-Down>", "<cmd>horizontal resize -8<CR>", {})
map("n", "<A-S-Up>", "<cmd>horizontal resize +8<CR>", {})
-- Etc
map("n", ",sx", "<cmd>sp | wincmd w<CR>") -- go to definition in splitted window (horizontal)
map("n", ",sv", "<cmd>vs<CR>") -- go to definition in splitted window (vertical)
map("n", ",st", function() -- Copy window to new tab
	vim.cmd("split | wincmd T")
	local tabnr = vim.fn.tabpagenr()
	local filename = vim.fn.expand("%:t")
	if filename ~= "" then
		vim.fn.settabvar(tabnr, "tabname", " sp: " .. filename)
	end
end)
map("n", ",mt", function() -- move window to tab
	vim.cmd("wincmd T")
	local tabnr = vim.fn.tabpagenr()
	local filename = vim.fn.expand("%:t")
	if filename ~= "" then
		vim.fn.settabvar(tabnr, "tabname", " mv: " .. filename)
	end
end)

---------------------------------------------------------------------------------------------------------------------------------- TABS
-- New / Rename / Swap Position
map("n", "<A-t>", NewTabWithPrompt)
map("n", "<A-r>", RenameCurrentTab)
map("n", "<A-.>", MoveTabRight)
map("n", "<A-,>", MoveTabLeft)

-- Navigaion
map("n", "<A-p>", "<cmd>tabnext<CR>")
map("n", "<A-o>", "gT")
map("n", "<A-1>", "1gt")
map("n", "<A-2>", "2gt")
map("n", "<A-3>", "3gt")
map("n", "<A-4>", "4gt")
map("n", "<A-5>", "5gt")
map("n", "<A-6>", "6gt")
map("n", "<A-7>", "7gt")
map("n", "<A-8>", "8gt")
map("n", "<A-9>", "9gt")
-- Etc
map({ "n", "v" }, "<A-Enter>t", TabOnlyAndCloseHiddenBuffers)

-- DEPRECATED::, 2024-12-24 향후 문제 없으면 제거
-- map('n', 'gq', function()
--   if vim.fn.winnr('$') == 1 and vim.fn.tabpagenr('$') == 1 then vim.cmd('q')  -- 마지막 탭의 마지막 윈도우라면 걍 끄면 됨
--   elseif vim.fn.winnr('$') == 1 and vim.fn.tabpagenr('$') ~= 1 then
--     local bufnr = vim.fn.bufnr('%')
--     vim.cmd('q')
--     if vim.api.nvim_buf_is_valid(bufnr) then
--       vim.api.nvim_buf_delete(bufnr, { force = true })
--     end
--   elseif vim.fn.winnr('$') == 2 and require('nvim-tree.api').tree.is_visible() then
--     local bufnr = vim.fn.bufnr('%')
--     vim.cmd('q')
--     if vim.api.nvim_buf_is_valid(bufnr) then
--       vim.api.nvim_buf_delete(bufnr, { force = true })
--     end
--   else vim.cmd('bd!') end
-- end) -- close buffer, saving memory

-- DEPRECATED:: 2024-12-24 향후 문제 없으면 제거
-- map('n', 'ge', function()
--   vim.cmd('w')
--   -- 현재 윈도우가 마지막 윈도우라면 q로 종료
--   if vim.fn.winnr('$') == 1 then vim.cmd('q')
--   else vim.cmd('bd') end
--   vim.notify('Saved last buffers', 3, { render = 'minimal' })
-- end)

-- DEPRECATED:: 2024-12-24 향후 문제 없으면 제거
-- map('n', 'gtq', function()
--   -- 탭 이름이 'abcd' 라면
--   local tabname = GetCurrentTabName()
--   if tabname == ' Commit' or tabname == ' File' or tabname == 'GV' or tabname == 'Diff' then
--     vim.cmd('tabclose!')
--     return
--   end
--
--   -- 전체 탭의 개수가 1개라면 아무것도 하지 않고 종료
--   if vim.fn.tabpagenr('$') == 1 then
--     vim.notify('Cannot close the last tab page', 4, { render = 'minimal' })
--     return
--   end
--
--   -- 현재 탭의 모든 윈도우를 순회하며 버퍼를 닫음
--   -- local tabnr = vim.fn.tabpagenr()  -- 현재 탭 번호 가져오기
--   local tabid = vim.api.nvim_get_current_tabpage()  -- 탭 ID 가져오기
--   local wins = vim.api.nvim_tabpage_list_wins(tabid) -- 현재 탭의 윈도우 목록 가져오기, 인자로 받는 것은 탭 번호가 아니라 탭 ID
--
--   for _, win in ipairs(wins) do
--       local bufnr = vim.api.nvim_win_get_buf(win) -- 윈도우에 연결된 버퍼 번호 가져오기
--       vim.api.nvim_buf_delete(bufnr, { force = true }) -- 버퍼 삭제 (force 옵션으로 강제 종료)
--   end
-- end, opt)
