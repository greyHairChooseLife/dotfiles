return {
	"folke/snacks.nvim",
	priority = 1000,
	commit = "f6c8e80dd724453a6d06e0af08dd4bb06f5505c0",
	-- NOTE: to fix some bug, use this PR
	--  https://github.com/folke/snacks.nvim/pull/1525
	--  https://github.com/folke/snacks.nvim/issues/1524
	lazy = false,
	config = function()
		require("snacks").setup({
			image = { enabled = not require("utils").is_alacritty or true },
			picker = require("picker.plugins.configs.snacks-picker"),
			scroll = require("UI.plugins.configs.snacks-scroll"),
			bigfile = { enabled = true },
		})
	end,
}
