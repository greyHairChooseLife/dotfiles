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

-- MEMO:: 여기서부터  코ㄷ컴패니언
-- MEMO:: 여기서부터  코ㄷ컴패니언
-- MEMO:: 여기서부터  코ㄷ컴패니언
-- MEMO:: 여기서부터  코ㄷ컴패니언

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
	cdc.chat()
end

M.toggle_last_chat = function()
	-- local chat = cdc.last_chat()
	-- print(chat.ui:is_visible())
	-- print(chat.ui:is_active())
	-- chat.ui:open()

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

			-- 레퍼런스로 넣어주기
			cdc.last_chat():add_message({
				role = "user",
				content = string.format(
					"%s `%s` (which has a buffer number of _%d_ and a filepath of `%s`): \n\n%s",
					message,
					vim.fn.fnamemodify(path, ":t"),
					bufnr,
					path,
					formatted_content_with_line_numbers
				),
			}, { reference = id, visible = false })

			cdc.last_chat().references:add({
				bufnr = bufnr,
				id = id,
				path = path,
				source = "codecompanion.strategies.chat.slash_commands.buffer",
				opts = {},
			})

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
					vim.notify("Already in reference!", vim.log.levels.WARN)
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
		vim.print("buffer added to chat")
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
		require("utils").restore_cursor_position()
	end)
end

return M
