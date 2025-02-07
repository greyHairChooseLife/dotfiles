local utils = require("utils")

function NavBuffAfterCleaning(direction)
	utils.close_empty_unnamed_buffers()
	vim.cmd(direction == "prev" and "bprev" or "bnext")

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname:find("Term: ") then
		vim.cmd(direction == "prev" and "bprev" or "bnext")
	end

	local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
	-- "Term: "으로 시작하는 버퍼를 제거
	local filtered_buffers = vim.tbl_filter(function(buf)
		return not string.find(buf.name, "Term:")
	end, listed_buffers)

	local current_bufnr = vim.fn.bufnr()
	local current_buf_index

	for i, buf in ipairs(filtered_buffers) do
		if buf.bufnr == current_bufnr then
			current_buf_index = i
			break
		end
	end

	utils.print_in_time("  Buffers .. [" .. current_buf_index .. "/" .. #filtered_buffers .. "]", 2)
end

function ManageBuffer_gq()
	local bufnr = vim.fn.bufnr("%")
	vim.cmd("q!")

	if
		not utils.is_buffer_active_somewhere(bufnr)
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].filetype ~= "help"
		and vim.fn.bufname(bufnr) ~= ""
	then
		vim.cmd.bdelete(bufnr)
	end
end

function CloseOtherBuffersInCurrentTab()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local windows = vim.api.nvim_tabpage_list_wins(current_tab)

	-- 현재 탭의 다른 윈도우 닫기
	for _, win in ipairs(windows) do
		if vim.api.nvim_win_get_buf(win) ~= current_buf then
			vim.api.nvim_win_close(win, true)
		end
	end

	-- 히든 버퍼 중 다른 탭에서 사용되지 않는 버퍼 삭제
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf then
			-- 다른 탭에서 열려있는지 확인
			local is_open_elsewhere = false
			for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
				if tab ~= current_tab then
					local tab_wins = vim.api.nvim_tabpage_list_wins(tab)
					for _, tw in ipairs(tab_wins) do
						if vim.api.nvim_win_get_buf(tw) == buf then
							is_open_elsewhere = true
							break
						end
					end
				end
				if is_open_elsewhere then
					break
				end
			end

			-- 다른 탭에서 사용되지 않는 히든 버퍼 삭제
			if not is_open_elsewhere and vim.fn.bufwinnr(buf) == -1 then
				local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
				if filetype ~= "VoltWindow" then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end
	end

	vim.api.nvim_command("only")
end

function TabOnlyAndCloseHiddenBuffers()
	vim.cmd("TTimerlyToggle")
	-- 현재 탭에서 열린 버퍼 번호들을 저장
	local open_buffers = {}
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		open_buffers[buf] = true
	end

	-- 모든 버퍼를 순회하며, 열린 버퍼에 포함되지 않은(hidden 상태인) 버퍼를 닫기
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not open_buffers[buf] and vim.api.nvim_buf_is_loaded(buf) then
			local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
			if filetype ~= "VoltWindow" then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end

	print("tab only, wipe invisible buffers")
	vim.cmd("silent tabonly")
end

function BufferNextDropLast()
	local last_buf = vim.api.nvim_get_current_buf()
	local listed_buffers = vim.fn.getbufinfo({ buflisted = true })

	-- "Term: "으로 시작하는 버퍼를 제거
	local filtered_buffers = vim.tbl_filter(function(buf)
		return not string.find(buf.name, "Term:")
	end, listed_buffers)

	-- hidden 버퍼만 필터링
	local hidden_bufs = {}

	for _, buf in ipairs(filtered_buffers) do
		if buf.hidden == 1 then
			table.insert(hidden_bufs, buf.bufnr)
		end
	end

	-- 테이블에 요소가 1개 이상이라면, 다음 버퍼로 0번째 버퍼로 이동
	if #hidden_bufs > 0 then
		vim.api.nvim_set_current_buf(hidden_bufs[1])
	end

	-- 어쨋든 최근 버퍼는 닫는다.
	vim.cmd("bd " .. last_buf)
end

function ManageBuffer_ge()
	vim.cmd("w") -- 일단 저장

	ManageBuffer_gq()

	vim.notify("Saved last buffers", 3, { render = "minimal" })
end

