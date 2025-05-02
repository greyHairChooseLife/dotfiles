return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		scroll = {
			enabled = false,
			animate = {
				duration = { step = 15, total = 100 },
				easing = "linear",
			},
		},
	},
}
