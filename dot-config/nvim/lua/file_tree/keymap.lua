local wk_map = require("utils").wk_map

-- MEMO:: Directory
wk_map({
	["<Space>d"] = {
		group = "Directory  - NvimTree",
		order = { "f", "t" },
		["f"] = { "<cmd>NvimTreeFocus<CR>", desc = "focus", mode = "n" },
		["t"] = { ToggleTree, desc = "toggle ", mode = "n" },
	},
})
