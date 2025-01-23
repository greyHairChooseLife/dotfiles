-- MEMO:: 이벤트 종류는 doc에서 아래를 검색하면 나온다.
-- 5. Events					*autocmd-events* *E215* *E216*

local utils = require("utils")

-- Autocommand 그룹 생성 (중복 방지)
local float_win_group = vim.api.nvim_create_augroup("FloatWinSettings", { clear = true })

-- WinEnter 이벤트에 대한 Autocommand 생성
vim.api.nvim_create_autocmd("WinEnter", {
	group = float_win_group,
	callback = function()
		local win = vim.api.nvim_get_current_win()
		local config = vim.api.nvim_win_get_config(win)

		-- 플로팅 윈도우는 'relative' 필드가 비어있지 않음
		if config.relative ~= "" then
			-- 플로팅 윈도우에만 적용할 키맵 설정
			if vim.bo.filetype ~= "VoltWindow" then
				vim.keymap.set({ "n", "v" }, "gq", "<cmd>quit<CR>", { buffer = true, silent = true })
			end

		-- 추가 옵션 설정 (예: 텍스트 너비 조정)
		-- vim.bo.textwidth = 80
		else
			-- 플로팅 윈도우가 아닐 경우, 필요하다면 키맵을 제거하거나 기본 설정으로 복원
			--
			-- 예: 특정 키맵을 해제
			-- vim.keymap.del('n', 'PP', { buffer = true })
			-- vim.keymap.del('v', 'i', { buffer = true })
			-- vim.keymap.del('v', 'a', { buffer = true })

			-- 추가 옵션 복원
			-- vim.bo.textwidth = 0
		end
	end,
})

local Cursor = {
	show = function()
		vim.cmd("hi Cursor blend=0")
		vim.cmd("set guicursor-=a:Cursor/lCursor")
	end,

	hide = function()
		vim.cmd("hi Cursor blend=100")
		vim.cmd("set guicursor+=a:Cursor/lCursor")
	end,
}

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		if vim.bo.filetype == "NvimTree" then
			local api = require("nvim-tree.api")
			local view = require("nvim-tree.view")

			-- gui
			if not view.is_visible() then
				api.tree.open()
			end

			Cursor.hide()
		end

		if vim.bo.filetype == "Avante" then
			vim.cmd("stopinsert")
			vim.opt.signcolumn = "yes"
		end

		if vim.bo.filetype == "AvanteInput" then
			-- vim.cmd("stopinsert")
			vim.opt.wrap = true
			vim.defer_fn(function()
				-- os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
			end, 200) -- 약간의 딜레이가 필요하다. 왜냐면 내가 <A-hjkl>로 이동할 때 Alt키를 약간 느리게 떼는 경향이 있는데, 그럼 <A-Esc>가 되어버린다. 그래서 Alt키에서 손을 뗄 때까지 약간의 시간을 기다리는 딜레이를 준다.
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufLeave" }, {
	callback = function()
		if vim.bo.filetype == "NvimTree" then
			Cursor.show()
		end
	end,
})

vim.api.nvim_create_autocmd("TabNew", {
	callback = function()
		-- tabname이 커스텀 되는 것도 시간이 걸리기 떄문에, 약간의 딜레이를 줘야한다.
		vim.defer_fn(function()
			local tabname = utils.get_current_tabname()
			if tabname == " Commit" or tabname == " File" then
				vim.cmd("IBLDisable")
				-- DEPRECATED:: 2024-12-28
				-- vim.cmd('silent CocDisable')
			end
		end, 50)
	end,
})

vim.api.nvim_create_autocmd("TabEnter", {
	callback = function()
		require("nvim-tree.api").tree.reload() -- open된 buffer를 찾는 부분이 업데이트가 늦다. 탭 옮길때 갱신하면 잘 됨.
		local tabname = utils.get_current_tabname()
		if tabname == " Commit" or tabname == " File" then
			vim.cmd("IBLDisable")
			-- DEPRECATED:: 2024-12-28
			-- vim.cmd('silent CocDisable')
		end
	end,
})

vim.api.nvim_create_autocmd("TabLeave", {
	callback = function()
		local tabname = utils.get_current_tabname()
		if tabname == " Commit" or tabname == " File" then
			vim.cmd("IBLEnable")
			-- DEPRECATED:: 2024-12-28
			-- vim.cmd('silent CocEnable')
		end
	end,
})

vim.api.nvim_create_autocmd("TabClosed", {
	callback = function()
		vim.cmd("tabprev")
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		vim.cmd("normal! zR")
		vim.cmd("silent! loadview")

		-- 마지막 커서 위치로 이동
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		if mark[1] > 0 and mark[1] <= vim.fn.line("$") then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})

