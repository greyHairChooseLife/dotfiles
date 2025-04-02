local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>>>>> Noice.nvim
-- DEPRECATED:: 2025-02-03
-- map("n", "<Space>n", "<cmd>NoiceDismiss<CR>")

-- DEPRECATED:: 2025-02-06, which-key
-- map("n", ",.N", "<cmd>Noice telescope<CR>") -- N for Noice
-- <<<<<<<<<<<<<<<<<<<<

local wk_map = require("utils").wk_map
wk_map({
	[",w"] = {
		group = "Window Size",
		order = { "t", "A", "U" },
		["t"] = {
			function()
				ToggleWinFix()
			end,
			desc = "toggle fix",
			mode = "n",
		},
		["A"] = {
			function()
				ToggleAllWinFix()
			end,
			desc = "fix all",
			mode = "n",
		},
		["U"] = {
			function()
				UnfixAllWindows()
			end,
			desc = "unfix all",
			mode = "n",
		},
	},
})
