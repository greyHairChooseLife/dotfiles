local M = {}

local cdc = require("codecompanion")

local util = {
	---Add line numbers to the table of content
	---@param content string The content from method get_content(File Path: lua/codecompanion/utils/buffers.lua, 83:83)
	---@param start_line number
	---@return string
	add_line_numbers = function(content, start_line)
		local formatted = {}

		content = vim.split(content, "\n")
		for i, line in ipairs(content) do
			table.insert(formatted, string.format("%d:  %s", i + start_line, line))
		end

		return table.concat(formatted, "\n")
	end,

	---Formats the content of a buffer into a markdown string
	---@param buffer table The buffer data to include
	---@param formatted string after add_line_numbers
	---@return string
	format = function(buffer, formatted)
		return string.format(
			"Buffer Number: %d\n"
				.. "Name: %s\n"
				.. "Path: %s\n"
				.. "Filetype: %s\n"
				.. "Range start(linenumber): %s\n"
				.. "Range end(linenumber): %s\n"
				.. "Content:\n"
				.. "```%s\n"
				.. "%s\n"
				.. "```\n",
			buffer.number,
			buffer.name,
			buffer.path,
			buffer.filetype,
			buffer.start_line_of_rane,
			buffer.end_line_of_rane,
			buffer.filetype,
			formatted
		)
	end,

	back_to_normal_mode = function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	end,
}

M.inspect = function()
	local chat_buf = cdc.buf_get_chat()
	local is_chat_visible = next(chat_buf) ~= nil
	print(is_chat_visible and "있다" or "없다. ")
	print(vim.inspect(chat_buf))

	-- REF::
	--   {
	--     actions = <function 1>,
	--     add = <function 2>,
	--     buf_get_chat = <function 3>,
	--     chat = <function 4>,
	--     last_chat = <function 8>,
	--     close_last_chat = <function 5>, 제거는 안함
	--     toggle = <function 12>, 제거는 안함, 마지막 것만 닫음
	--     cmd = <function 6>,
	--     inline = <function 7>,
	--     prompt = <function 9>,
	--     prompt_library = <function 10>,
	--     setup = <function 11>,
	--     workspace_schema = <function 13>
	--   }

	-- if chat.chat:visible() then
	-- 	chat.chat:close()
	-- else
	-- 	require("utils").save_cursor_position()
	-- 	chat.open()
	-- 	require("utils").restore_cursor_position()
	-- end
end

M.test = function()
	-- 	chat.add({
	--   })
	-- local bufnr = vim.api.nvim_get_current_buf()

	-- local content = require("codecompanion.utils.buffers").format_with_line_numbers(bufnr)

	-- local chat = cdc.last_chat()
	-- if chat.ui:is_visible() then
	--   return chat.ui:hide()
	-- end
	print(vim.inspect())
end

M.create_new = function()
	local windows = vim.api.nvim_list_wins()

	if #windows == 1 and vim.bo.filetype == "codecompanion" then
		vim.cmd("vnew")
		cdc.chat()
		vim.cmd("only")
	else
		cdc.chat()
	end
end

M.toggle_last_chat = function()
	require("utils").save_cursor_position()
	cdc.toggle()
	require("utils").restore_cursor_position()
end

M.focus_last_chat = function()
	local chat = cdc.last_chat()

	if not chat then
		return cdc.chat()
	end

	if chat.ui:is_visible() and not chat.ui:is_active() then
		vim.api.nvim_set_current_win(chat.ui.winnr)
	else
		chat.ui:open()
	end
end

