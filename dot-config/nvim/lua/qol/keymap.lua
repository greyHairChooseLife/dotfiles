local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: 이거 없으면 일부 터미널에서 한글 입력시 문제가 발생한다.
-- (의도) "저는 오늘 저녁으로 김치를 먹었습니다."
-- (결과) "저 는오 늘저녁으 로김치 를먹었습니다."
map("i", "<Space>", function()
	-- TODO:: 이거 input-method가 한글로 설정된 경우로 한정할 수 있겠다. 그럼 nerd-dictation같은거 잘 될듯
	vim.defer_fn(function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Space>", true, false, true), "n", true)
	end, 20)
end, opt)

map("n", "`g", "<cmd>wincmd p<CR>") -- focus previous window & cursor position
map("v", "p", '"_dP') -- paste without yanking in visual mode
-- map("v", "x", '"_d') -- delete without yanking in visual mode
map("v", "<leader>s", SearchWithBrowser, opt)

-- 앞글자 대문자로 변환
map({ "n", "v" }, "gu", function()
	require("utils").save_cursor_position()
	vim.cmd("normal! lbvU")
	require("utils").restore_cursor_position()
end) -- CamelCase

map({ "n", "v" }, ";", ":")
map({ "n", "v" }, ":", ";")
map({ "n", "v" }, "Q", ",")

