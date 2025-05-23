return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		enabled = true,
		indent = {
			char = "▏",
			smart_indent_cap = true,
			repeat_linebreak = false,
		},
		-- whitespace = { highlight = { "Whitespace", "NonText" } },
		scope = { -- https://github.com/lukas-reineke/indent-blankline.nvim?tab=readme-ov-file#scope
			enabled = true,
			-- char = "▍",
			char = "▎",
			show_start = false,
			show_end = false,
			injected_languages = true,
			priority = 1000,
			-- exclude = { language = { "lua" } },
		},
		exclude = {
			filetypes = {
				"css",
				"markdown",
				"vimwiki",
			},
		},
	},
}
