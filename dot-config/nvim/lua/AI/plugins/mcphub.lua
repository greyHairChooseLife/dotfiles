return {
	"ravitemer/mcphub.nvim",
	event = "VeryLazy",
	build = "npm install -g mcp-hub@latest",
	config = function()
		require("mcphub").setup()
	end,
}
