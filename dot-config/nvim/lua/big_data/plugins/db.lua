return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod" },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } }, -- Optional
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_winwidth = 50
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_icons = {
			expanded = "",
			collapsed = ">",
			saved_query = "",
			new_query = "",
			tables = "󰤏",
			buffers = "󰷥",
			connection_ok = "",
			connection_error = "󰌺",
		}
	end,
	config = function()
		-- 2 space tab indent for the ui tree (filetype=dbui)
		vim.api.nvim_create_augroup("DadbodUISettings", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dbui",
			group = "DadbodUISettings",
			callback = function()
				vim.opt_local.expandtab = true
				vim.opt_local.shiftwidth = 2
				vim.opt_local.softtabstop = 2
			end,
		})

		-- Use csvview.nvim for pretty viewing of CSV db output (filetype=dbout)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dbout",
			group = "DadbodUISettings",
			callback = function(args)
				-- Get the first line of the buffer associated with the autocmd event
				local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)
				-- Check if the first line exists and contains a comma (very simple heuristic for CSV)
				if #lines > 0 and lines[1] and string.find(lines[1], ",", 1, true) then
					vim.cmd("CsvViewEnable")
				end
			end,
		})
	end,
}
