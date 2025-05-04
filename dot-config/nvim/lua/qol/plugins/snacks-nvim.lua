return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("snacks").setup({
			picker = require("picker.plugins.configs.snacks-picker"),
			scroll = require("UI.plugins.configs.snacks-scroll"),
			bigfile = { enabled = true },
		})
	end,
}
