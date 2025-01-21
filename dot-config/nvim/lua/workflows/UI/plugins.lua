return {
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local utils = require("utils")

			local colors = {
				blue = "#61afef",
				git_add = "#40cd52",
				git_change = "#ffcc00",
				git_delete = "#f1502f",
				greenbg = "#98c379",
				purple = "#c678dd",
				orange = "#FF8C00",
				wwhite = "#abb2bf",
				white = "#ffffff",
				bblack = "#282c34",
				black = "#000000",
				grey = "#333342",
				bg = "#24283b",
				active_qf = "#db4b4b",
				nvimTree = "#333342",
				active_oil = "#BDB80B",
				purple1 = "#A020F0",
				red2 = "#DC143C",
			}

			local my_theme = {
				normal = {
					a = { fg = colors.orange, bg = colors.orange },
					b = { fg = colors.orange, bg = colors.bg },
					c = { fg = colors.black, bg = colors.greenbg },
					x = { fg = colors.black, bg = colors.orange },
					y = { fg = colors.wwhite, bg = colors.bg },
					z = { fg = colors.bg, bg = colors.orange },
				},
				inactive = {
					a = { fg = colors.orange, bg = colors.bg },
					b = { fg = colors.orange, bg = colors.bg },
					c = { fg = colors.grey, bg = colors.grey },
					x = { fg = colors.grey, bg = colors.grey },
					y = { fg = colors.grey, bg = colors.grey },
					z = { fg = colors.wwhite, bg = colors.grey },
				},
			}

			local function empty()
				return ""
			end

			local function this_is_space()
				return " "
			end

			local function get_git_branch()
				-- 현재 디렉토리가 Git 저장소인지 확인
				local git_dir = vim.fn.finddir(".git", ".;")
				if git_dir == "" then
					return "no git" -- Git 저장소가 아니면 빈 문자열 반환
				end

				-- 현재 Git 브랜치를 가져옴
				local handle = io.popen("git branch --show-current 2>/dev/null")
				local branch = handle:read("*a")
				handle:close()

				-- 줄바꿈 제거하고 브랜치 이름 반환
				return " " .. branch:gsub("%s+", "")
			end

			local function this_is_fugitive()
				return "- Fugitive -"
			end

			local function harpoon_length()
				-- get the length of the harpoon list
				local items = require("harpoon"):list():length()
				if items == 0 then
					return ""
				else
					return "󰀱 " .. items
				end
			end

			-- 각종 컴포넌트 스니펫이다.
			-- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets

			local my_quickfix = {
				filetypes = { "qf" },
				sections = {
					lualine_a = {
						{
							"filetype",
							color = { bg = colors.active_qf, fg = colors.white, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
						},
					},
				},
				inactive_sections = {
					lualine_a = {
						{
							"filetype",
							color = { bg = colors.active_qf, fg = colors.white, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
							separator = { right = "" },
						},
					},
					lualine_b = { { empty, color = { bg = colors.grey } } },
				},
			}

			local my_nvimTree = {
				filetypes = { "NvimTree" },
				sections = {
					lualine_a = {
						{
							get_git_branch,
							color = { bg = colors.nvimTree, fg = colors.orange, gui = "bold,italic" },
							padding = { left = 3 },
						},
						{
							harpoon_length,
							color = { bg = colors.nvimTree, fg = colors.orange, gui = "bold,italic" },
							padding = { left = 22, right = 3 },
						},
					},
				},
				inactive_sections = {
					lualine_a = {
						{
							get_git_branch,
							color = { bg = colors.nvimTree, fg = colors.orange, gui = "bold,italic" },
							padding = { left = 3 },
						},
					},
					lualine_z = {
						{
							harpoon_length,
							color = { bg = colors.nvimTree, fg = colors.orange, gui = "bold,italic" },
							padding = { left = 22, right = 4 },
						},
					},
				},
			}

			local my_fugitive = {
				filetypes = { "fugitive" },
				sections = {
					lualine_a = {
						{
							get_git_branch,
							color = { bg = colors.orange, fg = colors.bblack, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
							-- separator = { right = "" },
						},
					},
					lualine_z = { { this_is_fugitive, color = { bg = colors.orange, fg = colors.bblack } } },
				},
				inactive_sections = {
					lualine_a = {
						{
							get_git_branch,
							color = { bg = colors.orange, fg = colors.bblack, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
							-- separator = { right = "" },
						},
					},
					lualine_b = { { empty, color = { bg = colors.grey } } },
					lualine_z = {
						{ this_is_fugitive, color = { bg = colors.grey, fg = colors.orange, gui = "italic" } },
					},
				},
			}

			local my_oil = {
				filetypes = { "oil" },
				sections = {
					lualine_a = {
						{
							"filetype",
							color = { bg = colors.active_oil, fg = colors.bblack, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
						},
					},
				},
				inactive_sections = {
					lualine_a = {
						{
							"filetype",
							color = { bg = colors.active_oil, fg = colors.bblack, gui = "bold,italic" },
							padding = { left = 3, right = 5 },
							-- separator = { right = " " },
						},
					},
					lualine_b = { { empty, color = { bg = colors.grey } } },
					lualine_z = { { this_is_space, color = { bg = colors.grey } } },
				},
			}

			-- vim.api.nvim_set_hl(0, "CustomSeparator", { fg = "#98c379", bg = "NONE" })
			--
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = my_theme,
					-- component_separators = { left = '', right = '' },
					-- section_separators = { left = '', right = '' },
					-- component_separators = { left = ' 󰪍󰪍 ', right = '' },
					-- section_separators = { left = '', right = '' },󰪍󰪍
					component_separators = { left = "%#CustomSeparator#████", right = "" },
					section_separators = { left = "", right = " " },
					disabled_filetypes = {
						statusline = {
							"packer",
							"alpha",
							"vimwiki",
							"aerial",
							"Avante",
							"AvanteInput",
							"AvanteSelectedFiles",
						},
						-- winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = false,
					globalstatus = false,
					refresh = {
						statusline = 50,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = {
						{
							"filename",
							file_status = false,
							newfile_status = false,
							symbols = {
								modified = "󰈸", -- Text to show when the file is modified.
								readonly = "", -- Text to show when the file is non-modifiable or readonly.
								unnamed = "New", -- Text to show for unnamed buffers.
								newfile = "New", -- Text to show for newly created file before first write
							},
							color = {
								fg = colors.bg,
								gui = "bold",
							},
							separator = { right = "" },
						},
						{
							function()
								if vim.bo.modified then
									return "󰈸󰈸󰈸"
								elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
									return " "
								else
									return " "
								end
							end,
							padding = { left = 0, right = 1 },
							color = function()
								if vim.bo.modified then
									return { fg = colors.red2 }
								elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
									return { fg = colors.purple1 }
								else
									return {}
								end
							end,
						},
					},
					lualine_b = {
						{
							"diff",
							diff_color = {
								added = { fg = colors.git_add },
								modified = { fg = colors.git_change },
								removed = { fg = colors.git_delete },
							},
							symbols = {
								added = utils.icons.git.Add,
								modified = utils.icons.git.Change,
								removed = utils.icons.git.Delete,
							},
						},
						{
							"diagnostics",
							diagnostics_color = {
								error = "DiagnosticError",
								warn = "DiagnosticWarn",
								info = "DiagnosticInfo",
								hint = "DiagnosticHint",
							},
							symbols = {
								error = utils.icons.diagnostics.Error .. " ",
								warn = utils.icons.diagnostics.Warn .. " ",
								hint = utils.icons.diagnostics.Hint .. " ",
								info = utils.icons.diagnostics.Info .. " ",
							},
						},
					},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {
						{
							"harpoon2",
							icon = "", -- 󰀱 󰃀 󰃃  󰆡  
							indicators = { "", "", "", "", "", "" },
							active_indicators = { "", "", "", "", "", "" },
							color_active = { fg = colors.orange, bg = colors.bg, gui = "bold" },
							_separator = "", --  󱋰 󰇜 󰇼 󱗘 󰑅 󱒖 󰩮 󰦟 󰓡    
							no_harpoon = "Harpoon not loaded",
							padding = { left = 1, right = 1 },
						},
					},
					lualine_z = {
						{ "location", padding = { left = 0, right = 1 } },
						{ "progress", padding = { left = 1, right = 1 } },
					},
				},
				inactive_sections = {
					lualine_a = {
						{
							"filename",
							file_status = false,
							newfile_status = false,
							symbols = {
								modified = "󰈸", -- Text to show when the file is modified.
								readonly = "", -- Text to show when the file is non-modifiable or readonly.
								unnamed = "New", -- Text to show for unnamed buffers.
								newfile = "New", -- Text to show for newly created file before first write
							},
							color = {
								fg = colors.wwhite,
								gui = "italic",
							},
							separator = { right = "" },
						},
						{
							function()
								if vim.bo.modified then
									return "󰈸"
								elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
									return ""
								else
									return " "
								end
							end,
							padding = { left = 0, right = 1 },
							color = {
								fg = colors.orange,
							},
						},
					},
					lualine_b = {
						{
							"diff",
							diff_color = {
								added = { fg = colors.git_add },
								modified = { fg = colors.git_change },
								removed = { fg = colors.git_delete },
							},
							symbols = {
								added = utils.icons.git.Add,
								modified = utils.icons.git.Change,
								removed = utils.icons.git.Delete,
							},
						},
						{
							"diagnostics",
							diagnostics_color = {
								error = "DiagnosticError",
								warn = "DiagnosticWarn",
								info = "DiagnosticInfo",
								hint = "DiagnosticHint",
							},
							symbols = {
								error = utils.icons.diagnostics.Error .. " ",
								warn = utils.icons.diagnostics.Warn .. " ",
								hint = utils.icons.diagnostics.Hint .. " ",
								info = utils.icons.diagnostics.Info .. " ",
							},
						},
					},
					lualine_z = {
						{
							"harpoon2",
							-- icon = '♥',
							icon = "",
							indicators = { "", "", "", "", "", "" },
							active_indicators = { "", "", "", "", "", "" },
							color_active = { fg = colors.orange, bg = colors.bg, gui = "bold" },
							_separator = "", --  󱋰 󰇜 󰇼 󱗘 󰑅 󱒖 󰩮 󰦟 󰓡    
							no_harpoon = "Harpoon not loaded",
						},
					},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = { "toggleterm", my_quickfix, my_nvimTree, my_fugitive, my_oil },
			})
		end,
	},
	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPre",
		opts = {},
	},
	{
		"goolord/alpha-nvim",
		lazy = false,
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- MEMO:: header
			local function header()
				local cwd = vim.fn.getcwd()
				-- Git 디렉토리인지 확인
				local git_dir_check = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
				if git_dir_check:match("true") == nil then
					return {
						"                                                                              " .. cwd,
						"Not git dir                                                                                                               ",
					}
				end

				local fetch_output = vim.fn.system("git log --oneline HEAD..FETCH_HEAD")
				local fetch_lines = {}
				for line in fetch_output:gmatch("([^\n]*)\n?") do
					table.insert(fetch_lines, line)
				end

				local result = {
					"                                                                                   " .. cwd,
					" HEAD..FETCH_HEAD                                                                                                                                 ",
					" ",
				}

				for _, line in ipairs(fetch_lines) do
					table.insert(result, "  " .. line)
				end

				table.insert(result, " origin/HEAD..HEAD")
				table.insert(result, "")

				local workload_output = vim.fn.system("git log --oneline origin/HEAD..HEAD")
				local workload_lines = {}
				for line in workload_output:gmatch("([^\n]*)\n?") do
					table.insert(workload_lines, line)
				end

				for _, line in ipairs(workload_lines) do
					table.insert(result, "  " .. line)
				end

				return result
			end
			dashboard.section.header.val = header()

			-- MEMO:: footer
			-- local function footer()
			-- 	return {
			-- 		"1. 미루지 않기",
			-- 		"2. 어려운 쪽을 선택하기",
			-- 	}
			-- end
			-- dashboard.section.footer.val = footer()

			-- Set menu
			dashboard.section.buttons.val = {
				dashboard.button("F", "                           -  fetch   ", function()
					vim.cmd("Git fetch")
					alpha.redraw()
				end),
				-- dashboard.button("n", "New", ":ene <BAR> startinsert <CR>"),
				dashboard.button("n", "New", ":ene<CR>"),
				dashboard.button("f", "File", ":Telescope find_files<CR>"),
				dashboard.button("w", "Word", ":Telescope live_grep<CR>"),
				dashboard.button("o", "Old", ":Telescope oldfiles<CR>"),
				dashboard.button(".", "", ""),
				dashboard.button("D", "                   ---------  doc   ", ":cd ~/Documents | vi .<CR>"),
				dashboard.button(
					"dpu",
					"                           -  pull    ",
					":cd ~/Documents/dev-wiki | :Git pull | :cd ~/Documents/job-wiki | :Git pull<CR>"
				),
				dashboard.button("1", "dev", ":cd ~/Documents/dev-wiki | :VimwikiIndex<CR>"),
				dashboard.button("2", "job", ":cd ~/Documents/job-wiki | :2VimwikiIndex<CR>"),
				dashboard.button(".", "", ""),
				dashboard.button("q", "                   ---------  configs   ", ":q<CR>"),
				dashboard.button("up", "󰂖 plugin update", ":PackerSync<CR>"),
				dashboard.button("i3", " i3", ":e ~/.config/i3/config<CR>"),
				dashboard.button("te", " term", ":e ~/.config/alacritty/alacritty.toml<CR>"),
				dashboard.button("vi", " vi", ":e ~/.config/nvim<CR>"),
				dashboard.button("ba", " bash", ":e ~/.config/bash.sub/<CR>"),
				dashboard.button(".", "", ""),
				dashboard.button("-", "                   ---------  sessions   ", ""),
				dashboard.button("S", "Session", "<cmd>SessionSearch<CR>"),
			}

			dashboard.section.header.opts.hl = "AlphaHeaderLabel"
			dashboard.section.buttons.opts.hl = "GitSignsChange"
			dashboard.section.footer.opts.hl = "ErrorMsg"

			-- Send config to alpha
			alpha.setup(dashboard.opts)
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		config = function()
			vim.api.nvim_set_hl(0, "MyBG", { fg = "#24283b" })
			vim.api.nvim_set_hl(0, "MyFG", { fg = "#7f52ff" })

			-- https://github.com/lukas-reineke/indent-blankline.nvim?tab=readme-ov-file#scope
			require("ibl").setup({
				enabled = true,
				indent = {
					char = "▏",
					smart_indent_cap = true,
					repeat_linebreak = false,
					highlight = { "MyBG" },
				},
				-- whitespace = { highlight = { "Whitespace", "NonText" } },
				scope = {
					enabled = true,
					-- char = "▍",
					char = "▏",
					highlight = { "MyFG", "MyFG" },
					show_start = true,
					show_end = true,
					injected_languages = true,
					priority = 500,
					-- exclude = { language = { "lua" } },
				},
				exclude = {
					filetypes = {
						"css",
					},
				},
			})
		end,
	},

	{
		"kelvinauta/focushere.nvim",
		cmd = "FocusHere",
		opts = true,
		-- config = function ()
		--    require("focushere").setup()
		-- end
	},

	{
		"folke/twilight.nvim",
		cmd = "Twilight",
		opts = {
			context = 1, -- amount of lines we will try to show around the current line
		},
	},

	{
		"cdmill/focus.nvim",
		cmd = "Focus",
		opts = {
			border = "none",
			zindex = 40, -- zindex of the focus window. Should be less than 50, which is the float default
			window = {
				backdrop = 0.9, -- shade the backdrop of the focus window. Set to 1 to keep the same as Normal
				-- height and width can be:
				-- * an asbolute number of cells when > 1
				-- * a percentage of the width / height of the editor when <= 1
				width = 150, -- width of the focus window
				height = 1, -- height of the focus window
				-- by default, no options are changed in for the focus window
				-- add any vim.wo options you want to apply
				options = {},
			},
			auto_zen = false, -- auto enable zen mode when entering focus mode
			-- by default, the options below are disabled for zen mode
			zen = {
				opts = {
					cmdheight = 0, -- disable cmdline
					cursorline = false, -- disable cursorline
					laststatus = 0, -- disable statusline
					number = false, -- disable number column
					relativenumber = false, -- disable relative numbers
					foldcolumn = "0", -- disable fold column
					signcolumn = "no", -- disable signcolumn
					statuscolumn = " ", -- disbale status column
				},
				diagnostics = false, -- disables diagnostics
			},
			plugins = {
				-- uncomment any of the lines below to disable that option in Focus mode
				-- options = {
				--   disable some global vim options (vim.o...) e.g.
				--   ruler = false
				-- },
				-- twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
				-- gitsigns = { enabled = false }, -- disables git signs
				-- tmux = { enabled = false }, -- disables the tmux statusline
				-- diagnostics = { enabled = false }, -- disables diagnostics
				-- todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
			},
			-- callback where you can add custom code when the focus window opens
			on_open = function(_win) end,
			-- callback where you can add custom code when the focus window closes
			on_close = function() end,
		},
	},

	{
		"stevearc/dressing.nvim",
		lazy = false,
		opts = {

			input = {
				-- Set to false to disable the vim.ui.input implementation
				enabled = false,

				-- Default prompt string
				default_prompt = "Input",

				-- Trim trailing `:` from prompt
				trim_prompt = true,

				-- Can be 'left', 'right', or 'center'
				title_pos = "right",

				-- The initial mode when the window opens (insert|normal|visual|select).
				start_mode = "insert",

				-- These are passed to nvim_open_win
				border = "rounded",
				-- 'editor' and 'win' will default to being centered
				relative = "cursor",

				-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				prefer_width = 40,
				width = nil,
				-- min_width and max_width can be a list of mixed types.
				-- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
				max_width = { 140, 0.9 },
				min_width = { 20, 0.2 },

				buf_options = {},
				win_options = {
					-- Disable line wrapping
					wrap = false,
					-- Indicator for when text exceeds window
					list = true,
					listchars = "precedes:…,extends:…",
					-- Increase this for more context when text scrolls off the window
					sidescrolloff = 0,
				},

				-- Set to `false` to disable
				mappings = {
					n = {
						["<Esc>"] = "Close",
						["<CR>"] = "Confirm",
					},
					i = {
						["<C-c>"] = "Close",
						["<CR>"] = "Confirm",
						["<Up>"] = "HistoryPrev",
						["<Down>"] = "HistoryNext",
					},
				},

				override = function(conf)
					-- This is the config that will be passed to nvim_open_win.
					-- Change values here to customize the layout
					return conf
				end,

				-- see :help dressing_get_config
				get_config = nil,
			},
			select = {
				-- Set to false to disable the vim.ui.select implementation
				enabled = true,

				-- Priority list of preferred vim.select implementations
				backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },

				-- Trim trailing `:` from prompt
				trim_prompt = true,

				-- Options for telescope selector
				-- These are passed into the telescope picker directly. Can be used like:
				-- telescope = require('telescope.themes').get_ivy({...})
				telescope = {
					borderchars = { "█", "█", "█", "█", "█", "█", "█", "█" },
					layout_strategy = "center",
					layout_config = {
						center = {
							height = 0.4,
							preview_cutoff = 40,
							prompt_position = "top",
							width = 0.4,
						},
					},
				},

				-- Options for fzf selector
				fzf = {
					window = {
						width = 0.5,
						height = 0.4,
					},
				},

				-- Options for fzf-lua
				fzf_lua = {
					-- winopts = {
					--   height = 0.5,
					--   width = 0.5,
					-- },
				},

				-- Options for nui Menu
				nui = {
					position = "50%",
					size = nil,
					relative = "editor",
					border = {
						style = "rounded",
					},
					buf_options = {
						swapfile = false,
						filetype = "DressingSelect",
					},
					win_options = {
						winblend = 0,
					},
					max_width = 80,
					max_height = 40,
					min_width = 40,
					min_height = 10,
				},

				-- Options for built-in selector
				builtin = {
					-- Display numbers for options and set up keymaps
					show_numbers = true,
					-- These are passed to nvim_open_win
					border = "rounded",
					-- 'editor' and 'win' will default to being centered
					relative = "editor",

					buf_options = {},
					win_options = {
						cursorline = true,
						cursorlineopt = "both",
						-- disable highlighting for the brackets around the numbers
						winhighlight = "MatchParen:",
						-- adds padding at the left border
						statuscolumn = " ",
					},

					-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
					-- the min_ and max_ options can be a list of mixed types.
					-- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
					width = nil,
					max_width = { 140, 0.8 },
					min_width = { 40, 0.2 },
					height = nil,
					max_height = 0.9,
					min_height = { 10, 0.2 },

					-- Set to `false` to disable
					mappings = {
						["<Esc>"] = "Close",
						["<C-c>"] = "Close",
						["<CR>"] = "Confirm",
					},

					override = function(conf)
						-- This is the config that will be passed to nvim_open_win.
						-- Change values here to customize the layout
						return conf
					end,
				},

				-- Used to override format_item. See :help dressing-format
				format_item_override = {},

				-- see :help dressing_get_config
				get_config = nil,
			},
		},
	},
}
