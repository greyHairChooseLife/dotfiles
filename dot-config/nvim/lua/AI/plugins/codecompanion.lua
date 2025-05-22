return {
	"olimorris/codecompanion.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- "j-hui/fidget.nvim",
		{
			"echasnovski/mini.diff",
			config = function()
				local diff = require("mini.diff")
				diff.setup({
					-- Disable column style
					view = { style = "number" },
					-- Disabled by default
					source = diff.gen_source.none(),
					-- Disable all default mappings
					mappings = {
						apply = "",
						reset = "",
						textobject = "",
						goto_first = "",
						goto_prev = "",
						goto_next = "",
						goto_last = "",
					},
				})
			end,
		},
		-- EXTENSIONS
		"ravitemer/codecompanion-history.nvim",
		"ravitemer/mcphub.nvim",
	},
	init = function()
		vim.cmd([[cab ccc CodeCompanionCmd]])
		vim.cmd([[cab cc CodeCompanion]]) -- inline
		vim.cmd([[cab cca CodeCompanionActions]])
	end,
	config = function()
		require("codecompanion").setup({
			display = {
				chat = {
					intro_message = "",
					show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
					separator = "=", -- The separator between the different messages in the chat buffer
					show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
					show_settings = false, -- Show LLM settings at the top of the chat buffer?
					show_token_count = false, -- Show the token count for each response?
					start_in_insert_mode = false, -- Open the chat buffer in insert mode?
					icons = {
						pinned_buffer = " ",
						watched_buffer = "󰴅 ",
					},
					window = {
						height = 0.8,
						width = math.max(math.min(math.floor(0.45 * vim.o.columns), 135), 100), -- 최대 135, 최소 100
						opts = {
							signcolumn = "yes:1",
						},
					},
				},
				action_palette = {
					width = 95,
					height = 10,
					prompt = "Prompt ", -- Prompt used for interactive LLM calls
					provider = "snacks", -- default|telescope|mini_pick
					opts = {
						show_default_actions = false, -- Show the default actions in the action palette?
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
					show_model_choices = true,
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
						---Decorate the user message before it's sent to the LLM
						prompt_decorator = function(message, adapter, context)
							return string.format([[<prompt>%s</prompt>]], message)
						end,
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
					slash_commands = require("AI.codecompanion.slash_commands"),
					tools = require("AI.codecompanion.tools"),
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
			prompt_library = require("AI.codecompanion.prompt_library"),
			opts = { system_prompt = require("AI.codecompanion.system_prompts.v1") },
			extensions = require("AI.codecompanion.extensions"),
		})

		-- MEMO:: setup custom utils
		require("AI.codecompanion.utils.basic_autocmd_as_callback").setup()
		require("AI.codecompanion.utils.diff_highlights").setup()
		require("AI.codecompanion.utils.extmarks").setup()
		require("AI.codecompanion.utils.save_english_study_records").setup()
		require("AI.codecompanion.utils.save_english_study_notes").setup()
	end,
}
