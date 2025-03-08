-- 노멀 모드: 전체 버퍼 내용을 주석과 함께 md 코드블록 형식으로 레지스트리에 저장
function Save_entire_buffer_to_register_for_AI_prompt()
	local content = vim.fn.join(vim.fn.getline(1, "$"), "\n") -- 전체 버퍼 내용 가져오기
	local relative_path = vim.fn.expand("%:p"):sub(#vim.fn.getcwd() + 2)
	local filetype = vim.bo.filetype
	local result = string.format("```%s\n## File Path: %s\n%s\n```", filetype, relative_path, content)

	vim.fn.setreg("+", result)
	print("copied entirely for AI!")
end

-- 비주얼 모드: 선택한 텍스트를 주석과 함께 md 코드블록 형식으로 레지스트리에 저장
function Save_visual_selection_to_register_for_AI_prompt()
	-- Visual 모드 종료 후 Normal 모드로 돌아가기
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

	vim.schedule(function()
		-- MEMO:: '<' 또는 '>' 이놈들은 기본적으로 이전 visual mode의 시작과 끝을 가져온다. 그러니 일단 nomal모드로 돌아간 뒤에 가져와야 정상 순서다.
		local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
		local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))

		local content = table.concat(vim.fn.getline(start_line, end_line), "\n")
		local relative_path = vim.fn.expand("%:p"):sub(#vim.fn.getcwd() + 2)
		local filetype = vim.bo.filetype
		local range = start_line .. "-" .. end_line

		local result = string.format("```%s\n## File Path: %s, %s\n%s\n```", filetype, relative_path, range, content)

		-- 텍스트를 레지스트리에 저장
		vim.fn.setreg("+", result)
		print("copied selected for AI!")
	end)
end

function Toggle_ChatWithCopilot()
	local chat = require("CopilotChat")

	if chat.chat:visible() then
		chat.chat:close()
	else
		require("utils").save_cursor_position()
		chat.open()
		require("utils").restore_cursor_position()
	end
end

function ChatWithCopilotOpen_Buffer()
	local chat = require("CopilotChat")
	chat.open({ selection = require("CopilotChat.select").buffer })
end

function ChatWithCopilotOpen_Visual()
	local chat = require("CopilotChat")
	chat.open({ selection = require("CopilotChat.select").visual })
end
