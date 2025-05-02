local utils = require("utils")

-- TODO::
-- 1. 종료 시 relativenumber 하이라이트가 바뀐다.
-- 2. 버퍼 또는 윈도우마다 별도의 상태를 가지는데, 이럼 안된다.
function ShareCursor()
	if vim.o.cursorline then
		vim.o.cursorline = false
		vim.o.cursorcolumn = false
		vim.o.relativenumber = false
	else
		vim.o.cursorline = true
		vim.o.cursorcolumn = true
		vim.o.relativenumber = true
		vim.cmd([[
      highlight CursorColumn guifg=white guibg=#AB82A5
      highlight CursorLine guifg=white guibg=#AB82A5
    ]])
	end
end
vim.cmd("command! ShareCursor lua ShareCursor()")

function HilightSearch()
	local text = utils.get_visual_text()
	if text and #text > 0 then
		vim.cmd("normal! bh")
		-- local pos = vim.api.nvim_win_get_cursor(0)
		-- vim.api.nvim_win_set_cursor(0, { pos[1] - 1, 1 })

		local keys = "/" .. text .. "\n"
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
	end
end

local function IsCursorOnEmptySpace()
	-- 현재 커서 위치 가져오기 (1-based index)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- 현재 줄 텍스트 가져오기
	local line = vim.api.nvim_get_current_line()
	-- 커서 위치의 문자 확인
	local char = line:sub(col + 1, col + 1) -- Lua는 1-based, col은 0-based
	return char == " " or char == ""
end

function ToggleHilightSearch()
	if vim.v.hlsearch == 1 then
		vim.cmd("nohlsearch | echon")
	else
		if not IsCursorOnEmptySpace() then
			vim.cmd("normal! viw")
			HilightSearch()
		end
	end
end

function BlinkCursorLine(duration)
	duration = duration or 50 -- 기본값 50ms
	vim.cmd("highlight CursorLine guibg=#2CB67D")
	vim.wo.cursorline = true
	vim.defer_fn(function()
		if vim.bo.filetype == "NvimTree" then
			vim.cmd("highlight CursorLine guibg=#242024")
		else
			vim.cmd("highlight CursorLine guibg=#242024")
			vim.wo.cursorline = false
		end
	end, duration)
end

function ReloadLayout(force)
	local _, restore = utils.get_window_preserver()

	if force then
		require("UI.modules.window_size").unfixAllWindows()
	end

	local win_count_curr_tab = #vim.api.nvim_tabpage_list_wins(0)
	local is_tree_open = require("utils").tree:is_visible()

	if win_count_curr_tab == 1 and is_tree_open then
		require("nvim-tree.api").tree.reload()
		return
	end

	-- 공통
	vim.cmd("wincmd = | echon")

	-- check nvim-tree
	if is_tree_open then
		NvimTreeResetUI()
	end

	if utils.is_filetype_open("aerial") then
		vim.cmd("AerialToggle")
		vim.cmd("AerialToggle")
	end

	restore()
end

function SearchWithBrowser()
	local selected = utils.get_visual_text()
	if selected == "" then
		print("No text selected!")
		return
	end

	local encoded_text = utils.url_encode(selected)
	local search_url = "--app=https://www.google.com/search?q=" .. encoded_text

	vim.fn.system("brave " .. search_url)

	-- 이런것도 가능하다. xdg-open으로 열기!
	-- vim.ui.open(search_url2)
end

