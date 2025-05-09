local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionInline*",
		group = group,
		callback = function(request)
			if request.match == "CodeCompanionInlineFinished" then
				-- Format the buffer after the inline request has completed
				require("conform").format({ bufnr = request.buf })
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequest*",
		group = group,
		callback = function(request)
			if request.match == "CodeCompanionRequestStarted" then
				vim.cmd("stopinsert")
				-- 영타 상태로 무조건 바꾸기
				vim.api.nvim_input("<Esc>")
				os.execute("xdotool key Escape")
			end
		end,
	})
end

return M
