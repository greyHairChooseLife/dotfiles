return {
	"backdround/tabscope.nvim",
	dir = "/home/sy/Me/tabscope.nvim",
	event = "VeryLazy",
	config = function()
		local ts = require("tabscope")
		ts.setup({})

		vim.keymap.set("n", "g1", function()
			local all = ts.get_internal_representation()

			all = ts.get_buffers_for_tab()
			vim.notify(vim.inspect(all))
		end)

		-- To remove tab local buffer, use remove_tab_buffer
		vim.keymap.set("n", "g;", ts.remove_tab_buffer)
	end,
}

-- return {
-- 	"tiagovla/scope.nvim",
-- 	event = "VeryLazy",
-- 	config = true,
-- }