function RemoveTrailingWhitespace()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd([[%s/\s\+$//e]])
	vim.api.nvim_win_set_cursor(0, pos)
end

function Insert_console_log()
	local log_message = "console.log();"
	local current_pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_put({ log_message }, "c", true, true)
	vim.api.nvim_win_set_cursor(0, { current_pos[1], current_pos[2] + #log_message - 2 })
end

function Insert_console_log_Visual()
	local file_path = vim.fn.expand("%:~:.") -- 상대경로
	local line_number = vim.fn.line(".")

	local selected_text = utils.get_visual_text()
	local log_message =
		string.format("console.log('At: %s: %d\\n', '%s: ', %s);", file_path, line_number, selected_text, selected_text)

	vim.api.nvim_put({ log_message }, "l", true, true)
	vim.api.nvim_input("k")
end

function UpdateCommandWindowHistory()
	vim.fn.histdel("cmd", -1)
	for i = 1, vim.fn.line("$") do
		local cmd = vim.fn.getline(i)
		if cmd ~= "" then -- 빈 줄은 무시
			vim.fn.histadd("cmd", cmd)
		end
	end
	print("Command-line history updated.")
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Shell command insdie Vim Buffer
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

---@class RunBufferOptions
---@field cover? boolean Whether to cover right-side window with result (default: false)
---@field selected? boolean Whether to run selected lines or full buffer (default: false)
---@field underline? boolean Whether to leave result under executed commands (default: false)
---@param opt? RunBufferOptions Table of options
function RunBufferWithSh(opt)
	require("utils").save_cursor_position()
	-- 옵션 기본값 설정
	opt = opt or {}
	local cover = opt.cover or false
	local selected = opt.selected or false
	local underline = opt.underline or false

	if selected and underline then
		local cmd = require("utils").get_visual_text()

		-- remove trailing newline char
		if cmd and #cmd > 0 and cmd:sub(-1) == "\n" then
			cmd = cmd:sub(1, -2)
		end
		vim.api.nvim_command(
			"silent! read !bash -ic "
				.. vim.fn.shellescape(cmd .. " | sed -r 's/\\x1B\\[[0-9;]*[mK]//g'")
				.. " 2>/dev/null"
		) -- interactive shell without Color
		return
	end

	--  임시 파일 생성
	local temp_file = vim.fn.tempname()

	if selected then
		vim.cmd("normal! gv")
		local start_line = vim.fn.line("'<")
		local end_line = vim.fn.line("'>")
		vim.api.nvim_command("silent! " .. start_line .. "," .. end_line .. "write! " .. temp_file)
	else
		vim.api.nvim_command("silent! write! " .. temp_file)
	end

	-- 현재 윈도우의 id와 우측 포커싱 후 id 확인
	local current_win = vim.api.nvim_get_current_win()
	vim.api.nvim_command("wincmd l")
	local new_win = vim.api.nvim_get_current_win()

	-- 포커스가 바뀌지 않았다면, 현재 우측 끝임
	if current_win == new_win then
		vim.api.nvim_command("vert belowright new")
	else
		vim.api.nvim_set_current_win(current_win)
		if cover then
			-- 우측 윈도우 덮어쓰기
			vim.api.nvim_command("wincmd l | wincmd 99j | %delete")
		else
			-- 우측에 새로운 윈도우
			vim.api.nvim_command("wincmd l | wincmd 99j | new")
		end
	end

	vim.api.nvim_command(
		[[r !date "+\%T" | awk '{line="=========================="; print line "\n===== time: " $1 " =====\n" line}']]
	)

	-- Read the file line by line and execute each line separately
	local lines = {}
	local f = io.open(temp_file, "r")
	if f then
		for line in f:lines() do
			table.insert(lines, line)
		end
		f:close()
	end

	for _, line in ipairs(lines) do
		if line:match("%S") then -- Skip empty lines
			vim.api.nvim_command("normal! o" .. line) -- Add the command
			vim.api.nvim_command(
				"silent! read !bash -ic "
					.. vim.fn.shellescape(line .. " | sed -r 's/\\x1B\\[[0-9;]*[mK]//g'")
					.. " 2>/dev/null"
			) -- Add the output
			vim.api.nvim_command("normal! o") -- Add an empty line for readability
		end
	end

	local line_count = vim.api.nvim_buf_line_count(0)
	-- Get current window height
	local current_height = vim.api.nvim_win_get_height(0)
	-- Set window height only if current height is smaller than needed
	if current_height < line_count + 5 then
		vim.api.nvim_win_set_height(0, line_count + 5)
	end

	vim.fn.delete(temp_file)
	require("utils").restore_cursor_position()
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Quickfix
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function QF_ToggleList() -- Quickfix list toggle 함수 정의
	-- Quickfix 창이 열려있는지 확인
	local is_open = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			is_open = true
			break
		end
	end

	if is_open then
		vim.cmd("cclose")
	else
		vim.cmd("copen | wincmd p")
	end
end

function QF_RemoveItem() -- Quickfix 항목 제거 함수 정의
	local curqfidx = vim.fn.line(".") - 1
	local qfall = vim.fn.getqflist()
	if #qfall == 1 then
		vim.fn.setqflist({}, "r")
		vim.api.nvim_command("cclose")
		vim.api.nvim_echo({ { "Good job, Quickfix list cleared!!", "MoreMsg" } }, false, {})
	else
		table.remove(qfall, curqfidx + 1) -- Lua에서 table 인덱스는 1부터 시작함에 주의
		vim.fn.setqflist(qfall, "r")
		if curqfidx < #qfall then
			vim.api.nvim_command(tostring(curqfidx) .. "cfirst")
		else
			vim.api.nvim_command(tostring(#qfall) .. "cfirst")
		end
		if #qfall == 0 then
			vim.api.nvim_command("cclose")
			vim.api.nvim_echo({ { "Quickfix list cleared", "MoreMsg" } }, false, {})
		else
			vim.api.nvim_command("copen")
		end
	end
end

function QF_ClearList() -- Quickfix list clear all 함수 정의
	vim.fn.setqflist({}, "r")
	vim.api.nvim_command("cclose")
	vim.api.nvim_echo({ { "Quickfix list cleared", "MoreMsg" } }, false, {})
end

function QF_MoveNext() -- Quickfix 리스트 순환 이동
	local qf_list = vim.fn.getqflist()
	if #qf_list == 0 then
		-- Notify("List is empty", 3, { title = "Quickfix" })
		return
	end -- Quickfix 리스트가 비어있는 경우 아무 동작도 하지 않음
	local qf_info = vim.fn.getqflist({ idx = 0 })
	local qf_index = qf_info.idx
	if qf_index == #qf_list then
		vim.cmd("cfirst")
	else
		vim.cmd("cnext")
	end
	vim.cmd("wincmd p")
end

function QF_MovePrev()
	local qf_list = vim.fn.getqflist()
	if #qf_list == 0 then
		-- Notify("List is empty", 3, { title = "Quickfix" })
		return
	end -- Quickfix 리스트가 비어있는 경우 아무 동작도 하지 않음
	local qf_info = vim.fn.getqflist({ idx = 0 })
	local qf_index = qf_info.idx
	if qf_index == 1 then
		vim.cmd("clast")
	else
		vim.cmd("cprev")
	end
	vim.cmd("wincmd p")
end

function QF_prev()
	-- if quickfix is empty, do nothing
	if #vim.fn.getqflist() == 0 then
		return
	end
	-- if first quickfix item, move to last
	if vim.fn.getqflist({ idx = 0 }).idx == 1 then
		vim.cmd("clast")
	else
		vim.cmd("cprev")
	end
end

function QF_next()
	-- if quickfix is empty, do nothing
	if #vim.fn.getqflist() == 0 then
		return
	end

	-- if last quickfix item, move to first
	if vim.fn.getqflist({ idx = 0 }).idx == #vim.fn.getqflist() then
		vim.cmd("cfirst")
	else
		vim.cmd("cnext")
	end
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- 검색 결과가 존재하는지 확인하여, 없더라도 에러가 발생하지 않도록 한다.
function Safe_search(direction)
	local prev_cursor = vim.api.nvim_win_get_cursor(0) -- 현재 커서 위치 저장
	local success, _ = pcall(function()
		vim.cmd("normal! " .. direction)
	end) -- 검색 실행

	if success then
		vim.cmd("normal! zz") -- 화면 중앙 정렬
		-- vim.cmd("match Search /\\%#\\zs\\k\\+/") -- 검색 결과 강조
		-- vim.defer_fn(function()
		-- 	vim.cmd("match none")
		-- end, 300) -- 0.3초 후 강조 해제
	else
		vim.api.nvim_win_set_cursor(0, prev_cursor) -- 실패 시 커서 원위치
	end
end

---Format the selected JSON text using the 'jq' command line tool
---Replaces the current visual selection with properly formatted JSON
---
---Requirements:
--- - 'jq' must be installed on the system
--- - Text must be selected in visual mode
--- - Selected text must be valid JSON
---
---@return nil
---@error Will show error notification if JSON is invalid or jq fails
function Format_json_with_jq()
	-- Save the selected text to a temporary file
	local temp_name = vim.fn.tempname()
	vim.cmd("'<,'>write !jq '.' >" .. temp_name)

	-- Replace the selected text with the formatted JSON
	vim.cmd("'<,'>read " .. temp_name)
	vim.cmd("'<,'>delete")
	vim.fn.delete(temp_name)
end
