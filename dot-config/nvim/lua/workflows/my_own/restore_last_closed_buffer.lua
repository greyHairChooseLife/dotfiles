-- 최근 닫힌 버퍼들의 스택 (최대 10개 저장)
local closed_buffers_stack = {}
local MAX_HISTORY = 10

-- 버퍼가 닫힐 때 실행되는 함수
local function save_closed_buffer(event)
	-- 닫히는 버퍼의 ID를 이벤트에서 가져옴
	local buf = event.buf

	-- 닫히는 버퍼의 정보 수집
	local bufname = vim.api.nvim_buf_get_name(buf)
	local buftype = vim.bo[buf].buftype

	-- 정상적인 파일 버퍼만 저장 (빈 이름이 아니고 일반 버퍼 타입일 때)
	if bufname ~= "" and buftype == "" then
		-- 실제 파일이 존재하는지 확인
		if vim.fn.filereadable(bufname) == 1 then
			-- 스택에 동일한 버퍼가 있으면 제거 (중복 방지)
			for i, path in ipairs(closed_buffers_stack) do
				if path == bufname then
					table.remove(closed_buffers_stack, i)
					break
				end
			end

			-- 스택 맨 앞에 추가
			table.insert(closed_buffers_stack, 1, bufname)

			-- 최대 저장 개수 유지
			if #closed_buffers_stack > MAX_HISTORY then
				table.remove(closed_buffers_stack)
			end
		end
	end
end

-- 마지막으로 닫힌 버퍼를 복원하는 함수
local function restore_last_closed_buffer()
	if #closed_buffers_stack > 0 then
		local last_buffer = closed_buffers_stack[1]

		-- 안전하게 명령 실행
		local status, error = pcall(function()
			vim.cmd("vnew " .. vim.fn.fnameescape(last_buffer))
		end)

		if status then
			-- 첫 번째 항목 제거 (복원 후)
			table.remove(closed_buffers_stack, 1)

			-- 레이아웃 재설정 함수가 존재하는지 확인 후 실행
			if #vim.api.nvim_list_wins() == 2 and type(_G.ReloadLayout) == "function" then
				_G.ReloadLayout()
			end
		else
			vim.notify("버퍼 복원 실패: " .. error, vim.log.levels.ERROR)
		end
	else
		vim.notify("🚫 복원할 버퍼 기록이 없습니다.", vim.log.levels.INFO)
	end
end

-- 버퍼 기록 목록 표시 함수
local function show_closed_buffer_history()
	if #closed_buffers_stack == 0 then
		vim.notify("🚫 저장된 버퍼 기록이 없습니다.", vim.log.levels.INFO)
		return
	end

	print("최근 닫힌 버퍼 목록:")
	for i, path in ipairs(closed_buffers_stack) do
		-- 파일명만 추출하여 표시
		local filename = vim.fn.fnamemodify(path, ":t")
		print(string.format("%d: %s", i, filename))
	end
end

-- 특정 번호의 버퍼 복원 함수
local function restore_buffer_by_index(index)
	if not index or index < 1 or index > #closed_buffers_stack then
		vim.notify("🚫 유효한 버퍼 번호가 아닙니다.", vim.log.levels.WARN)
		return
	end

	local buffer_to_restore = closed_buffers_stack[index]

	-- 안전하게 명령 실행
	local status, error = pcall(function()
		vim.cmd("vnew " .. vim.fn.fnameescape(buffer_to_restore))
	end)

	if status then
		-- 복원한 버퍼를 기록에서 제거
		table.remove(closed_buffers_stack, index)

		-- 레이아웃 재설정 함수가 존재하는지 확인 후 실행
		if #vim.api.nvim_list_wins() == 2 and type(_G.ReloadLayout) == "function" then
			_G.ReloadLayout()
		end
	else
		vim.notify("버퍼 복원 실패: " .. error, vim.log.levels.ERROR)
	end
end

-- 오토커맨드 설정: 버퍼가 삭제될 때 실행 (윈도우가 아닌 버퍼 이벤트 사용)
vim.api.nvim_create_autocmd("BufDelete", {
	callback = save_closed_buffer,
})

local wk_map = require("utils").wk_map
wk_map({
	["<leader>b"] = {
		order = { "r", "h" },
		group = "  Buffer",
		["r"] = { restore_last_closed_buffer, desc = "revive", mode = "n" },
		["h"] = { show_closed_buffer_history, desc = "history", mode = "n" },
	},
})

-- 숫자로 특정 버퍼 복원하는 명령어 추가
vim.api.nvim_create_user_command("RestoreBuffer", function(opts)
	local index = tonumber(opts.args)
	restore_buffer_by_index(index)
end, { nargs = 1, desc = "인덱스로 닫은 버퍼 복원" })