-- highlight yanked area
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "Sneak", timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		-- 예외 규정
		if vim.bo.filetype ~= "markdown" then
			RemoveTrailingWhitespace() -- 파일 저장시 공백 제거
		end

		require("utils").auto_mkdir()
	end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		-- -- 명령줄 입력 시에만 활성화
		-- GUI
		-- vim.opt.cmdheight = 1
		Cursor.show()

		-- KEYMAP
		vim.api.nvim_set_keymap(
			"c",
			"<Esc>",
			[[<C-u><Cmd>lua vim.fn.histdel("cmd", 0)<CR><Esc><Cmd>echon<CR>]],
			{ noremap = true, silent = true }
		) -- 실행하지 않은 명령은 cmd history에 기록 안됨
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		-- -- 명령줄 입력 시에만 활성화
		-- GUI
		-- vim.opt.cmdheight = 0
		vim.schedule(function()
			-- 이 시점에서는 일반 모드로 전환이 완료되어 버퍼/윈도우 관련 API를 안전하게 사용할 수 있음
			if vim.bo.filetype == "NvimTree" then
				Cursor.hide()
			end
		end)
	end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		vim.api.nvim_set_hl(0, "CmdlineWindowBG", { bg = "#0d0d0d" })
		vim.api.nvim_set_hl(0, "CmdlineWindowFG", { fg = "#0d0d0d" })
		vim.wo.winhighlight = "Normal:CmdlineWindowBG,EndOfBuffer:CmdlineWindowFG,SignColumn:CmdlineWindowBG"
		vim.wo.relativenumber = false
		vim.wo.number = false
		vim.o.laststatus = 0
		vim.o.cmdheight = 0

		vim.cmd("resize 20 | normal zb")

		-- KEYMAP
		local opts = { buffer = true }
		vim.keymap.set("n", "gq", "<Cmd>q<CR>", opts)
		vim.keymap.set("n", "gw", UpdateCommandWindowHistory, opts)
		vim.keymap.set("n", "ge", function()
			UpdateCommandWindowHistory()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("CmdwinLeave", {
	callback = function()
		-- vim.api.nvim_del_augroup_by_name("CmdwinEnter_GUI_KEYMAP")

		-- DEPRECATED:: 2025-01-24
		-- Noice.nvim 이후로 주석처리
		-- vim.o.cmdheight = 1

		vim.o.laststatus = 2
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		-- init with insert mode
		vim.cmd("startinsert")

		-- gui
		vim.api.nvim_set_hl(0, "TermBufferHighlight", { bg = "#0c0c0c" })
		vim.api.nvim_set_hl(0, "TermBufferEOB", { fg = "#0c0c0c" })
		vim.cmd(
			"setlocal winhighlight=Normal:TermBufferHighlight,SignColumn:TermBufferHighlight,EndOfBuffer:TermBufferEOB"
		)
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"

		-- keymap
		vim.keymap.set("n", "gq", "<Cmd>q<CR>", { buffer = true }) -- 버퍼는 종료하지 않는다. (e)xit으로 종료할 수 있다.
		vim.keymap.set("n", "cc", [[i<C-u>]], { buffer = true })
		-- NEW WINDOW & TAB
		vim.keymap.set("t", "<A-x>", "<Cmd>rightbelow new<CR>", { buffer = true })
		vim.keymap.set("t", "<A-v>", "<Cmd>vnew<CR>", { buffer = true })
		vim.keymap.set("t", "<A-t>", NewTabWithPrompt, { buffer = true })
		vim.keymap.set("t", "<A-r>", RenameCurrentTab, { buffer = true })
		vim.keymap.set("t", "<A-.>", MoveTabRight, { buffer = true })
		vim.keymap.set("t", "<A-,>", MoveTabLeft, { buffer = true })
		-- FOCUS TABS
		vim.keymap.set("t", "<A-p>", [[<C-\><C-n>gt]], { noremap = true, silent = true, buffer = true })
		vim.keymap.set("t", "<A-o>", [[<C-\><C-n>gT]], { noremap = true, silent = true, buffer = true })
		for i = 1, 9 do
			-- 숫자에 따른 탭 이동 (1gt, 2gt, ..., 9gt)
			vim.keymap.set("t", "<A-" .. i .. ">", [[<C-\><C-n>]] .. i .. [[gt]], { noremap = true, silent = true })
		end
		-- FOCUS WINDOW
		vim.keymap.set("t", "<A-h>", "<Cmd>wincmd h<CR>", { buffer = true })
		vim.keymap.set("t", "<A-j>", "<Cmd>wincmd j<CR>", { buffer = true })
		vim.keymap.set("t", "<A-k>", "<Cmd>wincmd k<CR>", { buffer = true })
		vim.keymap.set("t", "<A-l>", "<Cmd>wincmd l<CR>", { buffer = true })
		-- MOVE WINDOW PtSITION
		vim.keymap.set("t", "<A-H>", "<Cmd>WinShift left<CR>", { buffer = true })
		vim.keymap.set("t", "<A-J>", "<Cmd>WinShift down<CR>", { buffer = true })
		vim.keymap.set("t", "<A-K>", "<Cmd>WinShift up<CR>", { buffer = true })
		vim.keymap.set("t", "<A-L>", "<Cmd>WinShift right<CR>", { buffer = true })
		vim.keymap.set("t", ",mt", "<C-w>T", { buffer = true }) -- move window to tab
		vim.keymap.set("t", ",st", "<Cmd>sp<CR><C-w>T", { buffer = true }) -- copy window to tab
		-- WINDOW RESIZEt
		vim.keymap.set("t", "<A-Left>", "<Cmd>vertical resize -2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Right>", "<Cmd>vertical resize +2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Down>", "<Cmd>horizontal resize -2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Up>", "<Cmd>horizontal resize +2<CR>", { buffer = true })
		-- WINDOW RESIZEtHARD
		vim.keymap.set("t", "<A-S-Left>", "<Cmd>vertical resize -8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Right>", "<Cmd>vertical resize +8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Down>", "<Cmd>horizontal resize -8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Up>", "<Cmd>horizontal resize +8<CR>", { buffer = true })
	end,
})

-- TODO: 이거 왜 설정한거지? 찾아서 정리 해두기
-- REMOVE KEYMAP FROM NO-WHERE
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		pcall(vim.keymap.del, "i", "<C-G>s")
		pcall(vim.keymap.del, "i", "<C-G>S")
	end,
})
