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
	opts = {
		servers = {
			-- lua_ls = {},
			-- html = {},
			-- START_debug:
			-- ts_ls = {},
			-- basedpyright = {},
			-- END___debug:
		},
	},
	config = function(_, opts)
		local lspconfig = require("lspconfig")
		for server, config in pairs(opts.servers) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			lspconfig[server].setup(config)
		end

		-- REF: https://www.reddit.com/r/neovim/comments/1heow4i/why_are_not_all_basedpyright_features_working/
		lspconfig.basedpyright.setup({
			-- on_attach = function(client, bufnr)
			-- 	client.server_capabilities.document_formatting = false
			-- 	client.server_capabilities.semanticTokensProvider = nil
			-- 	require("lsp.attach").on_attach(client, bufnr)
			-- end,
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
							reportMissingParameterType = "none",
							reportUnusedParameter = "warning",
							reportUnknownParameterType = false,
							reportUnknownVariableType = false,
							reportUnusedCallResult = false,
							reportUnusedVariable = "warning",
							reportUnusedImport = "warning",
						},
					},
				},
				python = {},
			},
		})
	end,
}
