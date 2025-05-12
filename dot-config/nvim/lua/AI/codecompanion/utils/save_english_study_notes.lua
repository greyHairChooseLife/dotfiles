local M = {}

local function append_to_otp_file(generated)
	local target_file = "/home/sy/Documents/dev-wiki/notes/Area/나를_사랑하기/오답노트.md"
	local line_to_append = "[" .. generated .. "](./from_codecompanion_conversation/" .. generated .. ")"

	-- Open the file in append mode
	local file = io.open(target_file, "a")
	if not file then
		vim.notify("Failed to open target file for appending", vim.log.levels.ERROR)
		return false
	end

	-- Append the line with a newline before it
	file:write("\n" .. line_to_append)
	file:close()

	vim.notify("Successfully appended link to 오답노트.md", vim.log.levels.INFO)
	return true
end

function M.setup()
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestFinished",
		callback = function(_)
			-- Get the messages from the closed chat
			local cdc = require("codecompanion")
			local closed_chat = cdc.last_chat()

			if not closed_chat or not closed_chat.messages then
				return
			end

			-- Look for English study notes in the last assistant message
			local study_notes = nil
			for i = #closed_chat.messages, 1, -1 do
				local msg = closed_chat.messages[i]
				if msg.role == "llm" and msg.opts and msg.opts.visible then
					-- Check if this contains study notes
					if msg.content:match("# English Study Notes") then
						study_notes = msg.content
						break
					end
				end
			end

			-- If study notes were found, save them
			if study_notes then
				-- Create directory if it doesn't exist
				local path =
					"/home/sy/Documents/dev-wiki/notes/Area/나를_사랑하기/from_codecompanion_conversation"
				local notes_dir = vim.fn.expand(path)
				if vim.fn.isdirectory(notes_dir) == 0 then
					vim.fn.mkdir(notes_dir, "p")
				end

				-- Generate filename with date and time
				local date_str = os.date("%Y-%m-%d_%H-%M")
				local filename = notes_dir .. "/" .. date_str .. ".md"

				-- Write to file
				local file = io.open(filename, "w")
				if file then
					file:write(study_notes)
					file:close()
					vim.notify("English study notes saved to: " .. filename, vim.log.levels.INFO)
					append_to_otp_file(date_str)
				else
					vim.notify("Failed to save English study notes", vim.log.levels.ERROR)
				end
			end
		end,
	})
end

return M
