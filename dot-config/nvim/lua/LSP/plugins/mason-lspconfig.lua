return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"html",
				"superhtml",
				"biome",
				"ts_ls",
				"pylsp",
				"ruff",
				"basedpyright",
			},
			---@type boolean | string[] | { exclude: string[] }
			automatic_enable = false,
		})
	end,
}