M.add_buffer_reference = function()
	local add_selected_to_last_chat = function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		vim.schedule(function()
			local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
			local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))

			-- 정렬 (위에서 아래로)
			if start_line > end_line then
				start_line, end_line = end_line, start_line
			end

			local bufnr = vim.api.nvim_get_current_buf()

			local content = require("codecompanion.utils.buffers").get_content(bufnr, { start_line - 1, end_line })
			local info = require("codecompanion.utils.buffers").get_info(bufnr)
			info.start_line_of_rane = start_line
			info.end_line_of_rane = end_line

			local formatted_content_with_line_numbers =
				util.format(info, util.add_line_numbers(content, start_line - 1))

			local name = cdc.last_chat().references:make_id_from_buf(bufnr)
			if name == "" then
				name = "Buffer " .. bufnr
			end
			local id = "<buf>" .. name .. "</buf>"

			local path = vim.api.nvim_buf_get_name(bufnr)
			local message = "Here is the content from"

			-- NOTE: 레퍼런스까지 넣어주는게 의미 있을까? 넣을거라면 차라리 해당 버퍼(파일) 전체를 넣어주는게 좋지 않을까?
			-- 레퍼런스로 넣어주기
			-- cdc.last_chat():add_message({
			-- 	role = "user",
			-- 	content = string.format(
			-- 		"%s `%s` (which has a buffer number of _%d_ and a filepath of `%s`): \n\n%s",
			-- 		message,
			-- 		vim.fn.fnamemodify(path, ":t"),
			-- 		bufnr,
			-- 		path,
			-- 		formatted_content_with_line_numbers
			-- 	),
			-- }, { reference = id, visible = false })

			-- cdc.last_chat().references:add({
			-- 	bufnr = bufnr,
			-- 	id = id,
			-- 	path = path,
			-- 	source = "codecompanion.strategies.chat.slash_commands.buffer",
			-- 	opts = {},
			-- })

			-- 채팅 버퍼에도 간단히 표시
			local formatted_content = require("codecompanion.utils.buffers").format(bufnr, { start_line - 1, end_line })
			cdc.last_chat():add_buf_message({
				role = "user",
				content = string.format(
					"%s `%s:%s-%s`: \n%s\n\n",
					message,
					vim.fn.fnamemodify(path, ":t"),
					start_line,
					end_line,
					formatted_content
				),
			})
		end)
	end

	local add_buf_to_last_chat = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local content = require("codecompanion.utils.buffers").format_with_line_numbers(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		local message = "Here is the content from"
		local name = cdc.last_chat().references:make_id_from_buf(bufnr)

		if name == "" then
			name = "Buffer " .. bufnr
		end
		local id = "<buf>" .. name .. "</buf>"

		local formatted_content = string.format(
			"%s `%s` (which has a buffer number of _%d_ and a filepath of `%s`): \n\n%s",
			message,
			vim.fn.fnamemodify(path, ":t"),
			bufnr,
			path,
			content
		)

		-- Check for duplicate before adding
		local chat = cdc.last_chat()
		if chat then
			for _, msg in ipairs(chat.references.Chat.agents.messages) do
				if msg.content == formatted_content then
					vim.notify("Already in reference!", 2, { render = "minimal" })
					return false
				end
			end
		end

		-- Add reference if not duplicate
		cdc.last_chat():add_message({
			role = "user",
			content = formatted_content,
		}, { reference = id, visible = false })

		cdc.last_chat().references:add({
			bufnr = bufnr,
			id = id,
			path = path,
			source = "codecompanion.strategies.chat.slash_commands.buffer",
			opts = {},
		})
		cdc.last_chat().ui:set_virtual_text("Added: " .. vim.fn.fnamemodify(path, ":t"))
	end

	local chat = cdc.last_chat()
	local mode = vim.fn.mode()
	if mode == "n" then
		if not chat or not chat.ui:is_visible() then
			M.toggle_last_chat()
		end

		add_buf_to_last_chat()
	else
		if not chat or not chat.ui:is_visible() then
			util.back_to_normal_mode()
			vim.schedule(function()
				M.toggle_last_chat()
			end)
			vim.api.nvim_feedkeys("gv", "n", true)
		end

		add_selected_to_last_chat()
	end

	-- UI redraw
	vim.schedule(function()
		require("utils").save_cursor_position()
		M.focus_last_chat()
		if mode == "n" then
			require("utils").restore_cursor_position()
		end
	end)
end

-- 현재 탭의 모든 버퍼를 컨텍스트로 추가하는 함수
M.add_tab_buffers_reference = function()
	local chat = cdc.last_chat()
	if not chat or not chat.ui:is_visible() then
		M.toggle_last_chat()
		chat = cdc.last_chat()
	end

	-- 현재 탭의 모든 버퍼를 가져옴
	local current_tab = vim.api.nvim_get_current_tabpage()
	local buffers = vim.api.nvim_tabpage_list_wins(current_tab)
	local added_buffers = {}
	local skipped_buffers = {}

	for _, win in ipairs(buffers) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		-- local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
		local buftype = vim.bo[bufnr].buftype
		local path = vim.api.nvim_buf_get_name(bufnr)

		-- 일반 파일 버퍼만 처리 (특수 버퍼는 제외)
		if buftype == "" and path ~= "" then
			local content = require("codecompanion.utils.buffers").format_with_line_numbers(bufnr)
			local message = "Here is the content from"
			local name = chat.references:make_id_from_buf(bufnr)

			if name == "" then
				name = "Buffer " .. bufnr
			end
			local id = "<buf>" .. name .. "</buf>"

			local formatted_content = string.format(
				"%s `%s` (which has a buffer number of _%d_ and a filepath of `%s`): \n\n%s",
				message,
				vim.fn.fnamemodify(path, ":t"),
				bufnr,
				path,
				content
			)

			-- 중복 체크
			local is_duplicate = false
			for _, msg in ipairs(chat.references.Chat.agents.messages) do
				if msg.content == formatted_content then
					is_duplicate = true
					table.insert(skipped_buffers, vim.fn.fnamemodify(path, ":t"))
					break
				end
			end

			-- 중복이 아니면 추가
			if not is_duplicate then
				chat:add_message({
					role = "user",
					content = formatted_content,
				}, { reference = id, visible = false })

				chat.references:add({
					bufnr = bufnr,
					id = id,
					path = path,
					source = "codecompanion.strategies.chat.slash_commands.buffer",
					opts = {},
				})

				table.insert(added_buffers, vim.fn.fnamemodify(path, ":t"))
			end
		end
	end

	-- 결과 알림
	if #added_buffers > 0 then
		local added_msg = "Added: " .. table.concat(added_buffers, ", ")
		chat.ui:set_virtual_text(added_msg)
		vim.notify(added_msg, 2, { render = "minimal" })
	end

	if #skipped_buffers > 0 then
		vim.notify("Skipped (already in context): " .. table.concat(skipped_buffers, ", "), 2, { render = "minimal" })
	end

	-- UI redraw
	vim.schedule(function()
		require("utils").save_cursor_position()
		M.focus_last_chat()
		require("utils").restore_cursor_position()
	end)
end

-- work while adapter is 'copilot'
---@param model string adapter.model
M.chage_model = function(model)
	local chat = require("codecompanion").last_chat()

	if chat and chat.adapter and chat.adapter.name == "copilot" then
		chat:apply_model(model)
	end
end

M.codecompanion_breadcrumbs = function()
	local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
	if not chat then
		return nil
	end

	-- REF:
	-- vim.notify(vim.inspect(chat.settings))
	-- {
	--   max_tokens = 15000,
	--   model = "gemini-2.5-pro",
	--   n = 1,
	--   reasoning_effort = "medium",
	--   temperature = 0,
	--   top_p = 1
	-- }

	local reasoning_effort = chat.settings and chat.settings.reasoning_effort or " no"
	local max_tokens = chat.settings.max_tokens
	local used_tokens = chat.ui.tokens
	local percentage_usage = "0"

	if used_tokens ~= nil then
		percentage_usage = string.format("%.1f", (used_tokens / max_tokens) * 100)
	end
	used_tokens = 0

	local result = " " .. reasoning_effort .. "    󰰤  " .. percentage_usage .. "󱉸 (" .. used_tokens .. ")"
	local needed_padding = 24 - vim.api.nvim_strwidth(result)

	if needed_padding > 0 then
		return string.rep(" ", needed_padding) .. result
	else
		return result
	end
end

return M
