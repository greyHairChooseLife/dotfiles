return {
	"neovim/nvim-lspconfig",
	lazy = false,
	event = { "BufReadPre" },
	dependencies = {
		"saghen/blink.cmp",
		{
			"folke/lazydev.nvim",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		local servers = {
			lua_ls = {},
			html = {},
			superhtml = {},
			ts_ls = {},
			ruff = {
				init_options = {
					settings = { showSyntaxErrors = false },
					-- not working
					-- use config file (ref: https://docs.astral.sh/ruff/settings)
					-- configuration = { format = { ["quote-style"] = "single" } },
				},
			},
			pylsp = {
				settings = {
					pylsp = {
						pyflakes = { enabled = false },
						pycodestyle = { enabled = false },
						autopep8 = { enabled = false },
						yapf = { enabled = false },
						mccabe = { enabled = false },
						pylsp_mypy = { enabled = false },
						pylsp_black = { enabled = false },
						pylsp_isort = { enabled = false },
						-- plugins = {
						-- 	pycodestyle = {
						-- 		ignore = { "W391" },
						-- 		maxLineLength = 100,
						-- 	},
						-- },
					},
				},
			},
			basedpyright = {
				settings = {
					basedpyright = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
							typeCheckingMode = "basic",
							diagnosticSeverityOverrides = {
								reportAny = false,
								reportMissingTypeArgument = false,
								reportMissingTypeStubs = false,
								reportUnknownArgumentType = false,
								reportUnknownMemberType = false,
								reportUnusedParameter = "warning",
								reportMissingParameterType = "none",
								reportUnknownParameterType = false,
								reportUnknownVariableType = false,
								reportUnusedCallResult = false,
								reportUnusedVariable = "warning",
								reportUnusedImport = "warning",
							},
						},
					},
				},
			},
		}
		local disabled_server = { "pylsp" }

		for server, config in pairs(servers) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)

			if vim.tbl_contains(disabled_server, server) then
				vim.lsp.enable(server, false)
			else
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end
	end,
}
