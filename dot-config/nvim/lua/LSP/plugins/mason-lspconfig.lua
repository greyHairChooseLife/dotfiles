return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"html",
				"biome",
				-- START_debug:
				-- "ts_ls",
				-- "basedpyright",
				-- END___debug:
			},
		})
	end,
}
