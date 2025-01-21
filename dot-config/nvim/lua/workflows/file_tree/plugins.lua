return {
	{
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
			on_attach = require("workflows.file_tree.keymap").nvim_tree_on_attach,
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
	},

	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		opts = {
			-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
			-- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
			default_file_explorer = false,
			-- Id is automatically added at the beginning, and name at the end
			-- See :help oil-columns
			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			-- Buffer-local options to use for oil buffers
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			-- Window-local options to use for oil buffers
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
			delete_to_trash = true,
			-- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
			skip_confirm_for_simple_edits = false,
			-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
			-- (:help prompt_save_on_select_new_entry)
			prompt_save_on_select_new_entry = true,
			-- Oil will automatically delete hidden buffers after this delay
			-- You can set the delay to false to disable cleanup entirely
			-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				-- Enable or disable LSP file operations
				enabled = true,
				-- Time to wait for LSP file operations to complete before skipping
				timeout_ms = 1000,
				-- Set to true to autosave buffers that are updated with LSP willRenameFiles
				-- Set to "unmodified" to only save unmodified buffers
				autosave_changes = false,
			},
			-- Constrain the cursor to the editable parts of the oil buffer
			-- Set to `false` to disable, or "name" to keep it on the file names
			constrain_cursor = "editable",
			-- Set to true to watch the filesystem for changes and reload oil
			watch_for_changes = false,
			-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
			-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
			-- Additionally, if it is a string that matches "actions.<name>",
			-- it will use the mapping at require("oil.actions").<name>
			-- Set to `false` to remove a keymap
			-- See :help oil-actions for a list of all available actions
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				-- ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
				-- ["<C-x>"] = { "actions.select", opts = { split = "belowright" }, desc = "Open the entry in a horizontal split" },
				-- ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
				["<C-p>"] = "actions.preview",
				["ge"] = function() -- 저장 후 oil 버퍼를 nvim-tree버퍼로 치환
					local oil = require("oil")
					oil.save({ confirm = false }, function()
						oil.close()
						vim.cmd("NvimTreeOpen")
						vim.cmd("wincmd p | q | wincmd p | echon")
					end)
				end,
				["gw"] = function()
					vim.notify("USE 'ge' to save, or 'gq' to close without saving", 3, { title = "Oil" })
				end,
				["gq"] = function() -- (저장x)취소 후 oil 버퍼를 nvim-tree버퍼로 치환
					local oil = require("oil")
					oil.close()
					vim.cmd("NvimTreeOpen")
					vim.cmd("wincmd p | q | wincmd p | echon")
				end,
				["<C-l>"] = "actions.refresh",
				["<BS>"] = "actions.parent",
				["`"] = "actions.cd",
				["~"] = {
					"actions.cd",
					opts = { scope = "tab" },
					desc = ":tcd to the current oil directory",
					mode = "n",
				},
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				[",d"] = "actions.open_cwd",
				[",,d"] = "",
				["-"] = "",
			},
			-- Set to false to disable all of the above keymaps
			use_default_keymaps = true,
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = false,
				-- This function defines what is considered a "hidden" file
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, ".")
				end,
				-- This function defines what will never be shown, even when `show_hidden` is set
				is_always_hidden = function(name, bufnr)
					return false
				end,
				-- Sort file names in a more intuitive order for humans. Is less performant,
				-- so you may want to set to false if you work with large directories.
				natural_order = true,
				-- Sort file and directory names case insensitive
				case_insensitive = false,
				sort = {
					-- sort order can be "asc" or "desc"
					-- see :help oil-columns to see which columns are sortable
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			-- Extra arguments to pass to SCP when moving/copying files over SSH
			extra_scp_args = {},
			-- EXPERIMENTAL support for performing file operations with git
			git = {
				-- Return true to automatically git add/mv/rm files
				add = function(path)
					return false
				end,
				mv = function(src_path, dest_path)
					return false
				end,
				rm = function(path)
					return false
				end,
			},
			-- Configuration for the floating window in oil.open_float
			float = {
				-- Padding around the floating window
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- preview_split: Split direction: "auto", "left", "right", "above", "below".
				preview_split = "left",
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				override = function(conf)
					return conf
				end,
			},
			-- Configuration for the actions floating preview window
			preview = {
				-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a single value or a list of mixed integer/float types.
				-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
				max_width = 0.9,
				-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
				min_width = { 40, 0.4 },
				-- optionally define an integer/float for the exact width of the preview window
				width = nil,
				-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_height and max_height can be a single value or a list of mixed integer/float types.
				-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
				max_height = 0.9,
				-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
				min_height = { 5, 0.1 },
				-- optionally define an integer/float for the exact height of the preview window
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- Whether the preview window is automatically updated when the cursor is moved
				update_on_cursor_moved = false,
			},
			-- Configuration for the floating progress window
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},
			-- Configuration for the floating SSH window
			ssh = {
				border = "rounded",
			},
			-- Configuration for the floating keymaps help window
			keymaps_help = {
				border = "rounded",
			},
		},
	},

	{
		"ThePrimeagen/harpoon",
		lazy = false,
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			-- REQUIRED
			harpoon:setup({
				settings = {
					save_on_toggle = false,
					sync_on_ui_close = true,
					key = function()
						return vim.loop.cwd()
					end,
				},
			})
			-- REQUIRED

			vim.keymap.set("n", "<leader><space>a", function()
				harpoon:list():add()
				vim.notify("Added to Harpoon", "info", { title = "Harpoon" })
			end)
			vim.keymap.set("n", "<leader><space>b", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)

			vim.keymap.set("n", "<leader><space>1", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<leader><space>2", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<leader><space>3", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<leader><space>4", function()
				harpoon:list():select(4)
			end)
			vim.keymap.set("n", "<leader><space>5", function()
				harpoon:list():select(4)
			end)

			vim.keymap.set("n", "<C-h>", function()
				if vim.bo.filetype == "NvimTree" then
					harpoon.ui:toggle_quick_menu(harpoon:list())
					return
				end

				if vim.bo.filetype == "harpoon" then
					if vim.fn.line(".") == 1 then
						vim.cmd("normal j")
						return
					end

					vim.cmd("normal k")
					return
				end

				local success, _ = pcall(function()
					harpoon:list():prev({ ui_nav_wrap = true })
				end)
				if not success then
					harpoon:list():prev({ ui_nav_wrap = true })
				end
			end) -- ui_nav_wrap will cycle the list

			vim.keymap.set("n", "<C-l>", function()
				if vim.bo.filetype == "NvimTree" then
					harpoon.ui:toggle_quick_menu(harpoon:list())
					return
				end

				if vim.bo.filetype == "harpoon" then
					-- 현재 커서가 마지막 라인이라면
					if vim.fn.line(".") == vim.fn.line("$") then
						-- 커서를 마지막 라인으로 이동
						vim.cmd("normal k")
						return
					end
					vim.cmd("normal j")
					return
				end

				harpoon:list():next({ ui_nav_wrap = true })
			end)

			harpoon:extend({
				UI_CREATE = function(cx)
					vim.keymap.set("n", "<C-v>", function()
						harpoon.ui:select_menu_item({ vsplit = true })
					end, { buffer = cx.bufnr })

					vim.keymap.set("n", "<C-x>", function()
						harpoon.ui:select_menu_item({ split = true })
						vim.cmd("WinShift down")
						vim.cmd("WinShift down")
					end, { buffer = cx.bufnr })

					vim.keymap.set("n", "<C-t>", function()
						harpoon.ui:select_menu_item({ tabedit = true })
					end, { buffer = cx.bufnr })
				end,
			})

			-- basic telescope configuration
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end
			vim.keymap.set("n", "<leader><space>B", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open harpoon window" })
		end,
	},
	{
		"letieu/harpoon-lualine",
		dependencies = {
			"ThePrimeagen/harpoon",
		},
		opts = false,
	},
}
