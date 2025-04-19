return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		sort_by = "case_sensitive",
		view = { width = 40 },
		-- sync_root_with_cwd = true,
		filters = {
			dotfiles = true,
			custom = {
				-- "node_modules",
			},
		},
		renderer = {
			add_trailing = false,
			group_empty = false,
			highlight_git = false,
			full_name = false,
			highlight_opened_files = "name", -- active buffer 표시
			highlight_modified = "none",
			indent_width = 3,
			indent_markers = {
				enable = true,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					bottom = "─",
					none = " ",
				},
			},
			icons = {
				webdev_colors = true,
				git_placement = "before",
				modified_placement = "after",
				padding = " ",
				symlink_arrow = "  ",
				show = {
					file = true,
					folder = true,
					folder_arrow = false,
					git = true,
					modified = true,
				},
				glyphs = {
					default = "",
					symlink = "",
					bookmark = "", --  
					modified = "󰈸󰈸󰈸", --   
					folder = {
						arrow_closed = "",
						arrow_open = "",
						default = "",
						open = "",
						empty = "",
						empty_open = "", -- 
						symlink = "",
						symlink_open = "",
					},
					git = {
						unstaged = "󰍶", --  󱠇  󰅙   󰍶
						staged = "󰗠", --     󰗠 󰗡 󰄲 󰄴 󱤧 󰄵 󰱒
						unmerged = "",
						renamed = "", --      
						untracked = "󰋗 ", --       󰅗 󰅘 󰅙 󰅚 󰅜 󰅝 󱍥 󱍦
						deleted = "", -- 󰗨 󰺝 󰛌
						ignored = "",
					},
				},
			},
		},
		git = {
			enable = true,
			ignore = true,
			show_on_dirs = true,
			show_on_open_dirs = false,
			timeout = 400,
		},
		update_focused_file = {
			enable = true,
			update_root = false,
			ignore_list = {},
		},
		diagnostics = {
			enable = false, -- 오랫동안 봐 왔지만 실용적인 적이 딱히 없는듯?
			show_on_dirs = true,
			show_on_open_dirs = false,
			debounce_delay = 50,
			severity = {
				min = vim.diagnostic.severity.HINT,
				max = vim.diagnostic.severity.ERROR,
			},
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		on_attach = require("file_tree.nvimtree_keymap").nvim_tree_on_attach,
		auto_reload_on_write = true,
		modified = {
			enable = true,
			show_on_dirs = true,
			show_on_open_dirs = false,
		},
		actions = {
			change_dir = {
				enable = true,
				global = true,
				restrict_above_cwd = false,
			},
		},
	},
}
