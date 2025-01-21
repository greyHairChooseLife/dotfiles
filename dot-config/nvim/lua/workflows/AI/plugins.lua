return {
	{
		"github/copilot.vim",
		event = "BufReadPre",
	},

	{
		-- MEMO:
		--
		-- HOW TO INSTALL
		--  https://github.com/yetone/avante.nvim/issues/581#issuecomment-2394807552 packer 전용 플러그인 정의
		--  https://github.com/yetone/avante.nvim/issues/612#issuecomment-2375729928 설치 후 build 방법
		--  https://github.com/yetone/avante.nvim/issues/612#issuecomment-2401169692 config에 앞서 avante_lib을 불러와야한다.
		"yetone/avante.nvim",
		build = "make BUILD_FROM_SOURCE=true",
		-- lazy = false,
		cmd = {
			"AvanteAsk",
			"AvanteFocus",
			"AvanteChat",
		},
		version = false,
		BUILD_FROM_SOURCE = true,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- "HakonHarnes/img-clip.nvim",
		},
		config = function()
			require("avante_lib").load()
			require("avante").setup({
				---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
				-- provider = "claude", -- Recommend using Claude
				provider = "claude", -- Recommend using Claude
				auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
				-- claude = {
				--   endpoint = "https://api.anthropic.com",
				--   model = "claude-3-5-sonnet-latest",
				--   -- model = "claude-3-5-haiku-20241022", -- yet no supported
				--   temperature = 0,
				--   max_tokens = 4096,
				-- },
				behaviour = {
					auto_suggestions = false, -- Experimental stage
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = false,
					support_paste_from_clipboard = false,
				},
				mappings = {
					--- @class AvanteConflictMappings
					diff = {
						ours = "co",
						theirs = "cu",
						all_theirs = "ca",
						both = "cb",
						cursor = "c<Space>",
						next = "]x",
						prev = "[x",
					},
					suggestion = {
						accept = "<M-l>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
					jump = {
						next = "cn",
						prev = "cp",
					},
					submit = {
						normal = "<CR>",
						insert = "<C-s>",
					},
					sidebar = {
						apply_all = "A",
						apply_cursor = "a",
						switch_windows = "<Tab>",
						reverse_switch_windows = "<S-Tab>",
					},
				},
				hints = { enabled = false },
				windows = {
					---@type "right" | "left" | "top" | "bottom"
					position = "right", -- the position of the sidebar
					wrap = true, -- similar to vim.o.wrap
					width = 50, -- default % based on available width
					sidebar_header = {
						align = "right", -- left, center, right for title
						rounded = false,
					},
					ask = {
						start_insert = false,
					},
				},
				highlights = {
					---@type AvanteConflictHighlights
					diff = {
						current = "DiffDelete",
						incoming = "DiffAdd",
					},
				},
				--- @class AvanteConflictUserConfig
				diff = {
					autojump = true,
					---@type string | fun(): any
					-- list_opener = "copen",
				},
				--- @class AvanteRepoMapConfig
				repo_map = {
					ignore_patterns = { "%.git", "%.worktree", "__pycache__", "node_modules" }, -- ignore files matching these
				},
				--- https://github.com/yetone/avante.nvim/commit/a1da070
				--- @class AvanteFileSelectorConfig
				--- @field provider "native" | "fzf" | "telescope"
				file_selector = {
					-- e.g native, fzf, telescope
					-- native for vim.ui.select
					provider = "telescope",
					-- Options override for custom providers
					provider_opts = {},
				},
			})
		end,
	},
}
