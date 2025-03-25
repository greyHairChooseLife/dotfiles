local IS_DEV = false

return {
	-- {
	-- 	"github/copilot.vim",
	-- 	dependencies = {
	-- 		"catppuccin/nvim",
	-- 	},
	-- 	cmd = {
	-- 		-- enable 커맨드로는 안된다. restart, status 따위를 사용하자.
	-- 		"Copilot",
	-- 	},
	-- 	-- event = "BufReadPre",
	-- 	init = function()
	-- 		vim.g.copilot_filetypes = {
	-- 			["*"] = false,
	-- 			["markdown"] = false,
	-- 			["vimwiki"] = false,
	-- 		}

	-- 		vim.g.copilot_no_tab_map = true -- <A-k>
	-- 		vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
	-- 	end,
	-- },

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = { "InsertEnter", "VeryLazy" },
		opts = {
			panel = {
				enabled = false,
				auto_refresh = false,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>",
				},
				layout = {
					position = "bottom", -- | top | left | right | horizontal | vertical
					ratio = 0.4,
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = false,
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<A-k>",
					dismiss = "<A-h>",
					accept_word = false, -- <A-l> 키맵
					accept_line = "<A-j>",
					prev = "<A-p>",
					next = "<A-n>",
				},
			},
			filetypes = {
				["."] = false,
			},
			copilot_node_command = "node", -- Node.js version must be > 18.x
			server_opts_overrides = {},
		},
	},

	{
		"yetone/avante.nvim",
		-- MEMO:
		--
		-- HOW TO INSTALL
		--  https://github.com/yetone/avante.nvim/issues/581#issuecomment-2394807552 packer 전용 플러그인 정의
		--  https://github.com/yetone/avante.nvim/issues/612#issuecomment-2375729928 설치 후 build 방법
		--  https://github.com/yetone/avante.nvim/issues/612#issuecomment-2401169692 config에 앞서 avante_lib을 불러와야한다.
		build = "make BUILD_FROM_SOURCE=true",
		-- lazy = false,
		cmd = {
			"AvanteAsk",
			"AvanteFocus",
			"AvanteChat",
			"AvanteToggle",
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

	{
		-- dir = IS_DEV and "~/research/CopilotChat.nvim" or nil,
		"CopilotC-Nvim/CopilotChat.nvim",
		cmd = {
			"CopilotChat",
			"CopilotChatOpen",
			"CopilotChatClose",
			"CopilotChatToggle",
			"CopilotChatStop",
			"CopilotChatReset",
			"CopilotChatSave",
			"CopilotChatLoad",
			"CopilotChatPrompts",
			"CopilotChatModels",
			"CopilotChatAgents",
			"CopilotChatCommit",
			"CopilotChatExplain",
			"CopilotChatReview",
			"CopilotChatFix",
			"CopilotChatOptimize",
			"CopilotChatDocs",
			"CopilotChatTests",
			"CopilotChatReviewCommit",
			"CopilotChatBetterNamings",
		},
		dependencies = {
			-- { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			model = "claude-3.7-sonnet",
			agent = "copilot",
			context = "#buffers",
			-- sticky = "#buffers",

			-- highlight_headers = true,
			question_header = "  󰟷  ", -- Header to use for user questions
			answer_header = "  󱞩 Copilot   ", -- Header to use for AI answers
			separator = "", -- Separator to use in chat
			error_header = "[!ERROR]  Error ",
			references_display = "write",
			show_help = false, -- Shows help message as virtual lines when waiting for user input
			insert_at_end = false,
			selection = false, -- Have no predefined context by default
			debug = false, -- Enable debug logging (same as 'log_level = 'debug')

			-- providers = {
			-- 	copilot = { "claude-3.7-sonnet" },
			-- 	github_models = {},
			-- 	copilot_embeddings = {},
			-- },

			prompts = {
				Explain = {
					prompt = "Write an explanation for the selected code as paragraphs of text.",
					system_prompt = "COPILOT_EXPLAIN",
				},
				Review = {
					prompt = "Review the selected code.",
					system_prompt = "COPILOT_REVIEW",
				},
				Fix = {
					prompt = "There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.",
				},
				Optimize = {
					prompt = "Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.",
				},
				Docs = {
					prompt = "Please add documentation comments to the selected code.",
					model = "claude-3.5-sonnet",
				},
				Tests = {
					prompt = "Please generate tests for my code.",
				},
				Commit = {
					prompt = "Write a commit message following the commitizen convention.  \
- Title: Under 50 characters, in English  \
- Body: In Korean, wrapped at 72 characters  \
- Format as a `gitcommit` code block  \
- Body should be concise, using bullet points with `-` icon  \
- Avoid full sentences, use imperative and concise phrases ",
					context = "git:staged",
					model = "claude-3.5-sonnet",
					callback = function(response)
						require("CopilotChat").close()
						-- Extract just the commit message from inside the gitcommit code block
						local commit_message = response:match("```gitcommit\n(.-)\n```") or response
						vim.fn.setreg("+", commit_message)

						vim.cmd("silent G commit")
						-- Wait briefly for the commit buffer to open, then paste the response
						vim.defer_fn(function()
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("P", true, false, true), "n", false)
						end, 100)
					end,
				},
				ReviewCommit = {
					prompt = "Please read the provided Git diff and write a concise technical report in Korean, following the structure below. Respond only in Korean.\
Structure:\
- Title: One-line summary\
- Summary of Changes\
- Description of Functional or Behavioral Impact",
					-- - Risks and Suggestions for Improvement\
					-- - Areas That Require Testing or Verification",
					context = {
						"system:`git --no-pager log -p HEAD^..HEAD`",
						"system:`git diff --name-only HEAD^..HEAD | xargs -I {} sh -c 'echo ===== {}; git show HEAD^:{}'`", -- full file contents related
					},

					-- model = "claude-3.5-sonnet",
				},
				BetterNamings = {
					prompt = "Please provide better names for the following variables and functions.",
					model = "claude-3.5-sonnet",
				},
			},

			contexts = {
				-- BUG:: WORK IN PROGRESS
				-- chaged_files = {
				-- 	resolve = function()
				-- 		local get_context = require("workflows.AI.get_context")
				-- 		local changed_list = get_context.get_changed_files()
				-- 		local context = get_context.read_files(changed_list)
				-- 		return context
				-- 	end,
				-- },
			},

			mappings = {
				complete = {
					insert = "<Tab>",
				},
				close = {
					normal = "gq",
					insert = "<C-c>",
				},
				toggle_sticky = {
					normal = ",st",
				},
				clear_stickies = {
					normal = ",sc",
				},
				accept_diff = {
					normal = "<C-y>",
					insert = "<C-y>",
				},
				jump_to_diff = {
					normal = "gJ",
				},
				quickfix_answers = {
					normal = ",qa",
				},
				quickfix_diffs = {
					normal = ",qd",
				},
				yank_diff = {
					normal = ",dy",
					register = '"', -- Default register to use for yanking
				},
				show_diff = {
					normal = ",dv",
					full_diff = true, -- Show full diff instead of unified diff when showing diff window
				},
				show_info = {
					normal = "gi",
				},
				show_context = {
					normal = "gc",
				},
				show_help = {
					normal = "?",
				},
			},
		},
		-- config = function(_, opts)
		-- 	local chat = require("CopilotChat")
		-- 	chat.setup(opts)
		-- end,
	},
}