function ManageBuffer_gtq()
	-- 예외처리: 특수 탭
	local tabname = utils.get_current_tabname()
	if tabname == " Commit" or tabname == " File" or tabname == "GV" or tabname == "Diff" then
		vim.cmd("tabclose!")
		return
	end

	-- 예외처리: 전체 탭의 개수가 1개
	if vim.fn.tabpagenr("$") == 1 then
		vim.notify("Cannot close the last tab page", 4, { render = "minimal" })
		return
	end

	-- 현재 탭의 모든 윈도우 순회하며 조건에 맞을 때 종료(조건: is_buffer_active_somewhere)
	local tabid = vim.api.nvim_get_current_tabpage() -- 탭 ID 가져오기
	local wins = vim.api.nvim_tabpage_list_wins(tabid) -- 현재 탭의 윈도우 목록 가져오기, 인자로 받는 것은 탭 번호가 아니라 탭 ID
	for _, win in ipairs(wins) do
		if vim.bo.filetype == "NvimTree" then
			vim.cmd("q")
		elseif vim.api.nvim_win_is_valid(win) then
			local bufnr = vim.api.nvim_win_get_buf(win) -- 윈도우에 연결된 버퍼 번호 가져오기
			vim.cmd("q") -- 일단 꺼
			if not utils.is_buffer_active_somewhere(bufnr) then -- 다른데 활성화(눈에 보이게) 되어있지 않은것만 꺼
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
		end
	end
end

function ManageBuffer_gQ() -- loaded buffer를 모두 닫는다.
	local bufnr = vim.fn.bufnr("%")

	vim.cmd("q")

	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true }) -- bwipeout
	end
end

function ManageBuffer_gE() -- 저장 후, loaded buffer를 모두 닫는다.
	vim.cmd("w")

	ManageBuffer_gQ()
	vim.notify("Saved last buffers", 3, { render = "minimal" })
end

function ManageBuffer_gtQ()
	vim.notify("그간의 경험을 돌아보면 딱히 쓴 일, 쓸 일이 없는데?", 1, { render = "minimal" })
end

function FocusFloatingWindow()
	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		local config = vim.api.nvim_win_get_config(win)
		if config.focusable and config.relative ~= "" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
end

function NewTabWithPrompt()
	-- 입력 프롬프트 표시
	local tabname = vim.fn.input("Enter tab name: ")
	if tabname == "" then
		-- tabname = 'Tab ' .. vim.fn.tabpagenr('$') + 1
		-- 입력이 없거나 ESC를 누른 경우, 함수 종료
		return
	end
	-- 새로운 탭 생성 및 이름 설정
	vim.cmd("tabnew")
	local tabnr = vim.fn.tabpagenr()
	vim.fn.settabvar(tabnr, "tabname", tabname)
end

-- TODO:
-- 	아래처럼 살펴보면 tabname이란 variable로 잘 등록되어 있다. 그러나 표시가 안된다. 이부분 개선 필요.
--	lua print(vim.inspect(vim.fn.gettabinfo(<tabnr>)))
function RenameCurrentTab()
	-- 현재 탭 번호를 가져옵니다
	local tabnr = vim.fn.tabpagenr()

	-- 입력 프롬프트를 표시하여 새 탭 이름을 입력받습니다
	local tabname = vim.fn.input("Enter new tab name: ")
	if tabname == "" then
		-- tabname = 'Tab ' .. tabnr
		-- 입력이 없거나 ESC를 누른 경우, 함수 종료
		return
	end

	-- 현재 탭의 이름을 설정합니다
	vim.fn.settabvar(tabnr, "tabname", tabname)
	-- 탭라인을 업데이트합니다
	vim.cmd("redrawtabline")
end

function MoveTabLeft()
	local current_tab = vim.fn.tabpagenr()
	if current_tab == 1 then
		vim.cmd("tabmove $")
	elseif current_tab > 1 then
		vim.cmd("tabmove " .. (current_tab - 2))
	end
end

function MoveTabRight()
	local current_tab = vim.fn.tabpagenr()
	local total_tabs = vim.fn.tabpagenr("$")
	if current_tab < total_tabs then
		vim.cmd("tabmove " .. current_tab + 1)
	else
		vim.cmd("tabmove 0")
	end
end

function SplitTabModifyTabname()
	vim.cmd("split | wincmd T")
	local tabnr = vim.fn.tabpagenr()
	local filename = vim.fn.expand("%:t")
	if filename ~= "" then
		vim.fn.settabvar(tabnr, "tabname", " sp: " .. filename)
	end
end

function MoveTabModifyTabname()
	vim.cmd("wincmd T")
	local tabnr = vim.fn.tabpagenr()
	local filename = vim.fn.expand("%:t")
	if filename ~= "" then
		vim.fn.settabvar(tabnr, "tabname", " mv: " .. filename)
	end
end
