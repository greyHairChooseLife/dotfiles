return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua", stop_after_first = true },
				http = { "kulala" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", stop_after_first = true },
				python = { "ruff_organize_imports", "ruff_fix", "ruff_format", stop_after_first = true },
				bash = { "shfmt" },
				sh = { "shfmt" },
				yaml = { "yamlfmt" },
				toml = { "taplo" },
			},
			formatters = {
				kulala = {
					command = "kulala-fmt",
					args = { "format", "$FILENAME" },
					stdin = false,
				},
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		})
	end,
	keys = {
		-- {
		-- 	"<leader>rf",
		-- 	function()
		-- 		local bufnr = vim.api.nvim_get_current_buf()
		-- 		local filetype = vim.bo[bufnr].filetype
		-- 		local formatters = require("conform").list_formatters_for_buffer(bufnr)

		-- 		local formatted = require("conform").format({
		-- 			bufnr = bufnr,
		-- 			lsp_fallback = true,
		-- 			async = false,
		-- 		})

		-- 		vim.notify("Filetype: " .. filetype)
		-- 		vim.notify("Available formatters: " .. vim.inspect(formatters))
		-- 		vim.notify("Formatting result: " .. tostring(formatted))
		-- 	end,
		-- 	desc = "Format with debug info",
		-- },
	},
}
