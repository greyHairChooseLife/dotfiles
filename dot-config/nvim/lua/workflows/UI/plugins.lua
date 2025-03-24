return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
				light_style = "day", -- The theme is used when the background is set to light
				transparent = false, -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "dark", -- style for sidebars, see below
					floats = "dark", -- style for floating windows
				},
				day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
				dim_inactive = false, -- dims inactive windows
				lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
				--- You can override specific color groups to use other groups or a hex color
				--- function will be called with a ColorScheme table
				---@param colors ColorScheme
				on_colors = function(colors) end,
				--- You can override specific highlights to use other groups or a hex color
				--- function will be called with a Highlights and ColorScheme table
				---@param highlights tokyonight.Highlights
				---@param colors ColorScheme
				on_highlights = function(highlights, colors) end,
				cache = true, -- When set to true, the theme will be cached for better performance
				---@type table<string, boolean|{enabled:boolean}>
				plugins = {
					-- enable all plugins when not using lazy.nvim
					-- set to false to manually enable/disable plugins
					all = package.loaded.lazy == nil,
					-- uses your plugin manager to automatically enable needed plugins
					-- currently only lazy.nvim is supported
					auto = true,
					-- add any plugins here that you want to enable
					-- for all possible plugins, see:
					--   * https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
					-- telescope = true,
				},
			})

			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		-- enabled = false,
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local utils = require("utils")

			-- Import lualine components
			local lualine_components = require("workflows.UI.lualine_components")
			local colors = lualine_components.colors
			local my_theme = lualine_components.theme

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = my_theme,
					-- component_separators = { left = '', right = '' },
					-- section_separators = { left = '', right = '' },
					-- component_separators = { left = ' 󰪍󰪍 ', right = '' },
					-- section_separators = { left = '', right = '' },󰪍󰪍
					component_separators = { left = "%#CustomSeparator#█", right = "" },
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
							"copilot-chat",
							"copilot-overlay",
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
									return " "
								else
									return " "
								end
							end,
							padding = { left = 0, right = 1 },
							color = function()
								if vim.bo.modified then
									return { fg = colors.red2 }
								elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
									return { fg = colors.red2 }
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
					lualine_x = {
						{
							winfix_status,
							padding = { left = 1, right = 1 },
							color = {
								bg = colors.black,
								fg = colors.wwhite,
							},
						},
						{
							search_counter,
							padding = { left = 2, right = 1 },
							color = {
								bg = colors.search,
							},
						},
					},
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
						{ "location", padding = { left = 1, right = 1 } },
						{ "progress", padding = { left = 0, right = 1 } },
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
									return "󰈸󰈸󰈸"
								elseif vim.bo.readonly or vim.bo.buftype == "nowrite" or vim.bo.buftype == "nofile" then
									return " "
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
					lualine_y = {
						{
							winfix_status,
							padding = { left = 1, right = 1 },
							color = {
								bg = colors.black,
								fg = colors.wwhite,
							},
						},
						{
							copilot_chat,
							padding = { left = 2, right = 1 },
							color = {
								bg = colors.search,
							},
						},
						{
							search_counter,
							padding = { left = 2, right = 1 },
							color = {
								bg = colors.search,
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
				extensions = {
					lualine_components.my_terminal,
					lualine_components.my_quickfix,
					lualine_components.my_nvimTree,
					lualine_components.my_fugitive,
					lualine_components.my_oil,
					lualine_components.my_copilot_chat,
				},
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

				table.insert(result, " origin/main..HEAD")
				table.insert(result, "")

				local workload_output = vim.fn.system("git log --oneline origin/main..HEAD")
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
					":cd ~/Documents/dev-wiki | :Git pull --ff-only | :cd ~/Documents/job-wiki | :Git pull --ff-only<CR>"
				),
				dashboard.button("1", "dev", ":cd ~/Documents/dev-wiki | :VimwikiIndex<CR>"),
				dashboard.button("2", "job", ":cd ~/Documents/job-wiki | :2VimwikiIndex<CR>"),
				dashboard.button(".", "", ""),
				dashboard.button("q", "                   ---------  configs   ", ":q<CR>"),
				dashboard.button("lz", "󰂖 lazy plugins", ":Lazy<CR>"),
				dashboard.button("i3", " i3", ":cd ~/.config/i3 | e config<CR>"),
				dashboard.button("te", " term", ":cd ~/.config/alacritty | e alacritty.toml<CR>"),
				dashboard.button("tm", " tmux", ":cd ~/.config/tmux | e tmux.conf<CR>"),
				dashboard.button("vi", " vi", ":cd ~/.config | e nvim<CR>"),
				dashboard.button("ba", " bash", ":cd ~/.config | e bash.sub/<CR>"),
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
				char = "▏",
				show_start = false,
				show_end = false,
				injected_languages = true,
				priority = 1000,
				-- exclude = { language = { "lua" } },
			},
			exclude = {
				filetypes = {
					"css",
				},
			},
		},
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
		enabled = false,
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
				width = 0.5, -- width of the focus window
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
			on_open = function(_win)
				require("utils").setOpt(
					"winhighlight",
					"Normal:NoteBackground,FloatBorder:NoteBorder,FloatTitle:NoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"
				)
			end,
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

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				progress = {
					enabled = false,
				},
				signature = { auto_open = false },
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			routes = {
				{
					filter = { event = "msg_show", kind = "search_count" },
					opts = { skip = true },
				},
			},
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline_popup", -- view for rendering the cmdline. Set `cmdline` to get a classic cmdline at the bottom or try 'cmdline_popup'
				opts = {}, -- global options for the cmdline. See section on views
				---@type table<string, CmdlineFormat>
				format = {
					-- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
					-- view: (default is cmdline view)
					-- opts: any options passed to the view
					-- icon_hl_group: optional hl_group for the icon
					-- title: set to anything or empty string to hide
					-- ex)
					-- cmdline = { pattern = "^:", icon = "", lang = "vim" },
					-- search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
					-- search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
					cmdline = { lang = "vim", icon = "", conceal = false },
					search_down = { kind = "search", icon = "", lang = "regex", conceal = false },
					search_up = { kind = "search", icon = "", lang = "regex", conceal = false },
				},
			},
			messages = {
				view = "mini",
			},
			views = {
				cmdline_popup = {
					position = {
						row = "50%",
						col = "50%",
					},
					size = {
						width = 60,
						height = "auto",
					},
					border = {
						-- style = require("utils").borders.full,
						style = "rounded",
						padding = { 0, 0 },
					},
					filter_options = {},
					win_options = {
						-- winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					},
				},
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
}
