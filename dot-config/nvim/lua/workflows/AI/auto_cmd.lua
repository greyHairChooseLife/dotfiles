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
		if request.match == "CodeCompanionRequestFinished" then
			vim.cmd("stopinsert")
		end
	end,
})
