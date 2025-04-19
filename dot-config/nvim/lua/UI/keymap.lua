local map = vim.keymap.set
local opt = { noremap = true, silent = true }

local wk_map = require("utils").wk_map
wk_map({
	[",w"] = {
		group = "Window Size",
		order = { "f", "A", "U" },
		["f"] = {
			function()
				ToggleWinFix()
			end,
			desc = "fix (toggle)",
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