map({ "n", "v" }, "zo", "za") -- toggle fold uni-key
map({ "n", "v" }, "zz", "zz5<C-e>") -- toggle fold uni-key
map({ "n", "v" }, "zZ", "zz", { noremap = true }) -- toggle fold uni-key
map({ "n", "v" }, "gH", "0") -- move cursor
map({ "n", "v" }, "gh", "^") -- move cursor
map({ "n", "v" }, "gl", "$") -- move cursor
map({ "n", "v" }, "gL", "$") -- move cursor
map("n", "'", ToggleHilightSearch)
map("v", "'", HilightSearch)
map("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
map("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

map("n", "vv", "viw") -- easy visual block for word
map("v", "v", "<Esc>")

map({ "n", "v", "i", "c" }, "<leader>t", "<cmd>TTimerlyToggle<cr>")

map({ "n", "v" }, "<C-q>", "<Cmd>Focus<CR>")
map("v", ",<Space>", ":FocusHere<CR>", opt)
map("n", ",<Space>", "<cmd>FocusClear<CR>", opt)
map("n", "<Space><Space>", function()
	vim.cmd("NoiceDismiss")
	BlinkCursorLine()
end)
map("n", "yp", function()
	local absolute_path = vim.fn.expand("%:p")
	vim.fn.setreg("+", absolute_path)
	vim.notify("Copied path: " .. absolute_path, vim.log.levels.INFO)
end)

map("i", "cc<Enter>", function()
	vim.api.nvim_input("<Esc>cc")
end)
map("i", "zz", function()
	vim.api.nvim_input("<Esc>zza")
end)

-- TODO: <esc> 시뮬레이션 방법을 통일(검증 필요)하고, 함수로 만들어 재사용하자.
-- Easy Escape
map({ "i", "c" }, ";j<Space>", function()
	vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, "gq", function()
	vim.api.nvim_input("<C-c>") -- cmdwin에서는 <Esc>로 동작하도록
end, { noremap = true })
map({ "i", "c" }, ";ㅓ<Space>", function()
	vim.api.nvim_input("<Esc>") -- 실제 <Esc> 입력을 강제 실행
	os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
end, { noremap = true })
map("n", "ㅗ", function()
	os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
	vim.api.nvim_input("h")
end, opt)
map("n", "ㅓ", function()
	os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
	vim.api.nvim_input("j")
end, opt)
map("n", "ㅏ", function()
	os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
	vim.api.nvim_input("k")
end, opt)
map("n", "ㅣ", function()
	os.execute("xdotool key Escape") -- 영어 입력 모드로 전환 (kime에 ESC 입력 보내기), keyboard layout to English
	vim.api.nvim_input("l")
end, opt)

map({ "n", "v" }, "<C-e>", "2<C-e>")
map({ "n", "v" }, "<C-y>", "2<C-y>")
map("n", ",.<ESC>", "<Nop>") -- do nothing

-- 선택한 줄 이동
-- TODO:: commandline 자꾸 깜빡이는게 거슬려
map("x", "<A-k>", ":move '<-2<CR>gv-gv")
map("x", "<A-j>", ":move '>+1<CR>gv-gv")
map("v", "<A-h>", "<gv")
map("v", "<A-l>", ">gv")

-- snippet
map("i", "cl<cr>", Insert_console_log, opt)
map("v", "cl<cr>", Insert_console_log_Visual, opt)

-- FOLD는 항상  mkview
map("n", "zc", "zc<cmd>mkview<CR>")
map("n", "zo", "zo<cmd>mkview<CR>")
map("n", "zO", "zO<cmd>mkview<CR>")
map("n", "zm", "zm<cmd>mkview<CR>")
map("n", "zM", "zM<cmd>mkview<CR>")
map("n", "zr", "zr<cmd>mkview<CR>")
map("n", "zR", "zR<cmd>mkview<CR>")
map("n", "zf", "zf<cmd>mkview<CR>")
map("n", "zd", "zd<cmd>mkview<CR>")

-- TODO: tmux랑 겹친다. 새로운 keymap 또는 접근법을 찾아야한다.
-- FOLD MOVE
-- map({ "n", "v" }, "<C-j>", "zjw")
-- map({ "n", "v" }, "<C-k>", "zkw")
-- map({ "n", "v" }, "<C-h>", "[zw")
-- map({ "n", "v" }, "<C-l>", "]zw")
-- map({ "n", "v" }, "<C-n>", "%][%zz")
-- map({ "n", "v" }, "<C-p>", "[]%zz")

map("n", "n", function()
	Safe_search("n")
end, opt)
map("n", "N", function()
	Safe_search("N")
end, opt)

-- { 중괄호 }로 묶인 영역 통째로 복사
map("n", "yY", "va{Vy", opt)

map({ "n", "v" }, "<leader><leader>s", function()
	local mode = vim.fn.mode()
	if mode == "n" then
		require("utils").save_cursor_position()
		vim.api.nvim_feedkeys("vip", "n", true)
		require("utils").restore_cursor_position()
		vim.cmd("TTS")
	else
		vim.cmd("TTS")
	end
end, opt)

-- MEMO:: Session
wk_map({
	["<leader>s"] = {
		group = "󱫥  Session",
		order = { "s", "l" },
		["s"] = { "<cmd>SessionSave<CR>", desc = "save", mode = "n" },
		["v"] = {
			function()
				vim.cmd("SessionSearch")
				vim.fn.feedkeys("!json ", "m") -- json 파일에 탭 이름 정보 저장해둠
			end,
			desc = "view",
			mode = "n",
		},
	},
})

-- MEMO:: Run Command
wk_map({
	["<leader>r"] = {
		group = "  Run Command",
		order = { "r", "R", "u" },
		["u"] = {
			function()
				RunBufferWithSh({ selected = true, underline = true })
			end,
			desc = "underline",
			mode = "v",
		},
		["r"] = {
			function()
				local mode = vim.api.nvim_get_mode().mode
				if mode == "n" then
					RunBufferWithSh()
				else
					RunBufferWithSh({ selected = true })
				end
			end,
			desc = "run on buffer",
			mode = { "n", "v" },
		},
		["R"] = {
			function()
				local mode = vim.api.nvim_get_mode().mode
				if mode == "n" then
					RunBufferWithSh({ cover = true })
				else
					RunBufferWithSh({ selected = true, cover = true })
				end
			end,
			desc = "run on buffer and cover ",
			mode = { "n", "v" },
		},
	},
})

-- MEMO:: QuickFix
wk_map({
	["<Space>q"] = {
		group = "Quick Fix",
		order = { "f", "t", "n", "p" },
		["f"] = { "<cmd>copen<CR>", desc = "focus", mode = "n" },
		["t"] = { QF_ToggleList, desc = "toggle", mode = "n" },
		["n"] = { QF_next, desc = "next", mode = "n" },
		["p"] = { QF_prev, desc = "prev", mode = "n" },
	},
})
vim.keymap.set("n", "qn", QF_next)
vim.keymap.set("n", "qp", QF_prev)

-- MEMO:: Etc
wk_map({
	[","] = {
		order = { "r", "R", "C" },
		["r"] = { ReloadLayout, desc = "reload layout", mode = "n" },
		["R"] = {
			function()
				ReloadLayout(true)
			end,
			desc = "reload layout force",
			mode = "n",
		},
		["C"] = {
			function()
				local word = vim.fn.expand("<cword>")
				vim.api.nvim_feedkeys(":%s/" .. word .. "//g", "n", false)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true), "n", false)
			end,
			desc = "change",
			mode = "n",
		},
	},
})
