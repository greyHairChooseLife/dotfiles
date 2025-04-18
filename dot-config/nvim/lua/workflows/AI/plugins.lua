local IS_DEV = false

return {
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
					accept_word = false, -- 이어지는 suggestion을 위해 별도 설정
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
		"olimorris/codecompanion.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- "ravitemer/mcphub.nvim",
			-- "j-hui/fidget.nvim",
			"echasnovski/mini.diff",
		},
		init = function()
			vim.cmd([[cab ccc CodeCompanionCmd]])
			vim.cmd([[cab cci CodeCompanion]])
		end,
		config = function()
			local codecompanion = require("codecompanion")
			-- Set up function to sync mini.diff highlights with current colorscheme
			local function sync_diff_highlights()
				-- Link the MiniDiff's custom highlights to the default diff highlights
				-- Set highlight color for added lines to match the default DiffAdd highlight
				vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { link = "DiffAdd" })
				-- Set highlight color for deleted lines to match the default DiffDelete highlight
				vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { link = "DiffDelete" })
				-- Set highlight color for changed lines to match the default DiffChange highlight
				vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffChange" })
				-- Set highlight color for context lines to match the default DiffText highlight
				vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "DiffText" })
			end

			-- Initial highlight setup
			sync_diff_highlights()

			-- Update highlights when colorscheme changes
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = sync_diff_highlights,
				group = vim.api.nvim_create_augroup("CodeCompanionDiffHighlights", {}),
			})

			require("codecompanion").setup({
				display = {
					chat = {
						intro_message = "",
						show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
						separator = "=", -- The separator between the different messages in the chat buffer
						show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
						show_settings = false, -- Show LLM settings at the top of the chat buffer?
						show_token_count = true, -- Show the token count for each response?
						start_in_insert_mode = false, -- Open the chat buffer in insert mode?
						icons = {
							pinned_buffer = " ",
							watched_buffer = "󰴅 ",
						},
						window = {
							height = 0.8,
							width = math.max(math.min(math.floor(0.45 * vim.o.columns), 135), 100), -- 최대 135, 최소 100
						},
					},
					action_palette = {
						width = 95,
						height = 10,
						prompt = "Prompt ", -- Prompt used for interactive LLM calls
						provider = "telescope", -- default|telescope|mini_pick
						opts = {
							show_default_actions = true, -- Show the default actions in the action palette?
							show_default_prompt_library = false, -- Show the default prompt library in the action palette?
						},
					},
					diff = {
						enabled = true,
						close_chat_at = 1,
						provider = "mini_diff",
						opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
					},
				},
				adapters = {
					opts = {
						show_defaults = false,
					},
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "claude-3.7-sonnet",
									-- default = "claude-3.7-sonnet-thought",
								},
							},
						})
					end,
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {})
					end,
				},
				strategies = {
					chat = {
						roles = {
							---The header name for the LLM's messages
							---@type string|fun(adapter: CodeCompanion.Adapter): string
							llm = function(adapter)
								return " 󱞩   _" .. adapter.formatted_name
							end,

							---The header name for your messages
							---@type string
							user = " 󰟷",
						},
						keymaps = {
							close = { modes = { n = "<C-c>", i = "<C-c>" } },
							send = { modes = { i = { "<C-s>", "<A-Enter>" } } },
							stop = { modes = { n = "gs" } },
							pin = { modes = { n = "grp" } },
							watch = { modes = { n = "grw" } },
							clear = { modes = { n = "gX" } },
							previous_header = { modes = { n = "<C-p>" } },
							next_header = { modes = { n = "<C-n>" } },
							previous_chat = { modes = { n = "]]" } },
							next_chat = { modes = { n = "[[" } },
							system_prompt = { modes = { n = "gts" } }, -- toggle system prompts
							regenerate = { modes = { n = "gR" } },
						},
						adapter = "copilot",
						slash_commands = require("workflows.AI.codecompanion.slash_commands"),
						-- tools = require("workflows.AI.codecompanion.tools"),
						-- variables = {},
					},
					inline = {
						adapter = "copilot",
						keymaps = {
							accept_change = { modes = { n = "ca" } },
							reject_change = { modes = { n = "cr" } },
						},
					},
				},
				prompt_library = {
					-- touch default
					["Generate a Commit Message"] = {
						opts = { is_slash_cmd = false, short_name = "[deprecated] commit" },
					},
					-- custom
					["Review Commit"] = require("workflows.AI.function.codecompanion-review_commit"),
					["Generate CommitMsg"] = require("workflows.AI.function.codecompanion-generate_commit_msg"),
					["Analyze Git Status for branching commits"] = require(
						"workflows.AI.function.codecompanion-analyze_git_status"
					),
					["Load Full-context of the git status"] = require(
						"workflows.AI.function.codecompanion-get_full_git_status_reference"
					),
				},
				opts = {
					-- system_prompt = require("workflows.AI.codecompanion.system_prompt"),
				},
			})

			-- START_debug:
			-- local function compact_reference(messages)
			-- 	local refs = {}
			-- 	local result = {}

			-- 	-- First loop to find last occurrence of each reference
			-- 	for i, msg in ipairs(messages) do
			-- 		if msg.opts and msg.opts.reference then
			-- 			refs[msg.opts.reference] = i
			-- 		end
			-- 	end

			-- 	-- Second loop to keep messages with unique references
			-- 	for i, msg in ipairs(messages) do
			-- 		local ref = msg.opts and msg.opts.reference
			-- 		if not ref or refs[ref] == i then
			-- 			table.insert(result, msg)
			-- 		end
			-- 	end

			-- 	return result
			-- end

			-- vim.api.nvim_create_autocmd({ "User" }, {
			-- 	pattern = "CodeCompanionRequestFinished",
			-- 	callback = function(request)
			-- 		if request.data.strategy ~= "chat" then
			-- 			return
			-- 		end
			-- 		local current_chat = codecompanion.last_chat()
			-- 		if not current_chat then
			-- 			return
			-- 		end
			-- 		-- local config = require("codecompanion.config")
			-- 		-- local add_reference = require("workflows.AI.codecompanion.utils.add_reference")
			-- 		--
			-- 		-- add_reference(current_chat, {
			-- 		--   role = config.constants.USER_ROLE,
			-- 		--   content = string.format("# Environment\n- Current Time: %s\n", os.date("%c")),
			-- 		-- }, "system_prompt", "environment")
			-- 		current_chat.messages = compact_reference(current_chat.messages)
			-- 	end,
			-- })
			-- END___debug:
		end,
	},
}
