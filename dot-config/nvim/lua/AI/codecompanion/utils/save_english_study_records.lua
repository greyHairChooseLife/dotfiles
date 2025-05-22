local M = {}

local exclude_phrases = {
	"### Git Staged",
	"Please analyze my English",
	"Please explain this code from buffer",
	"Please generate unit tests for this code from buffer",
	"Please fix this code from buffer",
	"This is a list of the diagnostic messages",
}

function M.setup()
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestStarted",
		callback = function(_)
			-- vim.notify(vim.inspect(req))
			local cdc = require("codecompanion")

			if not cdc.last_chat() or not cdc.last_chat() then
				vim.notify("no messages found", 2, { render = "minimal" })
				return nil
			end

			local messages = cdc.last_chat().messages

			if not messages or #messages == 0 then
				vim.notify("no messages found", 2, { render = "minimal" })
				return nil
			end

			local last_message = messages[#messages]
			local content = last_message.content

			if not last_message.content then
				return nil
			end

			-- Filter out code blocks and references
			content = content:gsub("```.-```", "")
			content = content:gsub("<buf>.-</buf>", "")
			content = content:gsub("<file>.-</file>", "")
			content = content:gsub("<url>.-</url>", "")
			content = content:gsub("<tool>.-</tool>", "")
			content = content .. "\n"

			-- conditino 1:
			if not content or #content < 30 then
				return nil
			end

			-- conditino 2: Check if content contains any excluded phrase
			for _, phrase in ipairs(exclude_phrases) do
				if content:match(phrase) then
					return nil
				end
			end

			local notes_dir = vim.fn.expand("/tmp/english_study_src")
			if vim.fn.isdirectory(notes_dir) == 0 then
				vim.fn.mkdir(notes_dir, "p")
			end

			local filename = notes_dir .. "/records.md"

			local file = io.open(filename, "a")
			if file then
				file:write(content)
				file:close()
			else
				vim.notify("Failed to save English study notes", vim.log.levels.ERROR)
			end
		end,
	})
end

return M
